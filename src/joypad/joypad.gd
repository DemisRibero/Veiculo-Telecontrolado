extends Control

export(Vector2) var right_input = Vector2()
export(Vector2) var left_input = Vector2()

var touches = {}
var sensitivity = 0.5

var LightPositions = [-4.647 + 65, 83.643 + 65, 169.608 + 65]

export(int) var direction = 0
export(String) var mode = "1"
export(bool) var pedal_pressed = false

export(float) var acceleration = 0.0  # Variável para a aceleração
var max_acceleration = 160.0  # Aceleração máxima
var acceleration_rate = 0.1  # Taxa de aceleração
var deceleration_rate = 0.5  # Taxa de desaceleração

var gear = 0

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = {
				"position": event.position,
				"last_position": event.position,
				"pressed": true,
				"control": null
			}
			
			var buttons = ["slider", "steering_wheel", "pedal"]
			var used = []
			for b in touches:
				for bu in buttons:
					if touches[b]["control"] == bu:
						used.append(bu)
			
			# Assign the touch to a specific control based on the node name
			if $Gearbox/VSlider.is_pressed() and used.find("slider") == -1:
				touches[event.index]["control"] = "slider"
			elif $Node2D2/Volante.is_pressed()  and used.find("steering_wheel") == -1:
				touches[event.index]["control"] = "steering_wheel"
			elif $Node2D/Button.is_pressed() and used.find("pedal") == -1:
				touches[event.index]["control"] = "pedal"

		else:
			touches.erase(event.index)

	elif event is InputEventScreenDrag:
		if touches.has(event.index):
			var touch_data = touches[event.index]
			var displacement = event.position - touch_data["last_position"]
			var angleX = displacement.x * sensitivity
			var angleY = displacement.y * sensitivity

			# Update last position
			touches[event.index]["last_position"] = event.position

			# Handle drag based on assigned control
			if touch_data["control"] == "slider":
				handle_slider_drag(displacement.y)
			elif touch_data["control"] == "steering_wheel":
				handle_steering_wheel_drag(displacement.x)
			elif touch_data["control"] == "pedal":
				$Node2D/Button

func handle_slider_drag(displacementY):
	$Gearbox/VSlider.position.y += displacementY * 2
	$Gearbox/VSlider.position.y = clamp($Gearbox/VSlider.position.y, -480 + 65, -225 + 65)
	update_highlight()

func handle_steering_wheel_drag(displacementX):
	$Node2D2.rect_rotation += displacementX * 0.3
	$Node2D2.rect_rotation = clamp($Node2D2.rect_rotation, -66, 66)
	direction = $Node2D2.rect_rotation

func update_highlight():
	if $Gearbox/VSlider.position.y < -400 + 65:
		$Gearbox/HighLight.rect_position.y = LightPositions[0]
		mode = "1"
	elif $Gearbox/VSlider.position.y == -400 + 65 or $Gearbox/VSlider.position.y < -320 + 65:
		$Gearbox/HighLight.rect_position.y = LightPositions[1]
		mode = "2"
		acceleration = 0
		gear = 1
	else:
		$Gearbox/HighLight.rect_position.y = LightPositions[2]
		mode = "3"
	
func _on_left_stick_control_signal(speed, angle, vector):
	left_input = vector
	input_received(vector, 0)

func _on_right_stick_control_signal(speed, angle, vector):
	right_input = vector
	input_received(vector, 1)

func input_received(vector, id):
	match id:
		0:
			send_stick_event(vector.x, JOY_ANALOG_LX)
			send_stick_event(vector.y, JOY_ANALOG_LY)
		1:
			send_stick_event(vector.x, JOY_ANALOG_RX)
			send_stick_event(vector.y, JOY_ANALOG_RY)

func send_stick_event(value, id):
	var ev = InputEventJoypadMotion.new()
	ev.set_axis_value(value)
	ev.set_axis(id)
	Input.parse_input_event(ev)

func _process(delta):
	# Verifica se o pedal está pressionado e ajusta a aceleração
	if pedal_pressed and mode != "2":
		acceleration = lerp(acceleration, max_acceleration, delta * acceleration_rate)
	else:
		acceleration = lerp(acceleration, 0.0, delta * deceleration_rate)

	# Processa outros inputs e atualiza as posições, etc.
	pedal_pressed = $Node2D/Button.is_pressed()
	
	if acceleration != 0:
		gear = clamp(int((acceleration*1.5)/26.666)+1,1,6)
	#print(direction)
