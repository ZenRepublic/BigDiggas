extends Button
class_name TimedButton

@export var time_left_prefix:String = "Closes in:"
@export var activated_text:String
@export var refresh_frequency_seconds:int = 1

var activation_time:float
var time_elapsed:float

var is_active:bool=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled=true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_active:
		return
	
	time_elapsed+=delta
	if time_elapsed < refresh_frequency_seconds:
		return
	
	var utc_timestamp:float = Time.get_unix_time_from_system()
	if utc_timestamp >= activation_time:
		if disabled:
			disabled=false
			text = activated_text
			is_active=false
		return
			
	disabled=true
	var time_left_formatted:String = format_time(activation_time - utc_timestamp)
	text = "%s %s" % [time_left_prefix,time_left_formatted]
	time_elapsed=0

func activate(end_timestamp:float) -> void:
	activation_time = end_timestamp
	is_active=true
	time_elapsed = refresh_frequency_seconds
	
	
func format_time(timestamp: int) -> String:
	var hours = int(timestamp / 3600)
	var minutes = int((timestamp % 3600) / 60)
	var seconds = int(timestamp % 60)

	return str(hours) + "h " + str(minutes) + "m " + str(seconds) + "s"
