# import debugpy; debugpy.connect(('127.0.0.1', 5688))
"""
Enhanced Spider2 evaluation script with comprehensive column and row comparison functionality.

This script evaluates SQL query results with robust comparison metrics:

Column Comparison:
- Column name normalization (lowercase, strip whitespace)
- Precision/Recall/F1 scores for column matching
- Tracks True Positives (matched columns), False Positives (extra columns), False Negatives (missing columns)
- Penalizes extra columns (reduces precision) and missing columns (reduces recall)

Row Comparison:
- Efficient two-stage process: column normalization first, then row comparison
- Compares only common columns between predicted and gold dataframes
- Normalizes values: string case handling, float tolerance (0.01), handles mixed data types
- Greedy row-wise matching to handle duplicates correctly
- Precision/Recall/F1 scores based on matched rows
- Tracks matched rows (TP), extra rows (FP), and missing rows (FN)

Key Optimization:
- Column normalization is performed once and reused for both column and row comparisons
- Row comparison only operates on columns that exist in both dataframes
- This ensures consistency and improves performance

Generates comprehensive reports with both summary statistics and detailed per-instance metrics.
"""
import json
import re
from numpy import save
import pandas as pd
import math
import duckdb
from typing import List, Union
import os
import os.path as osp
import pandas as pd
import argparse
from google.cloud import bigquery
import shutil
import sqlite3
from tqdm import tqdm
import snowflake.connector
import logging

import sys
class TeeOutput:
    """Simple tee-like stream that writes to console and a file.

    This class mirrors writes to stdout/stderr into a log file while still
    printing to the console. Useful to keep a persistent log of the run.

    Attributes:
        console: The original stdout stream
        file:    The open file handle where logs are persisted
    """

    def __init__(self, filename):
        """Initialize the tee output.

        Args:
            filename: Path of the file to write mirrored output to.
        """
        self.console = sys.stdout
        self.file = open(filename, 'w')
    
    def write(self, message):
        """Write a message to both console and file."""
        self.console.write(message)
        self.file.write(message)
    
    def flush(self):
        """Flush both console and file buffers."""
        self.console.flush()
        self.file.flush()
    
    def close(self):
        """Close the underlying file handle."""
        self.file.close()

sys.stdout = TeeOutput('log.txt')
sys.stderr = sys.stdout

TOTAL_GB_PROCESSED = 0.0


byte_output_dict = {}

# Configure error logging to a dedicated file
logging.basicConfig(
    level=logging.ERROR,
    format='%(asctime)s | %(levelname)s | %(message)s',
    filename='errors.log',
    filemode='a'
)

def log_error(message: str, context=None) -> None:
    """Log a non-exception error with structured context."""
    try:
        context_json = json.dumps(context or {}, default=str)
    except Exception:
        context_json = str(context or {})
    logging.error(f"{message} | context={context_json}")

def log_exception(message: str, context=None) -> None:
    """Log an exception with stack trace and structured context."""
    try:
        context_json = json.dumps(context or {}, default=str)
    except Exception:
        context_json = str(context or {})
    logging.error(f"{message} | context={context_json}", exc_info=True)

# ---------------------------
# Column normalization helpers
# ---------------------------
# Shared synonym and stopword sets used to normalize column names consistently
SYNONYM_MAP = {
    'unique': 'distinct',
    'avg': 'average',
    'sum': 'total',
    'count': 'number',
    'qty': 'quantity',
    'amt': 'amount',
    'desc': 'description',
    'id': 'identifier',
    'max': 'maximum',
    'min': 'minimum',
    'pct': 'percentage',
    'percent': 'percentage',
    'num': 'number',
    'cust': 'customer',
    'prod': 'product',
    'trans': 'transaction',
    'cat': 'category',
    'grp': 'group',
    'dt': 'date',
    'ts': 'timestamp',
    'pk': 'primary key',
    'fk': 'foreign key',
    'cnt': 'number',
    'no': 'number',
    'nbr': 'number',
    'vol': 'volume',
    'val': 'value',
    'rev': 'revenue'
}

WORDS_TO_REMOVE = {'of', 'the', 'a', 'an'}

def normalize_column_name(col) -> str:
    """Normalize a column name consistently across the module.

    - Lowercase, trim whitespace
    - Replace underscores with spaces
    - Remove common stop-words (of, the, a, an)
    - Harmonize common synonyms word-by-word
    """
    normalized = str(col).lower().strip().replace('_', ' ')
    words = normalized.split()
    normalized_words = []
    for word in words:
        if word in WORDS_TO_REMOVE:
            continue
        elif word in SYNONYM_MAP:
            normalized_words.append(SYNONYM_MAP[word])
        else:
            normalized_words.append(word)
    return ' '.join(normalized_words)

def load_jsonl_to_dict(jsonl_file):
    """Load a JSONL file into a dictionary keyed by `instance_id`.

    Each line in the file must be a JSON object containing an `instance_id` field.

    Args:
        jsonl_file: Path to the JSONL file.

    Returns:
        dict: Mapping from instance_id to the parsed JSON object for that line.
    """
    data_dict = {}
    with open(jsonl_file, 'r') as file:
        for line in file:
            item = json.loads(line.strip())
            instance_id = item['instance_id']
            data_dict[instance_id] = item
    return data_dict

def load_json_list_to_dict(json_file_path):
    """Load a JSON list file into a dictionary keyed by `instance_id`.

    The JSON file should contain a list of objects, each with an `instance_id`.

    Args:
        json_file_path: Path to the JSON file containing a list of objects.

    Returns:
        dict: Mapping from instance_id to the corresponding object.
    """
    with open(json_file_path, 'r', encoding='utf-8') as file:
        data_list = json.load(file)
    data_dict = {item['instance_id']: item for item in data_list}
    return data_dict


