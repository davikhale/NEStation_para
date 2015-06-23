// ### Preset machines  ###

//Relay

/obj/machinery/telecomms/relay/preset
	nnetwork = "tcommsat"

/obj/machinery/telecomms/relay/preset/station
	nid = "Station Relay"
	listening_level = 1
	autolinkers = list("s_relay")

/obj/machinery/telecomms/relay/preset/telecomms
	nid = "Telecomms Relay"
	autolinkers = list("relay")

/obj/machinery/telecomms/relay/preset/mining
	nid = "Mining Relay"
	autolinkers = list("m_relay")

/obj/machinery/telecomms/relay/preset/ruskie
	nid = "Ruskie Relay"
	hide = 1
	toggled = 0
	autolinkers = list("r_relay")

/obj/machinery/telecomms/relay/preset/centcom
	nid = "Centcom Relay"
	hide = 1
	toggled = 1
	//anchored = 1
	use_power = 0
	//idle_power_usage = 0
	heatgen = 0
	autolinkers = list("c_relay")

//HUB

/obj/machinery/telecomms/hub/preset
	nid = "Hub"
	nnetwork = "tcommsat"
	autolinkers = list("hub", "relay", "c_relay", "s_relay", "m_relay", "r_relay", "science", "medical",
	"supply", "service", "common", "command", "engineering", "security",
	"receiverA", "receiverB", "broadcasterA", "broadcasterB")

/obj/machinery/telecomms/hub/preset_cent
	nid = "CentComm Hub"
	nnetwork = "tcommsat"
	use_power = 0
	autolinkers = list("hub_cent", "c_relay", "s_relay", "m_relay", "r_relay",
	 "centcomm", "receiverCent", "broadcasterCent")

//Receivers

//--PRESET LEFT--//

/obj/machinery/telecomms/receiver/preset_left
	nid = "Receiver A"
	nnetwork = "tcommsat"
	autolinkers = list("receiverA") // link to relay
	freq_listening = list(1351, 1355, 1347, 1349) // science, medical, supply, service


//--PRESET RIGHT--//

/obj/machinery/telecomms/receiver/preset_right
	nid = "Receiver B"
	nnetwork = "tcommsat"
	autolinkers = list("receiverB") // link to relay
	freq_listening = list(1353, 1357, 1359) //command, engineering, security

	//Common and other radio frequencies for people to freely use
	New()
		for(var/i = 1441, i < 1489, i += 2)
			freq_listening |= i
		..()

/obj/machinery/telecomms/receiver/preset_cent
	nid = "CentComm Receiver"
	nnetwork = "tcommsat"
	use_power = 0
	autolinkers = list("receiverCent")
	freq_listening = list(ERT_FREQ, DTH_FREQ)

//Buses

/obj/machinery/telecomms/bus/preset_one
	nid = "Bus 1"
	nnetwork = "tcommsat"
	freq_listening = list(1351, 1355)
	autolinkers = list("processor1", "science", "medical")

/obj/machinery/telecomms/bus/preset_two
	nid = "Bus 2"
	nnetwork = "tcommsat"
	freq_listening = list(1347,1349)
	autolinkers = list("processor2", "supply", "service")

/obj/machinery/telecomms/bus/preset_three
	nid = "Bus 3"
	nnetwork = "tcommsat"
	freq_listening = list(1359, 1353)
	autolinkers = list("processor3", "security", "command")

/obj/machinery/telecomms/bus/preset_four
	nid = "Bus 4"
	nnetwork = "tcommsat"
	freq_listening = list(1357)
	autolinkers = list("processor4", "engineering", "common")

/obj/machinery/telecomms/bus/preset_four/New()
	for(var/i = 1441, i < 1489, i += 2)
		freq_listening |= i
	..()

/obj/machinery/telecomms/bus/preset_cent
	nid = "CentComm Bus"
	nnetwork = "tcommsat"
	use_power = 0
	freq_listening = list(ERT_FREQ, DTH_FREQ)
	autolinkers = list("processorCent", "centcomm")

//Processors

/obj/machinery/telecomms/processor/preset_one
	nid = "Processor 1"
	nnetwork = "tcommsat"
	autolinkers = list("processor1") // processors are sort of isolated; they don't need backward links

/obj/machinery/telecomms/processor/preset_two
	nid = "Processor 2"
	nnetwork = "tcommsat"
	autolinkers = list("processor2")

/obj/machinery/telecomms/processor/preset_three
	nid = "Processor 3"
	nnetwork = "tcommsat"
	autolinkers = list("processor3")

/obj/machinery/telecomms/processor/preset_four
	nid = "Processor 4"
	nnetwork = "tcommsat"
	autolinkers = list("processor4")

/obj/machinery/telecomms/processor/preset_cent
	nid = "CentComm Processor"
	nnetwork = "tcommsat"
	use_power = 0
	autolinkers = list("processorCent")

//Servers

/obj/machinery/telecomms/server/presets

	nnetwork = "tcommsat"

/obj/machinery/telecomms/server/presets/science
	nid = "Science Server"
	freq_listening = list(1351)
	autolinkers = list("science")

/obj/machinery/telecomms/server/presets/medical
	nid = "Medical Server"
	freq_listening = list(1355)
	autolinkers = list("medical")

/obj/machinery/telecomms/server/presets/supply
	nid = "Supply Server"
	freq_listening = list(1347)
	autolinkers = list("supply")

/obj/machinery/telecomms/server/presets/service
	nid = "Service Server"
	freq_listening = list(1349)
	autolinkers = list("service")

/obj/machinery/telecomms/server/presets/common
	nid = "Common Server"
	freq_listening = list()
	autolinkers = list("common")

	//Common and other radio frequencies for people to freely use
	// 1441 to 1489
/obj/machinery/telecomms/server/presets/common/New()
	for(var/i = 1441, i < 1489, i += 2)
		freq_listening |= i
	..()

/obj/machinery/telecomms/server/presets/command
	nid = "Command Server"
	freq_listening = list(1353)
	autolinkers = list("command")

/obj/machinery/telecomms/server/presets/engineering
	nid = "Engineering Server"
	freq_listening = list(1357)
	autolinkers = list("engineering")

/obj/machinery/telecomms/server/presets/security
	nid = "Security Server"
	freq_listening = list(1359)
	autolinkers = list("security")

/obj/machinery/telecomms/server/presets/centcomm
	nid = "CentComm Server"
	freq_listening = list(ERT_FREQ, DTH_FREQ)
	use_power = 0
	autolinkers = list("centcomm")

//Broadcasters

//--PRESET LEFT--//

/obj/machinery/telecomms/broadcaster/preset_left
	nid = "Broadcaster A"
	nnetwork = "tcommsat"
	autolinkers = list("broadcasterA")

//--PRESET RIGHT--//

/obj/machinery/telecomms/broadcaster/preset_right
	nid = "Broadcaster B"
	nnetwork = "tcommsat"
	autolinkers = list("broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_cent
	nid = "CentComm Broadcaster"
	nnetwork = "tcommsat"
	use_power = 0
	autolinkers = list("broadcasterCent")