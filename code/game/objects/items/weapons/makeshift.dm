/obj/item/weapon/makeshift/incend_bat
	name = "makeshift incendiary bat"
	desc = "A bat with a homemade incendiary charge on it. This end forward."
	icon_state = "incend_bat"
	force = 3
	throwforce = 5
	var/obj/item/weapon/tank/plasma/ptank2 = null
	var/obj/item/device/assembly/prox_sensor/psensor = null
	var/obj/item/device/assembly/igniter/I = null
	var/status = 0
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
			L.IgniteMob()
			user << "\red Well that was dumb..."
			del (src)
			return
		user.drop_item()
		I = W
		W.loc = src
		force = 40
		return

/obj/item/weapon/makeshift/incend_bat/attack(mob/target as mob, mob/living/user as mob)

	var/mob/living/L = target
	L.IgniteMob()
	..()
	user << "The bat shatters and [target] bursts into flames!"
	del (src)