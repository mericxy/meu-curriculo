# AGENTS.md

Instrucoes para agentes trabalhando neste repositorio.

## Objetivo do repositorio

Este repositorio mantem versoes do curriculo de Marcio Valente com conteudo em YAML, layout compartilhado em Typst, PDFs finais, imagens de preview e uma API JSON estatica bilingue.

Prioridades:

- Manter o curriculo simples, legivel e otimizado para ATS/modelos de IA.
- Evitar layouts complexos, colunas, tabelas, icones ou elementos que prejudiquem a extracao de texto.
- Preservar conteudo verdadeiro. Nao inventar tecnologias, metricas, cargos, projetos ou resultados.
- Sempre atualizar o PDF e o preview correspondentes quando um YAML mudar.
- Sempre executar `make todos` quando o layout compartilhado ou o gerador mudar.

## Arquivos principais

- `curriculos/curriculo.yaml`: fonte de conteudo do perfil de software.
- `curriculos/curriculo-en.yaml`: traducao inglesa do perfil de software para a API estatica.
- `curriculos/curriculo-geral.yaml`: fonte de conteudo do perfil geral de TI, sistemas e suporte.
- `curriculo.typ`: layout compartilhado em Typst; le diretamente o YAML passado via `--input dados=...`.
- `fonts/`: fontes Latin Modern Sans versionadas, usadas pelo Typst.
- `main.pdf` e `preview.png`: artefatos finais do perfil de software.
- `main-geral.pdf` e `preview-geral.png`: artefatos finais do perfil geral.
- `scripts/generate_resume_json.rb`: validacao bilingue e conversao para o contrato JSON publico.
- `wrangler.jsonc`: configuracao do Worker que publica os assets estaticos.
- `Makefile`: alvos `software`, `geral`, `api` e `todos`.
- `README.md`: exibicao dos previews, links para os PDFs e documentacao da arquitetura.
- `TODO-PROJETOS.md`: backlog para adicionar projetos ao curriculo.
- `LOG-TO-DO.md`: registro das mudancas executadas a partir de tarefas do usuario.

## Fluxo de trabalho

1. Leia o pedido do usuario e confira o estado do Git:

```bash
git status --short --untracked-files=all
```

2. Antes de editar, leia o YAML do perfil solicitado e os arquivos compartilhados relevantes:

```bash
sed -n '1,260p' curriculos/curriculo.yaml
sed -n '1,260p' curriculos/curriculo-geral.yaml
sed -n '1,260p' curriculo.typ
sed -n '1,280p' README.md
```

3. Edite o conteudo no YAML correspondente. Edite `curriculo.typ` somente para mudancas de layout, mantendo:

- Uma pagina sempre que possivel.
- Secoes diretas: resumo, competencias, experiencia, educacao, idiomas e projetos quando existirem.
- Texto extraivel e sem decoracao excessiva.
- Keywords distribuidas naturalmente nas experiencias e competencias, sem secao artificial de "Palavras-chave".

4. Gere o perfil correspondente quando o conteudo mudar:

```bash
make software
make geral
```

Quando `curriculo.typ`, `fonts/`, o gerador JSON ou o `Makefile` mudar, gere todos os artefatos:

```bash
make todos
```

Os alvos do Make tambem regeneram os previews PNG.

Quando a fonte inglesa mudar sem alteracao no perfil em portugues, execute pelo menos:

```bash
make api
```

5. Valide os PDFs para ATS/modelos de IA:

```bash
pdftotext main.pdf -
pdfinfo main.pdf
pdftotext main-geral.pdf -
pdfinfo main-geral.pdf
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
git diff -- Makefile curriculo.typ fonts curriculos/curriculo.yaml curriculos/curriculo-en.yaml curriculos/curriculo-geral.yaml README.md AGENTS.md CONTRIBUTING.md scripts/generate_resume_json.rb wrangler.jsonc .github TODO-PROJETOS.md LOG-TO-DO.md
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
