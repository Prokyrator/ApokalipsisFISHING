extends Control

var name_input: LineEdit
var greeting_label: Label
var play_btn: Button
var login_btn: Button
var error_label: Label

const MIN_NAME_LENGTH = 2
const MAX_NAME_LENGTH = 16


func _ready():
	_build_window()
	_check_existing_user()


func _check_existing_user():
	var current_file = FileAccess.open("user://current_user.json", FileAccess.READ)
	if current_file:
		var data = JSON.parse_string(current_file.get_as_text())
		current_file.close()
		if data and data.has("name"):
			_show_greeting(data["name"])
			return
	_show_login()


func _build_window():
	custom_minimum_size = Vector2(500, 350)
	position = Vector2(390, 185)
	
	var panel = Panel.new()
	panel.size = Vector2(500, 350)
	panel.position = Vector2.ZERO
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(1.0, 0.78, 0.0, 1.0)
	panel_style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	
	var title = Label.new()
	title.text = "Рыбалка Апокалипсис"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(500, 50)
	title.position = Vector2(0, 20)
	add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Бункер выжившего"
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.size = Vector2(500, 30)
	subtitle.position = Vector2(0, 65)
	add_child(subtitle)
	
	name_input = LineEdit.new()
	name_input.placeholder_text = "Введите ваше имя..."
	name_input.custom_minimum_size = Vector2(300, 45)
	name_input.position = Vector2(100, 120)
	name_input.max_length = MAX_NAME_LENGTH
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	input_style.border_width_left = 2
	input_style.border_width_right = 2
	input_style.border_width_top = 2
	input_style.border_width_bottom = 2
	input_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	input_style.set_corner_radius_all(6)
	name_input.add_theme_stylebox_override("normal", input_style)
	name_input.add_theme_stylebox_override("focus", input_style)
	name_input.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	name_input.add_theme_color_override("font_placeholder_color", Color(0.5, 0.5, 0.5, 0.6))
	name_input.add_theme_font_size_override("font_size", 18)
	add_child(name_input)
	
	greeting_label = Label.new()
	greeting_label.text = ""
	greeting_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	greeting_label.add_theme_font_size_override("font_size", 24)
	greeting_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	greeting_label.size = Vector2(500, 50)
	greeting_label.position = Vector2(0, 130)
	greeting_label.visible = false
	add_child(greeting_label)
	
	login_btn = Button.new()
	login_btn.text = "Войти"
	login_btn.custom_minimum_size = Vector2(200, 50)
	login_btn.position = Vector2(150, 190)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.6, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	btn_style.set_corner_radius_all(6)
	login_btn.add_theme_stylebox_override("normal", btn_style)
	login_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	login_btn.add_theme_font_size_override("font_size", 20)
	login_btn.pressed.connect(_on_login_pressed)
	add_child(login_btn)
	
	play_btn = Button.new()
	play_btn.text = "Играть"
	play_btn.custom_minimum_size = Vector2(200, 50)
	play_btn.position = Vector2(150, 200)
	play_btn.add_theme_stylebox_override("normal", btn_style)
	play_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	play_btn.add_theme_font_size_override("font_size", 20)
	play_btn.pressed.connect(_on_play_pressed)
	play_btn.visible = false
	add_child(play_btn)
	
	error_label = Label.new()
	error_label.text = ""
	error_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
	error_label.add_theme_font_size_override("font_size", 14)
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.size = Vector2(500, 30)
	error_label.position = Vector2(0, 255)
	error_label.visible = false
	add_child(error_label)


func _show_login():
	name_input.visible = true
	login_btn.visible = true
	greeting_label.visible = false
	play_btn.visible = false


func _show_greeting(name: String):
	name_input.visible = false
	login_btn.visible = false
	greeting_label.text = "Добро пожаловать, %s!" % name
	greeting_label.visible = true
	play_btn.visible = true
	GameData.current_player_name = name
	GameData._load_player_data()
	
	# Обновляем интерфейс
	var interface_layer = get_node_or_null("/root/GlobalUi/UILayer/СлойИнтерфейса")
	if interface_layer and interface_layer.has_method("rebuild_player_info"):
		interface_layer.call_deferred("rebuild_player_info")


func _on_login_pressed():
	var name = name_input.text.strip_edges()
	
	if name.length() < MIN_NAME_LENGTH:
		_show_error("Имя должно быть не короче %d символов" % MIN_NAME_LENGTH)
		return
	
	if not _is_valid_name(name):
		_show_error("Имя содержит недопустимые символы")
		return
	
	var file = FileAccess.open("user://current_user.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"name": name}))
	file.close()
	
	_show_greeting(name)


func _on_play_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://scenes/bunker.tscn")


func _show_error(text: String):
	error_label.text = text
	error_label.visible = true
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3.0
	timer.timeout.connect(func(): error_label.visible = false)
	add_child(timer)
	timer.start()


func _is_valid_name(name: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Zа-яА-Я0-9 _-]+$")
	return regex.search(name) != null
