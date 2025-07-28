# LegoNE - Automating Approximate NE Algorithm Design and Analysis

## Overview

LegoNE is a tool for automating both the design of approximate Nash equilibria (NE) algorithms and their approximation analysis. It contains the following components:

1. **LegoNE programming language**: A python-like language for specifying approximate NE algorithms. Users can specify the building blocks of the algorithm, such as computing the best response, computing an NE for a two-layer zero-sum game, and mixing two strategies. Then, users can write down the algorithm by combining these building blocks.
2. **LegoNE compiler**: A compiler that translates the LegoNE code into Mathematica code that computes the approximation bound of the algorithm.
    
3. **LegoNE auto-design module**: A Python 3 module that automatically designs approximate NE algorithms using large language models (LLMs). It coordinates the interaction between LLM and evaluator (LegoNE compiler + Mathematica) to iteratively generate and improve LegoNE algorithms. It manages:
    1. Experiment logging and result storage
    2. LLM interactions for algorithm generation
    3. Algorithm evaluation and improvement cycles
    4. Best result tracking

## Download

To use LegoNE, you should first download the source code of LegoNE from this repository and run the code on your machine. 

### Download Using Shells

You can use shells to download the source code of LegoNE. For MacOS and Linux users, your shell application is Terminal. For Windows users, your shell application is Command Prompt (cmd).

To download the source code of LegoNE, you need to have `git` installed on your machine. If you don't have `git` installed, you can refer to the [official website](https://git-scm.com/downloads) to download and install `git`.

After installing `git`, you can run the following command in your shell application to download the source code of LegoNE to your current directory:

```bash
git clone https://github.com/lhydave/lego-ne.git
```

After downloading the source code, you can navigate to the `lego-ne` directory to start using LegoNE.

### Download Using Browser

Alternatively, you can download the source code of LegoNE by clicking the green "Code" button on the top right corner of this page, and then click "Download ZIP". After downloading the ZIP file, you can extract the source code to your desired directory.

## Installation

### Prerequisites

