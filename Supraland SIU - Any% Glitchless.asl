// Current as of version 1.2.3349 - May 6 2024
state("SupralandSIU-Win64-Shipping")
{
    // Most of the setup that normally goes here is done now with MemoryWatchers in init.
    // For stuff that's different than the rest, we do it here.
    bool inputDisabled : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x580, 0x398;
    byte pickaxe : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xee8;
    byte area : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x1318;
}

startup
{
    vars.settings = new Dictionary<string, Tuple<string, string>> {
        { "TutorialDone", Tuple.Create("Down the Pipe", "Split on going down the pipe during the intro cutscene.") },
        { "SkillWalkSpeedx2", Tuple.Create("Speed Upgrade", "Split on picking up the speed upgrade in the bunker.") },
        { "JumpHeightPlus", Tuple.Create("High Jump", "Split on picking up the high jump upgrade.") },
        { "SkillCrouch", Tuple.Create("Crouch", "Split on picking up the crouch upgrade.") },
        { "Pickaxe", Tuple.Create("Pickaxe & Upgrades", "Split on picking up the wooden pickaxe, stone, iron, or diamond.") },
        { "MinesToCage", Tuple.Create("Mines to Cage", "Split on going from Mines to Cage area.") },
        { "SkillHasGrapple", Tuple.Create("Grapple Beam", "Split on picking up the grapple beam.") },
        { "SkillHasBelt", Tuple.Create("Magnet Belt", "Split on picking up the magnet belt.") },
        { "CageToFactory", Tuple.Create("Cage to Factory", "Split on going from Cage to Factory area.") },
        { "MagnetRepel", Tuple.Create("Magnet Belt Repel", "Split on picking up the magnet belt repel upgrade.") },
        { "CageToBank", Tuple.Create("Cage to Bank", "Split on going from Cage to Bank area.") },
        { "SkillHasElectricGun", Tuple.Create("Electric Gun", "Split on picking up the electric gun.") },
        { "SkillGrappleGold", Tuple.Create("Grapple Beam Gold Upgrade", "Split on picking up the grapple beam gold upgrade.") },
        { "Strong", Tuple.Create("Strength", "Split on getting strong in the gym.") },
        { "SkillHasForceBlock", Tuple.Create("Force Cube", "Split on getting the Force Cube.") },
        { "SkillHasTranslocator", Tuple.Create("Translocator", "Split on getting the Translocator.") },
        { "BeachToCastle", Tuple.Create("Beach to Castle", "Split on going from Beach to Castle area.") },
        { "CastleToCage", Tuple.Create("Castle to Cage", "Split on going from Castle to cage area.") },
        { "Endgame", Tuple.Create("End", "Split on hitting the endgame trigger.") },
    };

    settings.Add("splits", true, "Splits");
    settings.CurrentDefaultParent = "splits";
    foreach (string key in vars.settings.Keys) {
        settings.Add(key, true, vars.settings[key].Item1);
        settings.SetToolTip(key, vars.settings[key].Item2);
    }
}

init {
    // Map the keys to the final segment of the pointer address inside the character controller.
    // At time of writing they're all in there, so I'm trying to keep the amount of code minimal to avoid typos.
    var memoryFlags = new Dictionary<string, int> {
        { "TutorialDone", 0x7bb },
        { "SkillWalkSpeedx2", 0x7c2 },
        { "JumpHeightPlus", 0xa48 },
        { "SkillCrouch", 0x1319 },
        { "SkillHasGrapple", 0x7cc },
        { "SkillHasBelt", 0x7c9 },
        { "MagnetRepel", 0xec3 },
        { "SkillHasElectricGun", 0x1200 },
        { "SkillGrappleGold", 0xe88 },
        { "Strong", 0xe82 },
        { "SkillHasForceBlock", 0x7c3 },
        { "SkillHasTranslocator", 0x7ce },
        { "Endgame", 0xeac }
    };

    // Watchers are what we use to check state from the game's memory.
    vars.watchers = new MemoryWatcherList();

    // This is where we separately track things that have happened to avoid weird issues with cutscenes
    // taking away our items.
    vars.collected = new Dictionary<string, bool>();

    // Build the above variables from the single array. I do it this way to once again keep a single
    // source of truth for the key names and memory addresses.
    foreach (var flag in memoryFlags) {
        vars.watchers.Add(new MemoryWatcher<bool>(new DeepPointer(0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, flag.Value)) { Name = flag.Key });
        vars.collected.Add(flag.Key, false);
    }
    // If at some point I have other flags that don't sit inside FirstPersonCharacter, add them manually right here.

    // Special case for pickaxe, since it's a byte instead of a bool and the tier matters.
    vars.collectedPickaxe = 0;

    // Special case for area transitions.
    vars.triggeredMinesToCage = false;
    vars.triggeredCageToFactory = false;
    vars.triggeredCageToBank = false;
    vars.triggeredCageToBeach = false;
    vars.triggeredBeachToCastle = false;
    vars.triggeredCastleToCage = false;
}

