extends Button
class_name TimedButton

@export var time_left_prefix:String = "Closes in:"
@export var activated_text:String
@export var refresh_frequency_seconds:int = 1
@export var enable_on_activation:bool=true

var finish_time:float=0
var time_elapsed:float

var is_active:bool=false

signal on_timer_finished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#disabled=true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_active:
		return
	
	time_elapsed+=delta
	if time_elapsed < refresh_frequency_seconds:
		return
	
	if is_finished():
		if enable_on_activation:
			disabled=false
		text = activated_text
		on_timer_finished.emit()
		is_active=false
		return
			
	#disabled=true
	var time_left_formatted:String = format_time_left(finish_time)
	text = "%s %s" % [time_left_prefix,time_left_formatted]
	time_elapsed=0

func start_timer(end_timestamp:float) -> void:
	finish_time = end_timestamp
	is_active=true
	time_elapsed = refresh_frequency_seconds
	
func is_finished() -> bool:
	if finish_time == 0:
		return false
		
	var utc_timestamp:float = Time.get_unix_time_from_system()
	return utc_timestamp >= finish_time
	
	
func format_time_left(end_time:float) -> String:
	var timestamp:int = end_time - Time.get_unix_time_from_system()
	var hours = int(timestamp / 3600)
	var minutes = int((timestamp % 3600) / 60)
	var seconds = int(timestamp % 60)

	return str(hours) + "h " + str(minutes) + "m " + str(seconds) + "s"
