class RecordNameCannotBeBlank < StandardError; end
class CategoryNameCannotBeBlank < StandardError; end
class EmailInvalid < StandardError; end
class EmailDoesNotExist < StandardError; end

class RecordsController < ApplicationController
  
  before_filter :find_record, :only => [:edit, :update, :show, :destroy]
  before_filter :all_records, :only => [:index, :show]
  before_filter :find_budget_data, :only => [:create, :update]

  def index
    user = User.find(current_user.id)
    respond_to do |format|
      format.html
      format.csv { send_data @records.to_csv}
    end
  end
  
  def new
  end
  
  def create
    raise RecordNameCannotBeBlank if params[:name].blank?
    category_and_limits = []
    @category_limits.each do |key, element|
      raise CategoryNameCannotBeBlank if element[:name].blank?
      element[:limit] = element[:limit].blank? ? 0 : element[:limit].to_f
      category_and_limits << Hash[*element.values]
    end
    
    shared_emails = validate_emails(@emails)    
    user_emails = [current_user.email ] + [shared_emails]
    record = Record.create(name: @name, 
                           user_emails: user_emails.flatten, 
                           category_and_limits: category_and_limits,
                           currency: params[:currency],
                           owner: current_user.id)
    render json: {id: record.id}, head: :created
  rescue RecordNameCannotBeBlank, CategoryNameCannotBeBlank, EmailInvalid, EmailDoesNotExist => e
    error_messages(e)
  end
  
  def show
    @category_names_limits = @record.category_and_limits
    @user_emails = @record.user_emails
    @user_emails.compact
    
    @spend_periods = @record.spend_periods
    filename = "#{@record.name}.csv"
    respond_to do |format|
      format.html
      format.csv { send_data @records.to_csv({:record => @record}), :filename => filename }
    end
  end
  
  def edit
    @category_names_limits = @record.category_and_limits
    @user_emails = @record.user_emails - [current_user.email]
    @user_emails.compact
  end
  
  def update
    raise RecordNameCannotBeBlank if @name.blank?
    category_and_limits = []
    @category_limits.each do |key, element|
      raise CategoryNameCannotBeBlank if element[:name].blank?
      element[:limit] = element[:limit].blank? ? 0 : element[:limit].to_f
      category_and_limits << Hash[*element.values]
    end
    shared_emails = []
    if params[:emails].nil?
      @record.user_emails.each do |email|
        shared_emails << email unless email == current_user.email
      end
    else
      shared_emails = validate_emails(emails)
    end
    user_emails = [current_user.email ] + [shared_emails]
    record_attributes = { name: @name,
                          user_emails: user_emails.flatten,
                          category_and_limits: category_and_limits}
    @record.update_attributes(record_attributes)
    render json: {id: @record.id}, head: :created
  rescue RecordNameCannotBeBlank, CategoryNameCannotBeBlank, EmailInvalid, EmailDoesNotExist => e
    error_messages(e)
  end
  
  def destroy
    @record.delete
    redirect_to records_path
  end
  
  private
  
    def find_record
      @record = Record.find(params[:id])
    end
    
    def render_error(message)
      render json: message, status: :bad_request
    end
    
    def is_email_valid?(email)
      email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    end
    
    def all_records
      @records = Record.where(user_emails: current_user.email)
    end

    def error_messages(e)
      if e.class == RecordNameCannotBeBlank
        render_error("Please enter budget name")
      elsif e.class == CategoryNameCannotBeBlank
        render_error("Please enter category name")
      elsif e.class == EmailInvalid
        render_error("Please enter valid email address")
      elsif e.class == EmailDoesNotExist
        render_error("User does not exist in the system, please try again")
      end
    end

    def validate_emails(emails)
      shared_emails = []
      emails.each do |email|
        unless email.blank?
          raise EmailInvalid if is_email_valid?(email).nil?
          user_email = User.where(email: email).first
          raise EmailDoesNotExist if user_email.nil?
          shared_emails << user_email.email
        end
      end
    end

    def find_budget_data
      @name = params[:name]
      @category_limits = params[:category_limits]
      @emails = params[:emails].values
    end
end
