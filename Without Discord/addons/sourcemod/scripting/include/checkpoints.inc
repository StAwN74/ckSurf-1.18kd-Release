/**
\file checkpoints.inc
\brief Sourcemod plugin API that facilitates checkpoint (location, view, velocity) saving

---------------------------------------------------------------------------------------------------------
-License:

Checkpoints - SourceMod Plugin
Copyright (C) 2012 B.D.A.K. Koch

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

As a special exception, AlliedModders LLC gives you permission to link the
code of this program (as well as its derivative works) to "Half-Life 2," the
"Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
by the Valve Corporation.  You must obey the GNU General Public License in
all respects for all other code used.  Additionally, AlliedModders LLC grants
this exception to all derivative works.  AlliedModders LLC defines further
exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
or <http://www.sourcemod.net/license.php>.
---------------------------------------------------------------------------------------------------------
*/

#if defined CHECKPOINTS_INC
	#endinput
#endif // defined CHECKPOINTS_INC
#define CHECKPOINTS_INC

#pragma semicolon 1

#include <sourcemod>

public SharedPlugin:__pl_maptimer = {
	name = "checkpoints",
	file = "checkpoints.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif // defined REQUIRE_PLUGIN
};

/**
 * List of possible events passed to \see Checkpoints_Event
 */
enum ECheckpoints_Event {
	CHECKPOINTS_EVENT_SAVE,				///<! Fired when a checkpoint is saved.
										///<! Additional data consists of the checkpoint (origin, eye_angles and velocity).
										///<! and its index.

	CHECKPOINTS_EVENT_TELEPORT,			///<! Fired when a player is teleported to a checkpoint.
										///<! Additional data consists of the checkpoint (origin, eye_angles and velocity)
										///<! and its index.

	CHECKPOINTS_EVENT_DELETE,			///<! Fired when a player's checkpoint is deleted.
										///<! Additional data consists of the checkpoint index.
										///<! Note: unblockable

	CHECKPOINTS_EVENT_CLEAR				///<! Fired when a player's checkpoints are cleared.
										///<! This event contains no additional data.
										///<! Note: unblockable
}

/**
 * \brief To find out when this is called, \see ECheckpoints_Event
 *
 * \return								An Action: value:
 *										Plugin_Stop: signals that the event should be blocked
 *										Plugin_Changed: signals a variable passed by referrence was changed
 *										Plugin_Continue: does nothing
 */

typedef Checkpoints_Event = function void(int entity, any data);

Checkpoints_Event(
	ECheckpoints_Event:event,
	client,								///<! [in] Client index of the player to whom the event pertains
	index,								///<! [in] Index of the checkpoint, if applicable
	Float:origin[3],					///<! [in, out] The player's origin vector, if applicable
	Float:eye_angles[3],				///<! [in, out] The player's eye angles, if applicable
	Float:velocity[3]					///<! [in, out] The player's velocity, if applicable
);

/**
 * \brief								Saves a player's location, view and velocity (checkpoint).
 *
 * \return								Index of the newly created checkpoint, -2 when blocked, or -1 on failure
 * \error								Inability to initialise adt_array
 */
native Checkpoints_Save(
	client,								///<! [in] Client index of the player whose current location, view and velocity should be saved
	index = -1							///<! [in] Index of the checkpoint to be overwritten, -1 to create a new checkpoint
);

/**
 * \brief Teleports a player to one of his checkpoints.
 *
 * \return								Index of the checkpoint the player was teleported to, -2 when blocked, or -1 on failure
 * \error								Inability to initialise adt_array, index < 0 or no checkpoints stored
 */
native Checkpoints_Teleport(
	client,								///<! [in] Client index of the player to be teleported
	index								///<! [in] Index of the checkpoint to teleport to
);

/**
 * \brief Teleports a player to the next checkpoint.
 *
 * \return								Index of the checkpoint the player was teleported to, -2 when blocked, or -1 on failure
 * \error								Inability to initialise adt_array, or no checkpoints stored
 */
native Checkpoints_Next(
	client								///<! [in] Client index of the player to be teleported
);

/**
 * \brief Teleports a player to the previous checkpoint.
 *
 * \return								Index of the checkpoint the player was teleported to, -2 when blocked, or -1 on failure
 * \error								Inability to initialise adt_array, or no checkpoints stored
 */
native Checkpoints_Previous(
	client								///<! [in] Client index of the player to be teleported
);

/**
 * \brief Deletes a checkpoint.
 *
 * \return								Index of the deleted checkpoint, or -1 on failure
 * \error								Inability to initialise adt_array, index < 0 or no checkpoints stored
 */
native Checkpoints_Delete(
	client,								///<! [in] Client index of the player whose checkpoint should be deleted
	index								///<! [in] Index of the checkpoint subject of deletion
);

/**
 * \brief Deletes every checkpoint a player has.
 *
 * \return								Number of checkpoints deleted
 * \error								Inability to initialise adt_array
 */
native Checkpoints_Clear(
	client								///<! [in] Client index of the player whose checkpoints should be deleted
);

native Checkpoints_GetNumberOfCheckpoints(
	client								///<! [in] The player's client index
);

/**
 * \brief Retrieves a player's current checkpoint index.
 *
 * \return								The player's current checkpoint index
 *										Note: -1 means no checkpoints available
 */
native Checkpoints_GetCurrentCPIndex(
	client								///<! [in] The player's client index
);

/**
 * \brief Sets a player's current checkpoint index.
 *
 * \return								The player's current checkpoint index (after clamping)
 *										Note: -1 means no checkpoints available
 */
native Checkpoints_SetCurrentCPIndex(
	client,								///<! [in] The player's client index
	index								///<! [in] The desired current checkpoint index
);

/**
 * Adds a function to Checkpoints' private forward's call list.
 *
 * Cannot be used during an incompleted call
 *
 * \return								True on success, false otherwise
 * \error								Invalid function
 */
native bool:Checkpoints_HookEvents(
	Checkpoints_Event:func				///<! [in] Function to add to forward
);

/**
 * Removes a function from Checkpoints' private forward's call list.
 *
 * Only removes one instance.
 * All instances will be removed if the plugin is unloaded.
 *
 * \return								True on success, false otherwise
 * \error								Invalid function
 */
native bool:Checkpoints_UnhookEvents(
	Checkpoints_Event:func				///<! [in] Function to remove from forward
);

public __pl_checkpoints_SetNTVOptional() {
	MarkNativeAsOptional("Checkpoints_Save");
	MarkNativeAsOptional("Checkpoints_Teleport");
	MarkNativeAsOptional("Checkpoints_Next");
	MarkNativeAsOptional("Checkpoints_Previous");
	MarkNativeAsOptional("Checkpoints_Delete");
	MarkNativeAsOptional("Checkpoints_Clear");
	MarkNativeAsOptional("Checkpoints_GetNumberOfCheckpoints");
	MarkNativeAsOptional("Checkpoints_GetCurrentCPIndex");
	MarkNativeAsOptional("Checkpoints_SetCurrentCPIndex");
	MarkNativeAsOptional("Checkpoints_HookEvents");
	MarkNativeAsOptional("Checkpoints_UnhookEvents");
}
