startTime = AbsoluteTime[]; (* Mathematica code generated from ../experiments/benchmarking/legone-code/DFM-extention-6.legone *)

(* name alias and parameters *)
b_U1;	 (* U1(x1,y1,z1) *)
b_f1;	 (* f1(x1,y1,z1) *)
b_U2;	 (* U2(x1,y1,z1) *)
b_f2;	 (* f2(x1,y1,z1) *)
b_U3;	 (* U3(x1,y1,z1) *)
b_f3;	 (* f3(x1,y1,z1) *)
a_U1;	 (* U1(x1,y1,z2) *)
a_f1;	 (* f1(x1,y1,z2) *)
a_U2;	 (* U2(x1,y1,z2) *)
a_f2;	 (* f2(x1,y1,z2) *)
a_U3;	 (* U3(x1,y1,z2) *)
a_f3;	 (* f3(x1,y1,z2) *)

(* constraint for optimal mixing operation *)
interPt[a1_, a2_, b1_, b2_] :=
	((a1 - a2) / (((a1 + b2) - a2) - b1))

interVal[a_, b_, lam_] :=
	((a * (1 - lam)) + (b * lam))

optMix[vara1_, varb1_, vara2_, varb2_, vara3_, varb3_] :=
	Min[
		Max[vara1, vara2, vara3],
		Max[varb1, varb2, varb3],
		If[(((vara1 <= vara2) || (varb1 >= varb2)) && ((vara1 >= vara2) || (varb1 <= varb2))), 1, Max[
			interVal[vara1, varb1, interPt[vara1, vara2, varb1, varb2]],
			interVal[vara3, varb3, interPt[vara1, vara2, varb1, varb2]]]],
		If[(((vara1 <= vara3) || (varb1 >= varb3)) && ((vara1 >= vara3) || (varb1 <= varb3))), 1, Max[
			interVal[vara1, varb1, interPt[vara1, vara3, varb1, varb3]],
			interVal[vara2, varb2, interPt[vara1, vara3, varb1, varb3]]]],
		If[(((vara2 <= vara3) || (varb2 >= varb3)) && ((vara2 >= vara3) || (varb2 <= varb3))), 1, Max[
			interVal[vara1, varb1, interPt[vara2, vara3, varb2, varb3]],
			interVal[vara2, varb2, interPt[vara2, vara3, varb2, varb3]]]]]



bound1 = optMix[a_f1, b_f1, a_f2, b_f2, a_f3, b_f3];  (* line (x1,y1,z2) -- (x1,y1,z1) *)
bound  = bound1;                                      (* final bound *)

