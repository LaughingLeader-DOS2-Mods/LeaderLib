LeaderLib Mod for Divinity: Original Sin 2 - Definitive Edition
=======
LeaderLib is a library mod used to provide common functionality to other mods.

# Releases
* [GitHub Release](https://github.com/LaughingLeader-DOS2-Mods/LeaderLib/releases/tag/mod-releases)
* Nexus (Coming Soon)
* Steam Workshop (Coming Soon)

# Support
If you're feeling generous, an easy way to show support is by tipping me a coffee:

[![Tip Me a Coffee](https://i.imgur.com/NkmwXff.png)](https://ko-fi.com/LaughingLeader)

All coffee goes toward fueling future and current development efforts. Thanks!

# Mod Authors
### Using LeaderLib
Check the [Leaderlib Wiki](https://github.com/LaughingLeader-DOS2-Mods/LeaderLib/wiki) for information on using LeaderLib with your mod.

# Main Features

## Mod Support
LeaderLib is, at its core, a way for mods to work together. It provides:

#### Mod Menu
LeaderLib includes a centralized "**Mod Menu**" for other mods to register dialog menus to. No longer is there a need for every individual mod to provide a separate settings book.

#### Dependency-Free Integration
Mods can add LeaderLib support with no dependencies required, thanks to LeaderLib's ModAPI system. Additional freatures include:
* A way to see what mods were registered with LeaderLib.
* A way to see what mods are currently active (provided they register in a way LeaderLib recognizes them). This lets mods work together without requiring a strict dependency.

## Treasure & Trader System
LeaderLib features a script-based treasure and trader system, which can be used to spawn both traders and loot dynamically, with a multitude of customization:

* Default events for when traders spawn and treasure generates, as well as the option to set custom events to fire when they're created.

#### Requirements
Requirements (party level, flag, or region) can be created and set for specific treasure and traders, preventing them from spawning until a requirement is met.
* Flag requirements can be object or global flags, and can be set to true or false (if the flag is set or not set).
* Treasure and traders can be set to spawn as soon as requirements are unlocked.
* Requirements can be re-used between multiple traders and treasure.

#### Queue System
A queue system is used when creating both treasure and traders, making spawning large amounts of objects less taxing on the game. The queue also has a timeout system in place, for when something goes wrong.

### Treasure-Specific
* Various generation types to specify *when* treasure can generate.
* Item templates, item stats, and treasure tables can be registered to specific "Treasure IDs".
* Delta mods and runes (with optional randomization), can be assigned to item entries.
* Item levels can be configured to a specific character level, a range of levels (i.e. 5-13, 4-7), or the party's level.
* Both traders and containers can be set to "generate endlessly" (i.e. every time the chest is opened, or the trader is talked to), provided the treasure requirements are met.

### Trader-Specific
* Support for global characters or characters that need to be spawned first.
* Starting gold for traders on specific levels.
* Multiple dialogs for traders on specific levels (optional), with optional requirements.
* Positions on specific levels can be assigned via coordinates, triggers, or objects (i.e. teleporting to a specific chair, or a character).
* Seats can be assigned to traders, so they'll sit after spawning.
* Traders can be set to generate treasure when dialog starts (rather than during trade generation by default).

## Retired Trader
LeaderLib adds a new trader to the main campaign that persists through every act. He exists as a central trader for mod-specific items added by all my mods. He also provides the "Mod Menu" book.

# Additional Features

## Mod Detection
* Active, registered mods can be queried, with a "Mod Found" and "Mod Not Found" event specified.

## Dependency-Free Api
Through flags, events, and databases, integration with LeaderLib can be done without actually setting it as a dependency in the editor. Read more on that here: [LeaderLib Wiki: Dependency Free Integration](https://github.com/LaughingLeader-DOS2-Mods/LeaderLib/wiki/Dependency-Free).

## Create Item by Stat
Items can be generated by stats through story, separately from the main generation queue, and equipped immediately. Normally this is only available through behavior scripts, but LeaderLib uses a combination of a dummy generator character and a queue system to generate items by stats dynamically through a story script.

When an item is generated by its stat, LeaderLib also stores the stat used to create that template on the item itself, providing an accurate way to identify or replicate it down the road (currently the GetStatString query in Osiris is unreliable).

### Event Flow System
When you want a specific set of events to take place in order, the Event Flow system is ideal. It consists of:

* A "stack" which contains the default wait time between events, the default timeout time, and the event to send when the stack is complete.
* An array of entries, which contain a "start" event to send out, and a "completion" event to listen for. When a stack entry is chosen, it sends out the start event and waits for the complete event before moving to the next entry in the stack.
* A timeout timer that prevents the stack from getting stuck if a completion event never fires.

Stacks may also have a customizable wait times for specific completion events, i.e., if you want the general wait time to be 50ms, but want the wait time between "Event A Completed" and "Event B Start" to be 500ms.

## Queue System
For when you want to process databases entries in a specific order, one by one, with a timeout timer making sure nothing gets stuck.

Queues are configured the follow way:
* Tick time to configure the time between each entry being processed.
* Timeout time to configure how long to wait before triggering the timeout event and moving on.
* "Process Entry" event is called when dealing with each queue entry.
* "Process Complete" event tells the queue to continue.
* "Process Timed Out" event to react when an entry times out.
* "Queue Complete" when the queue is done processing entries, this event is sent out and the queue is cleaned up.

## String Extensions
In order to make sorting strings a reality, strings themselves were expanded on.

### String Length
The length of a string can be calculated, providing an easier way to iterate through its characters.

### String Comparison
Strings can be compared to see which is greater/lesser, and the results are cached in a database for fast re-use.

### String Sorting
Strings are sorted according to the ASCII sorting order. Note that this means currently 10 will come after 1, so pad out your numbers.

The plan is to support a lexicographical sort order down the road.

## Arrays and Dictionaries
Index-based databases are useful for iterating through entries in a specific order. LeaderLib adds its own implemention of index-based databases through string-based arrays (array ID, index, string value) and dictionarys (array ID, index, string key, string value).

These databases also come with self-managing lengths (the amount of entries in the arrays), iterators `(DB_LLLIB_Array_Iterator(_ArrayID, _Index))` for iterating through the arrays in order, and set of helper-functions:

* `LLLIB_Array_GetFirstEntry`
	* Returns the entry with the smallest index in the array.
* `LLLIB_Array_Pop`
	* "Pops" the top entry in an array (index 0), shift all other entries up, and returns the entry. Used by the queue system to process entries one-by-one, in order.
	
## Iterators
LeaderLib also provides an easy way to create an "iterator" database, that is, one that returns a set of numbers in order, for iterating through databases in order.

# Usage
The complete source for LeaderLib is updated here for learning purposes. I encourage you to study the source and ask questions.

## Contributing to this project

* [Bug reports](CONTRIBUTING.md#bugs)
* [Feature requests](CONTRIBUTING.md#features)
* [Pull requests](CONTRIBUTING.md#pull-requests)

# Attribution
* [Divinity: Original Sin 2](http://store.steampowered.com/app/435150/Divinity_Original_Sin_2/), a wonderful game from [Larian Studios](http://larian.com/)
