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
				-- elseif attack_type == "ranged" then
					scoreboard:update_stat("ranged_killed", account_id, 1)
				end
			end
			
			if table.array_contains(mod.melee_lessers, breed_or_nil.name) then
				scoreboard:update_stat("melee_lesser_damage_dealt", account_id, actual_damage)
			elseif table.array_contains(mod.ranged_lessers, breed_or_nil.name) then
				scoreboard:update_stat("ranged_lesser_damage_dealt", account_id, actual_damage)
			elseif table.array_contains(mod.melee_elites, breed_or_nil.name) then
				scoreboard:update_stat("melee_elite_damage_dealt", account_id, actual_damage)
			elseif table.array_contains(mod.ranged_elites, breed_or_nil.name) then
				scoreboard:update_stat("ranged_elite_damage_dealt", account_id, actual_damage)
			elseif table.array_contains(mod.specials, breed_or_nil.name) then
				scoreboard:update_stat("special_damage_dealt", account_id, actual_damage)
			elseif table.array_contains(mod.disablers, breed_or_nil.name) then
				scoreboard:update_stat("disabler_damage_dealt", account_id, actual_damage)
			end
		end
	end
	return func(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, ...)
end)

mod.scoreboard_rows = {
	{
		name = "lesser_damage_dealt",
		text = "row_lesser_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_lesser_damage_dealt",
			"ranged_lesser_damage_dealt",
		},
		group = "offense",
		setting = "plugin_lesser_damage_dealt",
	},
	{
		name = "melee_lesser_damage_dealt",
		text = "row_melee_lesser_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "lesser_damage_dealt",
		setting = "plugin_lesser_damage_dealt",
	},
	{
		name = "ranged_lesser_damage_dealt",
		text = "row_ranged_lesser_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "lesser_damage_dealt",
		setting = "plugin_lesser_damage_dealt",
	},
	{
		name = "elite_damage_dealt",
		text = "row_elite_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_elite_damage_dealt",
			"ranged_elite_damage_dealt",
		},
		group = "offense",
		setting = "plugin_elite_damage_dealt",
	},
	{
		name = "melee_elite_damage_dealt",
		text = "row_melee_elite_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "elite_damage_dealt",
		setting = "plugin_elite_damage_dealt",
	},
	{
		name = "ranged_elite_damage_dealt",
		text = "row_ranged_elite_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "elite_damage_dealt",
		setting = "plugin_elite_damage_dealt",
	},
	{
		name = "special_disabler_damage_dealt",
		text = "row_special_disabler_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"special_damage_dealt",
			"disabler_damage_dealt",
		},
		group = "offense",
		setting = "plugin_special_disabler_damage_dealt",
	},
	{
		name = "special_damage_dealt",
		text = "row_special_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "special_disabler_damage_dealt",
		setting = "plugin_special_disabler_damage_dealt",
	},
	{
		name = "disabler_damage_dealt",
		text = "row_disabler_damage_dealt",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "special_disabler_damage_dealt",
		setting = "plugin_special_disabler_damage_dealt",
	},
	{
		name = "melee_ranged_killed",
		text = "row_melee_ranged_killed",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_killed",
			"ranged_killed",
		},
		group = "offense",
		setting = "plugin_melee_ranged_killed",
	},
	{
		name = "melee_killed",
		text = "row_melee_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_ranged_killed",
		setting = "plugin_melee_ranged_killed",
	},
	{
		name = "ranged_killed",
		text = "row_ranged_killed",
		validation = "ASC",
		iteration = "ADD",
		group = "offense",
		parent = "melee_ranged_killed",
		setting = "plugin_melee_ranged_killed",
	},
}
