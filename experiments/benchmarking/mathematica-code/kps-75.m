startTime = AbsoluteTime[];(* Mathematica code generated from ../experiments/legone-code/kps-75.legone *)

(* name alias and parameters *)
c_U1;	 (* U1(x1,y2) *)
c_f1;	 (* f1(x1,y2) *)
c_U2;	 (* U2(x1,y2) *)
c_f2;	 (* f2(x1,y2) *)
d_U1;	 (* U1(x1,y1) *)
d_f1;	 (* f1(x1,y1) *)
d_U2;	 (* U2(x1,y1) *)
d_f2;	 (* f2(x1,y1) *)
b_U1;	 (* U1(x2,y1) *)
b_f1;	 (* f1(x2,y1) *)
b_U2;	 (* U2(x2,y1) *)
b_f2;	 (* f2(x2,y1) *)
a_U1;	 (* U1(x2,y2) *)
a_f1;	 (* f1(x2,y2) *)
a_U2;	 (* U2(x2,y2) *)
a_f2;	 (* f2(x2,y2) *)

(* constraint for optimal mixing operation *)
interPt[a1_, a2_, b1_, b2_] :=
	((a1 - a2) / (((a1 + b2) - a2) - b1))

interVal[a_, b_, lam_] :=
	((a * (1 - lam)) + (b * lam))

optMix[vara1_, varb1_, vara2_, varb2_] :=
	Min[
		Max[vara1, vara2],
		Max[varb1, varb2],
		If[(((vara1 <= vara2) || (varb1 >= varb2)) && ((vara1 >= vara2) || (varb1 <= varb2))), 1, 
			interVal[vara1, varb1, interPt[vara1, vara2, varb1, varb2]]]]



bound1 = optMix[a_f1, c_f1, a_f2, c_f2];  (* line (x2,y2) -- (x1,y2) *)
bound2 = optMix[b_f1, d_f1, b_f2, d_f2];  (* line (x2,y1) -- (x1,y1) *)
bound3 = optMix[a_f1, b_f1, a_f2, b_f2];  (* line (x2,y2) -- (x2,y1) *)
bound4 = optMix[c_f1, d_f1, c_f2, d_f2];  (* line (x1,y2) -- (x1,y1) *)

(* MANUALLY ADDED -- diagonal upper bound for optimal mixing *)
f1[alpha_, u1_, v1_, h1_, g1_] := alpha*alpha*u1 + alpha*(1 - alpha)*(v1 + h1) + (1 - alpha)*(1 - alpha)*g1;
f2[alpha_, u2_, v2_, h2_, g2_] := alpha*alpha*u2 + alpha*(1 - alpha)*(v2 + h2) + (1 - alpha)*(1 - alpha)*g2;
f[alpha_, u1_, v1_, h1_, g1_, u2_, v2_, h2_, g2_] := Max[f1[alpha, u1, v1, h1, g1], f2[alpha, u2, v2, h2, g2]];

minimum1[u1_, v1_, h1_, g1_] := -(v1 + h1 - 2*g1)/(2*(u1 - v1 - h1 + g1));
minimum2[u2_, v2_, h2_, g2_] := -(v2 + h2 - 2*g2)/(2*(u2 - v2 - h2 + g2));

square[u1_, v1_, h1_, g1_, u2_, v2_, h2_, g2_] := (v1 + h1 - 2*g1 - v2 - h2 + 2*g2)^2 - 4*(u1 - v1 - h1 + g1 - u2 + v2 + h2 - g2)*(g1 - g2);

intersect1[u1_, v1_, h1_, g1_, u2_, v2_, h2_, g2_] := (-(v1 + h1 - 2*g1 - v2 - h2 + 2*g2) + Sqrt[square[u1, v1, h1, g1, u2, v2, h2, g2]])/(2*(u1 - v1 - h1 + g1 - u2 + v2 + h2 - g2));
intersect2[u1_, v1_, h1_, g1_, u2_, v2_, h2_, g2_] := (-(v1 + h1 - 2*g1 - v2 - h2 + 2*g2) - Sqrt[square[u1, v1, h1, g1, u2, v2, h2, g2]])/(2*(u1 - v1 - h1 + g1 - u2 + v2 + h2 - g2));

