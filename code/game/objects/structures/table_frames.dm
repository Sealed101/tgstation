/* Table Frames
 * Contains:
 * Frames
 * Wooden Frames
 */


/*
 * Normal Frames
 */

/obj/structure/table_frame
	name = "table frame"
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	max_integrity = 100
	///The type of material used in creation of the frame; will also apply to the table upon construction
	var/framestack = /obj/item/stack/rods
	///Amount of material used in the frame
	var/framestackamount = 2

/obj/structure/table_frame/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "disassembling...")
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 50))
		return TRUE
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	deconstruct(TRUE)
	return TRUE

/obj/structure/table_frame/attackby(obj/item/attack_item, mob/user, params)
	if(isstack(attack_item)) //check for non-sheet-material frame stack (e.g. carpets)
		var/obj/item/stack/material = attack_item
		if(material.table_variant) //any tables that aren't using the greyscale base for their sprite go here (e.g. plasteel/glass)
			if(material.get_amount() < 1)
				to_chat(user, span_warning("You need one [material.name] sheet to do this!"))
				return
			if(locate(/obj/structure/table) in get_turf(src))
				to_chat(user, span_warning("There's already a table built here!"))
				return
			to_chat(user, span_notice("You start adding [material.name] to [src]..."))
			if(!do_after(user, 2 SECONDS, target = src) || !material.use(1) || (locate(/obj/structure/table) in get_turf(src)))
				return
			make_new_table(material.table_variant)
		else if(istype(material, /obj/item/stack/sheet)) //minerals, wood and what have you
			//list of materials in the stack of sheets. will be applied as custom_materials in table creation
			var/list/material_list = list()
			if(material.material_type)
				material_list[material.material_type] = SHEET_MATERIAL_AMOUNT
			if(!length(material_list)) //no mineral cost set = we probably don't want to make a table out of this! otherwise we get a white table built out of "nothing"
				to_chat(user, span_warning("This material can't be used to make a table!"))
				return
			if(material.get_amount() < 1)
				to_chat(user, span_warning("You need one [material.name] sheet to do this!"))
				return
			if(locate(/obj/structure/table) in get_turf(src))
				to_chat(user, span_warning("There's already a table built here!"))
				return
			to_chat(user, span_notice("You start adding [material.name] to [src]..."))
			if(!do_after(user, 2 SECONDS, target = src) || !material.use(1) || (locate(/obj/structure/table) in get_turf(src)))
				return
			make_new_table(/obj/structure/table/greyscale, material_list)
		return
	return ..()


/obj/structure/table_frame/proc/make_new_table(table_type, custom_materials, carpet_type) //makes sure the new table made retains what we had as a frame
	var/obj/structure/table/result_table = new table_type(get_turf(src))
	result_table.frame = type
	result_table.framestack = framestack
	result_table.framestackamount = framestackamount
	if(carpet_type)
		result_table.buildstack = carpet_type
	if(custom_materials)
		result_table.set_custom_materials(custom_materials)
	qdel(src)

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new framestack(drop_location(), framestackamount)
	return ..()

/obj/structure/table_frame/narsie_act()
	. = ..()
	new /obj/structure/table_frame/wood(get_turf(src))
	qdel(src)

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE

/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params)
	if (isstack(I))
		var/obj/item/stack/material = I
		var/toConstruct // stores the table variant
		var/carpet_type // stores the carpet type used for construction in case of poker tables
		if(istype(I, /obj/item/stack/sheet/mineral/wood))
			toConstruct = /obj/structure/table/wood
		else if(istype(I, /obj/item/stack/tile/carpet))
			toConstruct = /obj/structure/table/wood/poker
			carpet_type = I.type
		if (toConstruct)
			if(material.get_amount() < 1)
				to_chat(user, span_warning("You need one [material.name] sheet to do this!"))
				return
			to_chat(user, span_notice("You start adding [material] to [src]..."))
			if(do_after(user, 20, target = src) && material.use(1))
				make_new_table(toConstruct, null, carpet_type)
	else
		return ..()
