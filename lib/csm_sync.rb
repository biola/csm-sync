module CSMSync

  def self.initialize!
    env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || :development

    RailsConfig.load_and_set_settings('./config/settings.yml', "./config/settings.#{env}.yml", './config/settings.local.yml')

    BiolaWebServices.configure do |config|
      config.cert_path    = Settings.ws.cert_path
      config.key_path     = Settings.ws.key_path
      config.key_password = Settings.ws.key_password
    end

    Mail.defaults do
      delivery_method Settings.email.delivery_method, Settings.email.options.to_hash
    end

    Sidekiq.configure_server do |config|
      config.redis = { url: Settings.redis.url, namespace: 'csm-sync' }
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: Settings.redis.url, namespace: 'csm-sync' }
    end

    if defined? ::ExceptionNotifier
      require 'active_support'
      require 'active_support/core_ext'
      require 'exception_notification/sidekiq'
      ExceptionNotifier.register_exception_notifier(:email, Settings.exception_notification.options.to_hash)
    end

    require 'biola_web_services'
    require './lib/csm_sync/contact'
    require './lib/csm_sync/csv'
    require './lib/csm_sync/netid'
    require './lib/csm_sync/oracle'
    require './lib/csm_sync/workers/csv_writer'
    require './lib/csm_sync/workers/csv_uploader'

    true
  end
end
