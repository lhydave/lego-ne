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

Every useful API has detailed documentations in the corresponding python file.

You can find a python example file `auto_design_experiment.py` in the `src` directory. This is an example file as well as the experiment file that demonstrates how to use the LegoNE auto-design module to automatically design approximate NE algorithms. You can modify the example file for your own experiments.

To run the example file, you can run the following command in the `src` directory:

```bash
python3 auto_design_experiment.py
```

When it is running, you can see all the logs in `auto-design.log` file in the `experiments/auto-design` directory. The generated algorithms and their approximation bounds are stored in the `experiments/auto-design/generated-algorithms` directory.

## Repository Structure

The repository contains the following directories:

- `src`: The source code of the LegoNE compiler and the LegoNE auto-design module.
- `experiments`: The experiments of the LegoNE compiler, including the LegoNE code, the generated Mathematica code, and the generated Z3 code.
- `tests`: The test cases of the LegoNE compiler, including the LegoNE code.
- `legone-spec.md`: The specification of the LegoNE programming language. You can learn how to write LegoNE code from this file.
- `README.md`: This file.