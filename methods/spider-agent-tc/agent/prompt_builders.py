import os
import subprocess

class BasePromptBuilder:
    
    def load_system_prompt(self, args):
        """Load system prompt from file"""
        with open(args.system_prompt_path, 'r', encoding='utf-8') as f:
            return f.read().strip()
    
    def load_external_knowledge(self, external_knowledge_file, args):
        """Load external knowledge from file"""
        if not external_knowledge_file:
            return None
        
        knowledge_path = os.path.join(args.documents_path, external_knowledge_file)
        if os.path.exists(knowledge_path):
            with open(knowledge_path, 'r', encoding='utf-8') as f:
                return f.read().strip()
        return None
    
    
    def build_initial_prompt(self, item, args):
        raise NotImplementedError

class SpiderAgentPromptBuilder(BasePromptBuilder):

    def get_database_info(self, db_id, args):
        """Get database directory listing"""
        db_path = os.path.join(args.databases_path, db_id)
        try:
            result = subprocess.run(['ls', db_path], capture_output=True, text=True)
            return result.stdout.strip()
        except Exception as e:
            return f"Error listing database: {str(e)}"

    
    def build_initial_prompt(self, item, args):
        system_prompt = self.load_system_prompt(args)
        external_knowledge_content = self.load_external_knowledge(item.get('external_knowledge'), args)
        db_info = self.get_database_info(item['db_id'], args)
        
        user_content = f"""Question: {item['instruction']}
External Knowledge: {external_knowledge_content if external_knowledge_content else 'None'}

You are in the folder contains schema, the database name is {item['db_id']}, the database contains schema_name:
```bash
ls {os.path.join(args.databases_path, item['db_id'])}
```
```output
{db_info}
```

When referencing tables, you must use the fully qualified three-part naming convention: database_name.schema_name.table_name. Now help me write the SQL query to answer the question. """

        return [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_content}
        ]



def get_prompt_builder(strategy):
    builders = {
        "spider-agent": SpiderAgentPromptBuilder(),
        # "database": DatabasePromptBuilder(),
        # "multi_step": MultiStepPromptBuilder(),
        # "reasoning": ReasoningPromptBuilder(),
    }
    
    return builders.get(strategy, SpiderAgentPromptBuilder())