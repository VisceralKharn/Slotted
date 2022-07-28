print('vex loaded')
local myChamp = g_local
local myChampSpellBook = myChamp:get_spell_book()



function vex()

    local mySpells = {}
    function mySpells:getSpells()
        self.spells = {
            q = {
                Range = 1200,
                Width = 360,
                Speed = 1600,
                Level = myChampSpellBook:get_spell_slot(e_spell_slot.q).level,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            w = {
                Range = 0,
                Width = 550,
                Speed = 10000,
                Level = myChampSpellBook:get_spell_slot(e_spell_slot.w).level,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            e = {
                Range = 1200,
                Width = 360,
                Speed = 1600,
                Level = myChampSpellBook:get_spell_slot(e_spell_slot.e).level,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            r = {
                Range = 1200,
                Width = 360,
                Speed = 1600,
                Level = myChampSpellBook:get_spell_slot(e_spell_slot.r).level,
                Base = {60, 105, 150, 195, 240},
                CastTime = 0.15,
                TotalDamage = 0 },
            }
            return self.spells
        end

    function mySpells:selectSpell(spell)
        if spell == 'q' then
            local selectedSpell = self.spells.q
        end
        if spell == 'w' then
            local selectedSpell = self.spells.w
        end
        if spell == 'e' then
            local selectedSpell = self.spells.e
        end
        if spell == 'r' then
            local selectedSpell = self.spells.r
        end
        return selectedSpell
    end

    function mySpells:InSpellRange(spell)
        selectedSpell = mySpells:selectSpell(spell)
        enemiesList = {}
        for i,v in ipairs(features.entity_list:get_enemies()) do
            if v ~= nil and v:is_alive() and v.position:dist_to(myChamp.position) <= selectedSpell.Range then
                enemiesList.insert(v)
            end
        end
        return enemiesList
    end

    function mySpells:getQDamage()
        mySpells:getSpells()
        local spell = mySpells:selectSpell('q')
        if spell.Base[spell.Level] ~= nil then
            local currentBase = spell.Base[spell.Level]
            spell.TotalDamage = ( myChamp:get_ability_power() * .70) + currentBase
        end
        return spell.TotalDamage
    end

    function mySpells:getWDamage()
        mySpells:getSpells()
        local spell = mySpells:selectSpell('w')
        if spell.Base[spell.Level] ~= nil then
            local currentBase = spell.Base[spell.Level]
            spell.TotalDamage = ( myChamp:get_ability_power() * .30) + currentBase
        end
        return spell.TotalDamage
    end

    function mySpells:getEDamage()
        mySpells:getSpells()
        local spell = mySpells:selectSpell('e')
        if spell.Base[spell.Level] ~= nil then
            local currentBase = spell.Base[spell.Level]
            spell.TotalDamage = ( myChamp:get_ability_power() * .70) + currentBase
        end
        return spell.TotalDamage
    end

    function mySpells:getRDamage()
        mySpells:getSpells()
        local spell = mySpells:selectSpell('r')
        if spell.Base[spell.Level] ~= nil then
            local currentBase = spell.Base[spell.Level]
            spell.TotalDamage = ( myChamp:get_ability_power() * .20) + currentBase
            spell.TotalDamage = spell.TotalDamage + ( myChamp:get_ability_power() * .50) + currentBase
        end
        return spell.TotalDamage
    end



    function mySpells:getTargetQDamage(target)
        currentTotalQDamage = mySpells:getQDamage()

    end

    cheat.register_callback("render", function()
        g_render:text(vec2:new(150, 50), color:new(255, 255, 255), tostring(mySpells:getQDamage()), "roboto-regular", 60)
    end)
end




    --
    --cheat.register_module(
    --        {
    --            champion_name = "Vex"
    --
    --        })



vex()


