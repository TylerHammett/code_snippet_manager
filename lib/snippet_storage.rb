require 'json'

class SnippetStorage
  def initialize(file = 'snippets.json')
    @file = file
    @snippets = load_snippets
  end

  def load_snippets
    if File.exist?(@file)
      JSON.parse(File.read(@file))
    else
      []
    end
  rescue JSON::ParserError
    puts "Warning: Data file is corrupted. Starting with an empty snippet list."
    []
  rescue IOError => e
    puts "Error reading from file: #{e.message}"
    []
  end

  def add_snippet(snippet)
    @snippets.push(snippet)
    save_snippets
  end

  def all_snippets
    @snippets
  end

  def save_snippets
    File.open(@file, 'w') do |f|
      f.write(JSON.pretty_generate(@snippets))
    end
  rescue IOError => e
    puts "Error writing to file: #{e.message}"
  end
end
