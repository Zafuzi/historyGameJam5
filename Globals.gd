extends Node

var g_current_level 		: String
var g_next_level 			: String
var g_previous_level 		: String
var screen_size 			: Vector2 				= Vector2(0, 0)
var g_global_volume 		: int 					= 10
var g_music_volume 			: int 					= 10
var g_sfx_volume 			: int 					= 10

onready var loading_scene = "res://Assets/LoadingScreen.tscn"

func _ready():
	if not g_next_level:
		g_next_level = "res://Assets/Levels/debug.tscn"

func _process(delta):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(g_global_volume / 10));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BackgroundMusic"), linear2db(g_music_volume / 10));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(g_sfx_volume / 10));
	screen_size = get_viewport().get_visible_rect().size
