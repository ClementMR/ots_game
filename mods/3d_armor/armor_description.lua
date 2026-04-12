local S = core.get_translator(core.get_current_modname())
local C = core.colorize

local pieces = {
    "3d_armor:helmet_",
    "3d_armor:chestplate_",
    "3d_armor:leggings_",
    "3d_armor:boots_",
    "shields:shield_"
}

for k, _ in pairs(armor.materials) do
    for _, piece in pairs(pieces) do
        local item = piece .. k
        local def = core.registered_tools[item]
        if def then
            local protection = def.armor_groups.fleshy
            local feather = def.groups.armor_feather
            local healing = def.groups.armor_heal
            local immortal = def.groups.immortal

            local new_desc = ""

            if protection and protection ~= 0 then
                new_desc = new_desc .. "\n" .. C("#808080", S("Armor Protection @1", protection))
            end
            if feather and feather ~= 0 then
                new_desc = new_desc .. "\n" .. C("#155DFC", S("Feather Falling @1", feather))
            end
            if healing and healing ~= 0 then
                new_desc = new_desc .. "\n" .. C("#016630", S("Healing Factor @1", healing))
            end
            if immortal and immortal ~= 0 then
                new_desc = new_desc .. "\n" .. C("#E7180B", S("Immortality @1", immortal))
            end

            core.override_item(item, {description =  def.description .. new_desc})
        end
    end
end