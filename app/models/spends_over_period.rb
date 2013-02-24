class SpendsOverPeriod
  include Mongoid::Document
  
  field :user, :type => String
  field :amount, :type => Float
  field :notes, :type => String
  field :created_at, :type => Time
  
  embedded_in :spend
  
  def get_user_name
    User.where(email: user).first.username
  end
  
  def get_user_gravatar
    User.where(email: user).first.gravatar_url
  end
  
end