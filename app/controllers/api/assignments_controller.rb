class Api::AssignmentsController < Api::BaseController

  def index
    @assignments = Assignment.published
  
    respond_to do |format|
      format.xml  { render :xml  => @assignments }
      format.json { render :json => @assignments }
    end
  end

  def show    
    @assignment = Assignment.published_with_photos.find_by_id(params[:id])
    
    unless @assignment
      redirect_to api_assignments_url
      return
    end
        
    respond_to do |format|
      format.xml  { render :xml  => @assignment.to_xml(:include => :photos) }
      format.json { render :json => @assignment.to_json(:include => :photos) }
    end
  rescue ActiveRecord::StatementInvalid
    redirect_to api_assignments_url
  end

end
