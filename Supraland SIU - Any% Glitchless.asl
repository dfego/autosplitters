// Supraland SIU - Any% Glitchless Autosplitter
// Author: Dan Fego / Delphi
// Last updated: 2026-08-10
//
// This script handles autosplitting for Supraland SIU, and was designed for
// the Any% Glitchless category. It is driven by a JSON file that I generate
// alongside this script from a more manageable YAML file. These files contain
// all the relevant split information for every supported game version.
//
// The intention of this separation of script and data is to make it easier to
// update and maintain over time, with many updates not requiring code changes.
//
// A bit of documentation on the memory structure...
//
// Most pointer paths have these components:
//   GameEngine -> GameInstance -> LocalPlayers[0] -> PlayerController -> FirstPersonCharacter
//
// Notes to self:
// - lamps
// - encounters
// final boss might be festering ghoul
// - aggro mode might be able to indicate starting?
// - bFinished might indicate defeat?
// - finding this memory address might be hard
// maybe ABP_AbsorbSpawner_Base_C
// maybe ABP_SpecificArenaSpawner_C
// "town" floor 3?
// player has a "spawners" array at 13E8
// These have isComplete at 2d0 (part of ABP_AbsorbSpawner_Base_C)
// and bSpawnerActive at 0x371
// and bPlayerIsInArenaTriggerArea
// and bPlayerHasEnteredArenaOnce
// Figuring out which is which might be hard, there's like 30.
// Okay so let's add, from player:
// 0x13E8 -> 0x2d0 isComplete
// 0x13E8 -> 0x377 bPlayerIsInArenaTriggerArea
// 0x13E8 -> 0x378 bPlayerHasEnteredArenaOnce
// allll of them? there's 29.
// maybe create a loop for all of them in code (loL) and then see which ones pop up in the logs as I play?
// GWorld = 0x4dd3de0
// UWorld -> PersistentLevel (0x30) -> Actors (0x98)
// omg finalbossquest...
// 0x12ce2b1e010
// okay, so finalbossquest can seemingly be via dlc2complete > levels[X] -- but X not consistent?
// like it literally has at 0x230 FinalBossQuest_4_ExecuteUberGraph_DLC2_FinallBoss_RefProperty that goes to it?
// but how to find which element in the array...
// What about DLC2_FinalBoss_C?
// GNames 0x4C4F980
state("SupralandSIU-Win64-Shipping")
{
    // int bool : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xd09;
}

// Handle all startup logic that does not require the game to be running.
// This includes opening the JSON config file, parsing it, and generating the
// setting shown to the user in the LiveSplit UI.
startup
{
    vars.scriptEnabled = true;
    vars.disableReason = "";

    // Load the file
    string configFilePath = "Components/Supraland SIU - Any% Glitchless.json";
    try {
        string jsonString = File.ReadAllText(configFilePath);
        vars.Config = JsonNode.Parse(jsonString);
    } catch (Exception e) {
        vars.Config = null;
        print("[Autosplit] Exception while loading config: " + e.Message);
    }

    // Validate we have a config at all.
    if (vars.Config == null) {
        vars.scriptEnabled = false;
        vars.disableReason = "config load/parse failed";
        print("[Autosplit] Disabled: " + vars.disableReason + " (" + configFilePath + ")");
    } else {
        print("[Autosplit] Loaded config file: " + configFilePath);
    }

    // If we don't have splits, nothing else makes sense.
    if (vars.Config["splits"] == null) {
        print("[Autosplit] No splits found in config file.");
        vars.scriptEnabled = false;
        vars.disableReason = "no splits found at top level of config";
    }

    // Helper delegate to build the settings displayed to the user.
    Action<JsonNode, string> buildSettings = (categoryNode, parentSettingKey) =>  {
        if (categoryNode != null) {
            // Ensure all the following settings are children of the parentSettingKey in the UI.
            settings.CurrentDefaultParent = parentSettingKey;

            // Iterate over each split
            foreach (var split in categoryNode.AsArray()) {
                string key = split["key"].GetValue<string>();
                var settingNode = split["setting"];
                if (settingNode != null) {
                    string settingName = settingNode["name"].GetValue<string>();
                    string settingDesc = settingNode["desc"].GetValue<string>();
                    bool settingDefault = settingNode["default"] != null ? settingNode["default"].GetValue<bool>() : true;
                    settings.Add(key, settingDefault, settingName);
                    settings.SetToolTip(key, settingDesc);
                }
            }
        }
    };

    // TODO maybe generate the categories from the config file instead of hardcoding
    // them here, but this is fine for now.

    // Create categories for the settings
    settings.Add("splits", true, "Splits");
    settings.Add("flags", true, "Flags", "splits");
    settings.Add("areas", true, "Area Transitions", "splits");
    settings.Add("pickaxe", true, "Pickaxe Upgrades", "splits");

    // Call the above settings builder for each split category.
    if (vars.Config != null && vars.Config["splits"] != null) {
        buildSettings(vars.Config["splits"]["flags"], "flags");
        buildSettings(vars.Config["splits"]["area_transitions"], "areas");
        buildSettings(vars.Config["splits"]["pickaxe_tiers"], "pickaxe");
    }
}

