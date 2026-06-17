extends Control

var current_slot: int = 0
var slot_buttons: Array = []

const PICKER_WIDTH = 260
const PICKER_HEIGHT = 36
const LABEL_WIDTH = 80
const GEAR_TYPES = [
	{"name": "Удилище", "type": 0, "y": 120},
	{"name": "Катушка", "type": 1, "y": 175},
	{"name": "Леска", "type": 2, "y": 230},
	{"name": "Крючок", "type": 3, "y": 285},
	{"name": "Наживка", "type": 4, "y": 340},
]

var picker_buttons: Dictionary = {}
var dropdown_popup: PopupMenu = null
var current_gear_type: int = -1
var dropdown_item_indices: Array = []


func _ready():
	visible = false
	_build_window()
	_update_slot_buttons_highlight()


func _build_window():
	custom_minimum_size = Vector2(700, 500)
	position = Vector2(290, 110)
	
	var panel = Panel.new()
	panel.size = Vector2(700, 500)
	panel.position = Vector2.ZERO
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(1.0, 0.78, 0.0, 1.0)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	
	var title = Label.new()
	title.text = "НАСТРОЙКА СНАСТЕЙ"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(700, 40)
	title.position = Vector2(0, 10)
	add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.position = Vector2(650, 10)
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.8, 0.2, 0.2, 0.9)
	close_style.set_corner_radius_all(6)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.pressed.connect(_on_close_pressed)
	add_child(close_btn)
	
	var slot_buttons_container = HBoxContainer.new()
	slot_buttons_container.name = "SlotButtons"
	slot_buttons_container.add_theme_constant_override("separation", 15)
	slot_buttons_container.position = Vector2(0, 60)
	slot_buttons_container.size = Vector2(700, 50)
	slot_buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(slot_buttons_container)
	
	for i in range(3):
		var btn = Button.new()
		btn.name = "SlotBtn" + str(i)
		btn.text = "Слот %d" % (i + 1)
		btn.custom_minimum_size = Vector2(120, 45)
		btn.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2, 0.9))
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_slot_selected.bind(i))
		slot_buttons_container.add_child(btn)
		slot_buttons.append(btn)
	
	for gt in GEAR_TYPES:
		_create_picker_row(gt["name"], gt["type"], gt["y"])
	
	dropdown_popup = PopupMenu.new()
	dropdown_popup.name = "DropdownPopup"
	dropdown_popup.index_pressed.connect(_on_dropdown_index_pressed)
	add_child(dropdown_popup)


func _create_picker_row(label_text: String, gear_type: int, y_pos: float):
	var label = Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 0.9))
	label.add_theme_font_size_override("font_size", 14)
	label.position = Vector2(30, y_pos + 8)
	label.size = Vector2(LABEL_WIDTH, 20)
	add_child(label)
	
	var picker_btn = Button.new()
	picker_btn.name = "Picker_" + str(gear_type)
	picker_btn.text = "пусто"
	picker_btn.custom_minimum_size = Vector2(PICKER_WIDTH, PICKER_HEIGHT)
	picker_btn.position = Vector2(30 + LABEL_WIDTH + 10, y_pos)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.78, 0.0, 0.4)
	style.set_corner_radius_all(4)
	picker_btn.add_theme_stylebox_override("normal", style)
	picker_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.8))
	picker_btn.add_theme_font_size_override("font_size", 13)
	picker_btn.pressed.connect(_on_picker_pressed.bind(gear_type))
	add_child(picker_btn)
	picker_buttons[gear_type] = picker_btn


func _on_slot_selected(slot: int):
	current_slot = slot
	_update_slot_buttons_highlight()
	_update_pickers()


func _update_slot_buttons_highlight():
	for i in range(slot_buttons.size()):
		var btn = slot_buttons[i]
		var normal_style = StyleBoxFlat.new()
		normal_style.border_width_left = 3
		normal_style.border_width_right = 3
		normal_style.border_width_top = 3
		normal_style.border_width_bottom = 3
		normal_style.set_corner_radius_all(6)
		
		var hover_style = normal_style.duplicate()
		var is_active = i == current_slot
		
		normal_style.bg_color = Color(0.0, 0.0, 0.0, 0.8)
		normal_style.border_color = Color(1.0, 0.78, 0.0, 1.0) if is_active else Color(0.4, 0.4, 0.4, 0.8)
		hover_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
		hover_style.border_color = Color(1.0, 0.85, 0.0, 1.0) if is_active else Color(0.5, 0.5, 0.5, 1.0)
		btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0) if is_active else Color(0.5, 0.5, 0.5, 0.9))
		btn.add_theme_stylebox_override("normal", normal_style)
		btn.add_theme_stylebox_override("hover", hover_style)


func _on_picker_pressed(gear_type: int):
	current_gear_type = gear_type
	_show_dropdown(gear_type)


func _show_dropdown(gear_type: int):
	dropdown_popup.clear()
	dropdown_item_indices.clear()
	
	dropdown_popup.add_item("пусто")
	dropdown_item_indices.append(-1)
	
	for i in range(GameData.inventory.size()):
		var item = GameData.inventory[i]
		if item.get("type") == gear_type:
			var dura = item.get("durability", -1)
			var max_d = item.get("max_durability", -1)
			if max_d > 0 and dura <= 0:
				continue
			dropdown_popup.add_item(_format_item_text(item))
			dropdown_item_indices.append(i)
	
	var btn = picker_buttons.get(gear_type)
	if btn:
		dropdown_popup.position = btn.global_position + Vector2(0, PICKER_HEIGHT)
		dropdown_popup.show()


func _on_dropdown_index_pressed(index: int):
	if index < 0 or index >= dropdown_item_indices.size():
		return
	var item_index = dropdown_item_indices[index]
	if current_gear_type < 0:
		return
	GameData.set_quick_slot_item(current_slot, current_gear_type, item_index)
	_update_pickers()
	current_gear_type = -1


func _update_pickers():
	for gt in GEAR_TYPES:
		var picker = picker_buttons.get(gt["type"])
		if not picker:
			continue
		var item = GameData.get_quick_slot_item(current_slot, gt["type"])
		if item:
			picker.text = _format_item_text(item)
			picker.add_theme_color_override("font_color", GameData.get_rarity_color(item.get("rarity", 1)))
		else:
			picker.text = "пусто"
			picker.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.5))


func _format_item_text(item: Dictionary) -> String:
	var line = "[%s] %s" % [GameData.get_rarity_name(item.get("rarity", 1)), item.get("name", "???")]
	var max_d = item.get("max_durability", 0)
	if max_d > 0:
		line += " (%d/%d)" % [item.get("durability", 0), max_d]
	return line


func _on_close_pressed():
	dropdown_popup.hide()
	UIManager.toggle_gear_setup()
	



func refresh():
	current_slot = 0
	_update_slot_buttons_highlight()
	_update_pickers()
