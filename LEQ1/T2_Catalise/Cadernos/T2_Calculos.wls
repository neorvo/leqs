(* Caderno de cálculo do T2 — dados de EXEMPLO, não de turma.
   Protocolo: 2000 mL água + 20 mL acetato de etilo, ~10 g Dowex 50W-X8, 60 °C. *)

thisDir = DirectoryName[$InputFileName];
Get[FileNameJoin[{thisDir, "..", "Pacotes", "LEQ1T2.wl"}]];

Needs["LEQ1T2`"];

c0 = ConcentracaoInicialEster[
  Quantity[20, "Milliliters"],
  Quantity[2000, "Milliliters"]
];
Print["C0 acetato de etilo = ", UnitConvert[c0, "Moles"/"Liters"]];

raw = Import[FileNameJoin[{thisDir, "..", "dados_exemplo", "ensaio_A_exemplo.csv"}], "Dataset"];

dados = Normal@raw[All,
  <|
    "t" -> Quantity[#t_min, "Minutes"],
    "V_aliquota" -> Quantity[#V_aliquota_mL, "Milliliters"],
    "C_NaOH" -> Quantity[#C_NaOH_mol_L, "Moles"/"Liters"],
    "V_NaOH" -> Quantity[#V_NaOH_mL, "Milliliters"]
  |>&
];

tab = TabelaConversao[dados, c0];
Print[Dataset[tab][All, {"t", "C_acido", "X"}]];

aj = AjusteKObs[tab[[All, "t"]], tab[[All, "X"]]];
Print["k_obs = ", aj["k_obs"], "   R2 = ", aj["R2"]];

prop = CaudalLeitoFixo[aj["k_obs"], Quantity[10, "Grams"], 0.20];
Print["Proposta leito W = 10 g, X = 0.20"];
Print[prop];

Print[Dowex50WX8[]];
