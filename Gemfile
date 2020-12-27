# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# PRESENTATION LAYER
gem 'slim', '~> 3.0'

# APPLICATION LAYER
# Web application related
gem 'econfig', '~> 2.1'
gem 'puma', '~> 3.11'
gem 'rack', '~> 2' # 2.3 will fix delegateclass bug
gem 'roda', '~> 3.8'

# Controllers and services
gem 'dry-monads'
gem 'dry-transaction'
gem 'dry-validation'

# Representers
gem 'multi_json'
gem 'roar'

# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 4.0'

# TESTING
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'

  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.0'

  gem 'headless', '~> 2.3'
  gem 'page-object', '~> 2.2'
  gem 'watir', '~> 6.17'
end

group :development, :test do
  gem 'rerun', '~> 0.13'
end

# DEBUGGING
group :development do
  # Debugging: see https://stackify.com/ruby-debugger-using-visual-studio-code/
  gem 'debase', '~> 0.2'
  gem 'ruby-debug-ide', '~> 0.7'
end

# QUALITY
group :development, :test do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

# UTILITIES
gem 'rake', '~> 13.0'