extends Node2D

@export var water_polygon: Polygon2D

func _ready():
	if not water_polygon:
		for child in get_children():
			if child is Polygon2D:
				water_polygon = child
				break
	
	if water_polygon:
		var fishing_gear = get_node("/root/GlobalUi/UILayer/СлойСнасти")
		if fishing_gear and fishing_gear.has_method("set_water_zone"):
			fishing_gear.set_water_zone(self)
	else:
		GlobalLogger.log("ERROR: WaterZone — Polygon2D не найден!")
