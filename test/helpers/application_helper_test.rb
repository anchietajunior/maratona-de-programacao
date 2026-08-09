require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "a fenced example becomes a code block, not a paragraph" do
    assert_match %r{<pre><code>arara}, markdown("Exemplo:\n\n```\narara\n```")
  end

  test "an indented fence still becomes a code block" do
    assert_match %r{<pre><code>}, markdown("Exemplo:\n\n  ```\n  arara\n  ```")
  end
end
