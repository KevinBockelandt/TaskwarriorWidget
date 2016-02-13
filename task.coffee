command: "/usr/local/bin/task export status:pending"

refreshFrequency: 10000 # every 10 sec



render: -> """
	<table id="container">
	</table>
"""


update: (output, domEl) ->

	# Find the HTML table and clear it before repopulating it
	$taskTable = $(domEl).find("#container")
	$taskTable.empty()

	# Get the JSON object containing all the tasks
	jsonObj = JSON.parse(output)

	# Sort the tasks according to their due date
	jsonObj.sort (a, b) ->
		aDue = 100000000               # tasks without due date
		bDue = 100000001               # will be put at the end of the list

		if a.due != undefined
			aDue = a.due.slice(0, 8)   # 8 first char are the date

		if b.due != undefined
			bDue = b.due.slice(0, 8)

		return parseInt(aDue) - parseInt(bDue)



	# We go over every pending task
	for task, i in jsonObj

		# Only display the 20 first available tasks
		if i > 20
			return

		dueDateOffset = 10000  # ridiculously high number to indicate there is no due date
		priority = ''
		project = ''
		tags = ''
		finalString = ''
		cofAlpha = (i * 0.05) * (-1) + 1 # transparency for this line in the table

		if task.due != undefined
			# Task warrior date strings are weirdly formatted
			dueDateIsoStr = task.due.slice(0, 4) + "-" + task.due.slice(4, 6) + "-" + task.due.slice(6, 11) + ":" + task.due.slice(11, 13) + ":" + task.due.slice(13);
			dueDate = new Date(dueDateIsoStr)
			# Get today's date to sort tasks by comparison
			today = new Date()
			today.setHours(0)
			today.setMinutes(0)
			# Get the offset in days between the due date and today			
			tempMin = dueDate.getMinutes() - dueDate.getTimezoneOffset()
			dueDate.setMinutes(tempMin)
			dueDateOffset = Math.floor((dueDate.getTime() - today.getTime()) / (24*60*60*1000))

		if task.priority != undefined
			priority = task.priority

		if task.project != undefined
			project = task.project

		# If the task has associated tags, create a single string out of them
		if task.tags != undefined
			for t in task.tags
				tags += "+" + t + " "


		# We put a background on odd numbered rows
		if i % 2 == 0
			finalString = "<tr>"
		else
			finalString = "<tr style='background-color:rgba(255, 255, 255, #{cofAlpha*0.06})'>"

		# Handle the cell containing the due date offset
		if dueDateOffset < 0
			finalString += "<td  style='color:rgba(255, 0, 0, #{cofAlpha})'>#{dueDateOffset}</td>"
		else if dueDateOffset == 0
			finalString += "<td  style='color:rgba(255, 200, 0, #{cofAlpha})'>#{dueDateOffset}</td>"
		else if dueDateOffset > 9999
			finalString += "<td></td>"
		else
			finalString += "<td  style='color:rgba(255, 255, 255, #{cofAlpha})'>#{dueDateOffset}</td>"

		# Handle the cell containing the priority
		if task.priority == "H"
			finalString += "<td  style='color:rgba(150, 200, 255, #{cofAlpha})'>#{priority}</td>"
		else if task.priority == "M"
			finalString += "<td  style='color:rgba(0, 150, 255, #{cofAlpha})'>#{priority}</td>"
		else
			finalString += "<td  style='color:rgba(0, 0, 255, #{cofAlpha})'>#{priority}</td>"

		# Add the cell containing the project name
		finalString += "<td  style='color:rgba(255, 255, 255, #{cofAlpha})'>#{project}</td>"

		# Handle the cell containing the description
		if dueDateOffset < 0
			finalString += "<td style='color:rgba(255, 0, 0, #{cofAlpha})'>#{task.description}</td>"
		else if dueDateOffset == 0
			finalString += "<td style='color:rgba(255, 200, 0, #{cofAlpha})'>#{task.description}</td>"
		else
			finalString += "<td style='color:rgba(255, 255, 255, #{cofAlpha})'>#{task.description}</td>"

		# Add the cell containing the tags
		finalString += "<td  style='color:rgba(50, 150, 50, #{cofAlpha})'>#{tags}</td>"
		finalString += "</tr>"


		# Append the string for the whole line to the table
		$taskTable.append(finalString)

		


style: """
	left: 20px
	top: 20px
	font-family: monospace
	font-size: 1.1em
	font-weight: 200

	#container
		border-collapse: collapse

	td
		padding-left: 8px
		padding-right: 8px
		padding-bottom: 4px

"""
