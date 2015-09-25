# Import and consolidate all helper files

require 'helpers/evernote_helpers.rb'

helpers do
  def default_notebook
    note_store.getDefaultNotebook(auth_token).guid
  end
end
