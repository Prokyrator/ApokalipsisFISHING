extends Node2D

func _ready():
	GlobalLogger.log("=== BunkerScene ready ===")
	_build_interface()
	call_deferred("_setup_ui")


func _setup_ui():
	var fishing_layer = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
	if fishing_layer:
		fishing_layer.visible = false


func _build_interface():
	var ui = Control.new()
	ui.name = "Интерфейс"
	ui.layout_mode = 3
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ui)
	
	var bg = ColorRect.new()
	bg.name = "Фон"
	bg.color = Color(0.08, 0.08, 0.08, 1.0)
	bg.size = get_viewport_rect().size
	bg.position = Vector2.ZERO
	ui.add_child(bg)
	
	var title = Label.new()
	title.name = "Заголовок"
	title.text = "БУНКЕР"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(1280, 100)
	title.position = Vector2.ZERO
	ui.add_child(title)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	btn_style.border_width_left = 3
	btn_style.border_width_right = 3
	btn_style.border_width_top = 3
	btn_style.border_width_bottom = 3
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.8)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn_style.corner_radius_bottom_right = 8
	
	var hover_style = btn_style.duplicate()
	hover_style.bg_color = Color(0.25, 0.25, 0.25, 0.9)
	hover_style.border_color = Color(1.0, 0.9, 0.0, 1.0)
	
	var buttons = [
		{"text": "ТОРГОВЕЦ", "y": 250},
		{"text": "ВЕРСТАК", "y": 350},
		{"text": "ДОСКА КВЕСТОВ", "y": 450},
	]
	
	for bt in buttons:
		var btn = Button.new()
		btn.text = bt["text"]
		btn.custom_minimum_size = Vector2(300, 60)
		btn.position = Vector2(490, bt["y"])
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
		btn.add_theme_font_size_override("font_size", 22)
		if bt["text"] == "ТОРГОВЕЦ":
			btn.pressed.connect(_on_trader_pressed)
		ui.add_child(btn)
		if bt["text"] == "ВЕРСТАК":
			btn.pressed.connect(_on_workbench_pressed)


func _on_trader_pressed():
	UIManager.toggle_trader()

func _on_workbench_pressed():
	UIManager.toggle_workbench()
