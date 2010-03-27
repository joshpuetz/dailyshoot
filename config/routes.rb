ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'welcome'
  map.faq 'faq', :controller => 'welcome', :action => 'faq'

  map.resources :assignments, 
                :has_many => :photos, 
                :collection => { :upcoming => :get },
                :member => { :reorder => :get }
                
  map.resources :mentions, 
                :member => { :parse => :post },
                :collection => { :bulk_destroy => :post}
                
  map.resources :photos, :member => { :regenerate => :post }
  map.resources :photogs
  map.resource  :session
  map.resources :suggestions, :member => { :thanks => :get }
  
  map.with_options(:controller => 'sessions') do |sessions|
    sessions.login  'login',  :action => 'new'
    sessions.logout 'logout', :action => 'destroy'
  end
  
  map.with_options(:controller => 'mobile') do |mobile|
    mobile.mobile_assignment 'mobile/assignment/:id', 
                             :action => 'assignment'
  end
  
  # API
  
  map.namespace(:api) do |api| 
    api.resources :assignments
    api.resources :photogs
  end

  #map.connect 'twitter/:action', :controller => 'twitter'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
