require_relative '../lib/code_snippet_manager'
require 'tty-prompt'
require 'stringio'

RSpec.describe CodeSnippetManager do
  let(:cli) { CodeSnippetManager.new }
  let(:storage) { instance_double(SnippetStorage) }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:snippets) {
    [
      {'title' => 'Original Title', 'code' => 'Original Code', 'tags' => []},
      {'title' => 'Second Snippet', 'code' => 'Second Code', 'tags' => []}
    ]
  }

  before do
    allow(SnippetStorage).to receive(:new).and_return(storage)
    allow(storage).to receive(:all_snippets).and_return(snippets)
    allow(storage).to receive(:save_snippets)
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  context "when adding a new snippet" do
    it "successfully adds a snippet when title and multi-line code are provided" do
      allow(prompt).to receive(:ask).with("Enter the title of the snippet (cannot be empty):").and_return("Example Title")
      allow(prompt).to receive(:ask).with("Enter tags (comma-separated):").and_return("tag1, tag2")
      allow($stdin).to receive(:gets).and_return("Line 1", "Line 2", "EOF")
      expected_snippet = {title: "Example Title", code: "Line 1\nLine 2", tags: ["tag1", "tag2"]}

      expect(storage).to receive(:add_snippet).with(expected_snippet)
      cli.add
    end

    it "does not add a snippet if the title is empty" do
      allow(prompt).to receive(:ask).with("Enter the title of the snippet (cannot be empty):").and_return("")
      expect(storage).not_to receive(:add_snippet)
      cli.add
    end

    it "does not add a snippet if the code is empty" do
      allow(prompt).to receive(:ask).with("Enter the title of the snippet (cannot be empty):").and_return("Example Title")
      allow(prompt).to receive(:ask).with("Enter tags (comma-separated):").and_return("")
      allow($stdin).to receive(:gets).and_return("EOF")
      expect(storage).not_to receive(:add_snippet)
      cli.add
    end
  end

  context "when editing a snippet" do
    it "successfully edits a snippet's title and code" do
      allow(prompt).to receive(:ask).with("Enter the index of the snippet you want to edit:", convert: :int).and_return(2)
      allow(prompt).to receive(:ask).with("Enter a new title or hit enter to keep current:", default: snippets[1]['title']).and_return("New Title")
      allow(prompt).to receive(:ask).with("Enter new code or hit enter to keep current:", default: snippets[1]['code']).and_return("New Code")
      expect(storage).to receive(:save_snippets)
      cli.edit
    end

    it "handles invalid index input gracefully" do
      allow(prompt).to receive(:ask).and_return(nil)  # Simulate invalid input
      expect { cli.edit }.to output(/Invalid index./).to_stdout
      expect(storage).not_to have_received(:save_snippets)
    end
  end

  context "when deleting a snippet" do
    it "successfully deletes a snippet given a valid index" do
      allow(prompt).to receive(:ask).with("Enter the index of the snippet you want to delete:", convert: :int).and_return(1)
      expect(storage).to receive(:save_snippets)
      cli.delete
    end

    it "does not delete any snippet if the index is invalid" do
      allow(prompt).to receive(:ask).with("Enter the index of the snippet you want to delete:", convert: :int).and_return(nil)
      expect(storage).not_to have_received(:save_snippets)
      cli.delete
    end
  end

  context "when listing snippets" do
    it "lists available snippets" do
      output = "1: Original Title\nOriginal Code\n\n2: Second Snippet\nSecond Code\n\n"
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
      allow(prompt).to receive(:ask).with("Search keyword cannot be empty.").and_return("Nonexistent")
      allow(storage).to receive(:all_snippets).and_return([])
      expect { cli.search("Nonexistent") }.to output("No snippets found.\n").to_stdout
    end
  end
end