(* constraints *)
constraints = {
	(* (f1(x1,y1,z1) <= (1.000000 / 3.000000)) *)
	(b_f1 <= (1.000000 / 3.000000)),
	(* (f2(x1,y1,z1) <= (1.000000 / 3.000000)) *)
	(b_f2 <= (1.000000 / 3.000000)),
	(* (U3(x1,y1,z2) <= U3(x1,y1,z2)) *)
	(a_U3 <= a_U3),
	(* (U3(x1,y1,z1) <= U3(x1,y1,z2)) *)
	(b_U3 <= a_U3),
	(* ((U3(x1,y1,z2) + f3(x1,y1,z2)) <= U3(x1,y1,z2)) *)
	((a_U3 + a_f3) <= a_U3),
	(* ((U3(x1,y1,z1) + f3(x1,y1,z1)) <= U3(x1,y1,z2)) *)
	((b_U3 + b_f3) <= a_U3),
	(* ((f1(x1,y1,z2) - f1(x1,y1,z2)) == (U1(x1,y1,z2) - U1(x1,y1,z2))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),
	(* ((f1(x1,y1,z1) - f1(x1,y1,z1)) == (U1(x1,y1,z1) - U1(x1,y1,z1))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),
	(* ((f2(x1,y1,z2) - f2(x1,y1,z2)) == (U2(x1,y1,z2) - U2(x1,y1,z2))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),
	(* ((f2(x1,y1,z1) - f2(x1,y1,z1)) == (U2(x1,y1,z1) - U2(x1,y1,z1))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),
	(* ((f3(x1,y1,z2) - f3(x1,y1,z2)) == (U3(x1,y1,z2) - U3(x1,y1,z2))) *)
	((a_f3 - a_f3) == (a_U3 - a_U3)),
	(* ((f3(x1,y1,z1) - f3(x1,y1,z2)) == (U3(x1,y1,z2) - U3(x1,y1,z1))) *)
	((b_f3 - a_f3) == (a_U3 - b_U3)),
	(* ((f3(x1,y1,z2) - f3(x1,y1,z1)) == (U3(x1,y1,z1) - U3(x1,y1,z2))) *)
	((a_f3 - b_f3) == (b_U3 - a_U3)),
	(* ((f3(x1,y1,z1) - f3(x1,y1,z1)) == (U3(x1,y1,z1) - U3(x1,y1,z1))) *)
	((b_f3 - b_f3) == (b_U3 - b_U3)),
	(* ((f1(x1,y1,z2) + U1(x1,y1,z2)) <= 1.000000) *)
	((a_f1 + a_U1) <= 1.000000),
	(* ((f1(x1,y1,z1) + U1(x1,y1,z1)) <= 1.000000) *)
	((b_f1 + b_U1) <= 1.000000),
	(* ((f2(x1,y1,z2) + U2(x1,y1,z2)) <= 1.000000) *)
	((a_f2 + a_U2) <= 1.000000),
	(* ((f2(x1,y1,z1) + U2(x1,y1,z1)) <= 1.000000) *)
	((b_f2 + b_U2) <= 1.000000),
	(* ((f3(x1,y1,z2) + U3(x1,y1,z2)) <= 1.000000) *)
	((a_f3 + a_U3) <= 1.000000),
	(* ((f3(x1,y1,z1) + U3(x1,y1,z1)) <= 1.000000) *)
	((b_f3 + b_U3) <= 1.000000),
	(* (f1(x1,y1,z2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x1,y1,z1) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x1,y1,z2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x1,y1,z1) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x1,y1,z2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x1,y1,z1) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x1,y1,z2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x1,y1,z1) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f2(x1,y1,z2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x1,y1,z1) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x1,y1,z2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x1,y1,z1) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x1,y1,z2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x1,y1,z1) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x1,y1,z2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x1,y1,z1) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f3(x1,y1,z2) >= 0.000000) *)
	(a_f3 >= 0.000000),
	(* (f3(x1,y1,z1) >= 0.000000) *)
	(b_f3 >= 0.000000),
	(* (f3(x1,y1,z2) >= 0.000000) *)
	(a_f3 >= 0.000000),
	(* (f3(x1,y1,z1) >= 0.000000) *)
	(b_f3 >= 0.000000),
	(* (f3(x1,y1,z2) >= 0.000000) *)
	(a_f3 >= 0.000000),
	(* (f3(x1,y1,z1) >= 0.000000) *)
	(b_f3 >= 0.000000),
	(* (f3(x1,y1,z2) >= 0.000000) *)
	(a_f3 >= 0.000000),
	(* (f3(x1,y1,z1) >= 0.000000) *)
	(b_f3 >= 0.000000),
	(* (U3(x1,y1,z2) >= 0.000000) *)
	(a_U3 >= 0.000000),
	(* (U3(x1,y1,z1) >= 0.000000) *)
	(b_U3 >= 0.000000),
	(* (U2(x1,y1,z2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x1,y1,z1) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U1(x1,y1,z2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(x1,y1,z1) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U3(x1,y1,z2) >= 0.000000) *)
	(a_U3 >= 0.000000),
	(* (U3(x1,y1,z1) >= 0.000000) *)
	(b_U3 >= 0.000000),
	(* ((U2(x1,y1,z2) + f2(x1,y1,z2)) >= 0.000000) *)
	((a_U2 + a_f2) >= 0.000000),
	(* ((U2(x1,y1,z1) + f2(x1,y1,z1)) >= 0.000000) *)
	((b_U2 + b_f2) >= 0.000000),
	(* (U1(x1,y1,z2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(x1,y1,z1) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* ((U3(x1,y1,z2) + f3(x1,y1,z2)) >= 0.000000) *)
	((a_U3 + a_f3) >= 0.000000),
	(* ((U3(x1,y1,z1) + f3(x1,y1,z1)) >= 0.000000) *)
	((b_U3 + b_f3) >= 0.000000),
	(* (U2(x1,y1,z2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x1,y1,z1) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U1(x1,y1,z2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(x1,y1,z1) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U3(x1,y1,z2) >= 0.000000) *)
	(a_U3 >= 0.000000),
	(* (U3(x1,y1,z1) >= 0.000000) *)
	(b_U3 >= 0.000000),
	(* (U2(x1,y1,z2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x1,y1,z1) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* ((U1(x1,y1,z2) + f1(x1,y1,z2)) >= 0.000000) *)
	((a_U1 + a_f1) >= 0.000000),
	(* ((U1(x1,y1,z1) + f1(x1,y1,z1)) >= 0.000000) *)
	((b_U1 + b_f1) >= 0.000000)
};

(* optimization for approximation bounds *)
result=NMaxValue[{bound, constraints}, {b_U1, b_f1, b_U2, b_f2, b_U3, b_f3, a_U1, a_f1, a_U2, a_f2, a_U3, a_f3}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000];

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];