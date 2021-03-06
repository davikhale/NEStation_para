/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	item_state = "rods"
	flags = CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	m_amt = 1000
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'

/obj/item/stack/rods/New(var/loc, var/amount=null)
	..()

	update_icon()

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(get_amount() < 2)
			user << "<span class='warning'>You need at least two rods to do this.</span>"
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			user.visible_message("<span class='warning'>[user.name] shaped [src] into metal with the weldingtool.</span>", \
						 "<span class='notice'>You shaped [src] into metal with the weldingtool.</span>", \
						 "<span class='warning'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	if (istype(W, /obj/item/weapon/tank/plasma))
		//I really hate to do it this way but I don't really know what I'm doing :P --MadSnailDisease
		//TODO: Be smart and make the incend bat buildable like everything else (e.g. the flamethrower)
		new /obj/item/weapon/makeshift/incend_bat(user.loc)
		user << "You twist the rods into a bat and add the phoron tank"
		del (src)
	..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if (locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if (G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
			else
				return 1
	else
		if(amount < 2)
			user << "\blue You need at least two rods to do this."
			return
		usr << "\blue Assembling grille..."

		if (!do_after(usr, 10))
			return

		var /obj/structure/grille/F = new /obj/structure/grille/ ( usr.loc )
		usr << "\blue You assemble a grille"
		F.add_fingerprint(usr)
		use(2)
	return
