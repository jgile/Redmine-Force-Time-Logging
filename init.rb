require 'issue'

Redmine::Plugin.register :force_update_time do
  name 'Force Update Time plugin'
  author 'John Gile'
  description 'This is a plugin for Redmine to force users to update logged time on tasks if of a certain tracker'
  version '0.0.1'
  url 'http://www.cliquestudios.com'
  author_url 'http://www.cliquestudios.com'
  settings :default => {'force_update_time_tracker' => nil}, :partial => 'settings/settings'
end



module IssuePatch
  def self.included(base)
    base.class_eval do
      unloadable

      validate :force_update_time, :on => :update

      protected
      def force_update_time
        has_error = false

        selected_trackers = Setting['plugin_force_update_time']['force_update_time_tracker']
	                               
# 	log = Logger.new('log/mylog.log')        
# 	log.info 'INCLUDES'    
# 	log.info  selected_trackers.include?("3")                                 
	                                
        if selected_trackers.include?(self.tracker.id.to_s)
          if !self.time_entries.empty?
            if !self.time_entries.where('created_on > ?', 1.minute.ago).exists?
	            
 	  		  log.info 'HAS ERROR' 	            
	            
              has_error = true
            end
          else
            has_error = true
          end
        end

        if has_error
          errors.add :time_entries, " - Did you update your time?"
        end
      end
    end
  end
end

Issue.send(:include, IssuePatch)