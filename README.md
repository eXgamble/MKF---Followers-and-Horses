# MKF - Followers and Horses

A small Skyrim Anniversary Edition mod built on
[Modifier Key Framework](https://www.nexusmods.com/skyrimspecialedition/mods/193566): hold the
modifier key to open a follower's or your own horse's inventory, without going through dialogue.

| Target | Activate | Hold the modifier key |
|---|---|---|
| A follower | `Talk +`: vanilla dialogue | `Inventory`: opens their inventory |
| Your own horse | `Ride +`: vanilla riding | `Inventory`: opens its inventory |

The modifier key is Modifier Key Framework's: Left Shift, or Left Shoulder on a gamepad, by default.
Nothing happens in combat, and only horses you own (bought or claimed) are affected.

## Requirements

- [SKSE64](https://skse.silverlock.org/)
- [Address Library for SKSE Plugins](https://www.nexusmods.com/skyrimspecialedition/mods/32444)
- [Modifier Key Framework](https://www.nexusmods.com/skyrimspecialedition/mods/193566)

## Repository layout

```
mod/   the mod exactly as installed: plugin (ESL), script + source, rule file, translation, SEQ
```

The author's MO2 mod folder is a directory junction to `mod/`.
