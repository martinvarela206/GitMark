import 'package:flutter/material.dart';

/// Servicio reactivo Singleton para monitorear la cuota de la API REST de GitHub.
/// Extiende ChangeNotifier (Sección 7 del Apunte de Cátedra) para notificar
/// automáticamente a la interfaz cuando la cuota cambia tras cada petición HTTP.
class RateLimitService extends ChangeNotifier {
  static final RateLimitService instance = RateLimitService._internal();
  RateLimitService._internal();

  int _remaining = 60;
  int _limit = 60;
  DateTime? _resetTime;

  int get remaining => _remaining;
  int get limit => _limit;
  DateTime? get resetTime => _resetTime;

  // Porcentaje disponible para el aro de progreso (de 0.0 a 1.0)
  double get percentage => _limit > 0 ? (_remaining / _limit).clamp(0.0, 1.0) : 0.0;

  // Semáforo de cátedra según la cuota restante
  Color get color {
    if (_remaining < 5) return Colors.redAccent;
    if (_remaining <= 20) return Colors.amber;
    return Colors.greenAccent;
  }

  // Texto amigable para el tiempo restante de restablecimiento de cuota
  String get resetTimeString {
    if (_resetTime == null) return 'Cuota inicial de 60 peticiones/hora';
    final ahora = DateTime.now();
    final diferencia = _resetTime!.difference(ahora);
    if (diferencia.isNegative) return 'Cuota restablecida';
    return 'Se reinicia en ${diferencia.inMinutes}m ${diferencia.inSeconds % 60}s';
  }

  /// Procesa los encabezados HTTP enviados por GitHub y notifica si hubo cambios
  void updateFromHeaders(Map<String, String> headers) {
    bool cambio = false;

    headers.forEach((key, value) {
      final k = key.toLowerCase();
      if (k == 'x-ratelimit-remaining') {
        final val = int.tryParse(value);
        if (val != null && val != _remaining) {
          _remaining = val;
          cambio = true;
        }
      } else if (k == 'x-ratelimit-limit') {
        final val = int.tryParse(value);
        if (val != null && val != _limit) {
          _limit = val;
          cambio = true;
        }
      } else if (k == 'x-ratelimit-reset') {
        final sec = int.tryParse(value);
        if (sec != null) {
          _resetTime = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        }
      }
    });

    if (cambio) {
      notifyListeners();
    }
  }
}