class SpendPeriod
  include Mongoid::Document
  
  field :type, :type => String
  field :start_date, :type => Time
  field :end_date, :type => Time
  field :archived, :type => Boolean, :default => false
  
  belongs_to :record
  has_many :spends
  
  def total_spent
    total = []
    spends.each do |spend|
      spend.spends_over_periods.each do |s|
        total << s.amount.to_f
      end
    end
    add_up_amount(total)
  end
  
  def total_amount
    total = record.category_and_limits.inject([]) do |r, e| 
      r << e.values.first
      r
    end
    add_up_amount(total)
  end
  
  def add_up_amount(array_amount)
    amount = 0
    array_amount.each { |t| amount = t + amount }
    amount
  end
  
  def get_user_name(user)
    User.where(email: user).first.username
  end
  
  def to_csv(options = {})
    spend_period = options[:spend_period]
    CSV.generate do |csv|
      start_date = Date.parse(spend_period.start_date.to_s)
      end_date = Date.parse(spend_period.end_date.to_s)
      csv << ["Spends"]
      csv << ["Start date", "End date"]
      csv << [start_date, end_date]
      csv << ["Total spent:", spend_period.total_spent]
      csv << ["\n"]
      spend_period.spends.each do |spend|
        csv << [spend.category_name, spend.category_limit]
        csv << ["\n"]
        csv << ["Amount spent", "Notes", "Added on", "Users"]
        spend.spends_over_periods.each do |sp|
          date = Date.parse(sp.created_at.to_s).strftime("%d %b %y")
          username = get_user_name(sp.user)
          csv << [sp.amount, sp.notes, date, username]
        end
        csv << ["\n"]
      end
    end
  end
end