// Layout do currículo em Typst. Lê o YAML diretamente, sem gerador intermediário.
// Uso: make software / make geral (veja o Makefile).

#let dados = yaml("/" + sys.inputs.at("dados", default: "curriculos/curriculo.yaml"))

#let accent = rgb("#1F4E79")
#let textgray = rgb("#333333")

#set document(title: dados.pessoal.nome + " - Currículo", author: dados.pessoal.nome)
#set page(paper: "a4", margin: 1.15cm, fill: white)
#set text(font: "Latin Modern Sans", size: 10pt, lang: "pt", region: "BR", fill: textgray)
#set par(leading: 0.42em, spacing: 0.42em, justify: true)
#show link: set text(fill: accent)

// "--" no YAML vinha da convenção do LaTeX; aqui vira travessão.
#let t(valor) = valor.replace("--", "–").replace(regex("\s+"), " ").trim()

#let frase(itens) = {
  let itens = itens.map(t)
  let texto = if itens.len() == 1 {
    itens.first()
  } else if itens.len() == 2 {
    itens.join(" e ")
  } else {
    let conector = if itens.last().contains(" e ") { ", " } else { " e " }
    itens.slice(0, -1).join(", ") + conector + itens.last()
  }
  if texto.ends-with(regex("[.!?]")) { texto } else { texto + "." }
}

#let secao(titulo) = {
  v(5pt)
  block(spacing: 0pt, text(size: 10pt, weight: "bold", fill: accent, titulo))
  v(2pt)
  line(length: 100%, stroke: 0.7pt + accent)
  v(1pt)
}

#let papel(titulo, periodo, organizacao, local) = [
  *#t(titulo)* | #t(periodo) \
  _#t(organizacao)_ | _#t(local)_
]

#let ligacao(l) = link(l.url, t(l.texto))

// Cabeçalho
#let p = dados.pessoal
#block(spacing: 0pt)[
  #text(size: 17.28pt, weight: "bold", t(p.nome))
  #v(1pt)
  #text(size: 12pt, t(p.titulo))
  #v(3pt)
  #link("mailto:" + p.email, p.email) #h(1em) | #h(1em) #t(p.telefone) #h(1em) | #h(1em) #t(p.localizacao) \
  #ligacao(p.linkedin) #h(1em) | #h(1em) #ligacao(p.github) #h(1em) | #h(1em) #ligacao(p.site)
]

#secao[Resumo Profissional]
#t(dados.resumo)

#secao[Competências Técnicas]
#for c in dados.competencias [
  *#t(c.categoria):* #frase(c.itens) \
]

#secao[Experiência Profissional]
#for (i, e) in dados.experiencias.enumerate() {
  if i > 0 { v(4pt) }
  papel(e.cargo, e.periodo, e.organizacao, e.localizacao)
  linebreak()
  e.realizacoes.map(r => [– #t(r)]).join(linebreak())
  parbreak()
}

#secao[Projetos]
#for (i, pr) in dados.projetos.enumerate() {
  let subtitulo = if "subtitulo" in pr { t(pr.subtitulo) } else { pr.tecnologias.map(t).join(", ") }
  [*#t(pr.nome) | #pr.links.map(ligacao).join(" | ")* \ _#subtitulo _ \ #t(pr.descricao)]
  parbreak()
}

#secao[Educação]
#for (i, ed) in dados.educacao.enumerate() {
  if i > 0 { v(4pt) }
  papel(ed.curso, ed.periodo, ed.instituicao, ed.localizacao)
  parbreak()
}

#secao[Idiomas]
#dados.idiomas.map(l => [#t(l.idioma): #t(l.nivel)]).join(linebreak())

#if "informacoes_adicionais" in dados [
  #secao[Informações Adicionais]
  #dados.informacoes_adicionais.map(x => [#t(x.titulo): #t(x.valor)]).join(linebreak())
]
