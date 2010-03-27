require 'test_helper'

class PhotogsControllerTest < ActionController::TestCase
  
  test "index should load photogs and render page" do
    get :index
    assert_not_nil assigns(:photogs)
    assert_response :success
    assert_template "photogs/index"
  end
  
  test "show should load photog and render page" do
    get :show, :id => photogs(:joe).to_param
    assert_equal photogs(:joe), assigns(:photog)
    assert_response :success
    assert_template "photogs/show"
  end
  
end
