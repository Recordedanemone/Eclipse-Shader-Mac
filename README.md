# Eclipse Shader for macOS (Iris + Vitrail)

This fork of [Eclipse](https://github.com/Merlin1809/Eclipse-Shader) by Merlin1809 compiles and runs on Apple Silicon Macs under **Vitrail**, the Vulkan backend for Iris that runs through MoltenVK. The unmodified pack fails to compile on Vitrail. With these patches it loads and runs well.

All credit for the shader goes to the original authors (Eclipse, Bliss and Chocapic13). This fork only makes it compatible with macOS and Vitrail. See [CREDITS.txt](CREDITS.txt).

## Installing

1. Download this repo as a zip (**Code → Download ZIP**). If the zip contains a top-level folder, re-zip so that `shaders/` sits at the root of the zip.
2. Put the zip in your instance's `shaderpacks` folder.
3. In game: **Options → Video Settings → Shader Packs**, then choose the pack.

## What was fixed

### 1. Macro redefinition errors
Vitrail's shader compiler is stricter than Apple's OpenGL driver. Redefining a macro with a different body is an error there, not a warning. That caused failures like `Macro redefined: diagonal3`. Every `#define` of `diagonal2`, `diagonal3`, `diagonal4`, `projMAD` and `transMAD` now has an `#undef` before it, in `lib/util.glsl`, `dimensions/*` and the per-world shadow and weather shaders (about 30 files).

### 2. 1D block-data image changed to 2D
MoltenVK can't bind 1D storage images. The block light lookup table `imgBlockData` is now a **2048×1 2D image**, not a 1D image of length 2048:
- `shaders.properties`: `image.imgBlockData = ... 2048 1`
- `uimage1D` / `usampler1D` changed to `uimage2D` / `usampler2D`
- Every `imageLoad` / `imageStore` call now takes `ivec2(id, 0)` (`lpv_blocks.glsl`, `diffuse_lighting.glsl`, `setup.csh`, `shadowcomp.csh`, `composite2.fsh`, voxel shaders and others)

Rendering under Iris on other platforms doesn't change.

### 3. Geometry and tessellation grass stages removed
Vitrail doesn't support geometry or tessellation shader stages. `gbuffers_terrain.gsh`, `.tcs` and `.tes` were removed from all five world folders. These stages only power **Shader Grass**, which the pack already turns off on MC 26.2+, so no visible feature is lost.

### 4. Vitrail detection
`lib/settings.glsl` now defines `VITRAIL` when the renderer is Apple and the reported GL version is above 4.1. Apple's own OpenGL driver never reports above 4.1, so this only matches Vitrail. The define hides the "Shader Grass unsupported" warning text in `final.fsh`, which doesn't apply here.

### 5. Shadow sampler fix
In `lib/specular.glsl`, the hardware shadow lookup now passes the full `vec3` shadow position to `shadowtex0HW`, not only `.xy`. A depth-compare sampler needs the reference depth, and Vulkan rejects the shorter call.

### 6. Flickering colored block light (experimental)
Under Vitrail, light from torches, lamps and lava flickered as the player moved. Iris normally fills the block light color table once, in the `setup` compute pass. Vitrail skips `setup` (the log shows `compute programs skipped, no stage exists for them yet: [setup]`). Vulkan doesn't clear new GPU memory, so the table held leftover data.

To fix this, each world folder has a new `prepare5.csh` pass that runs the setup code every frame when `VITRAIL` is defined. Vitrail already runs `prepare` passes. Under normal Iris it's an empty pass, and `shaders.properties` turns it off wherever `setup` is turned off. The cost per frame is very small.

> ⚠️ This fix hasn't been fully confirmed in game. If light still flickers, please open an issue and say what flickers: block light, sun and shadows, or overall screen brightness.

## Known limitations
- Shader Grass isn't available, because Vitrail has no geometry or tessellation stages.
- Features the pack already turns off on macOS (`MC_OS_MAC`) stay off.

---

# Eclipse - A Bliss Edit

Bliss is already one of the best and most feature rich shaders out there, yet I still wanted more...  
It started out with smaller features, but then the additions just kept piling up.

Notable changes/additions compared to Bliss unstable:
 + Custom moon orbit with possible eclipses
 + Water wave simulation for the player
 + Shader Grass
 + Aurora & Rainbow
 + Additional cirrus & cumulonimbus cloud layers (WIP)
 + Distant Horizons chunk fading
 + Moon Texture with phases
 + Snow Overlay and Rain Ripples
 + Better shader-side (hardcoded) emissives
 + Lightsource with shadows on the main end island
 + Better lightning strikes with clouds lighting up and shadows
 + Photonics, Caelum (Arda Craft) support
 + 1.21.11 Chunk Fade In support
 + Emissive Ores and Trims

Note: With default settings there is at least one guaranteed eclipse per ingame year.

## Eclipses <sub>(why else would I call the shader Eclipse??)</sub>

<img width="2560" height="1440" alt="2025-08-12_02 16 11" src="https://github.com/user-attachments/assets/8b2a1161-8bb5-4003-b04c-16a9c6f01494" />

## Overhauled end lighting for the main island

<img width="2560" height="1440" alt="2025-08-12_01 31 12" src="https://github.com/user-attachments/assets/a1a408cc-ed2a-46a3-a465-4b09d0d00660" />

## Water wave simulation

<img width="1920" height="1080" alt="2025-09-02_00 29 28" src="https://github.com/user-attachments/assets/87cbd02c-1149-4764-9ff0-7da521b0273a" />

## Shader Snow

<img width="1920" height="1080" alt="2025-08-13_13 38 18" src="https://github.com/user-attachments/assets/31e5102e-d872-4aec-a606-39ae88385d45" />

## Shader Grass

<img width="1920" height="1080" alt="2025-10-06_01 34 47" src="https://github.com/user-attachments/assets/47dfabab-51cf-4490-9247-35f7879a3690" />

## Lightning Shadows

<img width="2560" height="1440" alt="2025-08-12_02 52 02" src="https://github.com/user-attachments/assets/5f8c484f-2574-4a07-857b-9347c4b459c2" />

## Moon Texture with physically correct lighting

<img width="1920" height="1080" alt="2025-08-16_23 14 00" src="https://github.com/user-attachments/assets/1e92cf5f-9a28-47a0-8737-36853034ff68" />

## Rainbows

<img width="1920" height="1080" alt="2025-08-16_21 34 11" src="https://github.com/user-attachments/assets/618bf00e-d4f6-4336-87d9-79fb65e18775" />


### SPECIAL THANKS:
+ Chocapic13, for the base shader
+ Xonk, for developing the great Bliss shader
+ WoMspace, for spending alot of time creating a DOF overhaul
+ Null, for doing a huge amount of work creating the voxel floodfill colored lighting
+ Emin, and Gri573, for teaching me how to stop alot of light leaking
+ RRe36 and Sixthsurge, for the great ideas to steal
### [Want to support Xonk? Consider donating](https://ko-fi.com/xonkdev)

### [You can contact me by joining Xonk's discord server and using the Eclipse channel!](https://discord.gg/8nVt56H9zH)


# How to download the latest version:
 - locate the `green "code" button` on this page. this button is NOT in the `releases` page.
 - click the `green "code" button` and select `"download zip"`.
 - once the zip file finishes downloading, install it like a normal shader. you do NOT need to unzip/extract/decompress.

# Incompatible Mods / Mods with issues
- Chunks Fade In mod
- Puddles and Floods
- Create Aeronautics (requires "[Iris Extension](https://modrinth.com/mod/iris-extension)" for fix)
- BBS (disable shader curves setting in BBS settings)
- Iris Uniforms
- Epic Fight Mod (disable the compute shader setting in the Epic Fight Mod settings)
- Particle Rain
- Physics Mod (Fluid Sim and Weather particles are unsupported)
- Flerovium

# You want MOAR performance?
> [!NOTE]  
> My "[Iris Extension](https://modrinth.com/mod/iris-extension)" mod automatically does this when shader grass is disabled, there is no need to manually delete the files if you are using my mod!

 Delete the "gbuffers_terrain.gsh", "gbuffers_terrain.tcs" and "gbuffers_terrain.tes" files for all world folders in the shader.
 This will make the shader grass setting non functional BUT will increase performance, especially with high vanilla render distances!
 (If you're wondering why, Iris does NOT allow me to disable these files once they're there. So even when Shader Grass is disabled these execute and harm performance!)
