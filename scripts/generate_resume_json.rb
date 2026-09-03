#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "yaml"

PORTUGUESE_SOURCE = ARGV.fetch(0, "curriculos/curriculo.yaml")
ENGLISH_SOURCE = ARGV.fetch(1, "curriculos/curriculo-en.yaml")
TARGET = ARGV.fetch(2, "dist/api/v1/curriculo.json")

def fail_with(message)
  warn "Erro ao gerar API do curriculo: #{message}"
  exit 1
end

def required_hash(value, path)
  fail_with("#{path} deve ser um mapa") unless value.is_a?(Hash)
  value
end

def required_array(value, path)
  fail_with("#{path} deve ser uma lista nao vazia") unless value.is_a?(Array) && !value.empty?
  value
end

def required_string(value, path)
  fail_with("#{path} deve ser um texto nao vazio") unless value.is_a?(String) && !value.strip.empty?
  value.strip
end

def field(hash, key, path)
  required_string(hash[key], "#{path}.#{key}")
end

def load_yaml(source, locale)
  YAML.safe_load(
    File.read(source, encoding: "UTF-8"),
    permitted_classes: [],
    permitted_symbols: [],
    aliases: false
  )
rescue Errno::ENOENT
  fail_with("arquivo #{source} nao encontrado para #{locale}")
rescue Psych::SyntaxError => e
  fail_with("YAML invalido em #{source}, linha #{e.line}: #{e.problem}")
end

def project_link(value, path)
  link = required_hash(value, path)
  {
    "url" => field(link, "url", path),
    "label" => field(link, "texto", path)
  }
end

def project_resume(data, locale)
  root = required_hash(data, locale)
  personal = required_hash(root["pessoal"], "#{locale}.pessoal")

  {
    "personal" => {
      "name" => field(personal, "nome", "#{locale}.pessoal"),
      "headline" => field(personal, "titulo", "#{locale}.pessoal"),
      "email" => field(personal, "email", "#{locale}.pessoal"),
      "phone" => field(personal, "telefone", "#{locale}.pessoal"),
      "location" => field(personal, "localizacao", "#{locale}.pessoal"),
      "links" => {
        "linkedin" => project_link(personal["linkedin"], "#{locale}.pessoal.linkedin"),
        "github" => project_link(personal["github"], "#{locale}.pessoal.github"),
        "site" => project_link(personal["site"], "#{locale}.pessoal.site")
      }
    },
    "summary" => field(root, "resumo", locale),
    "skills" => required_array(root["competencias"], "#{locale}.competencias").each_with_index.map do |value, index|
      path = "#{locale}.competencias[#{index}]"
      skill = required_hash(value, path)
      {
        "category" => field(skill, "categoria", path),
        "items" => required_array(skill["itens"], "#{path}.itens").each_with_index.map do |item, item_index|
          required_string(item, "#{path}.itens[#{item_index}]")
        end
      }
    end,
    "experience" => required_array(root["experiencias"], "#{locale}.experiencias").each_with_index.map do |value, index|
      path = "#{locale}.experiencias[#{index}]"
      experience = required_hash(value, path)
      {
        "role" => field(experience, "cargo", path),
        "period" => field(experience, "periodo", path),
        "organization" => field(experience, "organizacao", path),
        "location" => field(experience, "localizacao", path),
        "highlights" => required_array(experience["realizacoes"], "#{path}.realizacoes").each_with_index.map do |item, item_index|
          required_string(item, "#{path}.realizacoes[#{item_index}]")
        end
      }
    end,
    "projects" => required_array(root["projetos"], "#{locale}.projetos").each_with_index.map do |value, index|
      path = "#{locale}.projetos[#{index}]"
      project = required_hash(value, path)
      {
        "name" => field(project, "nome", path),
        "links" => required_array(project["links"], "#{path}.links").each_with_index.map do |link, link_index|
          project_link(link, "#{path}.links[#{link_index}]")
        end,
        "technologies" => required_array(project["tecnologias"], "#{path}.tecnologias").each_with_index.map do |item, item_index|
          required_string(item, "#{path}.tecnologias[#{item_index}]")
        end,
        "description" => field(project, "descricao", path)
      }
    end,
    "education" => required_array(root["educacao"], "#{locale}.educacao").each_with_index.map do |value, index|
      path = "#{locale}.educacao[#{index}]"
      education = required_hash(value, path)
      {
        "course" => field(education, "curso", path),
        "period" => field(education, "periodo", path),
        "institution" => field(education, "instituicao", path),
        "location" => field(education, "localizacao", path)
      }
    end,
    "languages" => required_array(root["idiomas"], "#{locale}.idiomas").each_with_index.map do |value, index|
      path = "#{locale}.idiomas[#{index}]"
      language = required_hash(value, path)
      {
        "language" => field(language, "idioma", path),
        "level" => field(language, "nivel", path)
      }
    end
  }
end

def validate_locale_parity(portuguese, english)
  %w[skills experience projects education languages].each do |section|
    next if portuguese[section].length == english[section].length

    fail_with("pt-BR.#{section} e en.#{section} devem ter a mesma quantidade de itens")
  end

  %w[email phone].each do |field_name|
    next if portuguese["personal"][field_name] == english["personal"][field_name]

    fail_with("personal.#{field_name} deve ser igual nos dois idiomas")
  end

  %w[linkedin github site].each do |link_name|
    portuguese_url = portuguese.dig("personal", "links", link_name, "url")
    english_url = english.dig("personal", "links", link_name, "url")
    fail_with("personal.links.#{link_name}.url deve ser igual nos dois idiomas") unless portuguese_url == english_url
  end

  portuguese["experience"].each_with_index do |experience, index|
    next if experience["highlights"].length == english["experience"][index]["highlights"].length

    fail_with("experiencia #{index} deve ter a mesma quantidade de realizacoes nos dois idiomas")
  end

  portuguese["projects"].each_with_index do |project, index|
    english_project = english["projects"][index]
    fail_with("projeto #{index} deve ter a mesma quantidade de links nos dois idiomas") unless project["links"].length == english_project["links"].length
    fail_with("projeto #{index} deve ter as mesmas tecnologias nos dois idiomas") unless project["technologies"] == english_project["technologies"]

    project["links"].each_with_index do |link, link_index|
      next if link["url"] == english_project["links"][link_index]["url"]

      fail_with("URL do projeto #{index}, link #{link_index}, deve ser igual nos dois idiomas")
    end
  end
end

portuguese = project_resume(load_yaml(PORTUGUESE_SOURCE, "pt-BR"), "pt-BR")
english = project_resume(load_yaml(ENGLISH_SOURCE, "en"), "en")
validate_locale_parity(portuguese, english)

commit = ENV.fetch("GITHUB_SHA", "local").strip
commit = "local" if commit.empty?

document = {
  "schemaVersion" => 1,
  "profile" => "software",
  "source" => {
    "repository" => "mericxy/meu-curriculo",
    "commit" => commit
  },
  "defaultLocale" => "pt-BR",
  "locales" => {
    "pt-BR" => portuguese,
    "en" => english
  }
}

FileUtils.mkdir_p(File.dirname(TARGET))
File.write(TARGET, "#{JSON.pretty_generate(document)}\n", mode: "w", encoding: "UTF-8")
