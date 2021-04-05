#include <sourcemod>
#include <moreinfected>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#include "base/shared.sp"

#include "base/re_npcs/classic_zombies.sp"
#include "base/re_npcs/tyrant.sp"

public void OnPluginStart()
{
	base_npc_init();

	classiczombie_init();
	tyrant_init();

	RegConsoleCmd("testre", cmd);
}

Action cmd(int client, int args)
{
	float origin[3];
	GetClientEyePosition(client, origin);

	float angles[3];
	GetClientEyeAngles(client, angles);

	Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SOLID, RayType_Infinite, TraceEntityFilter_DontHitEntity, client);

	float end[3];
	TR_GetEndPosition(end, trace);

	delete trace;

	PrecacheModel("models/roach/redc/ety1.mdl");

	int entity = create_base_npc("npc_re_tyrant", 3);

	TeleportEntity(entity, end);

	return Plugin_Handled;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "npc_re_classiczombie")) {
		SDKHook(entity, SDKHook_Think, classiczombie_think);
		SDKHook(entity, SDKHook_Spawn, classiczombie_spawn);
	} else if(StrEqual(classname, "npc_re_tyrant")) {
		SDKHook(entity, SDKHook_Think, tyrant_think);
		SDKHook(entity, SDKHook_Spawn, tyrant_spawn);
	}
}

public void OnEntityDestroyed(int entity)
{
	if(entity == -1) {
		return;
	}

	char classname[64];
	GetEntityClassname(entity, classname, sizeof(classname));
	if(StrEqual(classname, "npc_re_classiczombie") ||
		StrEqual(classname, "npc_re_tyrant")) {
		base_npc_deleted(entity);
	}
}

public void OnPluginEnd()
{
	classiczombie_removeall();
	tyrant_removeall();
}