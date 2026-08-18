class UnauthorizedException implements Exception {
  const UnauthorizedException({
    this.message = 'Session expirée. Veuillez vous reconnecter.',
  });

  final String message;

  @override
  String toString() {
    return message;
  }
}
