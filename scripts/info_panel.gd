extends Control

var cut_progress: float = 0.0
var is_cutting: bool = false

const KEY_SIZE = 36
const LINE_COLOR = Color(1.0, 0.78, 0.0, 0.3)
const KEY_BG = Color(0.15, 0.15, 0.15, 0.9)
const KEY_BORDER = Color(1.0, 0.78, 0.0, 0.7)
const HINT_COLOR = Color(1.0, 1.0, 1.0, 0.7)


func _ready():
	_build_left_panel()
	_build_right_panel()


func _build_left_panel():
	var hints = [
		{"key": "G", "text": "Удилище"},
		{"key": "H", "text": "Катушка"},
		{"key": "␣", "text": "Подсечка"},
	]
	
	var panel_center_x = 60
	var start_y = 260
	
	for i in range(hints.size()):
		var h = hints[i]
		var y = start_y + i * 75
		
		if i > 0:
			var line = ColorRect.new()
			line.color = LINE_COLOR
			line.size = Vector2(80, 1)
			line.position = Vector2(panel_center_x - 40, y - 10)
			add_child(line)
		
		var key_x = panel_center_x - KEY_SIZE / 2
		
		var key_btn = Button.new()
		key_btn.text = h["key"]
		key_btn.custom_minimum_size = Vector2(KEY_SIZE, KEY_SIZE)
		key_btn.position = Vector2(key_x, y)
		key_btn.disabled = true
		var key_style = StyleBoxFlat.new()
		key_style.bg_color = KEY_BG
		key_style.border_width_left = 2
		key_style.border_width_right = 2
		key_style.border_width_top = 2
		key_style.border_width_bottom = 2
		key_style.border_color = KEY_BORDER
		key_style.set_corner_radius_all(6)
		key_btn.add_theme_stylebox_override("normal", key_style)
		key_btn.add_theme_stylebox_override("disabled", key_style)
		key_btn.add_theme_color_override("font_color", KEY_BORDER)
		key_btn.add_theme_color_override("font_disabled_color", KEY_BORDER)
		key_btn.add_theme_font_size_override("font_size", 16)
		add_child(key_btn)
		
		var hint_label = Label.new()
		hint_label.text = h["text"]
		hint_label.add_theme_color_override("font_color", HINT_COLOR)
		hint_label.add_theme_font_size_override("font_size", 12)
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_label.size = Vector2(120, 20)
		hint_label.position = Vector2(0, y + KEY_SIZE + 4)
		add_child(hint_label)


func _build_right_panel():
	var hints = [
		{"key": "␣", "text": "Повт. заброс"},
		{"key": "R", "text": "Обрезать", "hold": true},
	]
	
	var panel_center_x = 1220
	var start_y = 300
	
	for i in range(hints.size()):
		var h = hints[i]
		var y = start_y + i * 75
		
		if i > 0:
			var line = ColorRect.new()
			line.color = LINE_COLOR
			line.size = Vector2(80, 1)
			line.position = Vector2(panel_center_x - 40, y - 14)
			add_child(line)
		
		var key_x = panel_center_x - KEY_SIZE / 2
		
		if h.get("hold"):
			var fill_width = KEY_SIZE + 12
			var fill_height = KEY_SIZE + 12
			var fill_x = key_x - 6
			var fill_y = y - 6
			
			var circle_bg = Panel.new()
			circle_bg.name = "CutCircleBg"
			circle_bg.size = Vector2(fill_width, fill_height)
			circle_bg.position = Vector2(fill_x, fill_y)
			var bg_style = StyleBoxFlat.new()
			bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
			bg_style.border_width_left = 2
			bg_style.border_width_right = 2
			bg_style.border_width_top = 2
			bg_style.border_width_bottom = 2
			bg_style.border_color = Color(1.0, 0.78, 0.0, 0.5)
			bg_style.set_corner_radius_all(8)
			circle_bg.add_theme_stylebox_override("panel", bg_style)
			add_child(circle_bg)
			
			var circle_fill = Panel.new()
			circle_fill.name = "CutCircleFill"
			circle_fill.size = Vector2(0, fill_height)
			circle_fill.position = Vector2(fill_x, fill_y)
			var fill_style = StyleBoxFlat.new()
			fill_style.bg_color = Color(1.0, 0.1, 0.1, 0.9)
			fill_style.set_corner_radius_all(8)
			circle_fill.add_theme_stylebox_override("panel", fill_style)
			circle_fill.clip_contents = true
			add_child(circle_fill)
		
		var key_btn = Button.new()
		key_btn.text = h["key"]
		key_btn.custom_minimum_size = Vector2(KEY_SIZE, KEY_SIZE)
		key_btn.position = Vector2(key_x, y)
		key_btn.disabled = true
		var key_style = StyleBoxFlat.new()
		key_style.bg_color = KEY_BG
		key_style.border_width_left = 2
		key_style.border_width_right = 2
		key_style.border_width_top = 2
		key_style.border_width_bottom = 2
		key_style.border_color = KEY_BORDER
		key_style.set_corner_radius_all(6)
		key_btn.add_theme_stylebox_override("normal", key_style)
		key_btn.add_theme_stylebox_override("disabled", key_style)
		key_btn.add_theme_color_override("font_color", KEY_BORDER)
		key_btn.add_theme_color_override("font_disabled_color", KEY_BORDER)
		key_btn.add_theme_font_size_override("font_size", 16)
		key_btn.z_index = 1
		add_child(key_btn)
		
		var hint_label = Label.new()
		hint_label.text = h["text"]
		hint_label.add_theme_color_override("font_color", HINT_COLOR)
		hint_label.add_theme_font_size_override("font_size", 12)
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_label.size = Vector2(120, 20)
		hint_label.position = Vector2(1160, y + KEY_SIZE + 4)
		add_child(hint_label)
		
		if h.get("hold"):
			var hold_label = Label.new()
			hold_label.text = "удерж."
			hold_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.2, 0.7))
			hold_label.add_theme_font_size_override("font_size", 10)
			hold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hold_label.size = Vector2(120, 14)
			hold_label.position = Vector2(1160, y + KEY_SIZE + 22)
			add_child(hold_label)


func _process(_delta):
	var is_pressing = Input.is_key_pressed(KEY_R)
	
	if is_pressing:
		is_cutting = true
		cut_progress = minf(cut_progress + _delta, 2.0)
	else:
		is_cutting = false
		cut_progress = maxf(cut_progress - _delta * 2, 0.0)
	
	var circle_fill = get_node_or_null("CutCircleFill")
	if circle_fill:
		var max_width = KEY_SIZE + 12
		circle_fill.size.x = max_width * (cut_progress / 2.0)
	
	var is_bunker = false
	if get_tree().current_scene:
		is_bunker = get_tree().current_scene.name == "BunkerScene"
	visible = not is_bunker
