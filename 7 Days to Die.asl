// Autosplitter for 7 Days to Die, developed for 100Zombie% as of version 3.1.0.14.
// Apparently state gets left blank when using the Unity helper.
state("7DaysToDie") {}

startup
{
    // Load the unity helper, which is required for this autosplitter to work.
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.LoadSceneManager = true;

    // Create a toggleable setting for each kill. By default, all are off except 100.
    settings.Add("splits", true, "Splits");
    settings.CurrentDefaultParent = "splits";
    for (int i = 1; i <= 100; i++) {
        var on = (i == 100);
        settings.Add(i + "kills", on, i + " kills");
        settings.SetToolTip(i + "kills", "Split on killing " + i + " zombies");
    }
}

init
{
    // For logging
    vars.Helper.GameName = "7 Days to Die";

    // Grab the GameManager
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        // GameManager is a singleton, so we can just grab the static instance.
        vars.Helper["killedZombies"] = mono.Make<int>(
            "GameManager",
            "Instance",
            "myEntityPlayerLocal",
            "killedZombies"
        );

        vars.Helper["GameHasStarted"] = mono.Make<bool>(
            "GameManager",
            "Instance",
            "GameHasStarted"
        );

        return true;
    });
}

start
{
    return !vars.Helper["GameHasStarted"].Old && vars.Helper["GameHasStarted"].Current;
}

update
{
    // Pull kill count data.
    current.killedZombies = vars.Helper["killedZombies"].Current;

}

split
{
    // Only try and split if a zombie was killed this update.
    if (vars.Helper["killedZombies"].Changed) {
        // Only split if this threshold was in the settings.
        var settingsString = current.killedZombies + "kills";
        if (settings[settingsString]) {
            return true;
        }
    }
}