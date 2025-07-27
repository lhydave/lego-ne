startTime = AbsoluteTime[];(* Mathematica code generated from ../experiments/legone-code/bbm-1-38.legone *)

(* name alias and parameters *)
d_U1;	 (* U1(x_star,y_star) *)
d_f1;	 (* f1(x_star,y_star) *)
d_U2;	 (* U2(x_star,y_star) *)
d_f2;	 (* f2(x_star,y_star) *)
c_U1;	 (* U1(x_star,b2) *)
c_f1;	 (* f1(x_star,b2) *)
c_U2;	 (* U2(x_star,b2) *)
c_f2;	 (* f2(x_star,b2) *)
b_U1;	 (* U1(r1,y_star) *)
b_f1;	 (* f1(r1,y_star) *)
b_U2;	 (* U2(r1,y_star) *)
b_f2;	 (* f2(r1,y_star) *)
a_U1;	 (* U1(r1,b2) *)
a_f1;	 (* f1(r1,b2) *)
a_U2;	 (* U2(r1,b2) *)
a_f2;	 (* f2(r1,b2) *)

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



bound1 = optMix[a_f1, c_f1, a_f2, c_f2];  (* line (r1,b2) -- (x_star,b2) *)
bound2 = optMix[b_f1, d_f1, b_f2, d_f2];  (* line (r1,y_star) -- (x_star,y_star) *)
bound3 = optMix[a_f1, b_f1, a_f2, b_f2];  (* line (r1,b2) -- (r1,y_star) *)
bound4 = optMix[c_f1, d_f1, c_f2, d_f2];  (* line (x_star,b2) -- (x_star,y_star) *)
bound  = Min[bound1, bound2, bound3, bound4];  (* final bound *)