// Handle all initialization logic that happens when attaching to the game.
// We do most of the work here, bridging the gap between the configuration and the variables
// the update and split sections use.
init
{
    if (!vars.scriptEnabled) {
        print("[Autosplit] Disabled: " + vars.disableReason);
        return false;
    }

    // --- VARIABLES --- //

    // General ASL note: anything in vars is shared between sections and persistent across updates and splits.

    // Watchers are what we use to check state from the game's memory.
    // Declare this early so update doesn't freak out if it's an Unknown version.
    vars.watchers = new MemoryWatcherList();

    // This is where we separately track things that have happened to avoid weird issues with cutscenes
    // taking away our items.
    vars.triggered = new Dictionary<string, bool>();

    // Dictionary for what function to call for each split.
    vars.splitRules = new Dictionary<string, Func<bool>>();

    // Resolved dynamically in update by walking GWorld -> Levels -> Actors; null until found.
    vars.liveQuestPtr = IntPtr.Zero;
    vars.bossLevelPtr = IntPtr.Zero;
    vars.questScanTick = 0;
    vars.statusScanTick = 0;
    vars.questStarted = null;
    vars.questComplete = null;

    // --- VERSION CHECKING --- //

    // Get memory size of first module for version detection.
    int memorySize = modules.First().ModuleMemorySize;

    // Look up the version, defaulting to "Unknown" if we don't have that version.
    if (vars.Config["versions"] != null && vars.Config["versions"][memorySize.ToString()] != null) {
        version = vars.Config["versions"][memorySize.ToString()].GetValue<string>();
        print("[Autosplit] Detected game version: " + version);
    } else {
        print("[Autosplit] Unknown game version with memory size: " + memorySize);
        vars.scriptEnabled = false;
        vars.disableReason = "unknown game version";
        return false;
    }

    // --- STATIC ADDRESSES --- //

    // Module-relative static addresses for GWorld and the UE4.27 FNamePool (GNames).
    IntPtr moduleBase = modules.First().BaseAddress;
    vars.gWorldAddress = moduleBase + 0x4dd3de0;
    vars.fNamePoolBase = moduleBase + 0x4c4f980;

    // --- HELPER FUNCTIONS --- //

    // Helper function for buliding pointer maps from the arrays
    Func<JsonNode, DeepPointer> buildPointer = (node) => {
        var arr = node.AsArray();
        int baseAddress = arr[0].GetValue<int>();
        int[] offsets = arr.Skip(1).Select(x => x.GetValue<int>()).ToArray();
        return new DeepPointer(baseAddress, offsets);
    };

    // Function factory to build a split check for boolean flags.
    Func<string, Func<bool>> buildFlagRule = (key) => () => {
        // Safely check if the old value is different from the current value.
        var w = vars.watchers[key];
        return w.Old != null && w.Current != null && (bool)w.Old != (bool)w.Current;
    };

    // Function factory to build a split check for pickaxe upgrades.
    Func<int, Func<bool>> buildPickaxeRule = (targetTier) => () => {
        var w = vars.watchers["pickaxe_tier"];
        return w.Old != null && w.Current != null && (byte)w.Old < (byte)w.Current && (byte)w.Current == targetTier;
    };

    // Function factory to build a split check for pickaxe upgrades.
    Func<int, int, Func<bool>> buildAreaTransitionRule = (fromArea, toArea) => () => {
        var w = vars.watchers["area"];
        return w.Old != null && w.Current != null && (byte)w.Old == fromArea && (byte)w.Current == toArea;
    };

    // Resolves a UObject's FName by decoding the UE4.27 FNamePool entry it points to.
    vars.getObjectName = (Func<IntPtr, string>)((IntPtr obj) => {
        if (obj == IntPtr.Zero) {
            return null;
        }

        try {
            int comparisonIndex = game.ReadValue<int>(obj + 0x18);
            int block = comparisonIndex >> 16;
            int offset = comparisonIndex & 0xffff;

            IntPtr fNamePoolBase = (IntPtr)vars.fNamePoolBase;
            IntPtr chunkBase = game.ReadPointer(fNamePoolBase + 0x10 + (block * 0x8));
            if (chunkBase == IntPtr.Zero) {
                return null;
            }

            IntPtr entryAddress = chunkBase + (offset * 2);
            ushort header = game.ReadValue<ushort>(entryAddress);
            bool isWide = (header & 1) != 0;
            int length = (header >> 6) & 0x3ff;
            if (length <= 0 || length > 1024) {
                return null;
            }

            if (isWide) {
                byte[] raw = game.ReadBytes(entryAddress + 2, length * 2);
                return System.Text.Encoding.Unicode.GetString(raw);
            } else {
                byte[] raw = game.ReadBytes(entryAddress + 2, length);
                return System.Text.Encoding.ASCII.GetString(raw);
            }
        } catch {
            return null;
        }
    });

    // --- MEMORY WATCHERS AND SPLIT RULES --- //

    // This is the variable used to watch for starting the timer.
    vars.inputDisabled = null;
    if (vars.Config["start_pointers"] != null &&
        vars.Config["start_pointers"]["input_disabled"] != null &&
        vars.Config["start_pointers"]["input_disabled"][version] != null) {
        DeepPointer startPointer = buildPointer(vars.Config["start_pointers"]["input_disabled"][version]);
        vars.inputDisabled = new MemoryWatcher<bool>(startPointer) { Name = "inputDisabled" };
    }

    // Build rules and watchers, iterating over each unique key under splits.
    foreach (var splitsCategory in vars.Config["splits"].AsObject()) {
        string categoryName = splitsCategory.Key;

        // Iterate over each split within the category
        foreach (var split in splitsCategory.Value.AsArray()) {
            string key = split["key"].GetValue<string>();
            vars.triggered[key] = false;

            if (categoryName == "flags") {
                DeepPointer pointerPath = buildPointer(split["pointer_paths"][version]);
                vars.watchers.Add(new MemoryWatcher<bool>(pointerPath) { Name = key });
                vars.splitRules[key] = buildFlagRule(key);
            } else if (categoryName == "pickaxe_tiers") {
                vars.splitRules[key] = buildPickaxeRule(split["tier"].GetValue<int>());
            } else if (categoryName == "area_transitions") {
                vars.splitRules[key] = buildAreaTransitionRule(split["from"].GetValue<int>(), split["to"].GetValue<int>());
            }
        }
    }

    // Grab the pointers used by multiple splits and add them to watchers.
    if (vars.Config["shared_split_pointers"] != null) {
        foreach (var sharedPointer in vars.Config["shared_split_pointers"].AsObject()) {
            DeepPointer pointerPath = buildPointer(sharedPointer.Value[version]);
            vars.watchers.Add(new MemoryWatcher<byte>(pointerPath) { Name = sharedPointer.Key });
        }
    }

    // --- DEBUGGING ARENAS --- //
    // Awesome, the ordering seems consistent.
    // Important ones
    // - 13: Pre-Bank Arena
    // - 14: Inside Bank Arena
    // - 15: Pre-Beach Arena
    //
    // Use 378 for ground trigger, or 371 for spawn trigger...
    // Use 2d0 for completion
    vars.arenaWatchers = new MemoryWatcherList();

    // In a 64-bit game, pointers are 8 bytes long
    int pointerSize = 0x8;
    int[] targetOffsets = new int[] { 0x2d0, 0x371, 0x377, 0x378 }; // isComplete, bSpawnerActive, bPlayerIsInArenaTriggerArea, bPlayerHasEnteredArenaOnce

    for (int i = 0; i < 29; i++) {
        foreach (int offset in targetOffsets) {

            // The offset inside the TArray buffer to reach this specific pointer
            int pointerOffsetInArray = i * pointerSize;

            // Your path
            // -> Offset to the specific pointer (pointerOffsetInArray)
            // -> Target boolean offset inside the Arena struct (offset)
            var ptr = new DeepPointer(
                0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x13e8,
                pointerOffsetInArray,
                offset
            );

            string watcherName = "Arena_" + i + "_Offset_0x" + offset.ToString("x");
            vars.arenaWatchers.Add(new MemoryWatcher<bool>(ptr) { Name = watcherName });
        }
    }
}

