# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  avatar_file_name       :string
#  avatar_content_type    :string
#  avatar_file_size       :bigint
#  avatar_updated_at      :datetime
#

class User < ApplicationRecord
  attr_accessor :login
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable
  validates :name, presence: true, uniqueness: { case_sensitive: false}

  validates_format_of :name, with: /^[a-zA-Z0-9_¥]*$/, multiline: true
  validate :validate_name
  has_attached_file :avatar, styles: {midium: '300*300>', thumb: '100*100>'}, default_url: '/missing.png'
  validates_attachment_content_type :avatar, content_type: %r{¥image¥/.*¥z}

   def login=(login)
   	@login = login
   end

   def login
   	@login || self.name || self.email
   end

   def validate_name
   	errors.add(:name, :invalid) if User.where(email: name).exists?
   end

   def self.find_for_database_authentication(warden_conditions)
   	conditions = warden_conditions.dup
   	conditions[:email].downcase! if conditions[:email]
   	login = conditions.delete(:login)

   	where(conditions.to_hash).where(
   		['lower(name) = :value OR lower(email) = :value',
   			{ value: login.downcase }]
   	).first
   end
end
