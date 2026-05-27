extends Node
#this is a testing host from the noray repo, I should try to make my own eventually
var host = "tomfol.io"
var port = 8890
#used for client
var host_oid = ""
var isHost : bool

func setup_noray_host_signals():
	Noray.on_connect_nat.connect(noray_host_handle_connect)
	Noray.on_connect_relay.connect(noray_host_handle_connect)

func setup_noray_client_signals():
	Noray.on_connect_nat.connect(noray_handle_client_nat_connect)
	Noray.on_connect_relay.connect(noray_handle_client_relay_connect)

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
	
	if isHost:
		host_oid = Noray.oid
	return OK

func noray_start_host():
	setup_noray_host_signals()
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(Noray.local_port)

	if err != OK:
		printerr("Failed to create server on port %s" % Noray.local_port)
		return false # Failed to listen on port
	multiplayer.multiplayer_peer = peer
	Network.connect_signals()

func noray_start_client(oid : String):
	host_oid = oid
	setup_noray_client_signals()
	# Connect using NAT punchthrough
	Noray.connect_nat(oid)

func noray_handle_client_nat_connect(address: String, port: int) -> Error:
	print("Attempting NAT connection to IP %s with port %s" % [address, port])
	var err = await noray_handle_client_connect(address, port)
	
	if err != OK:
		printerr("Attempting Relay...")
		Noray.connect_relay(host_oid)
	return OK
	
	
	
func noray_handle_client_relay_connect(address: String, port: int) -> Error:
	print("Attempting Relay connection to IP %s with port %s" % [address, port])
	return await noray_handle_client_connect(address, port)

func noray_handle_client_connect(address: String, port : int) -> Error:
	# Do a handshake
	var udp = PacketPeerUDP.new()
	udp.bind(Noray.local_port)
	udp.set_dest_address(address, port)

	var err = await PacketHandshake.over_packet_peer(udp)
	udp.close()

	if err != OK:
		printerr("Client handshake failed!")
		return err
	print("Client handshake suceeded!")
	
	# Connect to host
	var peer = ENetMultiplayerPeer.new()
	err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)

	if err != OK:
		printerr("Client creation failed!")
		return err
	
	print("Client creation suceeded!")
	multiplayer.multiplayer_peer = peer
	return OK
	
func noray_host_handle_connect(address: String, port: int) -> Error:
	var peer = multiplayer.multiplayer_peer as ENetMultiplayerPeer
	var err = await PacketHandshake.over_enet(peer.host, address, port)
	if err != OK:
		printerr("Host handshake failed!")
		return err
	print("Host handshake succeeded!")
	return OK
