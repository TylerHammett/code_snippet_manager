require 'thor'
require 'tty-prompt'
require_relative 'snippet_storage'

class CodeSnippetManager < Thor
  def initialize(*args)
    super
    @storage = SnippetStorage.new
    @prompt = TTY::Prompt.new
  end

  desc "add", "Add a new code snippet. Prompts you for title, code, and optional tags."
  def add
    title = prompt_for_input("Enter the title of the snippet (cannot be empty):")
    return puts "Title cannot be empty." if title.empty?

    puts "Enter the code (end with 'EOF' on a new line):"
    code = capture_multiline_input
    return puts "Code cannot be empty." if code.empty?

    tags = prompt_for_input("Enter tags (comma-separated):").split(',').map(&:strip)

    snippet = { title: title, code: code, tags: tags }
    @storage.add_snippet(snippet)
    puts "Snippet added successfully."
  end

  desc "edit", "Edit an existing snippet. Select by index to modify its title or code."
  def edit
    list
    index = prompt_for_index("Enter the index of the snippet you want to edit:")
    return if index.nil?

    snippet = @storage.all_snippets[index]
    title = @prompt.ask("Enter a new title or hit enter to keep current:", default: snippet['title'])
    code = @prompt.ask("Enter new code or hit enter to keep current:", default: snippet['code'])

    snippet['title'] = title
    snippet['code'] = code

    @storage.save_snippets
    puts "Snippet updated successfully."
  end

  desc "delete", "Delete an existing snippet."
  def delete
    list
    index = prompt_for_index("Enter the index of the snippet you want to delete:")
    return if index.nil?

    @storage.all_snippets.delete_at(index)
    @storage.save_snippets
    puts "Snippet deleted successfully."
  end

  desc "list", "List all snippets"
  def list
    snippets = @storage.all_snippets
    if snippets.empty?
      puts "No snippets found."
    else
      snippets.each_with_index do |snippet, index|
        puts "#{index + 1}: #{snippet['title']}\n#{snippet['code']}\n\n"
      end
    end
  rescue => e
    puts "Failed to list snippets: #{e.message}"
  end

  desc "search", "Search snippets by keyword"
  def search(keyword, regex: false)
    return puts "Search keyword cannot be empty." if keyword.to_s.strip.empty?

    results = @storage.all_snippets.select do |snippet|
      pattern = regex ? Regexp.new(keyword) : /#{Regexp.escape(keyword)}/i
      (snippet['title'] && snippet['title'].match?(pattern)) ||
      (snippet['code'] && snippet['code'].match?(pattern))
    end
    display_search_results(results)
  end

  private

  def prompt_for_input(prompt)
    @prompt.ask(prompt)
  end

  def prompt_for_index(prompt)
    index = @prompt.ask(prompt, convert: :int) rescue nil 
    return index - 1 if index && index.between?(1, @storage.all_snippets.size)

    puts "Invalid index."
    nil
  end

  def capture_multiline_input
    code_lines = []
    while (line = $stdin.gets) && line.strip != 'EOF'
      code_lines << line.rstrip
    end
    code_lines.join("\n")
  end

  def search_snippet?(snippet, keyword)
    [snippet['title'], snippet['code']].compact.any? { |text| text.include?(keyword) }
  end

  def display_search_results(results)
    if results.empty?
      puts "No snippets found."
    else
      results.each_with_index do |snippet, index|
        puts "#{index + 1}: #{snippet['title']}\n#{snippet['code']}\n\n"
      end
    end
  end
end
