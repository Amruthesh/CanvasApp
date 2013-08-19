class HomeController < ApplicationController
  
  before_filter :from_fb, except: [:unavailable, :authorize]
  after_filter :allow_iframe
  
  def index
  end
  
  def step_two
  end
  
  def authorize
  end
  
  private
  
  def allow_iframe
    response.headers["X-Frame-Options"] = "GOFORIT"
  end
  
end
