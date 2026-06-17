extends Node

enum GearType { ROD, REEL, LINE, HOOK, BAIT, CAGE, COMPONENT }
enum Rarity { COMMON = 1, UNCOMMON = 2, RARE = 3, EPIC = 4, LEGENDARY = 5 }

signal quick_slots_changed()

var inventory: Array = []
var quick_slots: Array = []
var active_slot: int = -1
var first_run: bool = true
var caps: int = 100
var mutagens: int = 0
var current_player_name: String = ""
var player_level: int = 1
var player_exp: int = 0
var player_exp_to_level: int = 100

var fish_cage: Array = []
var cage_capacity: int = 20

const SLOT_KEYS = ["ROD", "REEL", "LINE", "HOOK", "BAIT"]


func _ready():
	pass


func _load_player_data():
	var file_name = "user://save_%s.json" % current_player_name
	if not FileAccess.file_exists(file_name):
		return
	var save_file = FileAccess.open(file_name, FileAccess.READ)
	if save_file == null:
		GlobalLogger.log("[GameData] Не удалось открыть save-файл: %s" % file_name)
		return
	var text = save_file.get_as_text()
	save_file.close()
	if text == null or text == "":
		GlobalLogger.log("[GameData] Save-файл пуст: %s" % file_name)
		return
	var json = JSON.parse_string(text)
	if json is Dictionary:
		inventory = json.get("inventory", [])
		quick_slots = json.get("quick_slots", [])
		active_slot = json.get("active_slot", -1)
		first_run = json.get("first_run", true)
		caps = json.get("caps", 100)
		mutagens = json.get("mutagens", 0)
		player_level = json.get("player_level", 1)
		player_exp = json.get("player_exp", 0)
		player_exp_to_level = json.get("player_exp_to_level", 100)
		fish_cage = json.get("fish_cage", [])
		cage_capacity = json.get("cage_capacity", 20)
	else:
		GlobalLogger.log("[GameData] Ошибка чтения save-файла: некорректный JSON")
	
	if first_run or quick_slots.is_empty():
		_give_starter_gear()
	
	_update_cage_capacity()


func _save_data():
	var file_name = "user://save_%s.json" % current_player_name
	var data = {
		"inventory": inventory,
		"quick_slots": quick_slots,
		"active_slot": active_slot,
		"first_run": first_run,
		"caps": caps,
		"mutagens": mutagens,
		"player_level": player_level,
		"player_exp": player_exp,
		"player_exp_to_level": player_exp_to_level,
		"fish_cage": fish_cage,
		"cage_capacity": cage_capacity
	}

	var save_file = FileAccess.open(file_name, FileAccess.WRITE)
	if save_file == null:
		GlobalLogger.log("[GameData] Не удалось открыть save-файл на запись: %s" % file_name)
		return

	var error = save_file.store_string(JSON.stringify(data, "\t"))
	if error != OK:
		GlobalLogger.log("[GameData] Ошибка записи save-файла: %s, код: %d" % [file_name, error])
	save_file.close()


