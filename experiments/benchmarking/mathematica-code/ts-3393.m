startTime = AbsoluteTime[];(* Mathematica code generated from ../experiments/legone-code/ts-3393.legone *)

(* name alias and parameters *)
d_U1;	 (* U1(xs,ys) *)
d_f1;	 (* f1(xs,ys) *)
d_U2;	 (* U2(xs,ys) *)
d_f2;	 (* f2(xs,ys) *)
c_U1;	 (* U1(xs,z) *)
c_f1;	 (* f1(xs,z) *)
c_U2;	 (* U2(xs,z) *)
c_f2;	 (* f2(xs,z) *)
b_U1;	 (* U1(w,ys) *)
b_f1;	 (* f1(w,ys) *)
b_U2;	 (* U2(w,ys) *)
b_f2;	 (* f2(w,ys) *)
a_U1;	 (* U1(w,z) *)
a_f1;	 (* f1(w,z) *)
a_U2;	 (* U2(w,z) *)
a_f2;	 (* f2(w,z) *)
rho;	 (* param rho *)

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



bound1 = optMix[a_f1, c_f1, a_f2, c_f2];  (* line (w,z) -- (xs,z) *)
bound2 = optMix[b_f1, d_f1, b_f2, d_f2];  (* line (w,ys) -- (xs,ys) *)
bound3 = optMix[a_f1, b_f1, a_f2, b_f2];  (* line (w,z) -- (w,ys) *)
bound4 = optMix[c_f1, d_f1, c_f2, d_f2];  (* line (xs,z) -- (xs,ys) *)
bound  = Min[bound1, bound2, bound3, bound4];  (* final bound *)

