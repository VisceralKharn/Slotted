
print('vex loaded')

--g_input:cast_spell((test.spell), nil)

function createEnemiesList()
    local enemiesList = {}
    for _,v in pairs(features.entity_list:get_enemies()) do
        enemiesList.insert(v)
    end
    return enemiesList
end

function getTargetMr(target)
    --return 100 / (target.MR+100)
    return 100 / (target.total_mr + 100)
end

function vex()
    local myChamp = g_local
    local myChampSpellBook = myChamp:get_spell_book()

    local spellsList = {'q','w','e','r'}

    local mySpells = {
        q = {
            spell = e_spell_slot.q,
            apRatio = .7,
            Range = 1200,
            Width = 360,
            Speed = 1600,
            --Level = myChampSpellBook:get_spell_slot(e_spell_slot.q).level,
            Level = 0,
            Base = {60, 105, 150, 195, 240},
            CastTime = 0.15,
            coolDown = {8 , 7 , 6 , 5 , 4},
            TotalDamage = 0 },
        w = {
            spell = e_spell_slot.w,
            apRatio = .3,
            Range = 0,
            Width = 550,
            Speed = 10000,
            --Level = myChampSpellBook:get_spell_slot(e_spell_slot.w).level,
            Level = 0,
            Base = {80, 120, 160, 200, 240},
            CastTime = 0.25,
            TotalDamage = 0 },
        e = {
            spell = e_spell_slot.e,
            apRatio = {.4,.45,.5,.55,.6},
            Range = 1200,
            Width = 360,
            Speed = 1600,
            --Level = myChampSpellBook:get_spell_slot(e_spell_slot.e).level,
            Level = 0,
            Base = {50, 70, 90, 110, 130},
            CastTime = 0.15,
            TotalDamage = 0 },
        r = {
            spell = e_spell_slot.r,
            apRatio = {.2, .5},
            Range = 1200,
            Width = 360,
            Speed = 1600,
            --Level = myChampSpellBook:get_spell_slot(e_spell_slot.r).level,
            Level = 0,
            Base = {75 , 125 , 175 },
            Base2 = {150 , 250 , 350},
            CastTime = 0.15,
            TotalDamage = 0 },
        totalComboDamage = 0
    }


    function mySpells:selectSpell(spellKey)
        if spellKey == 'q' then
            spellValues = self.q
            spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.q)
            self.q.Level = spellSlot.level
        end
        if spellKey == 'w' then
            spellValues = self.w
            spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.w)
            self.w.Level = spellSlot.level
        end
        if spellKey == 'e' then
            spellValues = self.e
            spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.e)
            self.e.Level = spellSlot.level
        end
        if spellKey == 'r' then
            spellValues = self.r
            spellSlot = myChampSpellBook:get_spell_slot(e_spell_slot.r)
            self.r.Level = spellSlot.level
        end


        return spellValues, spellSlot
    end


    function mySpells:getSpellDamage(spell)
        local selectedSpell = self:selectSpell(spell)
        local selectedLevel = selectedSpell.Level
        local currentBase = selectedSpell.Base[selectedLevel]

        if spell ~= 'r' and spell ~= 'e' then
            self[spell].TotalDamage = ( myChamp:get_ability_power() * selectedSpell.apRatio) + currentBase
        end


        if spell == 'e' then
            self[spell].TotalDamage = ( myChamp:get_ability_power() * selectedSpell.apRatio[selectedSpell.Level]) + currentBase
        end

        if spell == 'r' then

            self[spell].TotalDamage = ( myChamp:get_ability_power() * selectedSpell.apRatio[1]) + currentBase

            local Base2 = selectedSpell.Base2[selectedLevel]

            self[spell].TotalDamage = self[spell].TotalDamage  + ( myChamp:get_ability_power() * selectedSpell.apRatio[2]) + Base2
        end

        return self[spell].TotalDamage
    end


    function mySpells:getSpellDamageToTarget(spell, target)
        return self:getSpellDamage(spell) * getTargetMr(target)
    end


    function mySpells:isSpellInRange(spell,target)
        local selectedSpell = self:selectSpell(spell)
        if target.position:dist_to(myChamp.position) <= selectedSpell.Range then
            return true
        else
            return false
        end
    end


    function mySpells:enemiesListInSpellRange(spell)
        local selectedSpell = self:selectSpell(spell)
        local enemiesList = {}
        for k,v in ipairs(features.entity_list:get_enemies()) do
            if v ~= nil and v:is_alive() and self:isSpellInRange(spell, v) then
                enemiesList.insert(v)
            end
        end
        return enemiesList
    end


    function mySpells:spellsInRangeOfTarget(target)
        local eligibleSpells = {}
        for _, v in pairs(spellsList) do
               --local selectedSpell, spellSlot = self:selectSpell(v)
            if self:isSpellInRange(v,target) and spellSlot:is_ready() then
                eligibleSpells.insert(v)
            end
           end
        return eligibleSpells
       end


    function mySpells:checkIfSpellListKillsATarget(target)
        for _,v in self:spellsInRangeOfTarget(target) do
            local totalDps = 0
            local spellsToCast = {}
            local targetHp = target.health
            if self:getSpellDamageToTarget(v,target) > targetHp then
                print("Spell "..v.."can kill, cast")
                myChamp:cast_spell((self[v].spell), target.position)
            elseif totalDps > targetHp then
                for _,v in pairs(totalDps) do
                    myChamp:cast_spell((self[v].spell), target.position)
                end
            else
                totalDps.insert(self:getSpellDamageToTarget(v,target))
                spellsToCast.insert(v)
            end
        end

    end

    function mySpells:CheckIfSpellListKillsATargetInEnemyList()
        for _,v in pairs(createEnemiesList()) do
            self:checkIfSpellListKillsATarget(v)
        end
    end


    function mySpells:totalComboDamage()
        self.totalComboDamage = 0
        for k,v in pairs(spellsList) do
            print(v)
            spellValues, spellSlot = mySpells:selectSpell(v)
            self[v].TotalDamage = mySpells:getSpellDamage(v)
            if spellSlot:is_ready() then
                    self.totalComboDamage = self.totalComboDamage + self[v].TotalDamage
                    --end
            end
        end
        return self.totalComboDamage
    end


    function mySpells:getTotalComboDamageTarget(target)
        local currentTotalDamage = mySpells:totalComboDamage()
        return currentTotalDamage * getTargetMr(target)
    end






    --function mySpells:fullComboKillableEnemiesInRange()
    --    local killableEnemies = {}
    --
    --    for _,v in pairs(self:enemiesInSpellRange('r')) do
    --        local enemyHp = v.health
    --        if enemyHp < self.getComboTargetDamage(v) then
    --            killableEnemies.insert(v)
    --        end
    --    end
    --    return killableEnemies
    --end



    cheat.register_callback("render", function()
        g_render:text(vec2:new(150, 50), color:new(255, 255, 255), tostring(mySpells:CheckIfSpellListKillsATargetInEnemyList()), "roboto-regular", 60)
    end)

end


    --
    --cheat.register_module(
    --        {
    --            champion_name = "Vex"
    --
    --        })



vex()


