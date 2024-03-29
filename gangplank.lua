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
    self['q'].spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.q)
    self['q'].spellSlot = e_spell_slot.q

    self['w'].Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.w).level
    self['w'].spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.w)
    self['w'].spellSlot = e_spell_slot.w

    self['e'].Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.e).level
    self['e'].spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.e)
    self['e'].spellSlot = e_spell_slot.e

    self['r'].Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.r).level
    self['r'].spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.r)
    self['r'].spellSlot = e_spell_slot.r
end

function distance(x1, y1, z1, x2, y2, z2)
  -- Calculates the distance between two points
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

function midpoint(x1, y1, z1, x2, y2, z2)
  -- Calculates the midpoint between two points
  return (x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2
end

function find_circles(x1, y1, z1, x2, y2, z2)
  -- Calculates the center points and radii of the two circles
  local d = distance(x1, y1, z1, x2, y2, z2)
  local r = d / 2
  local mx, my, mz = midpoint(x1, y1, z1, x2, y2, z2)

  local h = math.sqrt((r^2) - ((d/2)^2))

  local dx = (y1 - y2) / d
  local dy = (x2 - x1) / d

  local cx1 = mx + h*dx
  local cy1 = my + h*dy
  local cz1 = z1
  local cx2 = mx - h*dx
  local cy2 = my - h*dy
  local cz2 = z1

  print(string.format("Circle 1: (%.2f, %.2f, %.2f), radius: %.2f", cx1, cy1, cz1, r))
  print(string.format("Circle 2: (%.2f, %.2f, %.2f), radius: %.2f", cx2, cy2, cz2, r))
end

-- Example usage:
find_circles(0, 0, 0, 3, 4, 0)



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
    self:refreshSpells()
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
        g_input:cast_spell((castSpellSlot), target)
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




function table.removeKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end



function mySpells:getActiveBarrels()
    for k,v in pairs(features.entity_list:get_enemy_minions()) do
        if  v:get_object_name() == 'GangplankBarrel' and v:is_targetable() then
            barrels[v.index] = v
        end
    end
    for k,v in pairs(barrels) do
        local barrel = v --features.entity_list:get_by_index(v)
        if barrel == nil then
            print('remove barrel with index '..k)
            table.removeKey(barrels,k)
        elseif barrel:is_alive() == false then
            print('remove barrel with index '..k)
            table.removeKey(barrels,k)
        end
    end
end




function mySpells:checkNumberOfActiveBarrelsInRange()
    self:getActiveBarrels()
    local activeBarrels = 0
    for k,v in pairs(barrels) do
        print(getDistance(g_local.position, v.position))
        if getDistance(g_local.position, v.position) <= self['q'].Range then
            activeBarrels = activeBarrels + 1

        end
    end
    return activeBarrels
end


function divideVec(vecPrimary, vecSecondary, distanceDenominator)
    local subtractVec = vec3:new(vecPrimary.x - vecSecondary.x, vecPrimary.y - vecSecondary.y, vecPrimary.z - vecSecondary.z)
    local newVec = vec3:new(subtractVec.x / distanceDenominator, subtractVec.y / distanceDenominator, subtractVec.z / distanceDenominator)
    local newVec = vec3:new(newVec.x + vecSecondary.x, newVec.y + vecSecondary.y, newVec.z + vecSecondary.z)
    return newVec
end


function addDistToVec(vec, distToAdd)
    return vec3:new(vec.x + distToAdd, vec.y + distToAdd, vec.z)
end


function mySpells:placeBarrel()
    if features.orbwalker:get_mode() == Combo_key then
        local target = features.target_selector:get_default_target()
        if target ~= nil then
            if self:numberOfECharges() >= 2 then
                if getDistance(g_local.position, target.position) <= self['e'].Width * 2 then
                    if self:checkNumberOfActiveBarrelsInRange() == 0 then
                        print('cast on me')
                        self:castSpellLocation('e', g_local.position)
                    else
                        print('cast to target')
                        --local closestBarrel = self:getClosestBarrel()
                        --furthest a barrel can go is .66 of distance from me to target
                        --distance of 2 barrels is 690
                        local distanceDivided = getDistance(g_local.position, target.position) / (self['e'].Width * 2)
                        local castELoc = divideVec(g_local.position, target.position, distanceDivided)
                        --local castELocDist = getDistance(castELoc, target.position)
                        --local castELoc = addDistToVec(castELoc, castELocDist)
                        --self:castSpellLocation('e', divideVec(g_local.position, target.position, distanceDivided))
                        self:castSpellLocation('e', castELoc)
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
            for k,v in pairs(barrels) do
                if v ~= nil then
                    g_render:line(v.position:to_screen(), target.position:to_screen(), Red,3)
                end
            end
        end
    end
end


function mySpells:qSpell()
    local mode = features.orbwalker:get_mode()
    if mode == Combo_key then
        local target = features.target_selector:get_default_target()
        if target ~= nil and getDistance(g_local.position, target.position) <= self['q'].Range then
            self:castSpellOnTarget('q',target)
        end
    end

end



cheat.register_callback("render", drawLineFromBarrelToTarget)
--cheat.register_callback('feature', function()
--    --mySpells:removeBarrels()
--    for k,v in pairs(features.entity_list:get_enemy_minions()) do
--        if v:get_object_name() == 'GangplankBarrel'
--            then print('GangplankBarrel found')
--        end
--    end
--end
--)

cheat.register_module({
    champion_name = "Gangplank",
    spell_e = function()
        mySpells:placeBarrel()
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

