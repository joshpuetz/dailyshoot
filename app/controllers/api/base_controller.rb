class Api::BaseController < ApplicationController
  
  before_filter :api_user_required
  
end
