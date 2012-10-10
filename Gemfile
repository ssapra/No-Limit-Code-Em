source 'https://rubygems.org'

gem 'rails', '3.2.8'
gem 'newrelic_rpm'
gem 'rack-timeout'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do 
	gem 'sqlite3'
end

group :production do
	gem 'pg'
end

gem 'ruby-poker'
gem 'bootstrap-sass'
gem 'google-buttons-sass'

group :test do
  gem 'cucumber-rails', '~> 1.3.0', :require => false
  gem 'rspec-rails', '~> 2.11.0'
  gem 'rspec-mocks'
  gem 'database_cleaner'
end

group :production do
  gem 'thin'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'haml'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'debugger'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'
