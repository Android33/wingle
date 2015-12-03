class User < ActiveRecord::Base

	acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
	has_many :donations
  has_many :favorites
	has_many :rpayments
  belongs_to :church

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
