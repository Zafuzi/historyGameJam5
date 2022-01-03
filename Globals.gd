extends Node

export (PackedScene) var g_current_level
export (PackedScene) var g_next_level
export (PackedScene) var g_previous_level

onready var loading_scene = "res://Assets/LoadingScreen.tscn"

func _ready():
	if not g_next_level:
		g_next_level = "res://Assets/Levels/debug.tscn"
