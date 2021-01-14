class CallActionsController < ApplicationController
  def new
    @call_action = CallAction.new
  end
end
