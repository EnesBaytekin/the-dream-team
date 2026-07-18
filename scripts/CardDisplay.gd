extends MarginContainer

@export var card_data: Dictionary = {} : set = _set_card_data

@onready var user_pp: TextureRect = $Control/UserPP
@onready var user_name: Label = $Control/UserName
@onready var jam_count: Label = $Control/JamCount
@onready var skill1: Label = $Control/Skill1


func _set_card_data(value: Dictionary):
	card_data = value
	_refresh()


func display(data: Dictionary):
	card_data = data
	_refresh()


func _refresh():
	if not is_node_ready():
		await ready
	if card_data.is_empty():
		return

	user_name.text = card_data.get("name", "??")
	jam_count.text = "Jam #%d" % card_data.get("game_jam", 0)

	var skills: Array = card_data.get("skills", [])
	if skills.size() > 0:
		var s = skills[0]
		skill1.text = "  * %s" % s.get("name", "?")
		skill1.show()
	else:
		skill1.hide()
