class AssignmentsController < ApplicationController
  
  before_filter :admin_required, :except => [:index, :show]
  before_filter :set_cache_control, :only => [:index, :show]
  
  def index
    @assignments = Assignment.published_with_photos.paginate(:page => params[:page], :per_page => 30)
  
    respond_to do |format|
      format.html
      format.rss
    end
  end

  def show
    @assignment = Assignment.published.find_by_position(params[:id])
    unless @assignment
      redirect_to assignments_url
      return
    end
    
    all_photos = @assignment.photos.with_photog
    
    @photo_count = all_photos.size
    @photos = all_photos.paginate(:page => params[:page], :per_page => 30)
    
  rescue ActiveRecord::StatementInvalid
    redirect_to assignments_url
  end

# ADMIN ONLY

  def upcoming
    @first_upcoming_position = Assignment.first_upcoming_position
    @assignments = Assignment.upcoming
  end

  def new
    @assignment = Assignment.new
  end

  def edit
    @assignment = Assignment.find_by_position(params[:id])
  end

  def create
    @assignment = Assignment.new(params[:assignment])
    
    if @assignment.save
      flash[:notice] = 'Assignment was successfully created.'
      redirect_to upcoming_assignments_url
    else
      render :action => "new"
    end
  end

  def update
    @assignment = Assignment.find_by_position(params[:id])

    if @assignment.update_attributes(params[:assignment])
      flash[:notice] = 'Assignment was successfully updated.'
      redirect_to upcoming_assignments_url        
    else
      render :action => "edit"
    end
  end

  def destroy
    @assignment = Assignment.find_by_position(params[:id])
    @assignment.destroy
    flash[:notice] = 'Assignment was successfully deleted.'
    redirect_to upcoming_assignments_url
  end
  
  def reorder
    @assignment = Assignment.find_by_position(params[:id])
    @assignment.move(params[:direction])
    redirect_to upcoming_assignments_url
  end
  
end
