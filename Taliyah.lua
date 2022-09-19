--[[

​Rendo's Taliyah Auto W-E-Q



​Features



-Auto Q if first Q hits

-Auto W Smart logic for pushing closer/away

-Auto E Smart logic for synergy with W



​​To do



-fix Antigapclose E

-maybe force movements for Q to follow enemy (let me know)

]]


ComboKey = 1
LasthitKey = 2
LaneclearKey = 3
HarassKey = 4
FleeKey = 5
blue = color:new(0,0,255)
green = color:new(0,255,0)
purple = color:new(153,0,153)
red = color:new(255,0,0)
storedpos = {}
storedtime = {}

script_name = "Rendo's Taliyah"
local test_navigation = menu.get_main_window():push_navigation(script_name, 10000)
local my_nav = menu.get_main_window():find_navigation(script_name)
local combo_sect = my_nav:add_section("Combo Settings")
local drawings_sect = my_nav:add_section("Drawing Settings")

local q_combo_config = g_config:add_bool(true, "Q_in_combo")
local e_combo_config = g_config:add_bool(true, "E_in_combo")
local w_combo_config = g_config:add_bool(true, "W_in_combo")
local e_draw_config = g_config:add_bool(true, "Draw_E")
local q_draw_config = g_config:add_bool(true, "Draw_Q")
local w_draw_config = g_config:add_bool(true, "Draw_W")

local q_combo_box = combo_sect:checkbox("Use Q in Combo", q_combo_config)
local w_combo_box = combo_sect:checkbox("Use W in Combo", w_combo_config)
local e_combo_box = combo_sect:checkbox("Use E in Combo", e_combo_config)
local q_draw_box = drawings_sect:checkbox("Draw Q", q_draw_config)
local w_draw_box = drawings_sect:checkbox("Draw W", w_draw_config)
local e_draw_box = drawings_sect:checkbox("Draw E", e_draw_config)

q_combo_box:set_value(true)
w_combo_box:set_value(true)
e_combo_box:set_value(true)
q_draw_box:set_value(true)
w_draw_box:set_value(true)
e_draw_box:set_value(true)

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
        manaCost = {55 , 60 , 65 , 70 , 75},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.q),
        spellSlot = e_spell_slot.q,
        apRatio = .5,
        Range = 980,
        Width = 200,
        Speed = 1950,
        Level = 0,
        Base = {45, 65, 85, 105, 125},
        CastTime = 0.25,
        coolDown = {7 , 6 , 5 , 4 , 3},
        TotalDamage = 0 },
    w = {
        lastCast = 0,
        manaCost = {40 , 30 , 20 , 10 , 0},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.w),
        spellSlot = e_spell_slot.w,
        apRatio = 0,
        Range = 890,
        Width = 225 / 2,
        Speed = 0,
        Level = 0,
        Base = {0, 0, 0, 0, 0},
        CastTime = 0.80,
        TotalDamage = 0 },
    e = {
        lastCast = 0,
        manaCost = {90 , 95 , 100 , 105 , 110},
        spell = g_local:get_spell_book():get_spell_slot(e_spell_slot.e),
        spellSlot = e_spell_slot.e,
        Range = 790,
        Width = 40,
        Speed = 0,
        Level = 0,
        CastTime = 0.25,
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
        print('casting spell '..spellToCast)
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

function mySpells:shouldStopStupidCast(target,predictionPos)
    if getDistance(target.position, predictionPos) > 500 then
        return True
    else
        return False
    end
end


function mySpells:isMinionInWay(spell,position)
    return features.prediction:minion_in_line(g_local.position, position, self[spell].Width)
end

function mySpells:qSpell(predPos)

        local mode = features.orbwalker:get_mode()
        if mode == ComboKey or mode == HarassKey then
            if predPos.position ~= nil and getDistance(g_local.position, predPos.position) <= self['q'].Range then
                if self:isMinionInWay('q',predPos.position) == false then
                    self:castSpellLocation('q',predPos.position)

                end
            end
        end


end


function mySpells:wSpell(predPos)

        local mode = features.orbwalker:get_mode()
        if mode == FleeKey then
            if predPos.position ~= nil and getDistance(g_local.position, predPos) <= self['w'].Range then
                g_input:cast_spell(1, predPos.position, g_local.position:extend(predPos.position, 75 + getDistance(g_local.position, predPos.position)))
            end
        end
        if mode == ComboKey then
            if predPos.position ~= nil and getDistance(g_local.position, predPos.position) < 525 then
                if target ~= nil then
                    self:eSpell('e',target)
                end
                g_input:cast_spell(1, predPos.position, g_local.position:extend(predPos.position, 75 + getDistance(g_local.position, predPos.position)))
            elseif self:canCast('e') then
                if predPos ~= nil and getDistance(g_local.position, predPos.position) > 525 then
                    if getDistance(g_local.position, predPos.position) <= self['w'].Range then
                        g_input:cast_spell(1, predPos.position, g_local.position:extend(predPos.position, 75 - getDistance(g_local.position, predPos.position)))
                    end
                end
            end
        end

end

function mySpells:eSpell(target)

        local mode = features.orbwalker:get_mode()
        if mode == ComboKey or mode == FleeKey then
            if getDistance(g_local.position, position) <= self['e'].Range  then
                self:castSpellLocation('e',target.position)
            end
        end


end


    

cheat.register_module({
    champion_name = "Taliyah",
    spell_q = function()
        if q_combo_box:get_value() then
            if features.target_selector:get_default_target() ~= nil then
                mySpells:qSpell(mySpells:predPosition('q', features.target_selector:get_default_target()))
            end

        end
    end,
    spell_w = function()
        if w_combo_box:get_value() then
            if features.target_selector:get_default_target() ~= nil then
                mySpells:wSpell(mySpells:predPosition('w', features.target_selector:get_default_target()))
            end

        end
    end,
    spell_e = function()
        if e_combo_box:get_value() then
            if features.target_selector:get_default_target() ~= nil then

                mySpells:eSpell(features.target_selector:get_default_target())
            end

        end
    end,
    get_priorities = function()
        return {
            "spell_w",
            "spell_e",
            "spell_q"
        }
    end
})