def compare_columns(pred_df, gold_df):
    """Compare normalized column sets and compute precision/recall/F1.

    Column names are normalized (case-insensitive, underscores treated as spaces,
    common synonyms harmonized) before comparison.

    Args:
        pred_df: Predicted dataframe.
        gold_df: Gold standard dataframe.

    Returns:
        dict with keys:
            precision, recall, f1, tp, fp, fn,
            pred_cols_normalized, gold_cols_normalized
    """
    # Ensure inputs are DataFrames
    if not isinstance(pred_df, pd.DataFrame):
        pred_df = pd.DataFrame(pred_df)
    if not isinstance(gold_df, pd.DataFrame):
        gold_df = pd.DataFrame(gold_df)
    
    # Use shared normalizer
    pred_cols_normalized = sorted([normalize_column_name(col) for col in pred_df.columns])
    gold_cols_normalized = sorted([normalize_column_name(col) for col in gold_df.columns])
    
    # Convert to sets for comparison
    pred_set = set(pred_cols_normalized)
    gold_set = set(gold_cols_normalized)
    
    # Calculate TP, FP, FN
    tp = list(pred_set.intersection(gold_set))  # Columns in both
    fp = list(pred_set - gold_set)  # Extra predicted columns
    fn = list(gold_set - pred_set)  # Missing columns
    
    # Calculate metrics
    tp_count = len(tp)
    fp_count = len(fp)
    fn_count = len(fn)
    
    # Calculate precision, recall, and F1
    precision = tp_count / (tp_count + fp_count) if (tp_count + fp_count) > 0 else 0.0
    recall = tp_count / (tp_count + fn_count) if (tp_count + fn_count) > 0 else 0.0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0.0
    
    return {
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'tp': sorted(tp),
        'fp': sorted(fp),
        'fn': sorted(fn),
        'pred_cols_normalized': pred_cols_normalized,
        'gold_cols_normalized': gold_cols_normalized
    }


def compare_rows(pred_df, gold_df, tolerance=1e-2, case_sensitive=False):
    """Compare rows on normalized common columns with tolerant value matching.

    Steps:
    - Normalize and align common columns by name (with synonym handling)
    - Normalize cell values (case-insensitive strings, rounded floats)
    - Greedy one-to-one row matching to handle duplicates

    Args:
        pred_df: Predicted dataframe.
        gold_df: Gold standard dataframe.
        tolerance: Decimal tolerance for float rounding (default 1e-2).
        case_sensitive: Whether to compare strings case-sensitively.

    Returns:
        dict with keys: precision, recall, f1, tp, fp, fn,
        common_columns, matched_pred_indices, matched_gold_indices
    """
    # Ensure inputs are DataFrames
    if not isinstance(pred_df, pd.DataFrame):
        pred_df = pd.DataFrame(pred_df)
    if not isinstance(gold_df, pd.DataFrame):
        gold_df = pd.DataFrame(gold_df)
        
    # Find common columns (normalized)
    pred_cols_norm = {normalize_column_name(col): col for col in pred_df.columns}
    gold_cols_norm = {normalize_column_name(col): col for col in gold_df.columns}
    common_cols_norm = set(pred_cols_norm.keys()).intersection(gold_cols_norm.keys())
    
    if not common_cols_norm:
        # No common columns, all rows are false positives/negatives
        return {
            'precision': 0.0,
            'recall': 0.0,
            'f1': 0.0,
            'tp': 0,
            'fp': len(pred_df),
            'fn': len(gold_df),
            'common_columns': [],
            'matched_pred_indices': [],
            'matched_gold_indices': []
        }
    
    # Get actual column names for common columns
    pred_common_cols = [pred_cols_norm[col] for col in common_cols_norm]
    gold_common_cols = [gold_cols_norm[col] for col in common_cols_norm]
    
    # Select only common columns from both dataframes
    pred_subset = pred_df[pred_common_cols].copy()
    gold_subset = gold_df[gold_common_cols].copy()
    
    # Normalize column names to match
    pred_subset.columns = list(common_cols_norm)
    gold_subset.columns = list(common_cols_norm)
    
    def normalize_value(val):
        """Normalize a single value for comparison."""
        if pd.isna(val):
            return "NaN"
        elif isinstance(val, (int, float)):
            # Round floats to specified tolerance
            if isinstance(val, float):
                return str(round(val, int(-math.log10(tolerance))))
            return str(val)
        else:
            # Convert to string and handle case sensitivity
            str_val = str(val)
            return str_val if case_sensitive else str_val.lower()
    
    # Normalize all values in both dataframes
    for col in pred_subset.columns:
        pred_subset[col] = pred_subset[col].apply(normalize_value)
        gold_subset[col] = gold_subset[col].apply(normalize_value)
    
    # Convert rows to tuples for comparison
    pred_rows = [tuple(row) for _, row in pred_subset.iterrows()]
    gold_rows = [tuple(row) for _, row in gold_subset.iterrows()]
    
    # Create indices for tracking
    pred_indices = list(range(len(pred_rows)))
    gold_indices = list(range(len(gold_rows)))
    
    matched_pred_indices = []
    matched_gold_indices = []
    
    # Greedy matching: for each gold row, find matching pred row
    for gold_idx, gold_row in enumerate(gold_rows):
        for pred_idx_pos, pred_idx in enumerate(pred_indices):
            if pred_rows[pred_idx] == gold_row:
                # Found a match
                matched_pred_indices.append(pred_idx)
                matched_gold_indices.append(gold_idx)
                # Remove matched pred index to handle duplicates correctly
                pred_indices.pop(pred_idx_pos)
                break
    
    # Calculate metrics
    tp = len(matched_pred_indices)  # True positives: matched rows
    fp = len(pred_df) - tp  # False positives: unmatched predicted rows
    fn = len(gold_df) - tp  # False negatives: unmatched gold rows
    
    # Calculate precision, recall, and F1
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0.0
    
    return {
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'tp': tp,
        'fp': fp,
        'fn': fn,
        'common_columns': sorted(list(common_cols_norm)),
        'matched_pred_indices': matched_pred_indices,
        'matched_gold_indices': matched_gold_indices
    }


