# 🛢️ OLD_TRAP - Advanced Road Trap System

An immersive road trap system for FiveM that adds a new dimension to your chases and RP scenarios!

## 🎯 Available Traps

- **Oil Slick** - Causes vehicles to lose control and spin violently
- **Glass Debris** - Randomly bursts 2 tires on vehicles

## ✨ Features

- ✅ Placement with kneeling animation
- ✅ Pickup system with E key
- ✅ Configurable lifetime (default: 5 minutes)
- ✅ Physical props placed on the ground
- ✅ Multi-point detection (wheels + vehicle center)
- ✅ Realistic and customizable effects
- ✅ Multi-player synchronization
- ✅ Integrated debug mode
- ✅ Optimized and performant
- ✅ Automatic cleanup on script stop

## 📦 Dependencies

- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_lib](https://github.com/overextended/ox_lib)

## 🔧 Installation

1. **Download and extract** the `old_trap` folder to your server's `resources` directory

2. **Add items to ox_inventory**
   
   Open `ox_inventory/data/items.lua` and add:
   
   ```lua
   ['bouteille_huile'] = {
       label = 'Oil Bottle',
       weight = 500,
       stack = true,
       close = true,
       description = 'Can be used to create an oil slick on the road',
       client = {
           export = 'old_trap.useTrap'
       }
   },

   ['morceau_verre'] = {
       label = 'Glass Shards',
       weight = 200,
       stack = true,
       close = true,
       description = 'Sharp glass pieces to burst vehicle tires',
       client = {
           export = 'old_trap.useTrap'
       }
   }
   ```

3. **Add to server.cfg**
   
   ```cfg
   ensure old_trap
   ```

4. **Restart your server** or restart the resources:
   
   ```
   restart ox_inventory
   restart old_trap
   ```

## ⚙️ Configuration

The `config.lua` file offers extensive customization options:

### General Settings
- `Config.Debug` - Enable/disable debug markers
- `Config.CanPickupTraps` - Allow players to pick up traps
- `Config.PickupOwnTrapsOnly` - Restrict pickup to trap owner only
- `Config.ReturnItemOnPickup` - Return item when picking up trap

### Trap Settings
Each trap can be configured with:
- **Duration** - Trap lifetime before auto-removal
- **Trigger radius** - Detection distance
- **Effect intensity** - Strength of the effect
- **Spin force** - Rotation intensity (oil only)
- **Max tires** - Number of tires to burst (glass only)

### Animation Settings
- Animation dictionary and clip
- Animation flag and duration

## 💡 Usage

### For Players
1. Obtain a trap item (`bouteille_huile` or `morceau_verre`)
2. Use the item from your inventory
3. A placement animation will play
4. The trap is now active on the ground
5. To pick up: Stand near the trap and press **E**


## 🎮 Effects

### Oil Slick
- Reduces vehicle grip and traction
- Applies random lateral forces
- Causes aggressive vehicle spinning
- Lasts 5 seconds per trigger
- Works even at low speeds

### Glass Debris
- Randomly bursts 2 tires
- Immediate effect on trigger
- Can affect any tire on the vehicle

## 🐛 Debug Mode

Enable debug mode in `config.lua`:
```lua
Config.Debug = true
```

This will display red circular markers showing the trigger radius of each trap.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 💬 Support

For support, please open join our discord.

## 🎯 Use Cases

Perfect for:
- 🚓 Police chases and roadblocks
- 🏴‍☠️ Gang activities and turf wars
- 🎭 RP scenarios and events
- 🏁 Custom racing events with obstacles

---

**Made with ❤️ for the FiveM community**
