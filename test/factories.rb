Factory.sequence(:record_name) { |n| "Record #{n}"}
Factory.sequence(:user_emails){ |n| "user#{n}@test.com"}
Factory.sequence(:username){ |n| "user#{n}"}

Factory.define :user do |u|
  u.username            { Factory.next(:username) }
  u.email               { Factory.next(:user_emails) }
  u.password              "password"
  u.password_confirmation "password"
end

Factory.define :record do |r|
  r.name { Factory.name(:record_name) }
end

Factory.define :spend_period do |s|
end

Factory.define :spend do |s|
  s.spends_over_periods { Factory.build(:spends_over_period) }
end

Factory.define :spends_over_period do |s|
end