extends Node2D

onready var control = $CenterContainer/Controller

func _ready():
	#Engine.set_time_scale(0.01)
	pass

func _process(delta):
	$SpritePanelBg/Pointer.rect_rotation =  ($CenterContainer/joypad.acceleration-160)*2#-300 -105
	$SpritePanelBg/Pointer.rect_rotation = clamp($SpritePanelBg/Pointer.rect_rotation,-300, -105)
	for n in $SpritePanelBg/Gears.get_children():
		if n != $"SpritePanelBg/Gears/1":
			n.self_modulate.a = 0.1
	
	for n in range(1,$CenterContainer/joypad.gear+1):
		$SpritePanelBg/Gears.get_child(n-1).self_modulate.a = 1
	
	if $CenterContainer/joypad.mode == "1":
		$SpritePanelBg/HighLight.rect_position.x = -13500000
	elif $CenterContainer/joypad.mode == "2":
		$SpritePanelBg/HighLight.rect_position.x = -135
	elif $CenterContainer/joypad.mode == "3":
		$SpritePanelBg/HighLight.rect_position.x = -116.105
	#var x_r = control.x_g
	#var y_r = control.y_g
	#var z_r = control.z_g
	#$MeshInstance.rotation_degrees.y = z_r
	#$Throttlebar.value = control.throttle
	#$SignalBar.value = control.sStrength
	pass
