# leqs

Cálculos dos trabalhos de **Laboratório de Engenharia Química 1 e 2**
(Universidade de Aveiro, Engenharia Química).

Repositório: [github.com/neorvo/leqs](https://github.com/neorvo/leqs).

O protocolo oficial de cada trabalho continua em Word, na UC.
Aqui vive só o motor de cálculo (Wolfram Language) e dados de *exemplo*.

## Abrir no Cursor (conta GitHub, sem SSH)

1. No Cursor: **File → Clone Repository**.
2. Colar `https://github.com/neorvo/leqs.git`.
3. Iniciar sessão com a conta **neorvo** se pedir.
4. **File → Open Folder** na pasta clonada.
5. Source Control (ícone da ramificação) → Stage → Commit → **Sync / Push**.

Não abras aqui o projecto Gibbs (`GibbsDB`). Pastas e contas separadas.

## Conteúdo

```
LEQ1/T2_Catalise/     hidrólise do acetato de etilo / Dowex 50W-X8
LEQ2/                 reservado (DTR / reatores não ideais)
AGENTS.md             regras para o Cursor e para o Grok
```

## Correr o T2

No Mathematica ou com `wolframscript`:

```wolfram
Get["LEQ1/T2_Catalise/Pacotes/LEQ1T2.wl"]
Get["LEQ1/T2_Catalise/Cadernos/T2_Calculos.wls"]
```

Testes sintéticos:

```wolfram
Get["LEQ1/T2_Catalise/testes/testes_T2.wls"]
```

## O que não entra neste repo

- dados brutos de turmas
- rubricas e notas
- drafts internos do protocolo Word
