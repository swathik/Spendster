require_relative '../test_helper'

class SpendsControllerTest < ActionController::TestCase

  def setup
    @user = Factory(:user)
    @record = Factory(:record, name: 'September', 
                     category_and_limits: [{ 'Food' => 100 }], 
                     user_ids: [@user.id])
    @spend_period = Factory(:spend_period, record_id: @record.id, type: 'Monthly',
                             :start_date => Time.now, :end_date => (Time.now + 1.month))
    sign_in @user
    super
  end

  teardown :clean_mongodb
  def clean_mongodb
     Mongoid.default_session.collections.each do |collection|
       unless collection.name =~ /^system\./
         collection.drop
       end
    end
  end
  
  context 'POST Create' do
    should 'create a new spend' do
      post :create, {
        categories: 'Food-100',
        amount: '20',
        notes: 'tesco',
        spend_period_id: @spend_period.id,
        record_id: @record.id
      }
      assert_equal 1, @spend_period.spends.count
    end
    
    should 'add spends over period if spend already exists and not create new spend' do
      data = {amount: '20', notes: 'asda', user: @user.email, created_at: Time.now }
      @spend = Factory(:spend, spend_period_id: @spend_period.id, category_name: 'Food', category_limit: 100,
                       :spends_over_periods => [data])
      post :create, {
        categories: 'Food-100',
        amount: '20',
        notes: 'asda',
        spend_period_id: @spend_period.id,
        record_id: @record.id,
        id: @spend.id
      }
      assert_equal 1, @spend_period.spends.count
      assert_equal @spend.id, @spend_period.spends.first.id
      assert_equal 1, @spend.spends_over_periods.count
    end
  end
end

  