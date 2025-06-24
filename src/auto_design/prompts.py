"""
    Config the prompts.
"""

from typing import Callable


BUILDING_BLOCKS = r"""
def Random1() -> p1:
    description = "Random strategy for player 1"
    extra_params = []
    constraints = [
    ]
    return x1

def Random2() -> p2:
    description = "Random strategy for player 2"
    extra_params = []
    constraints = [
    ]
    return y1

def Random3() -> p3:
    description = "Random strategy for player 3"
    extra_params = []
    constraints = [
    ]
    return x3

def BestResponse1(s2: p2, s3: p3) -> p1:
    description = "Best response for player 1 against (s2, s3)"
    extra_params = []
    constraints = [
        forall(x:p1).(U1(x,s2,s3)<=U1(x1,s2,s3))
    ]
    return x1

def BestResponse2(s1: p1, s3: p3) -> p2:
    description = "Best response for player 2 against (s1, s3)"
    extra_params = []
    constraints = [
        forall(y:p2).(U2(s1,y,s3)<=U2(s1,y1,s3))
    ]
    return y1

def BestResponse3(s1: p1, s2: p2) -> p3:
    description = "Best response for player 3 against (s1, s2)"
    extra_params = []
    constraints = [
        forall(z:p3).(U3(s1,s2,z)<=U3(s1,s2,z1))
    ]
    return z1

def StationaryPoint3(s3:p3) -> List[p1, p2, p1, p2]:
    description = "Compute the stationary point and its dual solution of players 1 and 2 when player 3 plays s3"
    extra_params = ["rho3"]
    constraints = [
        f1(w,z,s3)>=f2(w,z,s3), # branch condition
        0<=rho3,
        rho3<=1,
        f1(xs,ys,s3)==f2(xs,ys,s3),
        forall(x:p1).(U1(x,ys,s3)<=U1(w,ys,s3)),
        forall(y:p2).(U2(xs,y,s3)<=U2(xs,z,s3)),
        forall(x:p1).forall(y:p2).(f1(xs,ys,s3)<=rho3*(U1(w,y,s3)-U1(x,ys,s3)-U1(xs,y,s3)+U1(xs,ys,s3))+(1-rho3)*(U2(x,z,s3)-U2(xs,y,s3)-U2(x,ys,s3)+U2(xs,ys,s3)))
    ]
    return xs, ys, w, z

def StationaryPoint1(s1:p1) -> List[p2, p3, p2, p3]:
    description = "Compute the stationary point and its dual solution of players 2 and 3 when player 1 plays s1"
    extra_params = ["rho1"]
    constraints = [
        f1(s1,w,z)>=f2(s1,w,z), # branch condition
        0<=rho1,
        rho1<=1,
        f2(s1,xs,ys)==f3(s1,xs,ys),
        forall(x:p2).(U2(s1,x,ys)<=U2(s1,w,ys)),
        forall(y:p3).(U3(s1,xs,y)<=U3(s1,xs,z)),
        forall(x:p2).forall(y:p3).(f2(s1,xs,ys)<=rho1*(U2(s1,w,y)-U2(s1,x,ys)-U2(s1,xs,y)+U2(s1,xs,ys))+(1-rho1)*(U3(s1,x,z)-U3(s1,xs,y)-U3(s1,x,ys)+U3(s1,xs,ys)))
    ]
    return xs, ys, w, z

def EqMix1(x1: p1, x2: p1) -> p1:
    description = "Equal mixture of two strategies for player 1"
    extra_params = []
    constraints = [
        forall(u:Payoff).forall(y:p2).forall(z:p3).(u(x1,y,z)+u(x2,y,z)==2*u(x,y,z)),
        forall(y:p2).forall(z:p3).(f2(x1,y,z)+f2(x2,y,z)>=2*f2(x,y,z)),
        forall(y:p2).forall(z:p3).(f3(x1,y,z)+f3(x2,y,z)>=2*f3(x,y,z))
    ]
    return x

def EqMix2(y1: p2, y2: p2) -> p2:
    description = "Equal mixture of two strategies for player 2"
    extra_params = []
    constraints = [
        forall(u:Payoff).forall(x:p1).forall(z:p3).(u(x,y1,z)+u(x,y2,z)==2*u(x,y,z)),
        forall(x:p1).forall(z:p3).(f1(x,y1,z)+f1(x,y2,z)>=2*f1(x,y,z)),
        forall(x:p1).forall(z:p3).(f3(x,y1,z)+f3(x,y2,z)>=2*f3(x,y,z))
    ]
    return y

def EqMix3(z1: p3, z2: p3) -> p3:
    description = "Equal mixture of two strategies for player 3"
    extra_params = []
    constraints = [
        forall(u:Payoff).forall(x:p1).forall(y:p2).(u(x,y,z1)+u(x,y,z2)==2*u(x,y,z)),
        forall(x:p1).forall(y:p2).(f1(x,y,z1)+f1(x,y,z2)>=2*f1(x,y,z)),
        forall(x:p1).forall(y:p2).(f2(x,y,z1)+f2(x,y,z2)>=2*f2(x,y,z))
    ]
    return z

def ZeroSumNE1(s1: p1, U: Payoff) -> List[p2, p3]:
    description = "Zero-sum Nash equilibrium for players 2 and 3 with fixed player 1 strategy"
    extra_params = []
    constraints = [
        forall(y:p2).(U(s1,y,z_star)<=U(s1,y_star,z_star)),
        forall(z:p3).(U(s1,y_star,z)>=U(s1,y_star,z_star))
    ]
    return y_star, z_star

def ZeroSumNE2(s2: p2, U: Payoff) -> List[p1, p3]:
    description = "Zero-sum Nash equilibrium for players 1 and 3 with fixed player 2 strategy"
    extra_params = []
    constraints = [
        forall(x:p1).(U(x,s2,z_star)<=U(x_star,s2,z_star)),
        forall(z:p3).(U(x_star,s2,z)>=U(x_star,s2,z_star))
    ]
    return x_star, z_star

def ZeroSumNE3(s3: p3, U: Payoff) -> List[p1, p2]:
    description = "Zero-sum Nash equilibrium for players 1 and 2 with fixed player 3 strategy"
    extra_params = []
    constraints = [
        forall(x:p1).(U(x,y_star,s3)<=U(x_star,y_star,s3)),
        forall(y:p2).(U(x_star,y,s3)>=U(x_star,y_star,s3))
    ]
    return x_star, y_star

def TwoPlayerSOTA3(s3: p3) -> List[p1, p2]:
    description = "Two-player SOTA algorithms for players 1 and 2 with fixed player 3 strategy"
    extra_params = []
    constraints = [
        f1(x1,y1,s3)<=1/3,
        f2(x1,y1,s3)<=1/3
    ]
    return x1, y1

def TwoPlayerSOTA2(s2: p2) -> List[p1, p3]:
    description = "Two-player SOTA algorithms for players 1 and 3 with fixed player 2 strategy"
    extra_params = []
    constraints = [
        f1(x1,s2,z1)<=1/3,
        f3(x1,s2,z1)<=1/3
    ]
    return x1, z1

def TwoPlayerSOTA1(s1: p1) -> List[p2, p3]:
    description = "Two-player SOTA algorithms for players 2 and 3 with fixed player 1 strategy"
    extra_params = []
    constraints = [
        f2(s1,y1,z1)<=1/3,
        f3(s1,y1,z1)<=1/3
    ]
    return y1, z1
"""

