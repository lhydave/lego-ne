startTime = AbsoluteTime[];(* Mathematica code generated from ../experiments/legone-code/cdffjs-38.legone *)

(* name alias and parameters *)
i_U1;	 (* U1(x_star,y_star) *)
i_f1;	 (* f1(x_star,y_star) *)
i_U2;	 (* U2(x_star,y_star) *)
i_f2;	 (* f2(x_star,y_star) *)
f_U1;	 (* U1(x_hat,y_star) *)
f_f1;	 (* f1(x_hat,y_star) *)
f_U2;	 (* U2(x_hat,y_star) *)
f_f2;	 (* f2(x_hat,y_star) *)
h_U1;	 (* U1(x_star,j) *)
h_f1;	 (* f1(x_star,j) *)
h_U2;	 (* U2(x_star,j) *)
h_f2;	 (* f2(x_star,j) *)
g_U1;	 (* U1(x_star,y_hat) *)
g_f1;	 (* f1(x_star,y_hat) *)
g_U2;	 (* U2(x_star,y_hat) *)
g_f2;	 (* f2(x_star,y_hat) *)
e_U1;	 (* U1(x_hat,j) *)
e_f1;	 (* f1(x_hat,j) *)
e_U2;	 (* U2(x_hat,j) *)
e_f2;	 (* f2(x_hat,j) *)
d_U1;	 (* U1(x_hat,y_hat) *)
d_f1;	 (* f1(x_hat,y_hat) *)
d_U2;	 (* U2(x_hat,y_hat) *)
d_f2;	 (* f2(x_hat,y_hat) *)
c_U1;	 (* U1(r,y_star) *)
c_f1;	 (* f1(r,y_star) *)
c_U2;	 (* U2(r,y_star) *)
c_f2;	 (* f2(r,y_star) *)
b_U1;	 (* U1(r,j) *)
b_f1;	 (* f1(r,j) *)
b_U2;	 (* U2(r,j) *)
b_f2;	 (* f2(r,j) *)
a_U1;	 (* U1(r,y_hat) *)
a_f1;	 (* f1(r,y_hat) *)
a_U2;	 (* U2(r,y_hat) *)
a_f2;	 (* f2(r,y_hat) *)

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



bound1  = optMix[a_f1, d_f1, a_f2, d_f2];  (* line (r,y_hat) -- (x_hat,y_hat) *)
bound2  = optMix[a_f1, g_f1, a_f2, g_f2];  (* line (r,y_hat) -- (x_star,y_hat) *)
bound3  = optMix[d_f1, g_f1, d_f2, g_f2];  (* line (x_hat,y_hat) -- (x_star,y_hat) *)
bound4  = optMix[b_f1, e_f1, b_f2, e_f2];  (* line (r,j) -- (x_hat,j) *)
bound5  = optMix[b_f1, h_f1, b_f2, h_f2];  (* line (r,j) -- (x_star,j) *)
bound6  = optMix[e_f1, h_f1, e_f2, h_f2];  (* line (x_hat,j) -- (x_star,j) *)
bound7  = optMix[c_f1, f_f1, c_f2, f_f2];  (* line (r,y_star) -- (x_hat,y_star) *)
bound8  = optMix[c_f1, i_f1, c_f2, i_f2];  (* line (r,y_star) -- (x_star,y_star) *)
bound9  = optMix[f_f1, i_f1, f_f2, i_f2];  (* line (x_hat,y_star) -- (x_star,y_star) *)
bound10 = optMix[a_f1, b_f1, a_f2, b_f2];  (* line (r,y_hat) -- (r,j) *)
bound11 = optMix[a_f1, c_f1, a_f2, c_f2];  (* line (r,y_hat) -- (r,y_star) *)
bound12 = optMix[b_f1, c_f1, b_f2, c_f2];  (* line (r,j) -- (r,y_star) *)
bound13 = optMix[d_f1, e_f1, d_f2, e_f2];  (* line (x_hat,y_hat) -- (x_hat,j) *)
bound14 = optMix[d_f1, f_f1, d_f2, f_f2];  (* line (x_hat,y_hat) -- (x_hat,y_star) *)
bound15 = optMix[e_f1, f_f1, e_f2, f_f2];  (* line (x_hat,j) -- (x_hat,y_star) *)
bound16 = optMix[g_f1, h_f1, g_f2, h_f2];  (* line (x_star,y_hat) -- (x_star,j) *)
bound17 = optMix[g_f1, i_f1, g_f2, i_f2];  (* line (x_star,y_hat) -- (x_star,y_star) *)
bound18 = optMix[h_f1, i_f1, h_f2, i_f2];  (* line (x_star,j) -- (x_star,y_star) *)
bound   = Min[bound1, bound2, bound3, bound4, bound5, bound6, bound7, bound8, bound9, bound10, bound11, bound12, bound13, bound14, bound15, bound16, bound17, bound18];  (* final bound *)

