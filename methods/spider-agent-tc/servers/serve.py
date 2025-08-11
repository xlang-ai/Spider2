import argparse
import asyncio
import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from typing import Dict, Any, List
import logging

from servers.utils.tool_registry import ToolRegistry

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI(title="Tools Server API")
tool_registry = ToolRegistry()

tool_registry.load_tools()

@app.post("/execute")
async def execute_tool(request: Request) -> JSONResponse:
    try:
        data = await request.json()
        tool_calls = data.get("tool_calls", [])
        
        if not tool_calls:
            return JSONResponse(
                status_code=400,
                content={"error": "No tool_calls provided"}
            )
        
        tool_call = tool_calls[0]
        tool_name = tool_call.get("name")
        arguments = tool_call.get("arguments", {})
        
        logger.info(f"Executing tool: {tool_name} with arguments: {arguments}")
        
        if not tool_registry.has_tool(tool_name):
            return JSONResponse(
                status_code=404,
                content={"error": f"Tool {tool_name} not found"}
            )
        
        result = await tool_registry.execute_tool(tool_name, **arguments)
        
        return JSONResponse(content=result)
    
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={"error": f"Internal server error: {str(e)}"}
        )

def parse_args():
    parser = argparse.ArgumentParser(description="Tools Server")
    parser.add_argument("--workers_per_tool", type=int, default=8, help="Number of workers per tool")
    parser.add_argument("--port", type=int, default=5000, help="Server port")
    parser.add_argument("--host", type=str, default="0.0.0.0", help="Server host")
    return parser.parse_args()

def main():
    args = parse_args()
    
    tool_registry.set_workers_per_tool(args.workers_per_tool)
    
    logger.info(f"Starting server on port {args.port} with {args.workers_per_tool} workers per tool")
    uvicorn.run(app, host=args.host, port=args.port, log_level="info")

if __name__ == "__main__":
    main()