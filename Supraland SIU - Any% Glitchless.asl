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
// I've also gone a bit overboard and built a dynamic pointer resolution system
// that can traverse the game's memory graph to find actors and objects that
// aren't always present at the same memory address, which is useful for things
// like the final boss quest. This is all driven by the JSON configuration file,
// so it can be updated without touching the ASL code. In theory, anyway.
//
// A bit of documentation on the memory structure...
//
// Most pointer paths have these components:
//   GameEngine -> GameInstance -> LocalPlayers[0] -> PlayerController -> FirstPersonCharacter
state("SupralandSIU-Win64-Shipping") {}

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
    Action<JsonNode, string> buildSettings = (entries, parentSettingKey) =>  {
        if (entries != null) {
            settings.CurrentDefaultParent = parentSettingKey;

            foreach (var split in entries.AsArray()) {
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

    // Create the top-level settings category.
    settings.Add("splits", true, "Splits");

    // Build each category and its child split settings from the same config object.
    JsonNode splits = vars.Config["splits"];
    if (splits != null) {
        foreach (var category in splits.AsObject()) {
            string categoryKey = category.Key;
            JsonNode setting = category.Value["setting"];
            bool settingDefault = setting["default"] != null ? setting["default"].GetValue<bool>() : true;
            settings.Add(categoryKey, settingDefault, setting["name"].GetValue<string>(), "splits");
            settings.SetToolTip(categoryKey, setting["desc"].GetValue<string>());
            buildSettings(category.Value["entries"], categoryKey);
        }
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

    // Pointers resolved dynamically in update via vars.resolveSmartPath, keyed by dynamic_pointers name.
    vars.dynamicPtrs = new Dictionary<string, IntPtr>();
    vars.dynamicOldStates = new Dictionary<string, bool>();
    vars.dynamicScanTick = 0;

    // Keep track of any invalid step types in the dynamic pointer resolution so we don't spam the log.
    vars.invalidSmartPathTypes = new HashSet<string>();

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

    // Module-relative static address for the UE4.27 FNamePool (GNames).
    IntPtr moduleBase = modules.First().BaseAddress;
    int fNamePoolOffset = vars.Config["global_offsets"]["f_name_pool"][version].GetValue<int>();
    IntPtr fNamePoolBase = moduleBase + fNamePoolOffset;

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

    // Function factory to build a split check for a boolean flag relative to a dynamically resolved pointer.
    Func<string, string, int, Func<bool>> buildDynamicFlagRule = (key, basePointer, offset) => () => {
        if (!vars.dynamicPtrs.ContainsKey(basePointer) || (IntPtr)vars.dynamicPtrs[basePointer] == IntPtr.Zero) {
            return false;
        }

        try {
            bool currentValue = game.ReadValue<bool>((IntPtr)vars.dynamicPtrs[basePointer] + offset);
            bool oldValue = vars.dynamicOldStates.ContainsKey(key) && vars.dynamicOldStates[key];
            vars.dynamicOldStates[key] = currentValue;
            return !oldValue && currentValue;
        } catch {
            return false;
        }
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

    // Generic graph-traversal state machine driven by a JSON path sequence, so dynamic actor
    // discovery (e.g. the final boss quest) doesn't need hardcoded nested loops per target.
    // Each step is either:
    //   { "type": "module_pointer", "value": <int> }
    //     currentAddress = *(moduleBase + value)
    //   { "type": "offset", "value": <int> }
    //     currentAddress = *(currentAddress + value)
    //   { "type": "tarray_search", "array_offset": <int>, "name_pointer_offset": <int>, "target_name": <string> }
    //     Treats currentAddress + array_offset as a TArray<T*> (data ptr at +0x0, count at +0x8),
    //     resolves each element's name via the pointer at name_pointer_offset, and sets
    //     currentAddress to the matching element (or IntPtr.Zero if nothing matches).
    vars.resolveSmartPath = (Func<JsonNode, IntPtr>)((JsonNode pathSequence) => {
        IntPtr currentAddress = IntPtr.Zero;

        foreach (var step in pathSequence.AsArray()) {
            string stepType = step["type"].GetValue<string>();

            if (stepType == "module_pointer") {
                int value = step["value"].GetValue<int>();
                currentAddress = game.ReadPointer(moduleBase + value);
            } else if (stepType == "offset") {
                if (currentAddress == IntPtr.Zero) {
                    return IntPtr.Zero;
                }

                int value = step["value"].GetValue<int>();
                currentAddress = game.ReadPointer(currentAddress + value);
            } else if (stepType == "tarray_search") {
                if (currentAddress == IntPtr.Zero) {
                    return IntPtr.Zero;
                }

                // Navigate a TArray<T*> structure, searching for an element whose name matches the target_name.
                // Offset 0 is the data pointer, offset 8 is the count.
                int arrayOffset = step["array_offset"].GetValue<int>();
                int namePointerOffset = step["name_pointer_offset"].GetValue<int>();
                string targetName = step["target_name"].GetValue<string>();

                IntPtr arrayBase = currentAddress + arrayOffset;
                IntPtr arrayData = game.ReadPointer(arrayBase);
                int count = game.ReadValue<int>(arrayBase + 0x8);

                IntPtr found = IntPtr.Zero;
                for (int i = 0; i < count; i++) {
                    IntPtr itemAddress = game.ReadPointer(arrayData + i * 0x8);
                    IntPtr namePointer = game.ReadPointer(itemAddress + namePointerOffset);
                    string itemName = vars.getObjectName(namePointer);

                    if (targetName.Equals(itemName, StringComparison.Ordinal)) {
                        found = itemAddress;
                        break;
                    }
                }

                currentAddress = found;
            } else {
                if (vars.invalidSmartPathTypes.Add(stepType)) {
                    print("[Autosplit] Invalid dynamic pointer step type: " + stepType);
                }
                return IntPtr.Zero;
            }
        }

        return currentAddress;
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
    foreach (var category in vars.Config["splits"].AsObject()) {
        string categoryName = category.Key;

        // Iterate over each split within the category
        foreach (var split in category.Value["entries"].AsArray()) {
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
            } else if (categoryName == "dynamic_flags") {
                string basePointer = split["base_pointer"].GetValue<string>();
                int offset = split["offset"].GetValue<int>();
                vars.splitRules[key] = buildDynamicFlagRule(key, basePointer, offset);
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

    // Reset dynamically resolved pointers so a fresh run doesn't reuse pointers from a previous attempt.
    vars.dynamicPtrs.Clear();
    vars.dynamicOldStates.Clear();
    vars.dynamicScanTick = 0;
}

// Run before split.
update
{
    if (!vars.scriptEnabled) {
        return;
    }

    if (vars.inputDisabled != null) {
        vars.inputDisabled.Update(game);
    }
    vars.watchers.UpdateAll(game);

    // --- DEBUGGING ARENAS --- //
    vars.arenaWatchers.UpdateAll(game);

    // --- DYNAMIC POINTER RESOLUTION --- //
    // Throttled to once every 60 ticks (~a second) so failed attempts don't spam the log or burn CPU.
    // Once a pointer resolves it's left alone; it's assumed stable for the rest of the run.
    vars.dynamicScanTick = (int)vars.dynamicScanTick + 1;

    JsonNode dynamicPointers = vars.Config["dynamic_pointers"];
    if (dynamicPointers == null || (int)vars.dynamicScanTick % 60 != 0) {
        return;
    }

    // Iterate over each dynamic pointer in the config, resolving them if they haven't been resolved yet.
    // This is done in update because the things dynamic paths are needed for aren't always available on start/init.
    foreach (var dynamicPointer in dynamicPointers.AsObject()) {
        string key = dynamicPointer.Key;

        // Skip if we've already resolved this pointer.
        if (vars.dynamicPtrs.ContainsKey(key)) {
            continue;
        }

        try {
            JsonNode pathSequence = dynamicPointer.Value[version];
            IntPtr resolved = pathSequence != null ? vars.resolveSmartPath(pathSequence) : IntPtr.Zero;
            if (resolved == IntPtr.Zero) {
                continue;
            }

            vars.dynamicPtrs[key] = resolved;
            print("[Autosplit] Resolved dynamic pointer '" + key + "' at " + resolved.ToString("x"));
        } catch (Exception e) {
            print("[Autosplit] Exception while resolving dynamic pointer '" + key + "': " + e.Message);
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