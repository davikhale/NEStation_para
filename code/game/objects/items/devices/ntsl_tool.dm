/**
 * A handheld device for writing, downloading, uploading, saving, and managing NTSL scripts
 */

/obj/item/device/ntsl_tool
	name = "NTSL Gun"
	desc = "Used for writing NTSL scripts and uploading them to machines."
	icon_state = "ntsltool"
	flags = CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	m_amt = 600
	g_amt = 200
	origin_tech = "magnets=1;engineering=2;programming=2"

	var/screen = 0				// the screen number:
	var/list/machines = list()	// the machines located by the gun
	var/mob/editingcode
	var/mob/lasteditor
	var/list/viewingcode = list()
	var/obj/machinery/SelectedMachine

	var/nnetwork = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages
	var/range = 1				// range that the gun has (for admunbus/reverse mingebagging)

	var/storedcode = ""			// code stored

	var/emagged = 0


	req_access = list(access_tcomsat)


	proc/update_ide()

		// loop if there's someone manning the keyboard
		while(editingcode)
			if(!editingcode.client)
				editingcode = null
				break

			// For the typer, the input is enabled. Buffer the typed text
			if(editingcode)
				storedcode = "[winget(editingcode, "tcscode", "text")]"
			if(editingcode) // double if's to work around a runtime error
				winset(editingcode, "tcscode", "is-disabled=false")

			// If the player's not manning the keyboard anymore, adjust everything
			if( !(editingcode in range(1, src)) || (editingcode.machine != src) )
				if(editingcode)
					winshow(editingcode, "Telecomms IDE", 0) // hide the window!
				editingcode = null
				break

			// For other people viewing the typer type code, the input is disabled and they can only view the code
			// (this is put in place so that there's not any magical shenanigans with 50 people inputting different code all at once)

			if(length(viewingcode))
				// This piece of code is very important - it escapes quotation marks so string aren't cut off by the input element
				var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
				showcode = replacetext(storedcode, "\"", "\\\"")

				for(var/mob/M in viewingcode)

					if(M.machine == src && M in view(1, src))
						winset(M, "tcscode", "is-disabled=true")
						winset(M, "tcscode", "text=\"[showcode]\"")
					else
						viewingcode.Remove(M)
						winshow(M, "Telecomms IDE", 0) // hide the window!

			sleep(5)

		if(length(viewingcode) > 0)
			editingcode = pick(viewingcode)
			viewingcode.Remove(editingcode)
			update_ide()


	Topic(href, href_list)
		if(..())
			return


		add_fingerprint(usr)
		usr.set_machine(src)
		if(!src.allowed(usr))
			usr << "\red ACCESS DENIED."
			return

		if(href_list["viewmachine"])
			screen = 1
			for(var/obj/machinery/telecomms/M in machines)
				if(M.nid == href_list["viewmachine"])
					SelectedMachine = M
					break
			for(var/obj/machinery/door/airlock/M in machines)
				if(M.nid == href_list["viewmachine"])
					SelectedMachine = M
					break

		if(href_list["operation"])
			switch(href_list["operation"])

				if("release")
					machines = list()
					screen = 0

				if("mainmenu")
					screen = 0

				if("scan")
					if(machines.len > 0)
						temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

					else
						for(var/obj/machinery/telecomms/server/M in range(range, usr))
							if(M.nnetwork == nnetwork)
								machines.Add(M)

						for(var/obj/machinery/door/airlock/M in range(range, usr))
							if(M.nnetwork == nnetwork)
								machines.Add(M)

						if(!machines.len)
							temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE MACHINES IN \[[nnetwork]\] -</font color>"
						else
							temp = "<font color = #336699>- [machines.len] MACHINES PROBED & BUFFERED -</font color>"

						screen = 0

				if("editcode")
					if(editingcode == usr) return
					if(usr in viewingcode) return

					if(!editingcode)
						lasteditor = usr
						editingcode = usr
						winshow(editingcode, "Telecomms IDE", 1) // show the IDE
						winset(editingcode, "tcscode", "is-disabled=false")
						winset(editingcode, "tcscode", "text=\"\"")
						var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
						showcode = replacetext(storedcode, "\"", "\\\"")
						winset(editingcode, "tcscode", "text=\"[showcode]\"")
						spawn()
						update_ide()

					else
						viewingcode.Add(usr)
						winshow(usr, "Telecomms IDE", 1) // show the IDE
						winset(usr, "tcscode", "is-disabled=true")
						winset(editingcode, "tcscode", "text=\"\"")
						var/showcode = replacetext(storedcode, "\"", "\\\"")
						winset(usr, "tcscode", "text=\"[showcode]\"")

				if("togglerun")
					SelectedMachine.autoruncode = !(SelectedMachine.autoruncode)

		if(href_list["network"])

			var/newnet = input(usr, "Which network do you want to view?", "Comm Monitor", nnetwork) as null|text

			if(newnet)
				if(length(newnet) > 15)
					temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

				else

					nnetwork = newnet
					screen = 0
					machines = list()
					temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[nnetwork]\] -</font color>"

		if(href_list["range"])
			var/newrange = input(usr, "Input tile range of NTSL Gun", "Range", range) as null|num
			if(newrange)
				if(newrange < 0)
					newrange = 0
				if(newrange > 100)
					newrange = 0
				range = newrange

		src.attack_self(usr)
		return

