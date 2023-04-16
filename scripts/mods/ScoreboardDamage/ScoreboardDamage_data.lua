local mod = get_mod("ScoreboardDamage")

return {
	name = "ScoreboardDamage",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "plugin_melee_data",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_ranged_data",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_melee_data_special",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_ranged_data_special",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_melee_lesser_data",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_ranged_lesser_data",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_melee_elite_data",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_ranged_elite_data",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_special_data",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "plugin_disabler_data",
				type = "checkbox",
				default_value = true,
			},
		},
	},
}
