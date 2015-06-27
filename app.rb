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
require './config/evernote_config.rb'

##
# Verify that you have obtained an Evernote API key
##
before do
  if OAUTH_CONSUMER_KEY.empty? || OAUTH_CONSUMER_SECRET.empty?
    halt '<span style="color:red">Before using this sample code you must edit evernote_config.rb and replace OAUTH_CONSUMER_KEY and OAUTH_CONSUMER_SECRET with the values that you received from Evernote. If you do not have an API key, you can request one from <a href="http://dev.evernote.com/documentation/cloud/">dev.evernote.com/documentation/cloud/</a>.</span>'
  end
end

# Load app helper methods
require './helpers/evernote_helpers.rb'

##
# Index page
##
get '/' do
  erb :index
end

##
# Reset the session
##
get '/reset' do
  session.clear
  redirect '/'
end

##
# Obtain temporary credentials
##
get '/requesttoken' do
  callback_url = request.url.chomp("requesttoken").concat("callback")
  begin
    session[:request_token] = client.request_token(:oauth_callback => callback_url)
    redirect '/authorize'
  rescue => e
    @last_error = "Error obtaining temporary credentials: #{e.message}"
    erb :error
  end
end

##
# Redirect the user to Evernote for authorization
##
get '/authorize' do
  if session[:request_token]
    redirect session[:request_token].authorize_url
  else
    # You shouldn't be invoking this if you don't have a request token
    @last_error = "Request token not set."
    erb :error
  end
end

##
# Receive callback from the Evernote authorization page
##
get '/callback' do
  unless params['oauth_verifier'] || session['request_token']
    @last_error = "Content owner did not authorize the temporary credentials"
    halt erb :error
  end
  session[:oauth_verifier] = params['oauth_verifier']
  begin
    session[:access_token] = session[:request_token].get_access_token(:oauth_verifier => session[:oauth_verifier])
    redirect '/notebooks'
  rescue => e
    @last_error = 'Error extracting access token'
    erb :error
  end
end


##
# notebook CRUD start
##
get '/notebooks' do
  begin
    if authorized
      # Get total notes count
      @total_notes_count = total_note_count
    end

    erb "notebooks/index".to_sym
  rescue => e
    @last_error = "Error listing notebooks: #{e.message}"
    erb :error
  end
end


##
# note CRUD start
##
get '/notebooks/:notebook_id/notes' do
  @notebook = find_notebook
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.notebookGuid = @notebook.guid
  @notes = note_store.findNotes(filter, 0, 100).notes

  erb "notebooks/notes/index".to_sym
end

get '/notebooks/:notebook_id/notes/:id' do
  @note = find_note
  @content = get_note_content(@note)
  erb "notebooks/notes/show".to_sym
end