obj/item/device/ntsl_tool/emag_act(user as mob)
	if(!emagged)
		playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		user << "\blue You you disable the security protocols"

/obj/item/device/ntsl_tool/attack_self(mob/user as mob)
	interact(user)

obj/item/device/ntsl_tool/interact(mob/user as mob)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	user.set_machine(src)
	var/dat = "<TITLE>NanoTrasen SL Gun</TITLE><center><b>NanoTrasen Scripting Language</b></center>"

	switch(screen)


	  // --- Main Menu ---

		if(0)
			dat += "<br>[temp]<br>"
			dat += "<br>Current Network: <a href='?src=\ref[src];network=1'>[nnetwork]</a><br>"
			if(machines.len)
				dat += "<br>Detected Machines on network [nnetwork]:<ul>"
				for(var/obj/machinery/telecomms/M in machines)
					dat += "<li><a href='?src=\ref[src];viewmachine=[M.nid]'>\ref[M] [M.name]</a> ([M.nid])</li>"
				for(var/obj/machinery/door/airlock/M in machines)
					dat += "<li><a href='?src=\ref[src];viewmachine=[M.nid]'>\ref[M] [M.name]</a> ([M.nid])</li>"
				dat += "</ul>"
				dat += "<br><a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"

			else
				dat += "<br>No servers detected. Scan for servers: <a href='?src=\ref[src];operation=scan'>\[Scan\]</a>"


	  // --- Viewing Server ---

		if(1)
			dat += "<br>[temp]<br>"
			dat += "<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=\ref[src];operation=refresh'>\[Refresh\]</a></center>"
			dat += "<br>Current Network: [nnetwork]"
			dat += "<br>Selected Machine: [SelectedMachine.nid]<br><br>"
			dat += "<br><a href='?src=\ref[src];operation=editcode'>\[Edit Code\]</a>"
			dat += "<br>Signal Execution: "
			if(SelectedMachine.autoruncode)
				dat += "<a href='?src=\ref[src];operation=togglerun'>ALWAYS</a>"
			else
				dat += "<a href='?src=\ref[src];operation=togglerun'>NEVER</a>"

	  // --- Admin Settings ---

	  	if(0 && user.client.holder)
	  		dat += "<hr><center><b>ADMIN SETTINGS</b></center><br>"
	  		dat += "<br>Range: <a href='?src=\ref[src];range=1'>[range]</a><br>"
			// add one for clearing all user code within a range

	user << browse(dat, "window=ntsl_gun;size=575x400")
	onclose(user, "server_control")

	temp = ""
	return