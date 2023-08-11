math.randomseed(os.time())

local charge_exists = minetest.get_modpath("charge")

-- Variate sound pitch ever so slightly
function vpitch(variations)
	local variation = variations - 2
	return (100 - (math.random(-variation, variation)) * 10) / 100
end

-- Redefine drop function (Thanks jordan4ibenez!)
-- Throw items using player's velocity
function minetest.item_drop(itemstack, dropper, pos, sound)
	local player_collect_height = 1.3
	-- if player then do modified item drop
	if dropper and minetest.get_player_information(dropper:get_player_name()) then
		local name = dropper:get_player_name()
		local dir = dropper:get_look_dir()
		local vel = dropper:get_velocity()
		local pos = {
			x = pos.x,
			y = pos.y + player_collect_height,
			z = pos.z,
		}
		local item = itemstack:to_string()
		local obj = minetest.add_item(pos, item)
		sound = sound or "throw"
		if obj then
			local extra_vel = 0
			if charge_exists then
				if charge.amount[name] then
					extra_vel = charge.amount[name] * 5
				end
				charge.amount[name] = 0
				if charge.sound[name] then
					minetest.sound_fade(charge.sound[name], 10, 0)
				end
			end
			vel.x = (dir.x * (4 + extra_vel)) + vel.x
			vel.y = (dir.y * (4 + extra_vel)) + 2 + vel.y
			vel.z = (dir.z * (4 + extra_vel)) + vel.z
			obj:add_velocity(vel)
			obj:get_luaentity().dropped_by = dropper:get_player_name()
			itemstack:clear()
			minetest.sound_play(sound, {
				pos = pos,
				gain = 0.1,
				pitch = vpitch(5),
			})
			return itemstack
		end
	end
end
