"""
    Config the prompts.
"""

from typing import Callable


BUILDING_BLOCKS = r"""
def BestResponse1(s2: p2) -> p1:
    description = "Best response for player 1 against s2"
    extra_params = []
    constraints = [
        forall(x:p1).(U1(x,s2)<=U1(x1,s2))
    ]
    return x1

def BestResponse2(s1: p1) -> p2:
    description = "Best response for player 2 against s1"
    extra_params = []
    constraints = [
        forall(y:p2).(U2(s1,y)<=U2(s1,y1))
    ]
    return y1

def Random1() -> p1:
    description = "Random strategy for player 1"
    extra_params = []
    constraints = []
    return x

def Random2() -> p2:
    description = "Random strategy for player 2"
    extra_params = []
    constraints = []
    return y

def StationaryPoint() -> List[p1, p2, p1, p2]:
    description = "Compute the stationary point and its dual solution"
    extra_params = ["rho"]
    constraints = [
        0<=rho,
        rho<=1,
        f1(xs,ys)==f2(xs,ys),
        forall(x:p1).(U1(x,ys)<=U1(w,ys)),
        forall(y:p2).(U2(xs,y)<=U2(xs,z)),
        forall(x:p1).forall(y:p2).(f1(xs,ys)<=rho*(U1(w,y)-U1(x,ys)-U1(xs,y)+U1(xs,ys))+(1-rho)*(U2(x,z)-U2(xs,y)-U2(x,ys)+U2(xs,ys)))
    ]
    return xs, ys, w, z

def ZeroSumNE(U: Payoff) -> List[p1, p2]:
    description = "Zero-sum Nash equilibrium"
    extra_params = []
    constraints = [
        forall(x:p1).(U(x,y_star)<=U(x_star,y_star)),
        forall(y:p2).(U(x_star,y)>=U(x_star,y_star))
    ]
    return x_star, y_star
    
def EqMix1(x1: p1, x2: p1) -> p1:
    description = "Equal mixture of two strategies for player 1"
    extra_params = []
    constraints = [
        forall(u:Payoff).forall(y:p2).(u(x1,y)+u(x2,y)==2*u(x,y)),
        forall(y:p2).(f2(x1,y)+f2(x2,y)>=2*f2(x,y)),
    ]
    return x

def EqMix2(y1: p2, y2: p2) -> p2:
    description = "Equal mixture of two strategies for player 2"
    extra_params = []
    constraints = [
        forall(u:Payoff).forall(x:p1).(u(x,y1)+u(x,y2)==2*u(x,y)),
        forall(x:p1).(f1(x,y1)+f1(x,y2)>=2*f1(x,y)),
    ]
    return y

def MaxPayoff(U: Payoff) -> List[p1, p2]:
    description = "Maximize the payoff U"
    extra_params = []
    constraints = [
        forall(x:p1).forall(y:p2).(U(x,y)<=U(x1,y1))
    ]
    return x1, y1
"""

INHERENT_CONSTRAINTS = r"""
def inherent_constraints() -> p1:
    description = "Inherent constraints"
    extra_params = []
    constraints = [
        forall(x1:p1).forall(x2:p1).forall(y:p2).(f1(x1,y)-f1(x2,y)==U1(x2,y)-U1(x1,y)),
        forall(x:p1).forall(y1:p2).forall(y2:p2).(f2(x,y1)-f2(x,y2)==U2(x,y2)-U2(x,y1)),
        forall(x:p1).forall(y:p2).(f1(x,y)+U1(x,y)<=1),
        forall(x:p1).forall(y:p2).(f2(x,y)+U2(x,y)<=1),
        forall(x:p1).forall(y:p2).(f1(x,y)>=0),
        forall(x:p1).forall(y:p2).(f2(x,y)>=0),
        forall(x:p1).forall(y:p2).forall(U:Payoff).(U(x,y)>=0)
    ]
    return None

"""

NUM_PLAYER_DECLARE = r"""num_players = 2
"""

SAMPLE_OUTPUT = r"""
```python
def algo():
    b1: p1 = Random1()
    b2: p2 = BestResponse2(b1)
    a1: p1 = BestResponse1(b2)
```
"""

FIRST_ROUND_PROMPT = f"""You are an expert in algorithmic game theory. Now you are given a task to design approximate Nash equilibrium (ANE) algorithms for two-player games with an approximation $\\epsilon$ as small as possible. Specifically, for each round, you need to give me a python-like function called `algo()` using provided building blocks. Then, the compiler will give you the error message (if your code has bugs) or the approximation $\\epsilon$ your given algorithm has. You can use these information to modify your code in the next round.

You need to follow the following instructions:
    1. `p1`, `p2`,... are the types of strategies. `pi` is the strategy of player i.
    2. `Payoff` is the type of payoff. There are two inherent payoff variables: `U1` of player 1 and `U2` of player 2. The real parameter of `Payoff` type variable is a linear combination of U1 and U2, e.g., `U1-U2`.
    3. You can only define `algo()` using static single assignments (SSAs).
    4. Each assignment statement be given a type annotation, e.g., `x1: p1, x2: p2, y1: p1, y2: p2 = StationaryPoint()`, here `p1` and `p2` are necessary.
    5. You must not write down the return statement as the compiler will automatically figure out the return. However, you need to construct for each player at least one strategy.
    6. Your algorithm should not exceed 8 lines, the shorter the better (Occam's Razor).
    7. You can only output the `def algo():` statements in python code block.
    8. You can utilize the information given in building block definitions to design the algorithm. Don't let the below "sample output" to restrict your creativity.

Provided building blocks: 
{BUILDING_BLOCKS}

Sample output: 
{SAMPLE_OUTPUT}

Your outout algorithm starts here:
"""

COMPILE_ERROR_PROMPT: Callable[[str], str] = (
    lambda err_msg: """Your code has caused a compile error. The error message is here:
"""
    + err_msg
    + """
Your new outout algorithm starts here:
"""
)

APPROX_PROMPT: Callable[[float], str] = (
    lambda approx: """Your provided code has an approximation $\\epsilon$ of """
    + str(approx)
    + """
Your new outout algorithm starts here:
"""
)
