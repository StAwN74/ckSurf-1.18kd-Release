
 ***
I personally use this version because it does not deal with server hibernation.
I don't like plugins touching hibernation or blocking it, but I have to cancel hibernation manually, or else sql requests can be corrupt.
So, if you use disabled/ckSurf_slnh.smx, you HAVE to set sv_hibernate_when_empty 0 in your launch command and in your server.cfg. Otherwise, your database WILL SURELY be corrupt.
 ***
