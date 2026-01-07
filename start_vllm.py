#!/usr/bin/env python3

import subprocess
import os

def get_idle_gpus(threshold_mb: int = 1000) -> list[int]:
    """Find GPUs with memory usage below threshold (default 1GB)."""
    result = subprocess.run(
        ['nvidia-smi', '--query-gpu=index,memory.used', '--format=csv,noheader,nounits'],
        capture_output=True, text=True
    )
    idle_gpus = []
    for line in result.stdout.strip().split('\n'):
        idx, mem_used = line.split(', ')
        if float(mem_used) < threshold_mb:
            idle_gpus.append(int(idx))
    return idle_gpus

def create_offline_llm(model: str, max_model_len: int, gpu_memory_utilization: float, tensor_parallel_size: int):
    gpus = get_idle_gpus()
    if len(gpus) < 2:
        raise RuntimeError("At least 2 GPUs are required to run the model.")
    cuda_devices = ','.join(map(str, gpus))
    os.environ['CUDA_VISIBLE_DEVICES'] = cuda_devices
    print("Using GPUs: ", cuda_devices)

    from vllm import LLM
    return LLM(
        model=model,
        tensor_parallel_size=len(gpus),
        max_model_len=max_model_len,
        gpu_memory_utilization=gpu_memory_utilization,
        trust_remote_code=True,
    )

def create_openai_api_llm(
    model: str,
    max_model_len: int,
    gpu_memory_utilization: float,
    port: int = 8000,
    host: str = "0.0.0.0",
    api_key: str = "JOSHUA",
):
    """Start a vLLM server exposing an OpenAI-compatible API endpoint in a subprocess."""
    gpus = get_idle_gpus()
    if len(gpus) < 2:
        raise RuntimeError("At least 2 GPUs are required to run the model.")
    cuda_devices = ','.join(map(str, gpus))
    
    print(f"Using GPUs: {cuda_devices}")
    print(f"Starting OpenAI API server at http://{host}:{port}")
    print(f"Using API key: {api_key}")

    env = os.environ.copy()
    env['CUDA_VISIBLE_DEVICES'] = cuda_devices
    env['VLLM_API_KEY'] = api_key

    cmd = [
        'python', '-m', 'vllm.entrypoints.openai.api_server',
        '--model', model,
        '--max-model-len', str(max_model_len),
        '--gpu-memory-utilization', str(gpu_memory_utilization),
        '--tensor-parallel-size', str(len(gpus)),
        '--port', str(port),
        '--host', host,
        '--trust-remote-code',
        '--api-key', api_key,
    ]
    subprocess.run(cmd, env=env)

def inference_offline_llm(model: str, max_model_len: int, gpu_memory_utilization: float, tensor_parallel_size: int):
    llm = create_offline_llm(
        # model="Qwen/Qwen2.5-7B-Instruct",
        model="Snowflake/Arctic-Text2SQL-R1-7B",
        max_model_len=32000,
        gpu_memory_utilization=0.9,
        tensor_parallel_size=1,
    )
    
    from vllm import SamplingParams
    # Demo
    prompts = ["Hello!", "What is 2+2?"]
    outputs = llm.generate(prompts, SamplingParams(max_tokens=50), use_tqdm=True)
    for out in outputs:
        print(f"\n{out.prompt} → {out.outputs[0].text}")

if __name__ == "__main__":
    # create_openai_api_llm(
    #     model="Snowflake/Arctic-Text2SQL-R1-7B",
    #     max_model_len=32000,
    #     gpu_memory_utilization=0.9,
    #     port=8001,
    #     host="0.0.0.0",
    #     api_key="JOSHUA",
    # )
    
    create_openai_api_llm(
        model="/data/deema/rec/text2sql-rl/checkpoints/text2sql-grpo-d6-e17-deema/",
        max_model_len=32000,
        gpu_memory_utilization=0.9,
        port=8001,
        host="0.0.0.0",
        api_key="JOSHUA",
    )