/*
 * MOTD Fixer
 *
 * Fixes the MOTD loading of data under Counter-Strike : Global Offensive
 *
 * Coded by dubbeh - www.dubbeh.net
 *
 * Licensed under the GPLv3
 *
 */


#if defined _motdf_included
 #endinput
#endif
#define _motdf_included


/*
 * Show an MOTD Panel in CS:GO for the URL
 *
 * Make sure the URL starts with http/https to be validated on the web-script
 *
 * @param 	iClientIndex = The current server client index to display to
 * @param	szTitle = MOTD panel title
 * @param 	szURL = The URL to display
 * @param	bHidden = Display or Hide the panel
 * @param	iPanelWidth = MOTD Panel Width
 * @param	iPanelHeight = MOTD Panel Height
 * @return 	1 on success - 0 on failure
 *
 */
native int MOTDF_ShowMOTDPanel (int iClientIndex, const char []szTitle, const char []szURL, bool bHidden = false, int iPanelWidth = 1024, int iPanelHeight = 576);

public SharedPlugin __pl_motdf =
{
    name = "motdf",
    file = "motdf.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_motdf_SetNTVOptional()
{
	MarkNativeAsOptional("MOTDF_ShowMOTDPanel");
}
#endif
