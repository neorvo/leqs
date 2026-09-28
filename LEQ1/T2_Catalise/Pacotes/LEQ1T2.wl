(* ::Package:: *)
(* LEQ1T2 — hidrólise do acetato de etilo sobre resina ácida (T2, LEQ 1, UA).
   Não é saponificação. 1.ª ordem aparente no éster com excesso de água. *)

BeginPackage["LEQ1T2`"];

ConcentracaoInicialEster::usage =
  "ConcentracaoInicialEster[vEster, vAgua] concentração inicial do acetato de etilo. \
Volumes com unidade. Densidade e massa molar por omissão: 0.900 g/mL e 88.11 g/mol.";

ConversaoTitulacao::usage =
  "ConversaoTitulacao[vAliquota, cNaOH, vNaOH, c0] conversão X a partir da titulação \
do ácido acético (estequiometria 1:1), com X = C_acido / c0.";

TabelaConversao::usage =
  "TabelaConversao[dados, c0] dados = lista de associações com chaves \
\"t\", \"V_aliquota\", \"C_NaOH\", \"V_NaOH\". Devolve tabela com C_acido e X.";

AjusteKObs::usage =
  "AjusteKObs[tempos, conversoes] ajusta -Log[1-X] = k_obs t. \
Devolve <|\"k_obs\", \"R2\", \"ajuste\"|>. tempos e k_obs com unidade se os tempos a tiverem.";

ArrheniusAparente::usage =
  "ArrheniusAparente[temperaturas, kObs] ln k = ln k0 - Ea/(R T). \
Devolve <|\"Ea\", \"k0\", \"R2\", \"ajuste\"|>.";

VelocidadeObservada::usage =
  "VelocidadeObservada[kObs, cBulk] r'_obs = k_obs C_A,bulk (eq. 12 do protocolo).";

ModuloWeiszPrater::usage =
  "ModuloWeiszPrater[rObsMassa, dp, rhoP, de, cS] M_WP = (dp^2/36) r'_obs ρ_p / (D_e C_{A,s}). \
rObsMassa é a velocidade por massa de catalisador. Classifica o regime.";

FatorEficienciaEsfera::usage =
  "FatorEficienciaEsfera[moduloThiele] η para esfera e 1.ª ordem (eq. 8). \
Só usar depois de Weisz-Prater indicar limitações internas.";

CaudalLeitoFixo::usage =
  "CaudalLeitoFixo[kObsBatch, wCat, xAlvo] Q = - k_obs W / ln(1-X) (Tabela 1). \
Hipótese explícita: k_obs,batch ≈ k_obs,leito.";

MassaLeitoFixo::usage =
  "MassaLeitoFixo[kObsBatch, qv, xAlvo] W = - Q ln(1-X) / k_obs (Tabela 1).";

DensidadeResinaMolhada::usage =
  "DensidadeResinaMolhada[rhoSeca, alpha] ρ_p,molhada = (1+α) ρ_seca (eq. 26).";

Dowex50WX8::usage = "Dowex50WX8[] propriedades de catálogo usadas no protocolo (Tabela 2).";

Begin["`Private`"];

$MassaMolarAcEtilo = Quantity[88.11, "Grams"/"Moles"];
$DensidadeAcEtilo = Quantity[0.900, "Grams"/"Milliliters"];
$R = Quantity[8.314, "Joules"/("Moles"*"Kelvins")];

ConcentracaoInicialEster[vEster_, vAgua_,
    dens_:$DensidadeAcEtilo, mw_:$MassaMolarAcEtilo] :=
  Module[{n0, vTot},
    n0 = dens*vEster/mw;
    vTot = vEster + vAgua;
    n0/vTot
  ];

ConversaoTitulacao[vAliquota_, cNaOH_, vNaOH_, c0_] :=
  Module[{cAcido},
    cAcido = cNaOH*vNaOH/vAliquota;
    cAcido/c0
  ];

TabelaConversao[dados_List, c0_] :=
  Map[
    Function[row,
      Module[{cAcido, x},
        cAcido = row["C_NaOH"]*row["V_NaOH"]/row["V_aliquota"];
        x = cAcido/c0;
        Join[row, <|"C_acido" -> cAcido, "X" -> x|>]
      ]
    ],
    dados
  ];

