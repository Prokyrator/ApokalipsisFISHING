extends Control

var map_texture: TextureRect
var map_frame: Panel
var location_buttons: Array = []
var confirm_dialog: Control = null

const LOCATIONS = [
	{"name": "Болото", "x": 350, "y": 300, "scene": "res://scenes/lake.tscn"},
	{"name": "Бункер", "x": 700, "y": 150, "scene": "res://scenes/bunker.tscn"},
]


func _ready():
	visible = false
	_build_window()


func _build_window():
	custom_minimum_size = Vector2(1040, 620)
	position = Vector2(120, 100)
	
	map_texture = TextureRect.new()
	map_texture.name = "ФонКарты"
	map_texture.size = Vector2(1040, 620)
	map_texture.position = Vector2.ZERO
	map_texture.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	map_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	var tex = load("res://assets/textures/backgrounds/map_bg.jpg")
	if tex:
		map_texture.texture = tex
	else:
		var bg = ColorRect.new()
		bg.color = Color(0.1, 0.15, 0.1, 1.0)
		bg.size = Vector2(1040, 620)
		bg.position = Vector2.ZERO
		add_child(bg)
	add_child(map_texture)
	
	map_frame = Panel.new()
	map_frame.name = "РамкаКарты"
	map_frame.size = Vector2(1040, 620)
	map_frame.position = Vector2.ZERO
	var frame_style = StyleBoxFlat.new()
	frame_style.bg_color = Color(0, 0, 0, 0)
	frame_style.border_width_left = 4
	frame_style.border_width_right = 4
	frame_style.border_width_top = 4
	frame_style.border_width_bottom = 4
	frame_style.border_color = Color(1.0, 0.78, 0.0, 1.0)
	map_frame.add_theme_stylebox_override("panel", frame_style)
	add_child(map_frame)
	
	for loc in LOCATIONS:
		_create_location_marker(loc)
	
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.position = Vector2(990, 10)
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.8, 0.2, 0.2, 0.9)
	close_style.corner_radius_top_left = 6
	close_style.corner_radius_top_right = 6
	close_style.corner_radius_bottom_left = 6
	close_style.corner_radius_bottom_right = 6
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.pressed.connect(_on_close_pressed)
	add_child(close_btn)
	
	var title = Label.new()
	title.text = "КАРТА"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(1040, 40)
	title.position = Vector2(0, 10)
	add_child(title)


func _create_location_marker(loc: Dictionary):
	var btn = Button.new()
	btn.text = loc["name"]
	btn.custom_minimum_size = Vector2(140, 30)
	btn.position = Vector2(loc["x"], loc["y"])
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.7)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.78, 0.0, 0.8)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	hover_style.border_color = Color(1.0, 0.9, 0.0, 1.0)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	btn.add_theme_font_size_override("font_size", 11)
	btn.pressed.connect(_on_location_pressed.bind(loc))
	add_child(btn)
	location_buttons.append(btn)


func _on_location_pressed(loc: Dictionary):
	if loc["scene"] != "":
		_show_confirm_dialog(loc)


func _on_close_pressed():
	visible = false
	var fishing_layer = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
	if fishing_layer:
		fishing_layer.visible = true


func _show_confirm_dialog(loc: Dictionary):
	if confirm_dialog:
		confirm_dialog.queue_free()
	
	confirm_dialog = Control.new()
	confirm_dialog.name = "ConfirmDialog"
	confirm_dialog.z_index = 200
	
	var panel = Panel.new()
	panel.size = Vector2(400, 150)
	panel.position = Vector2(320, 235)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.05, 0.95)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(1.0, 0.78, 0.0, 1.0)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	confirm_dialog.add_child(panel)
	
	var label = Label.new()
	label.text = "Перейти на %s?" % loc["name"]
	label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	label.add_theme_font_size_override("font_size", 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(400, 50)
	label.position = Vector2(320, 250)
	confirm_dialog.add_child(label)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.8)
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	
	var yes_btn = Button.new()
	yes_btn.text = "ДА"
	yes_btn.custom_minimum_size = Vector2(120, 45)
	yes_btn.position = Vector2(380, 310)
	yes_btn.add_theme_stylebox_override("normal", btn_style)
	var yes_hover = btn_style.duplicate()
	yes_hover.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	yes_btn.add_theme_stylebox_override("hover", yes_hover)
	yes_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2, 1.0))
	yes_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	yes_btn.add_theme_font_size_override("font_size", 18)
	yes_btn.pressed.connect(_on_confirm_yes.bind(loc))
	confirm_dialog.add_child(yes_btn)
	
	var no_btn = Button.new()
	no_btn.text = "НЕТ"
	no_btn.custom_minimum_size = Vector2(120, 45)
	no_btn.position = Vector2(540, 310)
	no_btn.add_theme_stylebox_override("normal", btn_style)
	var no_hover = btn_style.duplicate()
	no_hover.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	no_btn.add_theme_stylebox_override("hover", no_hover)
	no_btn.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
	no_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	no_btn.add_theme_font_size_override("font_size", 18)
	no_btn.pressed.connect(_on_confirm_no)
	confirm_dialog.add_child(no_btn)
	
	add_child(confirm_dialog)


func _on_confirm_yes(loc: Dictionary):
	if confirm_dialog:
		confirm_dialog.queue_free()
		confirm_dialog = null
	visible = false
	
	# Останавливаем все активные рыбалки
	var fishing_gear = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
	if fishing_gear:
		for gear in fishing_gear.active_gears:
			if gear and typeof(gear) == TYPE_DICTIONARY:
				fishing_gear.bite_system.stop_bite_timer(gear)
				fishing_gear.minigame_ui.cleanup(gear)
		fishing_gear.active_gears.clear()
	
	get_tree().change_scene_to_file(loc["scene"])


func _on_confirm_no():
	if confirm_dialog:
		confirm_dialog.queue_free()
		confirm_dialog = null


func refresh():
	pass
