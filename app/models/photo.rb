#
# Credit: Patrick Lenz (http://github.com/scoop)
# Credit: Urban Hafner (http://github.com/ujh)
#

require 'open-uri'

class Photo < ActiveRecord::Base
    
  validates_presence_of :url, :thumb_url
  
  belongs_to :assignment, :counter_cache => true
  belongs_to :photog, :counter_cache => true
      
  def self.most_recent(limit=30)
    find(:all, 
         :limit => limit,
         :order => 'tweeted_at desc',
         :joins => :photog, 
         :select => "photos.*, photogs.screen_name as photog_screen_name")
  end
  
  def self.all_from_tweet(tweet)
    photos = []
    urls = tweet.scan(/https?:\/\/\S+/).select do |url|
      begin
        URI.parse(url)
      rescue URI::InvalidURIError
        false
      end
    end
    urls.each do |url|
      photo = Photo.new(:url => url)
      if photo.update_image_urls.compact.any?
        photos << photo
      end
    end
    photos
  end
  
  def service
    case
      when self.url =~ /bestc\.am/
        {:name => "The Best Camera", :handler => :bestcam }
      when self.url =~ /twitpic\.com/
        {:name => "TwitPic", :handler => :twitpic }
      when self.url =~ /tweetphoto\.com/
        {:name => "TweetPhoto", :handler => :tweetphoto }
      when self.url =~ /yfrog\.com/
        {:name => "yFrog", :handler => :yfrog }
      when self.url =~ /farm\d\.static\.flickr\.com/
        {:name => "Flickr", :handler => :flickr_static }
      when self.url =~ /flickr\.com/
        {:name => "Flickr", :handler => :flickr }
      when self.url =~ /flic\.kr/
        {:name => "Flickr", :handler => :flickr }
      when self.url =~ /imgur\.com/
        {:name => "imgur", :handler => :imgur }
      when self.url =~ /snaptweet\.com/
        {:name => "SnapTweet", :handler => :snaptweet }
      when self.url =~ /smugmug\.com/
        {:name => "SmugMug", :handler => :smugmug }
      when self.url =~ /twitgoo\.com/
        {:name => "Twitgoo", :handler => :twitgoo }
      when self.url =~ /twitsnaps\.com/
        {:name => "TwitSnaps", :handler => :twitsnaps }
      when self.url =~ /zenfolio\.com/
        {:name => "Zenfolio", :handler => :zenfolio }
      when self.url =~ /365project\.org/
        {:name => "365 Project", :handler => :three_sixty_five_project }
      else {}
    end
  end
    
  def update_image_urls    
    image_urls = if service[:handler]
      send(service[:handler])
    else 
      expanded_url = ShortURL.new(self.url).expand
      if expanded_url != self.url
        self.url = expanded_url
        update_image_urls
      else
        []
      end
    end
    if image_urls.any?
      self.thumb_url = image_urls[0]
      self.medium_url = image_urls[1]
    else
      self.thumb_url = nil
      self.medium_url = nil
    end
    [self.thumb_url, self.medium_url]
  rescue => e
    self.thumb_url = '/images/no-photo.png'
    self.medium_url = nil
    raise ThumbRetrievalError.new(e, self.url)
  end
  
  class ThumbRetrievalError < StandardError
    attr_accessor :original_exception, :url
    def initialize(original_exception, url)
      self.original_exception, self.url = original_exception, url
    end

    def to_s
      "%s raised %s" % [ url, original_exception ]
    end
  end

