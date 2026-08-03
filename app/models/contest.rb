class Contest < ApplicationRecord
  has_many :problems, dependent: :destroy
end
