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
			end
			
			if table.array_contains(mod.melee_lessers, breed_or_nil.name) then
				scoreboard:update_stat("melee_lesser_damage_dealt", account_id, actual_damage)
			elseif table.array_contains(mod.ranged_lessers, breed_or_nil.name) then
				scoreboard:update_stat("ranged_lesser_damage_dealt", account_id, actual_damage)
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
}
