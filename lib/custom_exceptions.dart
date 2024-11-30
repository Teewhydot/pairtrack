class PairFullException implements Exception {
  final String message;
  PairFullException(this.message);
}

class PairNotFoundException implements Exception {
  final String message;
  PairNotFoundException(this.message);
}

class LocationUpdateException implements Exception {
  final String message;
  LocationUpdateException(this.message);
}
