// Current as of version 1.2.3349 - May 6 2024
state("SupralandSIU-Win64-Shipping")
{
    // Most of the setup that normally goes here is done now with MemoryWatchers in init.
    // For stuff that's different than the rest, we do it here.
    byte pickaxe : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xee8;
    byte area : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x1318;
}

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

    // Area transition "constants". I'd make an enum but I don't think I can do that here.
    vars.areas = new Dictionary<string, byte> {
        { "Mines", 1 },
        { "Cage", 2 },
        { "Factory", 3 },
        { "Bank", 4 },
        { "Beach", 5 },
        { "Castle", 8 },
    };

    // Area transitions we actually care about, using the strings defined above.
    vars.areaTransitions = new List<Tuple<string, string>> {
        Tuple.Create("Mines", "Cage"),
        Tuple.Create("Cage", "Factory"),
        Tuple.Create("Cage", "Bank"),
        Tuple.Create("Cage", "Beach"),
        Tuple.Create("Beach", "Castle"),
        Tuple.Create("Castle", "Cage"),
    };

    // Pickaxe "constants".
    vars.pickaxeTiers = new Dictionary<string, byte> {
        // { "None", 0},
        { "Wood", 1 },
        { "Stone", 2 },
        { "Iron", 3 },
        { "Diamond", 4 },
    };

    // Add splits from the config file
    settings.Add("splits", true, "Splits");
    settings.CurrentDefaultParent = "splits";
    foreach (var split in vars.Config["splits"]["flags"].AsArray()) {
        string key = split["key"].GetValue<string>();
        // print("[Autosplit] Adding setting for: " + key);
        if (split["setting"] != null) {
            var setting = split["setting"];
            string setting_name = setting["name"].GetValue<string>();
            string setting_desc = setting["desc"].GetValue<string>();
            bool setting_default = setting["default"] != null ? setting["default"].GetValue<bool>() : true;
            settings.Add(key, setting_default, setting_name);
            settings.SetToolTip(key, setting_desc);
        }
    }

    // This creates a sub-setting of areas under splits and adds the area transitions.
    settings.Add("areas", true, "Area Transitions");
    settings.CurrentDefaultParent = "areas";
    foreach (var transition in vars.areaTransitions) {
        string fromArea = transition.Item1;
        string toArea = transition.Item2;
        string settingKey = fromArea + "To" + toArea;
        string settingName = fromArea + " to " + toArea;
        string settingTooltip = "Split on going from the " + fromArea + " area to the " + toArea + " area for the first time.";

        settings.Add(settingKey, true, settingName);
        settings.SetToolTip(settingKey, settingTooltip);
    }

    // Handle pickaxe upgrades as well.
    settings.CurrentDefaultParent = "splits";
    settings.Add("pickaxe", true, "Pickaxe Upgrades");
    settings.CurrentDefaultParent = "pickaxe";
    foreach (var tier in vars.pickaxeTiers) {
        string settingKey = "Pickaxe" + tier.Key;
        string settingName = "Pickaxe: " + tier.Key;
        string settingTooltip = "Split on picking up the " + tier.Key + " pickaxe.";

        settings.Add(settingKey, true, settingName);
        settings.SetToolTip(settingKey, settingTooltip);
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

    // Helper function for buliding pointer maps from the arrays
    Func<JsonNode, DeepPointer> buildPointer = (node) => {
        var arr = node.AsArray();
        int baseAddress = arr[0].GetValue<int>();
        int[] offsets = arr.Skip(1).Select(x => x.GetValue<int>()).ToArray();
        return new DeepPointer(baseAddress, offsets);
    };

    // This is the variable used to watch for starting the timer.
    vars.inputDisabled = null;
    if (vars.Config["start_pointers"] != null &&
        vars.Config["start_pointers"]["input_disabled"] != null &&
        vars.Config["start_pointers"]["input_disabled"][version] != null) {
        DeepPointer startPointer = buildPointer(vars.Config["start_pointers"]["input_disabled"][version]);
        vars.inputDisabled = new MemoryWatcher<bool>(startPointer) { Name = "inputDisabled" };
    }

    // Build the above variables from the single array. I do it this way to once again keep a single
    // source of truth for the key names and memory addresses.
    foreach (var split in vars.Config["splits"]["flags"].AsArray()) {
        string key = split["key"].GetValue<string>();
        DeepPointer pointerPath = buildPointer(split["pointer_paths"][version]);
        vars.watchers.Add(new MemoryWatcher<bool>(pointerPath) { Name = key });
        vars.triggered.Add(key, false);
    }

    // Add the area transitions to triggered as well, based on the from string + to string.
    foreach (var transition in vars.areaTransitions) {
        string transitionKey = transition.Item1 + "To" + transition.Item2;
        vars.triggered.Add(transitionKey, false);
    }

    // Add the pickaxe tiers to triggered as well, based on the tier name.
    foreach (var tier in vars.pickaxeTiers) {
        string tierKey = "Pickaxe" + tier.Key;
        vars.triggered.Add(tierKey, false);
    }

    // If at some point I have other flags that don't sit inside FirstPersonCharacter, add them manually right here.
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
    
    // Iterate over each watcher and if it's enabled and it's different, then we split.
    // We also guard against re-setting on the same flag by checking our triggered array.
    foreach (MemoryWatcher watcher in vars.watchers) {
        bool watcherEnabled = settings[watcher.Name];
        bool watcherTriggered = vars.triggered[watcher.Name];
        bool watcherChanged = watcher.Old != null && watcher.Current != null && (bool)watcher.Old != (bool)watcher.Current;
        if (watcherEnabled && !watcherTriggered && watcherChanged) {
            print("[Autosplit] " + watcher.Name);
            vars.triggered[watcher.Name] = true;
            return true;
        }
    }

    // Area transitions are also tracked separately.
    // Theoretically I just want the first time we get to certain areas mostly, but I'd rather be explicit.
    foreach (var transition in vars.areaTransitions) {
        string fromArea = transition.Item1;
        string toArea = transition.Item2;
        string transitionKey = fromArea + "To" + toArea;
        if (settings[transitionKey] && !vars.triggered[transitionKey] && old.area == vars.areas[fromArea] && current.area == vars.areas[toArea]) {
            print("[Autosplit] " + fromArea + " to " + toArea);
            vars.triggered[transitionKey] = true;
            return true;
        }
    }

    // Pickaxe upgrades are also tracked separately. We loop because we need to respect the settings.
    foreach (var tier in vars.pickaxeTiers) {
        string tierKey = "Pickaxe" + tier.Key;
        if (settings[tierKey] && !vars.triggered[tierKey] && current.pickaxe > old.pickaxe && current.pickaxe == tier.Value) {
            print("[Autosplit] Pickaxe tier " + tier.Key);
            vars.triggered[tierKey] = true;
            return true;
        }
    }
}