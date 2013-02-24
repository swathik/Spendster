require_relative '../test_helper'

class RecordsControllerTest < ActionController::TestCase
  
  def setup
    @user = Factory(:user)
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

  context 'GET index' do
    should 'display a link to create record' do
      get :index
      assert_select 'a.accordion-toggle', /create Budget List/i
    end
    
    should 'display a list of all the records' do
      record = Factory(:record, name: 'First record', 
                       category_and_limits: { 'Food' => 100 }, 
                       user_ids: [@user.id])
      get :index
    end
  end
  
  context 'POST create' do
    should 'be able to create a new record without user emails' do
      post :create, {
        name: 'record one',
        emails: {"0" => ""},
        category_limits: {"0"=>{"name"=>"Food", "limit"=>"200"}}
      }
      assert_equal 1, Record.all.count
    end
    
    should 'be able to create new record with existing user emails' do
      @second_user = Factory(:user, email: 'seconduser@test.com')
      post :create, {
        name: 'December',
        emails: {"0" => 'seconduser@test.com'},
        category_limits: {"0"=>{"name"=>"Water", "limit"=>"200"}}
      }
      record = Record.all.last
      user_id = @second_user.id
      assert_equal true, record.user_ids.include?(user_id)
    end
    
    should 'display error message if record name is nil' do
      post :create, {
        name: '',
        emails: {"0" => ""},
        category_limits: {"0"=>{"name"=>"Food", "limit"=>"200"}}
      }
      assert_equal response.body, "Please enter record name"
      assert_equal 0, Record.all.count
    end
    
    should 'display error message if category name is nil' do
      post :create, {
        name: 'September',
        emails: {'0' => ''},
        category_limits: {'0' => { 'name' => '', 'limit' => ''}}
      }
      assert_equal response.body, 'Please enter category name'
      assert_equal 0, Record.all.count
    end
    
    should 'display error message if email is invalid' do
      post :create, {
        name: 'September',
        emails: {'0' => 'invalid'},
        category_limits: {'0' => { 'name' => 'Food', 'limit' => '100'}}
      }
      assert_equal response.body, 'Please enter valid email address'
      assert_equal 0, Record.all.count
    end
    
    should 'display error message if email id does not exist' do
      post :create, {
        name: 'September',
        emails: {'0' => 'someone@email.com'},
        category_limits: {'0' => { 'name' => 'Food', 'limit' => '100'}}
      }
      assert_equal response.body, 'User does not exist in the system, please try again'
      assert_equal 0, Record.all.count
    end
    
    should 'create record when limits are not nil or invalid with value as zero' do
      post :create, {
        name: 'record one',
        emails: {"0" => ""},
        category_limits: {"0"=>{"name"=>"Food", "limit"=>""}}
      }
      record = Record.all.last
      assert_equal [{"Food" => 0}], record.category_and_limits
    end
    
    should 'create record when limits are not nil or invalid with value as zero' do
      post :create, {
        name: 'record one',
        emails: {"0" => ""},
        category_limits: {"0"=>{"name"=>"Food", "limit"=>"invalid"}}
      }
      record = Record.all.last
      assert_equal [{"Food" => 0}], record.category_and_limits
    end
  end
  
  context 'GET show' do
    should 'display record' do
      record = Factory(:record, name: 'First record', 
                       category_and_limits: [{ 'Food' => 100 }], 
                       user_ids: [@user.id])
      get :show, id: record.id
      assert_select 'p small', /#{@user.email}/
    end
  end
  
  context 'PUT update' do
    should 'edit all fields' do
      @second_user = Factory(:user, email: 'seconduser@test.com')
      @record = Factory(:record, name: 'June', 
                       category_and_limits: { 'Food' => 100 }, 
                       user_ids: [@user.id])
      put :update, { id: @record.id, 
                     name: 'October', 
                     emails: {"0" => "seconduser@test.com"}, 
                     category_limits: {'0' => {'name' => 'Water', 'limit' => '200'}} }
      assert_equal 'October', @record.reload.name
      assert_equal [{'Water' => 200}], @record.reload.category_and_limits
      assert_equal [@user.id, @second_user.id], @record.user_ids.flatten
    end
    
    should 'be to add new category name and limits' do
      @record = Factory(:record, name: 'June', 
                       category_and_limits: { 'Food' => 100 }, 
                       user_ids: [@user.id])
      put :update, { id: @record.id, 
                     name: 'June', 
                     emails: {"0" => ""}, 
                     category_limits: {'0' => {'name' => 'Water', 'limit' => '200'}, 
                                       '1' => {'name' => 'Bills', 'limit' => '300'} } }
      assert_equal [{'Water' => 200}, {'Bills' => 300}], @record.reload.category_and_limits
    end
  end
  
  context 'DELETE' do
    should 'destroy record' do
      @record = Factory(:record, name: 'June', 
                       category_and_limits: { 'Food' => 100 }, 
                       user_ids: [@user.id])
      post :destroy, { id: @record.id }
      assert_redirected_to records_path
    end
  end

end
