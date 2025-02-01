# TODO
from openai import OpenAI
from openai.types.chat import ChatCompletionMessageParam
client = OpenAI(api_key="sk-2fb1b94a7fc841e0872ebf3aae550070", base_url="https://api.deepseek.com")

# Round 1
messages: list[ChatCompletionMessageParam] = [{"role": "user", "content": "What's the highest mountain in the world?"}]
response = client.chat.completions.create(
    model="deepseek-chat",
    messages=messages
)

messages.append(response.choices[0].message) # type: ignore
print(f"Messages Round 1: {messages}")

# Round 2
messages.append({"role": "user", "content": "What is the second?"})
response = client.chat.completions.create(
    model="deepseek-chat",
    messages=messages
)

messages.append(response.choices[0].message) # type: ignore
print(f"Messages Round 2: {messages}")