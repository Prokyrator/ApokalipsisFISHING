extends Button

func _ready():
	pressed.connect(_on_close_pressed)
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(1.0, 0.78, 0.0, 1)
	normal_style.border_width_left = 3
	normal_style.border_width_right = 3
	normal_style.border_width_top = 3
	normal_style.border_width_bottom = 3
	normal_style.border_color = Color(1.0, 0.0, 0.0, 1)
	normal_style.corner_radius_top_left = 6
	normal_style.corner_radius_top_right = 6
	normal_style.corner_radius_bottom_left = 6
	normal_style.corner_radius_bottom_right = 6
	add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.0, 0.8, 0.0, 1)
	add_theme_stylebox_override("hover", hover_style)
	
	add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1))
	add_theme_font_size_override("font_size", 28)


func _on_close_pressed():
	var inv = get_node_or_null("/root/GlobalUi/UILayer/СлойИнвентаря")
	var map_panel = get_node_or_null("/root/GlobalUi/UILayer/СлойКарты")
	var gear_setup = get_node_or_null("/root/GlobalUi/UILayer/СлойСнастиНастройка")
	if inv: inv.visible = false
	if map_panel: map_panel.visible = false
	if gear_setup: gear_setup.visible = false
	var fishing_layer = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
	if fishing_layer: fishing_layer.visible = true
	visible = false
