module SessionsHelper

  def sign_in(user)
    session[:user_id] = user.objectId

    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id] rescue nil

    if (@current_user == nil && session[:user_id] != nil)
      session[:user_id] = nil
    end

    @current_user
  end

  def signed_in?
    !current_user.nil?
  end

  def is_agent?
    current_user.role == Role::AGENT
  end

  def is_owner?
    current_user.role == Role::OWNER
  end

  def is_upper_management?
    case current_user.role
    when Role::AGENT
      return false
    when Role::FRIEND
      return false
    else
      return true
    end
  end
end
