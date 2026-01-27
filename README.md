# ScreenPets 🐉

A native macOS menu bar app that displays animated pets roaming across your screen(s).

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Multiple Pets** - Choose from Dragon, Nyan Cat, or Ghost
- **Multi-Screen Support** - Pets can roam across all your displays
- **Three Movement Modes**:
  - Secondary Screen Only - Pet stays on non-primary displays
  - Cross Screen - Pet moves across all screens
  - Free Roam - Pet flies freely in any direction
- **Adjustable Size** - Scale pets from 0.5x to 3x
- **Always on Top** - Pets float above all windows, including menu bar and dock
- **Native SwiftUI** - Lightweight, efficient, and battery-friendly

## Screenshots

<!-- TODO: Add screenshots -->

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later (for building)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/sealovesky/ScreenPets.git
   cd ScreenPets
   ```

2. Open in Xcode:
   ```bash
   open ScreenPets.xcodeproj
   ```

3. Build and run (⌘R)

### Download Release

<!-- TODO: Add release download link -->

## Usage

1. Launch ScreenPets - it appears in your menu bar
2. Click the menu bar icon to access settings
3. Choose your pet, movement mode, and size
4. Toggle the pet on/off with the switch

## Project Structure

```
ScreenPets/
├── ScreenPetsApp.swift      # App entry point
├── Models/
│   ├── Pet.swift            # Pet protocol and types
│   └── PetSettings.swift    # Settings manager
├── Pets/
│   ├── DragonPet.swift      # Dragon implementation
│   ├── NyanCatPet.swift     # Nyan Cat implementation
│   └── GhostPet.swift       # Ghost implementation
├── Managers/
│   ├── PetManager.swift     # Pet lifecycle management
│   └── PetWindowController.swift  # Multi-screen window management
├── Views/
│   └── SettingsView.swift   # Settings panel UI
└── Resources/
    ├── AppIcon.svg          # App icon source
    └── Assets.xcassets/     # Asset catalog
```

## Roadmap

- [ ] More pet types (cat, dog, bird, etc.)
- [ ] Pet interactions (click reactions, idle animations)
- [ ] Sound effects
- [ ] Speed adjustment
- [ ] Launch at login option
- [ ] Keyboard shortcuts
- [ ] Drag to reposition pets
- [ ] Multiple pets at once
- [ ] Pet mood/state system
- [ ] Custom pet creator

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by desktop pet apps from the 90s/2000s
- Built with SwiftUI and AppKit