// Start the auto-splitter when this returns true.
start
{
    // This is buried deep within the character controller, in the action manager.
    // However, it does seem to trigger exactly at the right time.
    // Finding this took me longer than the rest of the script to this point.
    if (old.inputDisabled && !current.inputDisabled) {
        print("[Autosplit] start (inputDisabled off)");
        return true;
    }
}

// Perform this whenever start (above) returns true.
onStart {
    // Reset all collected flags back to false.
    // The list is to avoid an issue with older versions of C# with modifying dictionaries during iteration.
    print("[Autosplit] resetting collected flags");
    foreach (string key in new List<string>(vars.collected.Keys)) {
        vars.collected[key] = false;
        print("[Autosplit] Collected " + key + ": " + vars.collected[key]);
    }

    // Reset pickaxe tier
    vars.collectedPickaxe = 0;

    // Reset area transition flags
    vars.triggeredMinesToCage = false;
    vars.triggeredCageToFactory = false;
    vars.triggeredCageToBank = false;
    vars.triggeredCageToBeach = false;
    vars.triggeredBeachToCastle = false;
    vars.triggeredCastleToCage = false;
}

// Run before split.
update
{
    // Because this is using watchers instead of the state block, we need to update the watchers every frame.
    vars.watchers.UpdateAll(game);
}

// If this returns true, it splits.
split
{
    // Iterate over each watcher and if it's enabled and it's different, then we split.
    // We also guard against re-setting on the same flag by checking our collected array.
    foreach (MemoryWatcher watcher in vars.watchers) {
        if (settings[watcher.Name] && !vars.collected[watcher.Name] && (bool)watcher.Old != (bool)watcher.Current && (bool)watcher.Current) {
            print("[Autosplit] " + watcher.Name);
            vars.collected[watcher.Name] = true;
            return true;
        }
    }

    // Pickaxe is separate because it's got tiers.
    if (settings["Pickaxe"] && current.pickaxe > old.pickaxe && vars.collectedPickaxe < current.pickaxe) {
        print("[Autosplit] Pickaxe tier " + current.pickaxe);
        vars.collectedPickaxe = current.pickaxe;
        return true;
    }

    // Area is different because I'm looking for specific transitions.
    if (settings["BeachToCastle"] && !vars.triggeredBeachToCastle && old.area == 5 && current.area == 8) {
        print("[Autosplit] Beach to Castle");
        vars.triggeredBeachToCastle = true;
        return true;
    }

    // Area is different because I'm looking for specific transitions.
    if (settings["CastleToCage"] && !vars.triggeredCastleToCage && old.area == 8 && current.area == 2) {
        print("[Autosplit] Castle to Cage");
        vars.triggeredCastleToCage = true;
        return true;
    }

        // Area is different because I'm looking for specific transitions.
    if (settings["MinesToCage"] && !vars.triggeredMinesToCage && old.area == 1 && current.area == 2) {
        print("[Autosplit] Mines to Cage");
        vars.triggeredMinesToCage = true;
        return true;
    }

    // Area is different because I'm looking for specific transitions.
    if (settings["CageToFactory"] && !vars.triggeredCageToFactory && old.area == 2 && current.area == 3) {
        print("[Autosplit] Cage to Factory");
        vars.triggeredCageToFactory = true;
        return true;
    }

    // Area is different because I'm looking for specific transitions.
    if (settings["CageToBank"] && !vars.triggeredCageToBank && old.area == 2 && current.area == 4) {
        print("[Autosplit] Cage to Bank");
        vars.triggeredCageToBank = true;
        return true;
    }

    // Area is different because I'm looking for specific transitions.
    if (settings["CageToBeach"] && !vars.triggeredCageToBeach && old.area == 2 && current.area == 5) {
        print("[Autosplit] Cage to Beach");
        vars.triggeredCageToBeach = true;
        return true;
    }
}