def compare_rows_on_common_columns(pred_subset, gold_subset, common_cols_norm, tolerance=1e-2, case_sensitive=False):
    """Compare rows when both dataframes are subset to the same column set.

    Args:
        pred_subset: Predicted dataframe with only common columns.
        gold_subset: Gold dataframe with only common columns.
        common_cols_norm: Normalized column names used for alignment.
        tolerance: Decimal tolerance for float rounding.
        case_sensitive: Whether to compare strings case-sensitively.

    Returns:
        dict of row comparison metrics (precision, recall, f1, tp, fp, fn, ...)
    """
    # Normalize column names to match
    pred_subset.columns = common_cols_norm
    gold_subset.columns = common_cols_norm
    
    def normalize_value(val):
        """Normalize a single value for comparison."""
        if pd.isna(val):
            return "NaN"
        elif isinstance(val, (int, float)):
            # Round floats to specified tolerance
            if isinstance(val, float):
                return str(round(val, int(-math.log10(tolerance))))
            return str(val)
        else:
            # Convert to string and handle case sensitivity
            str_val = str(val)
            return str_val if case_sensitive else str_val.lower()
    
    # Normalize all values in both dataframes
    for col in pred_subset.columns:
        pred_subset[col] = pred_subset[col].apply(normalize_value)
        gold_subset[col] = gold_subset[col].apply(normalize_value)
    
    # Convert rows to tuples for comparison
    pred_rows = [tuple(row) for _, row in pred_subset.iterrows()]
    gold_rows = [tuple(row) for _, row in gold_subset.iterrows()]
    
    # Create indices for tracking
    pred_indices = list(range(len(pred_rows)))
    matched_pred_indices = []
    matched_gold_indices = []
    
    # Greedy matching: for each gold row, find matching pred row
    for gold_idx, gold_row in enumerate(gold_rows):
        for pred_idx_pos, pred_idx in enumerate(pred_indices):
            if pred_rows[pred_idx] == gold_row:
                # Found a match
                matched_pred_indices.append(pred_idx)
                matched_gold_indices.append(gold_idx)
                # Remove matched pred index to handle duplicates correctly
                pred_indices.pop(pred_idx_pos)
                break
    
    # Calculate metrics
    tp = len(matched_pred_indices)  # True positives: matched rows
    fp = len(pred_rows) - tp  # False positives: unmatched predicted rows
    fn = len(gold_rows) - tp  # False negatives: unmatched gold rows
    
    # Calculate precision, recall, and F1
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0.0
    
    return {
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'tp': tp,
        'fp': fp,
        'fn': fn,
        'common_columns': common_cols_norm,
        'matched_pred_indices': matched_pred_indices,
        'matched_gold_indices': matched_gold_indices
    }


def compare_multi_pandas_table(pred, multi_gold, multi_condition_cols=[], multi_ignore_order=False, include_column_metrics=False, include_row_metrics=False):
    """
    Compare predicted dataframe against multiple gold standard dataframes.
    
    Args:
        pred (pd.DataFrame): Predicted dataframe
        multi_gold (list[pd.DataFrame]): List of gold standard dataframes
        multi_condition_cols (list, optional): List of condition columns for each gold df. Defaults to [].
        multi_ignore_order (bool, optional): Whether to ignore order. Defaults to False.
        include_column_metrics (bool, optional): Whether to include column comparison metrics. Defaults to False.
        include_row_metrics (bool, optional): Whether to include row comparison metrics. Defaults to False.
        
    Returns:
        Based on the metrics flags:
        - If both are False: int (1 if match, 0 otherwise)
        - If only column_metrics: tuple (data_score, best_column_metrics)
        - If only row_metrics: tuple (data_score, best_row_metrics)
        - If both are True: tuple (data_score, best_column_metrics, best_row_metrics)
    """
    # print('multi_condition_cols', multi_condition_cols)

    if multi_condition_cols == [] or multi_condition_cols == [[]] or multi_condition_cols == [None] or multi_condition_cols == None:
        multi_condition_cols = [[] for _ in range(len(multi_gold))]
    elif len(multi_gold) > 1 and not all(isinstance(sublist, list) for sublist in multi_condition_cols):
        multi_condition_cols = [multi_condition_cols for _ in range(len(multi_gold))]
    multi_ignore_order = [multi_ignore_order for _ in range(len(multi_gold))]

    best_column_metrics = None
    best_row_metrics = None
    best_column_f1 = -1
    best_row_f1 = -1
    
    for i, gold in enumerate(multi_gold):
        # For efficiency when calculating metrics, do column normalization once
        if include_column_metrics or include_row_metrics:
            # Ensure inputs are DataFrames
            if not isinstance(pred, pd.DataFrame):
                pred = pd.DataFrame(pred)
            if not isinstance(gold, pd.DataFrame):
                gold = pd.DataFrame(gold)
                
            # Get comparison results with requested metrics
            result = compare_pandas_table(pred, gold, multi_condition_cols[i], multi_ignore_order[i], 
                                        include_column_metrics=include_column_metrics,
                                        include_row_metrics=include_row_metrics)
            
            # Handle different return types based on metrics requested
            if include_column_metrics and include_row_metrics:
                data_score, column_metrics, row_metrics = result
                if data_score == 1:
                    return 1, column_metrics, row_metrics
                # Track best metrics even if data doesn't match
                if column_metrics['f1'] > best_column_f1:
                    best_column_f1 = column_metrics['f1']
                    best_column_metrics = column_metrics
                if row_metrics['f1'] > best_row_f1:
                    best_row_f1 = row_metrics['f1']
                    best_row_metrics = row_metrics
            elif include_column_metrics:
                data_score, column_metrics = result
                if data_score == 1:
                    return 1, column_metrics
                if column_metrics['f1'] > best_column_f1:
                    best_column_f1 = column_metrics['f1']
                    best_column_metrics = column_metrics
            elif include_row_metrics:
                data_score, row_metrics = result
                if data_score == 1:
                    return 1, row_metrics
                if row_metrics['f1'] > best_row_f1:
                    best_row_f1 = row_metrics['f1']
                    best_row_metrics = row_metrics
        else:
            # No metrics requested, just check data match
            if compare_pandas_table(pred, gold, multi_condition_cols[i], multi_ignore_order[i]):
                return 1
    
    # Return based on what metrics were requested
    if include_column_metrics and include_row_metrics:
        return 0, best_column_metrics, best_row_metrics
    elif include_column_metrics:
        return 0, best_column_metrics
    elif include_row_metrics:
        return 0, best_row_metrics
    else:
        return 0
        
    


