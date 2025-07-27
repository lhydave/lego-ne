startTime = AbsoluteTime[];(* Mathematica code generated from ../experiments/legone-code/dfm-3333.legone *)

(* name alias and parameters *)
i_U1;	 (* U1(xs,ys) *)
i_f1;	 (* f1(xs,ys) *)
i_U2;	 (* U2(xs,ys) *)
i_f2;	 (* f2(xs,ys) *)
h_U1;	 (* U1(xs,z) *)
h_f1;	 (* f1(xs,z) *)
h_U2;	 (* U2(xs,z) *)
h_f2;	 (* f2(xs,z) *)
g_U1;	 (* U1(xs,y_hat) *)
g_f1;	 (* f1(xs,y_hat) *)
g_U2;	 (* U2(xs,y_hat) *)
g_f2;	 (* f2(xs,y_hat) *)
d_U1;	 (* U1(w,y_hat) *)
d_f1;	 (* f1(w,y_hat) *)
d_U2;	 (* U2(w,y_hat) *)
d_f2;	 (* f2(w,y_hat) *)
b_U1;	 (* U1(w_hat,z) *)
b_f1;	 (* f1(w_hat,z) *)
b_U2;	 (* U2(w_hat,z) *)
b_f2;	 (* f2(w_hat,z) *)
e_U1;	 (* U1(w,z) *)
e_f1;	 (* f1(w,z) *)
e_U2;	 (* U2(w,z) *)
e_f2;	 (* f2(w,z) *)
c_U1;	 (* U1(w_hat,ys) *)
c_f1;	 (* f1(w_hat,ys) *)
c_U2;	 (* U2(w_hat,ys) *)
c_f2;	 (* f2(w_hat,ys) *)
f_U1;	 (* U1(w,ys) *)
f_f1;	 (* f1(w,ys) *)
f_U2;	 (* U2(w,ys) *)
f_f2;	 (* f2(w,ys) *)
a_U1;	 (* U1(w_hat,y_hat) *)
a_f1;	 (* f1(w_hat,y_hat) *)
a_U2;	 (* U2(w_hat,y_hat) *)
a_f2;	 (* f2(w_hat,y_hat) *)
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



bound1  = optMix[a_f1, d_f1, a_f2, d_f2];  (* line (w_hat,y_hat) -- (w,y_hat) *)
bound2  = optMix[a_f1, g_f1, a_f2, g_f2];  (* line (w_hat,y_hat) -- (xs,y_hat) *)
bound3  = optMix[d_f1, g_f1, d_f2, g_f2];  (* line (w,y_hat) -- (xs,y_hat) *)
bound4  = optMix[b_f1, e_f1, b_f2, e_f2];  (* line (w_hat,z) -- (w,z) *)
bound5  = optMix[b_f1, h_f1, b_f2, h_f2];  (* line (w_hat,z) -- (xs,z) *)
bound6  = optMix[e_f1, h_f1, e_f2, h_f2];  (* line (w,z) -- (xs,z) *)
bound7  = optMix[c_f1, f_f1, c_f2, f_f2];  (* line (w_hat,ys) -- (w,ys) *)
bound8  = optMix[c_f1, i_f1, c_f2, i_f2];  (* line (w_hat,ys) -- (xs,ys) *)
bound9  = optMix[f_f1, i_f1, f_f2, i_f2];  (* line (w,ys) -- (xs,ys) *)
bound10 = optMix[a_f1, b_f1, a_f2, b_f2];  (* line (w_hat,y_hat) -- (w_hat,z) *)
bound11 = optMix[a_f1, c_f1, a_f2, c_f2];  (* line (w_hat,y_hat) -- (w_hat,ys) *)
bound12 = optMix[b_f1, c_f1, b_f2, c_f2];  (* line (w_hat,z) -- (w_hat,ys) *)
bound13 = optMix[d_f1, e_f1, d_f2, e_f2];  (* line (w,y_hat) -- (w,z) *)
bound14 = optMix[d_f1, f_f1, d_f2, f_f2];  (* line (w,y_hat) -- (w,ys) *)
bound15 = optMix[e_f1, f_f1, e_f2, f_f2];  (* line (w,z) -- (w,ys) *)
bound16 = optMix[g_f1, h_f1, g_f2, h_f2];  (* line (xs,y_hat) -- (xs,z) *)
bound17 = optMix[g_f1, i_f1, g_f2, i_f2];  (* line (xs,y_hat) -- (xs,ys) *)
bound18 = optMix[h_f1, i_f1, h_f2, i_f2];  (* line (xs,z) -- (xs,ys) *)
bound   = Min[bound1, bound2, bound3, bound4, bound5, bound6, bound7, bound8, bound9, bound10, bound11, bound12, bound13, bound14, bound15, bound16, bound17, bound18];  (* final bound *)

