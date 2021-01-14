# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require 'capistrano/rvm'

task :use_rbenv do
  require 'capistrano/rbenv'
end

task 'production' => [:use_rbenv]

# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'
require 'capistrano/passenger'
# require 'capistrano/cookbook'

set :default_env, {
    'PATH' => '$PATH:/home/ubuntu/.rbenv/bin:/home/ubuntu/.rbenv/shims:/home/ubuntu/.nvm/versions/node/v4.4.0/bin/'
}

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
