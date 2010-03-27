require 'test_helper'

class Api::AssignmentsControllerTest < ActionController::TestCase
  
  test "index without login should be unauthorized" do    
    get :index, :format => "xml"
    
    assert_response 401
  end
  
  test "index should serialize assignments" do
    login_api
    
    get :index, :format => "xml"
    
    assert_response :success
    assert_not_nil assigns(:assignments)
    
    xml = Hash.from_xml(@response.body)
    assert_equal 3, xml["assignments"].length
  end
  
  test "show should serialize assignment record" do
    login_api
    
    get :show, :id => assignments(:ds10).id, :format => "xml"
    
    assert_response :success
    assert_not_nil assigns(:assignment)
  
    xml = Hash.from_xml(@response.body)
    assert_equal assignments(:ds10).id, xml["assignment"]["id"]
    assert_equal assignments(:ds10).date,     xml["assignment"]["date"]
    assert_equal assignments(:ds10).tag,      xml["assignment"]["tag"]
    assert_equal assignments(:ds10).text,     xml["assignment"]["text"]
    assert_equal assignments(:ds10).photos_count, xml["assignment"]["photos_count"]
    assert_not_nil xml["assignment"]["photos"]
  end

end