(* constraints *)
constraints = {
	(* (U1(x_star,y_star) >= U2(x_hat,y_hat)) *)
	(i_U1 >= d_U2),
	(* (U1(r,y_star) <= U1(x_star,y_star)) *)
	(c_U1 <= i_U1),
	(* (U1(x_hat,y_star) <= U1(x_star,y_star)) *)
	(f_U1 <= i_U1),
	(* (U1(x_star,y_star) <= U1(x_star,y_star)) *)
	(i_U1 <= i_U1),
	(* ((U1(r,y_star) + f1(r,y_star)) <= U1(x_star,y_star)) *)
	((c_U1 + c_f1) <= i_U1),
	(* ((U1(x_hat,y_star) + f1(x_hat,y_star)) <= U1(x_star,y_star)) *)
	((f_U1 + f_f1) <= i_U1),
	(* ((U1(x_star,y_star) + f1(x_star,y_star)) <= U1(x_star,y_star)) *)
	((i_U1 + i_f1) <= i_U1),
	(* (U1(x_star,y_hat) >= U1(x_star,y_star)) *)
	(g_U1 >= i_U1),
	(* (U1(x_star,j) >= U1(x_star,y_star)) *)
	(h_U1 >= i_U1),
	(* (U1(x_star,y_star) >= U1(x_star,y_star)) *)
	(i_U1 >= i_U1),
	(* (U1(x_star,y_hat) >= U1(x_star,y_star)) *)
	(g_U1 >= i_U1),
	(* (U1(x_star,j) >= U1(x_star,y_star)) *)
	(h_U1 >= i_U1),
	(* (U1(x_star,y_star) >= U1(x_star,y_star)) *)
	(i_U1 >= i_U1),
	(* (U2(r,y_hat) >= U2(x_hat,y_hat)) *)
	(a_U2 >= d_U2),
	(* (U2(x_hat,y_hat) >= U2(x_hat,y_hat)) *)
	(d_U2 >= d_U2),
	(* (U2(x_star,y_hat) >= U2(x_hat,y_hat)) *)
	(g_U2 >= d_U2),
	(* (U2(r,y_hat) >= U2(x_hat,y_hat)) *)
	(a_U2 >= d_U2),
	(* (U2(x_hat,y_hat) >= U2(x_hat,y_hat)) *)
	(d_U2 >= d_U2),
	(* (U2(x_star,y_hat) >= U2(x_hat,y_hat)) *)
	(g_U2 >= d_U2),
	(* (U2(x_hat,y_hat) <= U2(x_hat,y_hat)) *)
	(d_U2 <= d_U2),
	(* (U2(x_hat,j) <= U2(x_hat,y_hat)) *)
	(e_U2 <= d_U2),
	(* (U2(x_hat,y_star) <= U2(x_hat,y_hat)) *)
	(f_U2 <= d_U2),
	(* ((U2(x_hat,y_hat) + f2(x_hat,y_hat)) <= U2(x_hat,y_hat)) *)
	((d_U2 + d_f2) <= d_U2),
	(* ((U2(x_hat,j) + f2(x_hat,j)) <= U2(x_hat,y_hat)) *)
	((e_U2 + e_f2) <= d_U2),
	(* ((U2(x_hat,y_star) + f2(x_hat,y_star)) <= U2(x_hat,y_hat)) *)
	((f_U2 + f_f2) <= d_U2),
	(* (U2(x_star,y_hat) <= U2(x_star,j)) *)
	(g_U2 <= h_U2),
	(* (U2(x_star,j) <= U2(x_star,j)) *)
	(h_U2 <= h_U2),
	(* (U2(x_star,y_star) <= U2(x_star,j)) *)
	(i_U2 <= h_U2),
	(* ((U2(x_star,y_hat) + f2(x_star,y_hat)) <= U2(x_star,j)) *)
	((g_U2 + g_f2) <= h_U2),
	(* ((U2(x_star,j) + f2(x_star,j)) <= U2(x_star,j)) *)
	((h_U2 + h_f2) <= h_U2),
	(* ((U2(x_star,y_star) + f2(x_star,y_star)) <= U2(x_star,j)) *)
	((i_U2 + i_f2) <= h_U2),
	(* (U1(r,j) <= U1(r,j)) *)
	(b_U1 <= b_U1),
	(* (U1(x_hat,j) <= U1(r,j)) *)
	(e_U1 <= b_U1),
	(* (U1(x_star,j) <= U1(r,j)) *)
	(h_U1 <= b_U1),
	(* ((U1(r,j) + f1(r,j)) <= U1(r,j)) *)
	((b_U1 + b_f1) <= b_U1),
	(* ((U1(x_hat,j) + f1(x_hat,j)) <= U1(r,j)) *)
	((e_U1 + e_f1) <= b_U1),
	(* ((U1(x_star,j) + f1(x_star,j)) <= U1(r,j)) *)
	((h_U1 + h_f1) <= b_U1),
	(* ((f1(r,y_hat) - f1(r,y_hat)) == (U1(r,y_hat) - U1(r,y_hat))) *)
	((a_f1 - a_f1) == (a_U1 - a_U1)),
	(* ((f1(x_hat,y_hat) - f1(r,y_hat)) == (U1(r,y_hat) - U1(x_hat,y_hat))) *)
	((d_f1 - a_f1) == (a_U1 - d_U1)),
	(* ((f1(x_star,y_hat) - f1(r,y_hat)) == (U1(r,y_hat) - U1(x_star,y_hat))) *)
	((g_f1 - a_f1) == (a_U1 - g_U1)),
	(* ((f1(r,y_hat) - f1(x_hat,y_hat)) == (U1(x_hat,y_hat) - U1(r,y_hat))) *)
	((a_f1 - d_f1) == (d_U1 - a_U1)),
	(* ((f1(x_hat,y_hat) - f1(x_hat,y_hat)) == (U1(x_hat,y_hat) - U1(x_hat,y_hat))) *)
	((d_f1 - d_f1) == (d_U1 - d_U1)),
	(* ((f1(x_star,y_hat) - f1(x_hat,y_hat)) == (U1(x_hat,y_hat) - U1(x_star,y_hat))) *)
	((g_f1 - d_f1) == (d_U1 - g_U1)),
	(* ((f1(r,y_hat) - f1(x_star,y_hat)) == (U1(x_star,y_hat) - U1(r,y_hat))) *)
	((a_f1 - g_f1) == (g_U1 - a_U1)),
	(* ((f1(x_hat,y_hat) - f1(x_star,y_hat)) == (U1(x_star,y_hat) - U1(x_hat,y_hat))) *)
	((d_f1 - g_f1) == (g_U1 - d_U1)),
	(* ((f1(x_star,y_hat) - f1(x_star,y_hat)) == (U1(x_star,y_hat) - U1(x_star,y_hat))) *)
	((g_f1 - g_f1) == (g_U1 - g_U1)),
	(* ((f1(r,j) - f1(r,j)) == (U1(r,j) - U1(r,j))) *)
	((b_f1 - b_f1) == (b_U1 - b_U1)),
	(* ((f1(x_hat,j) - f1(r,j)) == (U1(r,j) - U1(x_hat,j))) *)
	((e_f1 - b_f1) == (b_U1 - e_U1)),
	(* ((f1(x_star,j) - f1(r,j)) == (U1(r,j) - U1(x_star,j))) *)
	((h_f1 - b_f1) == (b_U1 - h_U1)),
	(* ((f1(r,j) - f1(x_hat,j)) == (U1(x_hat,j) - U1(r,j))) *)
	((b_f1 - e_f1) == (e_U1 - b_U1)),
	(* ((f1(x_hat,j) - f1(x_hat,j)) == (U1(x_hat,j) - U1(x_hat,j))) *)
	((e_f1 - e_f1) == (e_U1 - e_U1)),
	(* ((f1(x_star,j) - f1(x_hat,j)) == (U1(x_hat,j) - U1(x_star,j))) *)
	((h_f1 - e_f1) == (e_U1 - h_U1)),
	(* ((f1(r,j) - f1(x_star,j)) == (U1(x_star,j) - U1(r,j))) *)
	((b_f1 - h_f1) == (h_U1 - b_U1)),
	(* ((f1(x_hat,j) - f1(x_star,j)) == (U1(x_star,j) - U1(x_hat,j))) *)
	((e_f1 - h_f1) == (h_U1 - e_U1)),
	(* ((f1(x_star,j) - f1(x_star,j)) == (U1(x_star,j) - U1(x_star,j))) *)
	((h_f1 - h_f1) == (h_U1 - h_U1)),
	(* ((f1(r,y_star) - f1(r,y_star)) == (U1(r,y_star) - U1(r,y_star))) *)
	((c_f1 - c_f1) == (c_U1 - c_U1)),
	(* ((f1(x_hat,y_star) - f1(r,y_star)) == (U1(r,y_star) - U1(x_hat,y_star))) *)
	((f_f1 - c_f1) == (c_U1 - f_U1)),
	(* ((f1(x_star,y_star) - f1(r,y_star)) == (U1(r,y_star) - U1(x_star,y_star))) *)
	((i_f1 - c_f1) == (c_U1 - i_U1)),
	(* ((f1(r,y_star) - f1(x_hat,y_star)) == (U1(x_hat,y_star) - U1(r,y_star))) *)
	((c_f1 - f_f1) == (f_U1 - c_U1)),
	(* ((f1(x_hat,y_star) - f1(x_hat,y_star)) == (U1(x_hat,y_star) - U1(x_hat,y_star))) *)
	((f_f1 - f_f1) == (f_U1 - f_U1)),
	(* ((f1(x_star,y_star) - f1(x_hat,y_star)) == (U1(x_hat,y_star) - U1(x_star,y_star))) *)
	((i_f1 - f_f1) == (f_U1 - i_U1)),
	(* ((f1(r,y_star) - f1(x_star,y_star)) == (U1(x_star,y_star) - U1(r,y_star))) *)
	((c_f1 - i_f1) == (i_U1 - c_U1)),
	(* ((f1(x_hat,y_star) - f1(x_star,y_star)) == (U1(x_star,y_star) - U1(x_hat,y_star))) *)
	((f_f1 - i_f1) == (i_U1 - f_U1)),
	(* ((f1(x_star,y_star) - f1(x_star,y_star)) == (U1(x_star,y_star) - U1(x_star,y_star))) *)
	((i_f1 - i_f1) == (i_U1 - i_U1)),
	(* ((f2(r,y_hat) - f2(r,y_hat)) == (U2(r,y_hat) - U2(r,y_hat))) *)
	((a_f2 - a_f2) == (a_U2 - a_U2)),
	(* ((f2(x_hat,y_hat) - f2(x_hat,y_hat)) == (U2(x_hat,y_hat) - U2(x_hat,y_hat))) *)
	((d_f2 - d_f2) == (d_U2 - d_U2)),
	(* ((f2(x_star,y_hat) - f2(x_star,y_hat)) == (U2(x_star,y_hat) - U2(x_star,y_hat))) *)
	((g_f2 - g_f2) == (g_U2 - g_U2)),
	(* ((f2(r,j) - f2(r,y_hat)) == (U2(r,y_hat) - U2(r,j))) *)
	((b_f2 - a_f2) == (a_U2 - b_U2)),
	(* ((f2(x_hat,j) - f2(x_hat,y_hat)) == (U2(x_hat,y_hat) - U2(x_hat,j))) *)
	((e_f2 - d_f2) == (d_U2 - e_U2)),
	(* ((f2(x_star,j) - f2(x_star,y_hat)) == (U2(x_star,y_hat) - U2(x_star,j))) *)
	((h_f2 - g_f2) == (g_U2 - h_U2)),
	(* ((f2(r,y_star) - f2(r,y_hat)) == (U2(r,y_hat) - U2(r,y_star))) *)
	((c_f2 - a_f2) == (a_U2 - c_U2)),
	(* ((f2(x_hat,y_star) - f2(x_hat,y_hat)) == (U2(x_hat,y_hat) - U2(x_hat,y_star))) *)
	((f_f2 - d_f2) == (d_U2 - f_U2)),
	(* ((f2(x_star,y_star) - f2(x_star,y_hat)) == (U2(x_star,y_hat) - U2(x_star,y_star))) *)
	((i_f2 - g_f2) == (g_U2 - i_U2)),
	(* ((f2(r,y_hat) - f2(r,j)) == (U2(r,j) - U2(r,y_hat))) *)
	((a_f2 - b_f2) == (b_U2 - a_U2)),
	(* ((f2(x_hat,y_hat) - f2(x_hat,j)) == (U2(x_hat,j) - U2(x_hat,y_hat))) *)
	((d_f2 - e_f2) == (e_U2 - d_U2)),
	(* ((f2(x_star,y_hat) - f2(x_star,j)) == (U2(x_star,j) - U2(x_star,y_hat))) *)
	((g_f2 - h_f2) == (h_U2 - g_U2)),
	(* ((f2(r,j) - f2(r,j)) == (U2(r,j) - U2(r,j))) *)
	((b_f2 - b_f2) == (b_U2 - b_U2)),
	(* ((f2(x_hat,j) - f2(x_hat,j)) == (U2(x_hat,j) - U2(x_hat,j))) *)
	((e_f2 - e_f2) == (e_U2 - e_U2)),
	(* ((f2(x_star,j) - f2(x_star,j)) == (U2(x_star,j) - U2(x_star,j))) *)
	((h_f2 - h_f2) == (h_U2 - h_U2)),
	(* ((f2(r,y_star) - f2(r,j)) == (U2(r,j) - U2(r,y_star))) *)
	((c_f2 - b_f2) == (b_U2 - c_U2)),
	(* ((f2(x_hat,y_star) - f2(x_hat,j)) == (U2(x_hat,j) - U2(x_hat,y_star))) *)
	((f_f2 - e_f2) == (e_U2 - f_U2)),
	(* ((f2(x_star,y_star) - f2(x_star,j)) == (U2(x_star,j) - U2(x_star,y_star))) *)
	((i_f2 - h_f2) == (h_U2 - i_U2)),
	(* ((f2(r,y_hat) - f2(r,y_star)) == (U2(r,y_star) - U2(r,y_hat))) *)
	((a_f2 - c_f2) == (c_U2 - a_U2)),
	(* ((f2(x_hat,y_hat) - f2(x_hat,y_star)) == (U2(x_hat,y_star) - U2(x_hat,y_hat))) *)
	((d_f2 - f_f2) == (f_U2 - d_U2)),
	(* ((f2(x_star,y_hat) - f2(x_star,y_star)) == (U2(x_star,y_star) - U2(x_star,y_hat))) *)
	((g_f2 - i_f2) == (i_U2 - g_U2)),
	(* ((f2(r,j) - f2(r,y_star)) == (U2(r,y_star) - U2(r,j))) *)
	((b_f2 - c_f2) == (c_U2 - b_U2)),
	(* ((f2(x_hat,j) - f2(x_hat,y_star)) == (U2(x_hat,y_star) - U2(x_hat,j))) *)
	((e_f2 - f_f2) == (f_U2 - e_U2)),
	(* ((f2(x_star,j) - f2(x_star,y_star)) == (U2(x_star,y_star) - U2(x_star,j))) *)
	((h_f2 - i_f2) == (i_U2 - h_U2)),
	(* ((f2(r,y_star) - f2(r,y_star)) == (U2(r,y_star) - U2(r,y_star))) *)
	((c_f2 - c_f2) == (c_U2 - c_U2)),
	(* ((f2(x_hat,y_star) - f2(x_hat,y_star)) == (U2(x_hat,y_star) - U2(x_hat,y_star))) *)
	((f_f2 - f_f2) == (f_U2 - f_U2)),
	(* ((f2(x_star,y_star) - f2(x_star,y_star)) == (U2(x_star,y_star) - U2(x_star,y_star))) *)
	((i_f2 - i_f2) == (i_U2 - i_U2)),
	(* ((f1(r,y_hat) + U1(r,y_hat)) <= 1.000000) *)
	((a_f1 + a_U1) <= 1.000000),
	(* ((f1(x_hat,y_hat) + U1(x_hat,y_hat)) <= 1.000000) *)
	((d_f1 + d_U1) <= 1.000000),
	(* ((f1(x_star,y_hat) + U1(x_star,y_hat)) <= 1.000000) *)
	((g_f1 + g_U1) <= 1.000000),
	(* ((f1(r,j) + U1(r,j)) <= 1.000000) *)
	((b_f1 + b_U1) <= 1.000000),
	(* ((f1(x_hat,j) + U1(x_hat,j)) <= 1.000000) *)
	((e_f1 + e_U1) <= 1.000000),
	(* ((f1(x_star,j) + U1(x_star,j)) <= 1.000000) *)
	((h_f1 + h_U1) <= 1.000000),
	(* ((f1(r,y_star) + U1(r,y_star)) <= 1.000000) *)
	((c_f1 + c_U1) <= 1.000000),
	(* ((f1(x_hat,y_star) + U1(x_hat,y_star)) <= 1.000000) *)
	((f_f1 + f_U1) <= 1.000000),
	(* ((f1(x_star,y_star) + U1(x_star,y_star)) <= 1.000000) *)
	((i_f1 + i_U1) <= 1.000000),
	(* ((f2(r,y_hat) + U2(r,y_hat)) <= 1.000000) *)
	((a_f2 + a_U2) <= 1.000000),
	(* ((f2(x_hat,y_hat) + U2(x_hat,y_hat)) <= 1.000000) *)
	((d_f2 + d_U2) <= 1.000000),
	(* ((f2(x_star,y_hat) + U2(x_star,y_hat)) <= 1.000000) *)
	((g_f2 + g_U2) <= 1.000000),
	(* ((f2(r,j) + U2(r,j)) <= 1.000000) *)
	((b_f2 + b_U2) <= 1.000000),
	(* ((f2(x_hat,j) + U2(x_hat,j)) <= 1.000000) *)
	((e_f2 + e_U2) <= 1.000000),
	(* ((f2(x_star,j) + U2(x_star,j)) <= 1.000000) *)
	((h_f2 + h_U2) <= 1.000000),
	(* ((f2(r,y_star) + U2(r,y_star)) <= 1.000000) *)
	((c_f2 + c_U2) <= 1.000000),
	(* ((f2(x_hat,y_star) + U2(x_hat,y_star)) <= 1.000000) *)
	((f_f2 + f_U2) <= 1.000000),
	(* ((f2(x_star,y_star) + U2(x_star,y_star)) <= 1.000000) *)
	((i_f2 + i_U2) <= 1.000000),
	(* (f1(r,y_hat) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x_hat,y_hat) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(x_star,y_hat) >= 0.000000) *)
	(g_f1 >= 0.000000),
	(* (f1(r,j) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x_hat,j) >= 0.000000) *)
	(e_f1 >= 0.000000),
	(* (f1(x_star,j) >= 0.000000) *)
	(h_f1 >= 0.000000),
	(* (f1(r,y_star) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(x_hat,y_star) >= 0.000000) *)
	(f_f1 >= 0.000000),
	(* (f1(x_star,y_star) >= 0.000000) *)
	(i_f1 >= 0.000000),
	(* (f1(r,y_hat) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(r,j) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(r,y_star) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(x_hat,y_hat) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(x_hat,j) >= 0.000000) *)
	(e_f1 >= 0.000000),
	(* (f1(x_hat,y_star) >= 0.000000) *)
	(f_f1 >= 0.000000),
	(* (f1(x_star,y_hat) >= 0.000000) *)
	(g_f1 >= 0.000000),
	(* (f1(x_star,j) >= 0.000000) *)
	(h_f1 >= 0.000000),
	(* (f1(x_star,y_star) >= 0.000000) *)
	(i_f1 >= 0.000000),
	(* (f1(r,y_hat) >= 0.000000) *)
	(a_f1 >= 0.000000),
	(* (f1(x_hat,y_hat) >= 0.000000) *)
	(d_f1 >= 0.000000),
	(* (f1(x_star,y_hat) >= 0.000000) *)
	(g_f1 >= 0.000000),
	(* (f1(r,j) >= 0.000000) *)
	(b_f1 >= 0.000000),
	(* (f1(x_hat,j) >= 0.000000) *)
	(e_f1 >= 0.000000),
	(* (f1(x_star,j) >= 0.000000) *)
	(h_f1 >= 0.000000),
	(* (f1(r,y_star) >= 0.000000) *)
	(c_f1 >= 0.000000),
	(* (f1(x_hat,y_star) >= 0.000000) *)
	(f_f1 >= 0.000000),
	(* (f1(x_star,y_star) >= 0.000000) *)
	(i_f1 >= 0.000000),
	(* (f2(r,y_hat) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x_hat,y_hat) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(x_star,y_hat) >= 0.000000) *)
	(g_f2 >= 0.000000),
	(* (f2(r,j) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x_hat,j) >= 0.000000) *)
	(e_f2 >= 0.000000),
	(* (f2(x_star,j) >= 0.000000) *)
	(h_f2 >= 0.000000),
	(* (f2(r,y_star) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(x_hat,y_star) >= 0.000000) *)
	(f_f2 >= 0.000000),
	(* (f2(x_star,y_star) >= 0.000000) *)
	(i_f2 >= 0.000000),
	(* (f2(r,y_hat) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(r,j) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(r,y_star) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(x_hat,y_hat) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(x_hat,j) >= 0.000000) *)
	(e_f2 >= 0.000000),
	(* (f2(x_hat,y_star) >= 0.000000) *)
	(f_f2 >= 0.000000),
	(* (f2(x_star,y_hat) >= 0.000000) *)
	(g_f2 >= 0.000000),
	(* (f2(x_star,j) >= 0.000000) *)
	(h_f2 >= 0.000000),
	(* (f2(x_star,y_star) >= 0.000000) *)
	(i_f2 >= 0.000000),
	(* (f2(r,y_hat) >= 0.000000) *)
	(a_f2 >= 0.000000),
	(* (f2(x_hat,y_hat) >= 0.000000) *)
	(d_f2 >= 0.000000),
	(* (f2(x_star,y_hat) >= 0.000000) *)
	(g_f2 >= 0.000000),
	(* (f2(r,j) >= 0.000000) *)
	(b_f2 >= 0.000000),
	(* (f2(x_hat,j) >= 0.000000) *)
	(e_f2 >= 0.000000),
	(* (f2(x_star,j) >= 0.000000) *)
	(h_f2 >= 0.000000),
	(* (f2(r,y_star) >= 0.000000) *)
	(c_f2 >= 0.000000),
	(* (f2(x_hat,y_star) >= 0.000000) *)
	(f_f2 >= 0.000000),
	(* (f2(x_star,y_star) >= 0.000000) *)
	(i_f2 >= 0.000000),
	(* (U2(r,y_hat) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x_hat,y_hat) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* (U2(x_star,y_hat) >= 0.000000) *)
	(g_U2 >= 0.000000),
	(* (U2(r,j) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(x_hat,j) >= 0.000000) *)
	(e_U2 >= 0.000000),
	(* (U2(x_star,j) >= 0.000000) *)
	(h_U2 >= 0.000000),
	(* (U2(r,y_star) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(x_hat,y_star) >= 0.000000) *)
	(f_U2 >= 0.000000),
	(* (U2(x_star,y_star) >= 0.000000) *)
	(i_U2 >= 0.000000),
	(* (U1(r,y_hat) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(x_hat,y_hat) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* (U1(x_star,y_hat) >= 0.000000) *)
	(g_U1 >= 0.000000),
	(* (U1(r,j) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U1(x_hat,j) >= 0.000000) *)
	(e_U1 >= 0.000000),
	(* (U1(x_star,j) >= 0.000000) *)
	(h_U1 >= 0.000000),
	(* (U1(r,y_star) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* (U1(x_hat,y_star) >= 0.000000) *)
	(f_U1 >= 0.000000),
	(* (U1(x_star,y_star) >= 0.000000) *)
	(i_U1 >= 0.000000),
	(* ((U2(r,y_hat) + f2(r,y_hat)) >= 0.000000) *)
	((a_U2 + a_f2) >= 0.000000),
	(* ((U2(r,j) + f2(r,j)) >= 0.000000) *)
	((b_U2 + b_f2) >= 0.000000),
	(* ((U2(r,y_star) + f2(r,y_star)) >= 0.000000) *)
	((c_U2 + c_f2) >= 0.000000),
	(* (U1(r,y_hat) >= 0.000000) *)
	(a_U1 >= 0.000000),
	(* (U1(r,j) >= 0.000000) *)
	(b_U1 >= 0.000000),
	(* (U1(r,y_star) >= 0.000000) *)
	(c_U1 >= 0.000000),
	(* ((U2(x_hat,y_hat) + f2(x_hat,y_hat)) >= 0.000000) *)
	((d_U2 + d_f2) >= 0.000000),
	(* ((U2(x_hat,j) + f2(x_hat,j)) >= 0.000000) *)
	((e_U2 + e_f2) >= 0.000000),
	(* ((U2(x_hat,y_star) + f2(x_hat,y_star)) >= 0.000000) *)
	((f_U2 + f_f2) >= 0.000000),
	(* (U1(x_hat,y_hat) >= 0.000000) *)
	(d_U1 >= 0.000000),
	(* (U1(x_hat,j) >= 0.000000) *)
	(e_U1 >= 0.000000),
	(* (U1(x_hat,y_star) >= 0.000000) *)
	(f_U1 >= 0.000000),
	(* ((U2(x_star,y_hat) + f2(x_star,y_hat)) >= 0.000000) *)
	((g_U2 + g_f2) >= 0.000000),
	(* ((U2(x_star,j) + f2(x_star,j)) >= 0.000000) *)
	((h_U2 + h_f2) >= 0.000000),
	(* ((U2(x_star,y_star) + f2(x_star,y_star)) >= 0.000000) *)
	((i_U2 + i_f2) >= 0.000000),
	(* (U1(x_star,y_hat) >= 0.000000) *)
	(g_U1 >= 0.000000),
	(* (U1(x_star,j) >= 0.000000) *)
	(h_U1 >= 0.000000),
	(* (U1(x_star,y_star) >= 0.000000) *)
	(i_U1 >= 0.000000),
	(* (U2(r,y_hat) >= 0.000000) *)
	(a_U2 >= 0.000000),
	(* (U2(x_hat,y_hat) >= 0.000000) *)
	(d_U2 >= 0.000000),
	(* (U2(x_star,y_hat) >= 0.000000) *)
	(g_U2 >= 0.000000),
	(* (U2(r,j) >= 0.000000) *)
	(b_U2 >= 0.000000),
	(* (U2(x_hat,j) >= 0.000000) *)
	(e_U2 >= 0.000000),
	(* (U2(x_star,j) >= 0.000000) *)
	(h_U2 >= 0.000000),
	(* (U2(r,y_star) >= 0.000000) *)
	(c_U2 >= 0.000000),
	(* (U2(x_hat,y_star) >= 0.000000) *)
	(f_U2 >= 0.000000),
	(* (U2(x_star,y_star) >= 0.000000) *)
	(i_U2 >= 0.000000),
	(* ((U1(r,y_hat) + f1(r,y_hat)) >= 0.000000) *)
	((a_U1 + a_f1) >= 0.000000),
	(* ((U1(x_hat,y_hat) + f1(x_hat,y_hat)) >= 0.000000) *)
	((d_U1 + d_f1) >= 0.000000),
	(* ((U1(x_star,y_hat) + f1(x_star,y_hat)) >= 0.000000) *)
	((g_U1 + g_f1) >= 0.000000),
	(* ((U1(r,j) + f1(r,j)) >= 0.000000) *)
	((b_U1 + b_f1) >= 0.000000),
	(* ((U1(x_hat,j) + f1(x_hat,j)) >= 0.000000) *)
	((e_U1 + e_f1) >= 0.000000),
	(* ((U1(x_star,j) + f1(x_star,j)) >= 0.000000) *)
	((h_U1 + h_f1) >= 0.000000),
	(* ((U1(r,y_star) + f1(r,y_star)) >= 0.000000) *)
	((c_U1 + c_f1) >= 0.000000),
	(* ((U1(x_hat,y_star) + f1(x_hat,y_star)) >= 0.000000) *)
	((f_U1 + f_f1) >= 0.000000),
	(* ((U1(x_star,y_star) + f1(x_star,y_star)) >= 0.000000) *)
	((i_U1 + i_f1) >= 0.000000)
};

(* optimization for approximation bounds *)
result = NMaxValue[{bound, constraints}, {i_U1, i_f1, i_U2, i_f2, f_U1, f_f1, f_U2, f_f2, h_U1, h_f1, h_U2, h_f2, g_U1, g_f1, g_U2, g_f2, e_U1, e_f1, e_U2, e_f2, d_U1, d_f1, d_U2, d_f2, c_U1, c_f1, c_U2, c_f2, b_U1, b_f1, b_U2, b_f2, a_U1, a_f1, a_U2, a_f2}, WorkingPrecision -> 20, AccuracyGoal -> 10, MaxIterations -> 2000]

endTime = AbsoluteTime[];
elapsed = endTime - startTime;
Print["Optimization result: ", result];
Print["\nOptimization completed in ", elapsed, " seconds"];
