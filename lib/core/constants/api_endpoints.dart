/// API endpoints and network configuration constants matching backend OpenAPI specification.
abstract final class ApiEndpoints {
  /// Default base URL for Android emulator
  static const String defaultAndroidBaseUrl = 'http://10.0.2.2:8080';

  /// Base URL for localhost (iOS simulator, desktop, web)
  static const String defaultLocalhostBaseUrl = 'http://localhost:8080';

  /// Active base URL (defaulting to Android emulator)
  static String baseUrl = defaultAndroidBaseUrl;

  /// Connection & receive timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Authentication
  static const String login = '/api/v1/auth/login';
  static const String logout = '/api/v1/auth/logout';
  static const String refresh = '/api/v1/auth/refresh';

  // Analytics (Owner only)
  static const String sellersRanking = '/api/v1/analytics/sellers-ranking';
  static const String topProducts = '/api/v1/analytics/top-products';
  static const String analyticsSummary = '/api/v1/analytics/summary';

  // Expenses (Owner only)
  static const String expenses = '/api/v1/expenses';

  // Orders & POS
  static const String orders = '/api/v1/orders';
  static String orderRefund(String orderId) => '/api/v1/orders/$orderId/refund';

  // Products & Inventory
  static const String products = '/api/v1/products';
  static String productById(String id) => '/api/v1/products/$id';
  static String productByQr(String qr) => '/api/v1/products/by-qr/$qr';

  // Sellers (Owner & Staff)
  static const String sellers = '/api/v1/sellers';
  static const String myEarnings = '/api/v1/sellers/my-earnings';
  static String sellerCommission(String sellerId) =>
      '/api/v1/sellers/$sellerId/commission';

  // Health
  static const String health = '/health';
}
