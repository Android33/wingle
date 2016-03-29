class User < ActiveRecord::Base

  has_one :userinfo
  has_one :nsetting
  has_one :fsetting
  has_many :pokes
  has_many :images
  has_many :favourites
  has_many :blockeds
  # u.lastchatseens
  has_many :lastchatseens
  has_many :notifications, foreign_key: 'receiver_id'
  has_and_belongs_to_many :chats

  acts_as_token_authenticatable

  def full_address
    "#{latitude}, #{longitude}"
  end
  geocoded_by :full_address   # can also be an IP address
  #  after_validation :geocode          # auto-fetch coordinates

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
