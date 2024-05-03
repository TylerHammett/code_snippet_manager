# spec/code_snippet_manager_spec.rb

require_relative '../lib/code_snippet_manager'

RSpec.describe CodeSnippetManager do
  context "when adding a new snippet" do
    it "should prompt the user to enter details" do
      expect { CodeSnippetManager.new.invoke(:add) }.to output(/Adding a new snippet.../).to_stdout
    end
  end
end
