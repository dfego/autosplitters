// Tinykin Autosplitter & Load Remover
// Author: Dan Fego / Delphi (autosplitter); Toothie & just-ero (load remover)
// Last updated: 2026-08-25
state("Tinykin") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.LoadSceneManager = true;
}

init
{
    vars.Helper.GameName = "Tinykin";
    vars.HooksReady = false;

    // 1. Declare the variables up front so ExpandoObject never panics
    vars.NameOffset = 0;
    vars.StatusOffset = 0;
    vars.ObjectivesOffset = 0;
    vars.ProgressOffset = 0;

    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        try 
        {
            var questClass = mono["Game", "Quest"];

            // For load removal
            var bootstrapClass = mono["Game", "Bootstrap"];
            vars.Helper["loading"] = mono.Make<bool>(bootstrapClass, "LoadingSceneFromBootstrap");

            vars.Helper["QuestList"] = mono.MakeList<IntPtr>(questClass, "QUESTS");
            vars.NameOffset = questClass["questName"];
            vars.StatusOffset = questClass["status"];

            vars.ObjectivesOffset = questClass["objectives"];
            
            // If this line crashes, the namespace isn't "Game" (it might be "")
            var objectiveClass = mono["Game", "QuestObjective"]; 
            
            // If this line crashes, the backing field string is wrong
            vars.ProgressOffset = objectiveClass["Progress"]; 

            vars.OldQuestObjectiveProgress = new List<int>();
            vars.CurrentQuestObjectiveProgress = new List<int>();

            vars.HooksReady = true;
            print("[Autosplit] Hooks ready!");

            return true; 
        }
        catch (Exception e) 
        {
            print("[Autosplit] TRYLOAD CRASH: " + e.Message);
            return false;
        }
    });
}

onStart
{
    // Clear our memory of completed quests whenever a new run starts
    vars.OldQuestObjectiveProgress.Clear();
    vars.CurrentQuestObjectiveProgress.Clear();
}

update
{
    // return false;

    // Reset our split flag every frame
    vars.ShouldSplit = false;

    try {
        // Keep the loading state updated every frame.
        // NOTE: if update returns false, isLoading doesn't run, so... don't do that.
        current.loading = vars.Helper["loading"].Current;

        var quests = vars.Helper["QuestList"];

        if (!vars.HooksReady || quests.Current.Count == 0 || vars.Helper.Scenes.Active.Name != "00_Hub") {
            return;
        }

        // Grab the singular active quest
        IntPtr questPtr = quests.Current[0];
        if (questPtr == IntPtr.Zero) return;

        // Get the pointer to the objectives array
        IntPtr objectivesArray = vars.Helper.Read<IntPtr>(questPtr + (int)vars.ObjectivesOffset);
        if (objectivesArray == IntPtr.Zero) return;

        // Get the length of the QuestObjective[] objectives array, which is stored at offset 0x18.
        int objectivesArrayLength = vars.Helper.Read<int>(objectivesArray + 0x18);
        // print("[Autosplit] objectivesArrayLength: " + objectivesArrayLength);

        // If current isn't populated, just populate it and don't do any checks.
        // Otherwise, move what's in current into old, refresh current, and do a check.
        if (vars.CurrentQuestObjectiveProgress.Count == 0) {
            for (int i = 0; i < objectivesArrayLength; i++) {
                int progress = vars.Helper.Read<int>(vars.Helper.Read<IntPtr>(objectivesArray + 0x20 + (i * 0x8)) + (int)vars.ProgressOffset);
                vars.CurrentQuestObjectiveProgress.Add(progress);
            }
        } else {
            vars.OldQuestObjectiveProgress.Clear();
            for (int i = 0; i < vars.CurrentQuestObjectiveProgress.Count; i++) {
                vars.OldQuestObjectiveProgress.Add(vars.CurrentQuestObjectiveProgress[i]);
            }

            vars.CurrentQuestObjectiveProgress.Clear();
            for (int i = 0; i < objectivesArrayLength; i++) {
                int progress = vars.Helper.Read<int>(vars.Helper.Read<IntPtr>(objectivesArray + 0x20 + (i * 0x8)) + (int)vars.ProgressOffset);
                vars.CurrentQuestObjectiveProgress.Add(progress);
            }

            for (int i = 0; i < vars.CurrentQuestObjectiveProgress.Count; i++) {
                if (vars.CurrentQuestObjectiveProgress[i] > vars.OldQuestObjectiveProgress[i]) {
                    print("[Autosplit] Objective " + i + " progressed from " + vars.OldQuestObjectiveProgress[i] + " to " + vars.CurrentQuestObjectiveProgress[i]);
                    vars.ShouldSplit = true;
                    break;
                }
            }
        }


        // // 2. Iterate through all 6 objectives
        // for (int i = 0; i < 6; i++) {
        //     // Start at 0x20, and add 0x8 for each subsequent index
        //     IntPtr objectivePtr = vars.Helper.Read<IntPtr>(objectivesArray + 0x20 + (i * 0x8));
            
        //     if (objectivePtr == IntPtr.Zero) continue;

        //     // 3. Read the backing field of the progress integer
        //     int progress = vars.Helper.Read<int>(objectivePtr + (int)vars.ProgressOffset);
            
        //     print("[Autosplit] Objective " + i + " Progress: " + progress);
        // }
    }
    catch (Exception e) 
    {
        print("[Autosplit] update exception: " + e.Message);
        return false;
    }
}

split
{
    // Fire the split if the update block caught a new completion this frame
    return vars.ShouldSplit;
}

isLoading
{
    return current.loading;
}