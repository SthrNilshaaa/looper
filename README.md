# OnePlayer 🎵

A full-featured, modern Linux desktop music player built with Flutter and Rust.

## Features
- **Modern UI**: Polished Material 3 design with Glassmorphism and smooth animations.
- **Wide Format Support**: MP3, FLAC, OPUS, AAC, WAV, OGG, and more (via libmpv).
- **Fast Library**: Recursive folder scanning and indexing for 50k+ tracks.
- **Native Integration**: Custom title bar and Linux-optimized performance.
- **Smart Management**: Organize by Songs, Albums, Artists, and Genres.

## Tech Stack
- **Framework**: [Flutter](https://flutter.dev)
- **Audio Engine**: [media_kit](https://github.com/alexmercerind/media_kit) (libmpv)
- **Database**: [Isar](https://isar.dev)
- **Metadata**: [metadata_god](https://pub.dev/packages/metadata_god)
- **State Management**: [Riverpod](https://riverpod.dev)

## Getting Started

### Prerequisites
Ensure you have the following installed on your Linux distribution:
```bash
# Ubuntu/Debian
sudo apt install libmpv-dev mpv
```

### Build Instructions
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run -d linux
   ```

## License
MIT
