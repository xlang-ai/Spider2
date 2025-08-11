from typing import Dict, Any
import logging

logger = logging.getLogger(__name__)

def terminate(answer: str, task_completed: str = "false", **kwargs) -> Dict[str, Any]:
    output = f"EXECUTION RESULT of [terminate]:\n{answer}"

    return {
        "content": output
    }


def register_tools(registry):
    
    registry.register_tool("terminate", terminate)
    
    registry.register_tool("finish", terminate)  # 注册finish作为terminate的别名