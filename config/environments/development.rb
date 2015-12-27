Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = "tymhbbq2824xmbck"
  Braintree::Configuration.public_key = "btmwrq39cqq7k9rr"
  Braintree::Configuration.private_key = "3800225ea9bf3be3f20e8b8c4af233a1"
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default :charset => "utf-8"
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => "www.gmail.com",
      :user_name            => ENV['GMAIL_ACCOUNT_ID'],
      :password             => ENV['GMAIL_ACCOUNT_PWD'],
      :authentication       => "plain",
      :enable_starttls_auto => true
  }
end
