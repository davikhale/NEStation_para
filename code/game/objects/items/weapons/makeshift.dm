/obj/item/weapon/makeshift/incend_bat //test again
	name = "makeshift incendiary bat"
	desc = "A bat with a homemade incendiary charge on it. This end forward."
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "incend_bat0"
	force = 3
	throwforce = 5
	var/obj/item/weapon/tank/plasma/ptank2 = null
	var/obj/item/device/assembly/prox_sensor/psensor = null
	var/obj/item/device/assembly/igniter/I = null
	hitsound = "sounds/weapons/punch1.ogg"

/obj/item/weapon/makeshift/incend_bat/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(user.stat || user.restrained() || user.lying)	return

	if(isigniter(W))
		if(I)
			var/mob/living/L = W
			L.fire_stacks = 15
			L.IgniteMob()
			user << "\red Well that was dumb..."
			del (src)
			return
		else
			src.force = 20
			src.icon_state = "incend_bat1"
			user.drop_item()
			I = W
			W.loc = src
			return

/obj/item/weapon/makeshift/incend_bat/attack(mob/target as mob, mob/living/user as mob)
	if(I)
		if (prob(10))
			var/mob/living/L = target
			L.fire_stacks = 15
			user.fire_stacks = 15
			L.IgniteMob()
			user.IgniteMob()
			user << "\red \b The bat shatters and both you and [target] burst into flames!"
			del (src)
			return
		var/mob/living/L = target
		L.fire_stacks = 15
		L.IgniteMob()
		..()
		user << "\red \b The bat shatters and [target] bursts into flames!"
		del (src)
		return
	..()

/obj/item/weapon/makeshift/mace
	name = "makeshift mace"
	desc = "Crudely made from a toolbox and wires, this is a force to be reconed with..."
	force = 10
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "flail0" //ignore this, I changed the name at one point -- MadSnailDisease
	var/status = 0
	var/attack_time = 0
	var/charge_tick = 4
	hitsound = "sounds/weapons/punch1.ogg"

/obj/item/weapon/makeshift/mace/attack(mob/target as mob, mob/living/user as mob)
	if(process())
		if(status)
			if (prob(10))
				user << "The cables snap and disconnects from the toolbox!"
				user << "<span class='notice'>The toolbox hits the ground and fall apart</span>"
				new /obj/item/stack/cable_coil(user.loc)
				del (src)
				return
			..()
		else
			..()
			user << "\red The toolbox flips open and disconnects from the wires!"
			new /obj/item/stack/cable_coil(user.loc)
			new /obj/item/weapon/storage/toolbox/mechanical(user.loc)
			del (src)
		return
	else
		user << "<span class='notice'>You are too tired to do that!</span>"

/obj/item/weapon/makeshift/mace/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(iswelder(W) && !status)
		src.force = 20
		src.status = 1
		user << "\blue You weld the toolbox shut"
		src.icon_state = "flail1"
		return
	..()

/obj/item/weapon/makeshift/mace/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	return 1

/obj/item/weapon/makeshift/tazer
	name = "makeshift tazer"
	desc = "This seems like a bad idea..."
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "tazer"
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=2"
	attack_verb = list("stabbed")
	var/stunforce = 7
	var/status = 0
	var/obj/item/weapon/stock_parts/cell/tcell = null
	var/hitcost = 1000

/obj/item/weapon/makeshift/tazer/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in \his mouth! It looks like \he's trying to commit suicide.</span>")
	return (FIRELOSS)

/obj/item/weapon/makeshift/tazer/New()
	..()
	update_icon()
	return

/obj/item/weapon/makeshift/tazer/CheckParts()
	tcell = locate(/obj/item/weapon/stock_parts/cell) in contents
	update_icon()

/obj/item/weapon/makeshift/tazer/New()
	..()
	tcell = new(src)
	update_icon()
	return

/obj/item/weapon/makeshift/tazer/proc/deductcharge(var/chrgdeductant)
	if(tcell)
		if(tcell.charge < (hitcost+chrgdeductant))
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, 1, -1)
		if(tcell.use(chrgdeductant))
			return 1
		else
			return 0

/obj/item/weapon/makeshift/tazer/update_icon()
	if(status)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/weapon/makeshift/tazer/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(tcell)
			user << "<span class='notice'>[src] already has a cell.</span>"

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(tcell)
			tcell.loc = get_turf(src.loc)
			tcell = null
			user << "<span class='notice'>You remove the power cell from the [src].</span>"
			del (src)
			new /obj/item/device/multitool(user.loc)
			return
		..()
	return

/obj/item/weapon/makeshift/tazer/attack_self(mob/user)
	if(tcell.charge > hitcost)
		status = !status
		user << "<span class='notice'>[src] is now [status ? "on" : "off"].</span>"
		playsound(loc, "sparks", 75, 1, -1)
	else
		status = 0
		user << "<span class='warning'>[src] is out of charge.</span>"
	update_icon()
	add_fingerprint(user)

/obj/item/weapon/makeshift/tazer/attack(mob/M, mob/living/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits themself with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return
	if(!isliving(M))
		return

	var/mob/living/L = M

	if(user.a_intent != "harm")
		if(status)
			user.do_attack_animation(L)
			baton_stun(L, user)
		else
			L.visible_message("<span class='warning'>[user] has prodded [L] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
			return
	else
		..()
		if(status)
			baton_stun(L, user)


/obj/item/weapon/makeshift/tazer/proc/baton_stun(mob/living/L, mob/user)
	user.lastattacked = L
	L.lastattacker = user

	L.Stun(stunforce)
	L.Weaken(stunforce)
	L.apply_effect(STUTTER, stunforce)

	L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
							"<span class='userdanger'>[user] has stunned you with [src]!</span>")
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			R.cell.use(hitcost)
	else
		deductcharge(hitcost)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(hit_appends)

	add_logs(L, user, "stunned", object="stunbaton")