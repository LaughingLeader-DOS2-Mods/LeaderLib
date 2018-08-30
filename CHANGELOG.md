LeaderLib Changelog
=======
# 1.0.0.0 (Coming Soon!)
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
