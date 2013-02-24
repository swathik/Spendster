class InvalidDateFormat < StandardError; end
class InvalidPeriod < StandardError; end

class SpendPeriodsController < ApplicationController
  
  before_filter :find_record
  before_filter :find_spend_period, :only => [:destroy, :show]
  
  def new
  end
  
  def create
    start_date = params[:start_date_picker]
    end_date = params[:end_date_picker]
    raise InvalidPeriod if start_date.blank? || end_date.blank?
    raise InvalidDateFormat if end_date < start_date
    SpendPeriod.create(start_date: start_date, end_date: end_date, record_id: @record.id)
    head :created
  rescue InvalidPeriod, InvalidDateFormat => e
    if e.class == InvalidPeriod
      render_error("Please choose appropriate date range")
    elsif e.class == InvalidDateFormat
      render_error("Please choose end date in the future")
    end
  end
  
  def show
    @spends = Kaminari.paginate_array(@spends).page(params[:page]).per(10)
    
    @categories = @category_and_limits.inject([]) do |result, element|
      result << element.keys + ["#{element.keys.first}-#{element.values.first}"]
      result
    end
    spends = @spend_period.spends
    @data = []
    @data << ['Category', 'Spent']
    spends.each do |spend|
      @data << [spend.category_name, spend.total_spent(spend.category_name)]
    end
    filename = "#{@record.name}-spends.csv"
    respond_to do |format|
      format.html
      format.csv { send_data @spend_period.to_csv({:spend_period => @spend_period}), :filename => filename }
    end
    
  end
  
  def generate_report
    @spend_period = SpendPeriod.find(params[:spend_period_id])
    @spends = @spend_period.spends
    @data = []
    @data << ['Category', 'Spent']
    @spends.each do |spend|
      @data << [spend.category_name, spend.total_spent(spend.category_name)]
    end
  end
  
  def destroy
    @spend_period.destroy
    redirect_to record_path(@record)
  end
  
  private
  
    def find_record
      @record = Record.find(params[:record_id])
      @category_and_limits = @record.category_and_limits
    end
    
    def find_spend_period
      @spend_period = SpendPeriod.find(params[:id])
      @spends = @spend_period.spends
    end
    
    def render_error(message)
      render json: message, status: :bad_request
    end
end