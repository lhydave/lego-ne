(* Mathematica code generated from ../tests/test_constraint/many_quantifier.legone *)

(* name alias and parameters *)
b_U1;	(* U1(s1,s2) *)
b_f1;	(* f1(s1,s2) *)
b_U2;	(* U2(s1,s2) *)
b_f2;	(* f2(s1,s2) *)
a_U1;	(* U1(t1,s2) *)
a_f1;	(* f1(t1,s2) *)
a_U2;	(* U2(t1,s2) *)
a_f2;	(* f2(t1,s2) *)
rho;	(* param rho *)

(* constraint for optimal mixing operation *)
optmix[vara1_, varb1_, vara2_, varb2_] := Piecewise[{
	{ Min[Min[Max[vara1, vara2], Max[varb1, varb2]], Max[(1 - (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1)) * vara1 + (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1) * varb1, (1 - (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1)) * vara2 + (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1) * varb2]], ((vara1 > varb1 && vara2 < varb2) || (vara1 < varb1 && vara2 > varb2)) }},
	Min[Max[vara1, vara2], Max[varb1, varb2]]];

bound1 = optmix[a_f1, b_f1, a_f2, b_f2];	(* (t1,s2) -- (s1,s2) *)


(* constraints *)
constraints = {
	(a_U2 <= b_U2),          (* (U2(t1,s2) <= U2(s1,s2)) *)
	(b_U2 <= b_U2),          (* (U2(s1,s2) <= U2(s1,s2)) *)
	(a_U1 <= b_U1),          (* (U1(t1,s2) <= U1(s1,s2)) *)
	(b_U1 <= b_U1),          (* (U1(s1,s2) <= U1(s1,s2)) *)
	((a_U2 + a_f2) <= b_U2),  (* ((U2(t1,s2) + f2(t1,s2)) <= U2(s1,s2)) *)
	(a_U1 <= b_U1),          (* (U1(t1,s2) <= U1(s1,s2)) *)
	((b_U2 + b_f2) <= b_U2),  (* ((U2(s1,s2) + f2(s1,s2)) <= U2(s1,s2)) *)
	(b_U1 <= b_U1),          (* (U1(s1,s2) <= U1(s1,s2)) *)
	(a_U2 <= b_U2),          (* (U2(t1,s2) <= U2(s1,s2)) *)
	(b_U2 <= b_U2),          (* (U2(s1,s2) <= U2(s1,s2)) *)
	((a_U1 + a_f1) <= b_U1),  (* ((U1(t1,s2) + f1(t1,s2)) <= U1(s1,s2)) *)
	((b_U1 + b_f1) <= b_U1),  (* ((U1(s1,s2) + f1(s1,s2)) <= U1(s1,s2)) *)
	(a_U1 >= a_U1),          (* (U1(t1,s2) >= U1(t1,s2)) *)
	(a_U1 >= b_U1),          (* (U1(t1,s2) >= U1(s1,s2)) *)
	(a_U1 >= (a_U1 + a_f1)),  (* (U1(t1,s2) >= (U1(t1,s2) + f1(t1,s2))) *)
	(a_U1 >= (b_U1 + b_f1)),  (* (U1(t1,s2) >= (U1(s1,s2) + f1(s1,s2))) *)
	(a_U1 >= (rho * a_U1)),  (* (U1(t1,s2) >= (rho * U1(t1,s2))) *)
	(a_U1 >= 0),             (* (U1(t1,s2) >= 0) *)
	(a_U1 <= 1),             (* (U1(t1,s2) <= 1) *)
	(a_f1 >= 0),             (* (f1(t1,s2) >= 0) *)
	(a_f1 <= 1),             (* (f1(t1,s2) <= 1) *)
	((a_U1 + a_f1) <= 1),    (* ((U1(t1,s2) + f1(t1,s2)) <= 1) *)
	(a_U2 >= 0),             (* (U2(t1,s2) >= 0) *)
	(a_U2 <= 1),             (* (U2(t1,s2) <= 1) *)
	(a_f2 >= 0),             (* (f2(t1,s2) >= 0) *)
	(a_f2 <= 1),             (* (f2(t1,s2) <= 1) *)
	((a_U2 + a_f2) <= 1),    (* ((U2(t1,s2) + f2(t1,s2)) <= 1) *)
	(b_U1 >= 0),             (* (U1(s1,s2) >= 0) *)
	(b_U1 <= 1),             (* (U1(s1,s2) <= 1) *)
	(b_f1 >= 0),             (* (f1(s1,s2) >= 0) *)
	(b_f1 <= 1),             (* (f1(s1,s2) <= 1) *)
	((b_U1 + b_f1) <= 1),    (* ((U1(s1,s2) + f1(s1,s2)) <= 1) *)
	(b_U2 >= 0),             (* (U2(s1,s2) >= 0) *)
	(b_U2 <= 1),             (* (U2(s1,s2) <= 1) *)
	(b_f2 >= 0),             (* (f2(s1,s2) >= 0) *)
	(b_f2 <= 1),             (* (f2(s1,s2) <= 1) *)
	((b_U2 + b_f2) <= 1)     (* ((U2(s1,s2) + f2(s1,s2)) <= 1) *)
};

(* solve the approximation bound *)
NMaximize[{bound1, constraints}, {b_U1, b_f1, b_U2, b_f2, a_U1, a_f1, a_U2, a_f2, rho}, AccuracyGoal -> 40, WorkingPrecision -> 60, Method -> "DifferentialEvolution", MaxIterations -> 1000]