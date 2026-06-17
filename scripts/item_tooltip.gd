extends Node

static func get_type_name(type: int) -> String:
	match type:
		0: return "Удилище"
		1: return "Катушка"
		2: return "Леска"
		3: return "Крючок"
		4: return "Наживка"
		5: return "Садок"
		6: return "Компонент"
	return "?"


static func show_tooltip(parent: Control, item: Dictionary):
	var tooltip = parent.get_node_or_null("Tooltip")
	if tooltip:
		tooltip.queue_free()
	
	tooltip = Control.new()
	tooltip.name = "Tooltip"
	tooltip.z_index = 200
	
	var rarity_color = GameData.get_rarity_color(item.get("rarity", 1))
	var rarity_name = GameData.get_rarity_name(item.get("rarity", 1))
	
	var lines: Array = []
	lines.append("[%s] %s" % [rarity_name, item.get("name", "???")])
	lines.append(get_type_name(item.get("type", 0)))
	
	if item.get("type") == 3:
		lines.append("Срыв: -%d%%" % int(item.get("snag_reduction", 0.1) * 100))
	elif item.get("type") == 4:
		lines.append("Кол-во: %d" % item.get("quantity", 0))
		lines.append("Скорость: -%d%%" % int((1.0 - item.get("bite_speed", 1.0)) * 100))
	elif item.get("type") == 6:
		lines.append("Грейд: %s" % item.get("grade", "?"))
	elif item.get("type") != 5:
		lines.append("Вес: %.0f кг" % item.get("weight_limit", 0))
	
	if item.get("type") == 5:
		lines.append("Вместимость: %d рыб" % item.get("capacity", 0))
	
	if item.get("max_durability", 0) > 0:
		lines.append("Прочность: %d/%d" % [item.get("durability", 0), item.get("max_durability", 0)])
	
	lines.append(item.get("description", ""))
	
	var y_offset = 5.0
	var line_height = 22.0
	
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.05, 0.95)
	bg.size = Vector2(300, lines.size() * line_height + 10)
	bg.position = Vector2.ZERO
	tooltip.add_child(bg)
	
	var title_label = Label.new()
	title_label.text = lines[0]
	title_label.add_theme_color_override("font_color", rarity_color)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.position = Vector2(10, y_offset)
	title_label.size = Vector2(280, line_height)
	tooltip.add_child(title_label)
	y_offset += line_height
	
	for i in range(1, lines.size()):
		var info_label = Label.new()
		info_label.text = lines[i]
		info_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
		info_label.add_theme_font_size_override("font_size", 12)
		info_label.position = Vector2(10, y_offset)
		info_label.size = Vector2(280, line_height)
		info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		tooltip.add_child(info_label)
		y_offset += line_height
	
	tooltip.position = parent.get_local_mouse_position() + Vector2(15, 15)
	parent.add_child(tooltip)


static func hide_tooltip(parent: Control):
	var tooltip = parent.get_node_or_null("Tooltip")
	if tooltip:
		tooltip.queue_free()
