thisDir = DirectoryName[$InputFileName];
Get[FileNameJoin[{thisDir, "..", "Pacotes", "LEQ1T2.wl"}]];
Needs["LEQ1T2`"];

ok = True;
check[nome_, cond_] := (
  If[TrueQ[cond],
    Print["OK  ", nome],
    Print["FALHOU  ", nome]; ok = False
  ]
);

(* 20 mL éster + 2000 mL água → C0 da ordem de 0.1 mol/L *)
c0 = QuantityMagnitude@UnitConvert[
  ConcentracaoInicialEster[Quantity[20, "Milliliters"], Quantity[2000, "Milliliters"]],
  "Moles"/"Liters"
];
check["C0 na ordem 0.10 mol/L", 0.09 < c0 < 0.11];

(* X = C_acido / C0 com estequiometria 1:1 *)
x = ConversaoTitulacao[
  Quantity[2, "Milliliters"],
  Quantity[0.02, "Moles"/"Liters"],
  Quantity[2, "Milliliters"],
  Quantity[0.1, "Moles"/"Liters"]
];
check["conversao titulacao", Abs[QuantityMagnitude@UnitConvert[x, "DimensionlessUnit"] - 0.20] < 1*^-9 || Abs[x - 0.2] < 1*^-6];

(* cinética exacta X = 1 - Exp[-k t] deve recuperar k *)
kTrue = 0.02;
tt = Range[5, 40, 5];
xx = 1 - Exp[-kTrue*tt];
aj = AjusteKObs[tt, xx];
check["ajuste k_obs", Abs[aj["k_obs"] - kTrue] < 1*^-8];
check["R2 ajuste", aj["R2"] > 0.999];

(* Tabela 1: W e Q inversos *)
k = Quantity[0.02, 1/"Minutes"];
w = Quantity[10, "Grams"];
q = CaudalLeitoFixo[k, w, 0.20]["Q"];
w2 = MassaLeitoFixo[k, q, 0.20]["W"];
check["inversao W-Q Tabela 1", Abs[QuantityMagnitude@UnitConvert[w2 - w, "Grams"]] < 1*^-8];

(* η → 1 quando M_T → 0 *)
check["eta(0) = 1", FatorEficienciaEsfera[0] == 1];
check["eta pequeno MT perto de 1", 0.98 < FatorEficienciaEsfera[0.1] < 1.001];

(* eq. 26 *)
check["densidade molhada", DensidadeResinaMolhada[50, 0.53] == 76.5];

If[ok, Print["\nTodos os testes passaram."], Print["\nHá testes em falha."]; Quit[1]];
