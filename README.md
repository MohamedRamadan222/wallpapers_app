<div align="center">

# Wallpapers

**A curated wallpaper browser with a quiet, dark, grayscale design.**
Discover photos from Pexels, save your favorites, and set them as your home or lock screen in two taps.

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State](https://img.shields.io/badge/State-BLoC-1A1A1E)](https://bloclibrary.dev)
[![API](https://img.shields.io/badge/Photos-Pexels-05A081?logo=pexels&logoColor=white)](https://www.pexels.com/api/)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%C2%B7%20iOS-3DDC84)](#platform-support)
[![Tests](https://img.shields.io/badge/tests-22%20passing-brightgreen)](#testing)

<br />

<img src="docs/screenshots/hero.png" alt="Wallpapers app: Home, Detail, Categories and Saved screens" width="100%" />

</div>

<br />

## Screenshots

<table>
  <tr>
    <td align="center" width="33%">
      <img src="docs/screenshots/01-home.png" alt="Home" /><br />
      <b>Home</b><br />
      <sub>Masonry grid, search and category chips</sub>
    </td>
    <td align="center" width="33%">
      <img src="docs/screenshots/02-search.png" alt="Search" /><br />
      <b>Live search</b><br />
      <sub>Results update as you type</sub>
    </td>
    <td align="center" width="33%">
      <img src="docs/screenshots/03-categories.png" alt="Categories" /><br />
      <b>Categories</b><br />
      <sub>Collections with live counts and thumbnails</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img src="docs/screenshots/05-detail.png" alt="Detail" /><br />
      <b>Detail</b><br />
      <sub>Pinch-zoom preview, photographer and resolution</sub>
    </td>
    <td align="center" width="33%">
      <img src="docs/screenshots/06-set-wallpaper.png" alt="Set wallpaper" /><br />
      <b>Set wallpaper</b><br />
      <sub>Home, lock, or both</sub>
    </td>
    <td align="center" width="33%">
      <img src="docs/screenshots/07-saved.png" alt="Saved" /><br />
      <b>Saved</b><br />
      <sub>Your favorites in one place</sub>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="3">
      <img src="docs/screenshots/04-saved-empty.png" alt="Saved, empty state" width="33%" /><br />
      <b>Empty state</b><br />
      <sub>A friendly nudge before you've saved anything</sub>
    </td>
  </tr>
</table>

<sub>Captured on a Pixel 7 Pro emulator running the real app against the live Pexels API.</sub>

## Features

- **Masonry browsing**: a staggered two-column grid of curated, portrait-oriented photos with infinite scroll.
- **Live search**: type to search all of Pexels, with a friendly empty state when nothing matches.
- **Category chips and collections**: Nature, Abstract, Minimal, AMOLED, Gradient, and Architecture. Chips combine with search, and the Categories tab shows live photo counts.
- **Immersive detail view**: full-screen preview with pinch-zoom (up to 4×), swipe-down to dismiss, the photographer's name, and the original resolution.
- **Set as wallpaper**: choose **Home screen**, **Lock screen**, or **Home and lock** (Android).
- **Download**: save any photo straight to your gallery.
- **Favorites**: tap the heart to collect wallpapers in the Saved tab.
- **Graceful failure**: skeleton loaders, offline and error states with retry, and a neutral gradient when an image can't load.
- **Quiet design**: a zinc-gray, dark-only palette so the photos are the only color on screen.

## Architecture

The app follows a layered, clean-architecture structure. The UI never talks to the network directly, and the domain layer has no Flutter or HTTP dependencies.

```mermaid
flowchart LR
    subgraph Presentation
        UI[Screens and widgets] --> BLoC[HomeBloc / FavoritesBloc]
    end
    subgraph Domain
        UC[Use cases] --> Repo[(WallpaperRepository)]
        Dev[(WallpaperDeviceActions)]
    end
    subgraph Data
        Impl[WallpaperRepositoryImpl] --> Pexels[PexelsRemoteDataSource]
        Impl --> Fav[FavoritesStore]
        Svc[WallpaperDeviceService] --> Native[[MethodChannel<br/>wallpapers_app/native]]
    end
    BLoC --> UC
    UI --> UC
    Repo -.implemented by.-> Impl
    Dev -.implemented by.-> Svc
    Pexels --> API[(Pexels API)]
```

Dependencies are constructor-injected into the root `WallpapersApp` widget, so tests can swap in fakes without touching production wiring.

### Project structure

```text
lib/
├── core/
│   ├── error/            # AppFailure hierarchy
│   └── theme/            # Zinc color palette and dark ThemeData
├── data/
│   ├── datasources/      # Pexels REST client
│   ├── models/           # JSON → entity mapping
│   ├── repositories/     # WallpaperRepository implementation
│   ├── services/         # Download + native channel bridge
│   └── stores/           # In-memory favorites
├── domain/
│   ├── device/           # Set-wallpaper / save-to-gallery contract
│   ├── entities/         # Wallpaper, WallpaperCategory, CategoryInfo
│   ├── repositories/     # Repository contract
│   └── usecases/         # GetWallpapers, SearchWallpapers, ToggleFavorite, …
├── presentation/
│   ├── bloc/             # Home and Favorites BLoCs
│   ├── detail/           # Full-screen wallpaper detail
│   ├── screens/          # App shell, Home, Categories, Favorites
│   └── widgets/          # WallpaperCard, SearchField, EmptyState
└── main.dart
```

### Tech stack

| Concern | Choice |
| --- | --- |
| Framework | [Flutter](https://flutter.dev) (Material 3, dark theme) |
| State management | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) + [`equatable`](https://pub.dev/packages/equatable) |
| Layout | [`flutter_staggered_grid_view`](https://pub.dev/packages/flutter_staggered_grid_view) |
| Networking | [`http`](https://pub.dev/packages/http) |
| Photos | [Pexels API](https://www.pexels.com/api/) |
| Device actions | Platform channel (Kotlin on Android, Swift on iOS) |

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.47 or newer (Dart 3.13)
- An Android emulator or device, or an iOS simulator or device
- A free [Pexels API key](https://www.pexels.com/api/)

### Run it

```bash
git clone https://github.com/MohamedRamadan222/wallpapers_app.git
cd wallpapers_app
flutter pub get
flutter run --dart-define=PEXELS_API_KEY=your_pexels_key
```

The key is compiled in at build time with `--dart-define`, so it never needs to live in source control. Without it, the app shows a "Missing Pexels API key" message instead of photos.

To build a release APK:

```bash
flutter build apk --release --dart-define=PEXELS_API_KEY=your_pexels_key
```

> **Tip:** in VS Code or Android Studio, add `--dart-define=PEXELS_API_KEY=...` to your run configuration's additional arguments.

## Platform support

| Feature | Android | iOS |
| --- | :---: | :---: |
| Browse, search, categories, favorites | ✅ | ✅ |
| Download to gallery | ✅ | ✅ |
| Set as home / lock wallpaper | ✅ | ➖ iOS doesn't let apps change the wallpaper. The app explains this and suggests setting it from Photos. |

## Testing

```bash
flutter test      # 22 unit and widget tests
flutter analyze
```

The suite covers the Pexels repository, the device-action service (with a mocked `MethodChannel`), and end-to-end widget flows: loading the catalog, search and empty results, category filtering, the detail sheet, swipe-to-dismiss, favoriting, and pagination. A fake Pexels HTTP client keeps the tests offline and deterministic.

## Credits

All photos are provided by [Pexels](https://www.pexels.com) and belong to their photographers, who are credited in each wallpaper's detail view. This app is not affiliated with Pexels.
