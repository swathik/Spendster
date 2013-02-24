class Spend
  include Mongoid::Document
  
  field :category_name, :type => String
  field :category_limit, :type => Float
  embeds_many :spends_over_periods
  
  belongs_to :spend_period
  
  def total_spent(category_name)
    total_amount = self.spends_over_periods.map{ |v| v.amount }
    add_up_amount(total_amount)
  end
  
  def add_up_amount(array_amount)
    amount = 0
    array_amount.each { |t| amount = t + amount }
    amount
  end

end