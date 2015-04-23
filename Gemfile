source 'https://rubygems.org'
source 'https://gems.biola.edu'

gem 'activesupport'
gem 'biola_web_services'
gem 'blazing'
gem 'mail'
gem 'net-scp'
gem 'rails_config', '0.5.0.beta1'
gem 'sidekiq'
gem 'sidetiq'

group :development, :staging, :production do
  gem 'ruby-oci8', require: 'oci8'
end

group :development, :test do
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-rescue'
end

group :test do
  gem 'rspec'
end

group :production do
  gem 'sentry-raven'
end