def compare_pandas_table(pred, gold, condition_cols=[], ignore_order=False, include_column_metrics=False, include_row_metrics=False):
    """Two-stage comparison of predicted vs. gold dataframes.

    Stage 1: Compare normalized column headers (optionally return metrics).
    Stage 2: Compare row data on common columns (optionally return metrics).

    Args:
        pred: Predicted dataframe.
        gold: Gold standard dataframe.
        condition_cols: Explicit indices of gold columns to evaluate (optional).
        ignore_order: If True, future enhancement could ignore row order.
        include_column_metrics: Whether to compute and return column metrics.
        include_row_metrics: Whether to compute and return row metrics.

    Returns:
        If both metrics flags are False: int (1 for perfect match, else 0).
        If only columns requested: (score, column_metrics).
        If only rows requested: (score, row_metrics).
        If both requested: (score, column_metrics, row_metrics).
    """
    tolerance = 1e-2
    
    # Ensure inputs are DataFrames
    if not isinstance(pred, pd.DataFrame):
        pred = pd.DataFrame(pred)
    if not isinstance(gold, pd.DataFrame):
        gold = pd.DataFrame(gold)
    
    # Handle condition_cols to determine which columns to compare
    if condition_cols != []:
        gold_for_comparison = gold.iloc[:, condition_cols]
        gold_columns_used = gold.columns[condition_cols].tolist()
    else:
        gold_for_comparison = gold
        gold_columns_used = gold.columns.tolist()

    # Step 1: Column Comparison (use shared normalizer)
    pred_cols_norm = {normalize_column_name(col): col for col in pred.columns}
    gold_cols_norm = {normalize_column_name(col): col for col in gold_columns_used}

    print(f"\npred_cols_norm: {pred_cols_norm}")
    print(f"\ngold_cols_norm: {gold_cols_norm}")
    
    pred_set = set(pred_cols_norm.keys())
    gold_set = set(gold_cols_norm.keys())
    common_cols_norm = pred_set.intersection(gold_set)
    
    # Calculate column metrics
    column_metrics = None
    if include_column_metrics:
        # Calculate TP, FP, FN for columns
        tp = sorted(list(pred_set.intersection(gold_set)))
        fp = sorted(list(pred_set - gold_set))
        fn = sorted(list(gold_set - pred_set))
        
        tp_count = len(tp)
        fp_count = len(fp)
        fn_count = len(fn)
        
        precision = tp_count / (tp_count + fp_count) if (tp_count + fp_count) > 0 else 0.0
        recall = tp_count / (tp_count + fn_count) if (tp_count + fn_count) > 0 else 0.0
        f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0.0
        
        column_metrics = {
            'precision': precision,
            'recall': recall,
            'f1': f1,
            'tp': tp,
            'fp': fp,
            'fn': fn,
            'pred_cols_normalized': sorted(list(pred_set)),
            'gold_cols_normalized': sorted(list(gold_set))
        }
    
    # Step 2: Row Comparison (only on common columns)
    row_metrics = None
    if include_row_metrics:
        if common_cols_norm:
            # Get actual column names for common columns
            pred_common_cols = [pred_cols_norm[col] for col in common_cols_norm]
            gold_common_cols = [gold_cols_norm[col] for col in common_cols_norm]
            
            # Select only common columns from both dataframes
            pred_subset = pred[pred_common_cols].copy()
            gold_subset = gold_for_comparison[gold_common_cols].copy()
            
            # Compare rows with normalization
            row_metrics = compare_rows_on_common_columns(
                pred_subset, gold_subset, 
                sorted(list(common_cols_norm)), 
                tolerance=tolerance,
                case_sensitive=False
            )
            
            # Handle ignore_order if specified
            if ignore_order and row_metrics['f1'] < 1.0:
                # Try again with order-agnostic comparison
                # This is a simplified approach - for full implementation, 
                # you'd need to modify compare_rows_on_common_columns
                pass
        else:
            # No common columns means no rows can match
            row_metrics = {
                'precision': 0.0,
                'recall': 0.0,
                'f1': 0.0,
                'tp': 0,
                'fp': len(pred),
                'fn': len(gold_for_comparison),
                'common_columns': []
            }
    
    # Calculate overall score based on perfect matches
    # Score is 1 only if both columns and rows match perfectly
    if include_column_metrics and include_row_metrics:
        score = 1 if (column_metrics['f1'] == 1.0 and row_metrics['f1'] == 1.0) else 0
    elif include_column_metrics:
        score = 1 if column_metrics['f1'] == 1.0 else 0
    elif include_row_metrics:
        score = 1 if row_metrics['f1'] == 1.0 else 0
    else:
        # If no metrics requested, do a simple comparison
        # Check if columns match and all data matches
        if pred_set != gold_set:
            score = 0
        else:
            # Columns match, now check data
            try:
                # Simple data comparison for when metrics aren't needed
                if condition_cols != []:
                    pred_data = pred[gold_columns_used]
                    gold_data = gold_for_comparison
                else:
                    pred_data = pred
                    gold_data = gold
                    
                # Sort columns to ensure same order
                pred_data = pred_data[sorted(pred_data.columns)]
                gold_data = gold_data[sorted(gold_data.columns)]
                
                # Compare DataFrames
                if len(pred_data) != len(gold_data):
                    score = 0
                else:
                    score = 1 if pred_data.equals(gold_data) else 0
            except:
                score = 0
    
    # Return based on what metrics were requested
    if include_column_metrics and include_row_metrics:
        # Compute overall (micro-averaged) metrics across columns and rows
        try:
            col_tp = len(column_metrics['tp']) if column_metrics and 'tp' in column_metrics else 0
            col_fp = len(column_metrics['fp']) if column_metrics and 'fp' in column_metrics else 0
            col_fn = len(column_metrics['fn']) if column_metrics and 'fn' in column_metrics else 0

            row_tp = row_metrics['tp'] if row_metrics and 'tp' in row_metrics else 0
            row_fp = row_metrics['fp'] if row_metrics and 'fp' in row_metrics else 0
            row_fn = row_metrics['fn'] if row_metrics and 'fn' in row_metrics else 0

            overall_tp = col_tp + row_tp
            overall_fp = col_fp + row_fp
            overall_fn = col_fn + row_fn

            overall_precision = overall_tp / (overall_tp + overall_fp) if (overall_tp + overall_fp) > 0 else 0.0
            overall_recall = overall_tp / (overall_tp + overall_fn) if (overall_tp + overall_fn) > 0 else 0.0
            overall_f1 = 2 * (overall_precision * overall_recall) / (overall_precision + overall_recall) if (overall_precision + overall_recall) > 0 else 0.0

            overall_metrics = {
                'precision': overall_precision,
                'recall': overall_recall,
                'f1': overall_f1,
                'tp': overall_tp,
                'fp': overall_fp,
                'fn': overall_fn,
            }

            # Attach overall metrics to both dicts for downstream access without changing return shape
            if column_metrics is not None:
                column_metrics['overall'] = overall_metrics
            if row_metrics is not None:
                row_metrics['overall'] = overall_metrics
        except Exception:
            # Fail-safe: do not block return if any unexpected structure
            pass
        return score, column_metrics, row_metrics
    elif include_column_metrics:
        return score, column_metrics
    elif include_row_metrics:
        return score, row_metrics
    else:
        return score


