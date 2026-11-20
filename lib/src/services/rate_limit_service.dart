import 'package:flutter/material.dart';

/// Servicio reactivo Singleton para monitorear la cuota de peticiones de la API REST de GitHub.
/// 
/// ¿Por qué es un Singleton (`instance` y constructor privado `_internal`)?
/// Para que exista una única fuente de la verdad en toda la aplicación. Tanto el servicio de red
/// (GitHubService) que realiza las peticiones HTTP como el widget visual (CuotaApiInfo) en el AppBar
/// comparten exactamente el mismo objeto en memoria y los mismos datos actualizados.
/// 
/// ¿Por qué extiende `ChangeNotifier`?
/// Implementa el patrón Observer: permite que cualquier widget suscrito (como `ListenableBuilder`)
/// reaccione automáticamente y se redibuje al invocar `notifyListeners()` cuando los valores de
/// la cuota cambien tras recibir una respuesta HTTP de GitHub.
class RateLimitService extends ChangeNotifier {
  // Instancia única y accesible globalmente (Patrón Singleton)
  static final RateLimitService instance = RateLimitService._internal();
  RateLimitService._internal();

  // Valores predeterminados para usuario anónimo de GitHub (60 peticiones/hora)
  int _remaining = 60;
  int _limit = 60;
  DateTime? _resetTime;

  int get remaining => _remaining;
  int get limit => _limit;
  DateTime? get resetTime => _resetTime;

  /// Calcula el porcentaje disponible para el arco del CircularProgressIndicator (de 0.0 a 1.0).
  /// El método .clamp(0.0, 1.0) garantiza que el valor nunca sea menor a 0 ni mayor a 1,
  /// evitando excepciones matemáticas en el widget de progreso.
  double get percentage => _limit > 0 ? (_remaining / _limit).clamp(0.0, 1.0) : 0.0;

  /// Semáforo de advertencia según la cuota restante:
  /// - Verde brillante: Más de 20 peticiones (estado seguro).
  /// - Ámbar / Naranja: Entre 5 y 20 peticiones (precaución, cuota baja).
  /// - Rojo alerta: Menos de 5 peticiones (crítico, riesgo inminente de bloqueo 403).
  Color get color {
    if (_remaining < 5) return Colors.redAccent;
    if (_remaining <= 20) return Colors.amber;
    return Colors.greenAccent;
  }

  /// Genera un texto amigable y legible para el SnackBar indicando cuándo se reinicia la cuota.
  String get resetTimeString {
    if (_resetTime == null) return 'Cuota inicial de 60 peticiones/hora';
    final ahora = DateTime.now();
    final diferencia = _resetTime!.difference(ahora);
    if (diferencia.isNegative) return 'Cuota restablecida';
    return 'Se reinicia en ${diferencia.inMinutes}m ${diferencia.inSeconds % 60}s';
  }

  /// Analiza los encabezados HTTP enviados por GitHub y notifica a la interfaz si hubo cambios.
  /// 
  /// GitHub envía 3 encabezados clave en cada respuesta:
  /// - x-ratelimit-limit: El límite total permitido (60).
  /// - x-ratelimit-remaining: Cuántas peticiones te quedan disponibles.
  /// - x-ratelimit-reset: Timestamp Unix (en segundos) en el que la cuota vuelve a 60.
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
          // GitHub envía el tiempo en segundos; DateTime requiere milisegundos (* 1000)
          _resetTime = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        }
      }
    });

    // Si la cuota cambió con respecto al valor anterior, avisamos a los widgets para que se actualicen
    if (cambio) {
      notifyListeners();
    }
  }
}
