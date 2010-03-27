require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  
  test "index should load assignments and render page" do
    get :index
    assert_not_nil assigns(:assignments)
    assert_response :success
    assert_template "assignments/index"
  end
  
  test "show a published assignment should load assignment and render page" do
    get :show, :id => assignments(:ds10).to_param
    assert_equal assignments(:ds10), assigns(:assignment)
    assert_response :success
    assert_template "assignments/show"
  end

  test "show an unpublished assignment should redirect" do
    get :show, :id => assignments(:upcoming_1).to_param
    assert_response :redirect
    assert_redirected_to assignments_url
  end

  test "upcoming should redirect to login when non-admin requests it" do
    get :upcoming
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "upcoming should load assignments and render page" do
    login_admin
    get :upcoming
    assert_not_nil assigns(:assignments)
    assert_response :success
    assert_template "assignments/upcoming"
  end

  test "new should redirect to login when non-admin requests it" do
    get :new
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  test "new should render page" do
    login_admin
    get :new
    assert_response :success
    assert_template "assignments/new"
  end

  test "create should redirect to login when non-admin requests it" do
    post :create, :assignment => { }
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  test "create should create assignment and redirect" do
    login_admin
    assert_difference('Assignment.count') do
      post :create, 
           :assignment => {:text => "Text", :tag => "tag", :date => Time.now}
    end
    assert_redirected_to upcoming_assignments_url
  end

  test "edit should redirect to login when non-admin requests it" do
    get :edit, :id => assignments(:ds10).to_param
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  test "edit should load assignment and render page" do
    login_admin
    get :edit, :id => assignments(:ds10).to_param
    assert_equal assignments(:ds10), assigns(:assignment)
    assert_response :success
    assert_template "assignments/edit"
  end

  test "update should redirect to login when non-admin requests it" do
    put :update, :id => assignments(:ds10).to_param
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  test "update should change assignment and redirect" do
    login_admin
    put :update, :id => assignments(:ds10).to_param, 
                 :assignment => { :text => "new text" }
    assert_equal "new text", assignments(:ds10, :reload).text
    assert_redirected_to upcoming_assignments_url
  end

  test "destroy should redirect to login when non-admin requests it" do
    delete :destroy, :id => assignments(:ds10).to_param
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  test "destroy should remove assignment and redirect" do
    login_admin
    assert_difference('Assignment.count', -1) do
      delete :destroy, :id => assignments(:ds10).to_param
    end

    assert_redirected_to upcoming_assignments_path
  end
  
  test "reorder should reorder assignment and redirect" do
    login_admin
    assert_equal 5, assignments(:upcoming_2).position
    get :reorder, :id => assignments(:upcoming_2).to_param, :direction => 'up'
    assert_equal 4, assignments(:upcoming_2, :reload).position
    assert_redirected_to upcoming_assignments_path
  end
  
end
