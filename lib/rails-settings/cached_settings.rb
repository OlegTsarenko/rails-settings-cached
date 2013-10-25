module RailsSettings
	class CachedSettings < Settings
    after_update :rewrite_cache
    after_create :rewrite_cache

		def rewrite_cache
			Rails.cache.write("settings_#{ self.class.env}:#{self.var}", self.value)
    end

    def self.env
      Rails.methods.include?(:env) ? Rails.env : 'test'
    end

    after_destroy { |record| Rails.cache.delete("settings_#{self.class.env}:#{record.var}") }

		def self.[](var_name)
			obj = Rails.cache.fetch("settings_#{env}:#{var_name}") {
				super(var_name)
			}
      obj || @@defaults[var_name.to_s]
    end

    def self.save_default(key,value)
      if self.send(key) == nil
        self.send("#{key}=",value)
      end
    end
	end
end
