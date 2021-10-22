/*
 _                                                                             _
|_|___________________________________________________________________________|_|
|_|                                                                           |_|
|_|--------------------...::Los Santos Gang Wars::...-------------------------|_|
|_|___________________________________________________________________________|_|

*/

/*Credits:
  AndreT for Dini
 
  EpisoDes: Fixed Some Bugs
  
  PS: Sorry If I forgot someone*/

#include <a_samp>
#include <Dini>
static gTeam[MAX_PLAYERS];
//=========================[Colors]=============================================
#define TEAM_AZTECAS_COLOR    0x01FCFFC8
#define COLOR_LIGHTGREEN      0x9ACD32AA
#define TEAM_GREEN_COLOR      0xFFFFFFAA
#define COLOR_LIGHTBLUE       0x33CCFFAA
#define TEAM_CYAN_COLOR       0xFF8282AA
#define TEAM_BLUE_COLOR       0x8D8DFF00
#define COLOR_LIGHTRED        0xFF6347AA
#define TEAM_HIT_COLOR        0xFFFFFF00
#define COLOR_ADMINCMD        0xa9c4e4ff
#define COLOR_YELLOW2         0xF5DEB3AA
#define COLOR_FLASH2          0xFFFFFF80
#define COLOR_YELLOW          0xFFFF00AA
#define COLOR_PURPLE          0xC2A2DAAA
#define COLOR_ORANGE          0xF97804FF
#define AZTECA_COLOR          0x33FFFF80
#define YAKUZA_COLOR          0x6D000080
#define CRIPZ_COLOR           0x2641FE80
#define COLOR_FLASH           0xFF000080
#define VAGOS_COLOR           0xF5BE1880
#define BALLA_COLOR           0x9245AB80
#define GROVE_COLOR           0x007D0080
#define TRIAD_COLOR           0x00000090
#define COLOR_GRAD1           0xB4B5B7FF
#define COLOR_GRAD2           0xBFC0C2FF
#define COLOR_WHITE           0xFFFFFFAA
#define COLOR_DBLUE           0x2641FEAA
#define COLOR_GREEN           0x33AA33AA
#define COLOR_GREY            0xAFAFAFAA
#define COLOR_RED             0xFF4646FF
//==========================[Anti-Money Hack]===================================
#define UpdateMoneyBar   GivePlayerMoney
#define ResetMoneyBar    ResetPlayerMoney
//===========================[Turf System]======================================
#define STANDINTURF_TIME 20000
#define MEMBERS_NEEDED   1
#define ATTACK_KILLS     5
#define ATTACK_TIME      180000
#define MAX_TEAMS        7
#define MAX_TURFS        52
#define TEAMSCORE        1000
//===========================[Forwards]=========================================
forward split(const strsrc[], strdest[][], delimiter);
forward OnPlayerRegister(playerid, password[]);
forward OnPlayerLogin(playerid,password[]);
forward OnPlayerDataSave(playerid);
forward ABroadCast(color,const string[],level);
forward SendAdminMessage(color, string[]);
forward ResetPlayerWeaponsEx(playerid);
forward RestoreWeapons(playerid);
forward HaveWeapon(playerid, weaponid);
forward RemovePlayerWeapon(playerid, weaponid);
forward GivePlayerGun(playerid, weaponid);
forward AntiHackCheat();
forward FixHour(hour);
forward ShowStats(playerid, targetid);
forward IsPlayerInInvalidNosVehicle(playerid);
forward SaveAccounts();
forward GeneralTimer();
forward SetPlayerToTeamColor(playerid);
forward ResetStats(playerid);
forward SendTeamMessage(team, color, string[]);
forward SetPlayerSpawn(playerid);
forward TimeTextForPlayer(playerid, Text:text, time);
forward DestroyTextTimer(Text:text);
forward PickupDestroy(playerid);
forward TipBot();
forward CalcBot();
forward GameBot();
forward FastestReaction(playerid);
forward StartLotto();
forward AnnounceEvent();
forward EventStarted();
//===========================[Zones Forwards]===================================
forward CheckPlayers();
forward StartWar(turf, attacker);
forward EndWar(turf, attacker, defender);
forward IsPlayerInTurf(playerid, Float:min_x, Float:min_y, Float:max_x, Float:max_y);
//==============================================================================
new TimerStarted[MAX_TURFS];
new gPlayerAccount[MAX_PLAYERS];
new gPlayerLogged[MAX_PLAYERS];
new gPlayerSpawned[MAX_PLAYERS];
new gPlayerLogTries[MAX_PLAYERS];
new BladeKill[MAX_PLAYERS];
new PlayerSpectating[MAX_PLAYERS];
new Float:TeleportDest[MAX_PLAYERS][3];
new Float:TelePos[MAX_PLAYERS][6];
new CreatedCars[100];
new CreatedCar = 0;
new Kills[MAX_PLAYERS];
new PlayerKilled[MAX_PLAYERS];
new HitID[MAX_PLAYERS];
new SpecPlayerReturnPos[MAX_PLAYERS];
new gDropPickup[MAX_PLAYERS];
new gPickupID[MAX_PLAYERS];
new realchat = 1;
new CalculateStarted;
new CalculateEvent;
new reactiontimer[MAX_PLAYERS];
new PlayerInEvent[MAX_PLAYERS];
new ParkourPoint[MAX_PLAYERS];
new Bounty[MAX_PLAYERS];
new Jackpot;
new Event;
new EventPlayers;
new aeventtimer;
new ParkourEventFinished;
new IsHitman[MAX_PLAYERS];
new PlayerCar[MAX_PLAYERS];
//==========================[Text Draws]========================================
new Text:txtSpec;
//=========================[World Time]=========================================
new timeshift = -1;
new shifthour;
new ghour = 0;
new gminute = 0;
new gsecond = 0;
new realtime = 1;
new wtime = 15;
//==============================================================================
enum pInfo
{
	pKey[256],
	pIP[21],
	pAdmin,
	pBanned,
	pDonateRank,
	pWarns,
	pJail,
	pJailTime,
	pReg,
	pCash,
	pKills,
	pDeaths,
	pScore,
	pGun0,
	pGun1,
	pGun2,
	pGun3,
	pGun4,
	pGun5,
	pGun6,
	pGun7,
	pGun8,
	pGun9,
	pGun10,
	pGun11,
	pGun12,
	pModel,
	pMuted,
	pSpree,
	Float:pCalcSec,
	pCWons,
	pLotto,
	pHide
};
new PlayerInfo[MAX_PLAYERS][pInfo];
//==============================================================================
new Float:gParkourPoints[25][3] = {
{2156.5188,-1051.5486,63.4219},
{2147.1707,-1038.3499,70.9141},
{2145.0027,-1020.0145,69.0391},
{2128.6655,-1015.6035,66.2290},
{2110.2017,-1010.0898,63.8438},
{2094.0994,-1004.9059,58.5475},
{2072.0046,-1000.5798,58.9766},
{2053.3127,-996.9725,51.3359},
{2038.1903,-999.1078,46.7422},
{2072.7566,-968.0931,48.7810},
{2076.4897,-967.2850,53.6534},
{2086.1211,-962.3100,55.5156},
{2075.5032,-959.2959,58.0156},
{2060.7339,-957.4730,52.8723},
{2042.3412,-957.8463,50.5659},
{2007.1000,-970.5846,42.4609},
{1997.6436,-981.0058,39.4063},
{1965.6726,-1018.7989,34.0045},
{2023.2430,-1022.6445,35.6674},
{2084.8811,-1033.6810,37.4688},
{2103.1643,-1046.9210,33.0313},
{2120.4065,-1069.9662,24.7435},
{2140.7800,-1068.7755,35.0558},
{2174.5598,-1085.8601,35.7188},
{2197.2344,-1091.8704,44.3047}
};
//==============================================================================
new Float:gDerbySpawn[11][4] = {
{-1470.7603,995.5387,1025.7063,270.0},
{-1328.4248,998.6580,1025.3599,90.0},
{-1395.3125,1025.2057,1025.7062,180.0},
{-1402.3094,961.9868,1025.1075,360.0},
{-1431.0920,965.6172,1024.9288,25.0},
{-1448.3115,1023.3336,1026.1880,230.0},
{-1365.6591,1026.0172,1025.8583,200.0},
{-1352.1920,970.2332,1024.7972,50.0},
{-1374.5555,994.1923,1024.0444,95.0},
{-1423.1147,990.2379,1024.0615,265.0},
{-1349.9714,994.6847,1024.0615,50.0}
};
//==============================================================================
enum
{
    TEAM_GROVE,
    TEAM_BALLAS,
    TEAM_VAGOS,
    TEAM_AZTECAS,
    TEAM_TRIADS,
    TEAM_YAKUZA,
    TEAM_CRIPZ
};

enum gInfo
{
    TeamName[64],
	TeamColor,
	TurfWarsWon,
	TurfWarsLost,
	RivalsKilled,
	HomiesDied,
	TeamScore
}

new TeamInfo[MAX_TEAMS][gInfo]= {
{"Grove Street Families", GROVE_COLOR, 0, 0, 0, 0, 0},
{"Rolling Height Ballas", BALLA_COLOR, 0, 0, 0, 0, 0},
{"Los Santos Vagos", VAGOS_COLOR, 0, 0, 0, 0, 0},
{"Varrio Los Aztecas", AZTECA_COLOR, 0, 0, 0, 0, 0},
{"Black Hand Triads", TRIAD_COLOR, 0, 0, 0, 0, 0},
{"Japanese Yakuza", YAKUZA_COLOR, 0, 0, 0, 0, 0},
{"Long Beach Cripz", CRIPZ_COLOR, 0, 0, 0, 0, 0}
};
//==============================================================================
enum tinfo
{
	 turfID,
 	 turfName[ 40 ],
 	 cityName[ 40 ],
	 Float:zMinX,
	 Float:zMinY,
	 Float:zMaxX,
	 Float:zMaxY,
	 TurfColor,
	 TurfOwner,
	 TurfAttacker,
	 TurfKills,
	 TurfAttackKills,
	 TurfWarStarted,
	 MIT
}

