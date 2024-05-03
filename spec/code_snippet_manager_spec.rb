require_relative '../lib/code_snippet_manager'
require 'stringio'

RSpec.describe CodeSnippetManager do
  let(:cli) { CodeSnippetManager.new }
  let(:storage) { instance_double(SnippetStorage) }

  before do
    allow(SnippetStorage).to receive(:new).and_return(storage)
  end

  context "when adding a new snippet" do
    it "successfully adds a snippet when title and multi-line code are provided" do
      allow($stdin).to receive(:gets).and_return("Example Title", "Line 1", "Line 2", "EOF")
      # Specify that the argument should be a single hash
      expect(storage).to receive(:add_snippet).with({title: "Example Title", code: "Line 1\nLine 2", tags: []})
      expected_output = "Enter the title of the snippet (cannot be empty):\n" +
                        "Enter the code (end with 'EOF' on a new line):\n" +
                        "Snippet added successfully.\n"
      expect { cli.add }.to output(expected_output).to_stdout
    end

    it "does not add a snippet if the title is empty" do
      allow($stdin).to receive(:gets).and_return("")
      expect(storage).not_to receive(:add_snippet)
      expect { cli.add }.to output("Enter the title of the snippet (cannot be empty):\nTitle cannot be empty.\n").to_stdout
    end

    it "does not add a snippet if the code is empty" do
      allow($stdin).to receive(:gets).and_return("Example Title", "EOF")
      expect(storage).not_to receive(:add_snippet)
      expect { cli.add }.to output("Enter the title of the snippet (cannot be empty):\nEnter the code (end with 'EOF' on a new line):\nCode cannot be empty.\n").to_stdout
    end
  end

  context "when listing snippets" do
    it "lists available snippets" do
      allow(storage).to receive(:all_snippets).and_return([{ 'title' => 'Title 1', 'code' => 'Code 1' }, { 'title' => 'Title 2', 'code' => 'Code 2' }])
      output = "1: Title 1\nCode 1\n\n2: Title 2\nCode 2\n\n"
      expect { cli.list }.to output(output).to_stdout
    end

    it "prints an error if no snippets are available" do
      allow(storage).to receive(:all_snippets).and_return([])
      expect { cli.list }.to output("No snippets found.\n").to_stdout
    end
  end

  context "when searching for snippets" do
    it "displays matching snippets" do
      allow(storage).to receive(:all_snippets).and_return([{ 'title' => 'Keyword Title', 'code' => 'Relevant code snippet' }])
      expected_output = "1: Keyword Title\nRelevant code snippet\n\n"
      expect { cli.search("Keyword") }.to output(expected_output).to_stdout
    end

    it "displays a message if no matching snippets are found" do
      allow(storage).to receive(:all_snippets).and_return([])
      expect { cli.search("Nonexistent") }.to output("No snippets found.\n").to_stdout
    end

    it "alerts if the search keyword is empty" do
      expect { cli.search("") }.to output("Search keyword cannot be empty.\n").to_stdout
    end
  end
end
