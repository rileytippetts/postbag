##
# App Blueprint
##

# copy "creative" notebook and format titles to exclude dates and use clear tags

get and store following note data within @parent_notebook (request every 3 months)
	loop for 3 months at a time starting from the earliest note created

		note.created (timestamp)

		note.title (string)
			# set note.title in tooltip element

		note.length (int)
			# set element height based on note.length (module between note.length and min/max height)

		note.tags (array of ids or names)
			# set element bg color based on tag key:value chart