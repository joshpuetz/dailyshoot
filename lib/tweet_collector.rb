class TweetCollector

  attr_accessor :debug
  
  def initialize(twitter)
    @twitter = twitter
    @debug = false
    @count = 0
  end
  
  def run(max_pages=100)
    @debug = true
    @count = 0
    page = 1
    
    last = Photo.first(:order => 'created_at desc')
    loop do
      raw_mentions = @twitter.mentions(:page => page)
      break unless raw_mentions.first
      found = false
      raw_mentions.each do |raw_mention|
        if last && raw_mention[:id].to_i <= last.tweet_id
          found = true
          break
        end
        next unless Photo.all(:conditions => {:tweet_id => raw_mention[:id].to_i}).count.zero?
        collect(raw_mention)
      end
      log "#{@count} mentions saved"
      count = 0
      break if found
      break if page == max_pages
      page += 1
      sleep 1
    end
  end
  
  def collect(raw_mention)
    mention = Mention.from_raw_mention(raw_mention)
    unless mention.save
      log "Unable to save original mention: #{mention.inspect}"
      return false
    end

    unless mention.tag
      log "No hashtag: #{mention.text}"
      return false
    end
    
    assignment = mention.assignment
    unless assignment
      log "Unknown assignment tag: #{mention.tag}"
      return false
    end
    
    photos = mention.photos
    if photos.empty?
      log "Photo URL parse error: #{mention.text}" 
      return false
    end

    photog = mention.photog
    
    photos = photos.select do |photo| 
      Photo.find_by_url_and_photog_id(photo.url, photog.id).nil? 
    end
    if photos.empty?
      log "Duplicate - skipping: #{mention.text}" 
      return false
    end
    
    if photog.new_record?
      photog.profile_image_url = mention.profile_image_url
      photog.save
    end

    photos.each do |photo|    
      photo.tweet_id = mention.tweet_id
      photo.assignment = assignment
      photo.photog = photog
      photo.save
    end

    log "#{@count}. #{mention.photog.screen_name} #{mention.assignment.tag}"

    @count += 1          
    mention.was_parsed = true
    mention.save
    
  rescue => e
    log "Unable to collect tweet: #{mention.text}: #{e.inspect}"
    return false
  end
   
private
  
  def log(message) 
    puts message if debug
  end
  
end