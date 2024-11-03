#define COSGLOW_OPACITY_MIN 32
#define COSGLOW_OPACITY_MAX 128
#define COSGLOW_OPACITY_DEFAULT 64
#define COSGLOW_THICKNESS_MIN 1
#define COSGLOW_THICKNESS_MAX 4
#define COSGLOW_THICKNESS_DEFAULT 1
#define COSGLOW_LAMP_RANGE_MIN 0
#define COSGLOW_LAMP_RANGE_MAX MINIMUM_USEFUL_LIGHT_RANGE
#define COSGLOW_LAMP_RANGE_DEFAULT COSGLOW_LAMP_RANGE_MAX/2
#define COSGLOW_LAMP_POWER 1
#define COSGLOW_LAMP_COLOR COLOR_WHITE

// You might be an undercover agent.
/datum/quirk/cosglow
	name = "Cosmetic Glow"
	desc = "You are capable of emitting a soft glow!"
	value = 0
	gain_text = span_notice("You feel empowered by a three-letter agency!")
	lose_text = span_notice("You realize that working for the space agency sucks!")
	medical_record_text = "Patient emits a subtle emissive aura."
	mob_trait = TRAIT_COSGLOW
	icon = FA_ICON_PERSON_RAYS
	mail_goodies = list (
		/obj/item/flashlight/glowstick = 1
	)
/datum/quirk/cosglow/add()
	// Define quirk holder mob
	var/mob/living/carbon/human/quirk_mob = quirk_holder

	// Add glow control action
	var/datum/action/cosglow/update_glow/quirk_action = new
	quirk_action.Grant(quirk_mob)

/datum/quirk/cosglow/remove()
	// Define quirk holder mob
	var/mob/living/carbon/human/quirk_mob = quirk_holder

	// Remove glow control action
	var/datum/action/cosglow/update_glow/quirk_action = locate() in quirk_mob.actions
	quirk_action.Remove(quirk_mob)

	// Remove glow effect
	quirk_mob.remove_filter("rad_fiend_glow")

// Light emitting status effect
/datum/status_effect/quirk_cosglow
	id = "quirk_cosglow"
	duration = -1
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE

	// Light effect object
	var/obj/effect/dummy/lighting_obj/moblight/cosglow_light_obj

/datum/status_effect/quirk_cosglow/on_apply()
	// Dynamic color is disabled
	/*
	// Get glow action
	var/datum/action/cosglow/update_glow/quirk_action = locate() in owner.actions

	// Check if glow action exists
	if(!quirk_action)
		return FALSE
	*/

	// Set light values
	// Ignores range settings to prevent crew becoming lanterns
	cosglow_light_obj = owner.mob_light(range = COSGLOW_LAMP_RANGE_DEFAULT, power = COSGLOW_LAMP_POWER, color = COSGLOW_LAMP_COLOR)

	return TRUE

/datum/status_effect/quirk_cosglow/on_remove()
	// Remove light
	QDEL_NULL(cosglow_light_obj)

/datum/status_effect/quirk_cosglow/get_examine_text()
	return span_notice("[owner.p_They()] emit[owner.p_s()] a harmless glowing aura.")

// Glow actions
/datum/action/cosglow
	name = "Broken Glow Action"
	desc = "Report this to a coder."
	button_icon = 'icons/obj/lighting.dmi'
	button_icon_state = "slime-on"
	var/obj/effect/dummy/lighting_obj/moblight/cosglow_light

/datum/action/cosglow/update_glow
	name = "Modify Glow"
	desc = "Change your glow color, thickness, and opacity."

	// Default glow color to use
	var/glow_color = COSGLOW_LAMP_COLOR

	// Default thickness of glow outline
	var/glow_thickness = COSGLOW_THICKNESS_DEFAULT

	// Default alpha of the glow outline
	var/glow_opacity = COSGLOW_OPACITY_DEFAULT

