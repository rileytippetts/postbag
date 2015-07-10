# required in '/app.rb'

# Compile sass
# get '/public/css/:name.css' do
#   content_type 'text/css', :charset => 'utf-8'
#   sass(:"public/css/#{params[:name]}", Compass.sass_engine_options )
# end

# Index page
get '/' do
  erb :index
end


# Reset the session
get '/reset' do
  session.clear
  redirect '/'
end


# Obtain temporary credentials
get '/requesttoken' do
  callback_url = request.url.chomp("requesttoken").concat("callback")
  begin
    session[:request_token] = client.request_token(:oauth_callback => callback_url)
    redirect '/authorize'
  rescue => e
    @last_error = 'Error obtaining temporary credentials: #{e.message}'
    erb :error
  end
end


# Redirect the user to Evernote for authorization
get '/authorize' do
  if session[:request_token]
    redirect session[:request_token].authorize_url
  else
    # You shouldn't be invoking this if you don't have a request token
    @last_error = 'Request token not set.'
    erb :error
  end
end


# Receive callback from the Evernote authorization page
get '/callback' do
  unless params['oauth_verifier'] || session['request_token']
    @last_error = 'Content owner did not authorize the temporary credentials'
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


# notebook CRUD start
get '/notebooks' do
  begin
    if authorized
      # Get total notes count
      @total_notes_count = total_note_count
    end

    erb 'notebooks/index'.to_sym
  rescue => e
    @last_error = 'Error listing notebooks: #{e.message}'
    erb :error
  end
end


# note CRUD start
get '/notebooks/:notebook_id/notes' do
  @notebook = find_notebook
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.notebookGuid = @notebook.guid
  @notes = note_store.findNotes(filter, 0, 100).notes

  erb 'notebooks/notes/index'.to_sym
end

get '/notebooks/:notebook_id/notes/:id' do
  @note = find_note
  @content = get_note_content(@note)
  erb 'notebooks/notes/show'.to_sym
end
