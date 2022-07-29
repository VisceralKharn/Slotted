print('vex loaded')
local myChamp = g_local
local myChampSpellBook = myChamp:get_spell_book()



function vex()

    local mySpells = {
        totalComboDamage = 0,
            q = {
                apRatio = .7,
                Range = 1200,
                Width = 360,
                Speed = 1600,
                --Level = myChampSpellBook:get_spell_slot(e_spell_slot.q).level,
                Level = 0,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            w = {
                apRatio = .3,
                Range = 0,
                Width = 550,
                Speed = 10000,
                --Level = myChampSpellBook:get_spell_slot(e_spell_slot.w).level,
                Level = 0,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            e = {
                apRation = {.4,.45,.5,.55,.6},
                Range = 1200,
                Width = 360,
                Speed = 1600,
                --Level = myChampSpellBook:get_spell_slot(e_spell_slot.e).level,
                Level = 0,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            r = {
                apRatio = {.2, .5},
                Range = 1200,
                Width = 360,
                Speed = 1600,
                --Level = myChampSpellBook:get_spell_slot(e_spell_slot.r).level,
                Level = 0,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            }



    function mySpells:selectSpell(spell)
        if spell == 'q' then
            local spellValues = self.spells.q
            local spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.q)
            self.spells.q.Level = spellSlot.level

        end
        if spell == 'w' then
            local spellValues = self.spells.w
            local spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.w)
            self.spells.w.Level = spellSlot.level
        end
        if spell == 'e' then
            local spellValues = self.spells.e
            local spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.e)
            self.spells.e.Level = spellSlot.level
        end
        if spell == 'r' then
            local spellValues = self.spells.r
            local spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.r)
            self.spells.r.Level = spellSlot.level
        end

        spellState = {
            valid = spellSlot:is_valid(),
            cooldown = spellSlot:get_cooldown(),
            ready = spellSlot:is_ready()
        }

        return spellValues, spellSlot, spellState
    end


    function mySpells:InSpellRange(spell)
        local selectedSpell = mySpells:selectSpell(spell)
        local enemiesList = {}
        for i,v in ipairs(features.entity_list:get_enemies()) do
            if v ~= nil and v:is_alive() and v.position:dist_to(myChamp.position) <= selectedSpell.Range then
                enemiesList.insert(v)
            end
        end
        return enemiesList
    end


    function mySpells:getSpellDamage(spell)
        local spell = mySpells:selectSpell(spell)
        if spell.Base[spell.Level] ~= nil or spell.Base[spell.Level] ~= 0 then
            local currentBase = spell.Base[spell.Level]
            if spell ~= 'r' then
                spell.TotalDamage = ( myChamp:get_ability_power() * spell.apRatio) + currentBase
            end
            if spell == 'r' then
                spell.TotalDamage = ( myChamp:get_ability_power() * spell.apRatio[0]) + currentBase
                spell.TotalDamage = spell.TotalDamage + ( myChamp:get_ability_power() * spell.apRatio[1]) + currentBase
            end
        end
        return self.spell.TotalDamage
    end



    function mySpells:currentTotalComboDamage()
        local totalComboDamage = 0
        for k,v in self.mySpells do
            spellValues, spellSlot, spellState = mySpells:selectSpell(k)
            self.spellValues.TotalDamage = getSpellDamage(k)
            if spellState.ready and spellState.valid then
                self.totalComboDamage = totalComboDamage + self.spellValues.TotalDamage
            end
        end
        return self.totalComboDamage
    end


    function mySpells:getTargetQDamage(target)
        local currentTotalQDamage = mySpells:getQDamage()

    end


    cheat.register_callback("render", function()
        g_render:text(vec2:new(150, 50), color:new(255, 255, 255), tostring(mySpells:currentTotalComboDamage()), "roboto-regular", 60)
    end)
end




    --
    --cheat.register_module(
    --        {
    --            champion_name = "Vex"
    --
    --        })



vex()


