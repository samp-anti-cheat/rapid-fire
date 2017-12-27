# Rapid Fire

* Type:
  Gameplay hack
* Description:
  Simply increases the rate of fire for weapons.
* Detection Method:
  The tick count between each shot is measured, if the value exceeds the default shot interval for that weapon the player is marked for report. C-Bug and dual wield are taken into account as these will increase the fire rate legitimately.
* Callback:
  `OnAntiCheatFireRate(playerid, weaponid, interval)`
* Author:
  Southclaw

## Installation

Simply install to your project:

```bash
sampctl package install samp-anti-cheat/rapid-fire
```

Include in your code and begin using the library:

```pawn
#include <rapid-fiew>
```

## Testing

To test, simply run the package:

```bash
sampctl package run
```

And connect to `localhost:7777` to test.
