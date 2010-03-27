require 'test_helper'

class Api::PhotogsControllerTest < ActionController::TestCase
  
  test "index via API should return photogs" do
    login_api
    
    get :index, :format => "xml"
    
    assert_response :success
    assert_not_nil assigns(:photogs)
    
    xml = Hash.from_xml(@response.body)
    assert_equal 1, xml["photogs"].length
  end


  test "show via API should return photog record" do
    login_api
    
    get :show, :id => photogs(:joe).screen_name, :format => "xml"
    
    assert_response :success
    assert_not_nil assigns(:photog)
  
    xml = Hash.from_xml(@response.body)
    assert_equal photogs(:joe).id, xml["photog"]["id"]
    assert_equal photogs(:joe).screen_name, xml["photog"]["screen_name"]
    assert_equal photogs(:joe).profile_image_url, xml["photog"]["profile_image_url"]
    assert_equal photogs(:joe).photos_count, xml["photog"]["photos_count"]
    assert_not_nil xml["photog"]["photos"]
  end
  
end