func _give_starter_gear():
	var file = FileAccess.open("res://data/starter_gear.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var json = JSON.parse_string(text)
		if json and json is Array:
			inventory = json.duplicate(true)
		file.close()
	
	quick_slots = [
		{"ROD": 0, "REEL": 1, "LINE": 2, "HOOK": 3, "BAIT": 4},
		{"ROD": -1, "REEL": -1, "LINE": -1, "HOOK": -1, "BAIT": -1},
		{"ROD": -1, "REEL": -1, "LINE": -1, "HOOK": -1, "BAIT": -1}
	]
	active_slot = 0
	caps = 100
	cage_capacity = 20
	first_run = false
	_save_data()


func _update_cage_capacity():
	var max_cap = 20
	for item in inventory:
		if item.get("type") == GearType.CAGE and item.get("active"):
			max_cap = item.get("capacity", 20)
			break
	cage_capacity = max_cap


func add_fish_to_cage(fish_data: Dictionary) -> bool:
	if fish_cage.size() >= cage_capacity:
		return false
	fish_cage.push_back(fish_data)
	_save_data()
	UIManager.update_cage_button()
	return true


func get_item(index: int):
	return inventory[index] if index >= 0 and index < inventory.size() else null


func set_quick_slot_item(slot_index: int, gear_type: int, item_index: int):
	if slot_index < 0 or slot_index >= 3:
		return
	quick_slots[slot_index][_gear_type_to_key(gear_type)] = item_index
	_save_data()
	quick_slots_changed.emit()


func get_quick_slot_item(slot_index: int, gear_type: int = -1):
	if slot_index < 0 or slot_index >= quick_slots.size():
		return null
	if gear_type < 0:
		gear_type = GearType.ROD
	return get_item(quick_slots[slot_index].get(_gear_type_to_key(gear_type), -1))


func is_slot_ready(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= quick_slots.size():
		return false
	for key in SLOT_KEYS:
		if quick_slots[slot_index].get(key, -1) < 0:
			return false
	return true


func damage_item_in_slot(slot_index: int, gear_type: int, damage_amount: int = 30) -> bool:
	if slot_index < 0 or slot_index >= quick_slots.size():
		return false
	var type_key = _gear_type_to_key(gear_type)
	var item_index = quick_slots[slot_index].get(type_key, -1)
	if item_index < 0:
		return false
	var item = inventory[item_index]
	var max_dura = item.get("max_durability", 0)
	if max_dura <= 0:
		return false
	item["durability"] = maxi(0, item["durability"] - damage_amount)
	var broken = item["durability"] <= 0
	if broken:
		quick_slots[slot_index][type_key] = -1
	_save_data()
	quick_slots_changed.emit()
	return broken


func break_line_in_slot(slot_index: int):
	if slot_index < 0 or slot_index >= quick_slots.size():
		return
	quick_slots[slot_index]["HOOK"] = -1
	var line_index = quick_slots[slot_index].get("LINE", -1)
	if line_index >= 0:
		var line_item = inventory[line_index]
		var loss = line_item.get("max_durability", 100) * 0.25
		line_item["durability"] = maxi(0, line_item["durability"] - loss)
		if line_item["durability"] <= 0:
			quick_slots[slot_index]["LINE"] = -1
	_save_data()
	quick_slots_changed.emit()


func _gear_type_to_key(gear_type: int) -> String:
	return SLOT_KEYS[gear_type] if gear_type >= 0 and gear_type < SLOT_KEYS.size() else "ROD"


func get_rarity_color(rarity: int) -> Color:
	match rarity:
		Rarity.COMMON: return Color(0.6, 0.6, 0.6, 1.0)
		Rarity.UNCOMMON: return Color(0.2, 0.8, 0.2, 1.0)
		Rarity.RARE: return Color(0.2, 0.4, 1.0, 1.0)
		Rarity.EPIC: return Color(0.7, 0.2, 1.0, 1.0)
		Rarity.LEGENDARY: return Color(1.0, 0.8, 0.0, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0)


func get_rarity_name(rarity: int) -> String:
	match rarity:
		Rarity.COMMON: return "I"
		Rarity.UNCOMMON: return "II"
		Rarity.RARE: return "III"
		Rarity.EPIC: return "IV"
		Rarity.LEGENDARY: return "V"
	return "?"

func get_fish_price(fish: Dictionary) -> int:
	var w = fish.get("caught_weight", 0)
	var g = fish.get("grade", "normal")
	var r = fish.get("rarity", 1)
	
	var gm = 1.0
	match g:
		"boss": gm = 25.0
		"mega": gm = 8.0
		"trophy": gm = 3.0
	
	var rm = 1.0
	if r == 2: rm = 3.0
	elif r == 3: rm = 10.0
	
	return int(w * 5 * gm * rm)
