extends Node
class_name LinkedButton

@export var button:BaseButton
@export var link:String
@onready var audio_player:AudioStreamPlayer = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(open_link)
	pass # Replace with function body.

func open_link() -> void:
	if audio_player.stream!=null:
		audio_player.play()
	OS.shell_open(link)