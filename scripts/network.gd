extends Node
#this is a testing host from the noray repo, I should try to make my own eventually
var host = "tomfol.io"
var port = 8890

func setup_noray_host_signals():
	Noray.on_connect_nat.connect(noray_host_handle_connect)
	Noray.on_connect_relay.connect(noray_host_handle_connect)

func setup_noray_client_signals():
	Noray.on_connect_nat.connect(noray_client_handle_connect)
	Noray.on_connect_relay.connect(noray_client_handle_connect)

func connect_to_noray():
	# Connect to noray
	var err = await Noray.connect_to_host(host, port)
	if err != OK:
		return err # Failed to connect

	# Register host
	Noray.register_host()
	await Noray.on_pid
	# Register remote address
	# This is where noray will direct traffic
	err = await Noray.register_remote()
	if err != OK:
		printerr("Failed to register to Noray")
		return err # Failed to register
	
	return OK

func noray_start_host():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(Noray.local_port)

	if err != OK:
		printerr("Failed to create server on port %s" % Noray.local_port)
		return false # Failed to listen on port

func noray_start_client(oid : String):
	# Connect using NAT punchthrough
	var err = Noray.connect_nat(oid)
	
	if err != OK:
		printerr("NAT Punchthrough has failed. Trying Relay...")
		# Or connect using relay
		Noray.connect_relay(oid)
		
	else:
		print("Connected via NAT Punchthrough!")

func noray_client_handle_connect(address: String, port: int) -> Error:
  # Do a handshake
	var udp = PacketPeerUDP.new()
	udp.bind(Noray.local_port)
	udp.set_dest_address(address, port)

	var err = await PacketHandshake.over_packet_peer(udp)
	udp.close()

	if err != OK:
		return err

  # Connect to host
	var peer = ENetMultiplayerPeer.new()
	err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)

	if err != OK:
		return err

	return OK
	
func noray_host_handle_connect(address: String, port: int) -> Error:
	var peer = get_tree().get_multiplayer().multiplayer_peer as ENetMultiplayerPeer
	var err = await PacketHandshake.over_enet(peer.host, address, port)

	if err != OK:
		return err
	
	print("New client successfully connected!")
	return OK
