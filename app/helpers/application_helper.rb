module ApplicationHelper
  
  def percent_of(n1, n2)
    n1.to_f / n2.to_f * 100.0
  end
  
  def currency
    {
      "USD" => "&#36;",
      "GBP" => "&pound;",
      "INR" => "&#8377;"
    }
  end
  
  def friendly_date(date)
    Date.parse(date).strftime("%d %b %y")
  end
  
  def total_amount(record)
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
end
