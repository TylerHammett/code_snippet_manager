require 'thor'
require_relative 'snippet_storage'

class CodeSnippetManager < Thor
  def initialize(*args)
    super
    @storage = SnippetStorage.new
  end

  desc "add", "Add a new code snippet"
  def add
    puts "Enter the title of the snippet (cannot be empty):"
    title = $stdin.gets.strip
    return puts "Title cannot be empty." if title.empty?

    puts "Enter the code (end with 'EOF' on a new line):"
    code_lines = []
    while (line = $stdin.gets) && line.strip != 'EOF'
      code_lines << line.rstrip
    end
    code = code_lines.join("\n")

    return puts "Code cannot be empty." if code.empty?

    snippet = { title: title, code: code, tags: [] }
    @storage.add_snippet(snippet)
    puts "Snippet added successfully."
  end

  desc "list", "List all snippets"
  def list
    snippets = @storage.all_snippets
    if snippets.empty?
      puts "No snippets found."
    else
      snippets.each_with_index do |snippet, index|
        title = snippet['title']
        code = snippet['code']
        puts "#{index + 1}: #{title}"
        puts code
        puts
      end
    end
  rescue => e
    puts "Failed to list snippets: #{e.message}"
  end

  desc "search", "Search snippets by keyword"
  def search(keyword)
    return puts "Search keyword cannot be empty." if keyword.to_s.strip.empty?

    results = @storage.all_snippets.select do |snippet|
      (snippet['title'] && snippet['title'].include?(keyword)) || (snippet['code'] && snippet['code'].include?(keyword))
    end
    if results.empty?
      puts "No snippets found."
    else
      results.each_with_index do |snippet, index|
        title = snippet['title']
        code = snippet['code']
        puts "#{index + 1}: #{title}"
        puts code
        puts
      end
    end
  end
end
