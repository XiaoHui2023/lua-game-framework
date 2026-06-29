---@param o unit
---@param args unit.options
return function(o, args)
    o.factory.collection_field("weapons")
    o.factory.ref_field("active_weapon", nil)
    o.factory.event_field("on_weapon_equipped")

    o.weapons.wrap_add(function(weapon)
        weapon.equip(o)
        o.factory.capture("", weapon)
        if o.active_weapon() == nil then
            o.active_weapon.set(weapon)
        end
        o.on_weapon_equipped(weapon)
        return weapon
    end)

    function o.equip_weapon(weapon)
        o.weapons.add(weapon)
        o.active_weapon.set(weapon)
        return weapon
    end
end
