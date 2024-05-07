require 'rouge'

module SyntaxHighlightHelper
  def highlight(code)
    formatter = Rouge::Formatters::Terminal256.new
    lexer = Rouge::Lexers::Ruby.new  # Assuming Ruby syntax
    formatter.format(lexer.lex(code))
  end
end
