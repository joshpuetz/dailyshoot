require 'test_helper'

class PhotogTest < ActiveSupport::TestCase

  test "should use screen_name as the param" do
    assert_equal 'joe', photogs(:joe).to_param
  end
  
  test "create with blank screen_name should fail" do
    assert_no_difference "Photog.count" do
      photog = new_photog :screen_name => ""
      assert !photog.valid?
    end
  end

  test "identify with a new Twitter user should return new record" do
    twitter_user = stub_mentions.first.user
    photog = Photog.with_screen_name(twitter_user.screen_name)
    
    assert photog.new_record?
  end
  
  test "missing_assignments should return assignments photog doesn't have a picture for" do
    missing_assignments = photogs(:bob).missing_assignments
    assert missing_assignments.length == 1
    assert missing_assignments[0] = assignments(:today)
    
    missing_assignments = photogs(:jane).missing_assignments
    assert missing_assignments.length == 2
    assert missing_assignments.include?(assignments(:ds1))
    assert missing_assignments.include?(assignments(:ds10))
    assert !missing_assignments.include?(assignments(:today))    
  end

  test "identify with an existing Twitter should find existing record" do
    twitter_user = stub_mentions.first.user
    twitter_user.screen_name = photogs(:joe).screen_name
    photog = Photog.with_screen_name(twitter_user.screen_name)

    assert_equal photogs(:joe), photog
  end
  
private

  def new_photog(options={})
    options = {
      :screen_name        => "@screen_name",
      :profile_image_url  => "image url"
    }.merge(options)

    Photog.create(options)
  end

end
