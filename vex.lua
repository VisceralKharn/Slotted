print('vex loaded')


--g_input:cast_spell((test.spell), nil)
function createEnemiesList()
    return features.entity_list:get_enemies()
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
            lastCast = 0,
            manaCost = {45,50,55,60,65},
            spell = myChampSpellBook:get_spell_slot(e_spell_slot.q),
            spellSlot = e_spell_slot.q,
            apRatio = .7,
            Range = 1200,
            Width = 360,
            Speed = 1600,
            Level = 0,
            Base = {60, 105, 150, 195, 240},
            CastTime = 0.15,
            coolDown = {8 , 7 , 6 , 5 , 4},
            TotalDamage = 0 },
        w = {
            lastCast = 0,
            manaCost = {75,75,75,75,75},
            spell = myChampSpellBook:get_spell_slot(e_spell_slot.w),
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
            manaCost = {70,80,90,100,110},
            spell = myChampSpellBook:get_spell_slot(e_spell_slot.e),
            spellSlot = e_spell_slot.e,
            apRatio = {.4,.45,.5,.55,.6},
            Range = 1200,
            Width = 360,
            Speed = 1600,
            Level = 0,
            Base = {50, 70, 90, 110, 130},
            CastTime = 0.15,
            TotalDamage = 0 },
        r = {
            lastCast = 0,
            manaCost = {100, 100, 100},
            spell = myChampSpellBook:get_spell_slot(e_spell_slot.r),
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
        self['q'].Level = myChampSpellBook:get_spell_slot(e_spell_slot.q).level
        self['w'].Level = myChampSpellBook:get_spell_slot(e_spell_slot.w).level
        self['e'].Level = myChampSpellBook:get_spell_slot(e_spell_slot.e).level
        self['r'].Level = myChampSpellBook:get_spell_slot(e_spell_slot.r).level
    end


    function mySpells:getSpellDamage(spell)
        self:refreshSpells()
        local selectedLevel = self[spell].Level
        local currentBase = self[spell].Base[selectedLevel]

        if spell ~= 'r' and spell ~= 'e' then
            self[spell].TotalDamage = ( myChamp:get_ability_power() * self[spell].apRatio) + currentBase
        end


        if spell == 'e' then
            self[spell].TotalDamage = ( myChamp:get_ability_power() * self[spell].apRatio[self[spell].Level]) + currentBase
        end

        if spell == 'r' then

            self[spell].TotalDamage = ( myChamp:get_ability_power() * self[spell].apRatio[1]) + currentBase

            local Base2 = self[spell].Base2[selectedLevel]

            self[spell].TotalDamage = self[spell].TotalDamage  + ( myChamp:get_ability_power() * self[spell].apRatio[2]) + Base2
        end

        return self[spell].TotalDamage
    end


    function mySpells:getSpellDamageToTarget(spell, target)
        return self:getSpellDamage(spell) * getTargetMr(target)
    end


    function mySpells:isSpellInRange(spell,target)
        if spell ~= 'r' then
            if target.position:dist_to(myChamp.position) <= self[spell].Range then
                return true
            else
                return false
            end
        end
        if spell == 'r' then
            local rLevel = self[spell].Level
            print('printing r spell range '..self[spell].Range[rLevel])
            if target.position:dist_to(myChamp.position) <= self[spell].Range[rLevel] then
                return true
            else
                return false
            end
        end

    end


    function mySpells:listOfEnemiesInSpellRange(spell)
        local enemiesList = {}
        for k,v in ipairs(features.entity_list:get_enemies()) do
            if v ~= nil and v:is_alive() and self:isSpellInRange(spell, v) then
                table.insert(enemiesList, v)
            end
        end
        return enemiesList
    end


    function mySpells:spellsInRangeOfTarget(target)
        local eligibleSpells = {}
        for _, v in pairs(spellsList) do
               --local self[spell], spellSlot = self:selectSpell(v)
            if self:isSpellInRange(v,target) and self:isSpellReady(v) then
                table.insert(eligibleSpells, v)
            end
           end
        return eligibleSpells
       end



    function mySpells:checkIfSpellListKillsATarget(spellList, target)
        for _,v in pairs(spellList) do
            local totalDps = 0
            local spellsToKillCount = 0
            local spellsToCast = {}
            local targetHp = target.health
            print(targetHp)
            if self:getSpellDamageToTarget(v,target) > targetHp then
                print("Spell "..v.."can kill, cast")
                self:castSpellOnTarget((self[v].spell), target.position)
            elseif totalDps > targetHp then
                for _,v in pairs(spellsToCast) do
                    self:castSpellOnTarget((self[v].spell), target.position)
                end
            else
                totalDps = totalDps + self:getSpellDamageToTarget(v,target)
                table.insert(spellsToCast, v)
            end
        end
        print(totalDps)
    end

    --if features.orbwalker:get_mode() == Combo_key
    --if target out of range but killable




    function mySpells:isSpellReady(spell)
            if self[spell].spell:is_ready() then
                return true
            else
                return false
            end
    end

    function mySpells:haveEnoughMana(spell)
        if myChamp.mana >= self[spell].manaCost[self[spell].Level] then
            return true
        else
            return false
        end
    end

    function mySpells:canCast(spell)
        if self:isSpellReady(spell) and self:haveEnoughMana(spell) then
            return true
        else
            return false
        end
    end

    function mySpells:castSpellOnTarget(spellToCast,target)
        if self:canCast(spellToCast) then
                local castSpellSlot = self[spellToCast].spellSlot
                print('casting spell '..spellToCast)
                if target ~= nil then
                    g_input:cast_spell((castSpellSlot), target.position)
                else
                    g_input:cast_spell(castSpellSlot)
                end
        end
    end


    function standardCombo()
            mySpells:refreshSpells()
            local target = features.target_selector:get_default_target()
            for _, spell in pairs(spellsList) do
                if spell ~= 'r' then
                    if mySpells:isSpellInRange(spell, target) then
                        if spell ~= 'w' then
                            mySpells:castSpellOnTarget(spell, target)
                        else
                            mySpells:castSpellOnTarget(spell, nil)
                        end
                    end
                end
            end
    end



    function womboCombo()
        if features.orbwalker:get_mode() == Combo_key then
            mySpells:refreshSpells()
            local totalDamageToTarget = 0
                for _,vTarget in pairs(createEnemiesList())
                do
                    print('targets current health '..vTarget.health)
                    if mySpells:isSpellInRange('q', vTarget) == false then
                        print('out of Q range')
                        print(mySpells:isSpellInRange('r',vTarget))
                        if mySpells:isSpellInRange('r',vTarget) == true then
                            print('in R range')
                            for _,vSpell in pairs(spellsList)
                            do
                                if mySpells:isSpellReady(vSpell) then
                                    totalDamageToTarget = totalDamageToTarget + mySpells:getSpellDamageToTarget(vSpell,vTarget)

                                end
                            end
                            print('total damage done to target '..totalDamageToTarget)
                            if totalDamageToTarget > vTarget.health then
                                print('total damage higher than target health, execute')
                                mySpells:castSpellOnTarget('r', vTarget)
                                mySpells:castSpellOnTarget('r', nil)
                                for _,vSpell in pairs(spellsList)
                                do
                                    mySpells:castSpellOnTarget(vSpell, vTarget)
                                end
                            end
                        end
                    else
                        standardCombo()
                    end
                    end
               end
        end


    --cheat.register_callback("render", function()
    --    g_render:text(vec2:new(150, 50), color:new(255, 255, 255), mySpells:CheckIfSpellListKillsATargetInEnemyList(), "roboto-regular", 60)
    --end)

    --mySpells:refreshSpells()

    --mySpells:CheckIfSpellListKillsATargetInEnemyList(enemies:createEnemiesList(),spellList)

    --cheat.register_callback('feature', function()
    --    womboCombo()
    --end
    --)

    Combo_key = 1
    Clear_key = 3
    Harass_key = 4

    cheat.register_callback('feature', function()
        womboCombo()
    end
    )


end
vex()






--function mySpells:totalComboDamage()
--    self.totalComboDamage = 0
--    for k,v in pairs(spellsList) do
--        print(v)
--        spellValues, spellSlot = mySpells:selectSpell(v)
--        self[v].TotalDamage = mySpells:getSpellDamage(v)
--        if spellSlot:is_ready() then
--                self.totalComboDamage = self.totalComboDamage + self[v].TotalDamage
--                --end
--        end
--    end
--    return self.totalComboDamage
--end

--cheat.register_callback("render", function()
--    g_render:text(vec2:new(150, 50), color:new(255, 255, 255), mySpells:CheckIfSpellListKillsATargetInEnemyList(), "roboto-regular", 60)
--end)