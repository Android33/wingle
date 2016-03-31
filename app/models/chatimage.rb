class Chatimage < ActiveRecord::Base
  belongs_to :chat

  mount_uploader :img, ChatimageUploader
end