new turfs[MAX_TURFS][tinfo] = {
{  0, "Ganton",            "LS", 2222.50, -1852.80, 2632.80, -1722.30, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{  1, "Ganton",            "LS", 2222.50, -1722.30, 2632.80, -1628.50, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{  2, "Idlewood",          "LS", 1812.60, -1852.80, 1971.60, -1742.30, AZTECA_COLOR,  TEAM_AZTECAS,  -1, 0, 0, 0, 0},
{  3, "Idlewood",          "LS", 1951.60, -1742.30, 2124.60, -1602.30, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{  4, "Idlewood",          "LS", 1812.60, -1602.30, 2124.60, -1449.60, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{  5, "Idlewood",          "LS", 2124.60, -1742.30, 2222.50, -1494.00, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{  6, "Idlewood",          "LS", 1971.60, -1852.80, 2222.50, -1742.30, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{  7, "Idlewood",          "LS", 1812.60, -1742.30, 1951.60, -1602.30, AZTECA_COLOR,  TEAM_AZTECAS,  -1, 0, 0, 0, 0},
{  8, "Willow Field",      "LS", 1970.60, -2179.20, 2089.00, -1852.80, AZTECA_COLOR,  TEAM_AZTECAS,  -1, 0, 0, 0, 0},
{  9, "Willow Field",      "LS", 2089.00, -1989.90, 2324.00, -1852.80, AZTECA_COLOR,  TEAM_AZTECAS,  -1, 0, 0, 0, 0},
{ 10, "Willow Field",      "LS", 2089.00, -2235.80, 2201.80, -1989.90, AZTECA_COLOR,  TEAM_AZTECAS,  -1, 0, 0, 0, 0},
{ 11, "Jefferson",         "LS", 2056.80, -1372.00, 2281.40, -1210.70, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 12, "Jefferson",         "LS", 2056.80, -1210.70, 2185.30, -1126.30, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 13, "Jefferson",         "LS", 2056.80, -1449.60, 2266.20, -1372.00, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 14, "East Los Santos",   "LS", 2421.00, -1628.50, 2632.80, -1454.30, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{ 15, "East Los Santos",   "LS", 2222.50, -1628.50, 2421.00, -1494.00, GROVE_COLOR,   TEAM_GROVE,   -1, 0, 0, 0, 0},
{ 16, "East Los Santos",   "LS", 2266.20, -1494.00, 2381.60, -1372.00, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 17, "East Los Santos",   "LS", 2281.60, -1372.00, 2381.60, -1135.00, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 18, "East Los Santos",   "LS", 2381.60, -1454.30, 2462.10, -1135.00, VAGOS_COLOR,   TEAM_VAGOS,   -1, 0, 0, 0, 0},
{ 19, "East Los Santos",   "LS", 2462.10, -1454.30, 2581.70, -1135.00, VAGOS_COLOR,   TEAM_VAGOS,   -1, 0, 0, 0, 0},
{ 20, "El Corona",         "LS", 1812.60, -2179.20, 1970.60, -1852.80, AZTECA_COLOR,  TEAM_AZTECAS,  -1, 0, 0, 0, 0},
{ 21, "El Corona",         "LS", 1692.60, -2179.20, 1812.60, -1842.20, AZTECA_COLOR,  TEAM_AZTECAS,  -1, 0, 0, 0, 0},
{ 22, "Glen Park",         "LS", 1812.60, -1350.70, 2056.80, -1100.80, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 23, "Los Flores",        "LS", 2581.70, -1393.40, 2747.70, -1135.00, VAGOS_COLOR,   TEAM_VAGOS,   -1, 0, 0, 0, 0},
{ 24, "Las Colinas",       "LS", 1994.30, -1100.80, 2056.80,  -920.80, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 25, "Las Colinas",       "LS", 2056.80, -1126.30, 2126.80,  -920.80, BALLA_COLOR,   TEAM_BALLAS,   -1, 0, 0, 0, 0},
{ 26, "Las Colinas",       "LS", 2185.30, -1154.50, 2281.40,  -934.40, VAGOS_COLOR,   TEAM_VAGOS,   -1, 0, 0, 0, 0},
{ 27, "Las Colinas",       "LS", 2126.80, -1126.30, 2185.30,  -934.40, VAGOS_COLOR,   TEAM_VAGOS,   -1, 0, 0, 0, 0},
{ 28, "Las Colinas",       "LS", 2632.70, -1135.00, 2747.70,  -945.00, VAGOS_COLOR,   TEAM_VAGOS,   -1, 0, 0, 0, 0},
{ 29, "Las Colinas",       "LS", 2281.40, -1135.00, 2632.70,  -945.00, VAGOS_COLOR,   TEAM_VAGOS,   -1, 0, 0, 0, 0},
{ 30, "Temple",       "LS", 1153.92, -1158.21, 1344.07, -1025.30, TRIAD_COLOR,   TEAM_TRIADS,   -1, 0, 0, 0, 0},
{ 31, "Temple",       "LS", 954.83, -1158.21, 1153.92, -1025.30, TRIAD_COLOR,   TEAM_TRIADS,   -1, 0, 0, 0, 0},
{ 32, "Vinewood",       "LS", 789.10, -1158.21, 954.83, -936.29, TRIAD_COLOR,   TEAM_TRIADS,   -1, 0, 0, 0, 0},
{ 33, "Temple",       "LS", 954.75, -1025.30, 1152.46, -936.29, TRIAD_COLOR,   TEAM_TRIADS,   -1, 0, 0, 0, 0},
{ 34, "Temple",       "LS", 1049.42, -1289.62, 1221.19, -1158.21, TRIAD_COLOR,   TEAM_TRIADS,   -1, 0, 0, 0, 0},
{ 35, "Temple",       "LS", 1221.19, -1289.62, 1341.26, -1158.21, TRIAD_COLOR,   TEAM_TRIADS,   -1, 0, 0, 0, 0},
{ 36, "Vinewood",       "LS", 1153.92, -1025.30, 1341.26, -862.01, TRIAD_COLOR,   TEAM_TRIADS,   -1, 0, 0, 0, 0},
{ 37, "Verona Beach",       "LS", 1145.10, -1718.26, 1292.30, -1565.49, YAKUZA_COLOR,   TEAM_YAKUZA,   -1, 0, 0, 0, 0},
{ 38, "Verona Beach",       "LS", 1041.96, -1718.26, 1145.10, -1565.49, YAKUZA_COLOR,   TEAM_YAKUZA,   -1, 0, 0, 0, 0},
{ 39, "Conference Center",       "LS", 1041.96, -1860.83, 1177.37, -1718.26, YAKUZA_COLOR,   TEAM_YAKUZA,   -1, 0, 0, 0, 0},
{ 40, "Conference Center",       "LS", 1177.37, -1860.83, 1292.30, -1718.26, YAKUZA_COLOR,   TEAM_YAKUZA,   -1, 0, 0, 0, 0},
{ 41, "Verona Beach",       "LS", 910.96, -1860.83, 1041.96, -1718.26, YAKUZA_COLOR,   TEAM_YAKUZA,   -1, 0, 0, 0, 0},
{ 42, "Verona Beach",       "LS", 910.96, -1718.26, 1041.96, -1410.60, YAKUZA_COLOR,   TEAM_YAKUZA,   -1, 0, 0, 0, 0},
{ 43, "Market",       "LS", 1041.96, -1565.49, 1347.25, -1410.60, YAKUZA_COLOR,   TEAM_YAKUZA,   -1, 0, 0, 0, 0},
{ 44, "Santa Maria Beach",       "LS", 349.85, -2088.68, 622.75,-1684.52, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0},
{ 45, "Santa Maria Beach",       "LS", 622.75, -2088.68, 804.95, -1684.52, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0},
{ 46, "Verona Beach",       "LS", 804.95, -2088.68, 912.48, -1684.52, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0},
{ 46, "Rodeo",       "LS", 359.47, -1684.52, 522.61, -1410.60, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0},
{ 47, "Rodeo",       "LS", 522.61, -1684.52, 629.04, -1410.60, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0},
{ 48, "Marina",       "LS", 629.04, -1684.52, 792.07, -1410.60, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0},
{ 49, "Verona Beach",       "LS", 792.07, -1684.52, 910.96, -1410.60, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0},
{ 50, "Verona Beach",       "LS", 912.48, -2088.68, 1057.43, -1860.83, CRIPZ_COLOR,   TEAM_CRIPZ,   -1, 0, 0, 0, 0}
};
new TurfInfo[MAX_TURFS][MAX_TEAMS][tinfo];
//===========================[Spawn Places]=====================================
new Float:gGroveSP[5][4] = {
{2486.3970, -1645.1057, 14.0772, 179.9111},
{2522.4792, -1678.8976, 15.4970,  84.5245},
{2459.4883, -1690.7766, 13.5447,   4.4374},
{2512.8555, -1650.1726, 14.3557, 144.0457},
{2452.1179, -1642.6036, 13.7357, 185.5197}
};

new Float:gBallaSP[5][4] = {
{1999.8577, -1114.6553, 27.1250, 182.0473},
{2022.9449, -1120.9398, 26.4210, 176.7813},
{2045.8439, -1115.7263, 26.3617, 273.3338},
{2093.7844, -1123.7844, 27.6899,  85.9610},
{2094.6392, -1145.1943, 26.5929,  90.0567}
};

new Float:gVagosSP[6][4] = {
{2626.2966, -1112.7968, 67.8459, 268.0490},
{2628.5859, -1068.0347, 69.6129, 270.7647},
{2576.2104, -1070.5781, 69.8322,  90.3136},
{2526.9141, -1061.0150, 69.5673, 276.0494},
{2579.2810, -1033.8696, 69.5804, 182.8840},
{2352.1838, -1166.6421, 27.4715, 359.5431}
};

new Float:gAztecaSP[5][4] = {
{1782.4652, -2125.8149, 14.0679,   2.1458},
{1802.0015, -2099.5906, 14.0210, 178.8617},
{1733.7253, -2098.3542, 14.0366, 179.5071},
{1674.3099, -2122.3008, 14.1460, 309.0879},
{1734.5999, -2129.7507, 14.0210, 359.1053}
};

new Float:gTriadsSP[5][4] = {
{1022.6276, -1122.8153, 23.8710, 184.3190},
{1009.3043, -1122.4684, 23.8996, 215.4357},
{1040.0020, -1120.8602, 23.8984, 132.0882},
{1020.9998, -1155.8867, 23.8315, 358.9174},
{1022.6276, -1122.8153, 23.8710, 184.3190}
};

new Float:gYakuzSP[5][4] = {
{1191.2260,-1653.1935,13.9201,179.4025},
{1009.3043, -1122.4684, 23.8996, 215.4357},
{1182.2813,-1656.2859,13.9332,234.5496},
{1206.6820,-1659.2520,13.5469,122.7119},
{1191.2260,-1653.1935,13.9201,179.4025}
};

new Float:gCripzSP[5][4] = {
{425.3501,-1757.3633,8.2564,182.2588},
{472.9323,-1772.0448,14.1202,318.4152},
{475.5638,-1746.6948,9.3761,95.6565},
{482.3629,-1764.7040,5.5398,176.5207},
{438.1846,-1749.9984,8.9666,219.4711}
};
//==============================================================================
enum pSpec
{
	Float:Coords[3],
	Float:sPx,
	Float:sPy,
	Float:sPz,
	sPint,
	sLocal,
	Float:sAngle,
	sVw,
	sCam,
};
new Unspec[MAX_PLAYERS][pSpec];
//==============================================================================
main()
{
     print("Bug Fixer: EpisoDes");
    print("      ...::Los Santos Gang Wars::...");
}
//==============================================================================
stock strvalEx( const string[] )
{
	if( strlen( string ) >= 50 ) return 0;
	return strval(string);
}
//==============================================================================
strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}
//==============================================================================
public OnGameModeInit()
{
    AntiDeAMX();
    new string[256];
    SetGameModeText("Turf Wars");
    format(string, sizeof(string), "Welcome to Abels gang war  server");
	gettime(ghour, gminute, gsecond);
	FixHour(ghour);
	ghour = shifthour;
	if(!realtime)
	{
		SetWorldTime(wtime);
	}
	AllowInteriorWeapons(1);
	EnableStuntBonusForAll(0);
	SetNameTagDrawDistance(60.0);
	AllowAdminTeleport(1);
	UsePlayerPedAnims();
	CalculateStarted = 0;
    CalculateEvent = 0;
    Jackpot = 20000;
    Event = 0;
    EventPlayers = 0;
    ParkourEventFinished = 0;
	if (realtime)
	{
		new tmphour;
		new tmpminute;
		new tmpsecond;
		gettime(tmphour, tmpminute, tmpsecond);
		FixHour(tmphour);
		tmphour = shifthour;
		SetWorldTime(tmphour);
	}
//===============================[Player Class]=================================
    AddPlayerClass(105, 2522.4792, -1678.8976, 15.4970,  84.5245, -1, -1, -1, -1, -1, -1); //Grove 1
    AddPlayerClass(106, 2486.3970, -1645.1057, 14.0772, 179.9111, -1, -1, -1, -1, -1, -1); //Grove 2
    AddPlayerClass(107, 2522.4792, -1678.8976, 15.4970,  84.5245, -1, -1, -1, -1, -1, -1); //Grove 3
    AddPlayerClass(102, 1999.8577, -1114.6553, 27.1250, 182.0473, -1, -1, -1, -1, -1, -1); //Ballas 1
    AddPlayerClass(103, 1999.8577, -1114.6553, 27.1250, 182.0473, -1, -1, -1, -1, -1, -1); //Ballas 2
    AddPlayerClass(104, 2022.9449, -1120.9398, 26.4210, 176.7813, -1, -1, -1, -1, -1, -1); //Ballas 3
    AddPlayerClass(108, 2626.2966, -1112.7968, 67.8459, 268.0490, -1, -1, -1, -1, -1, -1); //Vagos 1
    AddPlayerClass(109, 2626.2966, -1112.7968, 67.8459, 268.0490, -1, -1, -1, -1, -1, -1); //Vagos 1
    AddPlayerClass(110, 2628.5859, -1068.0347, 69.6129, 270.7647, -1, -1, -1, -1, -1, -1); //Vagos 2
    AddPlayerClass(114, 1782.4652, -2125.8149, 14.0679,   2.1458, -1, -1, -1, -1, -1, -1); //Aztecas 1
    AddPlayerClass(115, 1782.4652, -2125.8149, 14.0679,   2.1458, -1, -1, -1, -1, -1, -1); //Aztecas 2
    AddPlayerClass(116, 1802.0015, -2099.5906, 14.0210, 178.8617, -1, -1, -1, -1, -1, -1); //Aztecas 3
    AddPlayerClass(294, 1022.6276, -1122.8153, 23.8710, 184.3190, -1, -1, -1, -1, -1, -1); //Triads 1
    AddPlayerClass(117, 1022.6276, -1122.8153, 23.8710, 184.3190, -1, -1, -1, -1, -1, -1); //Triads 2
    AddPlayerClass(118, 1022.6276, -1122.8153, 23.8710, 184.3190, -1, -1, -1, -1, -1, -1); //Triads 3
    AddPlayerClass(120, 1022.6276, -1122.8153, 23.8710, 184.3190, -1, -1, -1, -1, -1, -1); //Triads 4
    AddPlayerClass(123, 1191.2260, -1653.1935, 13.9201, 179.4025, -1, -1, -1, -1, -1, -1); //Yakuza 1
    AddPlayerClass(23, 1191.2260, -1653.1935, 13.9201, 179.4025, -1, -1, -1, -1, -1, -1); //Yakuza 2
    AddPlayerClass(193, 1191.2260, -1653.1935, 13.9201, 179.4025, -1, -1, -1, -1, -1, -1); //Yakuza 3
    AddPlayerClass(49, 1191.2260, -1653.1935, 13.9201, 179.4025, -1, -1, -1, -1, -1, -1); //Yakuza 4
    AddPlayerClass(186, 1191.2260, -1653.1935, 13.9201, 179.4025, -1, -1, -1, -1, -1, -1); //Yakuza 5
    AddPlayerClass(21, 425.3501, -1757.3633, 8.2564, 182.2588, -1, -1, -1, -1, -1, -1); //Cripz 1
    AddPlayerClass(143, 425.3501, -1757.3633, 8.2564, 182.2588, -1, -1, -1, -1, -1, -1); //Cripz 2
    AddPlayerClass(156, 425.3501, -1757.3633, 8.2564, 182.2588, -1, -1, -1, -1, -1, -1); //Cripz 3
    AddPlayerClass(176, 425.3501, -1757.3633, 8.2564, 182.2588, -1, -1, -1, -1, -1, -1); //Cripz 4
    AddPlayerClass(177, 425.3501, -1757.3633, 8.2564, 182.2588, -1, -1, -1, -1, -1, -1); //Cripz 5
//================================[Vehicles]====================================
    AddStaticVehicleEx(492, 2487.6111, -1655.1952, 13.2177, 93.5354, 86, 0, 600); //1 Grove Street Car 1
    AddStaticVehicleEx(492, 2508.3157, -1666.6753, 13.0653, 13.1970, 86, 0, 600); //2 Grove Street Car 2
    AddStaticVehicleEx(518, 2506.0281, -1676.8573, 13.0455, 325.6399, 86, 86, 600); //3 Grove Street Car 3
    AddStaticVehicleEx(518, 2489.4839, -1682.6345, 13.2316, 270.1918, 86, 86, 600); //4 Grove Street Car 4
    AddStaticVehicleEx(549, 1673.5490, -2111.2495, 13.2442, 269.6485, 93, 0, 600); //5 Aztecas Car 1
    AddStaticVehicleEx(534, 1697.9955, -2099.3491, 13.2718, 178.6478, 93, 0, 600); //6 Aztecas Car 2
    AddStaticVehicleEx(567, 1698.657104, -2118.233154, 13.202400, 269.435791, 93, 0, 600); //7 Aztecas Car 3
    AddStaticVehicleEx(567, 1687.009155, -2118.233154, 13.256900, 269.970093, 93, 0, 600); //8 Aztecas Car 4
    AddStaticVehicleEx(566, 2015.377075, -1130.955200, 24.759199, 89.498100, 85, 0, 600); //9 Ballas Car 1
    AddStaticVehicleEx(566, 1993.344360, -1130.955200, 25.372999, 89.498100, 85, 0, 600); //10 Ballas Car 2
    AddStaticVehicleEx(566, 2013.419434, -1094.520996, 24.461599, 339.125214, 85, 0, 600); //11 Ballas Car 3
    AddStaticVehicleEx(566, 2008.581299, -1092.794922, 24.459299, 339.398987, 85, 0, 600); //12 Ballas Car 4
    AddStaticVehicleEx(579, 1006.8212, -1119.8981, 23.8283, 178.4172, 0, 0, 600); //13 Triads Car 1
    AddStaticVehicleEx(468, 1042.1277, -1119.4452, 23.5673, 92.5102, 0, 0, 600); //14 Triads Car 2
    AddStaticVehicleEx(461, 1042.3768, -1121.9794, 23.4834, 108.3609, 0, 0, 600); //15 Triads Car 3
    AddStaticVehicleEx(426, 1012.1818, -1119.7013, 23.6422, 181.7575, 0, 0, 600); //16 Triads Car 4
    AddStaticVehicleEx(567, 2335.1060, -1160.2599, 26.8024, 271.7384, 6, 6, 600); //17 Vaggos Car 1
    AddStaticVehicleEx(567, 2357.5723, -1159.0752, 27.3207, 272.2186, 6, 6, 600); //18 Vaggos Car 2
    AddStaticVehicleEx(534, 2365.6982, -1178.2589, 27.2342, 359.3282, 6, 6, 600); //19 Vaggos Car 3
    AddStaticVehicleEx(534, 2308.8508, -1170.3359, 26.1187, 358.6740, 6, 6, 600); //20 Vaggos Car 4
    AddStaticVehicleEx(445, 1197.0864, -1698.9131, 13.4219, 269.7160, 1, 1, 600); //21 Yakuza Car 1
    AddStaticVehicleEx(445, 1183.3868, -1685.2173, 13.4803, 178.8575, 1, 1, 600); //22 Yakuza Car 2
    AddStaticVehicleEx(401, 1210.7369, -1688.4989, 13.3264, 178.4651, 1, 1, 600); //23 Yakuza Car 3
    AddStaticVehicleEx(401, 1203.5840, -1646.3687, 13.5233, 179.9778, 1, 1, 600); //24 Yakuza Car 4
    AddStaticVehicleEx(518, 433.7166, -1767.3259, 5.1303, 268.9025, 2, 2, 600); //25 Cripz Car 1
    AddStaticVehicleEx(585, 453.9697, -1733.7606, 9.3741, 3.0728, 2, 2, 600); //26 Cripz Car 2
    AddStaticVehicleEx(567, 477.2629, -1764.9734, 5.4029, 90.9118, 2, 2, 600); //27 Cripz Car 3
    AddStaticVehicleEx(567, 425.9265, -1790.6731, 5.4166, 358.6425, 2, 2, 600); //28 Cripz Car 4
//================================[Objects]=====================================
    CreateObject(3461, 1189.5640, -1651.6622, 14.6831, 0.0, 327.9428, 90.8285); //Fire Stick 1
    CreateObject(3461, 1192.9659, -1651.6823, 14.7121, 0.0, 326.4811, 89.3020); //Fire Stick 2
//============================[Gang Wars System]================================
    for (new t=0; t<MAX_TURFS; t++)
	{
         GangZoneCreate(turfs[t][zMinX], turfs[t][zMinY], turfs[t][zMaxX], turfs[t][zMaxY]);
         for(new teams=0; teams < MAX_TEAMS; teams++) TurfInfo[t][teams][MIT] = 0;
    }
//============================[TextDraws]=======================================
	txtSpec = TextDrawCreate(610.0, 400.0,
	"~b~~k~~PED_SPRINT~ ~w~to respawn");
	TextDrawUseBox(txtSpec, 0);
	TextDrawFont(txtSpec, 2);
	TextDrawSetShadow(txtSpec,0);
    TextDrawSetOutline(txtSpec,1);
    TextDrawBackgroundColor(txtSpec,0x000000FF);
    TextDrawColor(txtSpec,0xFFFFFFFF);
    TextDrawAlignment(txtSpec,3);
//=============================[Timers]=========================================
	SetTimer("UpdateMoney", 1000, 1);
	SetTimer("AntiHackCheat", 100, 1);
    SetTimer("GeneralTimer", 1000, 1);
    SetTimer("CheckPlayers", 10000, 1);
    SetTimer("TipBot", 720000, 1);
    SetTimer("CalcBot", 660000, 1);
    SetTimer("GameBot", 500000, 1);
	return 1;
}
//===========================[Turf Wars Fucntions]==============================
public IsPlayerInTurf(playerid,Float:min_x,Float:min_y,Float:max_x,Float:max_y)
{
    new Float:X,Float:Y,Float:Z;
    GetPlayerPos(playerid, X, Y, Z);
    if((X <= max_x && X >= min_x) && (Y <= max_y && Y >= min_y)) return 1;
    return 0;
}
//==============================================================================
FlashZoneForPlayer( playerid )
{
    for (new i = 0; i < MAX_TURFS; i++)
	{
         if (turfs[i][TurfWarStarted] == 1)
         {
			 if (gTeam[playerid] == turfs[ i ][ TurfAttacker ])   GangZoneFlashForPlayer( playerid, i, COLOR_FLASH );
			 else if (gTeam[playerid] == turfs[ i ][ TurfOwner ]) GangZoneFlashForPlayer( playerid, i, COLOR_FLASH );
			 else GangZoneFlashForPlayer( playerid, i, COLOR_FLASH2 );
		 }
	}
}
//==============================================================================
public CheckPlayers( )
{
    new Float:x, Float:y, Float:z;
    for (new i = 0; i < MAX_TURFS; i++)
	{
         for (new c = 0; c < MAX_TEAMS; c++) TurfInfo[i][c][MIT] = 0;
         for (new b = 0; b < 500; b++)
		 {
              if (gPlayerSpawned[b] == 1 && !GetPlayerInterior(b) && PlayerInEvent[b] == 0)
			  {
                  GetPlayerPos(b, x, y, z);
			      if (IsPlayerInTurf(b, turfs[i][zMinX], turfs[i][zMinY], turfs[i][zMaxX], turfs[i][zMaxY]))
			      {
			          if (turfs[i][TurfWarStarted] != 1 && gTeam[b] != turfs[i][TurfOwner])
                      {
                           TurfInfo[i][gTeam[b]][MIT]++;
                           if (TurfInfo[i][gTeam[b]][MIT] >= MEMBERS_NEEDED)
                           {
                               if (TimerStarted[i] != 1)
							   {
                                   TimerStarted[i] = 1;
                                   SetTimerEx("StartWar", STANDINTURF_TIME, 0, "ii", i, gTeam[b]);
                               }
                           }
                      }
			      }
			  }
	     }
	}
}
//==============================================================================
public StartWar( turf, attacker )
{
    new Float:x, Float:y, Float:z;
    TimerStarted[turf] = 0;
    for (new c = 0; c < MAX_TEAMS; c++)
	{
	     TurfInfo[turf][c][TurfKills] =0;
	     TurfInfo[turf][c][TurfAttackKills] =0;
	     TurfInfo[turf][c][MIT]=0;
	}
    for (new id = 0; id < 500; id++)
	{
         if (gPlayerSpawned[id] == 1 && !GetPlayerInterior(id))
         {
             GetPlayerPos(id, x, y, z);
             if (IsPlayerInTurf(id, turfs[turf][zMinX], turfs[turf][zMinY], turfs[turf][zMaxX], turfs[turf][zMaxY]))
	         {
                 if (turfs[turf][TurfWarStarted] != 1)
                 {
			         if (gTeam[id] == attacker)
			         {
                         TurfInfo[turf][attacker][MIT]++;
                         if (TurfInfo[turf][attacker][MIT] >= MEMBERS_NEEDED)
                         {
                             turfs[turf][TurfAttacker] = attacker;
                             for (new t = 0; t < 500; t++)
                             {
                                  if (gTeam[t] == turfs[turf][TurfAttacker])
								  {
                                      new msg1[256];
                                      format(msg1,sizeof(msg1), "~w~We have provoked a turf war ~w~in ~y~%s ( %s ) ~w~against the ~r~%s.",
									  turfs[turf][turfName], turfs[turf][cityName], TeamInfo[turfs[turf][TurfOwner]][TeamName]);
                                      new Text:txt1 = TextDrawCreate(139.0, 350.0, msg1);
                                      TextDrawFont(txt1, 1);
                                      TextDrawLetterSize(txt1, 0.29, 1.0);
                                      TextDrawColor(txt1, COLOR_WHITE);
                                      TextDrawSetOutline(txt1, 1);
                                      TextDrawSetShadow(txt1, 0);
                                      TimeTextForPlayer(t, txt1, 6000);
                                      GangZoneFlashForPlayer(t, turfs[turf][turfID], COLOR_FLASH);
                                  }
                                  else if (gTeam[t] == turfs[turf][TurfOwner])
								  {
                                      new msg2[256];
                                      format(msg2,sizeof(msg2), "~r~The ~y~%s ~r~have attacked our turf in ~y~%s ( %s )!",
	                                  TeamInfo[turfs[turf][TurfAttacker]][TeamName], turfs[turf][turfName], turfs[turf][cityName]);
                                      new Text:txt2 = TextDrawCreate(139.0, 364.0, msg2);
                                      TextDrawFont(txt2, 1);
                                      TextDrawLetterSize(txt2, 0.29, 1.0);
                                      TextDrawColor(txt2, COLOR_RED);
                                      TextDrawSetOutline(txt2, 1);
                                      TextDrawSetShadow(txt2, 0);
                                      TimeTextForPlayer(t, txt2, 6000);
                                      GangZoneFlashForPlayer(t, turfs[turf][turfID], COLOR_FLASH);
                                  }
                                  else GangZoneFlashForPlayer(t, turfs[turf][turfID], COLOR_FLASH2);
                             }
                             turfs[turf][TurfWarStarted] =1;
                             SetTimerEx("EndWar", ATTACK_TIME, false ,"iii", turf, turfs[turf][TurfAttacker], turfs[turf][TurfOwner]);
				         }
                     }
                 }
	         }
	     }
	}
}
//==============================================================================
public EndWar(turf, attacker, defender)
{
    new string[256];
    new Float:x, Float:y, Float:z;
	if (turfs[turf][TurfWarStarted] == 1)
	{
        GangZoneStopFlashForAll(turf);
        turfs[turf][TurfWarStarted] =0;
        if (TurfInfo[turf][attacker][TurfAttackKills] > TurfInfo[turf][defender][TurfAttackKills])
        {
            for (new a = 0; a < 500; a++)
	        {
                 if (gTeam[a] == defender)
				 {
                     new msg1[ 256 ];
	                 format(msg1,sizeof(msg1), "~r~The ~y~%s ~r~have taken over our turf in ~y~%s!",
	                 TeamInfo[attacker][TeamName], turfs[turf][turfName]);
                     new Text:txt1 = TextDrawCreate(139.0, 420.0, msg1);
                     TextDrawFont(txt1, 1);
                     TextDrawLetterSize(txt1, 0.29, 1.0);
                     TextDrawSetShadow(txt1, 0);
                     TextDrawSetOutline(txt1, 1);
                     TextDrawColor(txt1, COLOR_RED);
                     TimeTextForPlayer(a, txt1, 6000);
                     format (string, sizeof(string), "Final score from the turf war in %s. %s: %d - %s: %d.",
					 turfs[turf][turfName],
					 TeamInfo[attacker][TeamName], TurfInfo[turf][attacker][TurfAttackKills],
					 TeamInfo[defender][TeamName], TurfInfo[turf][defender][TurfAttackKills]);
	                 SendClientMessage(a, COLOR_YELLOW, string);
	                 TeamInfo[defender][TurfWarsLost] ++;
	                 TeamInfo[defender][TeamScore] --;
		          }
	              else if (gTeam[a] == attacker)
				  {
                     new msg2[256];
                     format(msg2,sizeof(msg2), "~g~We won the turf war against the ~y~%s ~g~in ~y~%s!",
			         TeamInfo[defender][TeamName], turfs[turf][turfName]);
			         new Text:txt2 = TextDrawCreate(139.0, 378.0, msg2);
                     TextDrawFont(txt2, 1);
                     TextDrawLetterSize(txt2, 0.29, 1.0);
                     TextDrawSetShadow(txt2, 0);
                     TextDrawSetOutline(txt2, 1);
                     TextDrawColor(txt2, COLOR_WHITE);
                     TimeTextForPlayer(a, txt2, 6000);
                     format (string, sizeof(string), "Final score from the turf war in %s. %s: %d - %s: %d.",
					 turfs[turf][turfName],
					 TeamInfo[attacker][TeamName], TurfInfo[turf][attacker][TurfAttackKills],
					 TeamInfo[defender][TeamName], TurfInfo[turf][defender][TurfAttackKills]);
	                 SendClientMessage(a, COLOR_YELLOW, string);
	                 TeamInfo[attacker][TurfWarsWon]++;
	                 TeamInfo[attacker][TeamScore]++;
                     SendClientMessage(a, COLOR_LIGHTBLUE, "Well done. You received $2500.");
                     GivePlayerCash(a, 2500);
                     if (TeamInfo[attacker][TeamScore] >= TEAMSCORE)
					 {
                         for (new i = 0; i < MAX_TURFS; i++)
						 {
			   	         	  if (turfs[i][TurfOwner] == defender)
					          {
								  if (turfs[i][TurfWarStarted] != 1)
								  {
                                      turfs[i][TurfOwner] = attacker;
	                                  turfs[i][TurfColor] = TeamInfo[attacker][TeamColor];
	                                  GangZoneShowForAll(i, turfs[i][TurfColor]);
	                                  new msg[256];
                                      format(msg,sizeof(msg), "Excellent! Because of our teamscore: %d.~n~All their turfs belongs to us now.",
			                          TeamInfo[attacker][TeamScore]);
	                                  new Text:txt = TextDrawCreate( 23.0, 125.0, msg );
                                      TextDrawUseBox(txt, 1);
	                                  TextDrawBoxColor(txt, 0x00000066);
	                                  TextDrawTextSize(txt, 248.0, 0.0);
	                                  TextDrawAlignment(txt, 0);
	                                  TextDrawBackgroundColor(txt, 0x000000ff);
	                                  TextDrawFont(txt, 1);
	                                  TextDrawLetterSize(txt, 0.29, 1.0);
	                                  TextDrawColor(txt, 0xffffffff);
	                                  TextDrawSetOutline(txt, 1);
	                                  TextDrawSetProportional(txt, 1);
	                                  TimeTextForPlayer(a, txt, 6000);
	                              }
			         		  }
                         }
                     }
                 }
	        }
	        turfs[turf][TurfOwner] = attacker;
	        turfs[turf][TurfColor] = TeamInfo[attacker][TeamColor];
            GangZoneShowForAll(turf, turfs[turf][TurfColor] );
            turfs[turf][TurfAttacker] = -1;
            for (new c=0; c<MAX_TEAMS; c++) { TurfInfo[turf][c][TurfKills] = 0; TurfInfo[turf][c][TurfAttackKills] = 0; }
        }
        else if (TurfInfo[turf][attacker][TurfAttackKills] == 0 && TurfInfo[turf][defender][TurfAttackKills] == 0)
        {
            for (new id = 0; id < 500; id++)
		    {
                 if (gPlayerSpawned[id] == 1 && !GetPlayerInterior(id))
				 {
                     GetPlayerPos(id, x, y, z);
                     if (IsPlayerInTurf(id, turfs[turf][zMinX], turfs[turf][zMinY], turfs[turf][zMaxX], turfs[turf][zMaxY]))
					 {
                         if (gTeam[id] == attacker) TurfInfo[turf][attacker][MIT]++;
                         if (gTeam[id] == defender) TurfInfo[turf][defender][MIT]++;
				     }
				 }
	        }
            if (TurfInfo[turf][attacker][MIT] > TurfInfo[turf][defender][MIT])
            {
                for (new a = 0; a < 500; a++)
	            {
                     if (gTeam[a] == defender)
					 { 
                         new msg1[256];
	                     format(msg1,sizeof(msg1), "~r~The ~y~%s ~r~have taken over our turf in ~y~%s!",
	                     TeamInfo[attacker][TeamName], turfs[turf][turfName]);
                         new Text:txt1 = TextDrawCreate(139.0, 420.0, msg1);
                         TextDrawFont(txt1, 1 );
                         TextDrawLetterSize(txt1, 0.29, 1.0);
                         TextDrawSetShadow(txt1, 0);
                         TextDrawSetOutline(txt1, 1);
                         TextDrawColor(txt1, COLOR_RED);
                         TimeTextForPlayer(a, txt1, 6000);
					     format(string,sizeof(string), "We have been beaten by %s in gang war at %s.They had %d members on their turf.",TeamInfo[attacker][TeamName], turfs[turf][turfName], TurfInfo[turf][attacker][MIT]);
	                     SendClientMessage(a, COLOR_RED, string);
	                     TeamInfo[defender][TurfWarsLost]++;
	                     TeamInfo[defender][TeamScore]--;
		             }
	                 else if (gTeam[a] == attacker)
					 { 
                         new msg2[256];
                         format(msg2,sizeof(msg2), "~g~We won the turf war against the ~y~%s ~g~in ~y~%s!",
			             TeamInfo[defender][TeamName], turfs[turf][turfName]);
			             new Text:txt2 = TextDrawCreate(139.0, 378.0, msg2);
                         TextDrawFont(txt2, 1 );
                         TextDrawLetterSize(txt2, 0.29, 1.0);
                         TextDrawSetShadow(txt2, 0);
                         TextDrawSetOutline(txt2, 1);
                         TextDrawColor(txt2, COLOR_WHITE);
                         TimeTextForPlayer(a, txt2, 6000);
	                     format(string,sizeof(string), "We beated %s in gang war at %s.We had %d members on their turf.",TeamInfo[defender][TeamName], turfs[turf][turfName], TurfInfo[turf][attacker][MIT]);
	                     SendClientMessage(a, COLOR_YELLOW, string);
	                     TeamInfo[attacker][TurfWarsWon]++;
	                     TeamInfo[attacker][TeamScore]++;
	                     SendClientMessage(a, COLOR_LIGHTBLUE, "Well done. You received $5000.");
                         GivePlayerCash(a, 5000);
                     }
	            }
	            turfs[turf][TurfOwner] = attacker;
	            turfs[turf][TurfColor] = TeamInfo[attacker][TeamColor];
                GangZoneShowForAll(turf, turfs[turf][TurfColor]);
                turfs[turf][TurfAttacker] = -1;
                for (new c=0; c<MAX_TEAMS; c++) { TurfInfo[turf][c][TurfKills] = 0; TurfInfo[turf][c][TurfAttackKills] = 0; }
            }
            else
            {
                for (new a = 0; a < 500; a++)
	            {
                     if (gTeam[a] == defender)
					 {
                         new msg3[256];
                         format(msg3,sizeof(msg3), "~g~That showed them. The turf in ~y~%s ~g~remain ours.",turfs[turf][turfName]);
					     new Text:txt3 = TextDrawCreate( 139.0, 392.0, msg3);
                         TextDrawFont(txt3, 1);
                         TextDrawLetterSize(txt3, 0.29, 1.0);
                         TextDrawSetShadow(txt3, 0);
                         TextDrawSetOutline(txt3, 1);
                         TextDrawColor(txt3, COLOR_WHITE);
                         TimeTextForPlayer(a, txt3, 6000);
	                     TeamInfo[defender][TurfWarsWon]++;
	                     TeamInfo[defender][TeamScore]++;
	                     format(string,sizeof(string), "The turf in %s remains yours.",turfs[turf][turfName]);
	                     SendClientMessage(a, COLOR_YELLOW, string);
                         SendClientMessage(a, COLOR_LIGHTBLUE, "Well done. You received $2500.");
                         GivePlayerCash(a, 2500);
		             }
		             else if (gTeam[a] == attacker)
					 {
                         new msg4[256];
	                     format(msg4,sizeof(msg4), "~r~We lost the turf war against the ~y~%s ~r~in ~y~%s ( %s )!",
					     TeamInfo[defender][TeamName], turfs[turf][turfName], turfs[turf][cityName]);
                         new Text:txt4 = TextDrawCreate(139.0, 406.0, msg4);
                         TextDrawFont(txt4, 1);
                         TextDrawLetterSize(txt4, 0.29, 1.0);
                         TextDrawSetShadow(txt4, 0);
                         TextDrawSetOutline(txt4, 1);
                         TextDrawColor(txt4, COLOR_RED);
                         TimeTextForPlayer(a, txt4, 6000);
                         format(string,sizeof(string), "We lost the war against the %s in %s.",TeamInfo[defender][TeamName], turfs[turf][turfName]);
                         SendClientMessage(a, COLOR_LIGHTRED, string);
	                     TeamInfo[attacker][TurfWarsLost]++;
	                     TeamInfo[attacker][TeamScore]--;
                     }
	            }
	            turfs[turf][TurfOwner] = defender;
	            turfs[turf][TurfColor] = TeamInfo[defender][TeamColor];
                GangZoneShowForAll(turf, turfs[turf][TurfColor]);
                turfs[turf][TurfAttacker] = -1;
                for (new c=0; c<MAX_TEAMS; c++) { TurfInfo[turf][c][TurfKills] =0; TurfInfo[turf][c][TurfAttackKills] =0; }
            }
        }
        else
		{
            for (new a = 0; a < 500; a++)
	        {
                 if (gTeam[a] == defender)
				 { 
                     new msg3[256];
                     format(msg3,sizeof(msg3), "~g~That showed them. The turf in ~y~%s ( %s ) ~g~remain ours.",
					 turfs[turf][turfName], turfs[turf][cityName]);
					 new Text:txt3 = TextDrawCreate(139.0, 392.0, msg3);
                     TextDrawFont(txt3, 1 );
                     TextDrawLetterSize(txt3, 0.29, 1.0);
                     TextDrawSetShadow(txt3, 0);
                     TextDrawSetOutline(txt3, 1);
                     TextDrawColor(txt3, COLOR_WHITE);
                     TimeTextForPlayer(a, txt3, 6000);
                     format (string, sizeof(string), "Final score from the turfwar in %s ( %s ). %s %d - %s %d.",
					 turfs[turf][turfName], turfs[turf][cityName],
					 TeamInfo[defender][TeamName], TurfInfo[turf][defender][TurfAttackKills],
					 TeamInfo[attacker][TeamName], TurfInfo[turf][attacker][TurfAttackKills]);
	                 SendClientMessage(a, COLOR_YELLOW, string);
	                 TeamInfo[defender][TurfWarsWon]++;
	                 TeamInfo[defender][TeamScore]++;
                     SendClientMessage(a, COLOR_LIGHTBLUE, "Well done. You received $5000.");
                     GivePlayerCash(a, 5000);
		         }
		         else if (gTeam[a] == attacker)
				 {
                     new msg4[256];
	                 format(msg4,sizeof(msg4), "~r~We lost the turfwar against the ~y~%s ~r~in ~y~%s ( %s )!",
					 TeamInfo[defender][TeamName], turfs[turf][turfName], turfs[turf][cityName]);
                     new Text:txt4 = TextDrawCreate(139.0, 406.0, msg4);
                     TextDrawFont(txt4, 1);
                     TextDrawLetterSize(txt4, 0.29, 1.0);
                     TextDrawSetShadow(txt4, 0 );
                     TextDrawSetOutline(txt4, 1 );
                     TextDrawColor(txt4, COLOR_RED );
                     TimeTextForPlayer(a, txt4, 6000 );
                     format (string, sizeof(string), "Final score from the turfwar in %s ( %s ). %s %d - %s %d.",
					 turfs[turf][turfName], turfs[turf][cityName],
					 TeamInfo[defender][TeamName], TurfInfo[turf][defender][TurfAttackKills],
					 TeamInfo[attacker][TeamName], TurfInfo[turf][attacker][TurfAttackKills]);
	                 SendClientMessage(a, COLOR_YELLOW, string);
	                 TeamInfo[attacker][TurfWarsLost]++;
	                 TeamInfo[attacker][TeamScore]--;
                 }
	        }
            if (TeamInfo[attacker][TeamScore] >= TEAMSCORE) TeamInfo[attacker][TeamScore] =0;
	        turfs[turf][TurfOwner] = defender;
	        turfs[turf][TurfColor] = TeamInfo[defender][TeamColor];
            GangZoneShowForAll(turf, turfs[turf][TurfColor]);
            turfs[turf][TurfAttacker] = -1;
            for (new c=0; c<MAX_TEAMS; c++) { TurfInfo[turf][c][TurfKills] =0; TurfInfo[turf][c][TurfAttackKills] =0; }
		}
	}
}
//==============================================================================
public OnPlayerRequestClass(playerid, classid)
{
    PlayerInfo[playerid][pModel] = classid;
    SetPlayerClass(playerid, classid);
    PlayerPlaySound(playerid, 1068, 0.0, 0.0, 0.0 );
	switch(classid)
    {
       case 0..2:
       {
           SetPlayerPos(playerid, 2498.2249,-1644.6326,18.8751);
           SetPlayerCameraPos(playerid, 2498.2676,-1640.1935,18.6116);
           SetPlayerCameraLookAt(playerid, 2498.2249,-1644.6326,18.8751);
           SetPlayerFacingAngle(playerid, 0.0);
           GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~g~Grove Street Families", 3000, 3);
           ApplyAnimation(playerid,"LOWRIDER", "RAP_B_Loop",4.0,1,1,1,1,1);
       }
       case 3..5:
       {
           SetPlayerPos(playerid, 1979.8929,-1143.1704,25.9858);
           SetPlayerCameraPos(playerid, 1975.8948,-1145.9689,25.9895);
           SetPlayerCameraLookAt(playerid, 1979.8929,-1143.1704,25.9858);
           SetPlayerFacingAngle(playerid, 120.0);
           GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~p~Rolling Height Ballas", 3000, 3);
           ApplyAnimation(playerid,"GHANDS", "gsign2LH",4.0,1,1,1,1,1);
       }
       case 6..8:
       {
           SetPlayerPos(playerid, 2654.5081,-1063.5448,69.5937);
           SetPlayerCameraPos(playerid, 2658.3940,-1060.7126,69.5209);
           SetPlayerCameraLookAt(playerid, 2654.5081,-1063.5448,69.5937);
           SetPlayerFacingAngle(playerid, 300.0);
           GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~Los Santos Vagos", 3000, 3);
           ApplyAnimation(playerid,"RIOT", "RIOT_CHANT",4.0,1,1,1,1,1);
       }
       case 9..11:
       {
           SetPlayerPos(playerid, 1810.5295,-2103.0408,13.5469);
           SetPlayerCameraPos(playerid, 1814.3398,-2100.5222,13.5469);
           SetPlayerCameraLookAt(playerid, 1810.5295,-2103.0408,13.5469);
           SetPlayerFacingAngle(playerid, 300.0);
           GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~b~Varrio Los Aztecas", 3000, 3);
           ApplyAnimation(playerid,"RIOT", "RIOT_ANGRY",4.0,1,1,1,1,1);
       }
       case 12..15:
       {
           SetPlayerPos(playerid, 1022.6276,-1122.8153,23.8710);
           SetPlayerCameraPos(playerid, 1022.6276,-1126.8105,23.8696);
           SetPlayerCameraLookAt(playerid, 1022.6276,-1122.8153,23.8710);
           SetPlayerFacingAngle(playerid, 180.0);
           GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~i~Black Hand Triads", 3000, 3);
           ApplyAnimation(playerid,"GHANDS", "gsign2LH",4.0,1,1,1,1,1);
       }
       case 16..20:
       {
           SetPlayerPos(playerid, 1191.2260,-1653.1935,13.9201);
           SetPlayerCameraPos(playerid, 1191.2260,-1656.7068,13.8446);
           SetPlayerCameraLookAt(playerid, 1191.2260,-1653.1935,13.9201);
           SetPlayerFacingAngle(playerid, 180.0);
           GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~Japanese Yakuza", 3000, 3);
           ApplyAnimation(playerid,"RIOT", "RIOT_CHANT",4.0,1,1,1,1,1);
       }
       case 21..25:
       {
           SetPlayerPos(playerid, 425.3501,-1757.3633,8.2564);
           SetPlayerCameraPos(playerid, 425.7744,-1762.9508,7.9428);
           SetPlayerCameraLookAt(playerid, 425.3501,-1757.3633,8.2564);
           SetPlayerFacingAngle(playerid, 180.0);
           GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~b~Long Beach Cripz", 3000, 3);
           ApplyAnimation(playerid,"RIOT", "RIOT_ANGRY",4.0,1,1,1,1,1);
       }
    }
	return 1;
}
//==============================================================================
SetPlayerClass(playerid, classid)
{
    switch(classid)
    {
       case 0..2: { gTeam[playerid] = TEAM_GROVE; SetPlayerTeam(playerid, TEAM_GROVE); }
       case 3..5: { gTeam[playerid] = TEAM_BALLAS; SetPlayerTeam(playerid, TEAM_BALLAS); }
       case 6..8: { gTeam[playerid] = TEAM_VAGOS; SetPlayerTeam(playerid, TEAM_VAGOS); }
       case 9..11: { gTeam[playerid] = TEAM_AZTECAS; SetPlayerTeam(playerid, TEAM_AZTECAS); }
       case 12..15: { gTeam[playerid] = TEAM_TRIADS; SetPlayerTeam(playerid, TEAM_TRIADS); }
       case 16..20: { gTeam[playerid] = TEAM_YAKUZA; SetPlayerTeam(playerid, TEAM_YAKUZA); }
       case 21..25: { gTeam[playerid] = TEAM_CRIPZ; SetPlayerTeam(playerid, TEAM_CRIPZ); }
    }
}
//==============================================================================
public OnPlayerConnect(playerid)
{
	new string[MAX_PLAYER_NAME];
	ResetStats(playerid);
	format(string, sizeof(string), "%s.ini", PlayerName(playerid));
	if(!dini_Exists(string))
	{
		gPlayerAccount[playerid] = 0;
 		new regstring[256];
		new regname[64];
		SendClientMessage(playerid, COLOR_YELLOW, "You dont have an account. Please register your account to proceed.");
		GetPlayerName(playerid,regname,sizeof(regname));
		format(regstring,sizeof(regstring),"Los Santos Gang Wars\nPlease register your account by typing you password below");
		ShowPlayerDialog(playerid,12345,DIALOG_STYLE_INPUT,"Register",regstring,"Register","Exit");
		return 1;
	}
	else
	{
	    gPlayerAccount[playerid] = 1;
		new loginstring[256];
		new loginname[64];
		SendClientMessage(playerid, COLOR_YELLOW, "SERVER: That name is registered, please wait to login");
		SendClientMessage(playerid, COLOR_WHITE, "HINT: You can now login by typing your password below");
		GetPlayerName(playerid,loginname,sizeof(loginname));
		format(loginstring,sizeof(loginstring),"Los Santos Gang Wars\nThat name is registered. please enter your password below");
		ShowPlayerDialog(playerid,12346,DIALOG_STYLE_INPUT,"Login",loginstring,"Login","Exit");
		return 1;
	}
}
//==============================================================================
public ResetStats(playerid)
{
	PlayerInfo[playerid][pAdmin] = 0;
    PlayerInfo[playerid][pBanned] = 0;
    PlayerInfo[playerid][pDonateRank] = 0;
    PlayerInfo[playerid][pWarns] = 0;
    PlayerInfo[playerid][pJail] = 0;
    PlayerInfo[playerid][pJailTime] = 0;
    PlayerInfo[playerid][pCash] = 0;
    PlayerInfo[playerid][pReg] = 0;
    PlayerInfo[playerid][pKills] = 0;
	PlayerInfo[playerid][pDeaths] = 0;
	PlayerInfo[playerid][pGun0] = 0;
	PlayerInfo[playerid][pGun1] = 0;
	PlayerInfo[playerid][pGun2] = 0;
	PlayerInfo[playerid][pGun3] = 0;
	PlayerInfo[playerid][pGun4] = 0;
	PlayerInfo[playerid][pGun5] = 0;
	PlayerInfo[playerid][pGun6] = 0;
	PlayerInfo[playerid][pGun7] = 0;
	PlayerInfo[playerid][pGun8] = 0;
	PlayerInfo[playerid][pGun9] = 0;
	PlayerInfo[playerid][pGun10] = 0;
	PlayerInfo[playerid][pGun11] = 0;
	PlayerInfo[playerid][pGun12] = 0;
	PlayerInfo[playerid][pModel] = 0;
	PlayerInfo[playerid][pMuted] = 0;
	PlayerInfo[playerid][pSpree] = 0;
	PlayerInfo[playerid][pCalcSec] = 0.0;
	PlayerInfo[playerid][pCWons] = 0;
	PlayerInfo[playerid][pLotto] = 0;
	PlayerInfo[playerid][pHide] = 0;
	gPlayerAccount[playerid] = 0;
	gPlayerLogged[playerid] = 0;
    gPlayerLogTries[playerid] = 0;
    gPlayerSpawned[playerid] = 0;
    BladeKill[playerid] = 0;
    PlayerSpectating[playerid] = 0;
    SpecPlayerReturnPos[playerid] = 0;
    PlayerKilled[playerid] = 0;
    HitID[playerid] = 999;
    gDropPickup[playerid] = -1;
    gPickupID[playerid] = 0;
    PlayerInEvent[playerid] = 0;
    ParkourPoint[playerid] = 0;
    IsHitman[playerid] = 0;
    PlayerCar[playerid] = 0;
	return 0;
}
//==============================================================================
public OnPlayerDisconnect(playerid, reason)
{
    if(PlayerInEvent[playerid] != 0)
    {
        EventPlayers --;
    }
    DestroyVehicle(PlayerCar[playerid]);
    OnPlayerDataSave(playerid);
	return 1;
}
//==============================================================================
public OnPlayerRegister(playerid, password[])
{
	if(IsPlayerConnected(playerid))
	{
	    new string[256], playersip[64];
	    GetPlayerIp(playerid, playersip, sizeof(playersip));
	    format(string, sizeof(string), "%s.ini", PlayerName(playerid));
		if(!dini_Exists(string))
		{
		    dini_Create(string);
		    strmid(PlayerInfo[playerid][pKey], password, 0, strlen(password), 255);
		    strmid(PlayerInfo[playerid][pIP], playersip, 0, strlen(playersip), 255);
		    dini_Set(string, "Key", password);
		    dini_Set(string, "IP", playersip);
		    dini_IntSet(string, "AdminLevel", 0);
		    dini_IntSet(string, "Banned", 0);
		    dini_IntSet(string, "DonateRank", 0);
		    dini_IntSet(string, "Warnings", 0);
		    dini_IntSet(string, "Registered", 0);
		    dini_IntSet(string, "Cash", 0);
			dini_IntSet(string, "Kills", 0);
			dini_IntSet(string, "Deaths", 0);
			dini_IntSet(string, "Muted", 0);
			dini_IntSet(string, "KillSpree", 0);
			dini_IntSet(string, "CWons", 0);
			dini_IntSet(string, "Hide", 0);
		}
		new tmppass[64];
		OnPlayerLogin(playerid,tmppass);
		SendClientMessage(playerid, COLOR_YELLOW, "Account registered, you have been logged in automatically.");
	}
	return 1;
}
//==============================================================================
public OnPlayerDataSave(playerid)
{
    if(IsPlayerConnected(playerid))
	{
		if(gPlayerLogged[playerid] && gPlayerSpawned[playerid])
		{
		    new string[256], playersip[64];
		    format(string, sizeof(string), "%s.ini", PlayerName(playerid));
		    GetPlayerIp(playerid, playersip, sizeof(playersip));
		    if(dini_Exists(string))
		    {
		        dini_Set(string, "Key", PlayerInfo[playerid][pKey]);
		        dini_Set(string, "IP", PlayerInfo[playerid][pIP]);
		        dini_IntSet(string, "AdminLevel", PlayerInfo[playerid][pAdmin]);
		        dini_IntSet(string, "Banned", PlayerInfo[playerid][pBanned]);
		        dini_IntSet(string, "DonateRank", PlayerInfo[playerid][pDonateRank]);
		        dini_IntSet(string, "Registered", PlayerInfo[playerid][pReg]);
		        dini_IntSet(string, "Warnings", PlayerInfo[playerid][pWarns]);
		        dini_IntSet(string, "Cash", PlayerInfo[playerid][pCash]);
		        dini_IntSet(string, "Kills", PlayerInfo[playerid][pKills]);
		        dini_IntSet(string, "Deaths", PlayerInfo[playerid][pDeaths]);
		        dini_IntSet(string, "Muted", PlayerInfo[playerid][pMuted]);
		        dini_IntSet(string, "KillSpree", PlayerInfo[playerid][pSpree]);
		        dini_IntSet(string, "CWons", PlayerInfo[playerid][pCWons]);
		        dini_IntSet(string, "Hide", PlayerInfo[playerid][pHide]);
		    }
		}
	}
    return 1;
}
//==============================================================================
public OnPlayerLogin(playerid,password[])
{
	new string2[256], keystring[256];
	format(string2, sizeof(string2), "%s.ini", PlayerName(playerid));
	keystring = dini_Get(string2, "Key");
	if(strcmp(keystring, password, true) == 0)
	{
		PlayerInfo[playerid][pAdmin] = dini_Int(string2,"AdminLevel");
		PlayerInfo[playerid][pBanned] = dini_Int(string2,"Banned");
		PlayerInfo[playerid][pDonateRank] = dini_Int(string2,"DonateRank");
		PlayerInfo[playerid][pWarns] = dini_Int(string2,"Warnings");
		PlayerInfo[playerid][pReg] = dini_Int(string2,"Registered");
		PlayerInfo[playerid][pCash] = dini_Int(string2,"Cash");
		PlayerInfo[playerid][pKills] = dini_Int(string2,"Kills");
		PlayerInfo[playerid][pDeaths] = dini_Int(string2,"Deaths");
		PlayerInfo[playerid][pMuted] = dini_Int(string2,"Muted");
		PlayerInfo[playerid][pSpree] = dini_Int(string2,"KillSpree");
		PlayerInfo[playerid][pCWons] = dini_Int(string2,"CWons");
		PlayerInfo[playerid][pHide] = dini_Int(string2,"Hide");
//		PlayerInfo[playerid][pScore]= dini_Int(string2,"Score')
	}
	else
	{
	    new loginstring[256];
	    new loginname[64];
		GetPlayerName(playerid,loginname,sizeof(loginname));
		format(loginstring,sizeof(loginstring),"Wrong Password\nPlease enter the correct password u have 4 chances:",loginname);
		ShowPlayerDialog(playerid,12347,DIALOG_STYLE_INPUT,"Login",loginstring,"Login","Exit");
	    gPlayerLogTries[playerid] += 1;
	    if(gPlayerLogTries[playerid] == 4) Kick(playerid);
	    return 1;
	}
	if(PlayerInfo[playerid][pBanned] == 1)
	{
	    SendClientMessage(playerid, COLOR_ADMINCMD, "You are banned from this server goto our discord srver and create unban appeal.");
	    return Kick(playerid);
	}
	if(PlayerInfo[playerid][pReg] == 0)
	{
	    PlayerInfo[playerid][pReg] = 1;
		GivePlayerCash(playerid, 10000);
	}
	gPlayerLogged[playerid] = 1;
	SetPlayerCash(playerid, PlayerInfo[playerid][pCash]);
	format(string2, sizeof(string2), "SERVER: Welcome %s", PlayerName(playerid));
	SendClientMessage(playerid, COLOR_WHITE,string2);
	GetPlayerIp(playerid, PlayerInfo[playerid][pIP], 21);
	strmid(PlayerInfo[playerid][pKey], password, 0, strlen(password), 255);
	if (PlayerInfo[playerid][pDonateRank] > 0)
	{
	    SendClientMessage(playerid, COLOR_WHITE,"SERVER: You are a VIp Account user.");
	}
	if (PlayerInfo[playerid][pAdmin] > 0)
	{
		format(string2, sizeof(string2), "SERVER: You are logged in as a Level %d Admin.",PlayerInfo[playerid][pAdmin]);
		SendClientMessage(playerid, COLOR_WHITE,string2);
	}
	return 1;
}
//==============================================================================
public OnPlayerSpawn(playerid)
{
    PlayerPlaySound(playerid, 1069, 0.0, 0.0, 0.0);
    FlashZoneForPlayer(playerid);
    SetPlayerScore(playerid, PlayerInfo[playerid][pKills]);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_MICRO_UZI,100);
	for (new i = 0; i < MAX_TURFS; i++) GangZoneShowForPlayer(playerid, turfs[i][turfID], turfs[i][TurfColor]);
	SetPlayerToTeamColor(playerid);
	SetPlayerSpawn(playerid);
	if(PlayerInfo[playerid][pDonateRank] > 0)
	{
	    GivePlayerGun(playerid, 24);
	    GivePlayerGun(playerid, 27);
	}
	else
	{
	    GivePlayerGun(playerid, 23);
	    GivePlayerGun(playerid, 25);
	}
	return 1;
}
//==============================================================================
public SetPlayerSpawn(playerid)
{
    new rand = random(5);
    if(SpecPlayerReturnPos[playerid] == 1)
	{
	    SetPlayerPos(playerid, Unspec[playerid][sPx], Unspec[playerid][sPy], Unspec[playerid][sPz]);
	    SetPlayerFacingAngle(playerid, Unspec[playerid][sAngle]);
	    SetPlayerInterior(playerid, Unspec[playerid][sPint]);
	    SetPlayerVirtualWorld(playerid, Unspec[playerid][sVw]);
	    SpecPlayerReturnPos[playerid] = 0;
	    RestoreWeapons(playerid);
	    return 1;
	}
	if(PlayerKilled[playerid] == 1)
	{
	    if(HitID[playerid] != INVALID_PLAYER_ID)
	    {
	        TogglePlayerSpectating(playerid, 1);
	        PlayerSpectatePlayer(playerid, HitID[playerid]);
	        SetPlayerInterior(playerid, GetPlayerInterior(HitID[playerid]));
	        PlayerSpectating[playerid] = 1;
	        HitID[playerid] = 999;
	        TextDrawShowForPlayer(playerid, txtSpec);
	    }
	}
	switch(gTeam[playerid])
    {
       case TEAM_GROVE: {
         SetPlayerPos(playerid,gGroveSP[rand][0],gGroveSP[rand][1],gGroveSP[rand][2]);
	     SetPlayerFacingAngle(playerid,gGroveSP[rand][3]);
	     SetCameraBehindPlayer(playerid);
       }
       case TEAM_BALLAS: {
         SetPlayerPos(playerid,gBallaSP[rand][0],gBallaSP[rand][1],gBallaSP[rand][2]);
	     SetPlayerFacingAngle(playerid,gBallaSP[rand][3]);
	     SetCameraBehindPlayer(playerid);
       }
       case TEAM_VAGOS: {
         SetPlayerPos(playerid,gVagosSP[rand][0],gVagosSP[rand][1],gVagosSP[rand][2]);
	     SetPlayerFacingAngle(playerid,gVagosSP[rand][3]);
	     SetCameraBehindPlayer(playerid);
       }
       case TEAM_AZTECAS: {
         SetPlayerPos(playerid,gAztecaSP[rand][0],gAztecaSP[rand][1],gAztecaSP[rand][2]);
	     SetPlayerFacingAngle(playerid,gAztecaSP[rand][3]);
	     SetCameraBehindPlayer(playerid);
       }
       case TEAM_TRIADS: {
         SetPlayerPos(playerid,gTriadsSP[rand][0],gTriadsSP[rand][1],gTriadsSP[rand][2]);
	     SetPlayerFacingAngle(playerid,gTriadsSP[rand][3]);
	     SetCameraBehindPlayer(playerid);
       }
       case TEAM_YAKUZA: {
         SetPlayerPos(playerid,gYakuzSP[rand][0],gYakuzSP[rand][1],gYakuzSP[rand][2]);
	     SetPlayerFacingAngle(playerid,gYakuzSP[rand][3]);
	     SetCameraBehindPlayer(playerid);
       }
       case TEAM_CRIPZ: {
         SetPlayerPos(playerid,gCripzSP[rand][0],gCripzSP[rand][1],gCripzSP[rand][2]);
	     SetPlayerFacingAngle(playerid,gCripzSP[rand][3]);
	     SetCameraBehindPlayer(playerid);
       }
	}
    return 1;
}
//==============================================================================
public OnPlayerDeath(playerid, killerid, reason)
{
    new string[256];
    new Float: X, Float: Y, Float: Z;
    SendDeathMessage(killerid, playerid, reason);
    format(string, sizeof(string), "~w~Wasted");
    GameTextForPlayer(playerid, string, 5000, 2);
    if(PlayerInEvent[playerid] != 0)
    {
        DisablePlayerCheckpoint(playerid);
        DestroyVehicle(PlayerCar[playerid]);
	    ParkourPoint[playerid] = 0;
	    PlayerInEvent[playerid] = 0;
	    EventPlayers --;
	}
	GivePlayerCash(playerid, -500);
	HitID[playerid] = killerid;
    SetPlayerWantedLevel(playerid, 0);
    PlayerInfo[playerid][pDeaths] += 1;
	Kills[playerid] = 0;
	GetPlayerPos(playerid, X, Y, Z);
	gDropPickup[playerid] = GetPlayerWeapon(playerid);
	gPickupID[playerid] = CreatePickup(GetWeaponPickupID(GetPlayerWeapon(playerid)), 3, X, Y, Z, -1);
	SetTimerEx("PickupDestroy", 10000, 0, "i", playerid);
	ResetPlayerWeaponsEx(playerid);
	PlayerKilled[playerid] = 1;
	if(Bounty[playerid] > 0)
	{
	    GivePlayerCash(playerid, -Bounty[playerid]);
        Bounty[playerid] = 0;
        format(string, sizeof(string), " That player had a bounty on his head, Reward: %d$", Bounty[playerid]);
	    SendClientMessage(killerid, COLOR_YELLOW2, string);
	    GivePlayerCash(killerid, Bounty[playerid]);
	}
	if(killerid != 255)
	{
		if(GetPlayerState(killerid) == 2)
		{
		    new kickname[MAX_PLAYER_NAME];
			GetPlayerName(killerid, kickname, sizeof(kickname));
			format(string, 256, "AdmWarning: %s[%d]just killed a %s[%d] with Drive-By." ,kickname,killerid,PlayerName(playerid),playerid);
			ABroadCast(COLOR_YELLOW, string, 1);
			return 1;
		}
	}
    if(reason == 50)
	{
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			BladeKill[killerid] += 1;
			if(BladeKill[killerid] >= 3)
			{
			    GetPlayerName(killerid, kickname, sizeof(kickname));
			    format(string, 256, "AdmCmd: %s was kicked, reason: Excesive Blade Killing." ,kickname);
			    SendClientMessageToAll(COLOR_LIGHTRED, string);
			    Kick(killerid);
			}
		}
	}
	PlayerInfo[killerid][pKills] += 1;
	SetPlayerScore(killerid, PlayerInfo[killerid][pKills]);
	Kills[killerid]++;
	if(Kills[killerid] > 3) Bounty[killerid] += 1000 * Kills[killerid];
	new bonus = 500 * Kills[killerid];
	GivePlayerCash(killerid, bonus);
	if(Kills[killerid] == 3) format(string,sizeof(string),"~W~%s IS DOMINATING!", PlayerName(killerid));
    if(Kills[killerid] == 5) format(string,sizeof(string),"~W~%s IS ON A KILLING SPREE!", PlayerName(killerid));
    if(Kills[killerid] == 8) format(string,sizeof(string),"~W~%s HAS A MONSTER KILL!!!", PlayerName(killerid));
    if(Kills[killerid] == 11) format(string,sizeof(string),"~W~%s IS ~r~GODLIKE!", PlayerName(killerid));
    if(Kills[killerid] == 15) format(string,sizeof(string),"~W~%s IS ~R~WICKED SICK!", PlayerName(killerid));
    if(Kills[killerid] >= 18) format(string,sizeof(string),"~R~%s HOLY SHIT WITH %d KILLS!",PlayerName(killerid), Kills[killerid]);
    GameTextForAll(string, 5000, 4);
	SetPlayerWantedLevel(killerid, GetPlayerWantedLevel(killerid));
	if(Kills[killerid] > PlayerInfo[killerid][pSpree]) PlayerInfo[killerid][pSpree] = Kills[killerid];
    if (gTeam[killerid] != gTeam[playerid])
	{
	    new Float:x, Float:y, Float:z;
        TeamInfo[gTeam[killerid]][RivalsKilled]++;
        TeamInfo[gTeam[playerid]][HomiesDied]++;
        TeamInfo[gTeam[killerid]][TeamScore]++;
        TeamInfo[gTeam[playerid]][TeamScore]--;
		GetPlayerPos(playerid, x, y, z);
		GetPlayerPos(killerid, x, y, z);
	    for (new i = 0; i < MAX_TURFS; i++)
	    {
	        if (IsPlayerInTurf(playerid, turfs[i][zMinX], turfs[i][zMinY], turfs[i][zMaxX], turfs[i][zMaxY]) &&
			IsPlayerInTurf(killerid, turfs[i][zMinX], turfs[i][zMinY], turfs[i][zMaxX], turfs[i][zMaxY])  )
	        {
                if (turfs[i][TurfWarStarted] != 1 && !IsPlayerInAnyVehicle(killerid))
                {
                    TurfInfo[i][gTeam[killerid]][TurfKills]++;
                    if (TurfInfo[i][gTeam[killerid]][TurfKills] == ATTACK_KILLS)
                    {
                        if (turfs[i][TurfOwner] == gTeam[killerid])
						{
                            for (new a = 0; a < MAX_TEAMS; a++) TurfInfo[i][a][TurfKills] = 0;
							return 1;
                        }
                        turfs[ i ][ TurfAttacker ] = gTeam[killerid];
                        for (new b = 0; b < 500; b++)
	                    {
                            if (gTeam[b] == turfs[i][TurfAttacker])
							{
                                new msg1[256];
	                            format(msg1,sizeof(msg1), "~w~We have provoked a turfwar ~w~in ~y~%s ( %s ) ~w~against the ~r~%s",
								turfs[i][turfName], turfs[i][cityName], TeamInfo[turfs[i][TurfOwner]][TeamName]);
                                new Text:txt1 = TextDrawCreate(139.0, 350.0, msg1 );
                                TextDrawFont(txt1, 1);
                                TextDrawLetterSize(txt1, 0.29, 1.0);
                                TextDrawSetShadow(txt1, 0);
                                TextDrawSetOutline(txt1, 1);
                                TextDrawColor(txt1, COLOR_WHITE);
                                TimeTextForPlayer(b, txt1, 6000);
                                GangZoneFlashForPlayer(b, turfs[i][turfID], COLOR_FLASH );
                            }
                            else if (gTeam[b] == turfs[ i ][ TurfOwner ])
							{
                                new msg2[256];
	                            format(msg2,sizeof(msg2), "~r~The ~y~%s ~r~have attacked our turf in ~y~%s ( %s )!",
                                TeamInfo[turfs[i][TurfAttacker]][TeamName], turfs[i][turfName], turfs[i][cityName]);
                                new Text:txt2 = TextDrawCreate(139.0, 364.0, msg2);
                                TextDrawFont(txt2, 1);
                                TextDrawLetterSize(txt2, 0.29, 1.0);
                                TextDrawSetShadow(txt2, 0);
                                TextDrawSetOutline(txt2, 1);
                                TextDrawColor(txt2, COLOR_RED);
                                TimeTextForPlayer(b, txt2, 6000);
                                GangZoneFlashForPlayer(b, turfs[i][turfID], COLOR_FLASH);
                            }
                            else GangZoneFlashForPlayer(b, turfs[i][turfID], COLOR_FLASH2);
	                    }
	                    SetTimerEx("EndWar", ATTACK_TIME, false ,"iii", i, turfs[i][TurfAttacker], turfs[i][TurfOwner] );
	                    turfs[i][TurfWarStarted] = 1;
	                    for(new c = 0; c < MAX_TEAMS; c++) { TurfInfo[i][c][TurfKills] = 0; TurfInfo[i][c][TurfAttackKills] = 0; }
                        return 1;
                    }
                }
                else if (turfs[i][TurfWarStarted] == 1 && !IsPlayerInAnyVehicle(killerid) &&
                (turfs[i][TurfAttacker] == gTeam[killerid]) || turfs[i][TurfOwner] == gTeam[killerid])
                {
                    TurfInfo[i][gTeam[killerid]][TurfAttackKills]++;
                    return 1;
                }
	        }
	    }
	}
	if(PlayerInfo[killerid][pAdmin] < 1)
	{
	    for (new weap = 1; weap < 47; weap++)
        {
            if(GetPlayerWeapon(killerid) == weap && HaveWeapon(killerid, weap) != weap)
            {
                new weapname[32];
                GetWeaponName(weap, weapname, sizeof(weapname));
                format(string, sizeof(string), "Adm: %s was banned, reason: Weapon Hacking (%s).", PlayerName(killerid), weapname);
			    SendClientMessageToAll(COLOR_LIGHTRED, string);
			    PlayerInfo[killerid][pBanned] = 1;
			    format(string, sizeof(string), "Weapon Hacking (%s).", weapname);
			    BanEx(killerid, string);
            }
        }
	}
	return 1;
}
//==============================================================================
public OnPlayerText(playerid, text[])
{
    new string[256];
    new tmp[128];
    if(PlayerInfo[playerid][pMuted] != 0)
    {
        SendClientMessage(playerid, COLOR_ADMINCMD, " Dont try to speak idiot.");
        return 0;
    }
    if(CalculateStarted == 1)
    {
		switch (CalculateEvent)
		{
		    case 1:
		    {
		        new idx;
	            tmp = strtok(text, idx);
		        if ((strcmp("49", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("49")))
	            {
	                CalculateStarted = 0;
	                CalculateEvent = 0;
	                for(new i = 0; i < MAX_PLAYERS; i++)
		            {
		                KillTimer(reactiontimer[i]);
		            }
	                PlayerInfo[playerid][pCWons] ++;
	                GivePlayerCash(playerid, 20000);
	                format(string, sizeof(string), "* %s has the fastest reaction of %.1f seconds. %s has won %d times before.", PlayerName(playerid), PlayerInfo[playerid][pCalcSec], PlayerName(playerid), PlayerInfo[playerid][pCWons]);
	                SendClientMessageToAll(COLOR_YELLOW, string);
	                PlayerInfo[playerid][pCalcSec] = 0.0;
	            }
		    }
		    case 2:
		    {
		        new idx;
	            tmp = strtok(text, idx);
		        if ((strcmp("5.44", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("5.44")))
	            {
	                CalculateStarted = 0;
	                CalculateEvent = 0;
	                for(new i = 0; i < MAX_PLAYERS; i++)
		            {
		                KillTimer(reactiontimer[i]);
		            }
	                PlayerInfo[playerid][pCWons] ++;
	                GivePlayerCash(playerid, 20000);
	                format(string, sizeof(string), "* %s has the fastest reaction of %.1f seconds. %s has won %d times before.", PlayerName(playerid), PlayerInfo[playerid][pCalcSec], PlayerName(playerid), PlayerInfo[playerid][pCWons]);
	                SendClientMessageToAll(COLOR_YELLOW, string);
	                PlayerInfo[playerid][pCalcSec] = 0.0;
	            }
		    }
		    case 3:
		    {
		        new idx;
	            tmp = strtok(text, idx);
		        if ((strcmp("10", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("10")))
	            {
	                CalculateStarted = 0;
	                CalculateEvent = 0;
	                for(new i = 0; i < MAX_PLAYERS; i++)
		            {
		                KillTimer(reactiontimer[i]);
		            }
	                PlayerInfo[playerid][pCWons] ++;
	                GivePlayerCash(playerid, 20000);
	                format(string, sizeof(string), "* %s has the fastest reaction of %.1f seconds. %s has won %d times before.", PlayerName(playerid), PlayerInfo[playerid][pCalcSec], PlayerName(playerid), PlayerInfo[playerid][pCWons]);
	                SendClientMessageToAll(COLOR_YELLOW, string);
	                PlayerInfo[playerid][pCalcSec] = 0.0;
	            }
		    }
		    case 4:
		    {
		        new idx;
	            tmp = strtok(text, idx);
		        if ((strcmp("blood", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("blood")))
	            {
	                CalculateStarted = 0;
	                CalculateEvent = 0;
	                for(new i = 0; i < MAX_PLAYERS; i++)
		            {
		                KillTimer(reactiontimer[i]);
		            }
	                PlayerInfo[playerid][pCWons] ++;
	                GivePlayerCash(playerid, 20000);
	                format(string, sizeof(string), "* %s has the fastest reaction of %.1f seconds. %s has won %d times before.", PlayerName(playerid), PlayerInfo[playerid][pCalcSec], PlayerName(playerid), PlayerInfo[playerid][pCWons]);
	                SendClientMessageToAll(COLOR_YELLOW, string);
	                PlayerInfo[playerid][pCalcSec] = 0.0;
	            }
		    }
		    case 5:
		    {
		        new idx;
	            tmp = strtok(text, idx);
		        if ((strcmp("obama", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("obama")))
	            {
	                CalculateStarted = 0;
	                CalculateEvent = 0;
	                for(new i = 0; i < MAX_PLAYERS; i++)
		            {
		                KillTimer(reactiontimer[i]);
		            }
	                PlayerInfo[playerid][pCWons] ++;
	                GivePlayerCash(playerid, 20000);
	                format(string, sizeof(string), "* %s has the fastest reaction of %.1f seconds. %s has won %d times before.", PlayerName(playerid), PlayerInfo[playerid][pCalcSec], PlayerName(playerid), PlayerInfo[playerid][pCWons]);
	                SendClientMessageToAll(COLOR_YELLOW, string);
	                PlayerInfo[playerid][pCalcSec] = 0.0;
	            }
		    }
		}
    }
    if(text[0] == '!')
	{
	    new team = gTeam[playerid];
	    format(string, sizeof(string), "[TEAM] %s: %s", PlayerName(playerid), text[1]);
		SendTeamMessage(team, COLOR_ADMINCMD, string);
		return 0;
	}
	if(realchat)
	{
	    format(string, sizeof(string), "(%d): %s", playerid, text[0]);
	    SendPlayerMessageToAll(playerid, string);
	    return 0;
	}
	return 1;
}
//==============================================================================
public OnPlayerEnterCheckpoint(playerid)
{
    new string[128];
    if(PlayerInEvent[playerid] == 1)
	{
	    if(ParkourPoint[playerid] == 24)
	    {
	        if(ParkourEventFinished == 0)
	        {
	            format(string, sizeof(string), "** %s has finished first and won $30,000 at the parkour event.", PlayerName(playerid));
	            SendClientMessageToAll(COLOR_YELLOW, string);
	            GivePlayerCash(playerid, 30000);
	            ParkourEventFinished = 1;
	        }
	        SendClientMessageToAll(COLOR_WHITE, "Here is $5,000 for your participation.");
	        GivePlayerCash(playerid, 5000);
	        DisablePlayerCheckpoint(playerid);
	        ParkourPoint[playerid] = 0;
	        PlayerInEvent[playerid] = 0;
	        RestoreWeapons(playerid);
	        EventPlayers --;
	        return 1;
	    }
	    ParkourPoint[playerid] ++;
	    SetPlayerCheckpoint(playerid, gParkourPoints[ParkourPoint[playerid]][0], gParkourPoints[ParkourPoint[playerid]][1], gParkourPoints[ParkourPoint[playerid]][2], 3.0);
	    return 1;
	}
    return 1;
}
//==============================================================================
public OnPlayerCommandText(playerid, cmdtext[])
{
    new string[256];
	new cmd[256];
	new tmp[256];
	new playermoney;
	new giveplayer[MAX_PLAYER_NAME];
	new giveplayerid, specplayerid, moneys, idx;
	cmd = strtok(cmdtext, idx);
    printf("[cmd][%s]: %s",PlayerName(playerid),cmdtext);
//==============================================================================
	if(strcmp(cmd, "/cmds", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    SendClientMessage(playerid, COLOR_GRAD2,"GENERAL: /stats (/t)eam /pm /kill /turfhelp /givebounty");
		    SendClientMessage(playerid, COLOR_GRAD2,"GENERAL: /rules /joinevent /report /changepass /id");
		    SendClientMessage(playerid, COLOR_GRAD2,"GENERAL: /hitman /teamstats /pay /lotto /bounties /admins");
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "ADMIN: (/a)dmin (/ah)elp");
			}
		}
		return 1;
	}
//=================================[Admin Commands]=============================
	if(strcmp(cmd, "/ah", true) == 0 || strcmp(cmd, "/acmds", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "*1* ADMIN: /hide /listguns /check /spec /setint /kick /slap /warn /ban /gotoid /akill /(a)dmin chat");
			}
			if (PlayerInfo[playerid][pAdmin] >= 2)
			{
				SendClientMessage(playerid, COLOR_GRAD2,"*2* ADMIN: /freeze /unfreeze /setskin /fartbomb /blowup /cnnn /sban /skick");
			}
			if (PlayerInfo[playerid][pAdmin] >= 3)
			{
				SendClientMessage(playerid, COLOR_GRAD2,"*3* ADMIN: /mute /rangeban /jail /mark /gotomark /fine /gethere /disarm /goto /ipcheck");
			}
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
			    SendClientMessage(playerid, COLOR_GRAD2,"*4* ADMIN: /sethp /setarmor /sethpall /setarmorall /givemoney /setmoney");
			    SendClientMessage(playerid, COLOR_GRAD2,"*4* ADMIN: /veh /fixveh /destroycar /destroycars /givegun /unban");
			}
			if (PlayerInfo[playerid][pAdmin] >= 5)
			{
				SendClientMessage(playerid, COLOR_GRAD2," 5 ADMIN: /gmx /weather /weatherall /setlevel /makevip /tod /savechars /gotocar /setname");
			}
			SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
		}
		return 1;
	}
	if(strcmp(cmd, "/admin", true) == 0 || strcmp(cmd, "/a", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[256];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/a)dmin [admin chat]");
				return 1;
			}
			format(string, sizeof(string), "*%d Admin %s: %s", PlayerInfo[playerid][pAdmin], PlayerName(playerid), result);
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				SendAdminMessage(COLOR_YELLOW, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/hide",true)==0)
	{
		if(IsPlayerConnected(playerid))
		{
		    if(PlayerInfo[playerid][pAdmin] > 0)
		    {
		        switch (PlayerInfo[playerid][pHide])
		        {
		            case 0: { PlayerInfo[playerid][pHide] = 1; SendClientMessage(playerid, COLOR_YELLOW, "* Your name will now stay hidden from the admin list."); }
		            case 1: { PlayerInfo[playerid][pHide] = 0; SendClientMessage(playerid, COLOR_YELLOW, "* Your name will now be shown at the admin list."); }
		        }
		    }
			return 1;
		}
	}
	if(strcmp(cmd, "/listguns", true) == 0)
	{
		if (PlayerInfo[playerid][pAdmin] < 1)
	    {
		    SendClientMessage(playerid, COLOR_GREY, "You are not authorized");
		    return 1;
	    }
		tmp = strtok(cmdtext,idx);
		if (!strlen(tmp))
	    {
		    SendClientMessage(playerid, COLOR_GREY, "USAGE: /listguns [Playerid/PartOfName]");
		    return 1;
	    }
		giveplayerid = ReturnUser(tmp);
		if (giveplayerid == INVALID_PLAYER_ID)
	    {
		    SendClientMessage(playerid, COLOR_GREY, "That player is offline");
		    return 1;
	    }
	    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
	    SendClientMessage(playerid, COLOR_GREEN, "_________________________________");
	    format(string, sizeof(string), "*** %s's Weapons ***", giveplayer);
	    SendClientMessage(playerid, COLOR_WHITE, string);
	    for (new weap = 1; weap < 47; weap++)
        {
            if(HaveWeapon(giveplayerid, weap) == weap)
            {
                new weapname[32];
                GetWeaponName(weap, weapname, sizeof(weapname));
			    format(string, sizeof(string), "%s", weapname);
	            SendClientMessage(playerid, COLOR_WHITE, string);
            }
        }
	    SendClientMessage(playerid, COLOR_GREEN, "_________________________________");
		return 1;
	}
	if (strcmp(cmd, "/check", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_WHITE, "USAGE: /check [Playerid/PartOfName]");
					return 1;
				}
	            giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
				    ShowStats(playerid, giveplayerid);
				}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD1, "   No Such Player");
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not an Admin");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/spec", true) == 0)
	{
		if(PlayerInfo[playerid][pAdmin] >= 1)
		{
		    tmp = strtok(cmdtext, idx);
		    if(!strlen(tmp))
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: /spec [playerid]");
			    return 1;
		    }
		    specplayerid = strval(tmp);
		    if(!IsPlayerConnected(specplayerid))
			{
		        SendClientMessage(playerid, COLOR_GREY, "That player isn't logged in.");
			    return 1;
		    }
		    if(PlayerSpectating[playerid] == 0)
		    {
		        GetPlayerPos(playerid, Unspec[playerid][sPx], Unspec[playerid][sPy], Unspec[playerid][sPz]);
                Unspec[playerid][sPint] = GetPlayerInterior(playerid);
    	        Unspec[playerid][sVw] = GetPlayerVirtualWorld(playerid);
    	        GetPlayerFacingAngle(playerid, Unspec[playerid][sAngle]);
    	    }
	        TogglePlayerSpectating(playerid, 1);
			SetPlayerInterior(playerid, GetPlayerInterior(specplayerid));
			SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specplayerid));
			PlayerSpectating[playerid] = 1;
			if(IsPlayerInAnyVehicle(specplayerid))
			{
				new carid = GetPlayerVehicleID(specplayerid);
				PlayerSpectateVehicle(playerid, carid);
			}
			else
			{
				PlayerSpectatePlayer(playerid, specplayerid);
            }
        }
        else
        {
            SendClientMessage(playerid, COLOR_WHITE, "You are not an Admin !");
            return 1;
        }
 		return 1;
	}
 	if(strcmp(cmd, "/specoff", true) == 0)
	{
	    if(PlayerInfo[playerid][pAdmin] >= 1)
		{
		    if(PlayerSpectating[playerid] == 0)
		    {
		        SendClientMessage(playerid, COLOR_GREY, "You are not spectating.");
			    return 1;
		    }
    	    TogglePlayerSpectating(playerid, 0);
    	    SpecPlayerReturnPos[playerid] = 1;
    	    PlayerSpectating[playerid] = 0;
            SendClientMessage(playerid, COLOR_WHITE, "You are no longer spectating.");
		    return 1;
		}
	}
    if(strcmp(cmd, "/setint", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setint [Playerid/PartOfName] [interiorid]");
				return 1;
			}
			new playa;
			playa = ReturnUser(tmp);
			new intid;
			tmp = strtok(cmdtext, idx);
			intid = strvalEx(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
			    		GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						SetPlayerInterior(playa, intid);
						format(string, sizeof(string), "   You have set %s's interior to %d.", giveplayer, intid);
						SendClientMessage(playerid, COLOR_GRAD1, string);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/kick", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /kick [Playerid/PartOfName] [reason]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				if(IsPlayerConnected(giveplayerid))
				{
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
					    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
				        {
							format(string, sizeof(string), "AdmCmd: %s was kicked, reason: Attempting to kick a higher level admin", PlayerName(playerid));
							SendClientMessageToAll(COLOR_LIGHTRED, string);
							Kick(playerid);
							return 1;
				        }
						new length = strlen(cmdtext);
						while ((idx < length) && (cmdtext[idx] <= ' '))
						{
							idx++;
						}
						new offset = idx;
						new result[256];
						while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
						{
							result[idx - offset] = cmdtext[idx];
							idx++;
						}
						result[idx - offset] = EOS;
						if(!strlen(result))
						{
							SendClientMessage(playerid, COLOR_WHITE, "USAGE: /kick [Playerid/PartOfName] [reason]");
							return 1;
						}
						format(string, sizeof(string), "AdmCmd: %s was kicked by %s, reason: %s", giveplayer, PlayerName(playerid), (result));
						SendClientMessageToAll(COLOR_LIGHTRED, string);
						Kick(giveplayerid);
						return 1;
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/slap", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /slap [Playerid/PartOfName]");
				return 1;
			}
			new playa;
			new Float:shealth;
			new Float:slx, Float:sly, Float:slz;
			playa = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 2)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
			            if(PlayerInfo[playa][pAdmin] > PlayerInfo[playerid][pAdmin])
				        {
							SendClientMessage(playerid, COLOR_LIGHTRED, "You cant slap higer Admin level !");
							SetPlayerHealth(playerid, 0);
							return 1;
				        }
				        GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						GetPlayerHealth(playa, shealth);
						SetPlayerHealth(playa, shealth-5);
						GetPlayerPos(playa, slx, sly, slz);
						SetPlayerPos(playa, slx, sly, slz+5);
						PlayerPlaySound(playa, 1130, slx, sly, slz+5);
						format(string, sizeof(string), "AdmCmd: %s was slapped by %s",giveplayer ,PlayerName(playerid));
						ABroadCast(COLOR_LIGHTRED, string, 1);
					}
				}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/warn", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_LIGHTBLUE, "USAGE: /warn [Playerid/PartOfName] [reason]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
			    if(IsPlayerConnected(giveplayerid))
			    {
			        if(giveplayerid != INVALID_PLAYER_ID)
			        {
					    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						new length = strlen(cmdtext);
						while ((idx < length) && (cmdtext[idx] <= ' '))
						{
							idx++;
						}
						new offset = idx;
						new result[256];
						while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
						{
							result[idx - offset] = cmdtext[idx];
							idx++;
						}
						result[idx - offset] = EOS;
						if(!strlen(result))
						{
							SendClientMessage(playerid, COLOR_WHITE, "USAGE: /warn [Playerid/PartOfName] [reason]");
							return 1;
						}
						PlayerInfo[giveplayerid][pWarns] += 1;
						if(PlayerInfo[giveplayerid][pWarns] >= 3)
						{
							PlayerInfo[giveplayerid][pBanned] = 1;
							format(string, sizeof(string), "Adminstrator: %s was banned by %s (had 3 Warnings), reason: %s", giveplayer, PlayerName(playerid), (result));
							SendClientMessageToAll(COLOR_LIGHTRED, string);
							Ban(giveplayerid);
							return 1;
						}
						format(string, sizeof(string), "You warned %s, reason: %s", giveplayer, (result));
						SendClientMessage(playerid, COLOR_LIGHTRED, string);
						format(string, sizeof(string), "You were warned by %s, reason: %s", PlayerName(playerid), (result));
						SendClientMessage(giveplayerid, COLOR_LIGHTRED, string);
						return 1;
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/ban", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /ban [Playerid/PartOfName] [reason]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
			    if(IsPlayerConnected(giveplayerid))
			    {
			        if(giveplayerid != INVALID_PLAYER_ID)
			        {
					    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
				        {
							PlayerInfo[playerid][pBanned] = 1;
							format(string, sizeof(string), "AdmCmd: %s was banned, reason: Attempting to ban a higher level admin", PlayerName(playerid));
							SendClientMessageToAll(COLOR_LIGHTRED, string);
							BanEx(playerid, "Attempting to ban a higher level admin");
							return 1;
				        }
						new length = strlen(cmdtext);
						while ((idx < length) && (cmdtext[idx] <= ' '))
						{
							idx++;
						}
						new offset = idx;
						new result[256];
						while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
						{
							result[idx - offset] = cmdtext[idx];
							idx++;
						}
						result[idx - offset] = EOS;
						if(!strlen(result))
						{
							SendClientMessage(playerid, COLOR_WHITE, "USAGE: /ban [Playerid/PartOfName] [reason]");
							return 1;
						}
						PlayerInfo[giveplayerid][pBanned] = 1;
						format(string, sizeof(string), "AdmCmd: %s was banned by %s, reason: %s", giveplayer, PlayerName(playerid), (result));
						SendClientMessageToAll(COLOR_LIGHTRED, string);
						BanEx(giveplayerid, (result));
						return 1;
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/gotoid", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_DBLUE, "USAGE: /gotoid [Playerid/PartOfName]");
				return 1;
			}
			new Float:plocx,Float:plocy,Float:plocz;
			new plo;
			plo = ReturnUser(tmp);
			if (IsPlayerConnected(plo))
			{
			    if(plo != INVALID_PLAYER_ID)
			    {
					if (PlayerInfo[playerid][pAdmin] >= 1)
					{
						GetPlayerPos(plo, plocx, plocy, plocz);
						SetPlayerInterior(playerid, GetPlayerInterior(plo));
						SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(plo));
						if (GetPlayerState(playerid) == 2)
						{
							new tmpcar = GetPlayerVehicleID(playerid);
							SetVehiclePos(tmpcar, plocx, plocy+4, plocz);
							TelePos[playerid][0] = 0.0;TelePos[playerid][1] = 0.0;
						}
						else
						{
							SetPlayerPos(playerid,plocx,plocy+2, plocz);
						}
						SendClientMessage(playerid, COLOR_GRAD1, "   You have been teleported");
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", plo);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/akill", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /akill [Playerid/PartOfName]");
				return 1;
			}
			new plo;
			plo = ReturnUser(tmp);
			if (IsPlayerConnected(plo))
			{
			    if(plo != INVALID_PLAYER_ID)
			    {
					if (PlayerInfo[playerid][pAdmin] >= 1)
					{
						SetPlayerHealth(plo, 0);
						GetPlayerName(plo, giveplayer, sizeof(giveplayer));
						format(string, 256, "AdmCmd: %s has admin killed [%d]%s." ,PlayerName(playerid) ,plo, giveplayer);
                        ABroadCast(COLOR_LIGHTRED, string, 1);
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "   You are not Adminstrator Dont use admin cmds or u will be banned/kicked!");
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", plo);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/freeze", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /freeze [Playerid/PartOfName]");
				return 1;
			}
			new playa;
			playa = ReturnUser(tmp);
			if(PlayerInfo[playa][pAdmin] > PlayerInfo[playerid][pAdmin])
			{
				SendClientMessage(playerid, COLOR_GREY, "You can't froze higher level Admins !");
				return 1;
			}
			if (PlayerInfo[playerid][pAdmin] >= 2)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
				        GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						TogglePlayerControllable(playa, 0);
						format(string, sizeof(string), "AdmCmd: %s was Frozen by %s",giveplayer ,PlayerName(playerid));
						ABroadCast(COLOR_LIGHTRED, string, 1);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/unfreeze", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /unfreeze [playerid]");
				return 1;
			}
			new playa;
			playa = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] > 1)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
			    	    GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						TogglePlayerControllable(playa, 1);
						format(string, sizeof(string), "AdmCmd: %s was UnFrozen by %s",giveplayer ,PlayerName(playerid));
						ABroadCast(COLOR_LIGHTRED,string,1);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/setskin", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setskin [Playerid/PartOfName] [skin id]");
				return 1;
			}
			new para1;
			new level;
			para1 = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			level = strval(tmp);
			if(level > 299 || level < 1) { SendClientMessage(playerid, COLOR_GREY, "Wrong skin ID!"); return 1; }
			if (PlayerInfo[playerid][pAdmin] >= 2)
			{
			    if(IsPlayerConnected(para1))
			    {
			        if(para1 != INVALID_PLAYER_ID)
			        {
						GetPlayerName(para1, giveplayer, sizeof(giveplayer));
						format(string, sizeof(string), "You have set %s's skin to %d.", giveplayer,level);
						SendClientMessage(playerid, COLOR_GRAD2, string);
					    SetPlayerSkin(para1, level);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "You are not an Admin !");
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/fartbomb", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /fartbomb [Playerid/PartOfName]");
				return 1;
			}
			new Float:plocx,Float:plocy,Float:plocz;
			giveplayerid = ReturnUser(tmp);
			if (IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
					if (PlayerInfo[playerid][pAdmin] >= 2)
					{
					    if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
					    {
					        GetPlayerPos(playerid, plocx, plocy, plocz);
						    CreateExplosion(plocx, plocy, plocz-9, 7, 1.0);
					        return 1;
					    }
						GetPlayerPos(giveplayerid, plocx, plocy, plocz);
						CreateExplosion(plocx, plocy, plocz-9, 7, 1.0);
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "   you are not authorized to use that command!");
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/blowup", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if (PlayerInfo[playerid][pAdmin] < 2)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "You are not authorised to use that command.");
			    return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /blowup [Playerid/PartOfName] [type of explosion]");
				return 1;
			}
			new Float:plocx,Float:plocy,Float:plocz;
			new expltype;
			giveplayerid = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /blowup [Playerid/PartOfName] [type of explosion]");
				return 1;
			}
			expltype = strval(tmp);
			if (IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
				    if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
					{
					    GetPlayerPos(playerid, plocx, plocy, plocz);
					    CreateExplosion(plocx, plocy, plocz, expltype, 1.0);
					    return 1;
					}
					GetPlayerPos(giveplayerid, plocx, plocy, plocz);
					CreateExplosion(plocx, plocy, plocz, expltype, 1.0);
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/cnnn", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
				tmp = strtok(cmdtext, idx);
				new txtid;
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_WHITE, "USAGE: /cnnn <type> ");
					return 1;
				}
				txtid = strval(tmp);
				if(txtid == 2)
				{
					SendClientMessage(playerid, COLOR_GRAD2, "You can not select 2");
					return 1;
				}
				new length = strlen(cmdtext);
				while ((idx < length) && (cmdtext[idx] <= ' '))
				{
					idx++;
				}
				new offset = idx;
				new result[256];
				while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
				{
					result[idx - offset] = cmdtext[idx];
					idx++;
				}
				result[idx - offset] = EOS;
				if(!strlen(result))
				{
					SendClientMessage(playerid, COLOR_WHITE, "USAGE: /cnnn <type> [cnnc textformat ~n~=Newline ~r~=Red ~g~=Green ~b~=Blue ~w~=White ~y~=Yellow]");
					return 1;
				}
				format(string, sizeof(string), "~w~%s",result);
				for(new i = 0; i < MAX_PLAYERS; i++)
				{
				    GameTextForPlayer(i, string, 5000, txtid);
				}
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
				return 1;
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/sban", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /sban [Playerid/PartOfName] [reason]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 2)
			{
			    if(IsPlayerConnected(giveplayerid))
			    {
			        if(giveplayerid != INVALID_PLAYER_ID)
			        {
					    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
				        {
							PlayerInfo[playerid][pBanned] = 1;
							format(string, sizeof(string), "AdmCmd: %s was banned, reason: Attempting to ban a higher level admin", PlayerName(playerid));
							SendClientMessageToAll(COLOR_LIGHTRED, string);
							BanEx(playerid, "Attempting to ban a higher level admin");
							return 1;
				        }
						new length = strlen(cmdtext);
						while ((idx < length) && (cmdtext[idx] <= ' '))
						{
							idx++;
						}
						new offset = idx;
						new result[256];
						while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
						{
							result[idx - offset] = cmdtext[idx];
							idx++;
						}
						result[idx - offset] = EOS;
						if(!strlen(result))
						{
							SendClientMessage(playerid, COLOR_WHITE, "USAGE: /sban [Playerid/PartOfName] [reason]");
							return 1;
						}
						PlayerInfo[giveplayerid][pBanned] = 1;
						BanEx(giveplayerid, (result));
						return 1;
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/skick", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /skick [Playerid/PartOfName]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 2)
			{
				if(IsPlayerConnected(giveplayerid))
				{
				    if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
				    {
				        format(string, sizeof(string), "AdmCmd: %s was kicked, reason: Attempting to kick a higher level admin", PlayerName(playerid));
				        SendClientMessageToAll(COLOR_LIGHTRED, string);
				        Kick(playerid);
				        return 1;
				    }
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
				        Kick(giveplayerid);
				    }
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/mute", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_DBLUE, "USAGE: /mute [Playerid/PartOfName]");
				return 1;
			}
			new playa;
			playa = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(PlayerInfo[playa][pAdmin] > PlayerInfo[playerid][pAdmin])
			        {
				       SendClientMessage(playerid, COLOR_GREY, "You can't mute higher level Admins !");
				       return 1;
			        }
			        if(playa != INVALID_PLAYER_ID)
			        {
						if(PlayerInfo[playa][pMuted] == 0)
						{
							PlayerInfo[playa][pMuted] = 1;
							format(string, sizeof(string), "AdmCmd: %s was silenced by %s",PlayerName(playa) , PlayerName(playerid));
							ABroadCast(COLOR_LIGHTRED,string,1);
						}
						else
						{
							PlayerInfo[playa][pMuted] = 0;
							format(string, sizeof(string), "AdmCmd: %s was unsilenced by %s",PlayerName(playa) , PlayerName(playerid));
							ABroadCast(COLOR_LIGHTRED,string,1);
						}
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin Dont use admincmd!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/jail", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /jail [Playerid/PartOfName] [minutes] [reason]");
				return 1;
			}
			new playa;
			new money;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			money = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 3)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(PlayerInfo[playa][pAdmin] > PlayerInfo[playerid][pAdmin])
			        {
				       SendClientMessage(playerid, COLOR_GREY, "You can't jail higher level Admins !");
				       return 1;
			        }
			        if(playa != INVALID_PLAYER_ID)
			        {
				        GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						new length = strlen(cmdtext);
						while ((idx < length) && (cmdtext[idx] <= ' '))
						{
							idx++;
						}
						new offset = idx;
						new result[64];
						while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
						{
							result[idx - offset] = cmdtext[idx];
							idx++;
						}
						result[idx - offset] = EOS;
						if(!strlen(result))
						{
							SendClientMessage(playerid, COLOR_WHITE, "USAGE: /jail [Playerid/PartOfName] [minutes] [reason]");
							return 1;
						}
						ResetPlayerWeaponsEx(playa);
						PlayerInfo[playa][pJail] = 1;
						PlayerInfo[playa][pJailTime] = money*60;
						SetPlayerInterior(playa, 6);
				        for(new i = 0; i < MAX_PLAYERS; i++)
	                    {
	                        SetPlayerMarkerForPlayer(i, playa, TEAM_HIT_COLOR);
	                    }
						SetPlayerPos(playa, 264.6288,77.5742,1001.0391);
						format(string, sizeof(string), "You are jailed for %d minutes.", money);
						SendClientMessage(playa, COLOR_LIGHTBLUE, string);
						format(string, 256, "AdmCmd: %s has been jailed by an Admin, Reason: %s", giveplayer, (result));
						SendClientMessageToAll(COLOR_LIGHTRED,string);
						format(string, sizeof(string), "AdmCmd: %s has been jailed by %s, Reason: %s", giveplayer, PlayerName(playerid), (result));
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/mark", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 3)
			{
				GetPlayerPos(playerid, TeleportDest[playerid][0],TeleportDest[playerid][1],TeleportDest[playerid][2]);
				SendClientMessage(playerid, COLOR_GRAD1, "   Teleporter destination set");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/gotomark", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 3)
			{
				if (GetPlayerState(playerid) == 2)
				{
					new tmpcar = GetPlayerVehicleID(playerid);
					SetVehiclePos(tmpcar, TeleportDest[playerid][0],TeleportDest[playerid][1],TeleportDest[playerid][2]);
					TelePos[playerid][0] = 0.0;TelePos[playerid][1] = 0.0;
				}
				else
				{
					SetPlayerPos(playerid, TeleportDest[playerid][0],TeleportDest[playerid][1],TeleportDest[playerid][2]);
				}
				SendClientMessage(playerid, COLOR_GRAD1, "   You have been teleported");
				SetPlayerInterior(playerid, 0);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/fine", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /fine [Playerid/PartOfName] [amount] [reason]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] > 3)
			{
			    if(IsPlayerConnected(giveplayerid))
			    {
			        if(giveplayerid != INVALID_PLAYER_ID)
			        {
					    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						new fine;
						tmp = strtok(cmdtext, idx);
						if (!strlen(tmp))
						{
						SendClientMessage(playerid, COLOR_WHITE, "USAGE: /fine [Playerid/PartOfName] [amount] [reason]");
						return 1;
						}
						fine = strval(tmp);
						if (fine < 0)
						{
							SendClientMessage(playerid, COLOR_GRAD2, "Amount must be greater than 0");
							return 1;
						}
						new length = strlen(cmdtext);
						while ((idx < length) && (cmdtext[idx] <= ' '))
						{
							idx++;
						}
						new offset = idx;
						new result[256];
						while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
						{
							result[idx - offset] = cmdtext[idx];
							idx++;
						}
						result[idx - offset] = EOS;
						if(!strlen(result))
						{
							SendClientMessage(playerid, COLOR_WHITE, "USAGE: /fine [Playerid/PartOfName] [amount] [reason]");
							return 1;
						}
						format(string, sizeof(string), "AdmCmd: %s was fined $%d by an Admin, reason: %s", giveplayer, fine, (result));
						SendClientMessageToAll(COLOR_LIGHTRED, string);
						GivePlayerCash(giveplayerid, -fine);
						return 1;
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/bring", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /bring [Playerid/PartOfName]");
				return 1;
			}
			new Float:plocx,Float:plocy,Float:plocz;
			new plo;
			plo = ReturnUser(tmp);
			if (IsPlayerConnected(plo))
			{
			    if(plo != INVALID_PLAYER_ID)
			    {
					if (PlayerInfo[plo][pAdmin] > 1337)
					{
						SendClientMessage(playerid, COLOR_GRAD1, "Ask the admin to goto you.");
						return 1;
					}
					if (PlayerInfo[playerid][pAdmin] >= 3)
					{
						GetPlayerPos(playerid, plocx, plocy, plocz);
						SetPlayerVirtualWorld(plo, GetPlayerVirtualWorld(playerid));
						SetPlayerInterior(plo, GetPlayerInterior(playerid));
						if (GetPlayerState(plo) == 2)
						{
							TelePos[plo][0] = 0.0;
							TelePos[plo][1] = 0.0;
							new tmpcar = GetPlayerVehicleID(plo);
							SetVehiclePos(tmpcar, plocx, plocy+4, plocz);
						}
						else
						{
							SetPlayerPos(plo,plocx,plocy+2, plocz);
						}
						SendClientMessage(plo, COLOR_GRAD1, "   You have been teleported");
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", plo);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/disarm", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /disarm [Playerid/PartOfName]");
				return 1;
			}
			new playa;
			playa = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 3)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
                        GetPlayerName(playa, giveplayer, sizeof(giveplayer));
                        ResetPlayerWeapons(playa);
                        ResetPlayerWeaponsEx(playa);
			            format(string, sizeof(string), "You have taken all weapons from %s.", giveplayer);
						SendClientMessage(playerid, COLOR_WHITE, string);
						SendClientMessage(playa, COLOR_YELLOW, "You have been disarmed by an Admin");
					}
				}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/goto", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
		    if (PlayerInfo[playerid][pAdmin] >= 1)
			{
			new x_job[256];
			x_job = strtok(cmdtext, idx);
			if(!strlen(x_job)) {
				SendClientMessage(playerid, COLOR_WHITE, "|_________________________|");
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /goto [name]");
				SendClientMessage(playerid, COLOR_GREY, "Locations 1: LS, SF, LV");
				SendClientMessage(playerid, COLOR_WHITE, "|_________________________|");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
            if(strcmp(x_job,"ls",true) == 0)
            {
			    if (GetPlayerState(playerid) == 2)
				{
					new tmpcar = GetPlayerVehicleID(playerid);
					SetVehiclePos(tmpcar, 1538.8336,-1691.1599,13.5469);
					TelePos[playerid][0] = 0.0;TelePos[playerid][1] = 0.0;
				}
				else
				{
					SetPlayerPos(playerid, 1538.8336,-1691.1599,13.5469);
				}
				SendClientMessage(playerid, COLOR_GRAD1, "   You have been teleported !");
				SetPlayerInterior(playerid, 0);
			}
			else if(strcmp(x_job,"sf",true) == 0)
            {
			    if (GetPlayerState(playerid) == 2)
				{
					new tmpcar = GetPlayerVehicleID(playerid);
					SetVehiclePos(tmpcar, -1417.0,-295.8,14.1);
					TelePos[playerid][0] = 0.0;TelePos[playerid][1] = 0.0;
				}
				else
				{
					SetPlayerPos(playerid, -1417.0,-295.8,14.1);
				}
				SendClientMessage(playerid, COLOR_GRAD1, "   You have been teleported");
				SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
			}
			else if(strcmp(x_job,"lv",true) == 0)
			{
                if (GetPlayerState(playerid) == 2)
				{
					new tmpcar = GetPlayerVehicleID(playerid);
					SetVehiclePos(tmpcar, 1699.2, 1435.1, 10.7);
					TelePos[playerid][0] = 0.0;TelePos[playerid][1] = 0.0;
				}
				else
				{
					SetPlayerPos(playerid, 1699.2,1435.1, 10.7);
				}
				SendClientMessage(playerid, COLOR_GRAD1, "   You have been teleported");
				SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
			}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/ipcheck", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /ipcheck [Playerid/PartOfName]");
				return 1;
			}
			new playa;
			playa = ReturnUser(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 3)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
                        GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						new ip[20];
			            GetPlayerIp(playa,ip,sizeof(ip));
			            format(string, sizeof(string), "%s's IP: %s\n", giveplayer, ip);
						SendClientMessage(playerid, COLOR_WHITE, string);
					}
				}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/sethp", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /sethp [Playerid/PartOfName] [health]");
				return 1;
			}
			new playa;
			new health;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /sethp [Playerid/PartOfName] [health]");
				return 1;
			}
			health = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
				        SetPlayerHealth(playa, health);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/setarmor", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setarmor [Playerid/PartOfName] [armor]");
				return 1;
			}
			new playa;
			new health;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setarmor [Playerid/PartOfName] [armor]");
				return 1;
			}
			health = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
						SetPlayerArmour(playa, health);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/sethpall", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /sethpall [health]");
				return 1;
			}
			new health;
			health = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
                for(new i = 0; i < MAX_PLAYERS; i++)
	            {
					SetPlayerHealth(i, health);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/setarmorall", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setarmorall [armor]");
				return 1;
			}
			new health;
			health = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
			    for(new i = 0; i < MAX_PLAYERS; i++)
	            {
					SetPlayerArmour(i, health);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/setmoney", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setmoney [Playerid/PartOfName] [money]");
				return 1;
			}
			new playa;
			new money;
			new plname[MAX_PLAYER_NAME];
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			money = strval(tmp);
			GetPlayerName(playa, plname, sizeof(plname));
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
						SetPlayerCash(playa, money);
						format(string, sizeof(string), "You have set %s's money to $%d !", plname, money);
				        SendClientMessage(playerid, COLOR_GREY, string);
					}
				}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/givemoney", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /givemoney [Playerid/PartOfName] [money]");
				return 1;
			}
			new playa;
			new money;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			money = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
			    if(IsPlayerConnected(playa))
			    {
			        if(playa != INVALID_PLAYER_ID)
			        {
						GivePlayerCash(playa, money);
					}
				}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/unban", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        new string2[256];
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /unban [name]");
				SendClientMessage(playerid, COLOR_GREY, "Full name, this includes underscores. Also CaSe sEnSiTiVe.");
				return 1;
			}
			if (PlayerInfo[playerid][pAdmin] >= 4)
			{
			    format(string, sizeof(string), "%s.ini",tmp);
	    	    if(dini_Exists(string))
	    	    {
	    	        if(dini_Int(string, "Banned") > 0)
	    	        {
	        		    dini_IntSet(string, "Banned", 0);
	        		    dini_IntSet(string, "Warnings", 0);
            		    string2 = dini_Get(string, "IP");
            		    format(string, sizeof(string), "unbanip %s", string2);
            		    SendRconCommand(string);
            		    SendRconCommand("reloadbans");
            		    format(string, 256, "AdmCmd: %s was unbanned by %s.",tmp, PlayerName(playerid));
                        ABroadCast(COLOR_LIGHTRED, string, 1);
            		    return 1;
            	    }
            	    else
            	    {
            	        SendClientMessage(playerid, COLOR_GRAD2, "That player is not banned.");
            	        string2 = dini_Get(string, "IP");
            		    format(string, sizeof(string), "unbanip %s", string2);
            		    SendRconCommand(string);
            		    SendRconCommand("reloadbans");
            		    return 1;
            	    }
	    	    }
	    	    else
	    	    {
	        	    SendClientMessage(playerid, COLOR_GRAD2, "   Invalid name !");
	    	    }
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/rangeban", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        new string2[256];
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /rangeban [name]");
				SendClientMessage(playerid, COLOR_GREY, "Full name, this includes underscores. Also CaSe sEnSiTiVe.");
				return 1;
			}
			if (PlayerInfo[playerid][pAdmin] >= 3)
			{
			    format(string, sizeof(string), "%s.ini",tmp);
	    	    if(dini_Exists(string))
	    	    {
	        	    dini_IntSet(string, "Banned", 1);
            		string2 = dini_Get(string, "IP");
            		format(string, sizeof(string), "banip %s", string2);
            		SendRconCommand(string);
            		SendRconCommand("reloadbans");
            		format(string, 256, "AdmCmd: %s was rangebanned by %s.",tmp, PlayerName(playerid));
                    ABroadCast(COLOR_LIGHTRED, string, 1);
            		return 1;
	    	    }
	    	    else
	    	    {
	        	    SendClientMessage(playerid, COLOR_GRAD2, "   Invalid name !");
	    	    }
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/veh", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if (PlayerInfo[playerid][pAdmin] < 4)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			    return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /veh [carid] [color1] [color2]");
				return 1;
			}
			new car;
			car = strval(tmp);
			if(car < 400 || car > 611) { SendClientMessage(playerid, COLOR_GREY, "   Vehicle Number can't be below 400 or above 611 !"); return 1; }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /veh [carid] [color1] [color2]");
				return 1;
			}
			new color1;
			color1 = strval(tmp);
			if(color1 < 0 || color1 > 126) { SendClientMessage(playerid, COLOR_GREY, "   Color Number can't be below 0 or above 126 !"); return 1; }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /veh [carid] [color1] [color2]");
				return 1;
			}
			new color2;
			color2 = strval(tmp);
			if(color2 < 0 || color2 > 126) { SendClientMessage(playerid, COLOR_GREY, "   Color Number can't be below 0 or above 126 !"); return 1; }
			new Float:X,Float:Y,Float:Z;
			GetPlayerPos(playerid, X,Y,Z);
			new carid = CreateVehicle(car, X,Y,Z, 0.0, color1, color2, -1);
			LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
			SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid));
			CreatedCars[CreatedCar] = carid;
			CreatedCar ++;
			format(string, sizeof(string), "   Vehicle %d spawned.", carid);
			SendClientMessage(playerid, COLOR_GREY, string);
		}
		return 1;
	}
	if(strcmp(cmd, "/fixveh", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(PlayerInfo[playerid][pAdmin] < 4)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			    return 1;
			}
			if(IsPlayerInAnyVehicle(playerid))
			{
			    SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
			    RepairVehicle(GetPlayerVehicleID(playerid));
			    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			    SendClientMessage(playerid, COLOR_GREY, "   Vehicle Fixed !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/destroycar", true)== 0)
	{
	    if(PlayerInfo[playerid][pAdmin] > 1)
	    {
	        new removeVeh = GetPlayerVehicleID(playerid);
            SendClientMessage(playerid, COLOR_GRAD1, "You have destoyed the vehicle.");
            DestroyVehicle(removeVeh);
	        return 1;
		}
		else
		{
            SendClientMessage(playerid, COLOR_GRAD1, "You are not an Admin");
		}
	}
    if(strcmp(cmd, "/destroycars", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(PlayerInfo[playerid][pAdmin] < 4)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "   you are not authorized to use that command!");
			    return 1;
			}
			for(new i = 0; i < CreatedCar; i++)
    	    {
			    DestroyVehicle(CreatedCars[i]);
			}
			CreatedCar = 0;
			SendClientMessage(playerid, COLOR_GREY, "   Created Vehicles destroyed!");
		}
		return 1;
	}
	if(strcmp(cmd, "/givegun", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if(PlayerInfo[playerid][pAdmin] < 4)
            {
              SendClientMessage(playerid, COLOR_GREY, "You are not authorised to use that command !");
              return 1;
            }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /givegun [Playerid/PartOfName] [weaponid]");
				return 1;
			}
			new giveplayerid2;
			new gun;
			giveplayerid2 = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			gun = strval(tmp);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /givegun [Playerid/PartOfName] [weaponid]");
				SendClientMessage(playerid, COLOR_GREEN, "___________________________________________");
				SendClientMessage(playerid, COLOR_GRAD2, "1: Brass Knuckles 2: Golf Club 3: Nite Stick 4: Knife 5: Baseball Bat 6: Shovel 7: Pool Cue 8: Katana 9: Chainsaw");
				SendClientMessage(playerid, COLOR_GRAD2, "10: Purple Dildo 11: Small White Vibrator 12: Large White Vibrator 13: Silver Vibrator 14: Flowers 15: Cane 16: Frag Grenade");
				SendClientMessage(playerid, COLOR_GRAD2, "17: Tear Gas 18: Molotov Cocktail 19: Vehicle Missile 20: Hydra Flare 21: Jetpack 22: 9mm 23: Silenced 9mm 24: Desert Eagle");
				SendClientMessage(playerid, COLOR_GRAD2, "25: Shotgun 26: Sawnoff Shotgun 27: Combat Shotgun 28: Micro SMG (Mac 10) 29: SMG (MP5) 29: AK-47 31: M4 32: Tec-9) 33: Country Rifle");
				SendClientMessage(playerid, COLOR_GRAD2, "34: Sniper Rifle 35: Rocket Launcher 36: HS Rocket Launcher 37: Flamethrower 38: Minigun 39: Satchel Charge 40: Detonator");
				SendClientMessage(playerid, COLOR_GRAD2, "41: Spraycan 42: Fire Extinguisher 43: Camera 44: Nightvision Goggles 45: Infared Vision 46: Parachute");
				SendClientMessage(playerid, COLOR_GREEN, "___________________________________________");
				return 1;
			}
			if (gun > 1||gun < 47)
			{
			    if(IsPlayerConnected(giveplayerid2))
			    {
			        if(giveplayerid2 != INVALID_PLAYER_ID)
			        {
			            if(gun == 21)
			            {
			                SetPlayerSpecialAction(giveplayerid2, SPECIAL_ACTION_USEJETPACK);
			                format(string, sizeof(string), "  You have given a Jetpack to %s", PlayerName(giveplayerid2));
			                SendClientMessage(playerid, COLOR_GRAD2, string);
			                return 1;
			            }
			            new weaponname[32];
			            GetWeaponName(gun, weaponname, sizeof(weaponname));
			            GivePlayerGun(giveplayerid2, gun);
			            format(string, sizeof(string), "  You have given a %s to %s", weaponname, PlayerName(giveplayerid2));
			            SendClientMessage(playerid, COLOR_GRAD2, string);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD2, "You have selected an invalid Gun ID.");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/weather", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(PlayerInfo[playerid][pAdmin] < 1337)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			    return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: /weather [weatherid]");
			    return 1;
			}
			new weather;
			weather = strval(tmp);
			if(weather < 0||weather > 45) { SendClientMessage(playerid, COLOR_GREY, "   Weather ID can't be below 0 or above 45 !"); return 1; }
			SetPlayerWeather(playerid, weather);
			SendClientMessage(playerid, COLOR_GREY, "   Weather Set !");
		}
		return 1;
	}
	if(strcmp(cmd, "/weatherall", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(PlayerInfo[playerid][pAdmin] < 1337)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			    return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: /weatherall [weatherid]");
			    return 1;
			}
			new weather;
			weather = strval(tmp);
			if(weather < 0||weather > 45) { SendClientMessage(playerid, COLOR_GREY, "   Weather ID can't be below 0 or above 45 !"); return 1; }
			SetWeather(weather);
			SendClientMessage(playerid, COLOR_GREY, "   Weather Set to everyone !");
		}
		return 1;
	}
	if(strcmp(cmd, "/setlevel", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setlevel [Playerid/PartOfName] [level(1-5)]");
				return 1;
			}
			new para1;
			new level;
			para1 = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			level = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
			    if(IsPlayerConnected(para1))
			    {
			        if(para1 != INVALID_PLAYER_ID)
			        {
						GetPlayerName(para1, giveplayer, sizeof(giveplayer));
						PlayerInfo[para1][pAdmin] = level;
						format(string, sizeof(string), "* You have been promoted to a level %d admin by %s", level, PlayerName(playerid));
						SendClientMessage(para1, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* You have promoted %s to a level %d admin.", giveplayer,level);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/makevip", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /makedonator [Playerid/PartOfName] [donate rank]");
				return 1;
			}
			new para1;
			new level;
			para1 = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			level = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
			    if(IsPlayerConnected(para1))
			    {
			        if(para1 != INVALID_PLAYER_ID)
			        {
						GetPlayerName(para1, giveplayer, sizeof(giveplayer));
						PlayerInfo[para1][pDonateRank] = level;
						format(string, sizeof(string), "* Admin %s has made you a %d level Donator", level, PlayerName(playerid));
						SendClientMessage(para1, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* You have promoted %s to a level %d Donator.", giveplayer,level);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/tod", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /tod [0-23]");
				return 1;
			}
			new hour;
			hour = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
	            SetWorldTime(hour);
				format(string, sizeof(string), "   Time set to %d Hours.", hour);
				SendClientMessageToAll(COLOR_GRAD1, string);
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not an Admin !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/savechars", true) == 0)
	{
		if (PlayerInfo[playerid][pAdmin] >= 1337)
		{
			SendClientMessage(playerid, COLOR_YELLOW, "All player accounts updated successfully.");
			SaveAccounts();
		}
		else
		{
			SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use that command !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gotocar", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /gotocar [carid]");
				return 1;
			}
			new testcar = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
				new Float:cwx2,Float:cwy2,Float:cwz2;
				GetVehiclePos(testcar, cwx2, cwy2, cwz2);
				if (GetPlayerState(playerid) == 2)
				{
					new tmpcar = GetPlayerVehicleID(playerid);
					SetVehiclePos(tmpcar, cwx2, cwy2, cwz2);
					TelePos[playerid][0] = 0.0;TelePos[playerid][1] = 0.0;
				}
				else
				{
					SetPlayerPos(playerid, cwx2, cwy2, cwz2);
				}
				SendClientMessage(playerid, COLOR_GRAD1, "   You have been teleported");
				SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Admin!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/setname", true) == 0)
	{
		new tmpp[32];
		tmpp = strtok(cmdtext, idx);
		if(!strlen(tmpp))
		{
			SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setname [Playerid/PartOfName] [Name]");
			return 1;
		}
		new string2[32];
		giveplayerid = ReturnUser(tmpp);
		tmp = strtok(cmdtext, idx);
		if(IsPlayerConnected(playerid))
		{
		    if(PlayerInfo[playerid][pAdmin] >= 4)
		    {
		        format(string, sizeof(string), "%s.ini", tmp);
                if(fexist(string))
		        {
			        SendClientMessage(playerid, COLOR_GRAD2, "   That Name is registered !");
			        return 1;
		        }
		        if(IsPlayerConnected(giveplayerid))
		        {
				    format(string, sizeof(string), "%s.ini", PlayerName(giveplayerid));
				    dini_Remove(string);
				    format(string2, sizeof(string2), "%s.ini", tmp);
				    dini_Create(string2);
				    SetPlayerName(giveplayerid, tmp);
					format(string, sizeof(string), "You have set %s's name to %s", PlayerName(giveplayerid), tmp);
					SendClientMessage(playerid, COLOR_GREY, string);
					format(string, sizeof(string), "Your name has been changed from %s to %s", PlayerName(giveplayerid), tmp);
					SendClientMessage(giveplayerid, COLOR_YELLOW, string);
				}
				else
				{
				    format(string, sizeof(string), "%d is not an active player.", giveplayerid);
					SendClientMessage(playerid, COLOR_GRAD2, string);
				}
			}
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "You Must be logged in to use this command!");
		}
	  	return 1;
	}
	if(strcmp(cmd, "/gmx", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
				GameModeExit();
			}
		}
		return 1;
	}
//===============================[General]======================================
    if(strcmp(cmd, "/changepass", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (gPlayerLogged[playerid])
			{
				new length = strlen(cmdtext);
				while ((idx < length) && (cmdtext[idx] <= ' '))
				{
					idx++;
				}
				new offset = idx;
				new result[256];
				while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
				{
					result[idx - offset] = cmdtext[idx];
					idx++;
				}
				result[idx - offset] = EOS;
				if(!strlen(result))
				{
					SendClientMessage(playerid, COLOR_WHITE, "USAGE: /changepass [newpass]");
					return 1;
				}
				if(strfind( result , "," , true ) == -1)
    			{
		   			strmid(PlayerInfo[playerid][pKey], (result), 0, strlen((result)), 255);
					format(string, sizeof(string), "You have set your password to: %s.", (result));
					SendClientMessage(playerid, COLOR_WHITE, string);
				}
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "Invalid Symbol , is not allowed!");
				}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/report", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[256];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /report [Playerid][Reason]");
				return 1;
			}
			format(string, sizeof(string), "Report from: [%d]%s: %s", playerid, PlayerName(playerid), (result));
			ABroadCast(COLOR_YELLOW2,string,1);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "Your Report Message was sent to the Admins.");
	    }
	    return 1;
	}
	if (strcmp(cmd, "/kill", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    SetPlayerHealth(playerid, 0);
		}
		return 1;
	}
	if (strcmp(cmd, "/id", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /id [Playerid/PartOfName]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
				{
 				    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
					format(string, 256, "Name: %s, ID: %d",giveplayer, giveplayerid);
					SendClientMessage(playerid, COLOR_WHITE, string);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   No Such Player !");
			}
		}
		return 1;
	}
	if (strcmp(cmd, "/lotto", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /lotto [1-60]");
				return 1;
			}
			new lottonr = strval(tmp);
			if(lottonr < 1 || lottonr > 60) return SendClientMessage(playerid, COLOR_GRAD2, " Lotto number not below 1 or above 60.");
			PlayerInfo[playerid][pLotto] = lottonr;
			format(string, sizeof(string), "* You bought a lottery ticket with the number: %d.", lottonr);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			GivePlayerCash(playerid, -2000);
			return 1;
		}
		return 1;
	}
	if (strcmp(cmd, "/joinevent", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    switch (Event)
		    {
		        case 0: SendClientMessage(playerid, COLOR_GRAD2, " There is no event started yet.");
		        case 1:
		        {
		            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GRAD2, " You must be on foot in order to join this event.");
		            SendClientMessage(playerid, COLOR_LIGHTBLUE, "* You took part to the Parkour Event.");
		            SendClientMessage(playerid, COLOR_WHITE, "You will stay freezed until some players join the event.");
		            SetPlayerInterior(playerid, 0);
		            SetPlayerPos(playerid, 2163.5959, -1059.7662, 63.4219);
		            SetPlayerFacingAngle(playerid, 47);
		            TogglePlayerControllable(playerid, 0);
		            SetCameraBehindPlayer(playerid);
		            PlayerInEvent[playerid] = 1;
		            EventPlayers ++;
		            ResetPlayerWeapons(playerid);
		        }
		        case 2:
		        {
		            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GRAD2, " You must be on foot in order to join this event.");
		            SendClientMessage(playerid, COLOR_LIGHTBLUE, "* You took part to the Derby Event.");
		            SendClientMessage(playerid, COLOR_WHITE, "You will stay freezed until some players join the event.");
		            SetPlayerInterior(playerid, 15);
		            new rand = random(sizeof(gDerbySpawn));
			        SetPlayerPos(playerid, gDerbySpawn[rand][0], gDerbySpawn[rand][1], gDerbySpawn[rand][2]);
			        SetPlayerFacingAngle(playerid, gDerbySpawn[rand][3]);
		            TogglePlayerControllable(playerid, 0);
		            SetCameraBehindPlayer(playerid);
		            PlayerInEvent[playerid] = 2;
		            EventPlayers ++;
		            ResetPlayerWeapons(playerid);
		        }
		    }
		}
		return 1;
	}
	if (strcmp(cmd, "/bounties", true) == 0)
	{
	    new count = 0;
	    SendClientMessage(playerid, COLOR_YELLOW2,"|_______________Current Bounties________________|");
	    for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
				if(Bounty[i] > 0)
				{
					format(string, sizeof(string), "Name: %s ID: %d Head Price: $%d.", PlayerName(i), i, Bounty[i]);
					SendClientMessage(playerid, COLOR_WHITE, string);
					count++;
				}
			}
		}
	    if(count == 0) SendClientMessage(playerid, COLOR_GRAD2, "There are no bounties founded yet.");
	    SendClientMessage(playerid, COLOR_YELLOW2,"|_______________________________________________|");
        return 1;
    }
    if(strcmp(cmd, "/givebounty", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /givebounty [Playerid/PartOfName] [price]");
				return 1;
			}
	        giveplayerid = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /givebounty [Playerid/PartOfName] [price]");
				return 1;
			}
			moneys = strval(tmp);
			if (IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
					playermoney = GetPlayerCash(playerid);
					if (moneys > 0 && playermoney >= moneys)
					{
						GivePlayerCash(playerid, (0 - moneys));
						format(string, sizeof(string), " You have given %s a bounty of %d.", PlayerName(giveplayerid), moneys);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						Bounty[giveplayerid] += moneys;
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "   Invalid transaction amount.");
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
    if(strcmp(cmd, "/admins",true)==0)
	{
	    SendClientMessage(playerid, COLOR_YELLOW, "Current Admin List:");
		if(IsPlayerConnected(playerid))
		{
		    for(new i = 0; i < MAX_PLAYERS; i++)
			{
			    if(IsPlayerConnected(i))
			    {
			        if(PlayerInfo[i][pAdmin] >= 1 && PlayerInfo[i][pHide] == 0)
					{
					    format(string, sizeof(string), "Admin: %s, Level: [%d]",PlayerName(i),PlayerInfo[i][pAdmin]);
					    SendClientMessage(playerid, COLOR_YELLOW2, string);
					}
			    }
			}
			return 1;
		}
	}
	if(strcmp(cmd, "/hitman",true)==0)
	{
		if(IsPlayerConnected(playerid))
		{
		    if(PlayerInfo[playerid][pKills] > 499 || PlayerInfo[playerid][pDonateRank] > 0)
		    {
		        IsHitman[playerid] = 1;
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "You are a hitman now, your mission is to kill those with a bounty on their heads.");
		        SendClientMessage(playerid, COLOR_WHITE, "HINT: You can see the bounties on the map (Red Icons), type /bounties for more info.");
		        for(new i = 0; i < MAX_PLAYERS; i++)
			    {
			        if(IsPlayerConnected(i))
			        {
			            if(Bounty[i] > 0)
					    {
					        SetPlayerMarkerForPlayer(i, playerid, 0xEA0000FF);
					    }
			        }
			    }
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GRAD2, " You need at least 500 Kills to be a hitman.");
			}
			return 1;
		}
	}
	if(!strcmp(cmdtext,"/turfhelp",true))
	{
	    SendClientMessage(playerid, COLOR_ORANGE,"====================[ Turf Help ]===========================");
	    SendClientMessage(playerid, COLOR_WHITE,"3 kills starts a gang war, if the player is in his own zone");
	    SendClientMessage(playerid, COLOR_WHITE,"Remember: A player must be in his own turf for you to take it");
	    SendClientMessage(playerid, COLOR_WHITE,"Over 3 Player must be standing for 20 in an enemy area to provoke a war");
	    SendClientMessage(playerid, COLOR_WHITE,"To win the turf or to defend it, you need to wait 3 minutes.");
        return 1;
    }
    if (strcmp(cmd, "/teamstats", true) == 0)
	{
	    tmp = strtok(cmdtext, idx);
		if (!strlen(tmp))
		{
			for (new i = 0; i < MAX_TURFS; i++)
			{
                 new msg[256];
                 new turf = OwnedTurfs() * 100;
	             new maxturf = turf / MAX_TURFS;
                 format(msg, sizeof(msg), "~w~%s stats:~n~~g~Turfwars Won: %d~n~~r~Turfwars Lost: %d~n~~w~Rivals killed: %d~n~Homies lost: %d~n~~y~Turfs: %d~n~~w~Own: %d%% of LS~n~~w~Teamscore: %d",
		         TeamInfo[gTeam[playerid]][TeamName], TeamInfo[gTeam[playerid]][TurfWarsWon],
				 TeamInfo[gTeam[playerid]][TurfWarsLost], TeamInfo[gTeam[playerid]][RivalsKilled],
				 TeamInfo[gTeam[playerid]][HomiesDied], OwnedTurfs(), maxturf, TeamInfo[gTeam[playerid]][TeamScore]);
                 new Text:txt = TextDrawCreate( 33.0, 259.0, msg);
				 TextDrawUseBox(txt, 1);
				 TextDrawBoxColor(txt, 0x00000066);
				 TextDrawTextSize(txt, 141.0, 0.0);
				 TextDrawAlignment(txt, 0);
				 TextDrawBackgroundColor(txt, 0x000000ff);
				 TextDrawFont(txt, 1);
				 TextDrawLetterSize(txt, 0.29, 1.0);
				 TextDrawColor(txt, 0xffffffff);
				 TextDrawSetOutline(txt, 1);
				 TextDrawSetProportional(txt, 1);
				 TextDrawSetShadow(txt, 1);
                 TimeTextForPlayer(playerid, txt, 6000);
	             return 1;
	        }
		}
        return 1;
    }
	if (strcmp(cmd, "/stats", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
 		    if (gPlayerLogged[playerid] != 0)
			{
				ShowStats(playerid, playerid);
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   You are not Logged in !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/pm", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(gPlayerLogged[playerid] == 0)
	        {
	            SendClientMessage(playerid, COLOR_GREY, "   You havent logged in yet!");
	            return 1;
	        }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /pm [playerid/PartOfName] [text]");
				return 1;
			}
			giveplayerid = strval(tmp);
			if (IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
					GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
					new length = strlen(cmdtext);
					while ((idx < length) && (cmdtext[idx] <= ' '))
					{
						idx++;
					}
					new offset = idx;
					new result[256];
					while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
					{
						result[idx - offset] = cmdtext[idx];
						idx++;
					}
					result[idx - offset] = EOS;
					if(!strlen(result))
					{
						SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /pm [playerid/PartOfName] [text]");
						return 1;
					}
					format(string, sizeof(string), "* PM from %s(ID: %d): %s", PlayerName(playerid), playerid, (result));
					SendClientMessage(giveplayerid, COLOR_YELLOW, string);
					format(string, sizeof(string), "* PM to %s(ID: %d): %s", giveplayer, giveplayerid, (result));
					SendClientMessage(playerid,  COLOR_YELLOW, string);
					return 1;
				}
			}
			else
			{
					format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
					SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/team", true) == 0 || strcmp(cmd, "/t", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(PlayerInfo[playerid][pMuted] != 0)
            {
                SendClientMessage(playerid, COLOR_ADMINCMD, " You are muted, you cannot speak.");
                return 1;
            }
			new length = strlen(cmdtext);
			new team = gTeam[playerid];
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[256];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/t)eam [team chat]");
				SendClientMessage(playerid, COLOR_GRAD2, "You can use '!' infront of your text to speak to your team.");
				return 1;
			}
			format(string, sizeof(string), "[TEAM] %s: %s", PlayerName(playerid), result);
			SendTeamMessage(team, COLOR_ADMINCMD, string);
		}
		return 1;
	}
	if(strcmp(cmd, "/rules",true)==0)
	{
		if(IsPlayerConnected(playerid))
		{
			SendClientMessage(playerid, COLOR_YELLOW2,"- Don't use hacks, Example: Health hack, Weapon Hack, etc.");
			SendClientMessage(playerid, COLOR_YELLOW2,"- Don't abuse the Server Bugs like C-Bug");
			SendClientMessage(playerid, COLOR_YELLOW2,"- Don't Spam the chat.");
			SendClientMessage(playerid, COLOR_YELLOW2,"- If you see a hacker /report him and don't tell his name in chat");
			SendClientMessage(playerid, COLOR_YELLOW2,"- Respect the Admins and all the players, No Racism");
			SendClientMessage(playerid, COLOR_YELLOW2,"-NO cbug allowed");
			return 1;
		}
	}
	if(strcmp(cmd, "/pay", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /pay [Playerid/PartOfName] [amount]");
				return 1;
			}
	        giveplayerid = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "USAGE: /pay [Playerid/PartOfName] [amount]");
				return 1;
			}
			moneys = strval(tmp);
			if(moneys < 1 || moneys > 100000)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "Dont go below 1$, or above 100,000$ at once.");
			    return 1;
			}
			if (IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
				    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
					playermoney = GetPlayerCash(playerid);
					if (moneys > 0 && playermoney >= moneys)
					{
						GivePlayerCash(playerid, (0 - moneys));
						GivePlayerCash(giveplayerid, moneys);
						format(string, sizeof(string), "   You have sent %s, $%d.", giveplayer, moneys);
						PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
						SendClientMessage(playerid, COLOR_GRAD1, string);
						format(string, sizeof(string), "   You have recieved $%d from %s.", moneys, PlayerName(playerid));
						SendClientMessage(giveplayerid, COLOR_GRAD1, string);
						PlayerPlaySound(giveplayerid, 1052, 0.0, 0.0, 0.0);
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "   Invalid transaction amount.");
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d is not an active player.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	return 0;
}
//==============================================================================
public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_SPAWNED)
	{
		gPlayerSpawned[playerid] = 1;
	}
	return 1;
}
//==============================================================================
public OnPlayerPickUpPickup(playerid, pickupid)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(pickupid == gPickupID[i])
        {
	        GivePlayerGun(playerid, gDropPickup[i]);
	        DestroyPickup(gPickupID[i]);
	    }
	}
	return 1;
}
//==============================================================================
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PlayerKilled[playerid] == 1)
    {
	    if(IsKeyJustDown(KEY_SPRINT,newkeys,oldkeys))
        {
	        TogglePlayerSpectating(playerid, 0);
	        PlayerSpectating[playerid] = 0;
	        PlayerKilled[playerid] = 0;
            TextDrawHideForPlayer(playerid, txtSpec);
        }
    }
