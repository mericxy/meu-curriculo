# Contribuindo

Contribuições para o gerador, layout e documentação são bem-vindas. Não inclua dados pessoais, experiências, tecnologias ou métricas que não tenham sido fornecidos pelo titular do currículo.

## Ambiente de desenvolvimento

Instale:

- Ruby 3 ou superior;
- GNU Make;
- uma distribuição LaTeX com `latexmk`, suporte ao idioma português e Latin Modern;
- Poppler (`pdftoppm`, `pdftotext` e `pdfinfo`).

No macOS, as dependências principais podem ser instaladas com Homebrew e MacTeX:

```bash
brew install ruby poppler
brew install --cask mactex-no-gui
```

## Arquitetura

```mermaid
flowchart LR
    YAML["curriculos/*.yaml<br/>Conteúdo"] --> MAKE["Makefile + latexmkrc"]
    MAKE --> SCRIPT["generate_resume.rb<br/>Validação e conversão"]
    SCRIPT --> DATA["curriculo*.tex<br/>Conteúdo gerado"]
    DATA --> LAYOUT["main.tex<br/>Layout compartilhado"]
    LAYOUT --> PDF["main*.pdf"]
    PDF --> PREVIEW["preview*.png"]
```

| Arquivo | Responsabilidade |
| --- | --- |
| `curriculos/curriculo.yaml` | Conteúdo do perfil de software. |
| `curriculos/curriculo-geral.yaml` | Conteúdo do perfil geral de TI, sistemas e suporte. |
| `scripts/generate_resume.rb` | Valida o YAML, protege caracteres especiais e gera comandos LaTeX. |
| `curriculo*.tex` | Arquivos intermediários gerados; não devem ser editados manualmente. |
| `main.tex` | Layout compartilhado e ponto de entrada do perfil de software. |
| `main-geral.tex` | Seleciona os dados do perfil geral e reutiliza `main.tex`. |
| `Makefile` e `latexmkrc` | Orquestram geração, compilação e previews. |

## Fluxo de alteração

1. Edite o YAML do perfil desejado ou o arquivo compartilhado correspondente.
2. Execute `make software` ou `make geral` quando alterar conteúdo.
3. Execute `make todos` quando alterar o layout, gerador, `latexmkrc` ou `Makefile`.
4. Confirme que o texto pode ser extraído e que cada PDF permanece em uma página A4.

```bash
pdftotext main.pdf -
pdfinfo main.pdf
pdftotext main-geral.pdf -
pdfinfo main-geral.pdf
```

Para executar manualmente a conversão e a compilação:

```bash
ruby scripts/generate_resume.rb curriculos/curriculo.yaml curriculo.tex
latexmk -pdf -g main.tex
```

Inclua no pull request os PDFs e previews regenerados correspondentes às fontes alteradas. Mantenha o layout em uma coluna, sem tabelas ou elementos que prejudiquem a extração de texto por ATS.
