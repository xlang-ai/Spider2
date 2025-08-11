import json
import argparse
import random
from pathlib import Path

def extract_sql_answers(input_dir, output_folder):
    """
    Extract SQL answers from terminated records in JSON files
    """
    input_path = Path(input_dir)
    output_path = Path(output_folder)
    output_path.mkdir(parents=True, exist_ok=True)
    
    json_files = list(input_path.glob("*.json"))
    
    processed_count = 0
    skipped_count = 0
    
    for json_file in json_files:
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if not isinstance(data, list):
                skipped_count += 1
                continue
            
            # Find terminated records
            terminated_records = [record for record in data if record.get('terminated', False)]
            
            if not terminated_records:
                skipped_count += 1
                continue
            
            # Randomly select one terminated record
            selected_record = random.choice(terminated_records)
            
            # Extract instance_id or id
            instance_id = selected_record.get('instance_id') or selected_record.get('id')
            conversation = selected_record.get('conversation')

            
            if not instance_id or not conversation:
                skipped_count += 1
                continue
            
            # Extract SQL answer from last conversation item
            last_item = conversation[-1]
            tool_calls = last_item.get('tool_calls', [])
            
            if not tool_calls or len(tool_calls) == 0:
                skipped_count += 1
                continue
            
            first_tool_call = tool_calls[0]
            
            # Check if it's a terminate call
            if first_tool_call.get('name') != 'terminate':
                skipped_count += 1
                continue
            
            # Extract answer
            arguments = first_tool_call.get('arguments', {})
            if isinstance(arguments, str):
                arguments = json.loads(arguments)
            
            answer = arguments.get('answer')
            
            if not answer:
                skipped_count += 1
                continue
            
            # Save to SQL file
            sql_file = output_path / f"{instance_id}.sql"
            with open(sql_file, 'w', encoding='utf-8') as f:
                f.write(answer)
            
            processed_count += 1
            print(f"Extracted SQL from {json_file.name} -> {instance_id}.sql")
            
        except Exception as e:
            print(f"Error processing {json_file.name}: {e}")
            skipped_count += 1
    
    print(f"\nProcessed: {processed_count} files")
    print(f"Skipped: {skipped_count} files")

def main():
    parser = argparse.ArgumentParser(description='Extract SQL answers from terminated JSON records')
    parser.add_argument('input_dir', help='Input JSON directory path')
    parser.add_argument('output_folder', help='Output folder for SQL files')
    
    args = parser.parse_args()
    
    input_path = Path(args.input_dir)
    if not input_path.exists() or not input_path.is_dir():
        print(f"Error: Invalid input directory: {args.input_dir}")
        return 1
    
    try:
        extract_sql_answers(args.input_dir, args.output_folder)
        return 0
    except Exception as e:
        print(f"Processing error: {e}")
        return 1

if __name__ == '__main__':
    exit(main())