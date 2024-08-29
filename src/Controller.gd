extends Node
 
var r_input = null
var l_input = null

var server_udp = PacketPeerUDP.new()
var esp_ip = "192.168.4.1" # IP do ESP32 no modo Access Point
var port = 12000

func _ready():
	#print("Starting UDP communication...")
	r_input = get_node("../joypad").right_input.y
	l_input = get_node("../joypad").left_input.x

func _process(delta):
	# Enviar dados periodicamente
	var dir_input = int(get_node("../joypad").direction)
	var gear_input = int(get_node("../joypad").gear)
	var mode_input = (get_node("../joypad").mode)
	l_input = get_node("../joypad").left_input.x
	#print("R: ",r_input," L: ",l_input)
	var data_to_send = str(dir_input)+":"+str(gear_input)+":"+str(mode_input)
	print(data_to_send)
	var result = server_udp.set_dest_address(esp_ip, port)
	if result == OK:
		server_udp.put_packet(data_to_send.to_utf8())
		#print("Dados enviados para ESP32: %s" % data_to_send)
	else:
		#print("Erro ao definir endereço de destino: %s" % esp_ip)
		pass
