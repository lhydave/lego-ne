(* Mathematica code generated from /Volumes/Files/Projects/lego-ne/experiments/legone-code/ts-3393.legone *)

(* name alias and parameters *)
d_U1;	(* U1(xs,ys) *)
d_f1;	(* f1(xs,ys) *)
d_U2;	(* U2(xs,ys) *)
d_f2;	(* f2(xs,ys) *)
c_U1;	(* U1(xs,z) *)
c_f1;	(* f1(xs,z) *)
c_U2;	(* U2(xs,z) *)
c_f2;	(* f2(xs,z) *)
b_U1;	(* U1(w,ys) *)
b_f1;	(* f1(w,ys) *)
b_U2;	(* U2(w,ys) *)
b_f2;	(* f2(w,ys) *)
a_U1;	(* U1(w,z) *)
a_f1;	(* f1(w,z) *)
a_U2;	(* U2(w,z) *)
a_f2;	(* f2(w,z) *)
rho;	(* param rho *)

(* constraint for optimal mixing operation *)
optmix[vara1_, varb1_, vara2_, varb2_] := Piecewise[{
	{ Min[Min[Max[vara1, vara2], Max[varb1, varb2]], Max[(1 - (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1)) * vara1 + (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1) * varb1, (1 - (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1)) * vara2 + (vara1 * varb2 - vara2 * varb1) / (vara1 + varb2 - vara2 - varb1) * varb2]], ((vara1 > varb1 && vara2 < varb2) || (vara1 < varb1 && vara2 > varb2)) }},
	Min[Max[vara1, vara2], Max[varb1, varb2]]];

bound1 = optmix[a_f1, c_f1, a_f2, c_f2];	(* (w,z) -- (xs,z) *)

bound2 = optmix[b_f1, d_f1, b_f2, d_f2];	(* (w,ys) -- (xs,ys) *)

bound3 = optmix[a_f1, b_f1, a_f2, b_f2];	(* (w,z) -- (w,ys) *)

bound4 = optmix[c_f1, d_f1, c_f2, d_f2];	(* (xs,z) -- (xs,ys) *)


