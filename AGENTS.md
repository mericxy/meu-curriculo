# AGENTS.md

Instrucoes para agentes trabalhando neste repositorio.

## Objetivo do repositorio

Este repositorio mantem o curriculo de Marcio Valente em LaTeX, com PDF final e imagem de preview para exibicao no README.

Prioridades:

- Manter o curriculo simples, legivel e otimizado para ATS/modelos de IA.
- Evitar layouts complexos, colunas, tabelas, icones ou elementos que prejudiquem a extracao de texto.
- Preservar conteudo verdadeiro. Nao inventar tecnologias, metricas, cargos, projetos ou resultados.
- Sempre atualizar `main.pdf` e `preview.png` quando `main.tex` mudar.

## Arquivos principais

- `main.tex`: fonte principal do curriculo.
- `main.pdf`: PDF compilado a partir do LaTeX.
- `preview.png`: imagem da primeira pagina do PDF usada no README.
- `README.md`: exibicao do preview, link para o PDF e comando de compilacao.
- `TODO-PROJETOS.md`: backlog para adicionar projetos ao curriculo.
- `LOG-TO-DO.md`: registro das mudancas executadas a partir de tarefas do usuario.

## Fluxo de trabalho

1. Leia o pedido do usuario e confira o estado do Git:

```bash
git status --short --untracked-files=all
```

2. Antes de editar, leia os arquivos relevantes. Para mudancas no curriculo, normalmente leia:

```bash
sed -n '1,260p' main.tex
sed -n '1,200p' README.md
```

3. Edite `main.tex` de forma conservadora, mantendo:

- Uma pagina sempre que possivel.
- Secoes diretas: resumo, competencias, experiencia, educacao, idiomas e projetos quando existirem.
- Texto extraivel e sem decoracao excessiva.
- Keywords distribuidas naturalmente nas experiencias e competencias, sem secao artificial de "Palavras-chave".

4. Recompile o PDF sempre que `main.tex` mudar:

```bash
latexmk -pdf -g main.tex
```

5. Regere o preview PNG sempre que `main.pdf` mudar:

```bash
pdftoppm -png -singlefile -r 160 main.pdf preview
```

6. Valide o PDF para ATS/modelos de IA:

```bash
pdftotext main.pdf -
pdfinfo main.pdf
```

Critérios mínimos:

- `pdftotext` deve retornar texto legivel, com acentos corretos e secoes em ordem.
- `pdfinfo` deve confirmar 1 pagina em A4, salvo pedido explicito do usuario para expandir.

## Padrao de commits

Use commits pequenos e objetivos. Prefira mensagens em ingles, no imperativo ou descritivas curtas.

Exemplos:

```text
Update resume summary and skills
Add resume project backlog
Refresh resume preview
Document resume workflow
```

Antes de commitar:

```bash
git diff -- main.tex README.md AGENTS.md TODO-PROJETOS.md LOG-TO-DO.md
git status --short --untracked-files=all
```

Inclua no commit apenas arquivos relacionados ao pedido. Nao reverta mudancas do usuario.

## Logs e tarefas

Quando o usuario pedir para executar um TODO:

- Leia o arquivo de TODO citado.
- Execute os itens solicitados.
- Registre o que foi feito em `LOG-TO-DO.md` ou em um log especifico indicado pelo usuario.
- Se faltar informacao para uma mudanca verdadeira, crie ou atualize um TODO com as perguntas objetivas.

## DOCX

`pandoc` pode nao estar instalado. A maquina possui LibreOffice (`libreoffice`, `lowriter`, `soffice`).

Fluxo recomendado para DOCX:

- Finalizar primeiro o conteudo do curriculo.
- Criar uma versao intermediaria simples, como HTML ou ODT.
- Converter com LibreOffice em modo headless.
- Validar abrindo/extrair texto quando possivel.

Nao gerar `.docx` automaticamente sem pedido explicito.

## Cuidados de conteudo

- Nao adicionar projeto sem nome, link ou descricao fornecida pelo usuario.
- Nao adicionar React Router, testes, cloud, CI/CD, banco de dados ou outras tecnologias sem confirmacao.
- Numeros e metricas devem vir do usuario ou estar claramente marcados como aproximados quando ele autorizar.
- Evitar frases genericas como "aprendizado continuo" quando houver experiencia concreta para destacar.
