import subprocess
import os
from typing import Dict, Any, Tuple
import logging

logger = logging.getLogger(__name__)

# Default timeout value
TIMEOUT = 30  # 30 seconds timeout
MAX_CHARS = 2000  # Maximum characters to display

def execute_bash(command: str, work_dir: str = None, **kwargs) -> Dict[str, Any]:
    """
    Execute a Bash command

    Args:
        command: The bash command to execute
        work_dir: The working directory to execute the command in
        **kwargs: Additional parameters

    Returns:
        Dictionary containing the execution result with content and exec_meta keys
    """
    logger.info(f"Executing bash command: {command}")
    logger.info(f"Working directory: {work_dir}")
    
    try:
        # Use the provided work_dir or current directory if not specified
        cwd = work_dir if work_dir else os.getcwd()
        
        proc = subprocess.run(
            command,
            shell=True,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=kwargs.get('timeout', TIMEOUT)
        )
        
        stdout = proc.stdout
        stderr = proc.stderr
        return_code = proc.returncode
        success = return_code == 0
        
        # Construct the return content
        if success:
            content = stdout
        else:
            content = f"Error: {stderr}" if stderr else "Command execution failed"
        
        # Check if output is too long and truncate if necessary
        if len(content) > MAX_CHARS:
            truncated_content = content[:MAX_CHARS]
            total_chars = len(content)
            content = f"{truncated_content}\n\n[OUTPUT TRUNCATED]\nThe output has been truncated due to length ({total_chars} characters total, showing first {MAX_CHARS} characters)."
        
        logger.info(f"Command executed with return code: {return_code}")
        
    except subprocess.TimeoutExpired:
        content = f"Command timed out after {kwargs.get('timeout', TIMEOUT)} seconds"
        success = False
        logger.warning(f"Command timed out: {command}")
    except Exception as e:
        content = f"Error executing command: {str(e)}"
        success = False
        logger.error(f"Error executing command: {str(e)}")
    
    return {
        "content": f"EXECUTION RESULT of [execute_bash]:\n{content}"
    }

def register_tools(registry):
    """
    Register tools with the tool registry
    """
    registry.register_tool("execute_bash", execute_bash)