To build LegoNE compiler, you need to have the following dependencies installed:
- C++ compiler, e.g., MinGW on Windows, gcc on Linux, or clang on MacOS (support C++20)
- Make, this is installed by default on Linux and MacOS, but you need to install it on Windows, see [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm)
- Flex (>= 2.6), see [Flex GitHub website](https://github.com/westes/flex)
- Bison (>= 3.8.2), see [Bison official website](https://www.gnu.org/software/bison/)

To run the generated Mathematica code, you need to have one of the following applications installed:
- Mathematica (>= 13.0), a commercial GUI-based software
- Wolfram Engine (>= 13.0), a terminal-based free version of Mathematica

Both Mathematica and Wolfram Engine can be downloaded from the [Wolfram website](https://www.wolfram.com/).

To use the LegoNE auto-design module, you need to have the following dependencies installed:
- Python 3.11 or later (you can download it from the [Python official website](https://www.python.org/downloads/))
- pip3 (Python package manager, usually installed with Python)
- openai (python package for LLM interaction)
- attrs (python package for data validation)

You can install the above packages by running the following command:

```bash
pip3 install openai attrs
```

### Build

To build the LegoNE compiler, run the following command in the root directory of the project:

```bash
cd src; make 
```

If the build is successful, you will see a `compiler` executable in the `src` directory. You can also run the following command to clean the build in the `src` directory:

```bash
make clean
```

## How to Write LegoNE Code
LegoNE code is written in a python-like language. You can learn how to write LegoNE code from the `legone-spec.md` file in the root directory of the project. This file contains the specification of the LegoNE programming language, including the syntax and semantics of the language, as well as the example LegoNE code.

## Usage of LegoNE Compiler

The LegoNE code is written in a file with the extension `.legone`. 

To compile the LegoNE code into Mathematica code, you can run the following command in the `src` directory:

```bash
./compiler <input_file>.legone -o <output_file>
```

The compiler will generate a Mathematica code in the same directory as `compiler` with a file name `<output_file>`. You can then run the Mathematica code in Mathematica/Wolfram Engine to get the approximation bound of the algorithm.

For example, if you want to generate Mathematica code for the `example.legone` file with the output file `example.m`, you can run the following command:

```bash
./compiler example.legone -o example.m
```

## Usage of LegoNE Auto-Design Module

The LegoNE auto-design module leverages Large Language Models (LLMs) to automatically generate and refine approximate Nash Equilibria (NE) algorithms. This section provides a detailed guide on how to configure and run this module.

### Configuration

The primary configuration for the auto-design module is handled within the `src/auto_design_experiment.py` file. Before running the experiment, you must configure several parameters.

1.  **LLM Configuration**: You need to provide your own LLM API credentials. Open `src/auto_design_experiment.py` and locate the `llm_config` object.

    ```python
    llm_config = LLMConfig(
        api_key="YOUR API KEY HERE",
        base_url="YOUR BASE URL HERE",
        model="YOUR MODEL NAME HERE",
        temperature=0.8,
    )
    ```

    Replace the placeholder values:
    *   `api_key`: Your secret API key for the LLM service.
    *   `base_url`: The base URL for the API endpoint.
    *   `model`: The specific model name you intend to use.

2.  **Path Configuration**: The script defines paths for the compiler, result storage, and logs. The default values are set relative to the `src` directory. You can modify them if your project structure is different.

    *   `compiler_path`: Path to the compiled `compiler`. Default is `./compiler`.
    *   `result_store_path`: Directory to save the generated algorithms. Default is `../experiments/auto-design/generated-algorithms`.
    *   `log_path`: Path to the log file. Default is `../experiments/auto-design/auto-design.log`.

3.  **Experiment Parameters**: You can also tune the following parameters for the experiment:
    *   `max_algo_gen`: The maximum number of algorithms the module will attempt to generate.
    *   `max_round_mem`: The number of previous interaction rounds to keep in memory for the LLM's context.
    *   `restart_threshold`: The number of consecutive failures or non-improvements before the generation process is restarted.

### Running the Auto-Design Experiment

Once you have configured `auto_design_experiment.py`, you can run the experiment.

1.  Navigate to the `src` directory from the project's root folder:
    ```bash
    cd src
    ```

2.  Execute the Python script:
    ```bash
    python3 auto_design_experiment.py
    ```

### Viewing the Results

*   **Generated Algorithms**: The generated LegoNE algorithm files (with a `.legone` extension) and their calculated approximation bounds will be stored in the `experiments/auto-design/generated-algorithms` directory.
*   **Logs**: You can monitor the progress and see detailed logs of the interaction between the driver and the LLM in the `experiments/auto-design/auto-design.log` file. This is useful for debugging and understanding the generation process.

## Reproducing Experiment Results

### Reproducing Benchmarking Results

To reproduce the benchmarking experiment results, you can run the benchmarking scripts provided in the `experiments/benchmarking` directory.

If you wish to reproduce the compilation from LegoNE code to Mathematica code, you should first follow the instructions in the "Usage of LegoNE Compiler" section to compile the files located in `experiments/benchmarking/legone-code` into the `experiments/benchmarking/mathematica-code` directory. Please note that some of the Mathematica code in this directory has been manually modified or constructed to align with the proofs in the original paper, or due to limitations of the compiler. Then, if you need to reproduce running time, you have to manually add the timing code to the Mathematica code in the `experiments/benchmarking/mathematica-code` directory. 

If you already have the Mathematica code generated from the LegoNE code, you can follow the steps below to run the benchmarking experiments.

First, navigate to the `experiments/benchmarking` directory:
```bash
cd experiments/benchmarking
```

Next, run the `run_all.sh` script. This script will execute all the Mathematica code for the experiments. The output of each experiment will be stored in the `analyzer-outputs` directory.
```bash
./run_all.sh
```

After all the experiments are completed, you can run the `data_analyze.sh` script to analyze the results.
```bash
./data_analyze.sh
```
This script will read the output files from `analyzer-outputs`, calculate the average result and time for each experiment, and save the summary in `analyzer-outputs/summarize.txt`.

You can then view the summarized results in the `analyzer-outputs/summarize.txt` file.

### Reproducing Auto-Design Results

Due to randomness of LLMs, it is almost impossible to reproduce the exact same results of the auto-design module. However, you can rerun the auto-design experiment as described in the "Usage of LegoNE Auto-Design Module" section.

## Repository Structure

The repository contains the following directories:

- `src`: The source code of the LegoNE compiler and the LegoNE auto-design module.
- `experiments`: Contains files related to experiments, such as benchmarking scripts and outputs, and logs from the auto-design module.
- `tests`: The test cases of the LegoNE compiler, including the LegoNE code.
- `legone-spec.md`: The specification of the LegoNE programming language. You can learn how to write LegoNE code from this file.
- `README.md`: This file.