deteriorate[g1_, g2_, v1_, h1_, v2_, h2_] := -(g1 - g2)/(v1 + h1 - 2*g1 - v2 - h2 + 2*g2);

computeH[u1_, v1_, h1_, g1_, u2_, v2_, h2_, g2_] := Min[
    f[0, u1, v1, h1, g1, u2, v2, h2, g2], 
    f[1, u1, v1, h1, g1, u2, v2, h2, g2], 
    If[Denominator[minimum1[u1, v1, h1, g1]] > 0 && 0 < minimum1[u1, v1, h1, g1] < 1, f[minimum1[u1, v1, h1, g1], u1, v1, h1, g1, u2, v2, h2, g2], 1], 
    If[Denominator[minimum2[u2, v2, h2, g2]] > 0 && 0 < minimum2[u2, v2, h2, g2] < 1, f[minimum2[u2, v2, h2, g2], u1, v1, h1, g1, u2, v2, h2, g2], 1], 
    If[square[u1, v1, h1, g1, u2, v2, h2, g2] >= 0 && Denominator[intersect1[u1, v1, h1, g1, u2, v2, h2, g2]] != 0 && 0 < intersect1[u1, v1, h1, g1, u2, v2, h2, g2] < 1, f[intersect1[u1, v1, h1, g1, u2, v2, h2, g2], u1, v1, h1, g1, u2, v2, h2, g2], 1], 
    If[square[u1, v1, h1, g1, u2, v2, h2, g2] >= 0 && Denominator[intersect2[u1, v1, h1, g1, u2, v2, h2, g2]] != 0 && 0 < intersect2[u1, v1, h1, g1, u2, v2, h2, g2] < 1, f[intersect2[u1, v1, h1, g1, u2, v2, h2, g2], u1, v1, h1, g1, u2, v2, h2, g2], 1], 
    If[Denominator[deteriorate[g1, g2, v1, h1, v2, h2]] == 0 && 0 < deteriorate[g1, g2, v1, h1, v2, h2] < 1, f[deteriorate[g1, g2, v1, h1, v2, h2], u1, v1, h1, g1, u2, v2, h2, g2], 1]
];

bound5 = computeH[d_f1, c_f1, b_f1, a_f1, d_f2, c_f2, b_f2, a_f2];	(* (x1,y1) -- (x2,y2) *)
bound  = bound5;	(* final bound *)

