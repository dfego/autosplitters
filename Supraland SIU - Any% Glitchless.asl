// Current as of version 1.2.3349 - May 6 2024
state("SupralandSIU-Win64-Shipping") {}

startup
{
    string configFilePath = "Components/Supraland SIU - Any% Glitchless.json";
    string jsonString = File.ReadAllText(configFilePath);
    vars.Config = JsonNode.Parse(jsonString);
    if (vars.Config == null) {
        print("[Autosplit] Failed to load config file: " + configFilePath);
    } else {
        print("[Autosplit] Loaded config file: " + configFilePath);
    }

    // Create categories for the settings.
    settings.Add("splits", true, "Splits");
    settings.Add("flags", true, "Flags", "splits");
    settings.Add("areas", true, "Area Transitions");
    settings.Add("pickaxe", true, "Pickaxe Upgrades", "splits");

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

    // Call the above settings builder for each split category.
    if (vars.Config["splits"] != null) {
        buildSettings(vars.Config["splits"]["flags"], "flags");
        buildSettings(vars.Config["splits"]["area_transitions"], "areas");
        buildSettings(vars.Config["splits"]["pickaxe_tiers"], "pickaxe");
    }
}

init {
    // Watchers are what we use to check state from the game's memory.
    // Declare this early so update doesn't freak out if it's an Unknown version.
    vars.watchers = new MemoryWatcherList();

    // This is where we separately track things that have happened to avoid weird issues with cutscenes
    // taking away our items.
    vars.triggered = new Dictionary<string, bool>();

    // Get memory size of first module for version detection.
    int memorySize = modules.First().ModuleMemorySize;

    // Look up the version, defaulting to "Unknown" if we don't have that version.
    if (vars.Config["versions"] != null && vars.Config["versions"][memorySize.ToString()] != null) {
        version = vars.Config["versions"][memorySize.ToString()].GetValue<string>();
        print("[Autosplit] Detected game version: " + version);
    } else {
        print("[Autosplit] Unknown game version with memory size: " + memorySize);
        return false;
    }

    // Dictionary for what function to call for each split.
    vars.splitRules = new Dictionary<string, Func<bool>>();

    // *** HELPER FUNCTIONS BEGIN *** //

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

    // *** HELPER FUNCTIONS END *** //

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
    foreach (var sharedPointer in vars.Config["shared_split_pointers"].AsObject()) {
        DeepPointer pointerPath = buildPointer(sharedPointer.Value[version]);
        vars.watchers.Add(new MemoryWatcher<byte>(pointerPath) { Name = sharedPointer.Key });
    }
}

// Start the auto-splitter when this returns true.
start
{
    if (vars.inputDisabled != null &&
        vars.inputDisabled.Old != null &&
        (bool)vars.inputDisabled.Old &&
        !(bool)vars.inputDisabled.Current) {
        print("[Autosplit] start (input disabled off)");
        return true;
    }
}

// Perform this whenever start (above) returns true.
onStart {
    // Reset all triggered flags back to false.
    // The list is to avoid an issue with older versions of C# with modifying dictionaries during iteration.
    print("[Autosplit] resetting triggered flags");
    foreach (string key in new List<string>(vars.triggered.Keys)) {
        vars.triggered[key] = false;
    }
}

// Run before split.
update
{
    if (version != "Unknown") {
        if (vars.inputDisabled != null) {
            vars.inputDisabled.Update(game);
        }
        vars.watchers.UpdateAll(game);
    }
}

// If this returns true, it splits.
split
{
    if (version == "Unknown") {
        return false;
    }

    // Iterate over the split rules built in init.
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