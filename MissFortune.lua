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
        manaCost = {45 , 50 , 55 , 60 , 65 },
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.q),
        spellSlot = e_spell_slot.q,
        apRatio = 1,
        Range = 550,
        Width = 120,
        Speed = 1600,
        Level = 0,
        Base = {60, 105, 150, 195, 240},
        CastTime = 0.25,
        coolDown = {4.5 , 4.5 , 4.5 , 4.5 , 4.5},
        TotalDamage = 0 },
    w = {
        lastCast = 0,
        manaCost = {40 , 35 , 30 , 25 , 20},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.w),
        spellSlot = e_spell_slot.w,
        apRatio = .3,
        Range = 550,
        Width = 550,
        Speed = 1400,
        Level = 0,
        Base = {80, 120, 160, 200, 240},
        CastTime = 0,
        TotalDamage = 0 },
    e = {
        lastCast = 0,
        manaCost = {70,70,70,70,70},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.e),
        spellSlot = e_spell_slot.e,
        Range = 1000,
        Width = 1450,
        Speed = 2000,
        Level = 0,
        CastTime = 0,
        TotalDamage = 0 },
    r = {
        lastCast = 0,
        manaCost = {100, 100, 100},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.r),
        spellSlot = e_spell_slot.r,
        adRatio = { 110, 130, 150 },
        Range =  0 ,
        Width = 315,
        Speed = 2000,
        Level = 0,
        Base = {175 , 275 , 375 },
        CastTime = 0.25,
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
        g_input:cast_spell(castSpellSlot, target)
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
    print(self[spell].Range)
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


function mySpells:qSpell(target)
    local mode = features.orbwalker:get_mode()
    if mode == Harass_key or mode == Combo_key then
        if target ~= nil and getDistance(g_local.position, target.position) <= self['q'].Range then
            if features.orbwalker:should_reset_aa() then
                self:castSpellOnTarget('q',target)
            end
        end
    end
end

function mySpells:wSpell(target)
    local mode = features.orbwalker:get_mode()
    if mode == Harass_key or mode == Combo_key then
        if target ~= nil and getDistance(g_local.position, target.position) <= self['w'].Range then
            self:castSpellOnTarget('w')
        end
    end
end

function mySpells:eSpell(target)
    local mode = features.orbwalker:get_mode()
    if mode == Clear_key or mode == Harass_key or mode == Combo_key then
        if target ~= nil and getDistance(g_local.position, target.position) <= self['e'].Range then
            local ePred = self:predPosition('e',target)
            self:castSpellLocation('e', ePred.position)
        end
    end
end




cheat.register_module({
    champion_name = "MissFortune",
    spell_q = function()
        mySpells:qSpell(features.target_selector:get_default_target())
    end,
    spell_w = function()
        mySpells:wSpell(features.target_selector:get_default_target())
    end,
    spell_e = function()
        mySpells:eSpell(features.target_selector:get_default_target())
    end,
    get_priorities = function()
        return {
            "spell_q",
            "spell_w",
            "spell_e"
        }
    end
})