// Start the auto-splitter when this returns true.
start
{
    if (vars.scriptEnabled &&
        vars.inputDisabled != null &&
        vars.inputDisabled.Old != null &&
        (bool)vars.inputDisabled.Old &&
        !(bool)vars.inputDisabled.Current) {
        print("[Autosplit] start (input disabled off)");
        return true;
    }
}

// Perform this after start (above) returns true.
onStart
{
    // Reset all triggered flags back to false.
    // The list is to avoid an issue with older versions of C# with modifying dictionaries during iteration.
    print("[Autosplit] resetting triggered flags");
    foreach (string key in new List<string>(vars.triggered.Keys)) {
        vars.triggered[key] = false;
    }

    // Reset final boss quest discovery/status so a fresh run doesn't reuse pointers from a previous attempt.
    vars.liveQuestPtr = IntPtr.Zero;
    vars.bossLevelPtr = IntPtr.Zero;
    vars.questScanTick = 0;
    vars.statusScanTick = 0;
    vars.questStarted = null;
    vars.questComplete = null;
}

// Run before split.
update
{
    if (vars.scriptEnabled) {
        if (vars.inputDisabled != null) {
            vars.inputDisabled.Update(game);
        }
        vars.watchers.UpdateAll(game);

        // --- DEBUGGING ARENAS --- //
        vars.arenaWatchers.UpdateAll(game);

        // --- FINAL BOSS QUEST DISCOVERY --- //
        // Only scan once; the level/actor never move once resolved for the session.
        // Throttled to once every 120 ticks (~a couple seconds) so failed attempts don't spam the log or burn CPU.
        if ((IntPtr)vars.liveQuestPtr == IntPtr.Zero) {
            vars.questScanTick = (int)vars.questScanTick + 1;

            if ((int)vars.questScanTick % 120 == 0) {
                try {
                    IntPtr gWorld = game.ReadPointer((IntPtr)vars.gWorldAddress);
                    IntPtr persistentLevel = gWorld != IntPtr.Zero ? game.ReadPointer(gWorld + 0x30) : IntPtr.Zero;

                    if (persistentLevel != IntPtr.Zero) {
                        // Find the DLC2 final boss level's LevelScriptActor.
                        // Levels is a TArray<ULevel*> on UWorld itself, not on PersistentLevel/ULevel.
                        if ((IntPtr)vars.bossLevelPtr == IntPtr.Zero) {
                            IntPtr levelsData = game.ReadPointer(gWorld + 0x138);
                            int levelsCount = game.ReadValue<int>(gWorld + 0x140);

                            for (int i = 0; i < levelsCount; i++) {
                                IntPtr levelPtr = game.ReadPointer(levelsData + i * 0x8);
                                IntPtr levelScriptActor = game.ReadPointer(levelPtr + 0xe8);
                                string levelName = vars.getObjectName(levelScriptActor);

                                if (levelName != null && levelName.StartsWith("DLC2_FinalBoss_C")) {
                                    vars.bossLevelPtr = levelScriptActor;
                                    print("[Autosplit] Found boss level: " + levelName);
                                    break;
                                }
                            }
                        }

                        // The LevelScriptActor holds a direct reference to the quest object at 0x230.
                        if ((IntPtr)vars.bossLevelPtr != IntPtr.Zero) {
                            IntPtr questPtr = game.ReadPointer((IntPtr)vars.bossLevelPtr + 0x230);
                            string questName = vars.getObjectName(questPtr);
                            print("[Autosplit] [quest scan] questPtr=" + questPtr.ToString("x") + " questName=" + (questName ?? "(null)"));

                            if (questPtr != IntPtr.Zero && questName != null && questName.StartsWith("FinalBossQuest", StringComparison.OrdinalIgnoreCase)) {
                                vars.liveQuestPtr = questPtr;
                                print("[Autosplit] Found final boss quest: " + questName);
                            }
                        }
                    }
                } catch (Exception e) {
                    print("[Autosplit] Exception while resolving final boss quest: " + e.Message);
                }
            }
        }

        // --- FINAL BOSS QUEST STATUS (DEBUGGING) --- //
        if ((IntPtr)vars.liveQuestPtr != IntPtr.Zero) {
            vars.statusScanTick = (int)vars.statusScanTick + 1;

            try {
                IntPtr bossEnemyPtr = game.ReadPointer((IntPtr)vars.liveQuestPtr + 0x298);

                if (bossEnemyPtr != IntPtr.Zero) {
                    bool bAgroMode = game.ReadValue<bool>(bossEnemyPtr + 0xc88);
                    if (vars.questStarted == null || (bool)vars.questStarted != bAgroMode) {
                        print("[Autosplit] bAgroMode changed: " + vars.questStarted + " -> " + bAgroMode);
                        vars.questStarted = bAgroMode;
                    }

                    bool bFinished = game.ReadValue<bool>(bossEnemyPtr + 0xd44);
                    if (vars.questComplete == null || (bool)vars.questComplete != bFinished) {
                        print("[Autosplit] bFinished changed: " + vars.questComplete + " -> " + bFinished);
                        vars.questComplete = bFinished;
                    }
                }
            } catch (Exception e) {
                print("[Autosplit] Exception while reading quest status: " + e.Message);
            }
        }
    }
}

// If this returns true, it splits.
split
{
    if (!vars.scriptEnabled) {
        return false;
    }

    // Iterate over the split rules built in init. This is simple and concise as a result of all the work
    // done in init to build the rules and watchers from the data file. Each rule is a function that
    // returns true if the split should trigger.
    foreach (var rule in vars.splitRules) {
        string key = rule.Key;
        Func<bool> evaluateLogic = rule.Value;

        if (settings[key] && !vars.triggered[key] && evaluateLogic()) {
            print("[Autosplit] Split triggered: " + key);
            vars.triggered[key] = true;
            return true;
        }
    }
}