# SpeedyMount-BCC

This is a simplified and updated version of the Classic-Era addon `SpeedyMount`. 

## What has changed?

The old addon was checking for player buffs according to a hard-coded local database of mounts within the addons.
I found that to be very hard and tedious to maintain since in BCC there are a lot of new mounts (flying and ground mounts).

* Make use of the `IsMounted()` API Call
* Renamed the `HasMount()` to `CheckMountStatus()`
  * Completely reworked the function

What this does is it allows the addon to work with ANY mounts, regardless of if new ones are added to the game or not.

## Bug reporting
Please feel free to report any bugs in the "Issues" section of this GitHub repository.