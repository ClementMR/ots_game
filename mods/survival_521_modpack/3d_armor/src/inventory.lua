if core.get_modpath("sfinv") then
	local orig_get = sfinv.pages["sfinv:crafting"].get
	sfinv.override_page("sfinv:crafting", {
		get = function(self, player, context)
			local name = player:get_player_name()
			local armor_formspec = armor:get_armor_formspec(name)
			local fs = orig_get(self, player, context)

			return fs .. armor_formspec
		end
	})
end