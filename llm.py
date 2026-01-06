import os
from typing import Optional, List, Dict, Any
from dotenv import load_dotenv
from openai import OpenAI

def chat(
    messages: List[Dict[str, str]],
    model: Optional[str] = None,
    temperature: float = 0.2,
    max_tokens: Optional[int] = None,
    **kwargs: Any,
) -> str:
    load_dotenv()
    if not os.getenv("OPENAI_API_KEY"):
        raise RuntimeError("OPENAI_API_KEY is not set. Provide it in your environment or .env file.")
    if not os.getenv("OPENAI_BASE_URL"):
        raise RuntimeError("OPENAI_BASE_URL is not set. Provide it in your environment or .env file.")
    client = OpenAI(
            api_key=os.getenv("OPENAI_API_KEY"),
            base_url=os.getenv("OPENAI_BASE_URL"),
            max_retries=int(os.getenv("OPENAI_MAX_RETRIES", "3")),
            timeout=float(os.getenv("OPENAI_TIMEOUT", "300")),
        )
    chosen_model = model or os.getenv("OPENAI_MODEL", "gpt-4o-mini")

    resp = client.chat.completions.create(
        model=chosen_model,
        messages=messages,
        temperature=temperature,
        max_tokens=max_tokens,
        **kwargs,
    )
    return resp.choices[0].message.content or ""

if __name__ == "__main__":
    messages = [
        {"role": "system", "content": "You are so stupid that you can't answer any question correctly. Plus you only answer in Chinese."},
        {"role": "user", "content": "What is the capital of France?"}
    ]
    print(chat(messages))