state("SupralandSIU-Win64-Shipping")
{
    bool inputDisabled : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x580, 0x398;
    // int activeCutscenes : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xa14;

    bool tutorialDone : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x7bb;
    bool blackedOut : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xbe4;
    bool hasSpeed : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x7c2;
    bool hasHighJump : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xa48;
    bool hasCrouch : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x1319;
    bool hasGrapple : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x7cc;
    bool hasBelt : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x7c9;
    bool hasRepel : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xec3;
    bool hasElectricGun : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x1200;
    bool hasGrappleGold : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xe88;
    bool isStrong : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xe82;
    bool hasForceCube : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x7c3;
    bool hasTranslocator : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x7ce;
    byte pickaxe : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xee8;
    float swordRefireRate :  0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0x7e0;
    bool endgame : 0x4dd04c8, 0xd28, 0x38, 0x0, 0x30, 0x598, 0xeac;
}

startup
{
    vars.settings = new Dictionary<string, Tuple<string, string>> {
        { "pickaxe", Tuple.Create("Pickaxe & Upgrades", "Split on picking up the wooden pickaxe, stone, iron, or diamond.") },
        { "down_the_pipe", Tuple.Create("Down the Pipe", "Split on going down the pipe during the intro cutscene.") },
        { "speed", Tuple.Create("Speed Upgrade", "Split on picking up the speed upgrade in the bunker.") },
        { "high_jump", Tuple.Create("High Jump", "Split on picking up the high jump upgrade.") },
        { "crouch", Tuple.Create("Crouch", "Split on picking up the crouch upgrade.") },
        { "grapple", Tuple.Create("Grapple Beam", "Split on picking up the grapple beam.") },
        { "magnet_belt", Tuple.Create("Magnet Belt", "Split on picking up the magnet belt.") },
        { "repel", Tuple.Create("Magnet Belt Repel", "Split on picking up the magnet belt repel upgrade.") },
        { "electric_gun", Tuple.Create("Electric Gun", "Split on picking up the electric gun.") },
        { "grapple_gold", Tuple.Create("Grapple Beam Gold Upgrade", "Split on picking up the grapple beam gold upgrade.") },
        { "strong", Tuple.Create("Strength", "Split on getting strong in the gym.") },
        { "force_cube", Tuple.Create("Force Cube", "Split on getting the Force Cube.") },
        { "translocator", Tuple.Create("Translocator", "Split on getting the Translocator.") },
        { "end", Tuple.Create("End", "Split on hitting the endgame trigger.") },
    };

    settings.Add("splits", true, "Splits");
    settings.CurrentDefaultParent = "splits";
    foreach (string key in vars.settings.Keys) {
        settings.Add(key, true, vars.settings[key].Item1);
        settings.SetToolTip(key, vars.settings[key].Item2);
    }
}

start
{
    // This is buried deep within the character controller, in the action manager.
    // However, it does seem to trigger exactly at the right time.
    // Finding this took me longer than the rest of the script.
    if (old.inputDisabled && !current.inputDisabled) {
        print("[Autosplit] input (start)");
        return true;
    }
}

init {
    // Keeps track of items collected that get taken away during cutscenes.
    vars.collected = new Dictionary<string, bool> {
        { "speed", false },
        { "high_jump", false },
        { "crouch", false },
        { "grapple", false },
        { "magnet_belt", false },
        { "repel", false },
        { "electric_gun", false },
        { "grapple_gold", false },
        { "strong", false },
        { "force_cube", false },
        { "translocator", false },
    };
    vars.pickaxe = 0;
}

onStart {
    // Reset all collected flags back to false
    foreach (string key in vars.collected.Keys) {
        vars.collected[key] = false;
    }
    
    // Reset pickaxe tier
    vars.pickaxe = 0;
}

split
{
    // This isn't an item, so it isn't affected by the cutscene issues.
    if (settings["down_the_pipe"] && !old.tutorialDone && current.tutorialDone) {
        print("[Autosplit] tutorialdone");
        return true;
    }
    // This isn't an item, so it isn't affected by the cutscene issues.
    if (settings["end"] && !old.endgame && current.endgame) {
        print("[Autosplit] endgame");
        return true;
    }

    // // This attempts to dodge issues where cutscenes take away and give back player items.
    // if (current.inputDisabled || (old.inputDisabled && !current.inputDisabled)) {
    //     // kinda spams the logs, so commenting this out
    //     //  print("[Autosplit] skipping split checking for cutscene");
    //     return false;
    // }

    if (settings["pickaxe"] && vars.pickaxe == old.pickaxe && (current.pickaxe > old.pickaxe)) {
        print("[Autosplit] pickaxe");
        vars.pickaxe = current.pickaxe;
        return true;
    }
    if (settings["speed"] && !vars.collected["speed"] && !old.hasSpeed && current.hasSpeed) {
        print("[Autosplit] speed");
        vars.collected["speed"] = true;
        return true;
    }
    if (settings["high_jump"] && !vars.collected["high_jump"] && !old.hasHighJump && current.hasHighJump) {
        print("[Autosplit] highjump");
        vars.collected["high_jump"] = true;
        return true;
    }
    if (settings["crouch"] && !vars.collected["crouch"] && !old.hasCrouch && current.hasCrouch) {
        print("[Autosplit] crouch");
        vars.collected["crouch"] = true;
        return true;
    }
    if (settings["grapple"] && !vars.collected["grapple"] && !old.hasGrapple && current.hasGrapple) {
        print("[Autosplit] grapple");
        vars.collected["grapple"] = true;
        return true;
    }
    if (settings["magnet_belt"] && !vars.collected["magnet_belt"] && !old.hasBelt && current.hasBelt) {
        print("[Autosplit] belt");
        vars.collected["magnet_belt"] = true;
        return true;
    }
    if (settings["repel"] && !vars.collected["repel"] && !old.hasRepel && current.hasRepel) {
        print("[Autosplit] repel");
        vars.collected["repel"] = true;
        return true;
    }
    if (settings["electric_gun"] && !vars.collected["electric_gun"] && !old.hasElectricGun && current.hasElectricGun) {
        print("[Autosplit] gun");
        vars.collected["electric_gun"] = true;
        return true;
    }
    if (settings["grapple_gold"] && !vars.collected["grapple_gold"] && !old.hasGrappleGold && current.hasGrappleGold) {
        print("[Autosplit] gold");
        vars.collected["grapple_gold"] = true;
        return true;
    }
    if (settings["strong"] && !vars.collected["strong"] && !old.isStrong && current.isStrong) {
        print("[Autosplit] strong");
        vars.collected["strong"] = true;
        return true;
    }
    if (settings["force_cube"] && !vars.collected["force_cube"] && !old.hasForceCube && current.hasForceCube) {
        print("[Autosplit] cube");
        vars.collected["force_cube"] = true;
        return true;
    }
    if (settings["translocator"] && !vars.collected["translocator"] && !old.hasTranslocator && current.hasTranslocator) {
        print("[Autosplit] translocator");
        vars.collected["translocator"] = true;
        return true;
    }
    // if (current.swordRefireRate > old.swordRefireRate) {
    //     print("[Autosplit] swordRefireRate {old.swordRefireRate} -> {current.swordRefireRate}");
    //     return true;
    // }
}