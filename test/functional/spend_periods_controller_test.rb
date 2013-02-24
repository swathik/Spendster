require_relative '../test_helper'

class SpendPeriodsControllerTest < ActionController::TestCase
  
  def setup
    @user = Factory(:user)
    @record = Factory(:record, name: 'September', 
                     category_and_limits: [{ 'Food' => 100 }], 
                     user_ids: [@user.id])
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
    should 'create a monthly spend period' do
      post :create, { start_date_picker: '2012-11-10', end_date_picker: '2012-12-10', record_id: @record.id }
      assert_equal 1, @record.spend_periods.count
    end
    
    should 'display error message if dates are empty' do
      post :create, {
        start_date_picker: '',
        end_date_picker: '',
        record_id: @record.id
      }
      assert_equal response.body, 'Please choose appropriate date range'
      assert_equal 0, @record.spend_periods.count
    end
    
    should 'display error message if end date is past start date' do
      post :create, {
        start_date_picker: '2012-11-10',
        end_date_picker: '2012-10-10',
        record_id: @record.id
      }
      assert_equal response.body, 'Please choose end date in the future'
      assert_equal 0, @record.spend_periods.count
    end
  end
  
  context 'DELETE' do
    should 'be able to delete the spend period' do
      @spend_period = Factory(:spend_period, record_id: @record.id, type: 'Monthly',
                              :start_date => Time.now, :end_date => (Time.now + 1.month))
      post :destroy, { id: @spend_period.id, record_id: @record.id }
      assert_redirected_to record_path(@record)
      assert_equal 0, @record.spend_periods.count
    end
  end
end