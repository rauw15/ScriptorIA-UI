class AppConstants {
  // Tiempos de animación
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Textos de la aplicación
  static const String appName = 'AprendIA';
  static const String appSubtitle = 'Mejora tu caligrafía con IA';
  static const String loginTitle = 'Iniciar Sesión';
  static const String loginSubtitle = 'Bienvenido de nuevo a AprendIA';
  
  // Validaciones
  static const int minPasswordLength = 8;
  
  // API Configuration
  static const String apiBaseUrl = 'http://192.168.70.3:8000';
  static const String traceServiceBaseUrl = 'http://192.168.70.3:8001'; // URL del trace-service
  static const String authEndpoint = '';
  
  // Trace Service Endpoints
  static const String practicesEndpoint = '/practices';
  static const String practicesHistoryEndpoint = '/practices/history';
  static const String healthEndpoint = '/health';
  
  // Modo simulación
  static const bool simulateTraceService = false;
  static const bool simulateAIAnalysis = true; // Si es true, actualiza automáticamente el análisis usando el endpoint PUT /practices/{id}/analysis
}
