class Api::PhotogsController < Api::BaseController
  
  def index
    @photogs = Photog.all_by_photos_count
    
    respond_to do |format|
      format.xml  { render :xml  => @photogs }
      format.json { render :json => @photogs }
    end
  end
  
  def show
    @photog = Photog.find_by_screen_name(params[:id])
    
    unless @photog
      redirect_to api_photogs_url 
      return
    end
    
    @photos = @photog.photos.with_assignment
        
    respond_to do |format|
      format.xml  { render :xml  => @photog.to_xml(:include => :photos) }
      format.json { render :json => @photog.to_json(:include => :photos) }
    end
  end
  
end