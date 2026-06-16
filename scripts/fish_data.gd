extends Node

var fish_list: Array = []
var component_list: Array = []


func _ready():
	_load_json("res://data/fish_list.json", fish_list, "рыб")
	_load_json("res://data/components_list.json", component_list, "компонентов")


func _load_json(path: String, target: Array, name: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var json = JSON.parse_string(text)
		if json and json is Array:
			target.assign(json)
			GlobalLogger.log("[FishData] Загружено %d %s из JSON" % [target.size(), name])
		else:
			GlobalLogger.log("[FishData] Ошибка парсинга JSON: %s" % path)
		file.close()
	else:
		GlobalLogger.log("[FishData] Файл не найден: %s" % path)


func get_random_fish() -> Dictionary:
	if fish_list.is_empty():
		return {}
	return fish_list[randi() % fish_list.size()]


func get_fish_by_rarity(max_rarity: int) -> Dictionary:
	var filtered: Array = []
	for fish in fish_list:
		if fish["rarity"] <= max_rarity:
			filtered.append(fish)
	return filtered[randi() % filtered.size()] if not filtered.is_empty() else fish_list[0]


func generate_weight(fish: Dictionary) -> Dictionary:
	var roll = randf() * 100.0
	var weight: float
	var grade: String
	var w_min = fish.get("w_min", 0.01)
	var w_max = fish.get("w_max", 1.0)
	var w_range = w_max - w_min
	var w_trophy = w_max + w_range * 0.5
	var w_boss = w_max + w_range * 1.5
	if roll < 0.2:
		weight = randf_range(w_boss, w_boss * 2.0)
		grade = "boss"
	elif roll < 1.0:
		weight = randf_range(w_trophy, w_boss)
		grade = "mega"
	elif roll < 6.0:
		weight = randf_range(w_max, w_trophy)
		grade = "trophy"
	else:
		weight = randf_range(w_min, w_max)
		grade = "normal"
	return {"weight": snappedf(weight, 0.001), "grade": grade}


func generate_loot(fish_grade: String) -> Array:
	var loot: Array = []
	
	var drop_chance = 0.0
	match fish_grade:
		"normal": drop_chance = 5.0
		"trophy": drop_chance = 10.0
		"mega": drop_chance = 25.0
		"boss": drop_chance = 100.0
	
	if randf() * 100.0 > drop_chance:
		return loot
	
	var grade_roll = randf() * 100.0
	var component_grade = "common"
	match fish_grade:
		"normal":
			if grade_roll < 80: component_grade = "common"
			else: component_grade = "rare"
		"trophy":
			if grade_roll < 55: component_grade = "common"
			elif grade_roll < 85: component_grade = "rare"
			else: component_grade = "epic"
		"mega":
			if grade_roll < 35: component_grade = "common"
			elif grade_roll < 70: component_grade = "rare"
			elif grade_roll < 92: component_grade = "epic"
			else: component_grade = "legendary"
		"boss":
			if grade_roll < 50: component_grade = "rare"
			elif grade_roll < 80: component_grade = "epic"
			else: component_grade = "legendary"
	
	var matching: Array = []
	for comp in component_list:
		if comp["grade"] == component_grade:
			matching.append(comp)
	
	if matching.size() > 0:
		var picked = matching[randi() % matching.size()].duplicate()
		picked["comp_type"] = picked["type"]
		picked["type"] = GameData.GearType.COMPONENT
		loot.append(picked)
	
	return loot


func get_grade_color(grade: String) -> Color:
	match grade:
		"boss": return Color(1.0, 0.3, 0.0, 1.0)
		"mega": return Color(0.7, 0.2, 1.0, 1.0)
		"trophy": return Color(1.0, 0.8, 0.0, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0)
