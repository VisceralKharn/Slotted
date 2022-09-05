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
        Range = 325,
        Width = 325,
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
        Range = 1300,
        Width = 200,
        Speed = 5000,
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
        Range = 950,
        Width = 170,
        Speed = 1200,
        Level = 0,
        Base = {50, 70, 90, 110, 130},
        CastTime = 0.15,
        TotalDamage = 0 },
    r = {
        lastCast = 0,
        manaCost = {100, 100, 100},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.r),
        spellSlot = e_spell_slot.r,
        apRatio = .6,
        empoweredRatio = 1.8,
        Range =  500 ,
        Width = 360,
        Speed = 1600,
        Level = 0,
        Base = {125 , 250 , 375 },
        empoweredBase = {300,600,900},
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
        g_input:cast_spell(castSpellSlot, location)
    end
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

function mySpells:isMinionInWay(spell,position)
    return features.prediction:minion_in_line(g_local.position, position, self[spell].Width)
end

function mySpells:qSpell()
    local mode = features.orbwalker:get_mode()
    if  mode == Combo_key then
        local target = features.target_selector:get_default_target()
        if target ~= nil and getDistance(g_local.position, target.position) <= self['q'].Range then
            self:castSpellLocation('q',g_local.position)
        end
    end
end

function mySpells:wSpell()
    local mode = features.orbwalker:get_mode()
    if mode == Clear_key or mode == Harass_key or mode == Combo_key then
            local target = features.target_selector:get_default_target()
            if target ~= nil and getDistance(g_local.position, target.position) <= self['w'].Range then
                local wPred = self:predPosition('w',target)
                if self:isMinionInWay('w',wPred.position) == false then
                    self:castSpellLocation('w',wPred.position)

                end
            end
    end
end


function mySpells:eSpell()
    local mode = features.orbwalker:get_mode()
    if mode == Clear_key or mode == Harass_key or mode == Combo_key then
        local target = features.target_selector:get_default_target()
        if target ~= nil and getDistance(g_local.position, target.position) <= self['e'].Range then
            local ePred = self:predPosition('e',target)
            self:castSpellLocation('e', ePred.position)
        end
    end
end




cheat.register_module({
    champion_name = "Heimerdinger",
    spell_q = function()
        mySpells:qSpell()
    end,
    spell_w = function()
        mySpells:wSpell()
    end,
    spell_e = function()
        mySpells:eSpell()
    end ,
    get_priorities = function()
        return {
            "spell_e",
            "spell_q",
            "spell_w"
        }
    end
})