extends Control

const TOAST_MAX_WIDTH = 350
const TOAST_MIN_WIDTH = 150
const TOAST_HEIGHT = 28
const TOAST_GAP = 6
const TOAST_DISPLAY_TIME = 5.0
const TOAST_FADE_TIME = 0.5
const MAX_TOASTS = 5
const PADDING = 20

enum MsgType { SUCCESS, WARNING, ERROR, TROPHY, MEGA, BOSS }

const ICONS = {
	MsgType.SUCCESS: "✔",
	MsgType.WARNING: "⚠",
	MsgType.ERROR: "✖",
	MsgType.TROPHY: "★",
	MsgType.MEGA: "✦",
	MsgType.BOSS: "☠",
}
const COLORS = {
	MsgType.SUCCESS: Color(0.2, 1.0, 0.2, 1.0),
	MsgType.WARNING: Color(1.0, 0.9, 0.2, 1.0),
	MsgType.ERROR: Color(1.0, 0.2, 0.2, 1.0),
	MsgType.TROPHY: Color(1.0, 0.85, 0.0, 1.0),
	MsgType.MEGA: Color(0.7, 0.2, 1.0, 1.0),
	MsgType.BOSS: Color(1.0, 0.3, 0.0, 1.0),
}

var active_toasts: Array = []


func _ready():
	visible = true
	layout_mode = 0
	position = Vector2(1160 - TOAST_MAX_WIDTH - 10, 110)
	z_index = 500


func add_message(text: String, type: int = MsgType.WARNING):
	var toast = _create_toast(text, type)
	add_child(toast)
	active_toasts.append(toast)
	_reposition_toasts()
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = TOAST_DISPLAY_TIME
	timer.timeout.connect(_fade_toast.bind(toast, timer))
	add_child(timer)
	timer.start()
	
	toast.modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(toast, "modulate:a", 1.0, TOAST_FADE_TIME)
	
	while active_toasts.size() > MAX_TOASTS:
		var oldest = active_toasts.pop_front()
		if oldest and is_instance_valid(oldest):
			oldest.queue_free()


func _create_toast(text: String, type: int) -> Control:
	var font = ThemeDB.fallback_font
	var text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var toast_width = clampf(text_width + PADDING * 2 + 30, TOAST_MIN_WIDTH, TOAST_MAX_WIDTH)
	var color = COLORS.get(type, COLORS[MsgType.WARNING])
	
	var toast = Control.new()
	toast.custom_minimum_size = Vector2(toast_width, TOAST_HEIGHT)
	
	var bg = Panel.new()
	bg.size = Vector2(toast_width, TOAST_HEIGHT)
	bg.position = Vector2.ZERO
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = color
	style.set_corner_radius_all(8)
	bg.add_theme_stylebox_override("panel", style)
	toast.add_child(bg)
	
	var icon = Label.new()
	icon.text = ICONS.get(type, ICONS[MsgType.WARNING])
	icon.add_theme_font_size_override("font_size", 14)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.size = Vector2(24, TOAST_HEIGHT)
	icon.position = Vector2(6, 0)
	icon.add_theme_color_override("font_color", color)
	toast.add_child(icon)
	
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(toast_width - 36, TOAST_HEIGHT)
	label.position = Vector2(30, 0)
	label.add_theme_color_override("font_color", color)
	toast.add_child(label)
	
	return toast


func _reposition_toasts():
	var y_offset = 0.0
	for toast in active_toasts:
		if toast and is_instance_valid(toast):
			toast.position = Vector2(TOAST_MAX_WIDTH - toast.custom_minimum_size.x, y_offset)
			y_offset += TOAST_HEIGHT + TOAST_GAP


func _fade_toast(toast: Control, timer: Timer):
	if not toast or not is_instance_valid(toast):
		if timer and is_instance_valid(timer):
			timer.queue_free()
		return
	
	active_toasts.erase(toast)
	var t = create_tween()
	t.tween_property(toast, "modulate:a", 0.0, TOAST_FADE_TIME)
	t.tween_callback(toast.queue_free)
	
	if timer and is_instance_valid(timer):
		timer.queue_free()
