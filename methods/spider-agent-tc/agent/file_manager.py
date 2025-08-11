import json
import os
import threading
import glob
from collections import defaultdict

class FileManager:
    def __init__(self, args):
        self.args = args
        self.file_locks = defaultdict(threading.Lock)
        self.processed_instances = defaultdict(int)
        
    def check_if_terminated(self, result):
        """Check if a result has successfully executed to termination"""
        return result.get("terminated", False)
        
    def get_instance_file_path(self, instance_id):
        """Get the file path for a specific instance"""
        return os.path.join(self.args.output_folder, f"{instance_id}.json")
        
    def load_instance_results(self, instance_id):
        """Load results for a specific instance"""
        file_path = self.get_instance_file_path(instance_id)
        if not os.path.exists(file_path):
            return []
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data if isinstance(data, list) else [data]
        except Exception as e:
            print(f"Error loading {file_path}: {e}")
            return []
    
    def save_instance_results(self, instance_id, results):
        """Save all results for a specific instance"""
        file_path = self.get_instance_file_path(instance_id)
        os.makedirs(self.args.output_folder, exist_ok=True)
        
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(results, f, ensure_ascii=False, indent=2)
            print(f"Saved results to: {file_path}")
        except Exception as e:
            print(f"Error saving to {file_path}: {e}")
    
    def add_single_result(self, result):
        """Add a single result to the appropriate instance file"""
        instance_id = result["instance_id"]
        
        with self.file_locks[instance_id]:
            existing_results = self.load_instance_results(instance_id)
            existing_results.append(result)
            self.save_instance_results(instance_id, existing_results)
            
            if self.check_if_terminated(result):
                self.processed_instances[instance_id] += 1
        
    def load_existing_results(self):
        """Load existing results from all instance files"""
        if not os.path.exists(self.args.output_folder):
            print("Output folder does not exist, starting fresh")
            return []
            
        all_results = []
        instance_files = glob.glob(os.path.join(self.args.output_folder, "*.json"))
        
        for file_path in instance_files:
            try:
                filename = os.path.basename(file_path)
                instance_id = filename.replace('.json', '')
                
                instance_results = self.load_instance_results(instance_id)
                terminated_count = 0
                
                for result in instance_results:
                    if isinstance(result, dict) and "instance_id" in result:
                        all_results.append(result)
                        if self.check_if_terminated(result):
                            terminated_count += 1
                
                self.processed_instances[instance_id] = terminated_count
                        
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
                continue
        
        total_valid = sum(self.processed_instances.values())
        print(f"Found {total_valid} valid (terminated) results for {len(self.processed_instances)} unique instances")
        return all_results