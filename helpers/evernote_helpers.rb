# Required in '/app.rb'

helpers do
  def auth_token
    session[:access_token].token if session[:access_token]
  end

  def client
    @client ||= EvernoteOAuth::Client.new(token: auth_token, consumer_key:OAUTH_CONSUMER_KEY, consumer_secret:OAUTH_CONSUMER_SECRET, sandbox: SANDBOX)
  end

  def user_store
    @user_store ||= client.user_store
  end

  def note_store
    @note_store ||= client.note_store
  end

  def en_user
    user_store.getUser(auth_token)
  end

  def notebooks
    @notebooks ||= note_store.listNotebooks(auth_token)
  end

  def total_note_count
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    counts = note_store.findNoteCounts(auth_token, filter, false)
    notebooks.inject(0) do |total_count, notebook|
      total_count + (counts.notebookCounts[notebook.guid] || 0)
    end
  end

  def username
    @username ||= en_user.username
  end

  def authorized
    !!session[:access_token]
  end

  def find_notebook
    note_store.getNotebook(params[:notebook_id])
  end

  def find_note
    note_store.getNote(params[:id], true, true, false, false)
  end

  def get_note_content(note)
    escape_javascript(note_store.getNote(note.guid, true, true, false, false).content) rescue 'Get note content error'
  end

end
