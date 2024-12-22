###############################################
# VTTReader
#
# Class that converts VTT-formated .TXT files
# into [start_time, end_time, content] arrays.
# This way they can be easily displayed as 
# subtitles or audio description.
###############################################
extends Node
class_name VTTReader

# Reads a VTT file and returns a list of entries

static func read(file_loc):
	var data = []
	
	if FileAccess.file_exists(file_loc):
		
		var file = FileAccess.open(file_loc,FileAccess.READ)
		
		# validates it is in VTT format
		if file.get_line().lstrip(" ").rstrip(" ") == "WEBVTT":
		
			while !file.eof_reached():
				var line = file.get_line().lstrip(" ").rstrip(" ")
				# if not an empty line
				if line.length() > 0:
					var entry = [0,0,0]
					var times = line.split("-->",true,2)
					var text = ""
					
					line = file.get_line().lstrip(" ").rstrip(" ")
					
					# keep adding to the text until an empty line is reached
					while !file.eof_reached() && line.length() > 0:
						
						text += line + "\n"
						
						line = file.get_line().lstrip(" ").rstrip(" ")
						
					entry[0] = string_to_time(times[0])
					entry[1] = string_to_time(times[1])
					entry[2] = text
					
					data.append(entry)
				
	return data

static func string_to_time(string):
	string = string.lstrip(" ").rstrip(" ")
	
	# Assumes no hour position
	if string.count(":") == 1:
		string = "00:" + string
		
	var ms = Time.get_unix_time_from_datetime_string(string) * 1000
	
	ms += int(string.split(".")[1])
	
	return float(ms) * 0.001
