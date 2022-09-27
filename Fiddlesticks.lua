ComboKey = 1
LasthitKey = 2
LaneclearKey = 3
HarassKey = 4
FleeKey = 5
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
        manaCost = {45,50,55,60,65},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.q),
        spellSlot = e_spell_slot.q,
        apRatio = .7,
        Range = 575,
        Width = 360,
        Speed = 700,
        Level = 0,
        Base = {60, 105, 150, 195, 240},
        CastTime = 0.15,
        coolDown = {8 , 7 , 6 , 5 , 4},
        TotalDamage = 0 },
    w = {
        lastCast = 0,
        manaCost = {75,75,75,75,75},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.w),
        spellSlot = e_spell_slot.w,
        apRatio = .3,
        Range = 650,
        Width = 550,
        Speed = 10000,
        Level = 0,
        Base = {80, 120, 160, 200, 240},
        CastTime = 0.25,
        TotalDamage = 0 },
    e = {
        lastCast = 0,
        manaCost = {70,80,90,100,110},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.e),
        spellSlot = e_spell_slot.e,
        apRatio = {.4,.45,.5,.55,.6},
        Range = 850,
        Width = 200,
        Speed = 0,
        Level = 0,
        Base = {50, 70, 90, 110, 130},
        CastTime = 0.4,
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


function mySpells:isSpellReady(spell)
    return self[spell].spell:is_ready()
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
        g_input:cast_spell((castSpellSlot), target)
    end
end


function mySpells:castSpellLocation(spellToCast,location)
    if self:canCast(spellToCast) then
        local castSpellSlot = self[spellToCast].spellSlot
        g_input:cast_spell((castSpellSlot), location)
    end
    return location
end


function mySpells:isSpellInRange(spell,target)
    if target.position:dist_to(g_local.position) <= self[spell].Range then
        return true
    else
        return false
    end
end

function mySpells:predPosition(spell,target)
    local pred = features.prediction:predict(target.index, self[spell].Range, self[spell].Speed, self[spell].Width, self[spell].CastTime, g_local.position)
    return pred
end


function mySpells:qSpell(mode, target)
    if mode == ComboKey or mode == HarassKey then
        if target.position ~= nil and getDistance(g_local.position, target.position) <= self['q'].Range then
            self:castSpellOnTarget('q',target)
        end
    end
end




function mySpells:eSpell(mode, predPos)
    if mode == ComboKey or mode == HarassKey then
        if predPos.position ~= nil and getDistance(g_local.position, predPos.position) <= self['e'].Range then
            self:castSpellLocation('e',predPos.position)
        end
    end
end


function mySpells:getFiddleWStatus()
    local spellCastInfo = g_local:get_spell_book():get_spell_cast_info()
    if spellCastInfo ~= nil then
        local spellCastSlot = g_local:get_spell_book():get_spell_slot(spellCastInfo.slot)
        if spellCastSlot ~= nil then
            local spellSlotName = spellCastSlot:get_name()
            if spellSlotName == 'FiddleSticksW' then
                stopOrbWalker = true
            else
                stopOrbWalker = false
            end
            return stopOrbWalker
        end
    end
end

function mySpells:wSpell(mode, target)
    if mode == ComboKey or mode == HarassKey then
        if target.position ~= nil and getDistance(g_local.position, target.position) <= self['w'].Range then
            self:castSpellOnTarget('w', target)
        end
    end
end


function setOrbAllow(status)
    if status == true then
        status = false
    else
        status = true
    end
    features.orbwalker:allow_movement(status)
    features.orbwalker:allow_attacks(status)
end

wFunction = function()
    setOrbAllow(mySpells:getFiddleWStatus())
end

cheat.register_callback("feature", wFunction)

cheat.register_module({
    champion_name = "FiddleSticks",
    spell_q = function()
            if features.target_selector:get_default_target() ~= nil then
                mySpells:qSpell(features.orbwalker:get_mode(), features.target_selector:get_default_target())
            end
    end,
    spell_w = function()
        if features.target_selector:get_default_target() ~= nil then
            mySpells:wSpell(features.orbwalker:get_mode(), features.target_selector:get_default_target())
        end
    end,
    spell_e = function()
            if features.target_selector:get_default_target() ~= nil then
                mySpells:eSpell(features.orbwalker:get_mode(), mySpells:predPosition('e', features.target_selector:get_default_target()))
            end
    end,
    get_priorities = function()
        return {
            "spell_e",
            "spell_q",
            "spell_w"
        }
    end
})