/datum/action/cosglow/update_glow/Grant(mob/grant_to)
	. = ..()

	// Define user mob
	var/mob/living/carbon/human/action_mob = grant_to

	// Add outline effect
	if(glow_color && glow_thickness)
		action_mob.add_filter("rad_fiend_glow", 1, list("type" = "outline", "color" = glow_color + "[glow_opacity]", "size" = glow_thickness))

	// Apply status effect
	action_mob.apply_status_effect(/datum/status_effect/quirk_cosglow, TRAIT_COSGLOW)

/datum/action/cosglow/update_glow/Remove(mob/remove_from)
	. = ..()

	// Define user mob
	var/mob/living/carbon/human/action_mob = remove_from

	// Remove glow
	action_mob.remove_filter("rad_fiend_glow")

	// Remove status effect
	action_mob.remove_status_effect(/datum/status_effect/quirk_cosglow, TRAIT_COSGLOW)

/datum/action/cosglow/update_glow/Trigger(trigger_flags)
	. = ..()

	// Define user mob
	var/mob/living/carbon/human/action_mob = owner

	// Ask user for color input
	var/input_color = input(action_mob, "Select a color to use for your glow outline.", "Select Glow Color", glow_color) as color|null

	// Check if color input was given
	// Reset to stored color when not given input
	glow_color = (input_color ? input_color : glow_color)

	// Ask user for thickness input
	var/input_thickness_tgui = tgui_input_number(action_mob, "How thick is your glow outline?", "Select Glow Thickness", default = COSGLOW_THICKNESS_DEFAULT, max_value = COSGLOW_THICKNESS_MAX, min_value = COSGLOW_THICKNESS_MIN)

	// Check if thickness input was given
	// Reset to stored thickness when input is null
	glow_thickness = isnull(input_thickness_tgui) ? glow_thickness : input_thickness_tgui

	// Ask user for opacity input
	// Limit maximum to prevent crew turning into stickers
	var/input_opacity_tgui = tgui_input_number(action_mob, "How opaque is your glow outline?", "Select Glow Opacity", default = COSGLOW_OPACITY_DEFAULT, max_value = COSGLOW_OPACITY_MAX, min_value = COSGLOW_OPACITY_MIN)

	// Check if opacity input was given
	// If no input is given, reset to stored opacity
	var/opacity_clamped = isnull(input_opacity_tgui) ? hex2num(glow_opacity) : input_opacity_tgui

	// Update glow opacity
	glow_opacity = num2hex(opacity_clamped, 2)

	// Update outline effect
	if(glow_thickness && glow_color)
		action_mob.add_filter("rad_fiend_glow", 1, list("type" = "outline", "color" = glow_color + "[glow_opacity]", "size" = glow_thickness))
	else
		action_mob.remove_filter("rad_fiend_glow")

	// Find status effect
	var/datum/status_effect/quirk_cosglow/glow_effect = locate() in action_mob.status_effects

	// Update status effect light color
	//glow_effect?.cosglow_light_obj?.set_light_color(glow_color) // Unused

	// Update status effect light range
	// New value is based on light range
	var/light_obj_range = (COSGLOW_LAMP_RANGE_MAX/COSGLOW_THICKNESS_MAX) * glow_thickness
	glow_effect?.cosglow_light_obj?.set_light_range(light_obj_range)

#undef COSGLOW_OPACITY_MIN
#undef COSGLOW_OPACITY_MAX
#undef COSGLOW_OPACITY_DEFAULT
#undef COSGLOW_THICKNESS_MIN
#undef COSGLOW_THICKNESS_MAX
#undef COSGLOW_THICKNESS_DEFAULT
#undef COSGLOW_LAMP_RANGE_MIN
#undef COSGLOW_LAMP_RANGE_MAX
#undef COSGLOW_LAMP_RANGE_DEFAULT
#undef COSGLOW_LAMP_POWER
#undef COSGLOW_LAMP_COLOR
