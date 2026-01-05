import os
import time
from typing import Optional, List, Dict, Any
from dotenv import load_dotenv
from openai import OpenAI, RateLimitError, APITimeoutError, APIConnectionError

_client: Optional[OpenAI] = None

def _get_retry_after(exception, default_backoff: float) -> float:
    """
    Extract retry-after value from API exception headers.
    Returns the header value if present, otherwise returns default_backoff.
    """
    try:
        # OpenAI exceptions have a response attribute with headers
        if hasattr(exception, 'response') and exception.response is not None:
            headers = exception.response.headers
            retry_after = headers.get('retry-after') or headers.get('Retry-After')
            if retry_after:
                # retry-after can be seconds (int) or HTTP date string
                # Most APIs use seconds for rate limits
                return float(retry_after)
    except (ValueError, AttributeError, TypeError):
        pass  # Silently fall back to default
    return default_backoff

def _build_client(api_key: Optional[str] = None, base_url: Optional[str] = None) -> OpenAI:
    """
    Construct an OpenAI client using environment variables by default.

    - Reads OPENAI_API_KEY (required)
    - Reads OPENAI_BASE_URL (optional; useful for gateways/Azure-compatible endpoints)
    """
    load_dotenv()

    resolved_api_key = api_key or os.getenv("OPENAI_API_KEY")
    if not resolved_api_key:
        raise RuntimeError(
            "OPENAI_API_KEY is not set. Provide it in your environment or .env file."
        )

    resolved_base_url = base_url or os.getenv("OPENAI_BASE_URL")

    # Configure client-level retries and timeout via environment variables
    max_retries = int(os.getenv("OPENAI_MAX_RETRIES", "3"))
    timeout = float(os.getenv("OPENAI_TIMEOUT", "60"))

    if resolved_base_url:
        return OpenAI(
            api_key=resolved_api_key,
            base_url=resolved_base_url,
            max_retries=max_retries,
            timeout=timeout,
        )
    return OpenAI(api_key=resolved_api_key, max_retries=max_retries, timeout=timeout)

def get_client(api_key: Optional[str] = None, base_url: Optional[str] = None) -> OpenAI:
    """Return a cached OpenAI client instance, creating it on first use."""
    global _client
    if _client is None or api_key or base_url:
        _client = _build_client(api_key=api_key, base_url=base_url)
    return _client

def chat(
    messages: List[Dict[str, str]],
    model: Optional[str] = None,
    temperature: float = 0.2,
    max_tokens: Optional[int] = None,
    max_retries: int = 5,
    **kwargs: Any,
) -> str:
    """
    Minimal helper to get a single string response from Chat Completions.

    Parameters
    - messages: [{"role": "user"|"system"|"assistant", "content": "..."}, ...]
    - model: overrides OPENAI_MODEL if provided
    - temperature, max_tokens: forwarded to OpenAI
    - max_retries: number of retries for rate limit/timeout errors (default 5)
    - **kwargs: forwarded to OpenAI chat.completions.create

    Returns
    - assistant message content as a string
    """
    client = get_client()
    chosen_model = model or os.getenv("OPENAI_MODEL", "gpt-4o-mini")

    for attempt in range(max_retries):
        try:
            resp = client.chat.completions.create(
                model=chosen_model,
                messages=messages,
                temperature=temperature,
                max_tokens=max_tokens,
                **kwargs,
            )
            return resp.choices[0].message.content or ""
        
        except RateLimitError as e:
            default_backoff = 2 ** attempt  # Exponential backoff: 1, 2, 4, 8, 16 seconds
            wait_time = _get_retry_after(e, default_backoff)
            retry_after_source = "retry-after header" if wait_time != default_backoff else "exponential backoff"
            print(
                f"[WARN] Rate limit hit (attempt {attempt + 1}/{max_retries}). "
                f"Waiting {wait_time}s before retry (from {retry_after_source}). Error: {e}"
            )
            time.sleep(wait_time)
        
        except Exception as e:
            print(f"[ERROR] Error: {e}")
            raise
    
    # Should never reach here, but just in case
    raise RuntimeError("Exiting from llm retry loop")

if __name__ == "__main__":
    messages = [
        {"role": "system", "content": "You are so stupid that you can't answer any question correctly. Plus you only answer in Chinese."},
        {"role": "user", "content": "What is the capital of France?"}
    ]
    print(chat(messages))