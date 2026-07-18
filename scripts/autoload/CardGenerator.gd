extends Node

const NAMES := [
	"Kael", "Lyra", "Borin", "Sera", "Dorn", "Faye", "Grimm", "Naya",
	"Torvin", "Elara", "Zeph", "Mira", "Harkun", "Vessa", "Rook", "Ivy",
	"Fen", "Larke", "Orin", "Tessa", "Brom", "Sylas", "Dagny", "Riven",
	"Korvus", "Astra", "Jorak", "Niamh", "Theln", "Ziva",
]

const SKILLS := {
	"unity": 10, "godot": 8, "unreal engine": 5,
	"pygame": 6, "gamemaker": 7, "roblox": 2,
	"photoshop": 9, "aseprite": 8, "gimp": 4,
	"blender": 9, "3d animation": 5, "2d animation": 6,
	"fl studio": 7, "lmms": 3, "midi keyboard": 4, "guitar": 3,
}

const GAME_JAM_MAX := 10
const SKILL_MIN := 25
const SKILL_MAX := 100


static func _pick_weighted(items: Dictionary, count: int) -> Array:
	var pool = []
	for key in items:
		for _i in range(items[key]):
			pool.append(key)
	pool.shuffle()
	var selected = []
	var seen = {}
	for item in pool:
		if item in seen:
			continue
		seen[item] = true
		selected.append(item)
		if selected.size() >= count:
			break
	return selected


static func _weighted_rand(max_val: float) -> int:
	return 1 + int((max_val - 1.0) * pow(randf(), 2.0))


static func _skill_level() -> int:
	return SKILL_MIN + int((SKILL_MAX - SKILL_MIN) * pow(randf(), 0.7))


static func generate_card() -> Dictionary:
	var jam = _weighted_rand(GAME_JAM_MAX)
	var skill_count = randi_range(1, 3)
	var picked = _pick_weighted(SKILLS, skill_count)

	var skills = []
	for s in picked:
		skills.append({"name": s, "level": _skill_level()})

	return {
		"name": NAMES[randi() % NAMES.size()],
		"skills": skills,
		"game_jam": jam,
	}
