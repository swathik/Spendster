# require_relative '../test_helper'
# 
# class ArchiveTest < ActiveSupport::TestCase
#   
#   def setup
#     @user = Factory(:user)
#     sign_in @user
#     super
#   end
#   
#   teardown :clean_mongodb
#   def clean_mongodb
#      Mongoid.default_session.collections.each do |collection|
#        unless collection.name =~ /^system\./
#          collection.drop
#        end
#     end
#   end
#   
#   context "Schedule task" do
#     require 'debugger'; debugger
#     @record = Factory(:record, name: 'September', 
#                      category_and_limits: [{ 'Food' => 100 }], 
#                      user_ids: [@user.id])
#     @spend_period = Factory(:spend_period, record_id: @record.id, type: 'Monthly',
#                              :start_date => Time.now - 1.month, :end_date => (Time.now))
#                              
#     data = {amount: '20', notes: 'asda', user: @user.id, created_at: Time.now }
#     @spend = Factory(:spend, spend_period_id: @spend_period.id, category_name: 'Food', category_limit: 100,
#                      :spends_over_periods => [data])
#     
#     should "move from spends to archive after the time period" do
#       archive = Archive.add_spends_to_archive
#       assert_equal 1, Archive.all.count
#       assert_equal 0, @record.spend_periods.count
#     end
#   end
# 
# end
