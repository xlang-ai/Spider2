import re
import os
import requests
from copy import deepcopy

class MessageProcessor:
    def __init__(self, args):
        self.args = args
    
    def process_round(self, llm_response, item, messages, conversation_history):
        assistant_content, tool_calls, preserved_content = self.parse_assistant_message(llm_response, item)

        if not tool_calls:
            messages.append({"role": "assistant", "content": llm_response})
            conversation_history.append({
                "role": "assistant",
                "content": assistant_content,
                "tool_calls": []
            })
            
            format_prompt = "Please follow the <tool_call> tag format and return a <tool_call> tag containing function name and parameters."
            user_msg = {"role": "user", "content": format_prompt}
            messages.append(user_msg)
            conversation_history.append(user_msg)
            return {"continue": True}
        
        messages.append({"role": "assistant", "content": preserved_content})
        conversation_history.append({
            "role": "assistant",
            "content": assistant_content,
            "tool_calls": tool_calls
        })
        
        if any(tc["name"] == "terminate" for tc in tool_calls):
            return {"terminated": True}
        
        non_terminate_tool_calls = [tc for tc in tool_calls if tc["name"] != "terminate"]
        
        if non_terminate_tool_calls:
            exec_results = self.execute_tool_calls(non_terminate_tool_calls)
            
            for tool_call, exec_result in zip(non_terminate_tool_calls, exec_results):
                result_content = exec_result.get("content", str(exec_result))
                
                conversation_history.append({
                    "role": "tool",
                    "content": result_content
                })
                
                messages.append({
                    "role": "user", 
                    "content": result_content
                })
        
        return {"continue": True}
    
    def parse_assistant_message(self, content, item):
        """Parse assistant message, separate content and tool_calls"""
        tool_call_pattern = r'<tool_call>(.*?)</tool_call>'
        matches = list(re.finditer(tool_call_pattern, content, re.DOTALL))
        
        if not matches:
            return content, [], content
        
        first_match = matches[0]
        pre_tool_call_content = content[:first_match.start()].strip()
        first_tool_call_end = first_match.end()
        preserved_content = content[:first_tool_call_end]
        
        tool_calls = self.parse_tool_calls(preserved_content, item)
        
        return pre_tool_call_content, tool_calls, preserved_content
    
    def parse_tool_calls(self, content, item):
        """Parse tool calls and add work_dir parameter for execute_bash"""
        tool_calls = []
        pattern = r'<tool_call>(.*?)</tool_call>'
        matches = re.findall(pattern, content, re.DOTALL)
        
        if matches:
            match = matches[0]
            func_match = re.search(r'<function=([^>]+)>', match)
            if func_match:
                function_name = func_match.group(1)
                
                param_pattern = r'<parameter=([^>]+)>(.*?)</parameter>'
                param_matches = re.findall(param_pattern, match, re.DOTALL)
                
                arguments = {}
                for param_name, param_value in param_matches:
                    arguments[param_name] = param_value.strip()
                
                if function_name == "execute_bash" and "work_dir" not in arguments:
                    arguments["work_dir"] = os.path.join(self.args.databases_path, item['db_id'])
                
                tool_calls.append({
                    "name": function_name,
                    "arguments": arguments
                })
        
        return tool_calls
    
    def execute_tool_calls(self, tool_calls):
        """Execute tool calls via API"""
        if not tool_calls:
            return []
            
        url = f"http://{self.args.api_host}:{self.args.api_port}/execute"
        request_body = {"tool_calls": tool_calls}
        
        try:
            response = requests.post(
                url, 
                json=request_body, 
                timeout=30,
                headers={"Content-Type": "application/json"}
            )
            response.raise_for_status()
            
            api_response = response.json()
            
            if isinstance(api_response, list):
                return api_response
            elif isinstance(api_response, dict):
                return [api_response]
            else:
                return [{"error": f"Unexpected API response format: {api_response}"}]
                
        except Exception as e:
            error_result = {"error": f"API error: {str(e)}"}
            return [error_result] * len(tool_calls)