INHERENT_CONSTRAINTS = r"""
def inherent_constraints() -> p1:
    description = "Inherent constraints for 3-player games"
    extra_params = []
    constraints = [
        forall(x1:p1).forall(x2:p1).forall(y:p2).forall(z:p3).(f1(x1,y,z)-f1(x2,y,z)==U1(x2,y,z)-U1(x1,y,z)),
        forall(x:p1).forall(y1:p2).forall(y2:p2).forall(z:p3).(f2(x,y1,z)-f2(x,y2,z)==U2(x,y2,z)-U2(x,y1,z)),
        forall(x:p1).forall(y:p2).forall(z1:p3).forall(z2:p3).(f3(x,y,z1)-f3(x,y,z2)==U3(x,y,z2)-U3(x,y,z1)),
        
        forall(x:p1).forall(y:p2).forall(z:p3).(f1(x,y,z)+U1(x,y,z)<=1),
        forall(x:p1).forall(y:p2).forall(z:p3).(f2(x,y,z)+U2(x,y,z)<=1),
        forall(x:p1).forall(y:p2).forall(z:p3).(f3(x,y,z)+U3(x,y,z)<=1),
        
        forall(x:p1).forall(y:p2).forall(z:p3).(f1(x,y,z)>=0),
        forall(x:p1).forall(y:p2).forall(z:p3).(f2(x,y,z)>=0),
        forall(x:p1).forall(y:p2).forall(z:p3).(f3(x,y,z)>=0),
        
        forall(x:p1).forall(y:p2).forall(z:p3).forall(U:Payoff).(U(x,y,z)>=0)
    ]
    return None

"""

NUM_PLAYER_DECLARE = r"""num_players = 3
"""

