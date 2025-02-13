# Language Specification for LegoNE

LegoNE is a python-like language for specifying approximate NE algorithms.

## Syntax

The syntax of LegoNE can be described by the  EBNF grammar, where
- `[]` denotes an optional element
- `{}` denotes a repetition of zero or more times

The syntax of LegoNE is defined as follows, with the start symbol being `program`:

```ebnf
program                     ::= n_player_decl operation_defs algo_def;
n_player_decl               ::= "num_players" "=" number NEWLINE;

operation_defs              ::= {operation_def};
operation_def               ::= "def" operation_name "(" [operation_fparams] ")" "->" ret_type ":" NEWLINE INDENT operation_body DEDENT;
operation_name              ::= IDENTIFIER;
operation_fparams           ::= operation_fparam {"," operation_fparam};
operation_fparam            ::= strategy_fparam | payoff_fparam;
strategy_fparam             ::= IDENTIFIER ":" player_type;
payoff_fparam               ::= IDENTIFIER ":" payoff_type;

operation_body              ::= description_stmt extra_params_stmt constraints_stmt return_stmt;
description_stmt            ::= "description" "=" STRING NEWLINE;
extra_params_stmt           ::= "extra_params" "=" "[" [PARAM_STRING] {"," PARAM_STRING} "]" NEWLINE;
constraints_stmt            ::= "constraints" "=" "[" [constraint_string] {"," constraint_string} "]" NEWLINE;
return_stmt                 ::= "return" strategy_list NEWLINE;

constraint_string           ::= constraint | quantifiers "(" constraint ")";
quantifiers                 ::= {quantifier};
quantifier                  ::= "forall" "(" (strategy_fparam | payoff_fparam) ").";
constraint                  ::= exp ("==" | ">=" | "<=") exp;
exp                         ::= add_exp;
add_exp                     ::= mul_exp | add_exp ("+" | "-") mul_exp;
mul_exp                     ::= primary_exp | mul_exp "*" val;
primary_exp                 ::= val | "(" exp ")";
val                         ::= number | payoff_val | f_val | param;
payoff_val                  ::= IDENTIFIER "(" strategy_list ")";
f_val                       ::= f_name "(" strategy_list ")";
param                       ::= IDENTIFIER;
f_name                      ::= "f" number;
strategy_list               ::= strategy_rparam {"," strategy_rparam};

algo_def                    ::= "def" "algo" "(" ")" ":" NEWLINE INDENT algo_body DEDENT;
algo_body                   ::= construct_stmt {construct_stmt} [return_stmt];
construct_stmt              ::= strategy_with_type_list "=" operation_name "(" [operation_rparams] ")" NEWLINE;
strategy_with_type_list     ::= strategy_with_type {"," strategy_with_type};
strategy_with_type          ::= IDENTIFIER ":" player_type;
operation_rparams           ::= operation_rparam {"," operation_rparam};
operation_rparam            ::= strategy_rparam | payoff_rparam;
strategy_rparam             ::= IDENTIFIER;
payoff_rparam               ::= linear_combination;
linear_combination          ::= linear_combination {("+" | "-") linear_term} | linear_term;
linear_term                 ::= [number "*"] payoff_name;
payoff_name                 ::= "U" number;

ret_type                    ::= "List" "[" player_type {"," player_type} "]" | player_type;
player_type                 ::= "p" number;
payoff_type                 ::= "Payoff";
number                      ::= INT;
```

## Terminal Symbols

Now we specify the terminal symbols used in the EBNF grammar:

### Comments

Comments are denoted by `#` and continue to the end of the line.

```ebnf
comment ::= "#" .* "\n";
```

### Statements and Indents

To make LegoNE in a python-like style, we use line break (`NEWLINE`) to distinguish different statements, and use indents to denote the program blocks. The indents are denoted by `INDENT`, and the dedents are denoted by `DEDENT`. They are not explicitly written as tokens in the EBNF grammar, but the compiler should be aware of them. When there is a new line with more indents than the previous line, the compiler should insert an `INDENT` token. When there is a new line with fewer indents than the previous line, the compiler should insert a `DEDENT` token. 

However, since LegoNE is so restricted, the compiler will not check the correctness of the indents.

