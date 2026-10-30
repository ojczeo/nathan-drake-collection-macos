# Nathan Drake Collection for Mac

Experimental Apple Silicon launcher for [BilalReloaded’s PC port](https://github.com/bc160201983/Uncharted-The-Nathan-Drake-Collection-PC-port) of *Uncharted: The Nathan Drake Collection*.

**This repository does not contain game files.** You need your own decrypted PS4 game dump. The launcher is not affiliated with Sony, Naughty Dog, or Bluepoint.

## Install and run

1. Download the `.dmg` from the [latest release](https://github.com/truwa/nathan-drake-collection-macos/releases/latest) and open it.
2. Drag `NathanDrakeCollection.app` onto Applications, then open it from Applications. The release is notarized by Apple and signed with Developer ID, so a double-click should open it.
3. If macOS still refuses, open System Settings, go to Privacy & Security, and allow the app there. The button usually says Open Anyway.
4. Choose the game folder (`eboot.bin` and `sce_sys`).
5. If update 1.02 was dumped separately, choose that folder too. A sibling folder named like the game plus `-patch` or `-update` is detected automatically. Dumps are not copied or merged on disk.
6. Pick a game and press Play.

## Requirements

- Apple Silicon (M1 or newer)
- macOS 26 or newer
- Rosetta 2
- A decrypted dump of CUSA02344, CUSA02320, or CUSA02343 (`eboot.bin`, `sce_sys`, `u1data` / `u2data` / `u3data`)

The BilalReloaded native engine and KosmicKrisp are inside the app. You do not download that port separately.

Intel Macs are not supported. 

Recommended first settings: Medium (1080p, 60 FPS) in **Game Settings**. The in-game menu is Insert or R3+L2. **F10** frees the mouse; click the game window to capture it again. **Control-Command-F** toggles fullscreen. Command-Tab switches apps.

Saves, settings, and logs stay in `~/Library/Application Support/NathanDrakeCollection`. Replacing the app preserves that folder.


## Credits & Licenses

- **PC port:** [BilalReloaded](https://github.com/bc160201983/Uncharted-The-Nathan-Drake-Collection-PC-port) (GPLv2)
- **KosmicKrisp:** Mesa Vulkan on Metal (MIT)
- **SpartanPort:** [God of War III Remastered Mac launcher](https://github.com/FelipePrado0/SpartanPort) (GPLv2) — the Apple Silicon, KosmicKrisp, and packaging model for this app (Fleurat, nizwar, Incognito-Coder)
- **This launcher:** [MacGameTest](https://www.youtube.com/@MacGameTest)

See `NOTICES.txt` and Credits & Licenses in the app.

## Working with upstream 0.7.2 sources

The native C/C++ engine is **not committed** to this macOS repository. The build uses `port-work/bilal` when present, including any locally applied macOS adaptations. To fetch the exact BilalReloaded `v0.7.2` sources and their git submodules, run from this repository's root:

```bash
bash setup_port_source.sh
```

If `port-work/bilal` does not exist, the script clones there. If it already exists, it is **never overwritten**: the script downloads the pristine upstream tree into `port-work/bilal-upstream-v0.7.2` instead. To choose a different destination, use `PORT_CHECKOUT=port-work/bilal-clean-v0.7.2 bash setup_port_source.sh`. Both directories stay excluded by `.gitignore`.

**This only downloads source code.** The upstream tree is not automatically a functional macOS build. Reapply and merge the original local macOS changes, rebuild the x86-64 `gow3-probe` and `libgow3gpu.dylib`, and test on Apple Silicon before running `build_app.sh`. The Mac launcher has its own SwiftUI UI; do not replace it with the upstream Windows launcher. In particular, review the `VK_DRIVER_FILES` handling in `gow3_pc/gpu/shadps4/video_core/renderer_vulkan/vk_platform.cpp` before testing renderer selection.