SAMPLE_OUTPUT = r"""
```python
def algo():
    x_init: p3 = Random3()
    x1: p1, x2: p2, y1: p1, y2: p2 = StationaryPoint(x_init)
    x1s: p1, y2s: p2 = ZeroSumNE3(x_init, U1 + U2)
```
"""

FIRST_ROUND_PROMPT = f"""You are an expert in algorithmic game theory. Now you are given a task to design approximate Nash equilibrium (ANE) algorithms for three-player games with an approximation $\\epsilon$ as small as possible. Specifically, for each round, you need to give me a python-like function called `algo()` using provided building blocks. Then, the compiler will give you the error message (if your code has bugs) or the approximation $\\epsilon$ your given algorithm has. You can use these information to modify your code in the next round.

You need to follow the following instructions:
    1. `p1`, `p2`,... are the types of strategies. `pi` is the strategy of player i. `Payoff` is the type of payoff. 
    3. You can only define `algo()` using static single assignments (SSAs), that is, returning with a function calling. E.g., `x1: p1, x2: p2, y1: p1, y2: p2 = StationaryPoint(x_init)`. Any other code is not allowed, for example, you cannot write `x1: p1, x2: p2, _, _ = StationaryPoint(x_init)` or `x1: p1, x2: p2 = StationaryPoint(x_init)[0:2]`. Also, nested callings and direct assignment (e.g., `x: p1=y`) are prohibited.
    4. You can only construct at most THREE strategies for each player, the less the better (Occam's Razor). 
    5. Each assignment statement be given a type annotation, e.g., `x1: p1, x2: p2, y1: p1, y2: p2 = StationaryPoint(x_init)`, here `p1` and `p2` are necessary.
    6. You must follow the type annotations of building blocks when calling them.
    7. You must not provide the return statement, as the compiler will automatically combining all constructed strategies to obtain the return.
    8. Break symmetry may help, i.e., you can do different things on different players.
    9. You can only output the `def algo():` statements in python code block.
    10. Don't produce duplicate algorithms in new rounds.
    11. TwoPlayerSOTA is very good to use.

Provided building blocks: 
{BUILDING_BLOCKS}

Sample output: 
{SAMPLE_OUTPUT}

Your output algorithm starts here:
"""

def COMPILE_ERROR_PROMPT(err_msg: str) -> str:
    return f"""Your code has caused a compile error. The error message is here:
{err_msg}

Remember:

1. You must use building blocks given in the first round.
2. You can only construct at most THREE strategies for each player, the less the better (Occam's Razor). The more complex constraints a building block has, the more powerful it is to produce a better approximation bound.
3. You can only define `algo()` using static single assignments (SSAs), that is, returning with a function calling. E.g., `x1: p1, x2: p2, y1: p1, y2: p2 = StationaryPoint(x_init)`. Any other code is not allowed, for example, you cannot write `x1: p1, x2: p2, _, _ = StationaryPoint(x_init)` or `x1: p1, x2: p2 = StationaryPoint(x_init)[0:2]`. Also, nested callings and direct assignment (e.g., `x: p1=y`) are prohibited.
4. You must follow the type annotations of building blocks when calling them.
5. Breaking symmetry may help, i.e., you can apply very different building blocks on different players.
6. Be brave to use building blocks that are different from previous ones.
7. Don't produce duplicate algorithms in new rounds.
8. TwoPlayerSOTA is very good to use.

Your new output algorithm starts here:
"""

def APPROX_PROMPT(approx: float) -> str:
    return f"""Your provided code has an approximation $\\epsilon$ of {str(approx)}

Remember:

1. You must use building blocks given in the first round.
2. You can only construct at most THREE strategies for each player, the less the better (Occam's Razor). The more complex constraints a building block has, the more powerful it is to produce a better approximation bound.
3. You can only define `algo()` using static single assignments (SSAs), that is, returning with a function calling. E.g., `x1: p1, x2: p2, y1: p1, y2: p2 = StationaryPoint(x_init)`. Any other code is not allowed, for example, you cannot write `x1: p1, x2: p2, _, _ = StationaryPoint(x_init)` or `x1: p1, x2: p2 = StationaryPoint(x_init)[0:2]`. Also, nested callings and direct assignment (e.g., `x: p1=y`) are prohibited.
4. You must follow the type annotations of building blocks when calling them.
5. Breaking symmetry may help, i.e., you can apply very different building blocks on different players.
6. Be brave to use building blocks that are different from previous ones.
7. Don't produce duplicate algorithms in new rounds.
8. TwoPlayerSOTA is very good to use.

Try to improve the bound! Your new output algorithm starts here:
"""
