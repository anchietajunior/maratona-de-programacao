# rbs_inline: enabled

# A entrega do Balão de um Problema resolvido, com quem entregou e quando (Art. 25).
class Delivery < ApplicationRecord
  belongs_to :user
  belongs_to :problem
  belongs_to :staff, class_name: "User", default: -> { Current.user }

  validates :user_id, uniqueness: { scope: :problem_id }
end
