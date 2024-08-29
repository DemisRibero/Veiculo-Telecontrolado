extends Node2D

var color := {
	"grass_dark"   : Color("008208"),
	"grass_light"  : Color("03ac0e"),
	"border_dark"  : Color.red,
	"border_light" : Color.whitesmoke,
	"road_dark"    : Color(0.42, 0.42, 0.42),
	"road_light"   : Color(0.4, 0.4, 0.4),
	"strip_dark"   : Color(0, 0, 0, 0),
	"strip_light"  : Color(1, 1, 1),
}

var width := 1080
var height := 600
var road_width := 2000
var seg := 200
var cam := 0.85 # 0.85
var lines := []
var pos := 0
var num
var skyline_pos := 0.0
var skyline_h := 0

var road_length := 2000
var direction := 0
var target_curve_direction := 0.0
var current_curve := 0.0
var curve_speed := 0.08  # Controls how quickly the curve changes

onready var skyline = $backgorund

func _ready():
	for i in range(road_length):
		lines.append({ x = 0, y = 0, z = 0, X = 0, Y = 0, W = 0, scale = 0, curve = 0})
		lines[i].z = i * seg + 0.00000001
		
		if i < 755: lines[i].y = sin(i / 30.0) * 1500
	
	num = lines.size() 
	

func _process(delta):
	update()
	
	
	
	if $"../CenterContainer/joypad".pedal_pressed:
		if $"../CenterContainer/joypad".mode == "1":
			direction = 1
		if $"../CenterContainer/joypad".mode == "2":
			direction = 0
		if $"../CenterContainer/joypad".mode == "3":
			direction = -1
		if $"../CenterContainer/joypad".mode != "2":
			target_curve_direction = $"../CenterContainer/joypad".direction * 0.3
			skyline.scroll_offset.x -= target_curve_direction * 0.05
	else:
		
		if $"../CenterContainer/joypad".acceleration == 0:
			direction *= 2
		else:
			direction = 0
			target_curve_direction = 0
	
	if $"../CenterContainer/joypad".acceleration > 10:
		if $"../CenterContainer/joypad".mode == "1":
			direction = 1
		if $"../CenterContainer/joypad".mode == "2":
			direction = 0
		if $"../CenterContainer/joypad".mode == "3":
			direction = -1
	
	var a = 0
	if $"../CenterContainer/joypad".acceleration !=0:
		a = ($"../CenterContainer/joypad".acceleration/100) +1
	direction *= a * 1
	pos += int((seg * direction))
	#print(direction)
	# Gradually adjust the curve towards the target direction
	if $"../CenterContainer/joypad".pedal_pressed:
		current_curve = lerp(current_curve, target_curve_direction * 0.5, curve_speed)

	# Apply the current curve value to the road
	for i in range(road_length):
		lines[i].curve = current_curve

func _draw_road(color, x1, y1, w1, x2, y2, w2):
	var point = [Vector2(int(x1 - w1), int(y1)), Vector2(int(x2 - w2), int(y2)), Vector2(int(x2 + w2), int(y2)), Vector2(int(x1 + w1), int(y1))]
	draw_primitive(PoolVector2Array(point), PoolColorArray([color]), PoolVector2Array([]))

func _line(line, cam_x, cam_y, cam_z):
	line.scale = cam / (line.z - cam_z)
	line.X = (1 + line.scale * (line.x - cam_x)) * width / 2
	line.Y = (1 - line.scale * (line.y - cam_y)) * height / 2
	line.W = line.scale * road_width * (width / 2)
	return line

func _draw() -> void:
	if pos >= num * seg:
		pos -= num * seg
		
	if pos < 0:
		pos += num * seg
			
	var num_pos = 0
	var start_point = pos / seg
	var cam_h = 1500 + lines[start_point].y
	var cutoff = height
	var x = 0
	var dx = 0
	
	
	
	for n in range(start_point, start_point + 50):
		if n >= num:
			num_pos = num * seg
		else:
			num_pos = 0
			
		var l = _line(lines[fmod(n, num)], -x, cam_h, pos - num_pos)
		var p = lines[fmod(n - 1, num)]
		x += dx
		dx += l.curve
		
		if l.Y >= cutoff:
			continue
			
		cutoff = l.Y
		
		var border = color.border_dark if fmod((n / 4), 2) else color.border_light
		var road   = color.road_dark   if fmod((n / 4), 2) else color.road_light
		var grass  = color.grass_dark  if fmod((n / 8), 2) else color.grass_light
		var strip  = color.strip_dark  if fmod((n / 8), 2) else color.strip_light

		_draw_road(grass, 0, p.Y, width, 0, l.Y, width)
		_draw_road(border, p.X, p.Y, p.W * 1.2, l.X, l.Y, l.W * 1.2)
		_draw_road(road, p.X, p.Y, p.W, l.X, l.Y, l.W)
		_draw_road(strip, p.X, p.Y, p.W * 0.01, l.X, l.Y, l.W * 0.01)
