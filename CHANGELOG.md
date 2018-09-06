LeaderLib Changelog
=======
# 1.0.1.0
* Mod Menu Book
	* Made the Mod Menu book available for free by request from Old Man Lothar.
	* Swapped the Mod Menu icon for a default DOS2 one, to hopefully mitigate the current icon limitations.
		* Icon Limitations (DOS2DE v3.6.29.390): 7 texture atlases max in one UI. Multiple mods icons in the same UI, even if that mod only adds 1, make icons disappear from limitations in the engine.
* Treasure System
	* Fixed a small math mistake (1 - 4 = -3) when determining how many items to generate in certain situations.

# 1.0.0.9  
* Reworked the LeaderTrader's "avoid combat" behavior, as he may has started assaulting players in certain situations, despite his Pacifist ways. ;)

# 1.0.0.0
* Definitive Edition Release
* Refactored all LLLIB prefixed strings, databases, etc to LeaderLib.
* Bug fixes / tweaks to the treasure/trader systems.
* New helpers.
* Small optimizations to the event flow system.


# 0.9.2.0
* Added a new "Editor Helper" script
	* Contains new text events for playing animations and adding character stat points (attribute, ability, civil, talent, source/source max)
* Moved item helpers to a standalone script
* Added a new system for auto-leveling items
	* Also allows deltamods to be applied when an item reaches a specific level, allowing for equipment that gets stronger as the player levels up.
* Added a "Control Summon" skill for making a controlled summon or follower, in response to a current portrait bug making multiple summons unselectable
* Added a new character script (LLLIB_Follower) for disabling the auto-follow behavior found in summons/followers.
* Refactored procs/queries for clarity

# 0.9.1.0
* Added new helper scripts
	* Combat Helpers
		* New system that tracks whose active turn it is in combat, which objects are in combat, who killed who, and more
	* Party Helpers
		* Helpers for tracking the total number of party members
	* Skill Helpers
		* Added an easy helper for toggling a status with a skill
	* Main (Misc) Helpers
		* Added some behavior script to story events for equipment equipping/unequipping
* Added math extensions
	* New functions for power, factorials, sine and cosine
* Added flags for applying statuses and playing effects in dialog
* Added a new follower system, which helps with managing party followers

# 0.9.0.0
* Initial Public Release
