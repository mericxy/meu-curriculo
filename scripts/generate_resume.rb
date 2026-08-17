#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

source = ARGV.fetch(0, "curriculos/curriculo.yaml")
target = ARGV.fetch(1, "curriculo.tex")

def fail_with(message)
  warn "Erro ao gerar currículo: #{message}"
  exit 1
end

def required_hash(value, path)
  fail_with("#{path} deve ser um mapa") unless value.is_a?(Hash)
  value
end

def required_array(value, path)
  fail_with("#{path} deve ser uma lista não vazia") unless value.is_a?(Array) && !value.empty?
  value
end

def required_string(value, path)
  fail_with("#{path} deve ser um texto não vazio") unless value.is_a?(String) && !value.strip.empty?
  value.strip
end

def field(hash, key, path)
  required_string(hash[key], "#{path}.#{key}")
end

def tex_escape(value)
  replacements = {
    "\\" => "\\textbackslash{}",
    "{" => "\\{",
    "}" => "\\}",
    "$" => "\\$",
    "&" => "\\&",
    "#" => "\\#",
    "_" => "\\_",
    "%" => "\\%",
    "~" => "\\textasciitilde{}",
    "^" => "\\textasciicircum{}"
  }

  value.gsub(/[\\{}$&#_%~^]/, replacements).gsub(/\s+/, " ").strip
end

def tex_url(value, path)
  url = required_string(value, path)
  fail_with("#{path} contém caractere inválido para URL") if url.match?(/[{}\\]/)
  "\\detokenize{#{url}}"
end

def link(hash, path)
  data = required_hash(hash, path)
  url = tex_url(data["url"], "#{path}.url")
  label = tex_escape(field(data, "texto", path))
  "\\href{#{url}}{#{label}}"
end

def joined_sentence(values, path)
  items = required_array(values, path).each_with_index.map do |item, index|
    tex_escape(required_string(item, "#{path}[#{index}]"))
  end

  sentence = if items.length == 1
               items.first
             elsif items.length == 2
               items.join(" e ")
             else
               connector = items[-1].include?(" e ") ? ", " : " e "
               "#{items[0...-1].join(', ')}#{connector}#{items[-1]}"
             end
  sentence.match?(/[.!?]\z/) ? sentence : "#{sentence}."
end

begin
  data = YAML.safe_load(File.read(source, encoding: "UTF-8"), permitted_classes: [], permitted_symbols: [], aliases: false)
rescue Errno::ENOENT
  fail_with("arquivo #{source} não encontrado")
rescue Psych::SyntaxError => e
  fail_with("YAML inválido na linha #{e.line}: #{e.problem}")
end

root = required_hash(data, "raiz")
personal = required_hash(root["pessoal"], "pessoal")

email = field(personal, "email", "pessoal")
email_link = "\\href{#{tex_url("mailto:#{email}", 'pessoal.email')}}{#{tex_escape(email)}}"

lines = [
  "% Este arquivo é gerado por scripts/generate_resume.rb.",
  "% Edite #{File.basename(source)}, não este arquivo.",
  "",
  "\\resumeheader{#{tex_escape(field(personal, 'nome', 'pessoal'))}}" \
    "{#{tex_escape(field(personal, 'titulo', 'pessoal'))}}" \
    "{#{email_link}}" \
    "{#{tex_escape(field(personal, 'telefone', 'pessoal'))}}" \
    "{#{tex_escape(field(personal, 'localizacao', 'pessoal'))}}" \
    "{#{link(personal['linkedin'], 'pessoal.linkedin')}}" \
    "{#{link(personal['github'], 'pessoal.github')}}",
  "",
  "\\sectiontitle{Resumo Profissional}",
  "\\resumeparagraph{#{tex_escape(field(root, 'resumo', 'raiz'))}}",
  "",
  "\\sectiontitle{Competências Técnicas}"
]

required_array(root["competencias"], "competencias").each_with_index do |value, index|
  path = "competencias[#{index}]"
  skill = required_hash(value, path)
  lines << "\\skill{#{tex_escape(field(skill, 'categoria', path))}}{#{joined_sentence(skill['itens'], "#{path}.itens")}}"
end

lines << ""
lines << "\\sectiontitle{Experiência Profissional}"
required_array(root["experiencias"], "experiencias").each_with_index do |value, index|
  path = "experiencias[#{index}]"
  experience = required_hash(value, path)
  lines << "\\vspace{4pt}" unless index.zero?
  lines << "\\role{#{tex_escape(field(experience, 'cargo', path))}}" \
           "{#{tex_escape(field(experience, 'periodo', path))}}" \
           "{#{tex_escape(field(experience, 'organizacao', path))}}" \
           "{#{tex_escape(field(experience, 'localizacao', path))}}"
  required_array(experience["realizacoes"], "#{path}.realizacoes").each_with_index do |achievement, achievement_index|
    text = required_string(achievement, "#{path}.realizacoes[#{achievement_index}]")
    lines << "\\achievement{#{tex_escape(text)}}"
  end
end

lines << ""
lines << "\\sectiontitle{Projetos}"
required_array(root["projetos"], "projetos").each_with_index do |value, index|
  path = "projetos[#{index}]"
  project = required_hash(value, path)
  title = tex_escape(field(project, "nome", path))
  project_links = required_array(project["links"], "#{path}.links").each_with_index.map do |project_link, link_index|
    link(project_link, "#{path}.links[#{link_index}]")
  end
  title = "#{title} | #{project_links.join(' | ')}"
  subtitle = if project.key?("subtitulo")
               tex_escape(field(project, "subtitulo", path))
             else
               required_array(project["tecnologias"], "#{path}.tecnologias").each_with_index.map do |technology, technology_index|
                 tex_escape(required_string(technology, "#{path}.tecnologias[#{technology_index}]"))
               end.join(", ")
             end
  description = tex_escape(field(project, "descricao", path))
  lines << "\\project{#{title}}{#{subtitle}}{#{description}}"
  lines << "" unless index == root["projetos"].length - 1
end

lines << ""
lines << "\\sectiontitle{Educação}"
required_array(root["educacao"], "educacao").each_with_index do |value, index|
  path = "educacao[#{index}]"
  education = required_hash(value, path)
  lines << "\\vspace{4pt}" unless index.zero?
  lines << "\\role{#{tex_escape(field(education, 'curso', path))}}" \
           "{#{tex_escape(field(education, 'periodo', path))}}" \
           "{#{tex_escape(field(education, 'instituicao', path))}}" \
           "{#{tex_escape(field(education, 'localizacao', path))}}"
end

lines << ""
lines << "\\sectiontitle{Idiomas}"
required_array(root["idiomas"], "idiomas").each_with_index do |value, index|
  path = "idiomas[#{index}]"
  language = required_hash(value, path)
  lines << "\\resumelanguage{#{tex_escape(field(language, 'idioma', path))}}{#{tex_escape(field(language, 'nivel', path))}}"
end

if root.key?("informacoes_adicionais")
  lines << ""
  lines << "\\sectiontitle{Informações Adicionais}"
  required_array(root["informacoes_adicionais"], "informacoes_adicionais").each_with_index do |value, index|
    path = "informacoes_adicionais[#{index}]"
    information = required_hash(value, path)
    title = tex_escape(field(information, "titulo", path))
    value = tex_escape(field(information, "valor", path))
    lines << "\\resumeparagraph{#{title}: #{value}}"
  end
end

output = "#{lines.join("\n")}\n"
File.write(target, output, mode: "w", encoding: "UTF-8")
