LeaderLib Mod for Divinity: Original Sin 2
=======
LeaderLib is a library mod used to provide common code to other mods.

# Features

## Mod Support
LeaderLib is, at its core, a way for mods to work together. It provides:

* A way to register and detect what mods are running.
* A centralized "Mod Settings" menu for other mods to register their menus to. No longer is there a need for every mod to provide a separate settings book.
* Helpers, such as logging commands, and a way to sort strings alphanumerically. 
* A way to send general events, with no specific target in mind.

### Dependency-Free Integration
* Mods can add LeaderLib support with no dependencies required, thanks to LeaderLib's ModAPI system.

## Treasure & Trader System
LeaderLib features a script-based treasure and trader system, which can be used to spawn both treasure and loot dynamically, with a multitude of customization:

* Requirements (party level or flag) can be created and set for specific treasure and trader spawning, preventing them from spawning until a requirement is met.
* Events for when traders spawn, or treasure generates.

### Treasure-Specific
* Various generation types to specify *when* treasure can generate.
* Item templates, item stats, or treasure tables can be registered to specific "Treasure IDs".
* Delta mods and runes (with optional randomization), can be assigned to treasure + item entries.

### Trader-Specific
* Support for global characters or characters that need to be spawned first.
* Starting gold for traders on specific levels.
* Dialog for traders on specific levels, with an optional requirement.
* Positions on specific levels can be assigned via coordinates, triggers, or objects (i.e. teleporting to a specific chair, or a character).
* Seats can be assigned to traders, so they'll sit after spawning.

## "Retired Commander" Trader
LeaderLib adds a new trader to the main campaign that persists through every act.
He exists as a central trader for mod-specific items added by all my mods. 

# Releases
* [Nexus]()
* [Steam Workshop]() 

# Usage
The complete source for LeaderLib is updated here for learning purposes. I encourage you to study the source and ask questions.

## Contributing to this project

* [Bug reports](CONTRIBUTING.md#bugs)
* [Feature requests](CONTRIBUTING.md#features)
* [Pull requests](CONTRIBUTING.md#pull-requests)

# Attribution
* [Divinity: Original Sin 2](http://store.steampowered.com/app/435150/Divinity_Original_Sin_2/), a wonderful game from [Larian Studios](http://larian.com/)
