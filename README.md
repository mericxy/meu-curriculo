# Curriculo em LaTeX

Curriculo de Marcio Valente em LaTeX, otimizado para leitura humana e para sistemas ATS/modelos de IA.

## Preview

[Abrir PDF](main.pdf)

[Baixar DOCX](curriculo.docx)

![Preview do curriculo](preview.png)

## Compilar

```bash
latexmk -pdf main.tex
```

O PDF final sera gerado como `main.pdf`.

## Gerar DOCX

```bash
soffice --headless --convert-to odt --outdir . curriculo.html
soffice --headless --convert-to docx --outdir . curriculo.odt
```