For the detailed rules of line breaks and indents, please refer to [Section 2.1 of Python language specification](https://docs.python.org/3/reference/lexical_analysis.html#line-structure).

### Integers

Integers are denoted by `INT`, which is a sequence of digits, e.g., `123`. We only support non-negative integers which are represented by decimal numbers.

```ebnf
INT ::= [0-9]+;
```

### Identifiers

Identifiers are denoted by `IDENTIFIER`, which is a sequence of letters, digits, and underscores, starting with a letter, e.g., `x`, `x1`, `x_1`. Note that identifiers cannot be in form of `p0`, `p1`, etc., because we use `p` followed by a non-negative integer to denote the player type. They cannot be in form of `f0`, `f1`, etc., because we use `f` followed by a non-negative integer to denote the approximation/incentive/regret function of the player.

```ebnf
IDENTIFIER ::= [a-zA-Z_][a-zA-Z0-9_]*;
```

### Strings

Strings are denoted by `STRING`, which is a sequence of characters enclosed in double quotes, e.g., `"hello world"`.

```ebnf
STRING ::= \"[^\"\n]*\";
```

### Parameter Strings

Parameter strings are denoted by `PARAM_STRING`, which is a sequence of characters enclosed in double quotes, which follows the rule of identifiers, e.g., `"param1"`, `"param2"`.

```ebnf
PARAM_STRING ::= \"[a-zA-Z_][a-zA-Z0-9_]*\";
```

## Types

### Player Types

Player types are denoted by `player_type`, which is a sequence of `p` and a non-negative integer, e.g., `p1`, `p2`, `p3`.

### Payoff Type

Payoff type is denoted by `payoff_type`, which is the string `Payoff`.

### Return Type

Return type is denoted by `ret_type`, which is either a list of player types or a player type. The list of player types is denoted by `List` followed by a list of player types enclosed in square brackets, e.g., `List[p1, p2, p3]`. The player type is denoted by `player_type`.

## Semantics

### Number of Players

The `num_players` declaration specifies the number of players in the game. It is a non-negative integer.

### Operation Definitions

An operation definition specifies the basic operations of the algorithm, such as computing the best response, computing an NE for a two-layer zero-sum game, and mixing two strategies. It has the following components:
- `operation_name`: The name of the operation.
- `operation_fparams`: The formal parameters of the operation, which are either strategies or payoffs. They should be declared with their types. The type of a strategy is the number label of the player, and the type of a payoff is `Payoff`.
- `ret_type`: The return type of the operation, which is either a list of player types or a player type.
- `operation_body`: The body of the operation, which contains the following components:
  - `description_stmt`: A description of the operation.
  - `extra_params_stmt`: The extra parameters of the operation, which are a list of strings, each of which is the name of parameter in the constraints.
  - `constraints_stmt`: The constraints of the operation, which are a list of strings, each of which is a constraint. The construction of constraints will be specified later.
  - `return_stmt`: The return statement of the operation, which is a list of strategies, each of which is a strategy with its player type.

There are two built-in operations that can be used in the algorithm:
- `optimal_mix`: This operation computes the optimal mixing of the given strategies. To obey the syntax, the parameters of this operation should be a list of strategies, and the return type should be a list of strategies, which consists of a valid strategy profile. The compiler should check that each player has at least one strategy as input.
- `argmin`: Given a sequence of strategy profiles, this operation computes the one with minimum approximation. To obey the syntax, the parameters of this operation should be a list of strategy profiles in the following order: player 1's strategy in profile 1, player 2's strategy in profile 1, ..., player n's strategy in profile 1, player 1's strategy in profile 2, player 2's strategy in profile 2, ..., player n's strategy in profile 2, ..., and the return type should be a list of strategies, which consists of a valid strategy profile.

### Inherent Constraints

When an operation named ``inherent_constraints`` is defined, the compiler will recognize it as a special operation that contains the inherent constraints of the game. The constraints in this operation will be added to the constraints of the algorithm automatically. To tame the compiler, the return type of this operation should be any player type. The ``inherent_constraints`` operation must be defined in the program, otherwise the compiler will raise an error.

### Constraint Specification

A constraint is a first-order universal arithmetic formula, which is a string enclosed in double quotes. It is constructed using plus, minus, and multiplication operations, and comparison operations such as `==`, `>=`, and `<=`. The operands of the operations are either numbers, a realized payoff, or an $f$ value. A realized payoff is the evaluation of a payoff function with a list of strategies. An $f$ value is the evaluation of the approximation/incentive/regret function of player `k` with a list of strategies. Thus, they should be treated as a function call with a list of strategies as its arguments.

All bounded variables in the constraints are quantified by `forall` quantifiers. These variables should not appear in the extra parameters or return statements of the operation. 

By default, payoff functions can be used in the constraints without being declared in the formal parameters of the operation. These functions are in the form of `Uk(s1, s2, ..., sn)`, where `Uk` is the payoff function of player `k`, and `s1, s2, ..., sn` are the strategies of the players. The compiler will automatically identify these symbols and handle them properly.

The $f$ values is in the form of `fk(s1, s2, ..., sn)`, where `fk` is the approximation/incentive/regret function of player `k`, and `s1, s2, ..., sn` are the strategies of the players. The compiler will automatically identify these symbols and handle them properly.

### Algorithm Definition

An algorithm definition specifies the main algorithm for the approximate NE. It is composed of a sequence of construction statements, each of which creates a list of strategies by calling an operation. The algorithm will return the list of strategies as the output, which is a valid strategy profile. 

Note that the algorithm can lack the return statement. In this case, the compiler will automatically add the `optimal_mix` operation to the end of the algorithm on all constructed strategies, and return the result. It is recommended to not write the return statement in the algorithm, and let the compiler automatically add the `optimal_mix` operation. This is because these operations will generate great overhead in the constraint programming, and the user should be aware of this.

Thus, if you want to use the `optimal_mix` and `argmin` operations, you ought to follow the following rules: Only one of `optimal_mix` and `argmin` operations can be used in the algorithm. Either of them can be only used once, and must be used at the end of the algorithm.

## Keywords

All the keywords in LegoNE are hard keywords, which means they cannot be used as identifiers. The keywords are:
- `num_players`
- `def`
- `algo`
- `List`
- `p1`, `p2`, `p3`, ...
- `Payoff`
- `f1`, `f2`, `f3`, ...
- `forall`
- `description`
- `extra_params`
- `constraints`
- `return`
- `optimal_mix`
- `argmin`

## Example

The following is an example of a LegoNE program that specifies an approximate NE algorithm for a three-player game:

```python

num_players = 3

def best_response1(U: Payoff, s2: p2, s3: p3) -> p1:
    description = "Compute the best response for player 1 against (s2,s3)"
    extra_params = []
    constraints = [
        forall(x:p1).(U(x1, s2, s3) >= U(x, s2, s3))
    ]
    return x1

def eqmix1(s11: p1, s12: p1) -> p1:
    description = "Compute the equal mixture of s11 and s12 for player 1"
    extra_params = []
    constraints = [
        forall(U:Payoff).forall(s2:p2).forall(s3:p3).(U(s11, s2, s3) + U(s12, s2, s3) == 2 * U(s, s2, s3))
    ]
    return s

def random1() -> p1:
    description = "Randomly choose a strategy for player 1"
    extra_params = []
    constraints = []
    return s

def random2() -> p2:
    description = "Randomly choose a strategy for player 2"
    extra_params = []
    constraints = []
    return s

def random3() -> p3:
    description = "Randomly choose a strategy for player 3"
    extra_params = []
    constraints = []
    return s

def algo():
    s2: p2 = random2()
    s3: p3 = random3()
    s11: p1 = best_response1(U1, s2, s3)
    s12: p1 = random1()
    s1: p1 = eqmix1(s11, s12)
    ret1: p1, ret2: p2, ret3: p3 = OptMix(s1,s11,s12,s2,s3) # by default we will add this operation if the return statement is missing
    return ret1, ret2, ret3
```

The compiler should be able to parse the program and generate the corresponding constraint programming in Mathematica code.

NOTE: All strategies should be defined with its player type. This is force the user to define the strategies for each player, and the compiler can check if the strategies are correctly defined. Otherwise, the generated code could be incorrect without any warning. This is also the reason why we need to define the return type of the operations.
