# Movie Library

A Flutter (Material 3, dark cinematic theme) app that displays a movie collection with
real-time search, a List/Grid view toggle, local poster images, and a shared
"bonus" badge that updates on every card at once.

## Features

- 50 movies with local poster images (`Image.asset`, `BoxFit.cover`, error fallback)
- Live, case-insensitive search by title or genre; "No movies found" empty state
- AppBar button toggles between List View (`ListView.builder`) and Grid View
  (`GridView.builder`, exactly 2 columns) using the same `MovieCard`
- Shared bonus badge (starts at 20%): tapping any card's badge lowers the value on
  all cards by 1, never below 0. Implemented with only `setState()` and `VoidCallback`;
  `MovieCard` stays a `StatelessWidget`; no state-management packages

## Project structure

```text
movie_library/
├── assets/posters/        # 8 poster images (see note below)
├── lib/
│   ├── main.dart          # MaterialApp + theme
│   ├── movie.dart         # Movie model + movies list
│   ├── movie_card.dart    # Stateless card widget
│   └── home_page.dart     # Search, view toggle, shared bonus state
├── test/widget_test.dart  # Small widget tests (search empty state, bonus tap)
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── .gitignore
```

> **Poster images:** the files in `assets/posters/` are generated **placeholders**
> (gradient + title). To use real posters, replace the files **keeping the same
> filenames**: `inception.jpg`, `dark_knight.jpg`, `interstellar.jpg`, `titanic.jpg`,
> `avengers.jpg`, `joker.jpg`, `avatar.jpg`, `lion_king.jpg`.

## Setup

This archive contains the Dart sources and assets but not the platform folders
(`android/`, `ios/`, ...). Generate them once from inside the project folder:

```bash
flutter create . --project-name movie_library
flutter pub get
```

## Load 50 movies from TMDB

The app ships with 8 placeholder posters. To replace them with 50 real movies
(title, genre, year, rating, poster) from [TMDB](https://www.themoviedb.org/):

1. Create a free TMDB account and request an API key (Settings -> API). Use the **v3 API Key**.
2. From the project root run:

```powershell
# Windows PowerShell
$env:TMDB_API_KEY="YOUR_V3_KEY"; dart run tool/fetch_tmdb.dart
```
```bash
# macOS / Linux
TMDB_API_KEY=YOUR_V3_KEY dart run tool/fetch_tmdb.dart
```

The script downloads posters into `assets/posters/` and rewrites `lib/movie.dart`.
By default it uses TMDB's *top rated* chart; use `--list <TMDB_LIST_ID>` for a TMDB list.
Then run `flutter run` (a full restart is needed after assets change).

This product uses the TMDB API but is not endorsed or certified by TMDB.

## Analyze, test and run

```bash
flutter analyze
flutter test
flutter run            # with an Android emulator running or a device connected
```

Requires Flutter 3.22 or newer (Dart 3.4+).

## Screenshots

Add the two required screenshots to a `screenshots/` folder and reference them here:

1. **List View** – multiple cards visible: `screenshots/list_view.png`
2. **Grid View with search `action`** – two columns of results: `screenshots/grid_search.png`

How to capture:
- **Android Studio emulator:** click the camera icon in the emulator's side toolbar
  (or `adb exec-out screencap -p > screenshots/list_view.png`).
- **VS Code / DevTools:** use the emulator's screenshot button.
- **Real device:** use the device's screenshot shortcut and copy the file to your computer.

## GitHub submission

Create an empty repository on GitHub first, then (replace `<YOUR_REPOSITORY_URL>`
with the URL GitHub shows you):

```bash
git init
git add .
git commit -m "Initial commit: Movie Library Flutter app"
git branch -M main
git remote add origin <YOUR_REPOSITORY_URL>
git push -u origin main
```

`.gitignore` already excludes `build/`, `.dart_tool/` and other generated files.
# movie_library
