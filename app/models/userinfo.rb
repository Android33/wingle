class Userinfo < ActiveRecord::Base
  belongs_to :user

  before_create :generate_uid

  def generate_uid
    begin
      wingle_id = SecureRandom.hex(5)
      #   12 chars of 0..9, a..f
    end while Userinfo.where(:wingle_id => wingle_id).exists?
    self.wingle_id = wingle_id
  end
end
