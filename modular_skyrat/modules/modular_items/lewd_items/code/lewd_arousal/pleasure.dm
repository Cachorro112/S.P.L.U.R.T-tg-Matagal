/mob/living/proc/adjust_pleasure(pleas = 0, mob/living/partner, datum/interaction/interaction, position)
	if((stat >= DEAD || !client?.prefs?.read_preference(/datum/preference/toggle/erp)) && !(!ishuman(src) && !src.client && !SSinteractions.is_blacklisted(src)))
		return

	pleasure = clamp(pleasure + pleas, AROUSAL_MINIMUM, AROUSAL_LIMIT) // SPLURT EDIT - Lust tolerance

	var/lust_tolerance = 1
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		lust_tolerance = H.dna.features["lust_tolerance"] || 1

	if(pleasure >= AROUSAL_AUTO_CLIMAX_THRESHOLD * lust_tolerance) // lets cum // SPLURT EDIT - Lust tolerance
		climax(manual = FALSE, partner = partner, climax_interaction = interaction, interaction_position = position)
