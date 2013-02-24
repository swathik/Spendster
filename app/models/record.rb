class Record
  include Mongoid::Document
  
  field :name, :type => String
  field :user_emails, :type => Array
  field :currency, :type => String
  field :owner, :type => String
  field :category_and_limits, :type => Array
  
  has_many :spend_periods
  
  def shared?
    user_emails.count > 1
  end
  
  def self.to_csv(options = {})
    record = options[:record]
    CSV.generate do |csv|
      csv << ['Name']
      all.each do |r|
        csv << [r.name]
      end
    end
    if record
      CSV.generate do |csv|
        csv << [record.name]
        csv << ["\n"]
        csv << ["Category name, Category limit"]
        record.category_and_limits.each do |c|
          k = c.keys.first
          v = c.values.first
          csv << [k, v]
        end
        csv << ["\n"]
        csv << ["Time period"]
        csv << ["\n"]
        csv << ["Start date", "End date", "Total spent", "Total limit"]
        record.spend_periods.each do |s|
          start_date = Date.parse(s.start_date.to_s).strftime("%d %b %y")
          end_date = Date.parse(s.end_date.to_s).strftime("%d %b %y")
          csv << [start_date, end_date, s.total_spent, s.total_amount]
        end
      end
    end
  end
  
  def get_shared_users
    emails = user_emails.inject([]) do |result, element|
      email = User.where(email: element).first
      result << email.username if !email.nil?
      result
    end
  end
end