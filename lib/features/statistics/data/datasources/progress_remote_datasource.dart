import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';

/// DTO sencillo para las métricas generales de usuario devueltas
/// por progress-service (UserMetricsDTO).
class UserMetrics {
  final String userId;
  final int totalPractices;
  final int activeDays;
  final int totalAchievements;
  final DateTime? lastActivityDate;

  UserMetrics({
    required this.userId,
    required this.totalPractices,
    required this.activeDays,
    required this.totalAchievements,
    this.lastActivityDate,
  });

  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    return UserMetrics(
      userId: json['user_id'] as String,
      totalPractices: json['total_practices'] as int,
      activeDays: json['active_days'] as int,
      totalAchievements: json['total_achievements'] as int,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
    );
  }
}

/// Cliente remoto para progress-service.
class ProgressRemoteDataSource {
  final ApiClient apiClient;

  ProgressRemoteDataSource({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// Obtiene las métricas generales de un usuario desde progress-service.
  Future<UserMetrics> getUserMetrics(String userId) async {
    final String url =
        '${AppConstants.progressServiceBaseUrl}${AppConstants.progressMetricsEndpoint}/$userId';

    try {
      final Response response = await apiClient.get(url);
      return UserMetrics.fromJson(
        (response.data as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw Exception(
          'Error al obtener métricas de progreso: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Error al obtener métricas de progreso: $e');
    }
  }
}


