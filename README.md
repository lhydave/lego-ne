# Lego NE - Automating Approximate NE Algorithm Design and Analysis

## Overview

AutoApproxNE is a tool for automating the design and analysis of approximate Nash equilibria (NE) algorithms. It contains the following components:

1. **LegoNE**: A python-like language for specifying approximate NE algorithms. The user can specify the basic operations of the algorithm, such as computing the best response, computing an NE for a two-layer zero-sum game, and mixing two strategies. Then, the user can write down the algorithm by combining these basic operations. The LegoNE compiler will then generate Mathematica code whose output is the approximation bound of the algorithm.
2. **LegoNE Compiler**: A compiler that translates the LegoNE code into Mathematica code, which is implemented in C++ with flex and bison.

## Installation

### Prerequisites

To build LegoNE compiler, you need to have the following applications installed:
- gcc/clang (support C++20)
- flex
- bison

To run the generated Mathematica code, you need to have the following application installed:
- Mathematica (>= 13.0)

To run the generated Z3 code, you need to have the following application and package installed:
- python 3
- z3-solver (python package)

### Build

To build the LegoNE compiler, run the following command in the root directory of the project:

```bash
make
```

If the build is successful, you will see a `compiler` executable in the root directory. You can also run the following command to clean the build:

```bash
make clean
```

## Usage

The LegoNE code is written in a file with the extension `.legone`. To compile the LegoNE code, run the following command:

```bash
./compiler <input_file>.legone
```

The compiler will generate a Mathematica code in the same directory with the extension `.m`. You can then run the Mathematica code in Mathematica to get the approximation bound of the algorithm.

If you want to generate Z3 code to prove that an algorithm has a bound $0.33$, you can run the following command:

```bash
./compiler -b 0.33 <input_file>.legone
```

The compiler will generate a Z3 code in the same directory with the extension `.z3`. You can then run the Z3 code in Python to prove that the algorithm has a bound $0.33$.