def get_bigquery_sql_result(sql_query, is_save, save_dir=None, file_name="result.csv"):
    """Execute a BigQuery SQL query and optionally save results to CSV.

    When is_save is True, writes the full result to `save_dir/file_name`. When
    False, returns success status without persisting the result.

    Args:
        sql_query: BigQuery SQL query to execute.
        is_save: Whether to save the results to CSV.
        save_dir: Output directory for CSV when is_save is True.
        file_name: Output CSV filename.

    Returns:
        Tuple[bool, Optional[str]]: (success_flag, error_message)
    """
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "bigquery_credential.json"
    client = bigquery.Client()


    try:
        query_job = client.query(sql_query)
        results = query_job.result().to_dataframe() 
        total_bytes_processed = query_job.total_bytes_processed
        gb_processed = total_bytes_processed / (1024 ** 3)
        print(f"GB processed: {gb_processed:.5f} GB")
        global TOTAL_GB_PROCESSED
        TOTAL_GB_PROCESSED += gb_processed
        print(f"Total GB processed: {TOTAL_GB_PROCESSED:.5f} GB")
        
         
        
        if results.empty:
            print("No data found for the specified query.")
            results.to_csv(os.path.join(save_dir, file_name), index=False)
            return False, None
        else:
            if is_save:
                results.to_csv(os.path.join(save_dir, file_name), index=False)
                return True, None
            else:
                value = results.iat[0, 0]
                return True, None
    except Exception as e:
        # Log exception with context
        log_exception(
            "BigQuery execution error",
            {
                "file_name": file_name,
                "save_dir": save_dir,
                "is_save": is_save,
            }
        )
        return False, str(e)
    return True, None


def get_snowflake_sql_result(sql_query, database_id, is_save, save_dir=None, file_name="result.csv"):
    """Execute a Snowflake SQL query and optionally save results to CSV.

    Args:
        sql_query: Snowflake SQL query to execute.
        database_id: Snowflake database identifier/connection database.
        is_save: Whether to save the results to CSV.
        save_dir: Output directory for CSV when is_save is True.
        file_name: Output CSV filename.

    Returns:
        Tuple[bool, Optional[str]]: (success_flag, error_message)
    """
    snowflake_credential = json.load(open('snowflake_credential.json'))
    conn = snowflake.connector.connect(
        database=database_id,
        **snowflake_credential
    )
    cursor = conn.cursor()
    
    try:
        cursor.execute(sql_query)
        results = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        df = pd.DataFrame(results, columns=columns)
        if df.empty:
            print("No data found for the specified query.")
            return False, None
        else:
            if is_save:
                df.to_csv(os.path.join(save_dir, file_name), index=False)
                return True, None
    except Exception as e:
        # Log exception with context
        log_exception(
            "Snowflake execution error",
            {
                "database_id": database_id,
                "file_name": file_name,
                "save_dir": save_dir,
                "is_save": is_save,
            }
        )
        return False, str(e)


def get_sqlite_result(db_path, query, save_dir=None, file_name="result.csv", chunksize=500):
    """Execute a SQLite query with optional CSV output, using an in-memory copy.

    To avoid locking and side-effects, this function first backs up the database
    to an in-memory connection and executes the query there. If a save_dir is
    provided, results are streamed to CSV in chunks to reduce memory usage.

    Args:
        db_path: Path to the SQLite database file.
        query: SQL query string to execute.
        save_dir: Optional directory to save results as CSV. If None, returns a DataFrame.
        file_name: Output CSV filename when save_dir is provided.
        chunksize: Chunk size used when streaming results to CSV.

    Returns:
        Tuple[bool, Union[pd.DataFrame, str, None]]:
            (True, DataFrame) when save_dir is None and query returns data.
            (True, None) when results are successfully written to CSV.
            (False, error_string) when execution fails.
    """
    # print("hii1")
    # print(f"db_path: {db_path}")
    # print(f"query: {query}")
    # print(f"save_dir: {save_dir}")
    # print(f"file_name: {file_name}")
    # print(f"chunksize: {chunksize}")
    conn = sqlite3.connect(db_path)
    memory_conn = sqlite3.connect(':memory:')

    conn.backup(memory_conn)

    try:
        # print("hii2")
        if save_dir:
            if not os.path.exists(save_dir):
                os.makedirs(save_dir)
            for i, chunk in enumerate(pd.read_sql_query(query, memory_conn, chunksize=chunksize)):
                # print("hii3")
                # mode 'a' = append mode for subsequent chunks, 'w' = write mode for first chunk
                # This handles large result sets by writing chunks sequentially to avoid memory issues
                mode = 'a' if i > 0 else 'w'
                # Only write header for the first chunk to avoid duplicate headers
                header = i == 0
                chunk.to_csv(os.path.join(save_dir, file_name), mode=mode, header=header, index=False)
                # print("hii4")
        else:
            # print("hii5")
            # This else condition handles the case when save_dir is None or False
            # Instead of saving to a file, it reads the entire query result into a DataFrame
            # and returns it directly for immediate use
            df = pd.read_sql_query(query, memory_conn)
            return True, df

    except Exception as e:
        # Log exception with context
        log_exception(
            "SQLite execution error",
            {
                "db_path": db_path,
                "file_name": file_name,
                "save_dir": save_dir,
            }
        )
        return False, str(e)

    finally:
        # print("hii6")
        memory_conn.close()
        conn.close()
    
    return True, None


