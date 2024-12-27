extends Object
class_name VTTReader
## A class that converts VTT formatted files into dictionary objects.
##
## Class that converts VTT-formated .TXT files
## into [start_time, end_time, content] arrays.
## This way they can be easily displayed as 
## subtitles or audio description.

## Reads a VTT formatted file from a specific location and 
## returns the formatted data as an array of entries.
static func read(file_loc: String) -> Array:
	var data = []
	
	if FileAccess.file_exists(file_loc):
		
		var file = FileAccess.open(file_loc,FileAccess.READ)
		
		# validates it is in VTT format
		if file.get_line().strip_edges() == "WEBVTT":
		
			while !file.eof_reached():
				var line = file.get_line().strip_edges()
				# if not an empty line
				if line.length() > 0:
					var entry = [0,0,0]
					var times = line.split("-->",true,2)
					var text = ""
					
					line = file.get_line().strip_edges()
					
					# keep adding to the text until an empty line is reached
					while !file.eof_reached() && line.length() > 0:
						
						text += line + "\n"
						
						line = file.get_line().strip_edges()
						
					entry[0] = _string_to_time(times[0])
					entry[1] = _string_to_time(times[1])
					entry[2] = text
					
					data.append(entry)
				
	return data

static func _string_to_time(string):
	string = string.strip_edges()
	
	# Assumes no hour position
	if string.count(":") == 1:
		string = "00:" + string
		
	var ms = Time.get_unix_time_from_datetime_string(string) * 1000
	
	ms += int(string.split(".")[1])
	
	return float(ms) * 0.001
