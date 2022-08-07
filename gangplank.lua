Combo_key = 1
Clear_key = 3
Harass_key = 4
White = color:new(255,255,255)
Red = color:new(255,0,0)
Green = color:new(0,255,0)
Blue = color:new(0,0,200)
barrels = {}


function createEnemiesList()
    return features.entity_list:get_enemies()
end

function createEnemyMinionsList()
    return features.entity_list:get_enemy_minions()
end

function getTargetMr(target)
    --return 100 / (target.MR+100)
    return 100 / (target.total_mr + 100)
end

function getDistance(from,to)
    return from:dist_to(to)
end


local mySpells = {
    q = {
        lastCast = 0,
        manaCost = {55 , 50 , 45 , 40 , 35},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.q),
        spellSlot = e_spell_slot.q,
        apRatio = 1,
        Range = 625,
        Width = 360,
        Speed = 2600,
        Level = 0,
        Base = {60, 105, 150, 195, 240},
        CastTime = 0.25,
        coolDown = {4.5 , 4.5 , 4.5 , 4.5 , 4.5},
        TotalDamage = 0 },
    w = {
        lastCast = 0,
        manaCost = {60 , 70 , 80 , 90 , 100},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.w),
        spellSlot = e_spell_slot.w,
        apRatio = .3,
        Range = 0,
        Width = 550,
        Speed = 10000,
        Level = 0,
        Base = {80, 120, 160, 200, 240},
        CastTime = 0.25,
        TotalDamage = 0 },
    e = {
        lastCast = 0,
        manaCost = {0,0,0,0,0},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.e),
        spellSlot = e_spell_slot.e,
        apRatio = {.4,.45,.5,.55,.6},
        Range = 1000,
        Width = 345,
        Speed = 1600,
        Level = 0,
        Base = {50, 70, 90, 110, 130},
        CastTime = 0.15,
        TotalDamage = 0 },
    r = {
        lastCast = 0,
        manaCost = {100, 100, 100},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.r),
        spellSlot = e_spell_slot.r,
        apRatio = {.2, .5},
        Range = { 2000, 2500, 3000 },
        Width = 360,
        Speed = 1600,
        Level = 0,
        Base = {75 , 125 , 175 },
        Base2 = {150 , 250 , 350},
        CastTime = 0.15,
        TotalDamage = 0 },
    totalComboDamage = 0
}
function mySpells:refreshSpells()
    self['q'].Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.q).level
    self['w'].Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.w).level
    self['e'].Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.e).level
    self['r'].Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.r).level
end




function mySpells:isSpellReady(spell)
    if self[spell].spell:is_ready() then
        return true
    else
        return false
    end
end

function mySpells:haveEnoughMana(spell)
    if g_local.mana >= self[spell].manaCost[self[spell].Level] then
        return true
    else
        return false
    end
end

function mySpells:canCast(spell)
    mySpells:refreshSpells()
    if self:isSpellReady(spell) and self:haveEnoughMana(spell) then
        return true
    else
        return false
    end
end

function mySpells:castSpellOnTarget(spellToCast,target)
    local target = target or nil
    if self:canCast(spellToCast) then
        local castSpellSlot = self[spellToCast].spellSlot
        print('casting spell '..spellToCast)
        if target ~= nil then
            g_input:cast_spell((castSpellSlot), target)
        else
            g_input:cast_spell(castSpellSlot)
        end
    end
end


function mySpells:castSpellLocation(spellToCast,location)
    if self:canCast(spellToCast) then
        local castSpellSlot = self[spellToCast].spellSlot
        print('casting spell '..spellToCast)
        g_input:cast_spell((castSpellSlot), location)
    end
    return location
end

function mySpells:isSpellInRange(spell,target)
    print(self[spell].Range)
    if target.position:dist_to(g_local.position) <= self[spell].Range then
        return true
    else
        return false
    end
end


function mySpells:enemiesInERange()
    local eRangeEnemies = {}
    for k,v in pairs(createEnemiesList()) do
        if self:isSpellReady('e', v.position) then
            table.insert(eRangeEnemies,v)
        end
    end
    return eRangeEnemies
end


function mySpells:numberOfECharges()
   return g_local:get_spell_book():get_spell_slot(e_spell_slot.e).charges
