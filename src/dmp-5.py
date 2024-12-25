# Z3 code generated from ../experiments/legone-code/dmp-5.legone
from z3 import *

# predefined functions

# find the maximum of a list of arithmetic expressions
def max_list(nums: list[ArithRef]):
	from functools import reduce
	def max2(a, b):
		return If(a > b, a, b)
	return reduce(max2, nums)

# find the minimum of a list of arithmetic expressions
def min_list(nums: list[ArithRef]):
	from functools import reduce
	def min2(a, b):
		return If(a < b, a, b)
	return reduce(min2, nums)

# piecewise expressions
def piecewise(cases):
    """
    Implements a piecewise function in Z3.
    
    Args:
        cases: A list of (condition, value) pairs.
              The last condition can be True to represent the default case.
    
    Returns:
        A Z3 expression representing the piecewise function.
        
    Example:
        x = Real('x')
        f = piecewise([
            (x * x,     x < 0),
            (x,         x < 1),
            (2 * x + 1, True)
        ])
    """
    if not cases:
        raise ValueError("cases cannot be empty")
    
    *cases_before_last, last_case = cases
    result = last_case[0]  # start with the value of the last case
    
    # build If expressions from back to front
    for value, condition in reversed(cases_before_last):
        result = If(condition, value, result)
    
    return result

solver = Solver()

# name alias and parameters
b_U1 = Real('b_U1') # U1(b1,b2)
b_f1 = Real('b_f1') # f1(b1,b2)
b_U2 = Real('b_U2') # U2(b1,b2)
b_f2 = Real('b_f2') # f2(b1,b2)
a_U1 = Real('a_U1') # U1(a1,b2)
a_f1 = Real('a_f1') # f1(a1,b2)
a_U2 = Real('a_U2') # U2(a1,b2)
a_f2 = Real('a_f2') # f2(a1,b2)

# constraint for optimal mixing operation
def optmix(vara1, varb1, vara2, varb2):
	return piecewise([
		(min_list([min_list([max_list([vara1, vara2]), max_list([varb1, varb2])]), max_list([(1 - (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1)) * vara1 + (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1) * varb1, (1 - (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1)) * vara2 + (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1) * varb2])]), (((vara1 > varb1) & (vara2 < varb2)) | ((vara1 < varb1) & (vara2 > varb2)))),(min_list([max_list([vara1, vara2]), max_list([varb1, varb2])]), True)])

bound1 = optmix(a_f1, b_f1, a_f2, b_f2)	# (a1,b2) -- (b1,b2)


