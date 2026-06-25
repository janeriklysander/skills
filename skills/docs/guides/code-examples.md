# Code Examples in Documentation

Code examples are the most-read part of any technical document. A broken or misleading example destroys trust faster than any prose error.

## Non-Negotiable Rules

### Complete and runnable

Every code example must work if copy-pasted. No missing imports, no pseudo-code without explicit labeling, no undefined variables.

```python
# Bad — where does `client` come from?
response = client.create_charge(amount=1000, currency="usd")

# Good — complete and self-contained
from stripe import Stripe

client = Stripe(api_key="sk_test_...")
response = client.create_charge(amount=1000, currency="usd")
print(response.id)
```

### Verified by execution

Before including a code example in documentation, **run it**. Confirm it produces the expected output in the repo's language and runtime. Don't trust that it looks right.

### Single language

Use the language of the current repository. Don't provide multi-language tabs unless the project explicitly targets multiple runtimes.

### Focused

Each example illustrates one concept. Don't combine multiple ideas in a single block.

```python
# Bad — teaches configuration AND error handling AND retries simultaneously
client = Stripe(api_key=key, timeout=30, max_retries=3)
try:
    response = client.create_charge(amount=1000, currency="usd")
except StripeError as e:
    if e.retryable:
        response = client.create_charge(amount=1000, currency="usd")
    else:
        raise

# Good — one concept at a time
client = Stripe(api_key="sk_test_...")
response = client.create_charge(amount=1000, currency="usd")
```

Then in a separate section on error handling:

```python
try:
    response = client.create_charge(amount=1000, currency="usd")
except StripeError as e:
    print(f"Charge failed: {e.message}")
```

## Progressive Complexity

Start with the simplest possible example, then layer in complexity:

1. **Minimal** — the fewest lines to achieve the result
2. **Realistic** — adds configuration a real user would need
3. **Advanced** — shows error handling, edge cases, or performance tuning

Label each level clearly so readers can find the depth they need.

## Placeholder Values

Use realistic but obviously fake values:

| Type   | Good                               | Bad                |
| ------ | ---------------------------------- | ------------------ |
| URLs   | `https://api.example.com/v1/users` | `http://localhost` |
| Emails | `alex@example.com`                 | `test@test.com`    |
| IDs    | `usr_1a2b3c4d`                     | `123`              |

Use diverse names in examples (not always "John" and "Jane").

## Annotations

Use inline comments to explain non-obvious lines. Don't over-comment — only annotate what the reader wouldn't understand from the code alone.

```python
response = client.create_charge(
    amount=1000,       # Amount in smallest currency unit (cents)
    currency="usd",
    idempotency_key=uuid4(),  # Prevents duplicate charges on retry
)
```

## Output Examples

When the result matters, show it:

```python
print(response.status)
# => "succeeded"
```

This confirms the example works and sets expectations for what the reader should see.
