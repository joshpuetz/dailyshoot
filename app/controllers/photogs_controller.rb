class PhotogsController < ApplicationController
  
  before_filter :set_cache_control, :only => [:index]
    
  def index
    @photogs = Photog.all_by_photos_count.paginate(:page => params[:page], :per_page => 50)
    @photog_count = Photog.count
  end
  
  def show
    @photog = Photog.find_by_screen_name(params[:id])
    
    unless @photog
      redirect_to photogs_url 
      return
    end
    
    @photos = @photog.photos.with_assignment.paginate(:page => params[:page], :per_page => 30)
  end
  
end
