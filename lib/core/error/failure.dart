/// Domain-level failures. Repository implementations throw these;
/// blocs translate them into error states.
sealed class AppFailure implements Exception {
  const AppFailure([this.message = 'Something went wrong.']);

  final String message;
}

final class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Could not load wallpapers.']);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Wallpaper not found.']);
}

final class DeviceActionFailure extends AppFailure {
  const DeviceActionFailure([
    super.message = 'Could not complete that action.',
  ]);
}

final class MissingApiKeyFailure extends AppFailure {
  const MissingApiKeyFailure([
    super.message = 'Missing Pexels API key. Rebuild with --dart-define=PEXELS_API_KEY=your_key.',
  ]);
}
