class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[line]

  has_many :items, dependent: :destroy
  has_many :categories, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }

  def self.find_or_create_from_omniauth(auth)
    if auth.present?
      prof = User.find_or_initialize_by(provider: auth["provider"], uid: auth["uid"])
      if prof.new_record?
          # deviseの挙動対策としてフェイクアドレスを作成
          email = auth["info"]["email"] ? auth["info"]["email"] : "#{auth["uid"]}-#{auth["provider"]}@example.com"
          prof.email = email
          prof.name =  auth["info"]["name"]
          prof.password = Devise.friendly_token[0, 20]
          prof.save!
      end
      prof
    end
  end
end