(* constraints *)
constraints = {
	((a_f1 - a_f1) == (a_U1 - a_U1)),                                                                    (* ((f1(w,z) - f1(w,z)) == (U1(w,z) - U1(w,z))) *)
	((c_f1 - a_f1) == (a_U1 - c_U1)),                                                                    (* ((f1(xs,z) - f1(w,z)) == (U1(w,z) - U1(xs,z))) *)
	((a_f1 - c_f1) == (c_U1 - a_U1)),                                                                    (* ((f1(w,z) - f1(xs,z)) == (U1(xs,z) - U1(w,z))) *)
	((c_f1 - c_f1) == (c_U1 - c_U1)),                                                                    (* ((f1(xs,z) - f1(xs,z)) == (U1(xs,z) - U1(xs,z))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),                                                                    (* ((f1(w,ys) - f1(w,ys)) == (U1(w,ys) - U1(w,ys))) *)
	((d_f1 - b_f1) == (b_U1 - d_U1)),                                                                    (* ((f1(xs,ys) - f1(w,ys)) == (U1(w,ys) - U1(xs,ys))) *)
	((b_f1 - d_f1) == (d_U1 - b_U1)),                                                                    (* ((f1(w,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(w,ys))) *)
	((d_f1 - d_f1) == (d_U1 - d_U1)),                                                                    (* ((f1(xs,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(xs,ys))) *)
	((a_f1 - a_f1) == ((a_U1 + a_f1) - a_U1)),                                                           (* ((f1(w,z) - f1(w,z)) == ((U1(w,z) + f1(w,z)) - U1(w,z))) *)
	((a_f1 - c_f1) == ((c_U1 + c_f1) - a_U1)),                                                           (* ((f1(w,z) - f1(xs,z)) == ((U1(xs,z) + f1(xs,z)) - U1(w,z))) *)
	((b_f1 - b_f1) == ((b_U1 + b_f1) - b_U1)),                                                           (* ((f1(w,ys) - f1(w,ys)) == ((U1(w,ys) + f1(w,ys)) - U1(w,ys))) *)
	((b_f1 - d_f1) == ((d_U1 + d_f1) - b_U1)),                                                           (* ((f1(w,ys) - f1(xs,ys)) == ((U1(xs,ys) + f1(xs,ys)) - U1(w,ys))) *)
	((c_f1 - a_f1) == ((a_U1 + a_f1) - c_U1)),                                                           (* ((f1(xs,z) - f1(w,z)) == ((U1(w,z) + f1(w,z)) - U1(xs,z))) *)
	((c_f1 - c_f1) == ((c_U1 + c_f1) - c_U1)),                                                           (* ((f1(xs,z) - f1(xs,z)) == ((U1(xs,z) + f1(xs,z)) - U1(xs,z))) *)
	((d_f1 - b_f1) == ((b_U1 + b_f1) - d_U1)),                                                           (* ((f1(xs,ys) - f1(w,ys)) == ((U1(w,ys) + f1(w,ys)) - U1(xs,ys))) *)
	((d_f1 - d_f1) == ((d_U1 + d_f1) - d_U1)),                                                           (* ((f1(xs,ys) - f1(xs,ys)) == ((U1(xs,ys) + f1(xs,ys)) - U1(xs,ys))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),                                                                    (* ((f1(w,z) - f1(w,z)) == (U1(w,z) - U1(w,z))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),                                                                    (* ((f1(w,ys) - f1(w,ys)) == (U1(w,ys) - U1(w,ys))) *)
	((c_f1 - c_f1) == (c_U1 - c_U1)),                                                                    (* ((f1(xs,z) - f1(xs,z)) == (U1(xs,z) - U1(xs,z))) *)
	((d_f1 - d_f1) == (d_U1 - d_U1)),                                                                    (* ((f1(xs,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(xs,ys))) *)
	((a_f1 - a_f1) == (a_U1 - (a_U1 + a_f1))),                                                           (* ((f1(w,z) - f1(w,z)) == (U1(w,z) - (U1(w,z) + f1(w,z)))) *)
	((c_f1 - a_f1) == (a_U1 - (c_U1 + c_f1))),                                                           (* ((f1(xs,z) - f1(w,z)) == (U1(w,z) - (U1(xs,z) + f1(xs,z)))) *)
	((a_f1 - c_f1) == (c_U1 - (a_U1 + a_f1))),                                                           (* ((f1(w,z) - f1(xs,z)) == (U1(xs,z) - (U1(w,z) + f1(w,z)))) *)
	((c_f1 - c_f1) == (c_U1 - (c_U1 + c_f1))),                                                           (* ((f1(xs,z) - f1(xs,z)) == (U1(xs,z) - (U1(xs,z) + f1(xs,z)))) *)
	((b_f1 - b_f1) == (b_U1 - (b_U1 + b_f1))),                                                           (* ((f1(w,ys) - f1(w,ys)) == (U1(w,ys) - (U1(w,ys) + f1(w,ys)))) *)
	((d_f1 - b_f1) == (b_U1 - (d_U1 + d_f1))),                                                           (* ((f1(xs,ys) - f1(w,ys)) == (U1(w,ys) - (U1(xs,ys) + f1(xs,ys)))) *)
	((b_f1 - d_f1) == (d_U1 - (b_U1 + b_f1))),                                                           (* ((f1(w,ys) - f1(xs,ys)) == (U1(xs,ys) - (U1(w,ys) + f1(w,ys)))) *)
	((d_f1 - d_f1) == (d_U1 - (d_U1 + d_f1))),                                                           (* ((f1(xs,ys) - f1(xs,ys)) == (U1(xs,ys) - (U1(xs,ys) + f1(xs,ys)))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),                                                                    (* ((f2(w,z) - f2(w,z)) == (U2(w,z) - U2(w,z))) *)
	((c_f2 - c_f2) == (c_U2 - c_U2)),                                                                    (* ((f2(xs,z) - f2(xs,z)) == (U2(xs,z) - U2(xs,z))) *)
	((b_f2 - a_f2) == (a_U2 - b_U2)),                                                                    (* ((f2(w,ys) - f2(w,z)) == (U2(w,z) - U2(w,ys))) *)
	((d_f2 - c_f2) == (c_U2 - d_U2)),                                                                    (* ((f2(xs,ys) - f2(xs,z)) == (U2(xs,z) - U2(xs,ys))) *)
	((a_f2 - b_f2) == (b_U2 - a_U2)),                                                                    (* ((f2(w,z) - f2(w,ys)) == (U2(w,ys) - U2(w,z))) *)
	((c_f2 - d_f2) == (d_U2 - c_U2)),                                                                    (* ((f2(xs,z) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,z))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),                                                                    (* ((f2(w,ys) - f2(w,ys)) == (U2(w,ys) - U2(w,ys))) *)
	((d_f2 - d_f2) == (d_U2 - d_U2)),                                                                    (* ((f2(xs,ys) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,ys))) *)
	((a_f2 - a_f2) == (a_U2 - (a_U2 + a_f2))),                                                           (* ((f2(w,z) - f2(w,z)) == (U2(w,z) - (U2(w,z) + f2(w,z)))) *)
	((b_f2 - a_f2) == (a_U2 - (b_U2 + b_f2))),                                                           (* ((f2(w,ys) - f2(w,z)) == (U2(w,z) - (U2(w,ys) + f2(w,ys)))) *)
	((a_f2 - b_f2) == (b_U2 - (a_U2 + a_f2))),                                                           (* ((f2(w,z) - f2(w,ys)) == (U2(w,ys) - (U2(w,z) + f2(w,z)))) *)
	((b_f2 - b_f2) == (b_U2 - (b_U2 + b_f2))),                                                           (* ((f2(w,ys) - f2(w,ys)) == (U2(w,ys) - (U2(w,ys) + f2(w,ys)))) *)
	((c_f2 - c_f2) == (c_U2 - (c_U2 + c_f2))),                                                           (* ((f2(xs,z) - f2(xs,z)) == (U2(xs,z) - (U2(xs,z) + f2(xs,z)))) *)
	((d_f2 - c_f2) == (c_U2 - (d_U2 + d_f2))),                                                           (* ((f2(xs,ys) - f2(xs,z)) == (U2(xs,z) - (U2(xs,ys) + f2(xs,ys)))) *)
	((c_f2 - d_f2) == (d_U2 - (c_U2 + c_f2))),                                                           (* ((f2(xs,z) - f2(xs,ys)) == (U2(xs,ys) - (U2(xs,z) + f2(xs,z)))) *)
	((d_f2 - d_f2) == (d_U2 - (d_U2 + d_f2))),                                                           (* ((f2(xs,ys) - f2(xs,ys)) == (U2(xs,ys) - (U2(xs,ys) + f2(xs,ys)))) *)
	((a_f2 - a_f2) == ((a_U2 + a_f2) - a_U2)),                                                           (* ((f2(w,z) - f2(w,z)) == ((U2(w,z) + f2(w,z)) - U2(w,z))) *)
	((a_f2 - b_f2) == ((b_U2 + b_f2) - a_U2)),                                                           (* ((f2(w,z) - f2(w,ys)) == ((U2(w,ys) + f2(w,ys)) - U2(w,z))) *)
	((c_f2 - c_f2) == ((c_U2 + c_f2) - c_U2)),                                                           (* ((f2(xs,z) - f2(xs,z)) == ((U2(xs,z) + f2(xs,z)) - U2(xs,z))) *)
	((c_f2 - d_f2) == ((d_U2 + d_f2) - c_U2)),                                                           (* ((f2(xs,z) - f2(xs,ys)) == ((U2(xs,ys) + f2(xs,ys)) - U2(xs,z))) *)
	((b_f2 - a_f2) == ((a_U2 + a_f2) - b_U2)),                                                           (* ((f2(w,ys) - f2(w,z)) == ((U2(w,z) + f2(w,z)) - U2(w,ys))) *)
	((b_f2 - b_f2) == ((b_U2 + b_f2) - b_U2)),                                                           (* ((f2(w,ys) - f2(w,ys)) == ((U2(w,ys) + f2(w,ys)) - U2(w,ys))) *)
	((d_f2 - c_f2) == ((c_U2 + c_f2) - d_U2)),                                                           (* ((f2(xs,ys) - f2(xs,z)) == ((U2(xs,z) + f2(xs,z)) - U2(xs,ys))) *)
	((d_f2 - d_f2) == ((d_U2 + d_f2) - d_U2)),                                                           (* ((f2(xs,ys) - f2(xs,ys)) == ((U2(xs,ys) + f2(xs,ys)) - U2(xs,ys))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),                                                                    (* ((f2(w,z) - f2(w,z)) == (U2(w,z) - U2(w,z))) *)
	((c_f2 - c_f2) == (c_U2 - c_U2)),                                                                    (* ((f2(xs,z) - f2(xs,z)) == (U2(xs,z) - U2(xs,z))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),                                                                    (* ((f2(w,ys) - f2(w,ys)) == (U2(w,ys) - U2(w,ys))) *)
	((d_f2 - d_f2) == (d_U2 - d_U2)),                                                                    (* ((f2(xs,ys) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,ys))) *)
	(0 <= rho),                                                                                          (* (0 <= rho) *)
	(rho <= 1),                                                                                          (* (rho <= 1) *)
	(d_f1 == d_f2),                                                                                      (* (f1(xs,ys) == f2(xs,ys)) *)
	(b_U1 <= b_U1),                                                                                      (* (U1(w,ys) <= U1(w,ys)) *)
	(d_U1 <= b_U1),                                                                                      (* (U1(xs,ys) <= U1(w,ys)) *)
	((b_U1 + b_f1) <= b_U1),                                                                             (* ((U1(w,ys) + f1(w,ys)) <= U1(w,ys)) *)
	((d_U1 + d_f1) <= b_U1),                                                                             (* ((U1(xs,ys) + f1(xs,ys)) <= U1(w,ys)) *)
	(c_U2 <= c_U2),                                                                                      (* (U2(xs,z) <= U2(xs,z)) *)
	(d_U2 <= c_U2),                                                                                      (* (U2(xs,ys) <= U2(xs,z)) *)
	((c_U2 + c_f2) <= c_U2),                                                                             (* ((U2(xs,z) + f2(xs,z)) <= U2(xs,z)) *)
	((d_U2 + d_f2) <= c_U2),                                                                             (* ((U2(xs,ys) + f2(xs,ys)) <= U2(xs,z)) *)
	(a_f1 <= ((rho * (((a_U1 - b_U1) - c_U1) + d_U1)) + ((1 - rho) * (((a_U2 - c_U2) - b_U2) + d_U2)))),  (* (f1(w,z) <= ((rho * (((U1(w,z) - U1(w,ys)) - U1(xs,z)) + U1(xs,ys))) + ((1 - rho) * (((U2(w,z) - U2(xs,z)) - U2(w,ys)) + U2(xs,ys))))) *)
	(c_f1 <= ((rho * (((a_U1 - d_U1) - c_U1) + d_U1)) + ((1 - rho) * (((c_U2 - c_U2) - d_U2) + d_U2)))),  (* (f1(xs,z) <= ((rho * (((U1(w,z) - U1(xs,ys)) - U1(xs,z)) + U1(xs,ys))) + ((1 - rho) * (((U2(xs,z) - U2(xs,z)) - U2(xs,ys)) + U2(xs,ys))))) *)
	(b_f1 <= ((rho * (((b_U1 - b_U1) - d_U1) + d_U1)) + ((1 - rho) * (((a_U2 - d_U2) - b_U2) + d_U2)))),  (* (f1(w,ys) <= ((rho * (((U1(w,ys) - U1(w,ys)) - U1(xs,ys)) + U1(xs,ys))) + ((1 - rho) * (((U2(w,z) - U2(xs,ys)) - U2(w,ys)) + U2(xs,ys))))) *)
	(d_f1 <= ((rho * (((b_U1 - d_U1) - d_U1) + d_U1)) + ((1 - rho) * (((c_U2 - d_U2) - d_U2) + d_U2)))),  (* (f1(xs,ys) <= ((rho * (((U1(w,ys) - U1(xs,ys)) - U1(xs,ys)) + U1(xs,ys))) + ((1 - rho) * (((U2(xs,z) - U2(xs,ys)) - U2(xs,ys)) + U2(xs,ys))))) *)
	(a_U1 >= 0),                                                                                         (* (U1(w,z) >= 0) *)
	(a_U1 <= 1),                                                                                         (* (U1(w,z) <= 1) *)
	(a_f1 >= 0),                                                                                         (* (f1(w,z) >= 0) *)
	(a_f1 <= 1),                                                                                         (* (f1(w,z) <= 1) *)
	((a_U1 + a_f1) <= 1),                                                                                (* ((U1(w,z) + f1(w,z)) <= 1) *)
	(a_U2 >= 0),                                                                                         (* (U2(w,z) >= 0) *)
	(a_U2 <= 1),                                                                                         (* (U2(w,z) <= 1) *)
	(a_f2 >= 0),                                                                                         (* (f2(w,z) >= 0) *)
	(a_f2 <= 1),                                                                                         (* (f2(w,z) <= 1) *)
	((a_U2 + a_f2) <= 1),                                                                                (* ((U2(w,z) + f2(w,z)) <= 1) *)
	(b_U1 >= 0),                                                                                         (* (U1(w,ys) >= 0) *)
	(b_U1 <= 1),                                                                                         (* (U1(w,ys) <= 1) *)
	(b_f1 >= 0),                                                                                         (* (f1(w,ys) >= 0) *)
	(b_f1 <= 1),                                                                                         (* (f1(w,ys) <= 1) *)
	((b_U1 + b_f1) <= 1),                                                                                (* ((U1(w,ys) + f1(w,ys)) <= 1) *)
	(b_U2 >= 0),                                                                                         (* (U2(w,ys) >= 0) *)
	(b_U2 <= 1),                                                                                         (* (U2(w,ys) <= 1) *)
	(b_f2 >= 0),                                                                                         (* (f2(w,ys) >= 0) *)
	(b_f2 <= 1),                                                                                         (* (f2(w,ys) <= 1) *)
	((b_U2 + b_f2) <= 1),                                                                                (* ((U2(w,ys) + f2(w,ys)) <= 1) *)
	(c_U1 >= 0),                                                                                         (* (U1(xs,z) >= 0) *)
	(c_U1 <= 1),                                                                                         (* (U1(xs,z) <= 1) *)
	(c_f1 >= 0),                                                                                         (* (f1(xs,z) >= 0) *)
	(c_f1 <= 1),                                                                                         (* (f1(xs,z) <= 1) *)
	((c_U1 + c_f1) <= 1),                                                                                (* ((U1(xs,z) + f1(xs,z)) <= 1) *)
	(c_U2 >= 0),                                                                                         (* (U2(xs,z) >= 0) *)
	(c_U2 <= 1),                                                                                         (* (U2(xs,z) <= 1) *)
	(c_f2 >= 0),                                                                                         (* (f2(xs,z) >= 0) *)
	(c_f2 <= 1),                                                                                         (* (f2(xs,z) <= 1) *)
	((c_U2 + c_f2) <= 1),                                                                                (* ((U2(xs,z) + f2(xs,z)) <= 1) *)
	(d_U1 >= 0),                                                                                         (* (U1(xs,ys) >= 0) *)
	(d_U1 <= 1),                                                                                         (* (U1(xs,ys) <= 1) *)
	(d_f1 >= 0),                                                                                         (* (f1(xs,ys) >= 0) *)
	(d_f1 <= 1),                                                                                         (* (f1(xs,ys) <= 1) *)
	((d_U1 + d_f1) <= 1),                                                                                (* ((U1(xs,ys) + f1(xs,ys)) <= 1) *)
	(d_U2 >= 0),                                                                                         (* (U2(xs,ys) >= 0) *)
	(d_U2 <= 1),                                                                                         (* (U2(xs,ys) <= 1) *)
	(d_f2 >= 0),                                                                                         (* (f2(xs,ys) >= 0) *)
	(d_f2 <= 1),                                                                                         (* (f2(xs,ys) <= 1) *)
	((d_U2 + d_f2) <= 1)                                                                                 (* ((U2(xs,ys) + f2(xs,ys)) <= 1) *)
};

(* solve the approximation bound *)
NMaximize[{Min[bound1, bound2, bound3, bound4], constraints}, {d_U1, d_f1, d_U2, d_f2, c_U1, c_f1, c_U2, c_f2, b_U1, b_f1, b_U2, b_f2, a_U1, a_f1, a_U2, a_f2, rho}, AccuracyGoal -> 40, WorkingPrecision -> 60, Method -> "DifferentialEvolution", MaxIterations -> 1000]