extends Node2D

onready var map_node = get_node("/root/App/Map")

export(float) var pan_smooth := -5

var touches = {}
var touch_active = false
var current_position = Vector2(0, 0)
var last_center_pos
var vel = Vector2(0,0)


func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed == true:
		touches[event.index] = {"start": event, "current": event}
		
	if event is InputEventScreenTouch and event.pressed == false:
		touches.erase(event.index)
	if event is InputEventScreenDrag:
		touches[event.index]["current"] = event
		update_touch_info()
	if touches.size() < 2:
		touch_active = false

func _process(delta):
	if touches.size() > 1:
		update_vel(delta)
	if touches.size() == 0:
		do_real_smoothing(delta)
	

func update_touch_info():
	var avg_touch = Vector2(0, 0)
	for key in touches:
		avg_touch += touches[key].current.position
	if touches.size() > 1:
		last_center_pos = current_position
		current_position = avg_touch / touches.size()
		$Average.position = current_position
		var map_position = map_node.position
		var difference = last_center_pos - current_position

		if difference.x != 0:
			map_position.x -= difference.x
		if difference.y != 0:
			map_position.y -= difference.y
		if touch_active:
			map_node.position = map_position
		touch_active = true

func update_vel(delta):
	if touch_active:
		if last_center_pos == null:
			last_center_pos = current_position
		var move = last_center_pos - current_position
		var move_speed : Vector2 = move / delta
		vel = move_speed

func do_real_smoothing(delta : float):
	var l = vel.length()
	var move_frame = 10 * exp(pan_smooth * ((log(l/10) / pan_smooth)+delta))
	vel = vel.normalized() * move_frame
	map_node.position -= vel * delta