end


--function mySpells:getActiveBarrels()
--    local activeBarrels = { }
--    features.entity_list:force_update()
--    for k,v in pairs(createEnemyMinionsList()) do
--        if v:get_object_name() == 'GangplankBarrel' then
--            print('barrel found')
--            table.insert(activeBarrels, v)
--        end
--    return activeBarrels
--    end
--end


function mySpells:checkNumberOfActiveBarrels()
    local activeBarrels = 0
    for k,v in pairs(barrels) do
            activeBarrels = activeBarrels + 1
    end
    return activeBarrels
end






function mySpells:placeBarrel()
    if features.orbwalker:get_mode() == Combo_key then
        local target = features.target_selector:get_default_target()
        if target ~= nil then
            if self:numberOfECharges() >= 2 then
                if getDistance(g_local.position, target.position) <= self['q'].Width * 2 then
                    if self:checkNumberOfActiveBarrels() == 0 then
                        local barrelLoc = self:castSpellLocation('e', g_local.position)
                        local barrelIdx = g_local:get_spell_book():get_spell_cast_info().missile_index or nil
                        if  barrelIdx ~= nil then
                            print('inserting initial barrel to barrels')
                            barrels['0'] = {barrelIdx, barrelLoc}
                        end
                    end
                    if self:checkNumberOfActiveBarrels() > 1 then
                        local barrelLoc = self:castSpellLocation('e', (target.position) * .66)
                        print(target.position)
                        print(barrelLoc)
                        local barrelIdx = g_local:get_spell_book():get_spell_cast_info().missile_index or nil

                        if  barrelIdx ~= nil then
                            table.insert(barrels, {barrelIdx, barrelLoc})
                        end
                    end
                end
            end
        end
    end
end


function drawLineFromBarrelToTarget()
    if features.orbwalker:get_mode() == Combo_key then
        local target = features.target_selector:get_default_target()
        if target ~= nil then
            for k, barrel in pairs(barrels) do
                if barrel[2] ~= nil then
                    g_render:line(barrel[2]:to_screen(), target.position:to_screen(), Red,3)
                end
            end
        end
    end
end


function mySpells:qSpell()
    local mode = features.orbwalker:get_mode()
    if mode == Clear_key or mode == Harass_key then
        local target = features.target_selector:get_default_target()
        if target ~= nil then
            self:castSpellOnTarget('q',target)
        end
    end

end


function mySpells:removeBarrels()
    for k,v in pairs(barrels) do
        if v[2] == nil then
            table.remove(barrels, k)
        end
        if v[2] ~= nil then
            if getDistance(g_local.position, v[2]) > 1000 then
                table.remove(barrels, k)
            end
        end

    end
end

cheat.register_callback("render", drawLineFromBarrelToTarget)
--cheat.register_callback('feature', function()
--    mySpells:removeBarrels()
--end
--)

cheat.register_module({
    champion_name = "Gangplank",
    spell_e = function()
        local barrelIdx = mySpells:placeBarrel()
    end ,
    spell_q = function()
        mySpells:qSpell()
    end,
    get_priorities = function()
        return {
            "spell_e",
            "spell_q"
        }
    end
})



--function mySpells:haveEnoughMana(spell)
--    if myChamp.mana >= self[spell].manaCost[self[spell].Level] then
--        return true
--    else
--        return false
--    end
--end
--
--function mySpells:canCast(spell)
--    if self:isSpellReady(spell) and self:haveEnoughMana(spell) then
--        return true
--    else
--        return false
--    end
--end
--
--function mySpells:checkEStacks()
--    local spellSlot = self['e'].spell
--    return spellSlot
--end
--
--function mySpells:castSpellOnTarget(spellToCast,target)
--    if self:canCast(spellToCast) then
--        local castSpellSlot = self[spellToCast].spell
--        print('casting spell '..spellToCast)
--        if target ~= nil then
--            g_input:cast_spell((castSpellSlot), target.position)
--        else
--            g_input:cast_spell(castSpellSlot)
--        end
--    end
--end
--
--mySpells:castSpellOnTarget('e', myChamp.position)
--
--print(mySpells:checkEStacks())