(* constraints *)
constraints = {
	(* ((U1(r1,y_star) - U2(r1,y_star)) <= (U1(x_star,y_star) - U2(x_star,y_star))) *)
	((b_U1 - b_U2) <= (d_U1 - d_U2)),
	(* ((U1(x_star,y_star) - U2(x_star,y_star)) <= (U1(x_star,y_star) - U2(x_star,y_star))) *)
	((d_U1 - d_U2) <= (d_U1 - d_U2)),
	(* ((U1(x_star,b2) - U2(x_star,b2)) >= (U1(x_star,y_star) - U2(x_star,y_star))) *)
	((c_U1 - c_U2) >= (d_U1 - d_U2)),
	(* ((U1(x_star,y_star) - U2(x_star,y_star)) >= (U1(x_star,y_star) - U2(x_star,y_star))) *)
	((d_U1 - d_U2) >= (d_U1 - d_U2)),
	(* (f1(x_star,y_star) >= f2(x_star,y_star)) *)
	(d_f1 >= d_f2),
	(* (U1(r1,y_star) <= U1(r1,y_star)) *)
	(b_U1 <= b_U1),
	(* (U1(x_star,y_star) <= U1(r1,y_star)) *)
	(d_U1 <= b_U1),
	(* ((U1(r1,y_star) + f1(r1,y_star)) <= U1(r1,y_star)) *)
	((b_U1 + b_f1) <= b_U1),
	(* ((U1(x_star,y_star) + f1(x_star,y_star)) <= U1(r1,y_star)) *)
	((d_U1 + d_f1) <= b_U1),
	(* (U2(r1,b2) <= U2(r1,b2)) *)
	(a_U2 <= a_U2),
	(* (U2(r1,y_star) <= U2(r1,b2)) *)
	(b_U2 <= a_U2),
	(* ((U2(r1,b2) + f2(r1,b2)) <= U2(r1,b2)) *)
	((a_U2 + a_f2) <= a_U2),
	(* ((U2(r1,y_star) + f2(r1,y_star)) <= U2(r1,b2)) *)
	((b_U2 + b_f2) <= a_U2),
	(* ((f1(r1,b2) - f1(r1,b2)) == (U1(r1,b2) - U1(r1,b2))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),
	(* ((f1(x_star,b2) - f1(r1,b2)) == (U1(r1,b2) - U1(x_star,b2))) *)
	((c_f1 - a_f1) == (a_U1 - c_U1)),
	(* ((f1(r1,b2) - f1(x_star,b2)) == (U1(x_star,b2) - U1(r1,b2))) *)
	((a_f1 - c_f1) == (c_U1 - a_U1)),
	(* ((f1(x_star,b2) - f1(x_star,b2)) == (U1(x_star,b2) - U1(x_star,b2))) *)
	((c_f1 - c_f1) == (c_U1 - c_U1)),
	(* ((f1(r1,y_star) - f1(r1,y_star)) == (U1(r1,y_star) - U1(r1,y_star))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),
	(* ((f1(x_star,y_star) - f1(r1,y_star)) == (U1(r1,y_star) - U1(x_star,y_star))) *)
	((d_f1 - b_f1) == (b_U1 - d_U1)),
	(* ((f1(r1,y_star) - f1(x_star,y_star)) == (U1(x_star,y_star) - U1(r1,y_star))) *)
	((b_f1 - d_f1) == (d_U1 - b_U1)),
	(* ((f1(x_star,y_star) - f1(x_star,y_star)) == (U1(x_star,y_star) - U1(x_star,y_star))) *)
	((d_f1 - d_f1) == (d_U1 - d_U1)),
	(* ((f2(r1,b2) - f2(r1,b2)) == (U2(r1,b2) - U2(r1,b2))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),
	(* ((f2(x_star,b2) - f2(x_star,b2)) == (U2(x_star,b2) - U2(x_star,b2))) *)
	((c_f2 - c_f2) == (c_U2 - c_U2)),
	(* ((f2(r1,y_star) - f2(r1,b2)) == (U2(r1,b2) - U2(r1,y_star))) *)
	((b_f2 - a_f2) == (a_U2 - b_U2)),
	(* ((f2(x_star,y_star) - f2(x_star,b2)) == (U2(x_star,b2) - U2(x_star,y_star))) *)
	((d_f2 - c_f2) == (c_U2 - d_U2)),
	(* ((f2(r1,b2) - f2(r1,y_star)) == (U2(r1,y_star) - U2(r1,b2))) *)
	((a_f2 - b_f2) == (b_U2 - a_U2)),
	(* ((f2(x_star,b2) - f2(x_star,y_star)) == (U2(x_star,y_star) - U2(x_star,b2))) *)
	((c_f2 - d_f2) == (d_U2 - c_U2)),
	(* ((f2(r1,y_star) - f2(r1,y_star)) == (U2(r1,y_star) - U2(r1,y_star))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),
	(* ((f2(x_star,y_star) - f2(x_star,y_star)) == (U2(x_star,y_star) - U2(x_star,y_star))) *)
	((d_f2 - d_f2) == (d_U2 - d_U2)),
	(* ((f1(r1,b2) + U1(r1,b2)) <= 1.000000) *)
	((a_f1 + a_U1) <= 1.000000),
	(* ((f1(x_star,b2) + U1(x_star,b2)) <= 1.000000) *)
	((c_f1 + c_U1) <= 1.000000),
	(* ((f1(r1,y_star) + U1(r1,y_star)) <= 1.000000) *)
	((b_f1 + b_U1) <= 1.000000),
	(* ((f1(x_star,y_star) + U1(x_star,y_star)) <= 1.000000) *)
	((d_f1 + d_U1) <= 1.000000),
	(* ((f2(r1,b2) + U2(r1,b2)) <= 1.000000) *)
	((a_f2 + a_U2) <= 1.000000),
	(* ((f2(x_star,b2) + U2(x_star,b2)) <= 1.000000) *)
	((c_f2 + c_U2) <= 1.000000),
	(* ((f2(r1,y_star) + U2(r1,y_star)) <= 1.000000) *)
	((b_f2 + b_U2) <= 1.000000),
	(* ((f2(x_star,y_star) + U2(x_star,y_star)) <= 1.000000) *)
	((d_f2 + d_U2) <= 1.000000),
	(* (f1(r1,b2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x_star,b2) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(r1,y_star) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x_star,y_star) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(r1,b2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(r1,y_star) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x_star,b2) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(x_star,y_star) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(r1,b2) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x_star,b2) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(r1,y_star) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x_star,y_star) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f2(r1,b2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x_star,b2) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(r1,y_star) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x_star,y_star) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(r1,b2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(r1,y_star) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x_star,b2) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(x_star,y_star) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(r1,b2) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x_star,b2) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(r1,y_star) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x_star,y_star) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (U2(r1,b2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x_star,b2) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(r1,y_star) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(x_star,y_star) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* (U1(r1,b2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(x_star,b2) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(r1,y_star) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U1(x_star,y_star) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* ((U2(r1,b2) + f2(r1,b2)) >= 0.000000) *)
	((a_U2 + a_f2) >= 0.000000),
	(* ((U2(r1,y_star) + f2(r1,y_star)) >= 0.000000) *)
	((b_U2 + b_f2) >= 0.000000),
	(* (U1(r1,b2) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(r1,y_star) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* ((U2(x_star,b2) + f2(x_star,b2)) >= 0.000000) *)
	((c_U2 + c_f2) >= 0.000000),
	(* ((U2(x_star,y_star) + f2(x_star,y_star)) >= 0.000000) *)
	((d_U2 + d_f2) >= 0.000000),
	(* (U1(x_star,b2) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(x_star,y_star) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* (U2(r1,b2) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x_star,b2) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(r1,y_star) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(x_star,y_star) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* ((U1(r1,b2) + f1(r1,b2)) >= 0.000000) *)
	((a_U1 + a_f1) >= 0.000000),
	(* ((U1(x_star,b2) + f1(x_star,b2)) >= 0.000000) *)
	((c_U1 + c_f1) >= 0.000000),
	(* ((U1(r1,y_star) + f1(r1,y_star)) >= 0.000000) *)
	((b_U1 + b_f1) >= 0.000000),
	(* ((U1(x_star,y_star) + f1(x_star,y_star)) >= 0.000000) *)
	((d_U1 + d_f1) >= 0.000000)
};

(* optimization for approximation bounds *)
result = NMaxValue[{bound, constraints}, {d_U1, d_f1, d_U2, d_f2, c_U1, c_f1, c_U2, c_f2, b_U1, b_f1, b_U2, b_f2, a_U1, a_f1, a_U2, a_f2}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000]

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];