# constraints
solver.add((b_U2 <= b_U2)                           )  # (U2(b1,b2) <= U2(b1,b2))
solver.add(((b_U2 + b_f2) <= b_U2)                  )  # ((U2(b1,b2) + f2(b1,b2)) <= U2(b1,b2))
solver.add(((a_f1 - a_f1) == (a_U1 - a_U1))         )  # ((f1(a1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(a1,b2)))
solver.add(((a_f1 - a_f1) == (a_U1 - a_U1))         )  # ((f1(a1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(a1,b2)))
solver.add(((a_f1 - b_f1) == (b_U1 - a_U1))         )  # ((f1(a1,b2) - f1(b1,b2)) == (U1(b1,b2) - U1(a1,b2)))
solver.add(((a_f1 - b_f1) == (b_U1 - a_U1))         )  # ((f1(a1,b2) - f1(b1,b2)) == (U1(b1,b2) - U1(a1,b2)))
solver.add(((a_f1 - a_f1) == ((a_U1 + a_f1) - a_U1)))  # ((f1(a1,b2) - f1(a1,b2)) == ((U1(a1,b2) + f1(a1,b2)) - U1(a1,b2)))
solver.add(((a_f1 - b_f1) == ((b_U1 + b_f1) - a_U1)))  # ((f1(a1,b2) - f1(b1,b2)) == ((U1(b1,b2) + f1(b1,b2)) - U1(a1,b2)))
solver.add(((a_f1 - a_f1) == ((a_U1 + a_f1) - a_U1)))  # ((f1(a1,b2) - f1(a1,b2)) == ((U1(a1,b2) + f1(a1,b2)) - U1(a1,b2)))
solver.add(((a_f1 - b_f1) == ((b_U1 + b_f1) - a_U1)))  # ((f1(a1,b2) - f1(b1,b2)) == ((U1(b1,b2) + f1(b1,b2)) - U1(a1,b2)))
solver.add(((a_f1 - a_f1) == (a_U1 - a_U1))         )  # ((f1(a1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(a1,b2)))
solver.add(((a_f1 - a_f1) == (a_U1 - a_U1))         )  # ((f1(a1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(a1,b2)))
solver.add(((a_f1 - a_f1) == (a_U1 - a_U1))         )  # ((f1(a1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(a1,b2)))
solver.add(((a_f1 - a_f1) == (a_U1 - a_U1))         )  # ((f1(a1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(a1,b2)))
solver.add(((a_f1 - b_f1) == (b_U1 - a_U1))         )  # ((f1(a1,b2) - f1(b1,b2)) == (U1(b1,b2) - U1(a1,b2)))
solver.add(((a_f1 - b_f1) == (b_U1 - a_U1))         )  # ((f1(a1,b2) - f1(b1,b2)) == (U1(b1,b2) - U1(a1,b2)))
solver.add(((a_f2 - a_f2) == (a_U2 - a_U2))         )  # ((f2(a1,b2) - f2(a1,b2)) == (U2(a1,b2) - U2(a1,b2)))
solver.add(((b_f2 - b_f2) == (b_U2 - b_U2))         )  # ((f2(b1,b2) - f2(b1,b2)) == (U2(b1,b2) - U2(b1,b2)))
solver.add(((a_f2 - a_f2) == (a_U2 - (a_U2 + a_f2))))  # ((f2(a1,b2) - f2(a1,b2)) == (U2(a1,b2) - (U2(a1,b2) + f2(a1,b2))))
solver.add(((b_f2 - b_f2) == (b_U2 - (b_U2 + b_f2))))  # ((f2(b1,b2) - f2(b1,b2)) == (U2(b1,b2) - (U2(b1,b2) + f2(b1,b2))))
solver.add(((a_f2 - a_f2) == ((a_U2 + a_f2) - a_U2)))  # ((f2(a1,b2) - f2(a1,b2)) == ((U2(a1,b2) + f2(a1,b2)) - U2(a1,b2)))
solver.add(((b_f2 - b_f2) == ((b_U2 + b_f2) - b_U2)))  # ((f2(b1,b2) - f2(b1,b2)) == ((U2(b1,b2) + f2(b1,b2)) - U2(b1,b2)))
solver.add(((a_f2 - a_f2) == (a_U2 - a_U2))         )  # ((f2(a1,b2) - f2(a1,b2)) == (U2(a1,b2) - U2(a1,b2)))
solver.add(((b_f2 - b_f2) == (b_U2 - b_U2))         )  # ((f2(b1,b2) - f2(b1,b2)) == (U2(b1,b2) - U2(b1,b2)))
solver.add((a_U1 <= a_U1)                           )  # (U1(a1,b2) <= U1(a1,b2))
solver.add((b_U1 <= a_U1)                           )  # (U1(b1,b2) <= U1(a1,b2))
solver.add(((a_U1 + a_f1) <= a_U1)                  )  # ((U1(a1,b2) + f1(a1,b2)) <= U1(a1,b2))
solver.add(((b_U1 + b_f1) <= a_U1)                  )  # ((U1(b1,b2) + f1(b1,b2)) <= U1(a1,b2))
solver.add((a_U1 >= 0)                              )  # (U1(a1,b2) >= 0)
solver.add((a_U1 <= 1)                              )  # (U1(a1,b2) <= 1)
solver.add((a_f1 >= 0)                              )  # (f1(a1,b2) >= 0)
solver.add((a_f1 <= 1)                              )  # (f1(a1,b2) <= 1)
solver.add(((a_U1 + a_f1) <= 1)                     )  # ((U1(a1,b2) + f1(a1,b2)) <= 1)
solver.add((a_U2 >= 0)                              )  # (U2(a1,b2) >= 0)
solver.add((a_U2 <= 1)                              )  # (U2(a1,b2) <= 1)
solver.add((a_f2 >= 0)                              )  # (f2(a1,b2) >= 0)
solver.add((a_f2 <= 1)                              )  # (f2(a1,b2) <= 1)
solver.add(((a_U2 + a_f2) <= 1)                     )  # ((U2(a1,b2) + f2(a1,b2)) <= 1)
solver.add((b_U1 >= 0)                              )  # (U1(b1,b2) >= 0)
solver.add((b_U1 <= 1)                              )  # (U1(b1,b2) <= 1)
solver.add((b_f1 >= 0)                              )  # (f1(b1,b2) >= 0)
solver.add((b_f1 <= 1)                              )  # (f1(b1,b2) <= 1)
solver.add(((b_U1 + b_f1) <= 1)                     )  # ((U1(b1,b2) + f1(b1,b2)) <= 1)
solver.add((b_U2 >= 0)                              )  # (U2(b1,b2) >= 0)
solver.add((b_U2 <= 1)                              )  # (U2(b1,b2) <= 1)
solver.add((b_f2 >= 0)                              )  # (f2(b1,b2) >= 0)
solver.add((b_f2 <= 1)                              )  # (f2(b1,b2) <= 1)
solver.add(((b_U2 + b_f2) <= 1)                     )  # ((U2(b1,b2) + f2(b1,b2)) <= 1)

# constraints for approximation bounds
final_bound_exp = bound1
solver.add(final_bound_exp > 0.6)

# solve the SMT problem
if solver.check() == sat:
	print("Cannot prove that the given algorithm has approximation bound 0.6.")
else:
	print("The given algorithm is proven to have approximation bound 0.6.")

