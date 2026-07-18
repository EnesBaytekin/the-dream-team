extends MarginContainer

@export var card_data: Dictionary = {} : set = _set_card_data

@onready var user_pp: TextureRect = $Control/UserPP
@onready var user_name: Label = $Control/UserName
@onready var jam_count: Label = $Control/JamCount
@onready var skill_labels: Array = [$Control/Skill1, $Control/Skill2, $Control/Skill3]


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
	var jam_number = card_data.get("game_jam", 0)
	var jam_suffix = "th"
	match jam_number%10:
		1: jam_suffix = "st"
		2: jam_suffix = "nd"
		3: jam_suffix = "rd"
	jam_count.text = ("%d" % jam_number) + jam_suffix + " jam"

	var skills: Array = card_data.get("skills", [])
	for i in range(skill_labels.size()):
		if i < skills.size():
			var s = skills[i]
			skill_labels[i].text = "* %s" % s.get("name", "?")
			skill_labels[i].show()
		else:
			skill_labels[i].hide()
