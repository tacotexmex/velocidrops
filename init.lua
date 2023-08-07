math.randomseed(os.time())

-- Variate sound pitch ever so slightly
function vpitch(variations)
	local variation = variations - 2
	return (100 - (math.random(-variation, variation)) * 10) / 100
end

local charge = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	charge[name] = 0
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	charge[name] = nil
end)

controls.register_on_hold(function(player, control_name, time)
	if control_name == "sneak" then
		local name = player:get_player_name()
		charge[name] = charge[name] + time
		minetest.chat_send_all(charge[name])
	end
end)

controls.register_on_release(function(player, control_name, time)
	if control_name == "sneak" then
		local name = player:get_player_name()
		charge[name] = 0
	end
end)

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
		if charge[name] > 3 then
			charge[name] = 0
		end
		if obj then
			vel.x = (dir.x * (5 + (charge[name] * 10))) + vel.x
			vel.y = (dir.y * (5 + (charge[name] * 10))) + 2 + vel.y
			vel.z = (dir.z * (5 + (charge[name] * 10))) + vel.z
			obj:add_velocity(vel)
			obj:get_luaentity().dropped_by = dropper:get_player_name()
			itemstack:clear()
			charge[name] = 0
			minetest.sound_play(sound, {
				pos = pos,
				gain = 0.1,
				pitch = vpitch(5),
			})
			return itemstack
		end
	end
end
