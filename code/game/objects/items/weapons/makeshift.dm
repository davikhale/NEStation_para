/obj/item/weapon/makeshift/incend_bat
	name = "Makeshift incendiary bat"
	desc = "A bat with a homemade incendiary charge on it. This end forward."
	icon_state = "incend_bat"
	force = 40
	throwforce = 5
	var/obj/item/weapon/tank/plasma/ptank = null
	var/status = 0
	hitsound = "sounds/weapons/punch1.ogg"

/obj/item/weapon/makeshift/incend_bat/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(user.stat || user.restrained() || user.lying)	return
	if(isscrewdriver(W) && ptank)
		status = !status
		user << "<span class='notice'>[ptank] is now [status ? "secured" : "unsecured"]!</span>"
		return

	if(isigniter(W))
		var/mob/living/A = user
		A.IgniteMob()
		user << "\red Well that was dumb..."
		return

	if(istype(W,/obj/item/weapon/tank/plasma))
		if(ptank)
			user << "<span class='notice'>There appears to already be a incendiary charge attatched to \the [src]!</span>"
			return
		user.drop_item()
		ptank = W
		W.loc = src
		return

/obj/item/weapon/makeshift/incend_bat/attack(mob/target as mob, mob/living/user as mob)
	if(!istype(target, /mob/living) || !isrobot(target))
		var/obj/item/weapon/makeshift/incend_bat/force = 3
		..()
		user << "The bat shatters!"
		del (src)
		return
	var/mob/living/L = target
	L.IgniteMob()
	..()
	user << "The bat shatters and [target] bursts into flames!"
	del (src)