//===============================[RC Vehicles]==================================
	new Float:x, Float:y, Float:z;
    if(newkeys == KEY_SECONDARY_ATTACK )
	{
		new VehicleSeat = GetPlayerVehicleSeat(playerid);
		if(VehicleSeat == -1)
		{
			for(new forvehicleid; forvehicleid < MAX_VEHICLES; forvehicleid++)
			{
				if(!IsVehicleRc(forvehicleid)) continue;
				GetVehiclePos(forvehicleid, x, y, z);
				if(IsPlayerInRangeOfPoint(playerid, 6, x, y, z))
				{
					PutPlayerInVehicle(playerid, forvehicleid, 0);
					break;
				}
			}
		}
		else if(VehicleSeat == 0)
		{
			if(IsVehicleRc(GetPlayerVehicleID(playerid)))
			{
				GetPlayerPos(playerid, x, y, z);
				SetPlayerPos(playerid, x+1, y, z+1.0);
			}
		}
	}
    if(newkeys == KEY_FIRE || newkeys == 12 || newkeys == 36)
	{
		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 564)
		{
			new Float:angle;
			GetPlayerPos(playerid,x,y,z);
			GetVehicleZAngle(GetPlayerVehicleID(playerid), angle);
			x += (30 * floatsin(-angle + 5, degrees));
			y += (30 * floatcos(-angle + 5, degrees));
			CreateExplosion(x,y,z,3,4.0);
		}
	}
	return 1;
}
//==============================================================================
public OnPlayerStreamIn(playerid, forplayerid)
{
    if(Bounty[playerid] > 0)
	{
	    SetPlayerMarkerForPlayer(playerid, forplayerid, 0xEA0000FF);
	}
	return 1;
}
//==============================================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new string[256];
	if(response)
	{
		if(dialogid == 12346 || dialogid == 12347)
		{
		    if(strlen(inputtext))
		    {
				new tmppass[64];
				strmid(tmppass, inputtext, 0, strlen(inputtext), 255);
				OnPlayerLogin(playerid,tmppass);
			}
			else
			{
				new loginstring[256];
				SendClientMessage(playerid, COLOR_WHITE, "SERVER: You must enter a password");
				format(loginstring,sizeof(loginstring),"Los Santos Gang Wars\nThat name is registered. please enter your password below");
		        ShowPlayerDialog(playerid,12347,DIALOG_STYLE_INPUT,"Login",loginstring,"Login","Exit");
			}
		}
		if(dialogid == 12345)
		{
		    if(strlen(inputtext))
		    {
				format(string, sizeof(string), "%s.ini", PlayerName(playerid));
                if(dini_Exists(string))
	            {
					SendClientMessage(playerid, COLOR_YELLOW, "That Username is already taken, please choose a different one.");
					return 1;
				}
				new tmppass[64];
				strmid(tmppass, inputtext, 0, strlen(inputtext), 255);
				OnPlayerRegister(playerid, tmppass);
			}
			else
			{
 				new regstring[256];
				format(regstring,sizeof(regstring),"Los Santos Gang Wars\nThat name is not registered. type your password below to register");
				ShowPlayerDialog(playerid,12345,DIALOG_STYLE_INPUT,"Register",regstring,"Register","Exit");
			}
		}
	}
	else
	{
		Kick(playerid);
	}
	return 1;
}
//==============================================================================
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
//=============================[Anti-Money Hack Functions]======================
stock GivePlayerCash(playerid, money)
{
	PlayerInfo[playerid][pCash] += money;
	ResetMoneyBar(playerid);
	UpdateMoneyBar(playerid,PlayerInfo[playerid][pCash]);
	return PlayerInfo[playerid][pCash];
}
stock SetPlayerCash(playerid, money)
{
	PlayerInfo[playerid][pCash] = money;
	ResetMoneyBar(playerid);
	UpdateMoneyBar(playerid,PlayerInfo[playerid][pCash]);
	return PlayerInfo[playerid][pCash];
}
stock ResetPlayerCash(playerid)
{
	PlayerInfo[playerid][pCash] = 0;
	ResetMoneyBar(playerid);
	UpdateMoneyBar(playerid,PlayerInfo[playerid][pCash]);
	return PlayerInfo[playerid][pCash];
}
stock GetPlayerCash(playerid)
{
	return PlayerInfo[playerid][pCash];
}
//==============================================================================
stock PlayerName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}
//==============================================================================
stock IsKeyJustDown(key, newkeys, oldkeys)
{
	if((newkeys & key) && !(oldkeys & key)) return 1;
	return 0;
}
//==============================================================================
public ABroadCast(color,const string[],level)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if (PlayerInfo[i][pAdmin] >= level)
			{
				SendClientMessage(i, color, string);
			}
		}
	}
	return 1;
}
//==============================================================================
public ResetPlayerWeaponsEx(playerid)
{
    PlayerInfo[playerid][pGun0] = 0;
    PlayerInfo[playerid][pGun1] = 0;
    PlayerInfo[playerid][pGun2] = 0;
    PlayerInfo[playerid][pGun3] = 0;
    PlayerInfo[playerid][pGun4] = 0;
    PlayerInfo[playerid][pGun5] = 0;
    PlayerInfo[playerid][pGun6] = 0;
    PlayerInfo[playerid][pGun7] = 0;
    PlayerInfo[playerid][pGun8] = 0;
    PlayerInfo[playerid][pGun9] = 0;
    PlayerInfo[playerid][pGun10] = 0;
    PlayerInfo[playerid][pGun11] = 0;
    PlayerInfo[playerid][pGun12] = 0;
	ResetPlayerWeapons(playerid);
	return 1;
}
//==============================================================================
public HaveWeapon(playerid, weaponid)
{
    if(IsPlayerConnected(playerid))
    {
        switch (weaponid)
        {
            case 1: return PlayerInfo[playerid][pGun0];
            case 2..9: return PlayerInfo[playerid][pGun1];
            case 10..15: return PlayerInfo[playerid][pGun10];
            case 16..18: return PlayerInfo[playerid][pGun8];
            case 22..24: return PlayerInfo[playerid][pGun2];
            case 25..27: return PlayerInfo[playerid][pGun3];
            case 28..29: return PlayerInfo[playerid][pGun4];
            case 30..31: return PlayerInfo[playerid][pGun5];
            case 32: return PlayerInfo[playerid][pGun4];
            case 33..34: return PlayerInfo[playerid][pGun6];
            case 35..38: return PlayerInfo[playerid][pGun7];
            case 39: return PlayerInfo[playerid][pGun8];
            case 41..43: return PlayerInfo[playerid][pGun9];
            case 44..46: return PlayerInfo[playerid][pGun11];
        }
    }
    return 1;
}
//==============================================================================
public RemovePlayerWeapon(playerid, weaponid)
{
    switch(weaponid)
    {
        case 1: PlayerInfo[playerid][pGun0] = 0;
        case 2..9: PlayerInfo[playerid][pGun1] = 0;
        case 10..15: PlayerInfo[playerid][pGun10] = 0;
        case 16..18, 39: PlayerInfo[playerid][pGun8] = 0;
        case 22..24: PlayerInfo[playerid][pGun2] = 0;
        case 25..27: PlayerInfo[playerid][pGun3] = 0;
        case 28, 29, 32: PlayerInfo[playerid][pGun4] = 0;
        case 30, 31: PlayerInfo[playerid][pGun5] = 0;
        case 33, 34: PlayerInfo[playerid][pGun6] = 0;
        case 35..38: PlayerInfo[playerid][pGun7] = 0;
        case 40: PlayerInfo[playerid][pGun12] = 0;
        case 41..43: PlayerInfo[playerid][pGun9] = 0;
        case 44..46: PlayerInfo[playerid][pGun11] = 0;
    }
	ResetPlayerWeapons(playerid);
	RestoreWeapons(playerid);
	return 1;
}
//==============================================================================
public RestoreWeapons(playerid)
{
    if(PlayerInfo[playerid][pGun0] == 1) GivePlayerWeapon(playerid, 1, 1);
    switch (PlayerInfo[playerid][pGun1])
    {
        case 2: GivePlayerWeapon(playerid, 2, 1);
        case 3: GivePlayerWeapon(playerid, 3, 1);
        case 4: GivePlayerWeapon(playerid, 4, 1);
        case 5: GivePlayerWeapon(playerid, 5, 1);
        case 6: GivePlayerWeapon(playerid, 6, 1);
        case 7: GivePlayerWeapon(playerid, 7, 1);
        case 8: GivePlayerWeapon(playerid, 8, 1);
        case 9: GivePlayerWeapon(playerid, 9, 1);
    }
    switch (PlayerInfo[playerid][pGun2])
    {
        case 22: GivePlayerWeapon(playerid, 22, 99999);
        case 23: GivePlayerWeapon(playerid, 23, 99999);
        case 24: GivePlayerWeapon(playerid, 24, 99999);
    }
    switch (PlayerInfo[playerid][pGun3])
    {
        case 25: GivePlayerWeapon(playerid, 25, 99999);
        case 26: GivePlayerWeapon(playerid, 26, 99999);
        case 27: GivePlayerWeapon(playerid, 27, 99999);
    }
    switch (PlayerInfo[playerid][pGun4])
    {
        case 28: GivePlayerWeapon(playerid, 28, 99999);
        case 29: GivePlayerWeapon(playerid, 29, 99999);
        case 32: GivePlayerWeapon(playerid, 32, 99999);
    }
    switch (PlayerInfo[playerid][pGun5])
    {
        case 30: GivePlayerWeapon(playerid, 30, 99999);
        case 31: GivePlayerWeapon(playerid, 31, 99999);
    }
    switch (PlayerInfo[playerid][pGun6])
    {
        case 33: GivePlayerWeapon(playerid, 33, 99999);
        case 34: GivePlayerWeapon(playerid, 34, 99999);
    }
    switch (PlayerInfo[playerid][pGun7])
    {
        case 35: GivePlayerWeapon(playerid, 35, 99999);
        case 36: GivePlayerWeapon(playerid, 36, 99999);
        case 37: GivePlayerWeapon(playerid, 37, 99999);
        case 38: GivePlayerWeapon(playerid, 38, 99999);
    }
    switch (PlayerInfo[playerid][pGun8])
    {
        case 16: GivePlayerWeapon(playerid, 16, 99999);
        case 17: GivePlayerWeapon(playerid, 17, 99999);
        case 18: GivePlayerWeapon(playerid, 18, 99999);
    }
    switch (PlayerInfo[playerid][pGun9])
    {
        case 41: GivePlayerWeapon(playerid, 41, 99999);
        case 42: GivePlayerWeapon(playerid, 42, 99999);
        case 43: GivePlayerWeapon(playerid, 43, 99999);
    }
    switch (PlayerInfo[playerid][pGun10])
    {
        case 10: GivePlayerWeapon(playerid, 10, 1);
        case 11: GivePlayerWeapon(playerid, 11, 1);
        case 12: GivePlayerWeapon(playerid, 12, 1);
        case 13: GivePlayerWeapon(playerid, 13, 1);
        case 14: GivePlayerWeapon(playerid, 14, 1);
        case 15: GivePlayerWeapon(playerid, 15, 1);
    }
    switch (PlayerInfo[playerid][pGun11])
    {
        case 44: GivePlayerWeapon(playerid, 44, 99999);
        case 45: GivePlayerWeapon(playerid, 45, 99999);
        case 46: GivePlayerWeapon(playerid, 46, 1);
    }
	return 1;
}
//==============================================================================
public GivePlayerGun(playerid, weaponid)
{
    switch (weaponid)
    {
        case 1: { PlayerInfo[playerid][pGun0] = 1; GivePlayerWeapon(playerid, 1, 1); }
        case 2..9: { PlayerInfo[playerid][pGun1] = weaponid; GivePlayerWeapon(playerid, weaponid, 1); }
        case 10..15: { PlayerInfo[playerid][pGun10] = weaponid; GivePlayerWeapon(playerid, weaponid, 1); }
        case 16..18, 39: { PlayerInfo[playerid][pGun8] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 21: { PlayerInfo[playerid][pGun12] = 21; SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK); }
        case 22..24: { PlayerInfo[playerid][pGun2] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 25..27: { PlayerInfo[playerid][pGun3] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 28..29, 32: { PlayerInfo[playerid][pGun4] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 30, 31: { PlayerInfo[playerid][pGun5] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 33, 34: { PlayerInfo[playerid][pGun6] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 35..38: { PlayerInfo[playerid][pGun7] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 40: { PlayerInfo[playerid][pGun12] = 40; GivePlayerWeapon(playerid, 40, 99999); }
        case 41..43: { PlayerInfo[playerid][pGun9] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
        case 44..46: { PlayerInfo[playerid][pGun11] = weaponid; GivePlayerWeapon(playerid, weaponid, 99999); }
    }
	return 1;
}
//==============================================================================
public AntiHackCheat()
{
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && gPlayerSpawned[i] == 1 && PlayerInfo[i][pAdmin] < 1)
	    {
	        new string[128];
	        if(PlayerInfo[i][pAdmin] <= 4)
	        {
				for (new weap = 1; weap < 46; weap++)
                {
                    if(GetPlayerWeapon(i) == weap && HaveWeapon(i, weap) != weap) RemovePlayerWeapon(i, weap);
                }
				if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK && PlayerInfo[i][pGun12] != 21)
				{
				    format(string, sizeof(string), "AdmCmd: %s was kicked, reason: Jetpack Hack.", PlayerName(i));
					SendClientMessageToAll(COLOR_LIGHTRED, string);
					Kick(i);
				}
			}
	    }
	}
	return 1;
}
//===============================[Anti-DeAmx]===================================
AntiDeAMX()
{
	new a[][] =
	{
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}
//==============================================================================
public FixHour(hour)
{
	hour = timeshift+hour;
	if (hour < 0)
	{
		hour = hour+24;
	}
	else if (hour > 23)
	{
		hour = hour-24;
	}
	shifthour = hour;
	return 1;
}
//==============================================================================
public ShowStats(playerid,targetid)
{
    if(IsPlayerConnected(playerid) && IsPlayerConnected(targetid))
	{
	    new string[256];
		new drank[20];
		new Float:health;
		if(PlayerInfo[targetid][pDonateRank] == 1) { drank = "Power User"; }
		else if(PlayerInfo[targetid][pDonateRank] >= 2) { drank = "Donator"; }
		else { drank = "None"; }
		new admin = PlayerInfo[targetid][pAdmin];
		new cash = GetPlayerCash(targetid);
		new kills = PlayerInfo[targetid][pKills];
		new deaths = PlayerInfo[targetid][pDeaths];
		new intir = GetPlayerInterior(targetid);
		new vw = GetPlayerVirtualWorld(targetid);
		new warns = PlayerInfo[targetid][pWarns];
		new hp = GetPlayerHealth(targetid, health);
		new armor = GetPlayerArmour(targetid, health);
		new jtime = PlayerInfo[targetid][pJailTime];
		new spree = PlayerInfo[targetid][pSpree];
		new bounty = Bounty[targetid];
		new lotto = PlayerInfo[targetid][pLotto];
		SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
		format(string, sizeof(string),"Stats from %s:", PlayerName(targetid));
		SendClientMessage(playerid, COLOR_GREEN, string);
		format(string, sizeof(string), "AdminLevel: %d DonateRank: %s", admin, drank);
		SendClientMessage(playerid, COLOR_GRAD2, string);
		format(string, sizeof(string), "Longest Kill Strike: %d Kills: %d Deaths: %d", spree, kills, deaths);
		SendClientMessage(playerid, COLOR_GRAD2, string);
		format(string, sizeof(string), "Health: %d Armor: %d Cash: $%d", hp, armor, cash);
		SendClientMessage(playerid, COLOR_GRAD2, string);
		format(string, sizeof(string), "Bounty: %d Lotto Number: %d", bounty, lotto);
		SendClientMessage(playerid, COLOR_GRAD2, string);
		if (PlayerInfo[playerid][pAdmin] >= 1)
		{
			format(string, sizeof(string), "Interior:[%d] VirtualWorld:[%d] Warnings:[%d] JailTime:[%d]", vw, intir, warns, jtime);
			SendClientMessage(playerid, COLOR_WHITE, string);
		}
		SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
	}
}
//==============================================================================
public SendAdminMessage(color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][pAdmin] >= 1)
		    {
				SendClientMessage(i, color, string);
			}
		}
	}
}
//==============================================================================
new InvalidNosVehicles[29] =
{
	581,523,462,521,463,522,461,448,468,586,
    509,481,510,472,473,493,595,484,430,453,
    452,446,454,590,569,537,538,570,449
};
//==============================================================================
public IsPlayerInInvalidNosVehicle(playerid)
{
	new carid = GetPlayerVehicleID(playerid);
	new carmodel = GetVehicleModel(carid);
	for (new i=0; i<sizeof(InvalidNosVehicles); i++)
	{
	    if (carmodel == InvalidNosVehicles[i]) return 1;
	}
	return 0;
}
//==============================================================================
public SaveAccounts()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			OnPlayerDataSave(i);
		}
	}
}
//==============================================================================
public GeneralTimer()
{
    new Float:maxspeed = 1000.0;
    new plname[MAX_PLAYER_NAME];
	new string[256];
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
            if(PlayerInEvent[i] == 2)
            {
                if(EventPlayers == 1)
                {
                    if(IsPlayerInRangeOfPoint(i, 100.0, -1365.6591,1026.0172,1025.8583) && GetPlayerInterior(i) == 15)
                    {
                        format(string, sizeof(string), "** %s Joined the Evernt And Earnt $30,000.", PlayerName(i));
	                    SendClientMessageToAll(COLOR_YELLOW, string);
	                    GivePlayerCash(i, 30000);
                        RestoreWeapons(i);
                        PlayerInEvent[i] = 0;
                        EventPlayers = 0;
                    }
                }
            }
	        if(PlayerInfo[i][pJail] > 0)
			{
			    if(PlayerInfo[i][pJailTime] > 0)
			    {
				    PlayerInfo[i][pJailTime]--;
			    }
			    if(PlayerInfo[i][pJailTime] <= 0)
			    {
			        SetPlayerInterior(i, 6);
				    SetPlayerPos(i,268.0903,77.6489,1001.0391);
				    PlayerInfo[i][pJail] = 0;
				    PlayerInfo[i][pJailTime] = 0;
				    format(string, sizeof(string), "~n~~g~Freedom");
				    GameTextForPlayer(i, string, 5000, 1);
				    SetPlayerToTeamColor(i);
                }
			}
		    if(GetPlayerState(i) == 2)
		    {
			    GetPlayerPos(i, TelePos[i][3], TelePos[i][4], TelePos[i][5]);
				if(TelePos[i][0] != 0.0)
				{
				    new Float:xdist = TelePos[i][3]-TelePos[i][0];
					new Float:ydist = TelePos[i][4]-TelePos[i][1];
					new Float:sqxdist = xdist*xdist;
					new Float:sqydist = ydist*ydist;
					new Float:distance = (sqxdist+sqydist)/31;
					if(distance > maxspeed && PlayerInfo[i][pAdmin] < 1)
					{
					    GetPlayerName(i, plname, sizeof(plname));
						format(string, 256, "AdmWarning: [%d]%s %.0f mph",i,plname,distance);
						ABroadCast(COLOR_YELLOW,string,1);
					}
				}
			    new Float:vX, Float:vY, Float:vZ;
                GetVehicleVelocity(GetPlayerVehicleID(i), vX, vY, vZ);
                new speed = floatround(floatround(floatpower((vX * vX) + (vY * vY) + (vZ * vZ),0.5)*100)*1.61);
				if(speed > 174 && PlayerInfo[i][pAdmin] < 1)
				{
					new tmpcar = GetPlayerVehicleID(i);
					if(!IsAPlane(tmpcar))
					{
						GetPlayerName(i, plname, sizeof(plname));
						format(string, 256, "AdmWarning: [%d]%s %d kmh",i,plname,speed);
						ABroadCast(COLOR_YELLOW,string,1);
					}
				}
				else if(speed > 244 && PlayerInfo[i][pAdmin] < 1)
				{
					new tmpcar = GetPlayerVehicleID(i);
					if(IsAPlane(tmpcar))
					{
						GetPlayerName(i, plname, sizeof(plname));
						format(string, 256, "AdmWarning: [%d]%s %d kmh",i,plname,speed);
						ABroadCast(COLOR_YELLOW,string,1);
					}
				}
			}
		}
	}
	return 1;
}
//==============================================================================
stock IsVehicleRc(carid)
{
   	switch(GetVehicleModel(carid)){
		case 441, 464, 465, 501, 564, 594: return true;
	}
	return 0;
}
//==============================================================================
stock IsABoat(carid)
{
    new carmodel = GetVehicleModel(carid);
	if(carmodel == 430 || carmodel == 453 || carmodel == 484)
	{
		return 1;
	}
	return 0;
}
//==============================================================================
stock IsAPlane(carid)
{
    new AirVeh[] = { 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 548, 425, 417, 487, 488, 497, 563, 447, 469 };
    for(new i = 0; i < sizeof(AirVeh); i++)
    {
        if(GetVehicleModel(carid) == AirVeh[i]) return 1;
    }
    return 0;
}
//==============================================================================
stock IsBike(carid)
{
    new Bikes[] = { 509, 481, 510 };
    for(new i = 0; i < sizeof(Bikes); i++)
    {
        if(GetVehicleModel(carid) == Bikes[i]) return 1;
    }
    return 0;
}
//==============================================================================
public SetPlayerToTeamColor(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	    if(gTeam[playerid] == TEAM_GROVE) { SetPlayerColor(playerid, COLOR_GREEN); }
	    else if(gTeam[playerid] == TEAM_BALLAS) { SetPlayerColor(playerid, COLOR_PURPLE); }
	    else if(gTeam[playerid] == TEAM_VAGOS) { SetPlayerColor(playerid, COLOR_YELLOW); }
	    else if(gTeam[playerid] == TEAM_AZTECAS) { SetPlayerColor(playerid, COLOR_LIGHTBLUE); }
	    else if(gTeam[playerid] == TEAM_TRIADS) { SetPlayerColor(playerid, 0x00000070); }
	    else if(gTeam[playerid] == TEAM_YAKUZA) { SetPlayerColor(playerid, YAKUZA_COLOR); }
	    else if(gTeam[playerid] == TEAM_CRIPZ) { SetPlayerColor(playerid, CRIPZ_COLOR); }
	}
}
//==============================================================================
public SendTeamMessage(team, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(gTeam[i] == team)
		    {
				SendClientMessage(i, color, string);
			}
		}
	}
}
//==============================================================================
public split(const strsrc[], strdest[][], delimiter)
{
	new i, li;
	new aNum;
	new len;
	while(i <= strlen(strsrc))
	{
	    if(strsrc[i]==delimiter || i==strlen(strsrc))
		{
	        len = strmid(strdest[aNum], strsrc, li, i, 128);
	        strdest[aNum][len] = 0;
	        li = i+1;
	        aNum++;
		}
		i++;
	}
	return 1;
}
//==============================================================================
public TimeTextForPlayer(playerid, Text:text, time)
{
    TextDrawShowForPlayer( playerid, text );
    SetTimerEx("DestroyTextTimer", time, 0, "i", _:text);
}
public DestroyTextTimer(Text:text)  TextDrawDestroy(text);
//==============================================================================
stock OwnedTurfs()
{
    new turf, playerid;
    for (new i = 0; i < MAX_TURFS; i++) if (turfs[i][TurfOwner] == gTeam[playerid]) turf++;
    return turf;
}
//==============================================================================
stock OwnedTurfs2(teamid)
{
    new turf;
    for (new i = 0; i < MAX_TURFS; i++) if (turfs[i][TurfOwner] == teamid) turf++;
    return turf;
}
//==============================================================================
stock RandomEx(min, max)
{
	new output;
	output = max-min;
	output = random(output);
	output = min+output;
	return output;
}
//==============================================================================
ReturnUser(text[], playerid = INVALID_PLAYER_ID)
{
	new pos = 0;
	while (text[pos] < 0x21)
	{
		if (text[pos] == 0) return INVALID_PLAYER_ID;
		pos++;
	}
	new userid = INVALID_PLAYER_ID;
	if (IsNumeric(text[pos]))
	{
		userid = strval(text[pos]);
		if (userid >=0 && userid < MAX_PLAYERS)
		{
			if(!IsPlayerConnected(userid))
			{
				userid = INVALID_PLAYER_ID;
			}
			else
			{
				return userid;
			}
		}
	}
	new len = strlen(text[pos]);
	new count = 0;
	new name[MAX_PLAYER_NAME];
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i))
		{
			GetPlayerName(i, name, sizeof (name));
			if (strcmp(name, text[pos], true, len) == 0)
			{
				if (len == strlen(name))
				{
					return i;
				}
				else
				{
					count++;
					userid = i;
				}
			}
		}
	}
	if (count != 1)
	{
		if (playerid != INVALID_PLAYER_ID)
		{
			if (count)
			{
				SendClientMessage(playerid, 0xFF0000AA, "Multiple users found, please narrow search");
			}
			else
			{
				SendClientMessage(playerid, 0xFF0000AA, "No matching user found");
			}
		}
		userid = INVALID_PLAYER_ID;
	}
	return userid;
}
//==============================================================================
IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}
//==============================================================================
stock GetWeaponPickupID(weaponid)
{
	new pickupid;
	switch(weaponid)
	{
	    case 1:  pickupid = 331;
	    case 2:  pickupid = 333;
	    case 3:  pickupid = 334;
	    case 4:  pickupid = 335;
	    case 5:  pickupid = 336;
	    case 6:  pickupid = 337;
	    case 7:  pickupid = 338;
	    case 8:  pickupid = 339;
	    case 9:  pickupid = 341;
	    case 10: pickupid = 321;
	    case 11: pickupid = 322;
	    case 12: pickupid = 323;
	    case 13: pickupid = 324;
	    case 14: pickupid = 325;
	    case 15: pickupid = 326;
	    case 16: pickupid = 342;
	    case 17: pickupid = 343;
	    case 18: pickupid = 344;
	    case 22: pickupid = 346;
		case 23: pickupid = 347;
		case 24: pickupid = 348;
		case 25: pickupid = 349;
		case 26: pickupid = 350;
		case 27: pickupid = 351;
		case 28: pickupid = 352;
		case 29: pickupid = 353;
		case 30: pickupid = 355;
		case 31: pickupid = 356;
		case 32: pickupid = 372;
		case 33: pickupid = 357;
		case 34: pickupid = 358;
		case 35: pickupid = 359;
		case 36: pickupid = 360;
		case 37: pickupid = 361;
		case 38: pickupid = 362;
		case 39: pickupid = 363;
		case 40: pickupid = 364;
		case 41: pickupid = 365;
		case 42: pickupid = 366;
		default: pickupid = 0;
	}
	return pickupid;
}
//==============================================================================
public PickupDestroy(playerid)
{
    if(IsPlayerConnected(playerid))
    {
        DestroyPickup(gPickupID[playerid]);
    }
}
//==============================================================================
public TipBot()
{
	new tipid = RandomEx(0, 7);
	switch (tipid)
	{
	    case 0: SendClientMessageToAll(COLOR_ORANGE, "TIP: Seen a hacker? Don't tell in chat, /report him.");
	    case 1: SendClientMessageToAll(COLOR_ORANGE, "TIP: You think you can be one of us? Apply at our forum, www.mysite.com.");
	    case 2: SendClientMessageToAll(COLOR_ORANGE, "TIP: If you have a good idea that you want to suggest, visit our forum at www.mysite.com.");
	    case 3: SendClientMessageToAll(COLOR_ORANGE, "TIP: Don't know what to do? Need Help? Type /help.");
	    case 4: SendClientMessageToAll(COLOR_ORANGE, "TIP: Type /rules to avoid breaking them in the future.");
	    case 5: SendClientMessageToAll(COLOR_ORANGE, "TIP: Wanna have some fun? Then take part to the games ( Watch the announcement of the bots ).");
	    case 6: SendClientMessageToAll(COLOR_ORANGE, "TIP: Found a bug? Then post it on forums at www.mysite.com so we will be able to fit it.");
	    case 7: SendClientMessageToAll(COLOR_ORANGE, "TIP: Become a donator and win prizes and stuff. More info at www.mysite.com.");
	}
	return 1;
}
//==============================================================================
public CalcBot()
{
    if(CalculateStarted == 0)
    {
		new game = RandomEx(0, 5);
		switch (game)
		{
	    	case 0:
	    	{
		    	SendClientMessageToAll(COLOR_LIGHTBLUE, "** The first who calculate this: 56 + 44 - 18 + 1 -34 = ?, wins $20,000.");
		    	CalculateEvent = 1;
		    	CalculateStarted = 1;
		    	for(new i = 0; i < MAX_PLAYERS; i++)
		   	    {
		   	        reactiontimer[i] = SetTimerEx("FastestReaction", 100, 1, "i", i);
		    	}
			}
			case 1:
	    	{
		    	SendClientMessageToAll(COLOR_LIGHTBLUE, "** The first who calculate this: 34 * 160 / 1000 = ?, wins $20,000.");
		    	CalculateEvent = 2;
		    	CalculateStarted = 1;
		    	for(new i = 0; i < MAX_PLAYERS; i++)
		   	    {
		   	        reactiontimer[i] = SetTimerEx("FastestReaction", 100, 1, "i", i);
		    	}
			}
			case 2:
	    	{
		    	SendClientMessageToAll(COLOR_LIGHTBLUE, "** The first who calculate this: 3x + 5 * (-4) = 10, wins $20,000.");
		    	CalculateEvent = 3;
		    	CalculateStarted = 1;
		    	for(new i = 0; i < MAX_PLAYERS; i++)
		   	    {
		   	        reactiontimer[i] = SetTimerEx("FastestReaction", 100, 1, "i", i);
		    	}
			}
			case 3:
	    	{
		    	SendClientMessageToAll(COLOR_LIGHTBLUE, "** Complete the sentence and win $20,000: 'Lets it rain, let it flood, Kill a crip, Let a...'.");
		    	CalculateEvent = 4;
		    	CalculateStarted = 1;
		    	for(new i = 0; i < MAX_PLAYERS; i++)
		   	    {
		   	        reactiontimer[i] = SetTimerEx("FastestReaction", 100, 1, "i", i);
		    	}
			}
			case 4:
	    	{
		    	SendClientMessageToAll(COLOR_LIGHTBLUE, "** Answer the question and win $20,000: What is the last name of the U.S Governor?.");
		    	CalculateEvent = 4;
		    	CalculateStarted = 1;
		    	for(new i = 0; i < MAX_PLAYERS; i++)
		   	    {
		   	        reactiontimer[i] = SetTimerEx("FastestReaction", 100, 1, "i", i);
		    	}
			}
		}
	}
	return 1;
}
//==============================================================================
public FastestReaction(playerid)
{
    PlayerInfo[playerid][pCalcSec] = floatadd(PlayerInfo[playerid][pCalcSec], 0.1);
    return 1;
}
//==============================================================================
public GameBot()
{
    new game = RandomEx(0, 3);
    switch (game)
	{
	    case 0:
	    {
	        SendClientMessageToAll(COLOR_LIGHTGREEN, "Lottery News: The lottery draw will start in 20 seconds, Type /lotto to purchase a ticket.");
	        SetTimer("StartLotto", 20000, 0);
	    }
	    case 1:
	    {
	        SendClientMessageToAll(COLOR_LIGHTGREEN, "Parkour Event will start soon, to take part type /joinevent.");
	        aeventtimer = SetTimer("AnnounceEvent", 1000, 1);
	        Event = 1;
	        ParkourEventFinished = 0;
	        EventPlayers = 0;
	    }
	    case 2:
	    {
	        SendClientMessageToAll(COLOR_LIGHTGREEN, "Derby Event will start soon, to take part type /joinevent.");
	        aeventtimer = SetTimer("AnnounceEvent", 1000, 1);
	        Event = 2;
	        EventPlayers = 0;
	    }
	}
	return 1;
}
//==============================================================================
public StartLotto()
{
    new string[256];
    new lotto = RandomEx(1, 61);
    new JackpotFallen = 0;
    format(string, sizeof(string), "Lottery News: Today the Winning Number has fallen on: %d.", lotto);
	SendClientMessageToAll(COLOR_WHITE, string);
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(PlayerInfo[i][pLotto] == lotto)
	    {
	        format(string, sizeof(string), "* You have Won $%d with your Lottery Ticket.", Jackpot);
			SendClientMessage(i, COLOR_YELLOW, string);
	        GivePlayerCash(i, Jackpot);
	        JackpotFallen = 1;
	    }
	    else
	    {
	        SendClientMessage(i, COLOR_LIGHTBLUE, "* You haven't won with your Lottery Ticket this time.");
	    }
	    PlayerInfo[i][pLotto] = 0;
	}
	if(JackpotFallen)
	{
	    new rand = random(125000); rand += 15789;
	    Jackpot = rand;
	    format(string, sizeof(string), "Lottery News: The new Jackpot has been started with $%d.", Jackpot);
		SendClientMessageToAll(COLOR_WHITE, string);
	}
	else
	{
	    new rand = random(15000); rand += 2158;
	    Jackpot += rand;
	    format(string, sizeof(string), "Lottery News: The Jackpot has been raised to $%d.", Jackpot);
		SendClientMessageToAll(COLOR_WHITE, string);
	}
	return 1;
}
//==============================================================================
public AnnounceEvent()
{
    if(EventPlayers > 1)
    {
        KillTimer(aeventtimer);
        SendClientMessageToAll(COLOR_YELLOW, "The Event will start in 20 seconds, to join type /joinevent.");
        SetTimer("EventStarted", 20000, 0);
    }
    return 1;
}
//==============================================================================
public EventStarted()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
        switch (PlayerInEvent[i])
        {
            case 1:
            {
                SendClientMessageToAll(COLOR_LIGHTBLUE, "The Event has been stopped and its ready to begin.");
                SetPlayerCheckpoint(i, gParkourPoints[ParkourPoint[i]][0], gParkourPoints[ParkourPoint[i]][1], gParkourPoints[ParkourPoint[i]][2], 5.0);
                GameTextForPlayer(i, "~w~Go Go Go", 2000, 0);
                TogglePlayerControllable(i, 1);
                SetCameraBehindPlayer(i);
                Event = 0;
            }
            case 2:
            {
                new Float: X, Float: Y, Float: Z, Float: A;
                SendClientMessageToAll(COLOR_LIGHTBLUE, "The Event has been stopped and its ready to begin.");
                GameTextForPlayer(i, "~w~Go Go Go", 2000, 0);
                GetPlayerPos(i, X, Y, Z);
                GetPlayerFacingAngle(i, A);
                PlayerCar[i] = CreateVehicle(504, X, Y, Z, A, -1, -1, 6000000);
                LinkVehicleToInterior(PlayerCar[i], 15);
                PutPlayerInVehicle(i, PlayerCar[i], 0);
                TogglePlayerControllable(i, 1);
                Event = 0;
            }
        }
    }
}