AjusteKObs[tempos_List, conversoes_List] :=
  Module[{y, fit, k, r2, tm},
    y = -Log[1 - conversoes];
    tm = If[QuantityQ[First[tempos]], QuantityMagnitude[tempos], tempos];
    fit = LinearModelFit[Transpose[{tm, y}], t, t];
    k = fit["BestFitParameters"][[2]];
    If[QuantityQ[First[tempos]],
      k = Quantity[k, 1/QuantityUnit[First[tempos]]]
    ];
    r2 = fit["RSquared"];
    <|"k_obs" -> k, "R2" -> r2, "ajuste" -> fit|>
  ];

ArrheniusAparente[temperaturas_List, kObs_List] :=
  Module[{T, lnk, x, fit, slope, intercept, ea, k0},
    T = If[QuantityQ[First[temperaturas]],
      QuantityMagnitude[UnitConvert[temperaturas, "Kelvins"]],
      temperaturas
    ];
    lnk = Log[If[QuantityQ[First[kObs]], QuantityMagnitude[kObs], kObs]];
    x = 1/T;
    fit = LinearModelFit[Transpose[{x, lnk}], u, u];
    intercept = fit["BestFitParameters"][[1]];
    slope = fit["BestFitParameters"][[2]];
    ea = -slope*$R;
    If[QuantityQ[First[temperaturas]],
      ea = Quantity[QuantityMagnitude[ea], "Joules"/"Moles"]
    ];
    k0 = Exp[intercept];
    <|"Ea" -> ea, "k0" -> k0, "R2" -> fit["RSquared"], "ajuste" -> fit|>
  ];

VelocidadeObservada[kObs_, cBulk_] := kObs*cBulk;

(* M_WP = (d_p^2 / 36) * r'_obs * ρ_p / (D_e C_s)
   r'_obs por massa de catalisador. Critério usual: M_WP << 1 sem limitação interna. *)
ModuloWeiszPrater[rObsMassa_, dp_, rhoP_, de_, cS_] :=
  Module[{mwp, regime},
    mwp = (dp^2/36)*rObsMassa*rhoP/(de*cS);
    mwp = If[QuantityQ[mwp], QuantityMagnitude[UnitConvert[mwp, "DimensionlessUnit"]], mwp];
    regime = Which[
      mwp < 0.15, "cinetico (limitacoes internas desprezaveis)",
      mwp > 1, "forte limitacao interna",
      True, "zona intermédia — discutir no relatório"
    ];
    <|"M_WP" -> mwp, "regime" -> regime|>
  ];

FatorEficienciaEsfera[mt_] :=
  Module[{m},
    m = If[QuantityQ[mt], QuantityMagnitude[mt], mt];
    If[m == 0, 1, (1/m)*(1/Tanh[3 m] - 1/(3 m))]
  ];

CaudalLeitoFixo[kObsBatch_, wCat_, xAlvo_] :=
  <|"Q" -> -kObsBatch*wCat/Log[1 - xAlvo],
    "X_alvo" -> xAlvo,
    "W" -> wCat,
    "hipotese" -> "k_obs,batch ≈ k_obs,leito (1.ª aproximação, Tabela 1)"|>;

MassaLeitoFixo[kObsBatch_, qv_, xAlvo_] :=
  <|"W" -> -qv*Log[1 - xAlvo]/kObsBatch,
    "X_alvo" -> xAlvo,
    "Q" -> qv,
    "hipotese" -> "k_obs,batch ≈ k_obs,leito (1.ª aproximação, Tabela 1)"|>;

DensidadeResinaMolhada[rhoSeca_, alpha_] := (1 + alpha)*rhoSeca;

Dowex50WX8[] :=
  <|
    "nome" -> "Dowex 50W-X8",
    "reticulacao" -> Quantity[8, "Percent"],
    "alpha" -> Interval[{0.50, 0.56}],
    "rho_seca" -> Quantity[50, "Pounds"/"Feet"^3],
    "mesh_tabela" -> {"50-100", "100-200", "200-400"},
    "nota" -> "Tabela 2 do protocolo T2; 20-50 mesh usado no ensaio A não vem na tabela."
  |>;

End[];
EndPackage[];
