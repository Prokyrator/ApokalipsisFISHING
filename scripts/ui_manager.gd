extends Node

## Сигналы для внешних скриптов
signal inventory_toggled(visible: bool)
signal map_toggled(visible: bool)
signal gear_setup_toggled(visible: bool)
signal cage_toggled(visible: bool)
signal trader_toggled(visible: bool)
signal workbench_toggled(visible: bool)

## Кэш ссылок на панели
var ui_layer: CanvasLayer = null
var top_panel: Control = null
var fishing_layer: Control = null
var inventory_panel: Control = null
var map_panel: Control = null
var gear_setup_panel: Control = null
var quick_slots_bar: Control = null
var fishing_hints: Control = null
var message_panel: Control = null

## Динамически создаваемые панели
var cage_panel: Control = null
var trader_panel: Control = null
var workbench_panel: Control = null


func _ready():
	call_deferred("_cache_all_panels")


func _cache_all_panels():
	ui_layer = get_node_or_null("/root/GlobalUi/UILayer")
	if not ui_layer:
		GlobalLogger.log("[UIManager] UILayer не найден!")
		return
	
	top_panel = ui_layer.get_node_or_null("СлойИнтерфейса")
	fishing_layer = ui_layer.get_node_or_null("СлойСнасти")
	inventory_panel = ui_layer.get_node_or_null("СлойИнвентаря")
	map_panel = ui_layer.get_node_or_null("СлойКарты")
	gear_setup_panel = ui_layer.get_node_or_null("СлойСнастиНастройка")
	quick_slots_bar = ui_layer.get_node_or_null("QuickSlotsBar")
	fishing_hints = ui_layer.get_node_or_null("FishingHints")
	message_panel = ui_layer.get_node_or_null("MessagePanel")
	
	GlobalLogger.log("[UIManager] Панели закэшированы")
	GameData.fish_cage_changed.connect(_on_fish_cage_changed)


## Закрыть все панели кроме исключения
func close_all_panels(except: Control = null):
	var panels = [inventory_panel, map_panel, gear_setup_panel, cage_panel, trader_panel, workbench_panel]
	for panel in panels:
		if panel and panel != except and is_instance_valid(panel):
			panel.visible = false


## Переключить видимость панели
func toggle_panel(panel: Control, panel_name: String) -> bool:
	if not panel or not is_instance_valid(panel):
		return false
	var new_visible = not panel.visible
	close_all_panels(panel if new_visible else null)
	panel.visible = new_visible
	if new_visible:
		panel.z_index = 100
		if panel.has_method("refresh"):
			panel.refresh()
	return new_visible


## === Команды открытия/закрытия ===

func toggle_inventory():
	if not inventory_panel or not is_instance_valid(inventory_panel):
		return
	var new_visible = toggle_panel(inventory_panel, "инвентарь")
	inventory_toggled.emit(new_visible)
	if fishing_layer and is_instance_valid(fishing_layer):
		fishing_layer.visible = not new_visible
	if quick_slots_bar and is_instance_valid(quick_slots_bar):
		quick_slots_bar.visible = not new_visible
	if new_visible and inventory_panel.has_method("refresh"):
		inventory_panel.refresh()


func toggle_map():
	if not map_panel or not is_instance_valid(map_panel):
		return
	var new_visible = toggle_panel(map_panel, "карта")
	map_toggled.emit(new_visible)
	if fishing_layer and is_instance_valid(fishing_layer):
		fishing_layer.visible = not new_visible
	if quick_slots_bar and is_instance_valid(quick_slots_bar):
		quick_slots_bar.visible = not new_visible


func toggle_gear_setup():
	if not gear_setup_panel or not is_instance_valid(gear_setup_panel):
		return
	var new_visible = toggle_panel(gear_setup_panel, "снасти")
	gear_setup_toggled.emit(new_visible)
	if new_visible and gear_setup_panel.has_method("refresh"):
		gear_setup_panel.refresh()


func toggle_cage():
	if not cage_panel:
		cage_panel = _create_panel("CagePanel", "res://scripts/cage_panel.gd")
		if not cage_panel:
			return
	var new_visible = toggle_panel(cage_panel, "садок")
	cage_toggled.emit(new_visible)
	if new_visible and cage_panel.has_method("refresh"):
		cage_panel.refresh()
	if quick_slots_bar and is_instance_valid(quick_slots_bar):
		quick_slots_bar.visible = not new_visible


func toggle_trader():
	if not trader_panel:
		trader_panel = _create_panel("TraderPanel", "res://scripts/trader_panel.gd")
		if not trader_panel:
			return
	var new_visible = toggle_panel(trader_panel, "торговец")
	trader_toggled.emit(new_visible)
	if new_visible and trader_panel.has_method("refresh"):
		trader_panel.refresh()


func toggle_workbench():
	if not workbench_panel:
		workbench_panel = _create_panel("WorkbenchPanel", "res://scripts/workbench_panel.gd")
		if not workbench_panel:
			return
	var new_visible = toggle_panel(workbench_panel, "верстак")
	workbench_toggled.emit(new_visible)
	if new_visible and workbench_panel.has_method("refresh"):
		workbench_panel.refresh()


func _create_panel(name: String, script_path: String) -> Control:
	if not ui_layer:
		return null
	var panel = Control.new()
	panel.name = name
	panel.set_script(load(script_path))
	ui_layer.add_child(panel)
	return panel


## Обновить кнопку садка на верхней панели
func update_cage_button():
	if top_panel and is_instance_valid(top_panel) and top_panel.has_method("update_cage_button"):
		top_panel.update_cage_button()


## Обновить инфу игрока на верхней панели
func rebuild_player_info():
	if top_panel and is_instance_valid(top_panel) and top_panel.has_method("rebuild_player_info"):
		top_panel.rebuild_player_info()


## === Геттеры для внешних скриптов ===

func get_fishing_layer() -> Control:
	return fishing_layer

func get_message_panel() -> Control:
	return message_panel

func get_quick_slots_bar() -> Control:
	return quick_slots_bar

func is_any_window_open() -> bool:
	var panels = [inventory_panel, map_panel, gear_setup_panel, cage_panel, trader_panel, workbench_panel]
	for panel in panels:
		if panel and is_instance_valid(panel) and panel.visible:
			return true
	return false

func _on_fish_cage_changed():
	update_cage_button()
