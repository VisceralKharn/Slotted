float barrel_lasthit_time{ 4.f };

for ( auto enemy : g_entity_list->get_enemies( ) ) {
if ( !enemy || rt_hash( enemy->champion_name.text ) != ct_hash( "Gangplank" ) ) continue;

is_gangplank = true;

if ( enemy->level >= 13 ) barrel_lasthit_time = 1.f;
else if ( enemy->level >= 7 ) barrel_lasthit_time = 2.f;

break;
}

    if ( !is_gangplank ) return { };

for ( auto obj : g_entity_list->get_enemy_minions( ) ) {
if ( !obj || obj->is_dead( ) || obj->is_invisible( ) || !is_attackable( obj->index ) || is_ignored( obj->index ) || !obj->is_barrel( ) || obj->health > 2 ) continue;

float attack_time = m_attack_cast_delay + get_ping( ) / 2.f;
if ( m_autoattack_missile_speed > 0 ) attack_time += g_local->position.dist_to( obj->position ) / m_autoattack_missile_speed;

if ( obj->health == 2.f ) {
auto buffs = obj->buff_manager.get_all( );

for ( auto buff : buffs ) {
if ( !buff ) continue;

auto data = buff->get_buff_data( );
if ( !data ) continue;

auto info = data->get_buff_info( );
if ( !info || rt_hash( info->name ) != ct_hash( "gangplankebarrelactive" ) && rt_hash( info->name ) != ct_hash( "gangplankebarrellife" ) ) continue;


float time_alive = *g_time - data->start_time;

//std::cout << "buff: " << info->name << "   alive time: " << time_alive << std::endl;

if ( time_alive + attack_time >= barrel_lasthit_time ) {
target = obj;
target_found = true;
}

break;
}

if ( target_found ) break;

continue;
}

target = obj;
break;
}