raw_config = File.read("#{Rails.root}/config/user_profiles_config.yml")
USER_PROFILES_CONFIG = YAML.load(raw_config).symbolize_keys