(* constraints *)
constraints = {
	(* (U1(x2,y2) <= U1(x1,y1)) *)
	(a_U1 <= d_U1),
	(* (U1(x1,y2) <= U1(x1,y1)) *)
	(c_U1 <= d_U1),
	(* (U1(x2,y1) <= U1(x1,y1)) *)
	(b_U1 <= d_U1),
	(* (U1(x1,y1) <= U1(x1,y1)) *)
	(d_U1 <= d_U1),
	(* (U1(x2,y2) <= U1(x1,y1)) *)
	(a_U1 <= d_U1),
	(* (U1(x2,y1) <= U1(x1,y1)) *)
	(b_U1 <= d_U1),
	(* (U1(x1,y2) <= U1(x1,y1)) *)
	(c_U1 <= d_U1),
	(* (U1(x1,y1) <= U1(x1,y1)) *)
	(d_U1 <= d_U1),
	(* ((U1(x2,y2) + f1(x2,y2)) <= U1(x1,y1)) *)
	((a_U1 + a_f1) <= d_U1),
	(* ((U1(x1,y2) + f1(x1,y2)) <= U1(x1,y1)) *)
	((c_U1 + c_f1) <= d_U1),
	(* ((U1(x2,y1) + f1(x2,y1)) <= U1(x1,y1)) *)
	((b_U1 + b_f1) <= d_U1),
	(* ((U1(x1,y1) + f1(x1,y1)) <= U1(x1,y1)) *)
	((d_U1 + d_f1) <= d_U1),
	(* (U2(x2,y2) <= U2(x2,y2)) *)
	(a_U2 <= a_U2),
	(* (U2(x1,y2) <= U2(x2,y2)) *)
	(c_U2 <= a_U2),
	(* (U2(x2,y1) <= U2(x2,y2)) *)
	(b_U2 <= a_U2),
	(* (U2(x1,y1) <= U2(x2,y2)) *)
	(d_U2 <= a_U2),
	(* ((U2(x2,y2) + f2(x2,y2)) <= U2(x2,y2)) *)
	((a_U2 + a_f2) <= a_U2),
	(* ((U2(x2,y1) + f2(x2,y1)) <= U2(x2,y2)) *)
	((b_U2 + b_f2) <= a_U2),
	(* ((U2(x1,y2) + f2(x1,y2)) <= U2(x2,y2)) *)
	((c_U2 + c_f2) <= a_U2),
	(* ((U2(x1,y1) + f2(x1,y1)) <= U2(x2,y2)) *)
	((d_U2 + d_f2) <= a_U2),
	(* (U2(x2,y2) <= U2(x2,y2)) *)
	(a_U2 <= a_U2),
	(* (U2(x1,y2) <= U2(x2,y2)) *)
	(c_U2 <= a_U2),
	(* (U2(x2,y1) <= U2(x2,y2)) *)
	(b_U2 <= a_U2),
	(* (U2(x1,y1) <= U2(x2,y2)) *)
	(d_U2 <= a_U2),
	(* ((f1(x2,y2) - f1(x2,y2)) == (U1(x2,y2) - U1(x2,y2))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),
	(* ((f1(x1,y2) - f1(x2,y2)) == (U1(x2,y2) - U1(x1,y2))) *)
	((c_f1 - a_f1) == (a_U1 - c_U1)),
	(* ((f1(x2,y2) - f1(x1,y2)) == (U1(x1,y2) - U1(x2,y2))) *)
	((a_f1 - c_f1) == (c_U1 - a_U1)),
	(* ((f1(x1,y2) - f1(x1,y2)) == (U1(x1,y2) - U1(x1,y2))) *)
	((c_f1 - c_f1) == (c_U1 - c_U1)),
	(* ((f1(x2,y1) - f1(x2,y1)) == (U1(x2,y1) - U1(x2,y1))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),
	(* ((f1(x1,y1) - f1(x2,y1)) == (U1(x2,y1) - U1(x1,y1))) *)
	((d_f1 - b_f1) == (b_U1 - d_U1)),
	(* ((f1(x2,y1) - f1(x1,y1)) == (U1(x1,y1) - U1(x2,y1))) *)
	((b_f1 - d_f1) == (d_U1 - b_U1)),
	(* ((f1(x1,y1) - f1(x1,y1)) == (U1(x1,y1) - U1(x1,y1))) *)
	((d_f1 - d_f1) == (d_U1 - d_U1)),
	(* ((f2(x2,y2) - f2(x2,y2)) == (U2(x2,y2) - U2(x2,y2))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),
	(* ((f2(x1,y2) - f2(x1,y2)) == (U2(x1,y2) - U2(x1,y2))) *)
	((c_f2 - c_f2) == (c_U2 - c_U2)),
	(* ((f2(x2,y1) - f2(x2,y2)) == (U2(x2,y2) - U2(x2,y1))) *)
	((b_f2 - a_f2) == (a_U2 - b_U2)),
	(* ((f2(x1,y1) - f2(x1,y2)) == (U2(x1,y2) - U2(x1,y1))) *)
	((d_f2 - c_f2) == (c_U2 - d_U2)),
	(* ((f2(x2,y2) - f2(x2,y1)) == (U2(x2,y1) - U2(x2,y2))) *)
	((a_f2 - b_f2) == (b_U2 - a_U2)),
	(* ((f2(x1,y2) - f2(x1,y1)) == (U2(x1,y1) - U2(x1,y2))) *)
	((c_f2 - d_f2) == (d_U2 - c_U2)),
	(* ((f2(x2,y1) - f2(x2,y1)) == (U2(x2,y1) - U2(x2,y1))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),
	(* ((f2(x1,y1) - f2(x1,y1)) == (U2(x1,y1) - U2(x1,y1))) *)
	((d_f2 - d_f2) == (d_U2 - d_U2)),
	(* ((f1(x2,y2) + U1(x2,y2)) <= 1.000000) *)
	((a_f1 + a_U1) <= 1.000000),
	(* ((f1(x1,y2) + U1(x1,y2)) <= 1.000000) *)
	((c_f1 + c_U1) <= 1.000000),
	(* ((f1(x2,y1) + U1(x2,y1)) <= 1.000000) *)
	((b_f1 + b_U1) <= 1.000000),
	(* ((f1(x1,y1) + U1(x1,y1)) <= 1.000000) *)
	((d_f1 + d_U1) <= 1.000000),
	(* ((f2(x2,y2) + U2(x2,y2)) <= 1.000000) *)
	((a_f2 + a_U2) <= 1.000000),
	(* ((f2(x1,y2) + U2(x1,y2)) <= 1.000000) *)
	((c_f2 + c_U2) <= 1.000000),
	(* ((f2(x2,y1) + U2(x2,y1)) <= 1.000000) *)
	((b_f2 + b_U2) <= 1.000000),
	(* ((f2(x1,y1) + U2(x1,y1)) <= 1.000000) *)
	((d_f2 + d_U2) <= 1.000000),
	(* (f1(x2,y2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x1,y2) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(x2,y1) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x1,y1) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(x2,y2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x2,y1) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x1,y2) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(x1,y1) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(x2,y2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x1,y2) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(x2,y1) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x1,y1) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f2(x2,y2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x1,y2) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(x2,y1) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x1,y1) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(x2,y2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x2,y1) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x1,y2) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(x1,y1) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(x2,y2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x1,y2) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(x2,y1) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x1,y1) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (U2(x2,y2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x1,y2) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(x2,y1) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(x1,y1) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* (U1(x2,y2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(x1,y2) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(x2,y1) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U1(x1,y1) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* ((U2(x2,y2) + f2(x2,y2)) >= 0.000000) *)
	((a_U2 + a_f2) >= 0.000000),
	(* ((U2(x2,y1) + f2(x2,y1)) >= 0.000000) *)
	((b_U2 + b_f2) >= 0.000000),
	(* (U1(x2,y2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(x2,y1) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* ((U2(x1,y2) + f2(x1,y2)) >= 0.000000) *)
	((c_U2 + c_f2) >= 0.000000),
	(* ((U2(x1,y1) + f2(x1,y1)) >= 0.000000) *)
	((d_U2 + d_f2) >= 0.000000),
	(* (U1(x1,y2) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(x1,y1) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* (U2(x2,y2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x1,y2) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(x2,y1) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(x1,y1) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* ((U1(x2,y2) + f1(x2,y2)) >= 0.000000) *)
	((a_U1 + a_f1) >= 0.000000),
	(* ((U1(x1,y2) + f1(x1,y2)) >= 0.000000) *)
	((c_U1 + c_f1) >= 0.000000),
	(* ((U1(x2,y1) + f1(x2,y1)) >= 0.000000) *)
	((b_U1 + b_f1) >= 0.000000),
	(* ((U1(x1,y1) + f1(x1,y1)) >= 0.000000) *)
	((d_U1 + d_f1) >= 0.000000)
};

(* optimization for approximation bounds *)
result = NMaxValue[{bound, constraints}, {c_U1, c_f1, c_U2, c_f2, d_U1, d_f1, d_U2, d_f2, b_U1, b_f1, b_U2, b_f2, a_U1, a_f1, a_U2, a_f2}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000]

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];