def execute_gold_sql_query(db_path, gold_sql_query, gold_sql_file_path, gold_result_dir="/Users/shtlpmac050/Documents/Spider2/fork_spider/Spider2.0-fork/spider2-lite/evaluation_suite/gold/exec_result", chunksize=500):
    """
    Execute gold SQL query on the database and save results to gold_result_dir.
    Only executes if the corresponding CSV file doesn't already exist.
    
    Args:
        db_path: Path to the SQLite database
        gold_sql_query: The SQL query to execute
        gold_sql_file_path: Path to the gold SQL file (used to derive CSV filename)
        gold_result_dir: Directory where results should be saved
        chunksize: Chunk size for processing large results
        
    Returns:
        tuple: (success_flag, error_message_or_dataframe)
    """
    # Extract filename from SQL file path
    sql_filename = os.path.basename(gold_sql_file_path)
    # Convert .sql to .csv
    csv_filename = sql_filename.replace('.sql', '.csv')
    csv_path = os.path.join(gold_result_dir, csv_filename)
    
    # Check if CSV already exists
    if os.path.exists(csv_path):
        print(f"Gold result already exists: {csv_filename}, skipping execution to avoid data inconsistency")
        # Read and return the existing CSV
        try:
            df = pd.read_csv(csv_path)
            return True, df
        except Exception as e:
            print(f"Error reading existing CSV {csv_filename}: {e}")
            return False, str(e)
    
    # Execute the query and save results
    print(f"Executing gold query for {sql_filename}...")
    success, result = get_sqlite_result(db_path, gold_sql_query, gold_result_dir, csv_filename, chunksize)
    
    if success:
        print(f"Successfully executed and saved gold results to {csv_filename}")
    else:
        print(f"Failed to execute gold query for {sql_filename}: {result}")
    
    return success, result


