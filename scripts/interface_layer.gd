extends Control


var trader_panel = null
var cage_panel = null



func _ready():
	_build_top_panel()
	_build_side_panels()



func _build_top_panel():
	var top_panel = ColorRect.new()
	top_panel.name = "ВерхняяПанель"
	top_panel.color = Color(0.3, 0.3, 0.3, 1.0)
	top_panel.size = Vector2(1280, 100)
	top_panel.position = Vector2.ZERO
	add_child(top_panel)
	
	var info_frame_style = StyleBoxFlat.new()
	info_frame_style.bg_color = Color(0.0, 0.0, 0.0, 0.3)
	info_frame_style.border_width_left = 2
	info_frame_style.border_width_right = 2
	info_frame_style.border_width_top = 2
	info_frame_style.border_width_bottom = 2
	info_frame_style.border_color = Color(1.0, 0.78, 0.0, 0.5)
	info_frame_style.set_corner_radius_all(6)
	
	var info1_frame = Panel.new()
	info1_frame.name = "Info1Frame"
	info1_frame.size = Vector2(200, 84)
	info1_frame.position = Vector2(10, 8)
	info1_frame.add_theme_stylebox_override("panel", info_frame_style)
	top_panel.add_child(info1_frame)
	
	var info1 = VBoxContainer.new()
	info1.name = "Info1"
	info1.position = Vector2(20, 12)
	info1.add_theme_constant_override("separation", 1)
	top_panel.add_child(info1)
	
	var name_label = Label.new()
	name_label.text = GameData.current_player_name
	name_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	name_label.add_theme_font_size_override("font_size", 18)
	info1.add_child(name_label)
	
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "Ур. %d" % GameData.player_level
	level_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	level_label.add_theme_font_size_override("font_size", 14)
	info1.add_child(level_label)
	
	var exp_label = Label.new()
	exp_label.name = "ExpLabel"
	exp_label.text = "Опыт: %d / %d" % [GameData.player_exp, GameData.player_exp_to_level]
	exp_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	exp_label.add_theme_font_size_override("font_size", 12)
	info1.add_child(exp_label)
	
	var info2_frame = Panel.new()
	info2_frame.name = "Info2Frame"
	info2_frame.size = Vector2(130, 84)
	info2_frame.position = Vector2(220, 8)
	info2_frame.add_theme_stylebox_override("panel", info_frame_style)
	top_panel.add_child(info2_frame)
	
	var info2 = VBoxContainer.new()
	info2.name = "Info2"
	info2.position = Vector2(230, 35)
	info2.add_theme_constant_override("separation", 2)
	top_panel.add_child(info2)
	
	var caps_line = HBoxContainer.new()
	caps_line.add_theme_constant_override("separation", 4)
	info2.add_child(caps_line)
	
	var caps_icon = Label.new()
	caps_icon.text = "🧢"
	caps_icon.add_theme_font_size_override("font_size", 16)
	caps_line.add_child(caps_icon)
	
	var caps_val = Label.new()
	caps_val.name = "CapsVal"
	caps_val.text = "%d" % GameData.caps
	caps_val.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	caps_val.add_theme_font_size_override("font_size", 16)
	caps_line.add_child(caps_val)
	
	var muta_line = HBoxContainer.new()
	muta_line.add_theme_constant_override("separation", 4)
	info2.add_child(muta_line)
	
	var muta_icon = Label.new()
	muta_icon.text = "🧬"
	muta_icon.add_theme_font_size_override("font_size", 16)
	muta_line.add_child(muta_icon)
	
	var muta_val = Label.new()
	muta_val.name = "MutaVal"
	muta_val.text = "%d" % GameData.mutagens
	muta_val.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5, 1.0))
	muta_val.add_theme_font_size_override("font_size", 16)
	muta_line.add_child(muta_val)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	
	var buttons = [
		{"text": "САДОК\n0/20", "x": 800},
		{"text": "ИНВЕНТАРЬ", "x": 930},
		{"text": "КАРТА", "x": 1050},
		{"text": "СНАСТИ", "x": 1170},
	]
	
	for bt in buttons:
		var btn = Button.new()
		btn.text = bt["text"]
		btn.custom_minimum_size = Vector2(100, 80)
		btn.position = Vector2(bt["x"], 10)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 0.9))
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_constant_override("content_margin_top", 6)
		if bt["text"].begins_with("САДОК"):
			btn.add_theme_font_size_override("font_size", 11)
		if bt["text"].begins_with("САДОК"):
			btn.pressed.connect(_on_top_button_pressed.bind("САДОК"))
		else:
			btn.pressed.connect(_on_top_button_pressed.bind(bt["text"]))
		top_panel.add_child(btn)


func _build_side_panels():
	var panel_data = [
		{"name": "ЛеваяПанель", "x": 0},
		{"name": "ПраваяПанель", "x": 1160},
	]
	for pd in panel_data:
		var panel = ColorRect.new()
		panel.name = pd["name"]
		panel.color = Color(0.4, 0.3, 0.2, 1.0)
		panel.size = Vector2(120, 620)
		panel.position = Vector2(pd["x"], 100)
		add_child(panel)


func rebuild_player_info():
	var top_panel = get_node("ВерхняяПанель")
	var info1 = top_panel.get_node("Info1")
	info1.get_child(0).text = GameData.current_player_name
	info1.get_node("LevelLabel").text = "Ур. %d" % GameData.player_level
	info1.get_node("ExpLabel").text = "Опыт: %d / %d" % [GameData.player_exp, GameData.player_exp_to_level]
	var info2 = top_panel.get_node("Info2")
	var caps_line = info2.get_child(0)
	caps_line.get_node("CapsVal").text = "%d" % GameData.caps
	var muta_line = info2.get_child(1)
	muta_line.get_node("MutaVal").text = "%d" % GameData.mutagens
	update_cage_button()


func _on_top_button_pressed(button_name: String):
	match button_name:
		"САДОК":
			UIManager.toggle_cage()
		"ИНВЕНТАРЬ":
			UIManager.toggle_inventory()
		"КАРТА":
			UIManager.toggle_map()
		"СНАСТИ":
			UIManager.toggle_gear_setup()
				
				
				
func update_cage_button():
	var top_panel = get_node("ВерхняяПанель")
	for child in top_panel.get_children():
		if child is Button and child.text.begins_with("САДОК"):
			child.text = "САДОК\n%d/%d" % [GameData.fish_cage.size(), GameData.cage_capacity]
			return
