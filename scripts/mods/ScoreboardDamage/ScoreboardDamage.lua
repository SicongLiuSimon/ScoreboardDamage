local mod = get_mod("ScoreboardDamage")
local scoreboard = get_mod("scoreboard")
local Breed = scoreboard:original_require("scripts/utilities/breed")

mod.melee_lessers = {
	"chaos_newly_infected",
	"chaos_poxwalker",
	"cultist_melee",
	"renegade_melee",
}
mod.ranged_lessers = {
	"cultist_assault",
	"renegade_assault",
	"renegade_rifleman",
}
mod.melee_elites = {
	"cultist_berzerker",
	"renegade_berzerker",
	"renegade_executor",
	"chaos_ogryn_bulwark",
	"chaos_ogryn_executor",
}
mod.ranged_elites = {
	"cultist_gunner",
	"renegade_gunner",
	"cultist_shocktrooper",
	"renegade_shocktrooper",
	"chaos_ogryn_gunner",
}
mod.specials = {
	"chaos_poxwalker_bomber",
	"renegade_grenadier",
	"cultist_grenadier",
	"renegade_sniper",
	"renegade_flamer",
	"cultist_flamer",
}
mod.disablers = {
	"chaos_hound",
	"cultist_mutant",
	"renegade_netgunner",
}

mod.current_health = {}
mod.last_enemy_interaction = {}

mod:hook(CLASS.AttackReportManager, "add_attack_result", function(
    	func, self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot,
		damage, attack_result, attack_type, damage_efficiency, ...
	)
	local player = scoreboard:player_from_unit(attacking_unit)
	if player then
		local account_id = player:account_id() or player:name()
		local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
		local breed_or_nil = unit_data_extension and unit_data_extension:breed()
		local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)
		local actual_damage = damage
		local overkill_damage = 0

		if target_is_minion then
			-- Set last interacting player_unit
			mod.last_enemy_interaction[attacked_unit] = attacking_unit

			-- Get health extension
			local current_health = mod.current_health[attacked_unit]
			local unit_health_extension = ScriptUnit.has_extension(attacked_unit, "health_system")
			local new_health = unit_health_extension and unit_health_extension:current_health()

			-- Attack result
			if attack_result == "damaged" then
				-- Current health
				if not current_health then
					current_health = new_health + damage
				end
				-- Actual damage
				actual_damage = math.min(damage, current_health)
				-- Update health
				mod.current_health[attacked_unit] = new_health

			elseif attack_result == "died" then
				-- Current health
				if not current_health then
					current_health = damage
				end
				-- Actual damage
				actual_damage = current_health
				-- Overkill damage
				overkill_damage = damage - actual_damage
				-- Update health
				mod.current_health[attacked_unit] = nil
				-- Update scoreboard
				-- mod:echo(breed_or_nil.name)
				if attack_type == "melee" then
					scoreboard:update_stat("melee_killed", account_id, 1)
				else
					scoreboard:update_stat("ranged_killed", account_id, 1)
				end

				if table.array_contains(mod.melee_lessers, breed_or_nil.name) then
					scoreboard:update_stat("melee_lesser_killed", account_id, 1)
				elseif table.array_contains(mod.ranged_lessers, breed_or_nil.name) then
					scoreboard:update_stat("ranged_lesser_killed", account_id, 1)
				elseif table.array_contains(mod.melee_elites, breed_or_nil.name) then
					scoreboard:update_stat("melee_elite_killed", account_id, 1)
				elseif table.array_contains(mod.ranged_elites, breed_or_nil.name) then
					scoreboard:update_stat("ranged_elite_killed", account_id, 1)
				elseif table.array_contains(mod.specials, breed_or_nil.name) then
					scoreboard:update_stat("special_killed", account_id, 1)
				elseif table.array_contains(mod.disablers, breed_or_nil.name) then
					scoreboard:update_stat("disabler_killed", account_id, 1)
				end
			end
			
			if attack_type == "melee" then
				scoreboard:update_stat("melee_damaged", account_id, actual_damage)
			else
				scoreboard:update_stat("ranged_damaged", account_id, actual_damage)
			end

			if table.array_contains(mod.melee_lessers, breed_or_nil.name) then
				scoreboard:update_stat("melee_lesser_damaged", account_id, actual_damage)
			elseif table.array_contains(mod.ranged_lessers, breed_or_nil.name) then
				scoreboard:update_stat("ranged_lesser_damaged", account_id, actual_damage)
			elseif table.array_contains(mod.melee_elites, breed_or_nil.name) then
				scoreboard:update_stat("melee_elite_damaged", account_id, actual_damage)
			elseif table.array_contains(mod.ranged_elites, breed_or_nil.name) then
				scoreboard:update_stat("ranged_elite_damaged", account_id, actual_damage)
			elseif table.array_contains(mod.specials, breed_or_nil.name) then
				scoreboard:update_stat("special_damaged", account_id, actual_damage)
			elseif table.array_contains(mod.disablers, breed_or_nil.name) then
				scoreboard:update_stat("disabler_damaged", account_id, actual_damage)
			end
		end
	end
	return func(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, ...)
