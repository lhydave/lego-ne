"""
    The experiment driver, including logging functionality.
"""

from auto_design.llm_interact import LLMConfig, LLMInteractor
from auto_design.evaluator import Evaluator
import re
import os


class Driver(object):
    """Driver for automated algorithm design experiments using LLMs.
    
    This class coordinates the interaction between LLM and evaluator to iteratively
    generate and improve LegoNE algorithms. It manages:
    1. Experiment logging and result storage
    2. LLM interactions for algorithm generation
    3. Algorithm evaluation and improvement cycles
    4. Best result tracking
    
    Args:
        result_store_path (str): Directory path to store generated algorithms.
            Will be created if it doesn't exist.
        log_path (str): File path for detailed experiment logs.
            Will overwrite if file exists.
        compiler_path (str): Path to the LegoNE compiler executable.
        llm_config (LLMConfig): Configuration for LLM API access.
        max_round (int): Maximum number of interaction rounds with LLM.
            Each round includes algorithm generation and evaluation.
    
    Attributes:
        best_approx (float): Best approximation bound achieved so far.
            Initialized to 1.0 and updated when better results found.
        gen_algo_no (int): Counter for number of successfully generated algorithms.
    """

    def __init__(
        self,
        result_store_path: str,
        log_path: str,
        compiler_path: str,
        llm_config: LLMConfig,
        max_round: int,
    ):
        self.result_store_path = result_store_path
        self.log_path = log_path

        # Create result store directory if it doesn't exist
        os.makedirs(self.result_store_path, exist_ok=True)

        # Create and open log file
        self.log_file = open(self.log_path, "w", encoding="utf-8")
        self.max_round = max_round

        def logger(msg: str):
            msg_clean = remove_ansi_escape_sequences(msg)
            self.log_file.write(f"{msg_clean}\n")
            self.log_file.flush()
            print(msg)

        self.logger = logger

        self.llm_interactor = LLMInteractor(llm_config, logger)
        self.evaluator = Evaluator(compiler_path, logger=logger)

        self.gen_algo_no = 0
        self.best_approx: float = 1.0

    def save_algo(self, legone_code: str, approx: float, round: int):
        # Save the generated algorithm to a file
        algo_path = os.path.join(
            self.result_store_path, f"algo_{self.gen_algo_no}.legone"
        )
        self.logger(f"Saving algorithm to {algo_path}")
        with open(algo_path, "w", encoding="utf-8") as f:
            f.write(
                f"# This algorithm is generated at round {round}, with approximation bound {approx}\n"
            )
            f.write(legone_code)

    def run(self):
        """Execute the automated algorithm design experiment.
        
        This method runs the main experiment loop:
        1. For each round (up to max_round):
            - Get algorithm from LLM (first prompt or based on previous feedback)
            - Evaluate the algorithm using LegoNE compiler and Mathematica
            - If successful, save algorithm and update best approximation
            - Provide feedback to LLM for next round
        2. Finally outputs the best approximation achieved
        
        The method handles:
            - Failed LLM responses by retrying
            - Compilation errors by providing error feedback
            - Successful cases by providing approximation feedback
            - Logging of all interactions and results
            - Saving of all valid generated algorithms
        
        Results are stored in:
            - Individual algorithm files in result_store_path
            - Complete experiment log in log_path
            - Final best approximation printed to log
        """
        llm_ret: str | None = None
        succ = False
        eval_ret: str | float = ""
        for round in range(self.max_round):
            self.logger(f"\033[1;94mRound {round} starts\033[0m\n")
            # try to get a valid response until success
            while not llm_ret:
                if round == 0:
                    llm_ret = self.llm_interactor.first_round_interact()
                elif succ:
                    llm_ret = self.llm_interactor.approx_output_interact(eval_ret)  # type: ignore
                else:
                    llm_ret = self.llm_interactor.compile_error_interact(eval_ret)  # type: ignore

            # do the evaluation
            succ, eval_ret = self.evaluator.eval(llm_ret)
            if succ:
                self.save_algo(llm_ret, eval_ret, round)  # type: ignore
                self.gen_algo_no += 1
                self.best_approx = min(self.best_approx, eval_ret)  # type: ignore

            llm_ret = None
            self.logger(f"\033[1;94mRound {round} ends\033[0m\n")
        self.logger(f"\033[1;94mThe best approximation is {self.best_approx}\033[0m\n")
        self.log_file.close()


def remove_ansi_escape_sequences(text: str):
    # 正则表达式匹配ANSI转义序列
    ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
    return ansi_escape.sub("", text)
