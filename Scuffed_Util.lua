local Script_name = ("scuffed")
local test_navigation = menu.get_main_window():push_navigation(Script_name, 10000)
-- Create new config var
local NME_config = g_config:add_bool(true, "NME")
local LTL_config = g_config:add_bool(true, "Lthl")
local MIN_config = g_config:add_bool(true, "MIN")
local LANE_config = g_config:add_bool(true, "LANE")
local JINX_config = g_config:add_bool(true, "HARASS")
local ManualR_config = g_config:add_bool(true, "MANUALR")


local my_nav = menu.get_main_window():find_navigation(Script_name)

local scuff_sect = my_nav:add_section("Scuffed")

local checkboxNME = scuff_sect:checkbox("draw to enemy", NME_config)
local checkboxLethal = scuff_sect:checkbox("draw Lethal", LTL_config)
local checkboxMinion = scuff_sect:checkbox("draw Minions", MIN_config)
local checkboxLane = scuff_sect:checkbox("draw Lane pressure", LANE_config)
local checkboxJinx = scuff_sect:checkbox("Jinx rocket splash circle", JINX_config)
local checkboxManR = scuff_sect:checkbox("Semi Auto R key press U key (Jinx only atm)", ManualR_config)

Combo_key = 1
Clear_key = 3
Harass_key = 4

-- FEEL FREE TO CHANGE THESE DEFAULTS
checkboxNME:set_value(false)
checkboxLethal:set_value(false)
checkboxMinion:set_value(false)
checkboxLane:set_value(false)
checkboxJinx:set_value(false)
checkboxManR:set_value(true)

-- FEEL FREE TO CHANGE THESE DEFAULTS By setting "true" to "false"



function Prints(str)
    -- if my debugs messages are clogging up your lua log set dbg = 0 and all of them will stop
    local dbg = 1
    if dbg == 1 then 
        print(os.date('%H:%M:%S') .." ".. str) 
    end
end

function CalcDamage(index, rawDamage)
    Prints("cdt")
    
    local target = features.entity_list:get_by_index(index)
    if target == nil then return 0 end
    --Prints("Calcing: " .. target:get_object_name())
    local armor = target.total_armor
    calc = (rawDamage * ( 100 / ( 100 + armor )))
    Prints("lc")
    return calc
end

function CalcDamageAP(index, rawDamage)
    local target = features.entity_list:get_by_index(index)
    local mr = target.total_mr
    return (rawDamage * ( 100 / ( 100 + mr )))
end


function getQLevel()
    return g_local:get_spell_book():get_spell_slot(e_spell_slot.q).level
 end
function getWLevel()
    return g_local:get_spell_book():get_spell_slot(e_spell_slot.w).level
 end
function getELevel()
    return g_local:get_spell_book():get_spell_slot(e_spell_slot.e).level
 end
function getRLevel()
   return g_local:get_spell_book():get_spell_slot(e_spell_slot.r).level
end

function BonusAD()
   Hero = g_local
   return Hero.bonus_attack
end

function getAP()
   return g_local:get_ability_power()
end

function getAD()
    return g_local:get_attack_damage()
 end



 function get_rend_damage(index)
    Prints("Get rend dmg")
    local target = features.entity_list:get_by_index(index)
    local base = 20
    local levelDmg = 10*getELevel()
    local ad = getAD()
    local first_multiplier = 0.7
    local second_multiplier = (0.232+(0.0435*getELevel()))
    if getELevel() > 4 then second_multiplier = 0.406 end
    local first_spear_dmg = (base + levelDmg + ad*first_multiplier)
    local other_spear_dmg = (base + ad*second_multiplier)
    local num_other_spears = getStacks(index, 'kalistaexpungemarker')-1

    local raw = first_spear_dmg + (num_other_spears*other_spear_dmg)
    print(target:get_object_name() .. " has ".. num_other_spears + 1 .. " spear stacks and will take ".. raw .. " damage from rend before armour")
    if raw < 0 then return 0 end 
    -- Prints("first:" .. first_spear_dmg)
    -- Prints("seconds" .. other_spear_dmg * num_other_spears)
    -- Prints("subsequent muliplier is: " .. second_multiplier  )
    -- Prints("AD:".. getAD() .. " + " .. BonusAD())
    Prints("leaving rend calc")
    return raw
    -- 145 
    -- 229
end

