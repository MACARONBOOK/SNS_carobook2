class Room < ApplicationRecord
  has_many :chats, dependent: :destroy
  has_many :entries, dependent: :destroy
end
