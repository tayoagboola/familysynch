class AppConstants {
  // FastAPI base URL — set per environment
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://familysync-api.herokuapp.com',
  );

  // WebSocket base URL — wss for production
  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://familysync-api.herokuapp.com',
  );
}
