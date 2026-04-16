# CrystalPopperz — Lottie Animations

Place Lottie JSON files in this `assets/animations/` folder.

| File              | Used In          | Description                          |
|-------------------|------------------|--------------------------------------|
| splash.json       | Splash screen    | Crystal sparkle / logo animation     |
| menu_idle.json    | Main menu        | Background floating crystals loop    |
| level_win.json    | Level complete   | Stars/confetti celebration burst     |
| game_over.json    | Game over screen | Sad crystal or explosion             |
| power_fire.json   | Game board       | Fire crystal activation effect       |
| power_bomb.json   | Game board       | Bomb explosion effect                |
| power_lightning.json | Game board    | Lightning strike effect              |

## Free Lottie Sources
- https://lottiefiles.com (search: crystals, match, puzzle, celebration)
- https://iconscout.com/lottie-animations

## How to Integrate (already wired in code)
Screens already import `lottie` package. To activate:

```dart
import 'package:lottie/lottie.dart';

// Add to splash screen:
Lottie.asset('assets/animations/splash.json', width: 200, height: 200)

// Add to level complete dialog:
Lottie.asset('assets/animations/level_win.json', width: 180, height: 180, repeat: false)
```

## Note
All screens work without animations present — graceful fallback to emoji/text.
