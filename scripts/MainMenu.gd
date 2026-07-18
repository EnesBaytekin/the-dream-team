extends Control

func _ready():
	var title = Label.new()
	title.text = "THE DREAM TEAM"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 150)
	title.size = Vector2(960, 50)
	add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Card Collector Battler"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	subtitle.position = Vector2(0, 200)
	subtitle.size = Vector2(960, 30)
	add_child(subtitle)

	var new_game = Button.new()
	new_game.text = "New Game"
	new_game.position = Vector2(380, 300)
	new_game.size = Vector2(200, 50)
	new_game.add_theme_font_size_override("font_size", 16)
	new_game.pressed.connect(_on_new_game)
	add_child(new_game)

	var quit = Button.new()
	quit.text = "Quit"
	quit.position = Vector2(380, 360)
	quit.size = Vector2(200, 50)
	quit.add_theme_font_size_override("font_size", 16)
	quit.pressed.connect(_on_quit)
	add_child(quit)


func _on_new_game():
	GameManager.start_new_run()
	get_tree().change_scene_to_file("res://scenes/Hub.tscn")


func _on_quit():
	get_tree().quit()