(* constraints *)
constraints = {
	(* (0.000000 <= rho) *)
	(0.000000 <= rho),
	(* (rho <= 1.000000) *)
	(rho <= 1.000000),
	(* (f1(xs,ys) == f2(xs,ys)) *)
	(d_f1 == d_f2),
	(* (U1(w,ys) <= U1(w,ys)) *)
	(b_U1 <= b_U1),
	(* (U1(xs,ys) <= U1(w,ys)) *)
	(d_U1 <= b_U1),
	(* ((U1(w,ys) + f1(w,ys)) <= U1(w,ys)) *)
	((b_U1 + b_f1) <= b_U1),
	(* ((U1(xs,ys) + f1(xs,ys)) <= U1(w,ys)) *)
	((d_U1 + d_f1) <= b_U1),
	(* (U2(xs,z) <= U2(xs,z)) *)
	(c_U2 <= c_U2),
	(* (U2(xs,ys) <= U2(xs,z)) *)
	(d_U2 <= c_U2),
	(* ((U2(xs,z) + f2(xs,z)) <= U2(xs,z)) *)
	((c_U2 + c_f2) <= c_U2),
	(* ((U2(xs,ys) + f2(xs,ys)) <= U2(xs,z)) *)
	((d_U2 + d_f2) <= c_U2),
	(* (f1(xs,ys) <= ((rho * (((U1(w,z) - U1(w,ys)) - U1(xs,z)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w,z) - U2(xs,z)) - U2(w,ys)) + U2(xs,ys))))) *)
	(d_f1 <= ((rho * (((a_U1 - b_U1) - c_U1) + d_U1)) + ((1.000000 - rho) * (((a_U2 - c_U2) - b_U2) + d_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,z) - U1(xs,ys)) - U1(xs,z)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(xs,z) - U2(xs,z)) - U2(xs,ys)) + U2(xs,ys))))) *)
	(d_f1 <= ((rho * (((a_U1 - d_U1) - c_U1) + d_U1)) + ((1.000000 - rho) * (((c_U2 - c_U2) - d_U2) + d_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,ys) - U1(w,ys)) - U1(xs,ys)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w,z) - U2(xs,ys)) - U2(w,ys)) + U2(xs,ys))))) *)
	(d_f1 <= ((rho * (((b_U1 - b_U1) - d_U1) + d_U1)) + ((1.000000 - rho) * (((a_U2 - d_U2) - b_U2) + d_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,ys) - U1(xs,ys)) - U1(xs,ys)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(xs,z) - U2(xs,ys)) - U2(xs,ys)) + U2(xs,ys))))) *)
	(d_f1 <= ((rho * (((b_U1 - d_U1) - d_U1) + d_U1)) + ((1.000000 - rho) * (((c_U2 - d_U2) - d_U2) + d_U2)))),
	(* ((f1(w,z) - f1(w,z)) == (U1(w,z) - U1(w,z))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),
	(* ((f1(xs,z) - f1(w,z)) == (U1(w,z) - U1(xs,z))) *)
	((c_f1 - a_f1) == (a_U1 - c_U1)),
	(* ((f1(w,z) - f1(xs,z)) == (U1(xs,z) - U1(w,z))) *)
	((a_f1 - c_f1) == (c_U1 - a_U1)),
	(* ((f1(xs,z) - f1(xs,z)) == (U1(xs,z) - U1(xs,z))) *)
	((c_f1 - c_f1) == (c_U1 - c_U1)),
	(* ((f1(w,ys) - f1(w,ys)) == (U1(w,ys) - U1(w,ys))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),
	(* ((f1(xs,ys) - f1(w,ys)) == (U1(w,ys) - U1(xs,ys))) *)
	((d_f1 - b_f1) == (b_U1 - d_U1)),
	(* ((f1(w,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(w,ys))) *)
	((b_f1 - d_f1) == (d_U1 - b_U1)),
	(* ((f1(xs,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(xs,ys))) *)
	((d_f1 - d_f1) == (d_U1 - d_U1)),
	(* ((f2(w,z) - f2(w,z)) == (U2(w,z) - U2(w,z))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),
	(* ((f2(xs,z) - f2(xs,z)) == (U2(xs,z) - U2(xs,z))) *)
	((c_f2 - c_f2) == (c_U2 - c_U2)),
	(* ((f2(w,ys) - f2(w,z)) == (U2(w,z) - U2(w,ys))) *)
	((b_f2 - a_f2) == (a_U2 - b_U2)),
	(* ((f2(xs,ys) - f2(xs,z)) == (U2(xs,z) - U2(xs,ys))) *)
	((d_f2 - c_f2) == (c_U2 - d_U2)),
	(* ((f2(w,z) - f2(w,ys)) == (U2(w,ys) - U2(w,z))) *)
	((a_f2 - b_f2) == (b_U2 - a_U2)),
	(* ((f2(xs,z) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,z))) *)
	((c_f2 - d_f2) == (d_U2 - c_U2)),
	(* ((f2(w,ys) - f2(w,ys)) == (U2(w,ys) - U2(w,ys))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),
	(* ((f2(xs,ys) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,ys))) *)
	((d_f2 - d_f2) == (d_U2 - d_U2)),
	(* ((f1(w,z) + U1(w,z)) <= 1.000000) *)
	((a_f1 + a_U1) <= 1.000000),
	(* ((f1(xs,z) + U1(xs,z)) <= 1.000000) *)
	((c_f1 + c_U1) <= 1.000000),
	(* ((f1(w,ys) + U1(w,ys)) <= 1.000000) *)
	((b_f1 + b_U1) <= 1.000000),
	(* ((f1(xs,ys) + U1(xs,ys)) <= 1.000000) *)
	((d_f1 + d_U1) <= 1.000000),
	(* ((f2(w,z) + U2(w,z)) <= 1.000000) *)
	((a_f2 + a_U2) <= 1.000000),
	(* ((f2(xs,z) + U2(xs,z)) <= 1.000000) *)
	((c_f2 + c_U2) <= 1.000000),
	(* ((f2(w,ys) + U2(w,ys)) <= 1.000000) *)
	((b_f2 + b_U2) <= 1.000000),
	(* ((f2(xs,ys) + U2(xs,ys)) <= 1.000000) *)
	((d_f2 + d_U2) <= 1.000000),
	(* (f1(w,z) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(xs,z) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(w,ys) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(xs,ys) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(w,z) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(w,ys) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(xs,z) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(xs,ys) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(w,z) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(xs,z) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(w,ys) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(xs,ys) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f2(w,z) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(xs,z) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(w,ys) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(xs,ys) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(w,z) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(w,ys) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(xs,z) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(xs,ys) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(w,z) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(xs,z) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(w,ys) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(xs,ys) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (U2(w,z) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(xs,z) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(w,ys) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(xs,ys) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* (U1(w,z) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(xs,z) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(w,ys) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U1(xs,ys) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* ((U2(w,z) + f2(w,z)) >= 0.000000) *)
	((a_U2 + a_f2) >= 0.000000),
	(* ((U2(w,ys) + f2(w,ys)) >= 0.000000) *)
	((b_U2 + b_f2) >= 0.000000),
	(* (U1(w,z) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(w,ys) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* ((U2(xs,z) + f2(xs,z)) >= 0.000000) *)
	((c_U2 + c_f2) >= 0.000000),
	(* ((U2(xs,ys) + f2(xs,ys)) >= 0.000000) *)
	((d_U2 + d_f2) >= 0.000000),
	(* (U1(xs,z) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(xs,ys) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* (U2(w,z) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(xs,z) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(w,ys) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(xs,ys) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* ((U1(w,z) + f1(w,z)) >= 0.000000) *)
	((a_U1 + a_f1) >= 0.000000),
	(* ((U1(xs,z) + f1(xs,z)) >= 0.000000) *)
	((c_U1 + c_f1) >= 0.000000),
	(* ((U1(w,ys) + f1(w,ys)) >= 0.000000) *)
	((b_U1 + b_f1) >= 0.000000),
	(* ((U1(xs,ys) + f1(xs,ys)) >= 0.000000) *)
	((d_U1 + d_f1) >= 0.000000)
};

(* optimization for approximation bounds *)
result = NMaxValue[{bound, constraints}, {d_U1, d_f1, d_U2, d_f2, c_U1, c_f1, c_U2, c_f2, b_U1, b_f1, b_U2, b_f2, a_U1, a_f1, a_U2, a_f2, rho}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000]

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];
