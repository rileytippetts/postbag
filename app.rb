##
# Copyright 2015 Riley Tippetts. All rights reserved.
##

require 'sinatra'
require 'sinatra/content_for'
require 'action_view'

include ActionView::Helpers::JavaScriptHelper

if development?
  require 'sinatra/reloader'
  # require 'pry'
end
enable :sessions

# Load our dependencies and configuration settings
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
configure do
  require 'config/compass_config.rb'
  require 'config/evernote_config.rb'
end

# Verify that you have obtained an Evernote API key
before do
  if OAUTH_CONSUMER_KEY.empty? || OAUTH_CONSUMER_SECRET.empty?
    halt '<span style="color:red">Before using this sample code you must edit evernote_config.rb and replace OAUTH_CONSUMER_KEY and OAUTH_CONSUMER_SECRET with the values that you received from Evernote. If you do not have an API key, you can request one from <a href="http://dev.evernote.com/documentation/cloud/">dev.evernote.com/documentation/cloud/</a>.</span>'
  end
end

# Load app helper methods
require 'helpers/evernote_helpers.rb'

# Load app routes
require 'routes.rb'
