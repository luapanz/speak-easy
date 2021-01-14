class EnrollController < ApplicationController

  def show

    begin
      @valid = true
      @invite = Invite.find(params[:id])
      @message = @invite.message.html_safe

      if @invite.expiration.present?
        now = DateTime.now
        if(now < @invite.expiration)
          @expired = false
        else
          @expired = true
        end
      else
        @expired = false
      end
    rescue
      @valid = false
    end
  end

end
