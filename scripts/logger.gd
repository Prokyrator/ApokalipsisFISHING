extends Node

var enabled: bool = true
var start_time: float = 0.0


func _ready():
	start_time = Time.get_ticks_msec() / 1000.0


func log(msg: String):
	if not enabled:
		return
	var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
	print("[%06.1fs] %s" % [elapsed, msg])