protected
    
  def bestcam
    doc = Nokogiri::HTML(open(self.url))
    medium = doc.css('#main-content .photo img').first['src']    
    thumb = medium.gsub(/iphone/, 'thumb')   
    [thumb, medium]
  end
  
  def twitpic
    thumb = self.url.gsub(/(\w+)$/, 'show/thumb/\1')
    [thumb, thumb]
  end

  def tweetphoto
    api_url = "http://TweetPhotoAPI.com/api/TPAPI.svc/imagefromurl?size=thumbnail&url="
    thumb = open(api_url + self.url) { |f| f.base_uri.to_s }
    api_url = "http://TweetPhotoAPI.com/api/TPAPI.svc/imagefromurl?size=medium&url="
    medium = open(api_url + self.url) { |f| f.base_uri.to_s }
    [thumb, medium]
  end
  
  def yfrog
    if self.url =~ %r(/([\w\d]+)$)
      photo_id = $1
    else
      return [nil, nil]
    end
    
    api_url = "http://yfrog.com/api/xmlInfo?path="
    doc = Nokogiri::XML(open(api_url + photo_id))
    thumb = doc.css('thumb_link').first.text
    medium = doc.css('image_link').first.text
    [thumb, medium]
  end

  def twitgoo
    if self.url =~ %r(/([\w\d]+)$)
      photo_id = $1
    else
      return [nil, nil]
    end
    
    api_url = "http://twitgoo.com/api/message/info/"
    
    doc = Nokogiri::XML(open(api_url + photo_id))
    if doc.xpath('/rsp/@status').first.value == "ok"
      thumb = doc.xpath("//thumburl").first.text
      medium = doc.xpath("//imageurl").first.text
    else
      raise "Twitgoo API failed"
    end
    [thumb, medium]
  end
  
  def imgur
    uri = URI.parse(self.url)
    uri.host = 'i.imgur.com'
    uri.path.gsub!(/\.(\w+)/, 's.\1')
    thumb = "http://#{uri.host}#{uri.path}"
    [thumb, thumb]
  end
  
  def snaptweet
    doc = Nokogiri::HTML(open(self.url))
    flickr_static_url = doc.css('.pics img[src*=flickr]').first['src']
    
    photo_id = flickr_static_url.scan(%r(/(\d+)_[\w\d@-]+)).flatten.last
    return [nil, nil] unless photo_id
      
    flickr_with_photo_id(photo_id)
  end

  def twitsnaps
    if self.url =~ %r(img_id=([\d]+)$)
      photo_id = $1
    else
      return [nil, nil]
    end

    thumb = open("http://twitsnaps.com/thumb/#{photo_id}") { |f| f.base_uri.to_s }
    medium = open("http://twitsnaps.com/snap/#{photo_id}") { |f| f.base_uri.to_s }
    [thumb, medium]
  end

  def three_sixty_five_project
    doc = Nokogiri::HTML(open(self.url))
    medium = doc.css('.media-content a img').first['src']    
    thumb = medium.gsub(/(_m\.)/, '_sq.')

    [thumb, medium]
  end
  
  def zenfolio
    if self.url =~ %r(h([0-9a-f]+)$)
      photo_id = $1.to_i(16)
    else
      return [nil, nil]
    end
    
    api_url = "http://www.zenfolio.com/api/1.2/zfapi.asmx/LoadPhoto?photoId="
    user_agent = "Daily Shoot Submission Parser for Zenfolio"
    
    doc = Nokogiri::HTML(open(api_url + photo_id.to_s, 'User-Agent' => user_agent))
    
    if doc.xpath("/photo")
      url_core = doc.xpath('//urlcore').first.text

      base_image_url = "http://www.zenfolio.com/#{url_core}"
      thumb = "#{base_image_url}-1.jpg"
      medium = "#{base_image_url}-2.jpg"
    else
      raise "Zenfolio API failed"
    end

    [thumb, medium]
  end

  # http://farm{farm-id}.static.flickr.com/{server-id}/{photo-id}_{secret}.jpg.
  def flickr_static  
    photo_id = self.url.scan(%r(/(\d+)_[\w\d@-]+)).flatten.last
    return [nil, nil] unless photo_id
      
    flickr_with_photo_id(photo_id)
  end

  # There's a flickr gem to do this, too.  
  def flickr
    if self.url =~ %r(/p/(\w+))
      photo_id = Base58.base58_to_int($1)
    else
      photo_id = self.url.scan(%r(/photos/[\w@-]+/(\d+))).flatten.last
    end
    return [nil, nil] unless photo_id
    
    flickr_with_photo_id(photo_id)
  end
  
  def flickr_with_photo_id(photo_id)
    flickr_url = "http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&photo_id=#{photo_id}&api_key=#{ENV['FLICKR_API_KEY']}"
    doc = Nokogiri::XML(open(flickr_url))
    if doc.xpath('/rsp/@stat').first.value == "ok"
      thumb = doc.xpath("//size[@label='Square']").first['source']
      medium = doc.xpath("//size[@label='Medium']").first
      if medium 
        medium = medium['source']
      else
        medium = thumb
      end
    else
      raise "Flickr API failed"
    end
    [thumb, medium]
  end
  
  # 
  # Form:
  #   /AlbumID_AlbumKey#ImageID_ImageKey
  # 
  # Example: 
  #   http://bluecamel.smugmug.com/Photography/dailyshoot/10469863_EdveS#748954599_NUvea
  # 
  # Image ID = 748954599 (all numeric)
  # Image Key = NUvea (mixed case, case sensitive)
  def smugmug
    if self.url =~ %r(#([0-9]+)_([a-zA-Z0-9]+))
      image_id, image_key = $1, $2
    else
      return
    end
    
    session_url = "http://api.smugmug.com/services/api/rest/1.2.2/?method=smugmug.login.anonymously&APIKey=#{ENV['SMUGMUG_API_KEY']}"
    doc = Nokogiri::XML(open(session_url))
    if doc.xpath('/rsp/@stat').first.value == "ok"
      session_id = doc.xpath('//Session/@id').first.value
    else
      raise "SmugMug session failed"
    end
    
    images_url = "http://api.smugmug.com/services/api/rest/1.2.2/?method=smugmug.images.getURLs&SessionID=#{session_id}&ImageID=#{image_id}&ImageKey=#{image_key}"
    doc = Nokogiri::XML(open(images_url))
    if doc.xpath('/rsp/@stat').first.value == "ok"
      thumb = doc.xpath('//Image/@TinyURL').first.value
      medium = doc.xpath('//Image/@MediumURL').first.value
    else
      raise "SmugMug API failed"
    end
    [thumb, medium]
  end
  
end
