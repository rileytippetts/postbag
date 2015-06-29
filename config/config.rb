# Import and consolidate all configuration files

configure do
  require 'config/compass_config.rb'
  require 'config/evernote_config.rb'

  set :sass, Compass.sass_engine_options
  set :scss, Compass.sass_engine_options
end

get '/sass.css' do
  sass :sass_file
end

get '/scss.css' do
  scss :scss_file
end
