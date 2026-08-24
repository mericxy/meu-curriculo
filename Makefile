.PHONY: all software geral api todos

all: software

software: main.pdf preview.png

geral: main-geral.pdf preview-geral.png

api: dist/api/v1/curriculo.json

todos: software geral api

dist/api/v1/curriculo.json: curriculos/curriculo.yaml curriculos/curriculo-en.yaml scripts/generate_resume_json.rb
	ruby scripts/generate_resume_json.rb curriculos/curriculo.yaml curriculos/curriculo-en.yaml $@

curriculo.tex: curriculos/curriculo.yaml scripts/generate_resume.rb
	ruby scripts/generate_resume.rb curriculos/curriculo.yaml curriculo.tex

main.pdf: main.tex curriculo.tex
	latexmk -pdf -g main.tex

preview.png: main.pdf
	pdftoppm -png -singlefile -r 160 main.pdf preview

curriculo-geral.tex: curriculos/curriculo-geral.yaml scripts/generate_resume.rb
	ruby scripts/generate_resume.rb curriculos/curriculo-geral.yaml curriculo-geral.tex

main-geral.pdf: main-geral.tex main.tex curriculo-geral.tex
	latexmk -pdf -g main-geral.tex

preview-geral.png: main-geral.pdf
	pdftoppm -png -singlefile -r 160 main-geral.pdf preview-geral
