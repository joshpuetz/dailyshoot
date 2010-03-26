require 'test_helper'

class PhotoTest < ActiveSupport::TestCase

  test "tweet without a URL should not be exceptional" do
    tweet = "I've kept 3 shots for today's @dailyshoot. Can't decide which one to use."
    photos = Photo.all_from_tweet(tweet)
    
    assert_equal 0, photos.size
  end

  test "tweet with URL that isn't a photo should not assign photo" do
    tweet = "Check out http://dailyshoot.com"
    photos = Photo.all_from_tweet(tweet)

    assert_equal 0, photos.size
  end
  
  test "tweet with short URL that doesn't expand to a photo should not assign photo" do
    tweet = "http://bit.ly/5msIMo"
    photos = Photo.all_from_tweet(tweet)

    assert_equal 0, photos.size
  end
  
  test "tweet with invalid URL should ignore it" do
    tweet = "My first assignment: Water http://bi.. http://bit.ly/6Jp0el"
    url   = "http://www.flickr.com/photos/bg/4131881234/"
    thumb = "http://farm3.static.flickr.com/2589/4131881234_1cb6f072ca_s.jpg"
        
    assert_photo(tweet, url, thumb)
  end

  test "tweet with two photo URLs should assign two photos with url and thumb url" do
    tweet   = "Two @dailyshoot shots: http://flic.kr/p/7hVTxV and http://flic.kr/p/7hZKAJ"
    url_1   = "http://flic.kr/p/7hVTxV"
    thumb_1 = "http://farm3.static.flickr.com/2499/4129718895_2037cd7074_s.jpg"
    url_2   = "http://flic.kr/p/7hZKAJ"
    thumb_2 = "http://farm3.static.flickr.com/2774/4130472594_e7a3519f6b_s.jpg"
    
    photos = Photo.all_from_tweet(tweet)
    assert_equal 2, photos.size
    
    assert_equal url_1, photos[0].url
    assert_equal thumb_1, photos[0].thumb_url

    assert_equal url_2, photos[1].url
    assert_equal thumb_2, photos[1].thumb_url
  end
    
  test "tweet with bestc.am URL" do
    tweet  = "@dailyshoot #ds1 http://bestc.am/oGuf"
    url    = "http://bestc.am/oGuf"
    thumb  = "http://s3.amazonaws.com/cjapps/images/143131/thumb.jpg"
    medium = "http://s3.amazonaws.com/cjapps/images/143131/iphone.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end
  
  test "tweet with yfrog URL" do
    tweet  = "@dailyshoot #ds1 http://yfrog.com/4izptj"
    url    = "http://yfrog.com/4izptj"
    thumb  = "http://img162.imageshack.us/img162/6803/zpt.th.jpg"
    medium = "http://img162.imageshack.us/img162/6803/zpt.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end
  
  test "tweet with twitpic URL" do
    tweet  = "@dailyshoot #ds1 http://twitpic.com/qosz0"
    url    = "http://twitpic.com/qosz0"
    thumb  = "http://twitpic.com/show/thumb/qosz0"
    
    assert_photo(tweet, url, thumb, thumb)
  end

  test "tweet with tweetphoto URL" do
    tweet  = "@dailyshoot #ds1 http://tweetphoto.com/4898853"
    url    = "http://tweetphoto.com/4898853"
    thumb  = "http://cdn.cloudfiles.mosso.com/c54112/app4645111258411056.jpg"
    medium = "http://cdn.cloudfiles.mosso.com/c54102/app4645111258411056.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end
  
  test "tweet with imgur URL" do
    tweet  = "@dailyshoot #ds1 http://imgur.com/TRxN1.jpg"
    url    = "http://imgur.com/TRxN1.jpg"
    thumb  = "http://i.imgur.com/TRxN1s.jpg"
    
    assert_photo(tweet, url, thumb, thumb)
  end
  
  test "tweet with snaptweet URL" do
    tweet  = "@dailyshoot #ds1 http://snaptweet.com/03c12"
    url    = "http://snaptweet.com/03c12"
    thumb  = "http://farm3.static.flickr.com/2754/4117367227_d82460f234_s.jpg"
    medium = "http://farm3.static.flickr.com/2754/4117367227_d82460f234.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end
  
  test "tweet with flickr.com URL" do
    tweet  = "@dailyshoot #ds1 http://www.flickr.com/photos/clarkware/4131620353/"
    url    = "http://www.flickr.com/photos/clarkware/4131620353/"
    thumb  = "http://farm3.static.flickr.com/2662/4131620353_51affbc130_s.jpg"
    medium = "http://farm3.static.flickr.com/2662/4131620353_51affbc130.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end

  test "tweet with flic.kr URL" do
    tweet  = "@dailyshoot #ds1 http://flic.kr/p/7iDPb7"
    url    = "http://flic.kr/p/7iDPb7"
    thumb  = "http://farm3.static.flickr.com/2609/4137898878_2874643ebd_s.jpg"
    medium = "http://farm3.static.flickr.com/2609/4137898878_2874643ebd.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end

  test "tweet with flickr static URL" do
    tweet = "@dailyshoot #ds1 http://farm5.static.flickr.com/4036/4243576772_91ee986470_o.jpg"
    url   = "http://farm5.static.flickr.com/4036/4243576772_91ee986470_o.jpg"
    thumb = "http://farm5.static.flickr.com/4036/4243576772_cc4e890299_s.jpg"
    medium = "http://farm5.static.flickr.com/4036/4243576772_cc4e890299.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end

  test "tweet with flic.kr URL with no medium image should default to thumb URL" do
    tweet = "@dailyshoot #ds1 http://www.flickr.com/photos/46600585@N03/4283473824/"
    url   = "http://www.flickr.com/photos/46600585@N03/4283473824/"
    thumb = "http://farm5.static.flickr.com/4037/4283473824_eb4b5b864e_s.jpg"

    assert_photo(tweet, url, thumb, thumb)
  end
  
  test "tweet with flickr set URL should not assign a photo" do
    tweet = "@dailyshoot #ds1 http://flickr.com/ari/sets/72157622699478909/"
    photos = Photo.all_from_tweet(tweet)
    
    assert_equal 0, photos.size
  end
  
  test "tweet with smugmug URL" do
    tweet = "@dailyshoot #ds1 http://bluecamel.smugmug.com/Photography/dailyshoot/10469863_EdveS#748954599_NUvea"
    url   = "http://bluecamel.smugmug.com/Photography/dailyshoot/10469863_EdveS#748954599_NUvea"
    thumb = "http://bluecamel.smugmug.com/Photography/dailyshoot/DSC0717/748954599_NUvea-Ti.jpg"
    medium = "http://bluecamel.smugmug.com/Photography/dailyshoot/DSC0717/748954599_NUvea-M.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end

  test "tweet with twitgoo URL" do
    tweet = "@dailyshoot #ds1 http://twitgoo.com/crlg5"
    url   = "http://twitgoo.com/crlg5"
    thumb = "http://i46.tinypic.com/10fti7t_th.jpg"
    medium = "http://i46.tinypic.com/10fti7t.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end

  test "tweet with twitsnaps URL" do
    tweet = "@dailyshoot #ds1 http://twitsnaps.com/full_size.php?img_id=413"
    url   = "http://twitsnaps.com/full_size.php?img_id=413"
    thumb = "http://twitsnaps.com/share/thumbnail/413_SunriseAug2004.jpg"
    medium = "http://twitsnaps.com/share/fullphoto/413_SunriseAug2004.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end

  test "tweet with 365project URL" do
    tweet = "@dailyshoot #ds1 http://365project.org/mom2preteens/365/2010-03-14"
    url   = "http://365project.org/mom2preteens/365/2010-03-14"
    thumb = "http://media.365project.org/1/116876_defhimoprx_sq.jpg"
    medium = "http://media.365project.org/1/116876_defhimoprx_m.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end
  
  test "tweet with zenfolio URL" do
    tweet = "@dailyshoot #ds1 http://madeleine.zenfolio.com/p481334483/h187d9b98"
    url   = "http://madeleine.zenfolio.com/p481334483/h187d9b98"
    thumb = "http://www.zenfolio.com//img/v7/p410885016-1.jpg"
    medium = "http://www.zenfolio.com//img/v7/p410885016-2.jpg"
    
    assert_photo(tweet, url, thumb, medium)
  end
  
  # Shortened URLs
  
  test "tweet with bit.ly URL" do
    tweet  = "@dailyshoot #ds1 http://bit.ly/8lfTwJ"
    url    = "http://www.flickr.com/photos/clarkware/4131620353/"
    thumb  = "http://farm3.static.flickr.com/2662/4131620353_51affbc130_s.jpg"

    assert_photo(tweet, url, thumb)
  end
  
  test "tweet with tinyurl URL" do
    tweet  = "@dailyshoot #ds1 http://tinyurl.com/yd9kgxn"
    url    = "http://www.flickr.com/photos/clarkware/4193699212/"
    thumb  = "http://farm3.static.flickr.com/2596/4193699212_147e5a576e_s.jpg"

    assert_photo(tweet, url, thumb)
  end
  
  test "tweet with ow.ly URL" do
    tweet  = "@dailyshoot #ds1 http://ow.ly/WEJw"
    url    = "http://www.flickr.com/photos/sutterview/4275570878/"
    thumb  = "http://farm5.static.flickr.com/4006/4275570878_e3ee7201c3_s.jpg"

    assert_photo(tweet, url, thumb)
  end
  
  test "tweet with j.mp URL" do
    tweet  = "@dailyshoot #ds1 http://j.mp/7zgpjd"
    url    = "http://www.flickr.com/photos/ejknapp/4131597128/in/pool-1251121@N24"
    thumb  = "http://farm3.static.flickr.com/2565/4131597128_e04154164f_s.jpg"

    assert_photo(tweet, url, thumb)
  end
            
protected
  
  def assert_photo(tweet, url, thumb, medium=nil)
    photos = Photo.all_from_tweet(tweet)
    
    assert_equal 1, photos.size
    
    photo = photos.first
    
    assert_equal url, photo.url
    assert_equal thumb, photo.thumb_url
    assert_equal medium, photo.medium_url if medium
  end

end
