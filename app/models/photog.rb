class Photog < ActiveRecord::Base
  validates_presence_of :screen_name
  
  has_many :photos, :dependent => :nullify do
    def with_assignment(options={})
      find(:all, 
           :joins => [:assignment, :photog],
           :select => "photos.*, photogs.screen_name as photog_screen_name, assignments.position as assignment_position, assignments.tag as assignment_tag",
           :order => "assignments.position desc")
    end
  end
  
  has_many :assignments, :through => :photos
  # Annoyingly, generated counter_sql doesn't work when a subselect is specified so we must explicitly provide one
  has_many :missing_assignments, 
        :class_name => "Assignment", 
        :finder_sql => 'SELECT * FROM assignments WHERE (date <= \'#{Date.today}\' and id NOT IN (SELECT assignment_id FROM photos WHERE photos.photog_id = #{id} )) order by date asc',
        :counter_sql => 'SELECT count(*) FROM assignments WHERE (date <= \'#{Date.today}\' and id NOT IN (SELECT assignment_id FROM photos WHERE photos.photog_id = #{id} ))' do
          def find(*args)
            options = args.extract_options!
            sql = @finder_sql

            sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
            sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]

            Assignment.find_by_sql(sql)
          end
      end

  def self.all_by_photos_count
    all(:order => 'photos_count desc')
  end
  
  def self.with_screen_name(screen_name)
    self.find_by_screen_name(screen_name) || self.new(:screen_name => screen_name)
  end

  def twitter_url
    "http://twitter.com/#{screen_name}"
  end
    
  def to_param
    self.screen_name
  end
  
end