extends Node2D

func _ready():
	GlobalLogger.log("=== LakeScene ready ===")
	_build_interface()
	_build_water_zone()
	
	var fishing_layer = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
	if fishing_layer:
		fishing_layer.visible = true
		
	var info_panel = Control.new()
	info_panel.name = "InfoPanel"
	info_panel.set_script(load("res://scripts/info_panel.gd"))
	info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_node("/root/GlobalUi/UILayer").add_child(info_panel)
	
	var bar = Control.new()
	bar.name = "QuickSlotsBar"
	bar.set_script(load("res://scripts/quick_slots_bar.gd"))
	get_node("/root/GlobalUi/UILayer").add_child(bar)


func _build_interface():
	var ui = Control.new()
	ui.name = "Интерфейс"
	ui.layout_mode = 3
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ui)
	
	var bg_tex = TextureRect.new()
	bg_tex.name = "ФонОзера"
	bg_tex.size = Vector2(1040, 620)
	bg_tex.position = Vector2(120, 100)
	var tex = load("res://assets/textures/backgrounds/boloto.png")
	if tex:
		bg_tex.texture = tex
	else:
		var bg_fallback = ColorRect.new()
		bg_fallback.color = Color(0.1, 0.2, 0.3, 1.0)
		bg_fallback.size = Vector2(1040, 620)
		bg_fallback.position = Vector2(120, 100)
		ui.add_child(bg_fallback)
	ui.add_child(bg_tex)
	
	var frame = Panel.new()
	frame.name = "РамкаОзера"
	frame.size = Vector2(1040, 620)
	frame.position = Vector2(120, 100)
	var frame_style = StyleBoxFlat.new()
	frame_style.bg_color = Color(0, 0, 0, 0)
	frame_style.border_width_left = 4
	frame_style.border_width_right = 4
	frame_style.border_width_top = 4
	frame_style.border_width_bottom = 4
	frame_style.border_color = Color(1.0, 0.78, 0.0, 1.0)
	frame_style.corner_radius_top_left = 6
	frame_style.corner_radius_top_right = 6
	frame_style.corner_radius_bottom_left = 6
	frame_style.corner_radius_bottom_right = 6
	frame.add_theme_stylebox_override("panel", frame_style)
	ui.add_child(frame)


func _build_water_zone():
	var water_zone = Node2D.new()
	water_zone.name = "WaterZone"
	water_zone.set_script(load("res://scripts/water_zone.gd"))
	
	var polygon = Polygon2D.new()
	polygon.name = "WaterPolygon"
	polygon.color = Color(1, 1, 1, 0.0)
	polygon.polygon = [
		Vector2(120, 401), Vector2(526, 391), Vector2(630, 394),
		Vector2(809, 397), Vector2(835, 411), Vector2(1079, 398),
		Vector2(1089, 412), Vector2(1135, 416), Vector2(1157, 418),
		Vector2(1158, 718), Vector2(123, 718)
	]
	water_zone.add_child(polygon)
	add_child(water_zone)
