import os
from pathlib import Path
import pytest
from evaluator import Evaluator


def test_evaluator_workflow_success():
    # Test setup
    compiler_path = "./src/compiler"
    algo_code = """def algo():
    b1: p1 = Random1()
    b2: p2 = BestResponse2(b1)
    a1: p1 = BestResponse1(b2)"""

    # Initialize evaluator
    evaluator = Evaluator(compiler_path)

    # Verify initialization
    assert (
        evaluator.compiler_args[0] == compiler_path
    ), "Compiler path not set correctly"
    assert (
        evaluator.optimizer_args[0] == "wolframscript"
    ), "Default optimizer not set correctly"
    assert (
        evaluator.temp_legone_name == "__eval_temp.legone"
    ), "Temp LegoNE filename not set correctly"
    assert (
        evaluator.temp_wolfram_name == "__eval_temp.m"
    ), "Temp Wolfram filename not set correctly"

    # Test evaluation
    success, result = evaluator.eval(algo_code)

    # Verify return format
    assert isinstance(success, bool), "Success flag should be boolean"
    assert isinstance(
        result, float
    ), "Result should be float (success)"

    assert (success == True), "Cannot fail for this test case"
    # On success, verify approximation bound is approximately 0.5
    assert (
        abs(result - 0.5) < 1e-6
    ), "Approximation bound should be approximately 0.5"

    # Check if temporary files were created and then cleaned up
    assert not Path(
        evaluator.temp_legone_name
    ).exists(), "Temp LegoNE file should be cleaned up"
    assert not Path(
        evaluator.temp_wolfram_name
    ).exists(), "Temp Wolfram file should be cleaned up"


def test_evaluator_workflow_fail():
    # Test setup
    compiler_path = "./src/compiler"
    algo_code = """def algo():
    b1: p1 = Random1()
    b1: p2 = BestResponse2(b1)
    a1: p1 = BestResponse1(b2)"""

    # Initialize evaluator
    evaluator = Evaluator(compiler_path)

    # Verify initialization
    assert (
        evaluator.compiler_args[0] == compiler_path
    ), "Compiler path not set correctly"
    assert (
        evaluator.optimizer_args[0] == "wolframscript"
    ), "Default optimizer not set correctly"
    assert (
        evaluator.temp_legone_name == "__eval_temp.legone"
    ), "Temp LegoNE filename not set correctly"
    assert (
        evaluator.temp_wolfram_name == "__eval_temp.m"
    ), "Temp Wolfram filename not set correctly"

    # Test evaluation
    success, result = evaluator.eval(algo_code)

    # Verify return format
    assert isinstance(success, bool), "Success flag should be boolean"
    assert isinstance(
        result, str
    ), "Result should be str (error)"

    # On failure, verify error message contains "std::runtime_error"
    assert(result == "cannot define symbol b1: it was already defined.\n"), "the output of compile error is different from the expected one"

    # Check if temporary files were cleaned up even after error
    assert not Path(evaluator.temp_legone_name).exists(), "Temp LegoNE file should be cleaned up" 
    assert not Path(evaluator.temp_wolfram_name).exists(), "Temp Wolfram file should be cleaned up"