def evaluate_spider2sql(args):
    mode = args.mode
    gold_sql_dir = os.path.join(args.gold_dir, "sql")
    gold_result_dir = os.path.join(args.gold_dir, "exec_result")

    pred_result_dir = args.result_dir
    # print(f"pred_result_dir: {pred_result_dir}")
    # print(f"args.gold_dir: {args.gold_dir}")

    ## these are json dict with key as instance_id and value as a dict with keys as condition_cols, ignore_order, toks
    eval_standard_dict = load_jsonl_to_dict(os.path.join(args.gold_dir, "spider2lite_eval.jsonl"))
    ## these are json dict with key as instance_id and value as a dict with keys as condition_cols, ignore_order, toks
    spider2sql_metadata = load_jsonl_to_dict("spider2-lite.jsonl")
    
        
    gold_ids = []
    pred_ids = []
    if mode == "sql":
        for file in os.listdir(pred_result_dir):
            if file.endswith(".sql"):
                pred_ids.append(file.split(".")[0])
    elif mode == 'exec_result':
        # print("inside exec_result")
        for file in os.listdir(pred_result_dir):
            # print(f"args.result_dir: {pred_result_dir}")
            # print(f"file: {file}")
            if file.endswith(".csv"):
                pred_ids.append(file.split(".")[0])

    # print(f"pred_ids: {pred_ids}")
    
    gold_ids = list(eval_standard_dict.keys()) ## all the gold ids
    eval_ids = list(set(gold_ids).intersection(pred_ids)) ## commons ids between gold and pred

    # Sorting eval_ids alphabetically
    # Note: If eval_ids contains strings like ['local015.csv', 'local008.csv'], 
    # after sorting it will become ['local008.csv', 'local015.csv']
    # This is because Python sorts strings lexicographically (alphabetically)
    # where '0' comes before '1', so 'local008' comes before 'local015'
    eval_ids = sorted(eval_ids)
    output_results = []
    
    
    for id in tqdm(eval_ids):
        # print(f">>>Evaluating {id}...")
        error_info = None
        column_metrics = None  # Initialize column metrics for each iteration
        row_metrics = None  # Initialize row metrics for each iteration
        if mode == "sql":
            # print(f"pred_result_dir: {pred_result_dir}")
            pred_sql_query = open(os.path.join(pred_result_dir, f"{id}.sql")).read()
            if id.startswith("bq") or id.startswith("ga"):
                exe_flag, dbms_error_info = get_bigquery_sql_result(pred_sql_query, True, "temp", f"{id}.csv")  
                if exe_flag == False: 
                    score = 0
                    error_info = dbms_error_info
                    log_error(
                        "BigQuery execution failed",
                        {
                            "instance_id": id,
                            "mode": mode,
                            "error": dbms_error_info,
                        }
                    )
                else:                    
                    pred_pd = pd.read_csv(os.path.join("temp", f"{id}.csv"))
                    pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                    all_files = os.listdir(gold_result_dir)
                    csv_files = [file for file in all_files if pattern.match(file)]
                    csv_files = sorted(csv_files)
                    if len(csv_files) == 1:
                        gold_pd = pd.read_csv(os.path.join(gold_result_dir, f"{id}.csv"))
                        try:
                            score, column_metrics, row_metrics = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
                        except Exception as e:
                            print(f"An error occurred: {e}")
                            score = 0
                            error_info = 'Python Script Error:' + str(e)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'     
                    elif len(csv_files) > 1:
                        gold_pds = [pd.read_csv(os.path.join(gold_result_dir, file)) for file in csv_files]
                        score, column_metrics, row_metrics = compare_multi_pandas_table(pred_pd, gold_pds, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'

            elif id.startswith("local"):
                # First, execute the gold SQL query if its result doesn't exist
                gold_sql_file_path = os.path.join(gold_sql_dir, f"{id}.sql")
                if os.path.exists(gold_sql_file_path):
                    with open(gold_sql_file_path, 'r') as f:
                        gold_sql_query = f.read()
                    db_path = f"resource/databases/spider2-localdb/{spider2sql_metadata.get(id)['db']}.sqlite"
                    # Execute gold query (will skip if CSV already exists)
                    execute_gold_sql_query(db_path, gold_sql_query, gold_sql_file_path, gold_result_dir)
                
                # Now execute the predicted SQL query
                exe_flag, dbms_error_info = get_sqlite_result(f"resource/databases/spider2-localdb/{spider2sql_metadata.get(id)['db']}.sqlite", pred_sql_query, "temp", f"{id}.csv" )
                # print("hii7")
                # print(f"exe_flag: {exe_flag}")
                # print(f"dbms_error_info: {dbms_error_info}")
                # print("hii8")
                if exe_flag == False:
                    score = 0
                    error_info = dbms_error_info
                    log_error(
                        "SQLite execution failed",
                        {
                            "instance_id": id,
                            "mode": mode,
                            "error": dbms_error_info,
                        }
                    )
                else:
                    pred_pd = pd.read_csv(os.path.join("temp", f"{id}.csv"))  
                    pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                    all_files = os.listdir(gold_result_dir)
                    csv_files = [file for file in all_files if pattern.match(file)]
                    csv_files = sorted(csv_files)
                    if len(csv_files) == 1:
                        gold_pd = pd.read_csv(os.path.join(gold_result_dir, f"{id}.csv"))
                        try:
                            score, column_metrics, row_metrics = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
                        except Exception as e:
                            print(f"An error occurred: {e}")
                            score = 0
                            error_info = 'Python Script Error:' + str(e)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'     
                    elif len(csv_files) > 1:
                        gold_pds = [pd.read_csv(os.path.join(gold_result_dir, file)) for file in csv_files]
                        score, column_metrics, row_metrics = compare_multi_pandas_table(pred_pd, gold_pds, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'
            elif id.startswith("sf"):
                database_id = spider2sql_metadata[id]['db']
                exe_flag, dbms_error_info = get_snowflake_sql_result(pred_sql_query, database_id, True, "temp", f"{id}.csv") 
                if exe_flag == False: 
                    score = 0
                    error_info = dbms_error_info
                    log_error(
                        "Snowflake execution failed",
                        {
                            "instance_id": id,
                            "mode": mode,
                            "database_id": database_id,
                            "error": dbms_error_info,
                        }
                    )
                else:                    
                    pred_pd = pd.read_csv(os.path.join("temp", f"{id}.csv"))  
                    pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                    all_files = os.listdir(gold_result_dir)
                    csv_files = [file for file in all_files if pattern.match(file)]
                    csv_files = sorted(csv_files)
                    if len(csv_files) == 1:
                        gold_pd = pd.read_csv(os.path.join(gold_result_dir, f"{id}.csv"))
                        try:
                            score, column_metrics, row_metrics = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
                        except Exception as e:
                            print(f"An error occurred: {e}")
                            score = 0
                            error_info = 'Python Script Error:' + str(e)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'     
                    elif len(csv_files) > 1:
                        gold_pds = [pd.read_csv(os.path.join(gold_result_dir, file)) for file in csv_files]
                        score, column_metrics, row_metrics = compare_multi_pandas_table(pred_pd, gold_pds, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'                        
        elif mode == "exec_result":
            try:
                pred_pd = pd.read_csv(os.path.join(args.result_dir, f"{id}.csv"))
                # print(f"pred_pd: {pred_pd}")
                pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                all_files = os.listdir(gold_result_dir)
                csv_files = [file for file in all_files if pattern.match(file)]
                csv_files = sorted(csv_files)
                # print(f"csv_files: {csv_files}")
                # print(f"pred_pd: {pred_pd}")
                # print(f"gold_result_dir: {gold_result_dir}")
                # print(f"id: {id}")
                # print(f"eval_standard_dict.get(id)['condition_cols']: {eval_standard_dict.get(id)['condition_cols']}")
                # print(f"eval_standard_dict.get(id)['ignore_order']: {eval_standard_dict.get(id)['ignore_order']}")
                if len(csv_files) == 1:
                    gold_pd = pd.read_csv(os.path.join(gold_result_dir, f"{id}.csv"))
                    score, column_metrics, row_metrics = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
                elif len(csv_files) > 1:
                    gold_pds = [pd.read_csv(os.path.join(gold_result_dir, file)) for file in csv_files]
                    score, column_metrics, row_metrics = compare_multi_pandas_table(pred_pd, gold_pds, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'], include_column_metrics=True, include_row_metrics=True)
            except Exception as e:
                log_exception(
                    "Post-exec processing error",
                    {
                        "instance_id": id,
                        "mode": mode,
                        "result_dir": args.result_dir,
                        "gold_result_dir": gold_result_dir,
                    }
                )

        output_results.append(
            {
                "instance_id": id, 
                "score": score,
                "pred_sql": pred_sql_query if mode == "sql" else None,
                "error_info": error_info,
                "column_metrics": column_metrics if column_metrics else {
                    "precision": 0.0,
                    "recall": 0.0,
                    "f1": 0.0,
                    "tp": [],
                    "fp": [],
                    "fn": []
                },
                "row_metrics": row_metrics if row_metrics else {
                    "precision": 0.0,
                    "recall": 0.0,
                    "f1": 0.0,
                    "tp": 0,
                    "fp": 0,
                    "fn": 0,
                    "common_columns": []
                }
            }
        )

        
    # print({item['instance_id']: item['score'] for item in output_results if item['score']==1})  
    correct_examples = sum([item['score'] for item in output_results]) 

    # print(f"Final score: {correct_examples / len(output_results)}, Correct examples: {correct_examples}, Total examples: {len(output_results)}")
    # print(f"Real score: {correct_examples / 547}, Correct examples: {correct_examples}, Total examples: 547")
    
    # Calculate and print column metrics summary
    if output_results:
        avg_precision = sum(item['column_metrics']['precision'] for item in output_results) / len(output_results)
        avg_recall = sum(item['column_metrics']['recall'] for item in output_results) / len(output_results)
        avg_f1 = sum(item['column_metrics']['f1'] for item in output_results) / len(output_results)
        
        print(f"\n=== Column Comparison Metrics ===")
        print(f"Average Column Precision: {avg_precision:.4f}")
        print(f"Average Column Recall: {avg_recall:.4f}")
        print(f"Average Column F1 Score: {avg_f1:.4f}")
        
        # Find examples with perfect column matches
        perfect_column_matches = [item for item in output_results if item['column_metrics']['f1'] == 1.0]
        print(f"Perfect column matches: {len(perfect_column_matches)} / {len(output_results)}")
        
        # Examples with missing columns
        missing_columns_examples = [item for item in output_results if len(item['column_metrics']['fn']) > 0]
        print(f"Examples with missing columns: {len(missing_columns_examples)}")
        
        # Examples with extra columns
        extra_columns_examples = [item for item in output_results if len(item['column_metrics']['fp']) > 0]
        print(f"Examples with extra columns: {len(extra_columns_examples)}")
        
        # Calculate and print row metrics summary
        print(f"\n=== Row Comparison Metrics ===")
        avg_row_precision = sum(item['row_metrics']['precision'] for item in output_results) / len(output_results)
        avg_row_recall = sum(item['row_metrics']['recall'] for item in output_results) / len(output_results)
        avg_row_f1 = sum(item['row_metrics']['f1'] for item in output_results) / len(output_results)
        
        print(f"Average Row Precision: {avg_row_precision:.4f}")
        print(f"Average Row Recall: {avg_row_recall:.4f}")
        print(f"Average Row F1 Score: {avg_row_f1:.4f}")
        
        # Find examples with perfect row matches
        perfect_row_matches = [item for item in output_results if item['row_metrics']['f1'] == 1.0]
        print(f"Perfect row matches: {len(perfect_row_matches)} / {len(output_results)}")
        
        # Average matched/extra/missing rows
        avg_tp_rows = sum(item['row_metrics']['tp'] for item in output_results) / len(output_results)
        avg_fp_rows = sum(item['row_metrics']['fp'] for item in output_results) / len(output_results)
        avg_fn_rows = sum(item['row_metrics']['fn'] for item in output_results) / len(output_results)
        
        print(f"Average matched rows (TP): {avg_tp_rows:.2f}")
        print(f"Average extra rows (FP): {avg_fp_rows:.2f}")
        print(f"Average missing rows (FN): {avg_fn_rows:.2f}")

        # Calculate and print overall (columns + rows) metrics summary if available
        if 'overall' in output_results[0]['column_metrics'] or 'overall' in output_results[0]['row_metrics']:
            overall_precisions = []
            overall_recalls = []
            overall_f1s = []
            for item in output_results:
                overall_dict = item['column_metrics'].get('overall') or item['row_metrics'].get('overall')
                if overall_dict:
                    overall_precisions.append(overall_dict.get('precision', 0.0))
                    overall_recalls.append(overall_dict.get('recall', 0.0))
                    overall_f1s.append(overall_dict.get('f1', 0.0))
            if overall_precisions:
                avg_overall_precision = sum(overall_precisions) / len(overall_precisions)
                avg_overall_recall = sum(overall_recalls) / len(overall_recalls)
                avg_overall_f1 = sum(overall_f1s) / len(overall_f1s)
                print(f"\n=== Overall (Columns + Rows) Metrics ===")
                print(f"Average Overall Precision: {avg_overall_precision:.4f}")
                print(f"Average Overall Recall: {avg_overall_recall:.4f}")
                print(f"Average Overall F1 Score: {avg_overall_f1:.4f}")
        else:
            avg_overall_precision = 0.0
            avg_overall_recall = 0.0
            avg_overall_f1 = 0.0


    correct_ids = [item['instance_id'] for item in output_results if item['score'] == 1]

    csv_file = f"{args.result_dir}-ids.csv"
    import csv
    with open(csv_file, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(['instance_id'])
        for item in correct_ids:
            if item.startswith(('bq', 'ga', 'local')):
                item = 'sf_' + item
            writer.writerow([item])

    # print("TOTAL_GB_PROCESSED: ",TOTAL_GB_PROCESSED)
    
    # Save detailed column and row metrics to JSON file
    detailed_metrics_file = f"{args.result_dir}-detailed-metrics.json"
    detailed_metrics_data = {
        "summary": {
            "column_metrics": {
                "avg_precision": avg_precision if output_results else 0,
                "avg_recall": avg_recall if output_results else 0,
                "avg_f1": avg_f1 if output_results else 0,
                "perfect_matches": len(perfect_column_matches) if output_results else 0,
                "missing_columns_count": len(missing_columns_examples) if output_results else 0,
                "extra_columns_count": len(extra_columns_examples) if output_results else 0
            },
            "row_metrics": {
                "avg_precision": avg_row_precision if output_results else 0,
                "avg_recall": avg_row_recall if output_results else 0,
                "avg_f1": avg_row_f1 if output_results else 0,
                "perfect_matches": len(perfect_row_matches) if output_results else 0,
                "avg_tp_rows": avg_tp_rows if output_results else 0,
                "avg_fp_rows": avg_fp_rows if output_results else 0,
                "avg_fn_rows": avg_fn_rows if output_results else 0
            },
            "overall_metrics": {
                "avg_precision": avg_overall_precision if output_results else 0,
                "avg_recall": avg_overall_recall if output_results else 0,
                "avg_f1": avg_overall_f1 if output_results else 0
            },
            "total_evaluated": len(output_results),
            "correct_data_matches": correct_examples
        },
        "detailed_results": [
            {
                "instance_id": item["instance_id"],
                "data_score": item["score"],
                "column_metrics": {
                    "precision": item["column_metrics"]["precision"],
                    "recall": item["column_metrics"]["recall"],
                    "f1": item["column_metrics"]["f1"],
                    "true_positive_columns": item["column_metrics"]["tp"],
                    "false_positive_columns": item["column_metrics"]["fp"],
                    "false_negative_columns": item["column_metrics"]["fn"]
                },
                "row_metrics": {
                    "precision": item["row_metrics"]["precision"],
                    "recall": item["row_metrics"]["recall"],
                    "f1": item["row_metrics"]["f1"],
                    "true_positive_rows": item["row_metrics"]["tp"],
                    "false_positive_rows": item["row_metrics"]["fp"],
                    "false_negative_rows": item["row_metrics"]["fn"],
                    "common_columns_used": item["row_metrics"]["common_columns"]
                },
                "overall_metrics": item["column_metrics"].get("overall", item["row_metrics"].get("overall", {
                    "precision": 0.0,
                    "recall": 0.0,
                    "f1": 0.0,
                    "tp": 0,
                    "fp": 0,
                    "fn": 0
                }))
            }
            for item in output_results
        ]
    }
    
    with open(detailed_metrics_file, 'w', encoding='utf-8') as f:
        json.dump(detailed_metrics_data, f, indent=2)
    
    print(f"\nDetailed column and row metrics saved to: {detailed_metrics_file}")



if __name__ == "__main__":

    # Command to run this script:
    # python evaluation_suite/evaluate_v2.py --mode sql --result_dir evaluation_suite/predicted_results_folder --gold_dir evaluation_suite/gold

    ## python evaluation_suite/evaluate_v2.py --mode exec_result --result_dir temp --gold_dir evaluation_suite/gold

    parser = argparse.ArgumentParser(description="Run evaluations for NLP models.")
    parser.add_argument("--mode", type=str, choices=["sql", "exec_result"], default='sql', help="Mode of submission results")
    parser.add_argument("--result_dir", type=str, default="spider2sql_example_submit_result", help="Result directory")
    parser.add_argument("--gold_dir", type=str, default="gold", help="Result directory")
    parser.add_argument("--is_sql_debug", action="store_true", default=False)
    args = parser.parse_args()
    
    # if os.path.exists("temp"):
    #     shutil.rmtree("temp")
    # os.makedirs("temp")

    
    evaluate_spider2sql(args)