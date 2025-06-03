"""
    The main file to do the auto-design experiments.
"""

from auto_design.driver import Driver
from auto_design.llm_interact import LLMConfig


llm_config = LLMConfig(
    api_key="YOUR API KEY HERE",
    base_url="YOUR BASE URL HERE",
    model="YOUR MODEL NAME HERE",
    temperature=0.8,
)

compiler_path = "./compiler.exe"
result_store_path = "../experiments/auto-design-results"
log_path = "../experiments/auto-design.log"

max_algo_gen = 10
max_round_mem = 50
restart_threshold = 5

driver = Driver(
    result_store_path,
    log_path,
    compiler_path,
    llm_config,
    max_algo_gen,
    max_round_mem,
    restart_threshold,
)

driver.run()
