# Primeiro uso no Cursor (HTTPS, conta neorvo)

Já tens o Cursor ligado ao GitHub sem SSH. Usa só a conta **neorvo**.

## 1. Clonar o repo vazio (se ainda não clonaste)

Cursor: **File → Clone Repository**

```
https://github.com/neorvo/leqs.git
```

Escolhe uma pasta local, por exemplo `Documentos/leqs`.

Se o clone oficial ainda só tiver `README` antigo e `LICENSE`, copia para dentro dele
tudo o que está nesta pasta `leqs/` (AGENTS.md, LEQ1/, LEQ2/, .gitignore, README.md novo),
substituindo o README.

## 2. Abrir a pasta

**File → Open Folder** → a pasta `leqs` clonada.

Confirma canto inferior esquerdo: ramo `master` ou `main`, remote `origin`.

## 3. Primeiro commit e push (botões, sem terminal)

1. Ícone **Source Control** (ramificação).
2. Stage All.
3. Mensagem: `LEQ1 T2: pacote de cálculo inicial`.
4. Commit.
5. **Sync / Push**.
6. Se pedir conta, escolhe **neorvo** (não GibbsDB).

## 4. Falar com o Agent sem copiar ficheiros

`Ctrl+I` (Windows) e um pedido deste género:

```
Lê AGENTS.md e LEQ1/T2_Catalise/Pacotes/LEQ1T2.wl.
Não alteres a cinética (não é saponificação).
Acrescenta uma função ModuloMears segundo o protocolo T2
e um teste em testes/testes_T2.wls.
Mostra o diff e espera.
```

O Agent grava no disco. Tu só aceitas o diff e fazes push.

## 5. Correr o cálculo

No Mathematica, com a pasta `leqs` como diretório de trabalho:

```wolfram
SetDirectory["…/leqs"];
Get["LEQ1/T2_Catalise/Pacotes/LEQ1T2.wl"];
<<"LEQ1/T2_Catalise/Cadernos/T2_Calculos.wls"
```

Ou, se `wolframscript` estiver no PATH:

```
wolframscript -file LEQ1/T2_Catalise/testes/testes_T2.wls
```
