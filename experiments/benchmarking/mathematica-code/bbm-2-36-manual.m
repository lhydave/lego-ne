startTime = AbsoluteTime[]; (* BBM 0.36 -- manually constructed *)
(* name alias *)
a; (* fR(hat{x},y^* ) *)
b; (* fR(hat{x},b2 ) *)
c; (* fC(hat{x},y^* ) *)
d;(* fC(hat{x},b2 ) *)
g1;
g2;
h2;

(* constraints *)
(* case1: delta1=0 *)
constraint1 = {0 <= g1 <= 1/3, 1 >= g1 >= g2 >= 0, 0 <= a <= g1, 
   0 <= b <= 1 - h2, 0 <= c <= h2, d == 0, 0 <= h2 <= 1, a == g1, 
   c == g2};
(* case2:otherwise *)
constraint2 = {1/3 < g1 < Root[1 - 2 # - #^2 + #^3& , 2, 0], 
   1 >= g1 >= g2 >= 0, 0 <= a <= 1, 0 <= b <= 1, 0 <= c <= 1, 
   0 <= d <= 1, 
   0 <= b <= 
    If[1/3 < g1 < Root[1 - 2 # - #^2 + #^3& , 2, 0], 
     1 - (1 - (1 - g1) (-1 + 
            Sqrt@RealAbs[1 + 1/(1 - 2*g1) - 1/g1])) h2, 1], 
   0 <= a <= 
    If[1/3 < g1 < Root[
      1 - 2 # - #^2 + #^3& , 2, 
       0], (1 - (1 - g1) (-1 + 
           Sqrt@RealAbs[1 + 1/(1 - 2*g1) - 1/g1])) g1, 1], d == 0, 
   0 <= c <= 
    If[1/3 < g1 < Root[
      1 - 2 # - #^2 + #^3& , 2, 
       0], (1 - (1 - g1) (-1 + 
            Sqrt@RealAbs[1 + 1/(1 - 2*g1) - 1/g1])) h2 + (1 - 
         g1) (-1 + Sqrt@RealAbs[1 + 1/(1 - 2*g1) - 1/g1]) (1 - g1), 
     1], 0 <= h2 <= g2};
(* case3: delta1=1 *)
constraint3 = {Root[1 - 2 # - #^2 + #^3& , 2, 0] <= g1 < 1, 
   1 >= g1 >= g2 >= 0, a == 0, 0 <= b <= 1, 0 <= c <= 1 - g1, d == 0, 
   0 <= h2 <= 1, h2 == g2};

(* constraint for optimal mixing operation *)
optMix[ar_, br_, ac_, bc_] := If[ac <= ar && bc <= br, Min[ar, br], If[ac >= ar && bc >= br, Min[ac, bc], If[ar + bc - ac - br != 0, (ar*bc - ac*br)/(ar + bc - ac - br), Min[Max[ac, bc], Max[ar, br]]]]];

bound = optMix[a, b, c, d];

(* solve the approximation bound *)
branch1 = NMaxValue[{bound, constraint1}, {a, b, c, d, g1, g2, h2}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000];
branch2 = NMaxValue[{If[1/3 < g1 < Root[1 - 2 # - #^2 + #^3& , 2, 0], Evaluate[bound], 0], constraint2}, {a, b, c, d, g1, g2, h2}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000];
branch3 = NMaxValue[{bound, constraint3}, {a, b, c, d, g1, g2, h2},  WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000];

result = Max[branch1, branch2, branch3]

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];
