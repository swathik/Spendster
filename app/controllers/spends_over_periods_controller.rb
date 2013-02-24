class SpendsOverPeriodsController < ApplicationController
  
  before_filter :find_record_and_spend_and_spend_period, :only => [:destroy]
  
  def destroy
    spends_over_periods = @spend.spends_over_periods
    if spends_over_periods.size == 1
      @spend.destroy
    else
      spends_over_periods.find(params[:id]).delete
    end
    redirect_to record_spend_period_path(@record, @spend_period)
  end
  
  private
    def find_record_and_spend_and_spend_period
      @record = Record.find(params[:record_id])
      @spend = Spend.find(params[:spend_id])
      @spend_period = SpendPeriod.find(params[:spend_period_id])
    end
end
