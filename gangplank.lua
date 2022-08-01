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

function champion()
    local myChamp = g_local
    local myChampSpellBook = myChamp:get_spell_book()


    local mySpells = {
        q = {
            lastCast = 0,
            manaCost = {55 / 50 / 45 / 40 / 35},
            spell = myChampSpellBook:get_spell_slot(e_spell_slot.q),
            spellSlot = e_spell_slot.q,
            apRatio = .7,
            Range = 625,
            Width = 360,
            Speed = 2600,
            Level = 0,
            Base = {60, 105, 150, 195, 240},
            CastTime = 0.25,
            coolDown = {8 , 7 , 6 , 5 , 4},
            TotalDamage = 0 },
        w = {
            lastCast = 0,
            manaCost = {60 / 70 / 80 / 90 / 100},
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
            manaCost = {0,0,0,0,0},
            spell = myChampSpellBook:get_spell_slot(e_spell_slot.e),
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
    mySpells:refreshSpells()



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


    function mySpells:castSpellLocation(spellToCast,location)
        if self:canCast(spellToCast) then
            local castSpellSlot = self[spellToCast].spellSlot
            print('casting spell '..spellToCast)
            g_input:cast_spell((castSpellSlot), location)
        end
    end

    function mySpells:isSpellInRange(spell,target)
        if target.position:dist_to(myChamp.position) <= self[spell].Range then
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
       return self['e'].spell.charges
   end




    function mySpells:checkNumberOfActiveBarrels()
        local activeBarrels = 0
        for k,v in pairs(createEnemyMinionsList()) do
            if v:get_object_name() == 'GangplankBarrel' then
                activeBarrels = activeBarrels + 1
            end
        end
        return activeBarrels
    end

    function mySpells:placeBarrel()
        if self:checkNumberOfActiveBarrels() == 0 then
            self:castSpellLocation('e', myChamp.position)
        end
    end


    mySpells:placeBarrel()

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


end

champion()