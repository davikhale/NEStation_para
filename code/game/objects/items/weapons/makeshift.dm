/obj/item/weapon/makeshift/incend_bat
	name = "makeshift incendiary bat"
	desc = "A bat with a homemade incendiary charge on it. This end forward."
	icon_state = "incend_bat"
	force = 3
	throwforce = 5
	var/obj/item/weapon/tank/plasma/ptank2 = null
	var/obj/item/device/assembly/prox_sensor/psensor = null
	var/obj/item/device/assembly/igniter/I = null
	hitsound = "sounds/weapons/punch1.ogg"

/obj/item/weapon/makeshift/incend_bat/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(user.stat || user.restrained() || user.lying)	return
	//I know this is ugly, but I want it built in this order :P --MadSnailDisease
	if(istype(W, /obj/item/weapon/tank/plasma))
		if(ptank2)
			user << "\blue An incendiary charge has already been attatched"
			return
		user.drop_item()
		ptank2 = W
		W.loc = src
		return

	if(istype(W, /obj/item/device/assembly/prox_sensor))
		if(psensor)
			user << "\blue A proximity sensor has already been attatched"
			return
		user.drop_item()
		psensor = W
		W.loc = src
		return

	if(isigniter(W))
		if(I)
			var/mob/living/L = W
			L.fire_stacks = 100
			L.IgniteMob()
			user << "\red Well that was dumb..."
			del (src)
			return
		src.force = 40
		user.drop_item()
		I = W
		W.loc = src
		return

/obj/item/weapon/makeshift/incend_bat/attack(mob/target as mob, mob/living/user as mob)
	if(I)
		var/mob/living/L = target
		L.fire_stacks = 100
		L.IgniteMob()
		..()
		user << "\red \b The bat shatters and [target] bursts into flames!"
		del (src)
		return
	..()

/obj/item/weapon/makeshift/flail
	name = "makeshift flail"
	desc = "Crudely made from a toolbox and wires, this is a force to be reconed with..."
	force = 10
	var/status = 0
	var/attack_time = 0
	var/charge_tick = 0
	hitsound = "sounds/weapons/punch1.ogg"

/obj/item/weapon/makeshift/flail/attack(mob/target as mob, mob/living/user as mob)
	if(status)
		..()
		return
	else
		..()
		user << "\red The toolbox flips open and disconnects from the wires!"
		for(var/i = 0, i++ <= 10)
			new /obj/item/weapon/wire(user.loc)
		new /obj/item/weapon/storage/toolbox(user.loc)
		del (src)

/obj/item/weapon/makeshift/flail/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(iswelder(W))
		src.force = 20
		src.status = 1
		user << "\blue You weld the toolbox shut"
		return
	..()

/obj/item/weapon/makeshift/flail/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	return 1