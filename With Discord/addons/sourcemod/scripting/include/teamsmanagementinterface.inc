//v1.2
//Flags
#define FTMI_SOUND            (1<<0) //Should the default sound of TMI be used ?
#define FTMI_FADE             (1<<1) //Should the default fade of TMI be used ? ; implemented only for TMT_TEAMS
//Should the team management be instant (else = round_end) ?
#define FTMI_INSTANT          (1<<2) //if using this, it could be a good thing to use CancelTeamsManagement() before
enum TeamsManagementType
{
    TMT_TEAMS = (1<<0),             //an incoming action on round-end will affect the teams; to use with high priority to prevent incoming action
    TMT_INDIVIDUALS = (1<<1),       //an incoming action on round-end will affect one or many individuals
    TMT_ALL = TMT_INDIVIDUALS | TMT_TEAMS   //used to cancel everything but prevention
};

/**
* For TMT_TEAMS :
* Where actionId = : 
* 0 = Nothing
* 1 = Set Fair Scrambled teams
* 2 = Set Unfair Scrambled teams (pure scramble)
* 3 = Set Specific Scrambled teams (i.e. 1-2 v rest)
* 4 = Set Swap teams
*
* For TMT_INDIVIDUALS : 
* Where actionId = :
* 0 = Nothing
* 1 = Set to Spec
* 2 = Set to terro
* 3 = Set to CT
* 4 = Toggle team CT <--> T
*/

//A note about priority : -1 always take over the others
//A note about customValue : it contains a client Id if type is TMT_INDIVIDUALS

//In my mind for TMT_TEAMS : Scrambles (x3 + prevent + clan-together-scramble)
//In my mind for TMT_INDIV : Switch (x1), To-A-Team (x2) (from a clan-to-a-team too)

/**
* This forward is executed whenever a plugin request a Teams Management action.
* The request needs to be accepted (i.e. no other plugins made the same request 
* with a lower or equal priority).
*
* @param plugin        Plugin handle to identify owner of requested TM
* @param reasonId      Reason for the plugin to ask a management. Used for the calling plugin.
* @param priority      Priority with which the TM was requested. A TM request
* is accepted only if no current TM are requested, or if the priority is equal or superior.
* the plugin requesting a team management to give a reason or not.
* @param type          TeamsManagementType; see enum
* @param actionId      Kind of teams management to do (i.e. scrambling? move one player?)
* @param customValue   Used possibly for the action (i.e. userId to switch)
* @param flags         See FTMI_ defines above
* @noreturn
*/
forward OnTeamsManagementAcceptedRequest( const Handle:plugin, 
    const reasonId,
    const priority, 
    const TeamsManagementType:type,
    const actionId, 
    const any:customValue, 
    const flags);

/**
* This forward is executed whenever a plugin's request is known to not be executed.
* This is when another request a TMI with a type having a higher priority then the one
* that the abandoned request had.
* The request needs to have been accepted (i.e. this isn't forwarded for unaccepted requests;
* since a bool from the Native does that)
*
* @param plugin        Plugin handle to identify owner of requested TM
* @param reasonId      Reason for the plugin to ask a management. Used for the calling plugin.
* @param priority      Priority with which the TM was requested. A TM request
* is accepted only if no current TM are requested, or if the priority is equal or superior.
* the plugin requesting a team management to give a reason or not.
* @param type          TeamsManagementType; see enum
* @param actionId      Kind of teams management to do (i.e. scrambling? move one player?)
* @param customValue   Used possibly for the action (i.e. userId to switch)
* @param flags         See FTMI_ defines above
* @noreturn
*/
forward OnTeamsManagementAbandonedRequest( const Handle:plugin, 
    const reasonId,
    const priority, 
    const TeamsManagementType:type,
    const actionId, 
    const any:customValue, 
    const flags);

/**
* This forward is executed whenever a TMI execute Teams Management action.
*
* @param plugin        Plugin handle to identify owner of requested TM
* @param reasonId      Reason for the plugin to ask a management. Used for the calling plugin.
* @param priority      Priority with which the TM was requested. A TM request
* is accepted only if no current TM are requested, or if the priority is equal or superior.
* the plugin requesting a team management to give a reason or not.
* @param type          TeamsManagementType; see enum
* @param actionId      Kind of teams management to do (i.e. scrambling? move one player?)
* @param customValue   Used possibly for the action (i.e. userId to switch)
* @param flags         See FTMI_ defines above
* @noreturn
*/
forward OnTeamsManagementExecutedRequest( const Handle:plugin, 
    const reasonId,
    const priority, 
    const TeamsManagementType:type,
    const actionId, 
    const any:customValue, 
    const flags);

/**
* To request Teams Management
*
* @param reasonId      Reason for the plugin to ask a management. Used for the calling plugin.
* @param priority      Priority with of the TM. A TM request
* is accepted only if no current TM are requested, or if the priority is equal or superior.
* the plugin requesting a team management to give a reason or not.
* @param type          TeamsManagementType; see enum
* @param actionId      Kind of teams management to do (i.e. scrambling? move one player?)
* @param customValue   Used possibly for the action (i.e. userId to switch)
* @param flags         See FTMI_ defines above
* @return bool         If the request was successful. This doesn't mean that it will be executed (i.e. other plugins request with higher priority)
*/
native bool:RequestTeamsManagement( reasonId,
    priority, 
    TeamsManagementType:type,
    actionId, 
    any:customValue, 
    flags);

/**
* To cancel all Teams Management (of a type if specified; below or equals a certain priority)
*
* @param type          TeamsManagementType; see enum; if == TMT_ALL, all types but prevention
* @param priority      Teams Management requests =< of this will be canceled, or -1 to cancel them all !
* @return bool         If at least one request was canceled.
*/
native bool:CancelTeamsManagement( TeamsManagementType:type = TMT_ALL, 
    priority = -1 );