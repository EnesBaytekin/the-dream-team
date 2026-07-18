extends Control

func _ready():
	var title = Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 100)
	title.size = Vector2(960, 50)
	add_child(title)

	var bt = GameManager.total_battles
	var w = GameManager.wins
	var wr = GameManager.get_winrate()

	var stats = Label.new()
	stats.text = "Battles: %d\nWins: %d\nWinrate: %.0f%%\n\nBetter luck next time!" % [bt, w, wr]
	stats.add_theme_font_size_override("font_size", 14)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.position = Vector2(0, 180)
	stats.size = Vector2(960, 120)
	add_child(stats)

	var restart = Button.new()
	restart.text = "New Run"
	restart.position = Vector2(330, 330)
	restart.size = Vector2(140, 50)
	restart.add_theme_font_size_override("font_size", 14)
	restart.pressed.connect(_on_restart)
	add_child(restart)

	var menu = Button.new()
	menu.text = "Main Menu"
	menu.position = Vector2(500, 330)
	menu.size = Vector2(130, 50)
	menu.add_theme_font_size_override("font_size", 14)
	menu.pressed.connect(_on_menu)
	add_child(menu)


func _on_restart():
	GameManager.start_new_run()
	get_tree().change_scene_to_file("res://scenes/Hub.tscn")


func _on_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
