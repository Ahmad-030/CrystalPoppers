# CrystalPopperz — Image Assets

Place the following image files in this `assets/images/` folder:

| File                  | Used In       | Recommended Size | Notes                              |
|-----------------------|---------------|------------------|------------------------------------|
| splash_bg.png         | Splash screen | 1080×1920px      | Dark purple/fantasy crystal theme  |
| menu_bg.png           | Main menu     | 1080×1920px      | Bright crystals, light theme       |
| crystal_red.png       | (optional)    | 128×128px        | Custom crystal art                 |
| crystal_blue.png      | (optional)    | 128×128px        |                                    |
| crystal_green.png     | (optional)    | 128×128px        |                                    |
| crystal_yellow.png    | (optional)    | 128×128px        |                                    |
| crystal_purple.png    | (optional)    | 128×128px        |                                    |
| crystal_cyan.png      | (optional)    | 128×128px        |                                    |

## To Use Background Images
In `splash_screen.dart`, replace the `AnimatedBuilder` gradient block with:
```dart
Image.asset('assets/images/splash_bg.png', fit: BoxFit.cover)
```

In `main_menu_screen.dart`, replace the gradient `Container` with:
```dart
Image.asset('assets/images/menu_bg.png', fit: BoxFit.cover)
```

## Suggested AI Prompt for Image Generation
"Fantasy match-3 mobile game background, colorful glowing crystals,
purple and pink gradient sky, sparkles, light theme, portrait orientation,
game UI background art style, 1080x1920"
