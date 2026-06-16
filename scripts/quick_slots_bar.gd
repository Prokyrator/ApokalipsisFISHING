extends Control

var quick_buttons: Array = []

const BUTTON_SIZE = 56
const BUTTON_GAP = 14


func _ready():
	_build_buttons()
	visible = true


func _build_buttons():
	var container = HBoxContainer.new()
	container.name = "QuickSlotsContainer"
	container.add_theme_constant_override("separation", BUTTON_GAP)
	container.z_index = 100
	add_child(container)
	
	var screen_size = get_viewport_rect().size
	var total_width = BUTTON_SIZE * 3 + BUTTON_GAP * 2
	container.position = Vector2((screen_size.x - total_width) / 2, screen_size.y - BUTTON_SIZE - 30)
	
	for i in range(3):
		var btn = Button.new()
		btn.name = "QuickSlot" + str(i)
		btn.custom_minimum_size = Vector2(BUTTON_SIZE, BUTTON_SIZE)
		btn.focus_mode = Control.FOCUS_NONE
		_update_button_text(btn, i)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.15, 0.15)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(1.0, 0.78, 0.0, 0.4)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		btn.add_theme_stylebox_override("normal", style)
		
		var hover_style = style.duplicate()
		hover_style.bg_color = Color(0.25, 0.25, 0.25, 0.3)
		hover_style.border_color = Color(1.0, 0.9, 0.0, 0.7)
		btn.add_theme_stylebox_override("hover", hover_style)
		
		btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 0.6))
		btn.add_theme_font_size_override("font_size", 10)
		
		btn.pressed.connect(_on_quick_slot_pressed.bind(i))
		container.add_child(btn)
		quick_buttons.append(btn)


func _update_button_text(btn: Button, slot_index: int):
	btn.text = "Готов" if GameData.is_slot_ready(slot_index) else "Не\nсобрано"


func _on_quick_slot_pressed(slot_index: int):
	if not GameData.is_slot_ready(slot_index):
		var msg = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Снасти не собраны.", 1)
		return
	
	# Сообщаем fishing_gear о нажатии
	var fishing_gear = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
	if fishing_gear and fishing_gear.has_method("on_quick_slot_pressed"):
		fishing_gear.on_quick_slot_pressed(slot_index)


func refresh_buttons():
	for i in range(quick_buttons.size()):
		_update_button_text(quick_buttons[i], i)
		if not GameData.is_slot_ready(i):
			var fishing_gear = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
			if fishing_gear and fishing_gear.has_method("remove_gear_by_slot"):
				fishing_gear.remove_gear_by_slot(i)


func get_quick_buttons() -> Array:
	return quick_buttons
