.PHONY: all software geral api todos

TYPST = typst compile --root . --font-path fonts --ignore-system-fonts
LAYOUT = curriculo.typ $(wildcard fonts/*.otf)

all: software

software: main.pdf preview.png

geral: main-geral.pdf preview-geral.png

api: dist/api/v1/curriculo.json

todos: software geral api

dist/api/v1/curriculo.json: curriculos/curriculo.yaml curriculos/curriculo-en.yaml scripts/generate_resume_json.rb
	ruby scripts/generate_resume_json.rb curriculos/curriculo.yaml curriculos/curriculo-en.yaml $@

main.pdf: curriculos/curriculo.yaml $(LAYOUT)
	$(TYPST) --input dados=$< curriculo.typ $@

preview.png: curriculos/curriculo.yaml $(LAYOUT)
	$(TYPST) --input dados=$< --format png --ppi 160 curriculo.typ $@

main-geral.pdf: curriculos/curriculo-geral.yaml $(LAYOUT)
	$(TYPST) --input dados=$< curriculo.typ $@

preview-geral.png: curriculos/curriculo-geral.yaml $(LAYOUT)
	$(TYPST) --input dados=$< --format png --ppi 160 curriculo.typ $@