end)

mod.scoreboard_rows = {
	{
		name = "melee_data",
		text = "row_melee_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_killed",
			"melee_damaged",
		},
		group = "offense",
		setting = "plugin_melee_data",
	},
	{
		name = "melee_killed",
		text = "row_melee_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_data",
		setting = "plugin_melee_data",
	},
	{
		name = "melee_damaged",
		text = "row_melee_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_data",
		setting = "plugin_melee_data",
	},
	{
		name = "ranged_data",
		text = "row_ranged_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"ranged_killed",
			"ranged_damaged",
		},
		group = "offense",
		setting = "plugin_ranged_data",
	},
	{
		name = "ranged_killed",
		text = "row_ranged_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "ranged_data",
		setting = "plugin_ranged_data",
	},
	{
		name = "ranged_damaged",
		text = "row_ranged_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "ranged_data",
		setting = "plugin_ranged_data",
	},
	{
		name = "melee_lesser_data",
		text = "row_melee_lesser_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_lesser_killed",
			"melee_lesser_damaged",
		},
		group = "offense",
		setting = "plugin_melee_lesser_data",
	},
	{
		name = "melee_lesser_killed",
		text = "row_melee_lesser_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_lesser_data",
		setting = "plugin_melee_lesser_data",
	},
	{
		name = "melee_lesser_damaged",
		text = "row_melee_lesser_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_lesser_data",
		setting = "plugin_melee_lesser_data",
	},
	{
		name = "ranged_lesser_data",
		text = "row_ranged_lesser_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"ranged_lesser_killed",
			"ranged_lesser_damaged",
		},
		group = "offense",
		setting = "plugin_ranged_lesser_data",
	},
	{
		name = "ranged_lesser_killed",
		text = "row_ranged_lesser_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "ranged_lesser_data",
		setting = "plugin_ranged_lesser_data",
	},
	{
		name = "ranged_lesser_damaged",
		text = "row_ranged_lesser_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "ranged_lesser_data",
		setting = "plugin_ranged_lesser_data",
	},
	{
		name = "melee_elite_data",
		text = "row_melee_elite_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_elite_killed",
			"melee_elite_damaged",
		},
		group = "offense",
		setting = "plugin_melee_elite_data",
	},
	{
		name = "melee_elite_killed",
		text = "row_melee_elite_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_elite_data",
		setting = "plugin_melee_elite_data",
	},
	{
		name = "melee_elite_damaged",
		text = "row_melee_elite_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_elite_data",
		setting = "plugin_melee_elite_data",
	},
	{
		name = "ranged_elite_data",
		text = "row_ranged_elite_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"ranged_elite_killed",
			"ranged_elite_damaged",
		},
		group = "offense",
		setting = "plugin_ranged_elite_data",
	},
	{
		name = "ranged_elite_killed",
		text = "row_ranged_elite_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "ranged_elite_data",
		setting = "plugin_ranged_elite_data",
	},
	{
		name = "ranged_elite_damaged",
		text = "row_ranged_elite_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "ranged_elite_data",
		setting = "plugin_ranged_elite_data",
	},
	{
		name = "special_disabler_damaged",
		text = "row_special_disabler_damaged",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"special_damaged",
			"disabler_damaged",
		},
		group = "offense",
		setting = "plugin_special_disabler_damaged",
	},
	{
		name = "special_data",
		text = "row_special_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"special_killed",
			"special_damaged",
		},
		group = "offense",
		setting = "plugin_special_data",
	},
	{
		name = "special_killed",
		text = "row_special_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "special_data",
		setting = "plugin_special_data",
	},
	{
		name = "special_damaged",
		text = "row_special_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "special_data",
		setting = "plugin_special_data",
	},
	{
		name = "disabler_data",
		text = "row_disabler_data",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"disabler_killed",
			"disabler_damaged",
		},
		group = "offense",
		setting = "plugin_disabler_data",
	},
	{
		name = "disabler_killed",
		text = "row_disabler_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "disabler_data",
		setting = "plugin_disabler_data",
	},
	{
		name = "disabler_damaged",
		text = "row_disabler_damaged",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "disabler_data",
		setting = "plugin_disabler_data",
	},
}
