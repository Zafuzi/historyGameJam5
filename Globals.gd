extends Node

export (PackedScene) var g_current_level
export (PackedScene) var g_next_level
export (PackedScene) var g_previous_level


func _ready():
	if not g_next_level:
		g_next_level = preload("res://Levels/Level01.tscn")
