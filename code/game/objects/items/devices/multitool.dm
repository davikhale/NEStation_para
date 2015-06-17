/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */

/obj/item/device/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon_state = "multitool"
	flags = CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"
	var/obj/machinery/buffer // simple machine buffer for device linkage

/obj/item/device/multitool/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/L = W
		L.loc = src
		user << "<span class='notice'>You install a cell in [src].</span>"
		new /obj/item/weapon/makeshift/tazer(user.loc)
		del (src)


/obj/item/device/multitool/proc/IsBufferA(var/typepath)
	if(!buffer)
		return 0
	return istype(buffer,typepath)

// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.


/obj/item/device/multitool/ai_detect
	var/track_delay = 0

/obj/item/device/multitool/ai_detect/New()
	..()
	processing_objects += src


/obj/item/device/multitool/ai_detect/Del()
	processing_objects -= src
	..()

/obj/item/device/multitool/ai_detect/process()

	if(track_delay > world.time)
		return

	var/found_eye = 0

	for(var/mob/aiEye/A in living_mob_list)

		var/turf/our_turf = get_turf(src)
		var/turf/eye_turf = get_turf(A)

		if(get_dist(our_turf, eye_turf) < 9)
			found_eye = 1
			break

	if(found_eye)
		icon_state = "[initial(icon_state)]_red"
	else
		icon_state = initial(icon_state)

	track_delay = world.time + 10 // 1 second
	return

