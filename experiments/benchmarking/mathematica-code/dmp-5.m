startTime = AbsoluteTime[];(* Mathematica code generated from ../experiments/legone-code/dmp-5.legone *)

(* name alias and parameters *)
b_U1;	 (* U1(b1,b2) *)
b_f1;	 (* f1(b1,b2) *)
b_U2;	 (* U2(b1,b2) *)
b_f2;	 (* f2(b1,b2) *)
a_U1;	 (* U1(a1,b2) *)
a_f1;	 (* f1(a1,b2) *)
a_U2;	 (* U2(a1,b2) *)
a_f2;	 (* f2(a1,b2) *)

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



bound1 = optMix[a_f1, b_f1, a_f2, b_f2];  (* line (a1,b2) -- (b1,b2) *)
bound  = bound1;                          (* final bound *)

(* constraints *)
constraints = {
	(* (U2(b1,b2) <= U2(b1,b2)) *)
	(b_U2 <= b_U2),
	(* ((U2(b1,b2) + f2(b1,b2)) <= U2(b1,b2)) *)
	((b_U2 + b_f2) <= b_U2),
	(* (U1(a1,b2) <= U1(a1,b2)) *)
	(a_U1 <= a_U1),
	(* (U1(b1,b2) <= U1(a1,b2)) *)
	(b_U1 <= a_U1),
	(* ((U1(a1,b2) + f1(a1,b2)) <= U1(a1,b2)) *)
	((a_U1 + a_f1) <= a_U1),
	(* ((U1(b1,b2) + f1(b1,b2)) <= U1(a1,b2)) *)
	((b_U1 + b_f1) <= a_U1),
	(* ((f1(a1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(a1,b2))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),
	(* ((f1(b1,b2) - f1(a1,b2)) == (U1(a1,b2) - U1(b1,b2))) *)
	((b_f1 - a_f1) == (a_U1 - b_U1)),
	(* ((f1(a1,b2) - f1(b1,b2)) == (U1(b1,b2) - U1(a1,b2))) *)
	((a_f1 - b_f1) == (b_U1 - a_U1)),
	(* ((f1(b1,b2) - f1(b1,b2)) == (U1(b1,b2) - U1(b1,b2))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),
	(* ((f2(a1,b2) - f2(a1,b2)) == (U2(a1,b2) - U2(a1,b2))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),
	(* ((f2(b1,b2) - f2(b1,b2)) == (U2(b1,b2) - U2(b1,b2))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),
	(* ((f1(a1,b2) + U1(a1,b2)) <= 1.000000) *)
	((a_f1 + a_U1) <= 1.000000),
	(* ((f1(b1,b2) + U1(b1,b2)) <= 1.000000) *)
	((b_f1 + b_U1) <= 1.000000),
	(* ((f2(a1,b2) + U2(a1,b2)) <= 1.000000) *)
	((a_f2 + a_U2) <= 1.000000),
	(* ((f2(b1,b2) + U2(b1,b2)) <= 1.000000) *)
	((b_f2 + b_U2) <= 1.000000),
	(* (f1(a1,b2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(b1,b2) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(a1,b2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(b1,b2) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(a1,b2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(b1,b2) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f2(a1,b2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(b1,b2) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(a1,b2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(b1,b2) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(a1,b2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(b1,b2) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (U2(a1,b2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(b1,b2) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U1(a1,b2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(b1,b2) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* ((U2(a1,b2) + f2(a1,b2)) >= 0.000000) *)
	((a_U2 + a_f2) >= 0.000000),
	(* (U1(a1,b2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* ((U2(b1,b2) + f2(b1,b2)) >= 0.000000) *)
	((b_U2 + b_f2) >= 0.000000),
	(* (U1(b1,b2) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U2(a1,b2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(b1,b2) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* ((U1(a1,b2) + f1(a1,b2)) >= 0.000000) *)
	((a_U1 + a_f1) >= 0.000000),
	(* ((U1(b1,b2) + f1(b1,b2)) >= 0.000000) *)
	((b_U1 + b_f1) >= 0.000000)
};

(* optimization for approximation bounds *)
result = NMaxValue[{bound, constraints}, {b_U1, b_f1, b_U2, b_f2, a_U1, a_f1, a_U2, a_f2}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000]

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];
