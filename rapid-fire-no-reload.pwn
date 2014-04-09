#include <a_samp>


static
	WeaponMagSizes[17] =
	{
		// Pistols
		017, // 22 M9 x2 WHEN DUAL
		017, // 23 M9 SD
		007, // 24 Desert Eagle

		// Shotgun
		001, // 25 Shotgun
		002, // 26 Sawnoff x2 WHEN DUAL
		007, // 27 Spas 12

		// Automatic
		050, // 28 Mac 10 x2 WHEN DUAL
		030, // 29 MP5
		030, // 30 AK-47
		050, // 31 M16
		050, // 32 Tec 9 x2 WHEN DUAL

		// Rifle
		001, // 33 Rifle
		001, // 34 Sniper

		// Heavy
		001, // 35 RPG
		001, // 36 Heatseeker
		500, // 37 Flamer
		500 // 38 Minigun
	},
	WeaponShotIntervals[17] =
	{
		// Pistols
		300, // 22 M9 WHEN DUAL: 185
		400, // 23 M9 SD
		800, // 24 Desert Eagle

		// Shotgun
		1060, // 25 Shotgun
		300, // 26 Sawnoff WHEN DUAL: 140
		320, // 27 Spas 12

		// Automatic
		120, // 28 Mac 10 WHEN DUAL: 35
		100, // 29 MP5
		120, // 30 AK-47
		120, // 31 M16
		120, // 32 Tec 9 WHEN DUAL: 35

		// Rifle
		1060, // 33 Rifle
		1060, // 34 Sniper

		// Heavy
		0, // 35 RPG
		0, // 36 Heatseeker
		0, // 37 Flamer
		20 // 38 Minigun
	},
	PlayerSkillLevel[MAX_PLAYERS] = {999, ...},
	PlayerShotCounter[MAX_PLAYERS],
	PlayerLastShotTick[MAX_PLAYERS];


forward OnAntiCheatNoReload(playerid, roundsfired);
forward OnAntiCheatFireRate(playerid, weaponid, interval);


public OnPlayerUpdate(playerid)
{
	static lastweapon;
	new currentweapon = GetPlayerWeapon(playerid);

	if(lastweapon != currentweapon)
	{
		// Player reloaded by quick-switching
		PlayerShotCounter[playerid] = 0;
		lastweapon = currentweapon;
	}

	#if defined ACRoF_OnPlayerUpdate
		return ACRoF_OnPlayerUpdate(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
 
#define OnPlayerUpdate ACRoF_OnPlayerUpdate
#if defined ACRoF_OnPlayerUpdate
	forward ACRoF_OnPlayerUpdate(playerid);
#endif


public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(weaponid == 33 || weaponid == 34)
		return 1;

	new
		magsize = WeaponMagSizes[weaponid - 22],
		weaponstate = GetPlayerWeaponState(playerid);

	PlayerShotCounter[playerid]++;

	// Check if the player is using dual weapons
	if(PlayerSkillLevel[playerid] == 999)
	{
		if(weaponid == 22 || weaponid == 26 || weaponid == 28 || weaponid == 32)
			magsize *= 2;
	}

	// If the amount of fired shots exceeds the magazine size for the weapon
	// the player is probably using an infinite ammo mod.
	if(PlayerShotCounter[playerid] == magsize)
	{
		if(weaponstate != 1)
			CallLocalFunction("OnAntiCheatNoReload", "ii", playerid, PlayerShotCounter[playerid]);

		else
			PlayerShotCounter[playerid] = 0;

		return 0;
	}

	new
		interval = GetTickCountDifference(PlayerLastShotTick[playerid], GetTickCount()),
		weaponshotinterval = WeaponShotIntervals[weaponid - 22] - 20;

	if(PlayerSkillLevel[playerid] == 999)
	{
		switch(weaponid)
		{
			case 22: weaponshotinterval = 185;
			case 26: weaponshotinterval = 140;
			case 28: weaponshotinterval = 35;
			case 32: weaponshotinterval = 35;
		}
	}

	// c-bug needs taking into account
	if(weaponid == 24)
	{
		//
	}

	if(interval < weaponshotinterval)
	{
		CallLocalFunction("OnAntiCheatFireRate", "ddd", playerid, weaponid, interval);

		return 0;
	}

	PlayerLastShotTick[playerid] = GetTickCount();

	#if defined ACRoF_OnPlayerWeaponShot
		return ACRoF_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
 
#define OnPlayerWeaponShot ACRoF_OnPlayerWeaponShot
#if defined ACRoF_OnPlayerWeaponShot
	forward ACRoF_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif

stock ACRoF_SetPlayerSkillLevel(playerid, skill, level)
{
	PlayerSkillLevel[playerid] = level;

	return SetPlayerSkillLevel(playerid, skill, level);
}
#if defined _ALS_SetPlayerSkillLevel
    #undef SetPlayerSkillLevel
#else
    #define _ALS_SetPlayerSkillLevel
#endif
 
#define SetPlayerSkillLevel ACRoF_SetPlayerSkillLevel


/*
	I forgot the original creator for this code but it's very useful.
	Effectively abstracts the basic checking for tick count intervals with some
	extra code that compensates for integer overflowing from GetTickCount if the
	server machine has been on for over 2,147,483,647 milliseconds.

	Permalink : https://github.com/Southclaw/ScavengeSurvive/blob/master/gamemodes/SS/utils/tickcountfix.pwn
	Code also below for completion:
*/

stock intdiffabs(tick1, tick2)
{
	if(tick1 > tick2)
	{
		new value = (tick1 - tick2);

		return value < 0 ? -value : value;
	}

	else
	{
		new value = (tick1 - tick2);

		return value < 0 ? -value : value;
	}
}

stock GetTickCountDifference(a, b)
{
	if ((a < 0) && (b > 0))
	{

		new dist;

		dist = intdiffabs(a, b);

		if(dist > 2147483647)
			return intdiffabs(a - 2147483647, b - 2147483647);

		else
			return dist;
	}

	return intdiffabs(a, b);
}
