// Layout do currículo em Typst. Lê o YAML diretamente, sem gerador intermediário.
// Design padrão: 11pt, margem 1.7cm, seções sem filetes, hierarquia por tamanho, cor e espaço.
// Uso: make software / make geral (veja o Makefile). A skill tailor-resume compila este mesmo arquivo.

#let dados = yaml("/" + sys.inputs.at("dados", default: "curriculos/curriculo.yaml"))

#let accent = rgb("#1F4E79")
#let textgray = rgb("#2B2B2B")
#let muted = rgb("#5A5A5A")

#set document(title: dados.pessoal.nome + " - Currículo", author: dados.pessoal.nome)
#set page(paper: "a4", margin: 1.7cm, fill: white)
#set text(font: "Latin Modern Sans", size: 11pt, lang: "pt", region: "BR", fill: textgray, hyphenate: false)
#set par(leading: 0.5em, spacing: 0.5em, justify: true)
#show link: set text(fill: accent)
// Palavras com hífen (pip-audit, type-check) não quebram na linha: em pt o Typst repetiria o hífen
// ("pip-" / "-audit") e a extração ATS devolveria a palavra errada.
#show regex("\S+-\S+"): it => box(it)

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

#let sep = text(fill: muted)[#h(0.4em)|#h(0.4em)]

#let secao(titulo) = block(above: 11pt, below: 6pt, text(size: 12pt, weight: "bold", fill: accent, titulo))

#let papel(titulo, periodo, organizacao, local) = {
  par(justify: false)[*#t(titulo)*#sep#text(size: 9.5pt, fill: muted, t(periodo))]
  par(justify: false, text(size: 9.5pt, fill: muted)[_#t(organizacao)_#sep;_#t(local)_])
}

#let ligacao(l) = link(l.url, t(l.texto))

#let marcador(corpo) = par(hanging-indent: 1em)[– #corpo]

// Cabeçalho
#let p = dados.pessoal
#block(spacing: 0pt)[
  #text(size: 22pt, weight: "bold", t(p.nome))
  #v(2pt)
  #text(size: 11pt, fill: accent, t(p.titulo))
  #v(4pt)
  #set text(size: 9.5pt)
  #set par(leading: 0.7em)
  #link("mailto:" + p.email, p.email)#sep#t(p.telefone)#sep#t(p.localizacao) \
  #ligacao(p.linkedin)#sep#ligacao(p.github)#sep#ligacao(p.site)
]

#secao[Resumo Profissional]
#t(dados.resumo)

#secao[Experiência Profissional]
#for (i, e) in dados.experiencias.enumerate() {
  if i > 0 { v(7pt) }
  papel(e.cargo, e.periodo, e.organizacao, e.localizacao)
  v(2pt)
  for r in e.realizacoes { marcador(t(r)) }
}

#secao[Projetos]
#for (i, pr) in dados.projetos.enumerate() {
  if i > 0 { v(5pt) }
  let subtitulo = if "subtitulo" in pr { t(pr.subtitulo) } else { pr.tecnologias.map(t).join(", ") }
  par(justify: false)[*#t(pr.nome) | #pr.links.map(ligacao).join(" | ")*]
  par(justify: false, text(size: 9.5pt, fill: muted, subtitulo))
  par(t(pr.descricao))
}

#secao[Competências Técnicas]
#set par(spacing: 0.65em)
#for c in dados.competencias {
  par[*#t(c.categoria):* #frase(c.itens)]
}
#set par(spacing: 0.5em)

#secao[Educação]
#for (i, ed) in dados.educacao.enumerate() {
  if i > 0 { v(5pt) }
  papel(ed.curso, ed.periodo, ed.instituicao, ed.localizacao)
}

#secao[Idiomas]
#dados.idiomas.map(l => [#t(l.idioma): #t(l.nivel)]).join(sep)

#if "informacoes_adicionais" in dados [
  #secao[Informações Adicionais]
  #dados.informacoes_adicionais.map(x => [#t(x.titulo): #t(x.valor)]).join(linebreak())
]
