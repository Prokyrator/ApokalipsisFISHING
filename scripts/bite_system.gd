extends Node

signal bite_started(gear)
signal bite_missed(gear)
signal bite_hooked(gear)

var active_timers: Dictionary = {}

const TEST_MAX_WAIT = 3.0


func start_bite_timer(gear, float_node, float_original_pos):
	if not gear or typeof(gear) != TYPE_DICTIONARY:
		return
	
	var slot = gear.get("slot", -1)
	stop_bite_timer(gear)
	
	var fish = FishData.get_random_fish()
	gear["current_fish"] = fish
	
	var wait_min = fish.get("wait_min", 2.0)
	var wait_max = fish.get("wait_max", 15.0)
	var wait_time = randf_range(wait_min, wait_max)
	wait_time = minf(wait_time, TEST_MAX_WAIT)
	GlobalLogger.log("[BiteSystem] Ожидание поклёвки: %.1f сек. Рыба: %s" % [wait_time, fish["name"]])
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_time
	timer.timeout.connect(_on_bite_start.bind(gear, float_node, float_original_pos))
	add_child(timer)
	timer.start()
	
	active_timers[slot] = {
		"bite_timer": timer,
		"window_timer": null,
		"bite_tween": null
	}


func _on_bite_start(gear, float_node, float_original_pos):
	if not gear or typeof(gear) != TYPE_DICTIONARY:
		return
	if gear.get("in_minigame"):
		return
	
	gear["is_biting"] = true
	
	var fish = gear["current_fish"]
	if not fish:
		return
	
	GlobalLogger.log("[BiteSystem] ПОКЛЁВКА! %s — жми ПРОБЕЛ!" % fish["name"])
	
	var slot = gear.get("slot", -1)
	
	if float_node and is_instance_valid(float_node):
		var original_pos = float_original_pos if float_original_pos else float_node.position
		var tween = create_tween()
		tween.set_loops(999)
		tween.tween_property(float_node, "position:y", original_pos.y - 10, 0.1)
		tween.tween_property(float_node, "position:y", original_pos.y + 5, 0.1)
		tween.tween_property(float_node, "position:y", original_pos.y, 0.1)
		
		if active_timers.has(slot):
			active_timers[slot]["bite_tween"] = tween
		
		float_node.color = Color(1.0, 1.0, 0.0, 1.0)
	
	var window_timer = Timer.new()
	window_timer.one_shot = true
	window_timer.wait_time = fish.get("bite_time", 5.0)
	window_timer.timeout.connect(_on_bite_missed.bind(gear))
	add_child(window_timer)
	window_timer.start()
	
	if active_timers.has(slot):
		active_timers[slot]["window_timer"] = window_timer
	
	bite_started.emit(gear)


func _on_bite_missed(gear):
	if not gear or typeof(gear) != TYPE_DICTIONARY:
		return
	if gear.get("in_minigame") or not gear.get("is_biting"):
		return
	
	gear["is_biting"] = false
	GlobalLogger.log("[BiteSystem] Рыба ушла!")
	bite_missed.emit(gear)
	cleanup(gear)


func on_hook(gear):
	if not gear or typeof(gear) != TYPE_DICTIONARY:
		return
	if not gear.get("is_biting"):
		return
	
	GlobalLogger.log("[BiteSystem] ПОДСЕЧКА!")
	
	var slot = gear.get("slot", -1)
	if active_timers.has(slot):
		var timers = active_timers[slot]
		
		if timers.get("bite_tween"):
			timers["bite_tween"].kill()
			timers["bite_tween"] = null
		
		if timers.get("window_timer") and is_instance_valid(timers["window_timer"]):
			timers["window_timer"].stop()
			timers["window_timer"].queue_free()
			timers["window_timer"] = null
	
	gear["is_biting"] = false
	var fish = gear.get("current_fish")
	if fish:
		var weight_data = FishData.generate_weight(fish)
		fish["caught_weight"] = weight_data["weight"]
		fish["grade"] = weight_data["grade"]
	bite_hooked.emit(gear)


func stop_bite_timer(gear):
	if not gear:
		return
	var slot = gear.get("slot", -1)
	if active_timers.has(slot):
		var timers = active_timers[slot]
		if timers.get("bite_timer") and is_instance_valid(timers["bite_timer"]):
			timers["bite_timer"].stop()
			timers["bite_timer"].queue_free()
	cleanup(gear)


func cleanup(gear):
	if not gear:
		return
	var slot = gear.get("slot", -1)
	if active_timers.has(slot):
		var timers = active_timers[slot]
		if timers.get("window_timer") and is_instance_valid(timers["window_timer"]):
			timers["window_timer"].stop()
			timers["window_timer"].queue_free()
		if timers.get("bite_tween"):
			timers["bite_tween"].kill()
		active_timers.erase(slot)
	gear["is_biting"] = false
	gear["current_fish"] = null
