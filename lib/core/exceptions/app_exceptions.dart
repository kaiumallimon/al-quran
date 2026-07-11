/// Base exception for application errors.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException: $message';
}

/// Thrown when a network request fails.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Thrown when the API returns an invalid or unexpected response.
class ApiException extends AppException {
  const ApiException(super.message, {super.code, this.statusCode});

  final int? statusCode;
}

/// Thrown when cached or local data is missing or corrupted.
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Thrown when local storage operations fail.
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// Thrown when audio playback or download fails.
class AudioException extends AppException {
  const AudioException(super.message, {super.code});
}

/// Thrown when authentication fails or the user is unauthorized.
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code});
}

/// Thrown when cloud synchronization fails.
class SyncException extends AppException {
  const SyncException(super.message, {super.code});
}
