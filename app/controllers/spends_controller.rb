class SpendsController < ApplicationController
  
  before_filter :find_record, :only => [:new, :create, :destroy]
  before_filter :find_spend_period, :only => [:create, :destroy]
  
  def new
  end
  
  def create
    category_name_and_limits = params[:categories].split('-')
    @existing_spend = check_if_spend_already_exists(category_name_and_limits.first)
    if @existing_spend.nil?
      spend = Spend.create(category_name: category_name_and_limits.first, 
                           category_limit: category_name_and_limits.last,
                           spend_period_id: @spend_period.id)
      spend.spends_over_periods.create(notes: params[:notes], 
                                       amount: params[:amount], 
                                       user: current_user.email, 
                                       created_at: Time.now)
    else
      @existing_spend.spends_over_periods.create(notes: params[:notes],
                                                 amount: params[:amount],
                                                 user: current_user.email,
                                                 created_at: Time.now)
    end
    redirect_to record_spend_period_path(@record, @spend_period)
  end
  
  def destroy
    @spend = Spend.find(params[:id])
    @spend.delete
    redirect_to record_spend_period_path(@record, @spend_period)
    
  end
  
  private
  
    def find_record
      @record = Record.find(params[:record_id])
      @category_and_limits = @record.category_and_limits
    end
    
    def find_spend_period
      @spend_period = SpendPeriod.find(params[:spend_period_id])
    end
    
    def check_if_spend_already_exists(name)
      Spend.where(category_name: name, spend_period_id: @spend_period.id).first
    end
  
end