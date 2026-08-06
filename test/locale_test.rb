require "test_helper"

# Uma chave repetida no YAML não é erro de sintaxe: a última vence em silêncio, e um rótulo
# que virou namespace passa a renderizar o hash inteiro na tela. Foi assim que
# "{destroyed: ...}" apareceu no botão de excluir Caso de Teste.
class LocaleTest < ActiveSupport::TestCase
  test "no key is declared twice" do
    document = Psych.parse_file(Rails.root.join("config/locales/pt-BR.yml"))

    assert_empty duplicated_keys(document.children.first)
  end

  private
    def duplicated_keys(node, path = [])
      if node.is_a?(Psych::Nodes::Mapping)
        seen = Set.new

        node.children.each_slice(2).flat_map do |key, value|
          here = path + [ key.value ]
          repeated = seen.add?(key.value) ? [] : [ here.join(".") ]

          repeated + duplicated_keys(value, here)
        end
      else
        []
      end
    end
end
