// Tinykin Autosplitter & Load Remover
// Author: Dan Fego / Delphi (autosplitter); Toothie & just-ero (load remover)
// Last updated: 2026-08-25
//
// A really basic autosplitter for Tinykin, loosely based around the current All Parts route.
// A subset of possible scene transitions are available as settings to turn on and off.
// The transitions will always trigger a split, whether they're the first time or not.
// There's definitely room for improvement, but it's something!
// Practically speaking I could reduce the complexity by just having the settings be "from"
// scenes rather than full transitions, since practically speaking that's what we're doing here for this route.
//
// The existing load remover functionality by Toothie & just-ero is included as well.
state("Tinykin") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.LoadSceneManager = true;

    // Used for settings and splits
    vars.sceneTransitions = new List<Tuple<string, string, string>>
    {
        Tuple.Create("Hall to Workshop",    "01_Hall",             "00_Hub"),
        Tuple.Create("Hub to Sanctar",      "00_Hub",              "02_LivingRoom_v4"),
        Tuple.Create("Sanctar to Hub",      "02_LivingRoom_v4",    "00_Hub"),
        Tuple.Create("Sanctar to Foliana",  "02_LivingRoom_v4",    "03_Veranda_V4"),
        Tuple.Create("Hub to Foliana",      "00_Hub",              "03_Veranda_v4"),
        Tuple.Create("Foliana to Balnea",   "03_Veranda_v4",       "04_Bathroom_v2"),
        Tuple.Create("Balnea to Hub",       "04_Bathroom_v2",      "00_Hub"),
        Tuple.Create("Hub to Hall",         "00_Hub",              "01_Hall"),
        Tuple.Create("Hall to Ambrose",     "01_Hall",             "06_Kitchen_v2"),
        Tuple.Create("Ambrose to Hub",      "06_Kitchen_v2",       "00_Hub"),
        Tuple.Create("Hall to Celerion",    "01_Hall",             "07_Bedroom"),
        Tuple.Create("Celerion to Hub",     "07_Bedroom",          "00_Hub"),
        Tuple.Create("Hub to Attic",        "00_Hub",              "08_Attic"),
        Tuple.Create("Hub to Credits",      "00_Hub",              "Credits"),
    };

    // Settings for a given transition are on or off. Maybe I could get fancier at some point.
    settings.Add("loadRemoval", true, "Load Removal");
    settings.Add("splits", true, "Splits");
    settings.CurrentDefaultParent = "splits";
    foreach (var transition in vars.sceneTransitions)
    {
        string name = transition.Item1;
        settings.Add(name, true);
    }
}

init
{
    vars.Helper.GameName = "Tinykin";
    vars.HooksReady = false;
    current.scene = "";

    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        try
        {
            // For load removal
            var bootstrapClass = mono["Game", "Bootstrap"];
            vars.Helper["loading"] = mono.Make<bool>(bootstrapClass, "LoadingSceneFromBootstrap");

            vars.HooksReady = true;
            print("[Autosplit] Hooks ready!");

            return true;
        }
        catch (Exception e)
        {
            print("[Autosplit] tryload exception: " + e.Message);
            return false;
        }
    });
}

start
{
    if (!vars.HooksReady) {
        print("[Autosplit] Not checking start condition, hooks not ready.");
        return false;
    }

    // I used to check a transition here, but for the start trigger, all we need to know is are we in.
    if (current.scene == "01_Hall") {
        print("[Autosplit] Start triggered: " + old.scene + " to " + current.scene);
        return true;
    }
}

update
{
    try {
        if (!vars.HooksReady) {
            return;
        }

        // Keep the loading state updated every frame.
        // NOTE: if update returns false, isLoading doesn't run, so... don't do that.
        current.loading = vars.Helper["loading"].Current;

        // Get the current scene name and store it into current.scene.
        // This makes use of the runtime's magic old/current.
        // We ignore the "StartupScreen" scene, which is the loading screen between areas.
        string liveScene = vars.Helper.Scenes.Active.Name;
        if (liveScene != "StartupScreen") {
            current.scene =  liveScene;
        }

        if (old.scene != null && old.scene != current.scene) {
            print("[Autosplit] Scene changed from " + old.scene + " to " + current.scene);
        }
    }
    catch (Exception e)
    {
        print("[Autosplit] update exception: " + e.Message);
        return false;
    }
}

split
{
    if (old.scene != null && old.scene != current.scene) {
        print("[Autosplit] Scene changed from " + old.scene + " to " + current.scene);
    }

    // We split for specific transitions. Because some of them happen more than once, we just let it happen.
    foreach (var transition in vars.sceneTransitions)
    {
        string name = transition.Item1;
        string from = transition.Item2;
        string to = transition.Item3;
        if (settings[name] && old.scene == from && current.scene == to) {
            print("[Autosplit] Transition: " + name);
            return true;
        }
    }
}

isLoading
{
    if (settings["loadRemoval"]) {
        return current.loading;
    }
    return false;
}