(* constraints *)
constraints = {
	(* (f1(w,z) >= f2(w,z)) *)
	(e_f1 >= e_f2),
	(* (0.000000 <= rho) *)
	(0.000000 <= rho),
	(* (rho <= 1.000000) *)
	(rho <= 1.000000),
	(* (f1(xs,ys) == f2(xs,ys)) *)
	(i_f1 == i_f2),
	(* (U1(w_hat,ys) <= U1(w,ys)) *)
	(c_U1 <= f_U1),
	(* (U1(w,ys) <= U1(w,ys)) *)
	(f_U1 <= f_U1),
	(* (U1(xs,ys) <= U1(w,ys)) *)
	(i_U1 <= f_U1),
	(* ((U1(w_hat,ys) + f1(w_hat,ys)) <= U1(w,ys)) *)
	((c_U1 + c_f1) <= f_U1),
	(* ((U1(w,ys) + f1(w,ys)) <= U1(w,ys)) *)
	((f_U1 + f_f1) <= f_U1),
	(* ((U1(xs,ys) + f1(xs,ys)) <= U1(w,ys)) *)
	((i_U1 + i_f1) <= f_U1),
	(* (U2(xs,y_hat) <= U2(xs,z)) *)
	(g_U2 <= h_U2),
	(* (U2(xs,z) <= U2(xs,z)) *)
	(h_U2 <= h_U2),
	(* (U2(xs,ys) <= U2(xs,z)) *)
	(i_U2 <= h_U2),
	(* ((U2(xs,y_hat) + f2(xs,y_hat)) <= U2(xs,z)) *)
	((g_U2 + g_f2) <= h_U2),
	(* ((U2(xs,z) + f2(xs,z)) <= U2(xs,z)) *)
	((h_U2 + h_f2) <= h_U2),
	(* ((U2(xs,ys) + f2(xs,ys)) <= U2(xs,z)) *)
	((i_U2 + i_f2) <= h_U2),
	(* (f1(xs,ys) <= ((rho * (((U1(w,y_hat) - U1(w_hat,ys)) - U1(xs,y_hat)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w_hat,z) - U2(xs,y_hat)) - U2(w_hat,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((d_U1 - c_U1) - g_U1) + i_U1)) + ((1.000000 - rho) * (((b_U2 - g_U2) - c_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,y_hat) - U1(w,ys)) - U1(xs,y_hat)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w,z) - U2(xs,y_hat)) - U2(w,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((d_U1 - f_U1) - g_U1) + i_U1)) + ((1.000000 - rho) * (((e_U2 - g_U2) - f_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,y_hat) - U1(xs,ys)) - U1(xs,y_hat)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(xs,z) - U2(xs,y_hat)) - U2(xs,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((d_U1 - i_U1) - g_U1) + i_U1)) + ((1.000000 - rho) * (((h_U2 - g_U2) - i_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,z) - U1(w_hat,ys)) - U1(xs,z)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w_hat,z) - U2(xs,z)) - U2(w_hat,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((e_U1 - c_U1) - h_U1) + i_U1)) + ((1.000000 - rho) * (((b_U2 - h_U2) - c_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,z) - U1(w,ys)) - U1(xs,z)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w,z) - U2(xs,z)) - U2(w,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((e_U1 - f_U1) - h_U1) + i_U1)) + ((1.000000 - rho) * (((e_U2 - h_U2) - f_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,z) - U1(xs,ys)) - U1(xs,z)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(xs,z) - U2(xs,z)) - U2(xs,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((e_U1 - i_U1) - h_U1) + i_U1)) + ((1.000000 - rho) * (((h_U2 - h_U2) - i_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,ys) - U1(w_hat,ys)) - U1(xs,ys)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w_hat,z) - U2(xs,ys)) - U2(w_hat,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((f_U1 - c_U1) - i_U1) + i_U1)) + ((1.000000 - rho) * (((b_U2 - i_U2) - c_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,ys) - U1(w,ys)) - U1(xs,ys)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(w,z) - U2(xs,ys)) - U2(w,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((f_U1 - f_U1) - i_U1) + i_U1)) + ((1.000000 - rho) * (((e_U2 - i_U2) - f_U2) + i_U2)))),
	(* (f1(xs,ys) <= ((rho * (((U1(w,ys) - U1(xs,ys)) - U1(xs,ys)) + U1(xs,ys))) + ((1.000000 - rho) * (((U2(xs,z) - U2(xs,ys)) - U2(xs,ys)) + U2(xs,ys))))) *)
	(i_f1 <= ((rho * (((f_U1 - i_U1) - i_U1) + i_U1)) + ((1.000000 - rho) * (((h_U2 - i_U2) - i_U2) + i_U2)))),
	(* ((U2(w_hat,ys) + U2(w_hat,z)) == (2.000000 * U2(w_hat,y_hat))) *)
	((c_U2 + b_U2) == (2.000000 * a_U2)),
	(* ((U1(w_hat,ys) + U1(w_hat,z)) == (2.000000 * U1(w_hat,y_hat))) *)
	((c_U1 + b_U1) == (2.000000 * a_U1)),
	(* ((U2(w,ys) + U2(w,z)) == (2.000000 * U2(w,y_hat))) *)
	((f_U2 + e_U2) == (2.000000 * d_U2)),
	(* ((U1(w,ys) + U1(w,z)) == (2.000000 * U1(w,y_hat))) *)
	((f_U1 + e_U1) == (2.000000 * d_U1)),
	(* ((U2(xs,ys) + U2(xs,z)) == (2.000000 * U2(xs,y_hat))) *)
	((i_U2 + h_U2) == (2.000000 * g_U2)),
	(* ((U1(xs,ys) + U1(xs,z)) == (2.000000 * U1(xs,y_hat))) *)
	((i_U1 + h_U1) == (2.000000 * g_U1)),
	(* ((f1(w_hat,ys) + f1(w_hat,z)) >= (2.000000 * f1(w_hat,y_hat))) *)
	((c_f1 + b_f1) >= (2.000000 * a_f1)),
	(* ((f1(w,ys) + f1(w,z)) >= (2.000000 * f1(w,y_hat))) *)
	((f_f1 + e_f1) >= (2.000000 * d_f1)),
	(* ((f1(xs,ys) + f1(xs,z)) >= (2.000000 * f1(xs,y_hat))) *)
	((i_f1 + h_f1) >= (2.000000 * g_f1)),
	(* (U1(w_hat,y_hat) <= U1(w_hat,y_hat)) *)
	(a_U1 <= a_U1),
	(* (U1(w,y_hat) <= U1(w_hat,y_hat)) *)
	(d_U1 <= a_U1),
	(* (U1(xs,y_hat) <= U1(w_hat,y_hat)) *)
	(g_U1 <= a_U1),
	(* ((U1(w_hat,y_hat) + f1(w_hat,y_hat)) <= U1(w_hat,y_hat)) *)
	((a_U1 + a_f1) <= a_U1),
	(* ((U1(w,y_hat) + f1(w,y_hat)) <= U1(w_hat,y_hat)) *)
	((d_U1 + d_f1) <= a_U1),
	(* ((U1(xs,y_hat) + f1(xs,y_hat)) <= U1(w_hat,y_hat)) *)
	((g_U1 + g_f1) <= a_U1),
	(* ((f1(w_hat,y_hat) - f1(w_hat,y_hat)) == (U1(w_hat,y_hat) - U1(w_hat,y_hat))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),
	(* ((f1(w,y_hat) - f1(w_hat,y_hat)) == (U1(w_hat,y_hat) - U1(w,y_hat))) *)
	((d_f1 - a_f1) == (a_U1 - d_U1)),
	(* ((f1(xs,y_hat) - f1(w_hat,y_hat)) == (U1(w_hat,y_hat) - U1(xs,y_hat))) *)
	((g_f1 - a_f1) == (a_U1 - g_U1)),
	(* ((f1(w_hat,y_hat) - f1(w,y_hat)) == (U1(w,y_hat) - U1(w_hat,y_hat))) *)
	((a_f1 - d_f1) == (d_U1 - a_U1)),
	(* ((f1(w,y_hat) - f1(w,y_hat)) == (U1(w,y_hat) - U1(w,y_hat))) *)
	((d_f1 - d_f1) == (d_U1 - d_U1)),
	(* ((f1(xs,y_hat) - f1(w,y_hat)) == (U1(w,y_hat) - U1(xs,y_hat))) *)
	((g_f1 - d_f1) == (d_U1 - g_U1)),
	(* ((f1(w_hat,y_hat) - f1(xs,y_hat)) == (U1(xs,y_hat) - U1(w_hat,y_hat))) *)
	((a_f1 - g_f1) == (g_U1 - a_U1)),
	(* ((f1(w,y_hat) - f1(xs,y_hat)) == (U1(xs,y_hat) - U1(w,y_hat))) *)
	((d_f1 - g_f1) == (g_U1 - d_U1)),
	(* ((f1(xs,y_hat) - f1(xs,y_hat)) == (U1(xs,y_hat) - U1(xs,y_hat))) *)
	((g_f1 - g_f1) == (g_U1 - g_U1)),
	(* ((f1(w_hat,z) - f1(w_hat,z)) == (U1(w_hat,z) - U1(w_hat,z))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),
	(* ((f1(w,z) - f1(w_hat,z)) == (U1(w_hat,z) - U1(w,z))) *)
	((e_f1 - b_f1) == (b_U1 - e_U1)),
	(* ((f1(xs,z) - f1(w_hat,z)) == (U1(w_hat,z) - U1(xs,z))) *)
	((h_f1 - b_f1) == (b_U1 - h_U1)),
	(* ((f1(w_hat,z) - f1(w,z)) == (U1(w,z) - U1(w_hat,z))) *)
	((b_f1 - e_f1) == (e_U1 - b_U1)),
	(* ((f1(w,z) - f1(w,z)) == (U1(w,z) - U1(w,z))) *)
	((e_f1 - e_f1) == (e_U1 - e_U1)),
	(* ((f1(xs,z) - f1(w,z)) == (U1(w,z) - U1(xs,z))) *)
	((h_f1 - e_f1) == (e_U1 - h_U1)),
	(* ((f1(w_hat,z) - f1(xs,z)) == (U1(xs,z) - U1(w_hat,z))) *)
	((b_f1 - h_f1) == (h_U1 - b_U1)),
	(* ((f1(w,z) - f1(xs,z)) == (U1(xs,z) - U1(w,z))) *)
	((e_f1 - h_f1) == (h_U1 - e_U1)),
	(* ((f1(xs,z) - f1(xs,z)) == (U1(xs,z) - U1(xs,z))) *)
	((h_f1 - h_f1) == (h_U1 - h_U1)),
	(* ((f1(w_hat,ys) - f1(w_hat,ys)) == (U1(w_hat,ys) - U1(w_hat,ys))) *)
	((c_f1 - c_f1) == (c_U1 - c_U1)),
	(* ((f1(w,ys) - f1(w_hat,ys)) == (U1(w_hat,ys) - U1(w,ys))) *)
	((f_f1 - c_f1) == (c_U1 - f_U1)),
	(* ((f1(xs,ys) - f1(w_hat,ys)) == (U1(w_hat,ys) - U1(xs,ys))) *)
	((i_f1 - c_f1) == (c_U1 - i_U1)),
	(* ((f1(w_hat,ys) - f1(w,ys)) == (U1(w,ys) - U1(w_hat,ys))) *)
	((c_f1 - f_f1) == (f_U1 - c_U1)),
	(* ((f1(w,ys) - f1(w,ys)) == (U1(w,ys) - U1(w,ys))) *)
	((f_f1 - f_f1) == (f_U1 - f_U1)),
	(* ((f1(xs,ys) - f1(w,ys)) == (U1(w,ys) - U1(xs,ys))) *)
	((i_f1 - f_f1) == (f_U1 - i_U1)),
	(* ((f1(w_hat,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(w_hat,ys))) *)
	((c_f1 - i_f1) == (i_U1 - c_U1)),
	(* ((f1(w,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(w,ys))) *)
	((f_f1 - i_f1) == (i_U1 - f_U1)),
	(* ((f1(xs,ys) - f1(xs,ys)) == (U1(xs,ys) - U1(xs,ys))) *)
	((i_f1 - i_f1) == (i_U1 - i_U1)),
	(* ((f2(w_hat,y_hat) - f2(w_hat,y_hat)) == (U2(w_hat,y_hat) - U2(w_hat,y_hat))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),
	(* ((f2(w,y_hat) - f2(w,y_hat)) == (U2(w,y_hat) - U2(w,y_hat))) *)
	((d_f2 - d_f2) == (d_U2 - d_U2)),
	(* ((f2(xs,y_hat) - f2(xs,y_hat)) == (U2(xs,y_hat) - U2(xs,y_hat))) *)
	((g_f2 - g_f2) == (g_U2 - g_U2)),
	(* ((f2(w_hat,z) - f2(w_hat,y_hat)) == (U2(w_hat,y_hat) - U2(w_hat,z))) *)
	((b_f2 - a_f2) == (a_U2 - b_U2)),
	(* ((f2(w,z) - f2(w,y_hat)) == (U2(w,y_hat) - U2(w,z))) *)
	((e_f2 - d_f2) == (d_U2 - e_U2)),
	(* ((f2(xs,z) - f2(xs,y_hat)) == (U2(xs,y_hat) - U2(xs,z))) *)
	((h_f2 - g_f2) == (g_U2 - h_U2)),
	(* ((f2(w_hat,ys) - f2(w_hat,y_hat)) == (U2(w_hat,y_hat) - U2(w_hat,ys))) *)
	((c_f2 - a_f2) == (a_U2 - c_U2)),
	(* ((f2(w,ys) - f2(w,y_hat)) == (U2(w,y_hat) - U2(w,ys))) *)
	((f_f2 - d_f2) == (d_U2 - f_U2)),
	(* ((f2(xs,ys) - f2(xs,y_hat)) == (U2(xs,y_hat) - U2(xs,ys))) *)
	((i_f2 - g_f2) == (g_U2 - i_U2)),
	(* ((f2(w_hat,y_hat) - f2(w_hat,z)) == (U2(w_hat,z) - U2(w_hat,y_hat))) *)
	((a_f2 - b_f2) == (b_U2 - a_U2)),
	(* ((f2(w,y_hat) - f2(w,z)) == (U2(w,z) - U2(w,y_hat))) *)
	((d_f2 - e_f2) == (e_U2 - d_U2)),
	(* ((f2(xs,y_hat) - f2(xs,z)) == (U2(xs,z) - U2(xs,y_hat))) *)
	((g_f2 - h_f2) == (h_U2 - g_U2)),
	(* ((f2(w_hat,z) - f2(w_hat,z)) == (U2(w_hat,z) - U2(w_hat,z))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),
	(* ((f2(w,z) - f2(w,z)) == (U2(w,z) - U2(w,z))) *)
	((e_f2 - e_f2) == (e_U2 - e_U2)),
	(* ((f2(xs,z) - f2(xs,z)) == (U2(xs,z) - U2(xs,z))) *)
	((h_f2 - h_f2) == (h_U2 - h_U2)),
	(* ((f2(w_hat,ys) - f2(w_hat,z)) == (U2(w_hat,z) - U2(w_hat,ys))) *)
	((c_f2 - b_f2) == (b_U2 - c_U2)),
	(* ((f2(w,ys) - f2(w,z)) == (U2(w,z) - U2(w,ys))) *)
	((f_f2 - e_f2) == (e_U2 - f_U2)),
	(* ((f2(xs,ys) - f2(xs,z)) == (U2(xs,z) - U2(xs,ys))) *)
	((i_f2 - h_f2) == (h_U2 - i_U2)),
	(* ((f2(w_hat,y_hat) - f2(w_hat,ys)) == (U2(w_hat,ys) - U2(w_hat,y_hat))) *)
	((a_f2 - c_f2) == (c_U2 - a_U2)),
	(* ((f2(w,y_hat) - f2(w,ys)) == (U2(w,ys) - U2(w,y_hat))) *)
	((d_f2 - f_f2) == (f_U2 - d_U2)),
	(* ((f2(xs,y_hat) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,y_hat))) *)
	((g_f2 - i_f2) == (i_U2 - g_U2)),
	(* ((f2(w_hat,z) - f2(w_hat,ys)) == (U2(w_hat,ys) - U2(w_hat,z))) *)
	((b_f2 - c_f2) == (c_U2 - b_U2)),
	(* ((f2(w,z) - f2(w,ys)) == (U2(w,ys) - U2(w,z))) *)
	((e_f2 - f_f2) == (f_U2 - e_U2)),
	(* ((f2(xs,z) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,z))) *)
	((h_f2 - i_f2) == (i_U2 - h_U2)),
	(* ((f2(w_hat,ys) - f2(w_hat,ys)) == (U2(w_hat,ys) - U2(w_hat,ys))) *)
	((c_f2 - c_f2) == (c_U2 - c_U2)),
	(* ((f2(w,ys) - f2(w,ys)) == (U2(w,ys) - U2(w,ys))) *)
	((f_f2 - f_f2) == (f_U2 - f_U2)),
	(* ((f2(xs,ys) - f2(xs,ys)) == (U2(xs,ys) - U2(xs,ys))) *)
	((i_f2 - i_f2) == (i_U2 - i_U2)),
	(* ((f1(w_hat,y_hat) + U1(w_hat,y_hat)) <= 1.000000) *)
	((a_f1 + a_U1) <= 1.000000),
	(* ((f1(w,y_hat) + U1(w,y_hat)) <= 1.000000) *)
	((d_f1 + d_U1) <= 1.000000),
	(* ((f1(xs,y_hat) + U1(xs,y_hat)) <= 1.000000) *)
	((g_f1 + g_U1) <= 1.000000),
	(* ((f1(w_hat,z) + U1(w_hat,z)) <= 1.000000) *)
	((b_f1 + b_U1) <= 1.000000),
	(* ((f1(w,z) + U1(w,z)) <= 1.000000) *)
	((e_f1 + e_U1) <= 1.000000),
	(* ((f1(xs,z) + U1(xs,z)) <= 1.000000) *)
	((h_f1 + h_U1) <= 1.000000),
	(* ((f1(w_hat,ys) + U1(w_hat,ys)) <= 1.000000) *)
	((c_f1 + c_U1) <= 1.000000),
	(* ((f1(w,ys) + U1(w,ys)) <= 1.000000) *)
	((f_f1 + f_U1) <= 1.000000),
	(* ((f1(xs,ys) + U1(xs,ys)) <= 1.000000) *)
	((i_f1 + i_U1) <= 1.000000),
	(* ((f2(w_hat,y_hat) + U2(w_hat,y_hat)) <= 1.000000) *)
	((a_f2 + a_U2) <= 1.000000),
	(* ((f2(w,y_hat) + U2(w,y_hat)) <= 1.000000) *)
	((d_f2 + d_U2) <= 1.000000),
	(* ((f2(xs,y_hat) + U2(xs,y_hat)) <= 1.000000) *)
	((g_f2 + g_U2) <= 1.000000),
	(* ((f2(w_hat,z) + U2(w_hat,z)) <= 1.000000) *)
	((b_f2 + b_U2) <= 1.000000),
	(* ((f2(w,z) + U2(w,z)) <= 1.000000) *)
	((e_f2 + e_U2) <= 1.000000),
	(* ((f2(xs,z) + U2(xs,z)) <= 1.000000) *)
	((h_f2 + h_U2) <= 1.000000),
	(* ((f2(w_hat,ys) + U2(w_hat,ys)) <= 1.000000) *)
	((c_f2 + c_U2) <= 1.000000),
	(* ((f2(w,ys) + U2(w,ys)) <= 1.000000) *)
	((f_f2 + f_U2) <= 1.000000),
	(* ((f2(xs,ys) + U2(xs,ys)) <= 1.000000) *)
	((i_f2 + i_U2) <= 1.000000),
	(* (f1(w_hat,y_hat) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(w,y_hat) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(xs,y_hat) >= 0.000000) *)
	(g_f1 >= 0.000000),
	(* (f1(w_hat,z) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(w,z) >= 0.000000) *)
	(e_f1 >= 0.000000),
	(* (f1(xs,z) >= 0.000000) *)
	(h_f1 >= 0.000000),
	(* (f1(w_hat,ys) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(w,ys) >= 0.000000) *)
	(f_f1 >= 0.000000),
	(* (f1(xs,ys) >= 0.000000) *)
	(i_f1 >= 0.000000),
	(* (f1(w_hat,y_hat) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(w_hat,z) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(w_hat,ys) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(w,y_hat) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(w,z) >= 0.000000) *)
	(e_f1 >= 0.000000),
	(* (f1(w,ys) >= 0.000000) *)
	(f_f1 >= 0.000000),
	(* (f1(xs,y_hat) >= 0.000000) *)
	(g_f1 >= 0.000000),
	(* (f1(xs,z) >= 0.000000) *)
	(h_f1 >= 0.000000),
	(* (f1(xs,ys) >= 0.000000) *)
	(i_f1 >= 0.000000),
	(* (f1(w_hat,y_hat) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(w,y_hat) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(xs,y_hat) >= 0.000000) *)
	(g_f1 >= 0.000000),
	(* (f1(w_hat,z) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(w,z) >= 0.000000) *)
	(e_f1 >= 0.000000),
	(* (f1(xs,z) >= 0.000000) *)
	(h_f1 >= 0.000000),
	(* (f1(w_hat,ys) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(w,ys) >= 0.000000) *)
	(f_f1 >= 0.000000),
	(* (f1(xs,ys) >= 0.000000) *)
	(i_f1 >= 0.000000),
	(* (f2(w_hat,y_hat) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(w,y_hat) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(xs,y_hat) >= 0.000000) *)
	(g_f2 >= 0.000000),
	(* (f2(w_hat,z) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(w,z) >= 0.000000) *)
	(e_f2 >= 0.000000),
	(* (f2(xs,z) >= 0.000000) *)
	(h_f2 >= 0.000000),
	(* (f2(w_hat,ys) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(w,ys) >= 0.000000) *)
	(f_f2 >= 0.000000),
	(* (f2(xs,ys) >= 0.000000) *)
	(i_f2 >= 0.000000),
	(* (f2(w_hat,y_hat) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(w_hat,z) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(w_hat,ys) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(w,y_hat) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(w,z) >= 0.000000) *)
	(e_f2 >= 0.000000),
	(* (f2(w,ys) >= 0.000000) *)
	(f_f2 >= 0.000000),
	(* (f2(xs,y_hat) >= 0.000000) *)
	(g_f2 >= 0.000000),
	(* (f2(xs,z) >= 0.000000) *)
	(h_f2 >= 0.000000),
	(* (f2(xs,ys) >= 0.000000) *)
	(i_f2 >= 0.000000),
	(* (f2(w_hat,y_hat) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(w,y_hat) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(xs,y_hat) >= 0.000000) *)
	(g_f2 >= 0.000000),
	(* (f2(w_hat,z) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(w,z) >= 0.000000) *)
	(e_f2 >= 0.000000),
	(* (f2(xs,z) >= 0.000000) *)
	(h_f2 >= 0.000000),
	(* (f2(w_hat,ys) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(w,ys) >= 0.000000) *)
	(f_f2 >= 0.000000),
	(* (f2(xs,ys) >= 0.000000) *)
	(i_f2 >= 0.000000),
	(* (U2(w_hat,y_hat) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(w,y_hat) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* (U2(xs,y_hat) >= 0.000000) *)
	(g_U2 >= 0.000000),
	(* (U2(w_hat,z) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(w,z) >= 0.000000) *)
	(e_U2 >= 0.000000),
	(* (U2(xs,z) >= 0.000000) *)
	(h_U2 >= 0.000000),
	(* (U2(w_hat,ys) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(w,ys) >= 0.000000) *)
	(f_U2 >= 0.000000),
	(* (U2(xs,ys) >= 0.000000) *)
	(i_U2 >= 0.000000),
	(* (U1(w_hat,y_hat) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(w,y_hat) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* (U1(xs,y_hat) >= 0.000000) *)
	(g_U1 >= 0.000000),
	(* (U1(w_hat,z) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U1(w,z) >= 0.000000) *)
	(e_U1 >= 0.000000),
	(* (U1(xs,z) >= 0.000000) *)
	(h_U1 >= 0.000000),
	(* (U1(w_hat,ys) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(w,ys) >= 0.000000) *)
	(f_U1 >= 0.000000),
	(* (U1(xs,ys) >= 0.000000) *)
	(i_U1 >= 0.000000),
	(* ((U2(w_hat,y_hat) + f2(w_hat,y_hat)) >= 0.000000) *)
	((a_U2 + a_f2) >= 0.000000),
	(* ((U2(w_hat,z) + f2(w_hat,z)) >= 0.000000) *)
	((b_U2 + b_f2) >= 0.000000),
	(* ((U2(w_hat,ys) + f2(w_hat,ys)) >= 0.000000) *)
	((c_U2 + c_f2) >= 0.000000),
	(* (U1(w_hat,y_hat) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(w_hat,z) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U1(w_hat,ys) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* ((U2(w,y_hat) + f2(w,y_hat)) >= 0.000000) *)
	((d_U2 + d_f2) >= 0.000000),
	(* ((U2(w,z) + f2(w,z)) >= 0.000000) *)
	((e_U2 + e_f2) >= 0.000000),
	(* ((U2(w,ys) + f2(w,ys)) >= 0.000000) *)
	((f_U2 + f_f2) >= 0.000000),
	(* (U1(w,y_hat) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* (U1(w,z) >= 0.000000) *)
	(e_U1 >= 0.000000),
	(* (U1(w,ys) >= 0.000000) *)
	(f_U1 >= 0.000000),
	(* ((U2(xs,y_hat) + f2(xs,y_hat)) >= 0.000000) *)
	((g_U2 + g_f2) >= 0.000000),
	(* ((U2(xs,z) + f2(xs,z)) >= 0.000000) *)
	((h_U2 + h_f2) >= 0.000000),
	(* ((U2(xs,ys) + f2(xs,ys)) >= 0.000000) *)
	((i_U2 + i_f2) >= 0.000000),
	(* (U1(xs,y_hat) >= 0.000000) *)
	(g_U1 >= 0.000000),
	(* (U1(xs,z) >= 0.000000) *)
	(h_U1 >= 0.000000),
	(* (U1(xs,ys) >= 0.000000) *)
	(i_U1 >= 0.000000),
	(* (U2(w_hat,y_hat) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(w,y_hat) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* (U2(xs,y_hat) >= 0.000000) *)
	(g_U2 >= 0.000000),
	(* (U2(w_hat,z) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(w,z) >= 0.000000) *)
	(e_U2 >= 0.000000),
	(* (U2(xs,z) >= 0.000000) *)
	(h_U2 >= 0.000000),
	(* (U2(w_hat,ys) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(w,ys) >= 0.000000) *)
	(f_U2 >= 0.000000),
	(* (U2(xs,ys) >= 0.000000) *)
	(i_U2 >= 0.000000),
	(* ((U1(w_hat,y_hat) + f1(w_hat,y_hat)) >= 0.000000) *)
	((a_U1 + a_f1) >= 0.000000),
	(* ((U1(w,y_hat) + f1(w,y_hat)) >= 0.000000) *)
	((d_U1 + d_f1) >= 0.000000),
	(* ((U1(xs,y_hat) + f1(xs,y_hat)) >= 0.000000) *)
	((g_U1 + g_f1) >= 0.000000),
	(* ((U1(w_hat,z) + f1(w_hat,z)) >= 0.000000) *)
	((b_U1 + b_f1) >= 0.000000),
	(* ((U1(w,z) + f1(w,z)) >= 0.000000) *)
	((e_U1 + e_f1) >= 0.000000),
	(* ((U1(xs,z) + f1(xs,z)) >= 0.000000) *)
	((h_U1 + h_f1) >= 0.000000),
	(* ((U1(w_hat,ys) + f1(w_hat,ys)) >= 0.000000) *)
	((c_U1 + c_f1) >= 0.000000),
	(* ((U1(w,ys) + f1(w,ys)) >= 0.000000) *)
	((f_U1 + f_f1) >= 0.000000),
	(* ((U1(xs,ys) + f1(xs,ys)) >= 0.000000) *)
	((i_U1 + i_f1) >= 0.000000)
};

(* optimization for approximation bounds *)
result = NMaxValue[{bound, constraints}, {i_U1, i_f1, i_U2, i_f2, h_U1, h_f1, h_U2, h_f2, g_U1, g_f1, g_U2, g_f2, d_U1, d_f1, d_U2, d_f2, b_U1, b_f1, b_U2, b_f2, e_U1, e_f1, e_U2, e_f2, c_U1, c_f1, c_U2, c_f2, f_U1, f_f1, f_U2, f_f2, a_U1, a_f1, a_U2, a_f2, rho}, WorkingPrecision -> 6, AccuracyGoal -> 6, MaxIterations -> 2000];

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];
