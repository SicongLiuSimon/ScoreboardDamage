local mod = get_mod("ScoreboardDamage")

return {
	name = "ScoreboardDamage",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "plugin_lesser_damage_dealt",
				type = "checkbox",
				default_value = true,
			},
		},
	},
}
