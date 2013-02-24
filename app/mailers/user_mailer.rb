class UserMailer < ActionMailer::Base
  default :from => "notifications@example.com"
 
  def testing_foo(email)
    @emails = emails
    mail(:to => emails, :subject => "Spendster Report")
  end
end
