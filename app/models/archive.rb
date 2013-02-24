class Archive
  include Mongoid::Document
  
  field :record_name, :type => String
  field :user_emails, :type => Array
  field :start_date, :type => Time
  field :end_date, :type => Time
  field :spends, :type => Array
  field :total_spent, :type => Integer
  field :currency, :type => String
  
  def self.add_spends_to_archive
    all_records = Record.all
    all_records.each do |record|
      record.spend_periods.each do |spend_period|
        spends = []
        spend_result = {}
        spend_period.spends.each do |spend|
          spends_over_period = spend.spends_over_periods.collect do |e|
            spend_result = spend_result.merge( {
              :user => e.user, :amount => e.amount, :notes => e.notes, :created_at => e.created_at })
          end

          spends << { category_name: spend.category_name,
                      category_limit: spend.category_limit,
                      spends_over_period: spends_over_period }
        end
        if (spend_period.end_date == Date.today) && !(spend_period.archived?)
          data = {
            record_name: record.name,
            user_emails: record.user_emails,
            currency: record.currency,
            start_date: spend_period.start_date,
            end_date: spend_period.end_date,
            spends: spends,
            total_spent: spend_period.total_spent
          }
          self.create(data)
          spend_period.spends.destroy
          spend_period.update_attributes(:archived => true)
        end
      end
    end
  end
  
  def get_users(user_emails)
    emails = user_emails.inject([]) do |result, element|
      result << User.where(email: element).first.username
      result
    end
  end
  
  def get_user_name(email)
    User.where(email: email).first.username
  end
end
