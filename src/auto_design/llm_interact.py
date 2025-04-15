"""
    Methods and configurations for interacting with LLMs.
"""

from attr import dataclass
from openai import OpenAI
from openai.types.chat import ChatCompletionMessageParam
from auto_design.prompts import FIRST_ROUND_PROMPT, COMPILE_ERROR_PROMPT, APPROX_PROMPT
from typing import Callable
import re


@dataclass
class LLMConfig:
    """Configuration class for LLM interaction.

    Attributes:
        api_key (str): The API key for accessing the LLM service
        base_url (str): The base URL for the LLM API endpoint
        model (str): The name of the LLM model to use
        temperature (float between 0 and 1): The randomness of the LLM output, larger temperature means greater creativity
    """

    api_key: str
    base_url: str
    model: str
    temperature: float


class LLMInteractor(object):
    """Handles interactions with Large Language Models for algorithm generation.

    This class manages the conversation with LLMs, including sending prompts and
    processing responses to generate LegoNE algorithms.

    Args:
        llm_config (LLMConfig): Configuration for LLM interaction
        logger (Callable[[str], None], optional): Function for logging output.
            Defaults to no-op function.
    """

    def __init__(
        self, llm_config: LLMConfig, logger: Callable[[str], None] = lambda msg: None
    ):
        self.client = OpenAI(api_key=llm_config.api_key, base_url=llm_config.base_url)
        self.model = llm_config.model
        self.messages: list[ChatCompletionMessageParam] = []
        self.first_round_prompt = FIRST_ROUND_PROMPT
        self.compile_error_prompt = COMPILE_ERROR_PROMPT
        self.approx_prompt = APPROX_PROMPT
        self.temperature = llm_config.temperature
        if not 0 <= self.temperature <= 1:
            raise ValueError("temperature must be between 0 and 1")
        self.logger = logger

        self.logger(
            "\033[1;95mInitializing LLMInteractor with the following LLM configuration:\033[0m\n"
        )
        self.logger(f"Base URL: {llm_config.base_url}")
        self.logger(f"Model: {llm_config.model}")
        self.logger(f"temperature: {llm_config.temperature}")
        

    def interact(self, message: str):
        """Send a message to LLM and get processed response.

        Args:
            message (str): The prompt message to send to LLM

        Returns:
            str | None: Extracted Python code from LLM response, or None if failed
        """
        self.logger(
            f"""\033[1;95mSending message to LLM. The message is:\033[0m
\033[1;92m{' message begins '.center(100, '=')}\033[0m"""
        )
        self.logger(message)
        self.logger(f"\033[1;92m{' message ends '.center(100, '=')}\033[0m\n")

        # Get response from LLM
        try:
            # Add user message to history
            self.messages.append({"role": "user", "content": message})
#             self.logger(
#                 f"""\033[1;95mCurrent messages JSON:\033[0m
# \033[1;92m{' message JSON begins '.center(100, '=')}\033[0m"""
#             )
#             self.logger(str(self.messages))
#             self.logger(f"\033[1;92m{' message JSON ends '.center(100, '=')}\033[0m\n")

            response = self.client.chat.completions.create(
                model=self.model, messages=self.messages, temperature=self.temperature
            )

        except Exception as e:
            self.messages.pop()
            self.logger(
                f"\033[1;91merror occurs when getting the response. The error message is: {e}\033[0m\n"
            )
            return None

        ret_str = response.choices[0].message.content
        # Add assistant response to history
        self.messages.append({"role": "assistant", "content": ret_str})  # type: ignore

        if not ret_str:
            self.logger("\033[1;93mWarning: Empty response received from LLM\033[0m\n")
            return None

        ret = extract_python_code(ret_str)
        self.logger(
            f"""\033[1;95mReceiving a message from LLM, the contents are:\033[0m
\033[1;92m{' message begins '.center(100,'=')}\033[0m"""
        )
        self.logger(ret_str)
        self.logger(f"\033[1;92m{' message ends '.center(100, '=')}\033[0m\n")

        # if this is a reasoner model, try to record the the reasoning content
        try:
            self.logger(
                f"""\033[1;95mThe reasoning content of LLM is:\033[0m
\033[1;92m{' reasoning begins '.center(100,'=')}\033[0m
{response.choices[0].message.reasoning_content}
\033[1;92m{' reasoning ends '.center(100, '=')}\033[0m
"""
            )
        except:
            pass

        self.logger(
            f"""\033[1;95mThe extracted LegoNE code is:\033[0m
\033[1;92m{' LegoNE code begins '.center(100,'=')}\033[0m"""
        )

        self.logger(str(ret))
        self.logger(f"\033[1;92m{' LegoNE code ends '.center(100, '=')}\033[0m\n")

        return ret

    def first_round_interact(self):
        """Initiate first round of interaction with default prompt.

        Returns:
            str | None: Extracted Python code from LLM response, or None if failed
        """
        return self.interact(self.first_round_prompt)

    def compile_error_interact(self, err_msg: str):
        """Send compile error feedback to LLM and get new attempt.

        Args:
            err_msg (str): The compilation error message

        Returns:
            str | None: Extracted Python code from LLM response, or None if failed
        """
        self.logger(
            "\033[1;91mThe response LegoNE code encounters a compile error\033[0m"
        )
        return self.interact(self.compile_error_prompt(err_msg))

    def approx_output_interact(self, approx: float):
        """Send approximation bound feedback to LLM and get new attempt.

        Args:
            approx (float): The approximation bound achieved by previous attempt

        Returns:
            str | None: Extracted Python code from LLM response, or None if failed
        """
        self.logger("\033[1;92mThe response LegoNE code has an approximation\033[0m")
        return self.interact(self.approx_prompt(approx))


def extract_python_code(message: str):
    # Match code blocks between ```python and ``` or between ```py and ```
    pattern = r"```(?:python|py)\n(.*?)```"
    # Use findall to get all matches and return the last one
    matches: list[str] = re.findall(pattern, message, re.DOTALL)
    return matches[-1] if len(matches) > 0 else None
