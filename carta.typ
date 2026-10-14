// Layout da carta de apresentação em Typst, com a mesma identidade visual de curriculo.typ.
// Cabeçalho vem do YAML do currículo (--input dados=...); corpo vem do YAML da carta (--input carta=...).
// Uso: typst compile --root . --font-path fonts --ignore-system-fonts \
//        --input dados=<curriculo.yaml> --input carta=<carta.yaml> carta.typ <saida.pdf>

#let dados = yaml("/" + sys.inputs.at("dados", default: "curriculos/curriculo.yaml"))
#let carta = yaml("/" + sys.inputs.carta)

#let accent = rgb("#1F4E79")
#let textgray = rgb("#2B2B2B")
#let muted = rgb("#5A5A5A")

#set document(title: dados.pessoal.nome + " - Carta de apresentação", author: dados.pessoal.nome)
#set page(paper: "a4", margin: 1.7cm, fill: white)
#set text(font: "Latin Modern Sans", size: 11pt, lang: "pt", region: "BR", fill: textgray, hyphenate: false)
#set par(leading: 0.6em, spacing: 1.1em, justify: true)
#show link: set text(fill: accent)
#show regex("\S+-\S+"): it => box(it)

#let t(valor) = valor.replace("--", "–").replace(regex("\s+"), " ").trim()
#let sep = text(fill: muted)[#h(0.4em)|#h(0.4em)]
#let ligacao(l) = link(l.url, t(l.texto))

// Cabeçalho (idêntico ao do currículo)
#let p = dados.pessoal
#block(spacing: 0pt)[
  #set par(spacing: 0.5em)
  #text(size: 22pt, weight: "bold", t(p.nome))
  #v(2pt)
  #text(size: 11pt, fill: accent, t(p.titulo))
  #v(4pt)
  #set text(size: 9.5pt)
  #set par(leading: 0.7em)
  #link("mailto:" + p.email, p.email)#sep#t(p.telefone)#sep#t(p.localizacao) \
  #ligacao(p.linkedin)#sep#ligacao(p.github)#sep#ligacao(p.site)
]

#v(18pt)
#text(size: 9.5pt, fill: muted, t(carta.local_data))
#v(6pt)
#text(size: 12pt, weight: "bold", fill: accent, t(carta.assunto))
#v(4pt)

#par(t(carta.saudacao))
#for paragrafo in carta.paragrafos { par(t(paragrafo)) }

#v(6pt)
#par(justify: false)[#t(carta.despedida) \ *#t(p.nome)*]