function get_jinx_multiplier(index)
  local target = features.entity_list:get_by_index(index)

  if g_local.position:dist_to(target.position) >= 1500 then
      return 1
  elseif g_local.position:dist_to(target.position) <= 100 then
      return 0.1
  else
      return 0.10 + (0.06*((g_local.position:dist_to(target.position))/100))
  end

end

function getStacks(index , str)
    local s = 0
    Prints("checking spears")
    local target = features.entity_list:get_by_index(index)
    Prints("checking for spears on ".. target:get_object_name())
    for j, buff in pairs(features.buff_cache:get_all_buffs(target.index)) do  
        Prints(buff.name)  
        if buff.name == str then
            Prints("Found it")
            local num = buff:get_stacks();
            if num == nil then 
                print("tf man")
                return 0; 
            end
           
            Prints("num is not nil....")
            Prints(num .. " spears")
            return num
        end
    end
    Prints("spears: " .. s)
    return s  
end

--/**
-- I'd like to do it this way but this method is broken
--**/
function gs(index, str)
    Prints("checking spears 2")
    local s = 0
    -- this doesnt work :(
    local stacks = features.buff_cache:get_buff(index, str):get_stacks() 
    if stacks ~= nil then
        print(stacks)
        s = s + stacks
    end

    Prints("got spears: " .. s)
    return s   
end


function Can_R()
    Prints("check ready " .. espell)
   if  g_local:get_spell_book():get_spell_slot(e_spell_slot.r):is_ready() and g_local.mana  > Spell_Cost then 
        return true
   end
  
   return false
end

function mega()
    if checkboxJinx:get_value() == false then return false end
    --Prints("Process minions go in at " .. #MinionToHarass)
    local hero_Table = features.entity_list:get_enemy_minions()
    for i, obj_hero in ipairs(hero_Table) do
        --Prints("minion loop on " .. obj_hero:get_object_name())
        if obj_hero:is_alive() and obj_hero:is_visible() and g_local.position:dist_to(obj_hero.position) < g_local.attack_range+180 and g_local.position:dist_to(obj_hero.position) > g_local.attack_range then
            local exists = 0
            if #MinionToHarass > 0 then
                --Prints("checking if our list already has " .. obj_hero.index)
                for ii, alive in pairs(MinionToHarass) do
                    --Prints("have: " .. alive.idx .. " check: " .. obj_hero.index)
                    if alive.idx == obj_hero.index then
                        --Prints("we do!")
                        exists = 1
                    end
                end
            end
            if exists == 0 then
                table.insert(MinionToHarass, {idx = obj_hero.index }) 
            end        end
    end
end
        -- if (features.orbwalker:get_mode() == Harass_key and g_input:is_key_pressed(17)) then
        --     local hero_Table = features.entity_list:get_enemies()
        --     --
        --     for i, obj_hero in ipairs(hero_Table) do
        --         if obj_hero:is_alive() and obj_hero:is_visible() and g_local.position:dist_to(obj_hero.position) < g_local.attack_range+180 then
        --             if g_local.position:dist_to(obj_hero.position) > g_local.attack_range then
        --                 Prints("KILLL!!!")
        --             end
        --         end
        --     end

        -- end
------ -=--==--=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=
function lanes()
    Processlane()
end

function Score(list)
    local points = 0
    for i, min in ipairs(list) do
        if min:is_alive() and min:is_visible() and g_local.position:dist_to(min.position) < 1100 then
            local str = min:get_object_name() 
            if string.find(str, "Siege") then
                points = points + 2
            elseif string.find(str, "Ranged") then
                points = points + 1
            elseif string.find(str, "Melee") then
                points = points + 0.7
            end           
        end
    end
    return math.floor(points)
end

function Processlane()
    if  checkboxLane:get_value() == false then return false end
    --Prints("Process minions go in at " .. #MinionInRange)
    local aScore = Score(features.entity_list:get_ally_minions())
    --Prints("aScore: "  .. aScore)
    local eScore = Score(features.entity_list:get_enemy_minions())
    --Prints("eScore: "  .. eScore)

    if aScore==eScore then
        Pressure= "EVEN"
        Color = Blue
    elseif aScore>eScore then 
        Pressure = ("+ " .. aScore-eScore)
        Color = Green
    else
        Pressure = ("- " .. eScore-aScore)
        Color  = Red
        if eScore-aScore == 4 then
            Pressure = ("+ " .. eScore-aScore)
            Color  = White
        end
    end
    -- Prints(Pressure)
    

    -- Prints("end lane process")
end
--- =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==---=-=
function minions()
    ProcessMinions()
end

function ProcessMinions()
    if  checkboxMinion:get_value() == false then return false end
    --Prints("Process minions go in at " .. #MinionInRange)
    local hero_Table = features.entity_list:get_enemy_minions()
    for i, obj_hero in ipairs(hero_Table) do
        --Prints("minion loop on " .. obj_hero:get_object_name())
        if obj_hero:is_alive() and obj_hero:is_visible() and g_local.position:dist_to(obj_hero.position) < 900 then
            --Prints(obj_hero:get_object_name() .. " in range id: " .. obj_hero.index)
            local exists = 0
            if #MinionInRange > 0 then
                --Prints("checking if our list already has " .. obj_hero.index)
                for ii, alive in pairs(MinionInRange) do
                    --Prints("have: " .. alive.idx .. " check: " .. obj_hero.index)
                    if alive.idx == obj_hero.index then
                        --Prints("we do!")
                        alive.damage = (getAD() + 1)
                        alive.damageMore = (getAD() + 1 + getAD() + 1 + 5)
                        exists = 1
                    end
                end
            end
            if exists == 0 then
                --Prints("nope this one is new")
                local aa = getAD() + 1
                table.insert(MinionInRange, {idx = obj_hero.index , damage = aa, damageMore = (aa + aa + 5)}) 
                --Prints("added min now at ".. #MinionInRange)
            end
        end 
    end

    --Prints("cleaning minion list .. " .. #MinionInRange)
    for iii, enemy in pairs(MinionInRange) do
        local remove = false
        local obj = features.entity_list:get_by_index(enemy.idx)
        if obj ~= nil then
            if g_local.position:dist_to(obj.position) > 900 then remove = true end
            if obj:is_alive() == false then remove = true end
            if obj:is_visible() == false then remove = true end
        else
            remove = true
        end
        if remove then 
            table.remove(MinionInRange, iii)
            --Prints("remove min now at ".. #MinionInRange)
        end
        --Prints("this can stay")
    end
    --Prints("end minion process")
end

function Ready(spell)
    --Prints("check ready " .. espell)
    local slot = g_local:get_spell_book():get_spell_slot(spell)
    if slot == nil then Prints("slots nil mate ") return false end
    local mana = slot:get_mana_cost()
    local cost = mana[slot.level]
    if cost == nil then return false end
    local has_mana =  cost < g_local.mana
    return slot:is_ready() and slot.level > 0 and has_mana
end

function semiAutoR()
    if  checkboxManR:get_value() == false then return false end
    if Ready(e_spell_slot.r) then 
        if g_input:is_key_pressed(85) then -- U key T is 84, Y is 89
            Target = features.target_selector:get_default_target()
            -- dont do it if: nil or invis or bad target or not attackable or out of range XD
            if Target == nil then Prints("nil target manual ulti") return false end
            if features.target_selector:is_bad_target(Target.index) then Prints("bad target manual ulti") return false end
            if not features.orbwalker:is_attackable(Target.index, 3500, true) then Prints("not atkble manual ulti") return false end 
            if not (Target:is_alive() and Target:is_visible()) then Prints("dead or invis tgt manual ulti") return false end
            if g_local.position:dist_to(Target.position) > 3500 then Prints("man ult target to far away") return false  end
            
            -- do predict
            local qHit = features.prediction:predict(Target.index, SpellData[Hero_Champ].R_range, SpellData[Hero_Champ].R_speed, SpellData[Hero_Champ].R_width, SpellData[Hero_Champ].R_windup, g_local.position) 
            if (qHit.valid and qHit.hitchance >= 2) then
                Prints("cast manual R")
                g_input:cast_spell(e_spell_slot.r, qHit.position)
                return true
            end
            
            --Prints("Manual Ulti go")
        end
    end
end

 ----  =-=-=--==-=-=-=-=-=-=-=-=-=--=-=-=-=
function ks()
    if  checkboxLethal:get_value() == false then return false end
    ProcessKS()
end

function ProcessKS()
    -- get enemies
    --Prints("pks go in at " .. #NmeInRange)
    local hero_Table = features.entity_list:get_enemies()
    for i, obj_hero in ipairs(hero_Table) do
        --Prints("pks loop in " .. obj_hero:get_object_name())
        if obj_hero:is_alive() and obj_hero:is_visible() and g_local.position:dist_to(obj_hero.position) < Spell_Width then         
            local exists = 0
            if #NmeInRange > 0 then
                for ii, alive in pairs(NmeInRange) do
                    if alive.champ == obj_hero.index then 
                        dmg = SpellData[Hero_Champ].DMG(obj_hero.index)
                        --Prints("Stored dmg is " .. alive.damage .. " new dmg is " .. dmg )
                        alive.damage = dmg
                        --Prints("Stored dmg now: " .. dmg )
                        exists = 1
                    end
                end
            end

            if exists == 0 then
                table.insert(NmeInRange, {champ = obj_hero.index ,damage = SpellData[Hero_Champ].DMG(obj_hero.index)}) 
            end
        else  
            for iii, enemy in pairs(NmeInRange) do
                local obj = features.entity_list:get_by_index(enemy.champ)
                if not obj:is_alive() or not obj:is_visible() then
                    table.remove(NmeInRange, i)
                end
            end
        end   
    end
end

function Vec3_Extend(a,b, dist) 
    local distance = a:dist_to(b) 
    local offset = dist / distance 
    local dir = vec3:new((a.x - b.x), b.y, (a.z - b.z)) 
    local newPos = vec3:new((a.x + dir.x*offset), b.y, (a.z + dir.z*offset)) 
    return newPos 
end

--==--=-=-=-===-==-=-=-=-=-=-=-=-=---=-=-=
function DrawLinesToEnemies()
  --Prints("Dlte enter")
  local hero_Table = features.entity_list:get_enemies()
  for i, obj_hero in ipairs(hero_Table) do
    if obj_hero ~= nil and obj_hero:is_alive() then
        
        local dist = g_local.position:dist_to(obj_hero.position)
        local middleAndShown = dist <= 4500 and obj_hero:is_visible()
        local closeEnough = dist <= 1500
        local nearby = dist <= 900
        local dist_color = White
        if dist >= 3000 then 
            dist_color = color:new(100,255,100)
        elseif dist >= 1200 then
            dist_color = White
        else 
            dist_color = Red
        end
        if nearby then 
            g_render:line(g_local.position:to_screen(), obj_hero.position:to_screen(), Red,3)
        elseif middleAndShown or closeEnough then   
            g_render:circle_3d(g_local.position, Red, 900, 2, 90, 2)   
            local nmeChamp = obj_hero:get_object_name()
            local champ_texture = "C:\\resources\\champions\\" .. nmeChamp.. "\\" .. nmeChamp .."_square.png"
            local texture = g_render:load_texture_from_file(champ_texture)
            local hmm = Vec3_Extend(g_local.position, obj_hero.position, -900)
            g_render:line(g_local.position:to_screen(), hmm:to_screen(), Red,3)
            g_render:image(hmm:to_screen(), vec2:new(50,50), texture)
            g_render:text(hmm:to_screen(), dist_color, "" .. math.floor(dist), Font, 20)
        end


      end
  end
  --Prints("Dlte exit")
end

function DrawMins()
    local Square_color = color:new( 255,255,255)
    
    for _,obj_min_ in pairs(MinionInRange) do
        local obj_min = features.entity_list:get_by_index(obj_min_.idx)
        if obj_min ~= nil then 
            --Prints("I have you now" .. obj_min.index)
            if obj_min:is_minion() then
                --Prints("draw circle")
                local aa = getAD() +1
                local hp = obj_min.health -- features.prediction:predict_health(g_local, 0.15, true)
                if hp < aa then
                    g_render:circle(obj_min.position:to_screen(), color:new( 255,0,255), 15, 90)
                    --radius, flags, segments, thickness
                    --g_render:circle_3d(obj_min.position, color:new( 255,0,255), 15, 0, 90, 2)
                elseif hp < aa + aa then
                    --g_render:circle_3d(obj_min.position, Square_color, 15, 0, 90, 2)
                    g_render:circle(obj_min.position:to_screen(), Square_color, 15, 90)
                    
                end
                --Prints("drawn")
            end
        else Prints("min was nil") end
    end
end

function DrawLethal()
    local Square_color = color:new( 0,255,255)
    -- NennyUlt
    if #NmeInRange > 0 then
        --Prints("draw -> loop")
        for i, tbl in pairs(NmeInRange) do
            enemy = features.entity_list:get_by_index(tbl.champ) 
            if enemy:is_alive() then 
                local dmg = tbl.damage
                local Killable = false
                local hp = enemy.health+5
                -- print("hp: " .. hp)
                -- print("dmg: " .. dmg)
                local perc =  (dmg/hp)*100
                -- print("perc " .. perc)
                local pretty = math.floor(perc+0.5)
                -- print("prty " ..pretty)
                perc = pretty
                -- print(perc)
                -- print("max_hp: "..enemy.max_health)
                -- print("hp: "..enemy.health)

                if dmg >= (enemy.health + 5) then
                    Killable = true
                    Square_color = color:new(255,0,200)
                    Prints("draw circ")
                    if enemy.position:to_screen() ~= nil then
                        g_render:circle_3d(enemy.position, Square_color, 65, 1, 90, 2)
                        --g_render:circle(enemy.position:to_screen(), Square_color, 65, 90)
                    end
                    Prints("drew circ")
                end
                Prints("draw text")
                if enemy.position:to_screen() ~= nil then
                    Font = 'roboto-regular'
                    g_render:text(enemy.position:to_screen(), color:new(255,255,255),string, Font, 30) --Hold SHIFT to "..mode_text.." ultimate!
                    Prints("drew text")
                end
            end
        end 
    end
end


function draw()
    if checkboxJinx:get_value() then
        g_render:circle_3d(g_local.position, color:new( 0,255,0), g_local.attack_range+235, 2, 90, 2)
    end
    if checkboxLane:get_value() then
        local pos = vec2:new((Res.x/2) - 100, Res.y - 260 )
        g_render:text(pos, Color, Pressure, Font , 60)
    end
    if checkboxLethal:get_value() then 
        DrawLethal()
    end
    if checkboxNME:get_value() then 
      DrawLinesToEnemies()
    end
    if checkboxMinion:get_value() then 
        DrawMins()
    end
end

function Init()
    Recalling = {}
    NmeInRange = {}
    MinionInRange = {}
    MinionToHarass = {}
    Spell_Limiter = 1
    Pressure = ""
    Casted = false
    Res = g_render:get_screensize()
    Font = 'roboto-regular'
    White = color:new(255,255,255)
    Red = color:new(255,0,0)
    Green = color:new(0,255,0)
    Blue = color:new(0,0,200)
    COLOR = White
    Hero = g_local
    Hero_Champ = Hero.champion_name.text
    Spell_R_Level = g_local:get_spell_book():get_spell_slot(e_spell_slot.r).level
    
    SpellData = {
        ["Kalista"] = {
            Delay = 0.25,
            Width = 1100,
            MissileSpeed = 0,
            Collision = false,
            Cost = 30,
            DMG = function(index) return CalcDamage(index ,get_rend_damage(index)) end
        },
        ["Ezreal"] = {
            Width = 999999,
            DMG = function(index) return CalcDamageAP (index , 200 +  (150*getRLevel()) + BonusAD() +(0.9*getAP())  ) end
        },
        ["Senna"] = {
            Width = 999999,
            DMG = function(index) return CalcDamage(index , (125 + (125*getRLevel())) +  BonusAD() + (0.7*getAP())) end
        },
        ["Jinx"] = {
            Width = 999999,
            DMG = function(index) return CalcDamage(index ,((100 + (150*getRLevel() + (BonusAD() *1.5)))*get_jinx_multiplier(index)) + (0.2 + (0.05*getRLevel()))*(features.entity_list:get_by_index(index).max_health - features.entity_list:get_by_index(index).health)) end,
            R_range = 9000,
            R_speed = 2200,
            R_width = 280/2, --slot pred uses width/2
            R_windup = .6 
        },
        ["Caitlyn"] = {
            Width = 999999,
            DMG = function(index) return CalcDamage(index ,(300 + (225*getRLevel())) +  BonusAD()) end
            
        },
        ["KogMaw"] = {
            Width = 999999,
            DMG = function(index) return CalcDamage(index ,(300 + (225*getRLevel())) +  BonusAD()) end
            
        }
    }
    
    --print("j init")
    print(Hero_Champ)

    Spell_Width = SpellData[Hero_Champ].Width
    Spell_Delay = SpellData[Hero_Champ].Delay
    Spell_MissileSpeed = SpellData[Hero_Champ].MissileSpeed
    Spell_Collision = SpellData[Hero_Champ].Collision
    Spell_Cost = SpellData[Hero_Champ].Cost
end

print("---INIT--")
Init()
print("Killsight: ".. Hero_Champ)

cheat.register_callback("feature", ks)
cheat.register_callback("feature", minions)
cheat.register_callback("feature", lanes)
cheat.register_callback("feature", mega)
cheat.register_callback("feature", semiAutoR)
cheat.register_callback("render", draw)

