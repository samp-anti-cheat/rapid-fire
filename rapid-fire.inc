// built-in include guard removal
// just in case the user has a local dependency with the same file name
#if defined _inc_rapid_fire
	#undef _inc_rapid_fire
#endif
// custom include-guard to ensure we don't duplicate
#if defined _rapid_fire_included
	#endinput
#endif
#define _rapid_fire_included

#include <a_samp>
#include <tick-difference>


#define MAX_RAPIDFIRE_INFRACTIONS (3)

static WeaponShotIntervals[17] = {
	// Pistols
	300, // 22 M9 WHEN DUAL: 185
	400, // 23 M9 SD
	800, // 24 Desert Eagle WHEN C-BUGGING: 100

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
};

static
	infractions[MAX_PLAYERS],
	skillLevel[MAX_PLAYERS] = {999, ...},
	lastShotTick[MAX_PLAYERS],
	lastCrouchTick[MAX_PLAYERS];

forward OnAntiCheatFireRate(playerid, weaponid, interval);

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	// Store the time when the player hits crouch
	if(newkeys & KEY_CROUCH) {
		lastCrouchTick[playerid] = GetTickCount();
	}

	#if defined AC_RF_OnPlayerKeyStateChange
		return AC_RF_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif
 
#define OnPlayerKeyStateChange AC_RF_OnPlayerKeyStateChange
#if defined AC_RF_OnPlayerKeyStateChange
	forward AC_RF_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {
	new
		interval = GetTickCountDifference(lastShotTick[playerid], GetTickCount()),
		weaponshotinterval = WeaponShotIntervals[weaponid - 22] - 20;

	if(skillLevel[playerid] == 999) {
		switch(weaponid) {
			case 22: weaponshotinterval = 185;
			case 26: weaponshotinterval = 140;
			case 28: weaponshotinterval = 35;
			case 32: weaponshotinterval = 35;
		}
	}

	// c-bug needs taking into account
	if(weaponid == 24) {
		if(GetTickCountDifference(lastCrouchTick[playerid], GetTickCount()) < 600) {
			weaponshotinterval = 100;
		}
	}

	if(interval < weaponshotinterval) {
		infractions[playerid]++;

		if(infractions[playerid] == MAX_RAPIDFIRE_INFRACTIONS) {
			infractions[playerid] = 0;
			CallLocalFunction("OnAntiCheatFireRate", "ddd", playerid, weaponid, interval);
		}

		return 0;
	}

	lastShotTick[playerid] = GetTickCount();

	#if defined AC_RF_OnPlayerWeaponShot
		return AC_RF_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
 
#define OnPlayerWeaponShot AC_RF_OnPlayerWeaponShot
#if defined AC_RF_OnPlayerWeaponShot
	forward AC_RF_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif

stock AC_RF_SetPlayerSkillLevel(playerid, skill, level) {
	skillLevel[playerid] = level;

	return SetPlayerSkillLevel(playerid, skill, level);
}
#if defined _ALS_SetPlayerSkillLevel
	#undef SetPlayerSkillLevel
#else
	#define _ALS_SetPlayerSkillLevel
#endif
#define SetPlayerSkillLevel AC_RF_SetPlayerSkillLevel
