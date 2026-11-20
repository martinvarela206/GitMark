import 'package:flutter/material.dart';
import '../services/rate_limit_service.dart';

/// Widget reactivo en el AppBar que visualiza la cuota disponible de la API de GitHub.
/// 
/// ¿Por qué es un StatelessWidget si su contenido cambia en vivo?
/// Porque utiliza el widget reactivo 'ListenableBuilder':
/// En lugar de convertir todo el widget o la pantalla en un StatefulWidget con setState(),
/// ListenableBuilder escucha directamente a 'RateLimitService.instance' y redibuja
/// EXCLUSIVAMENTE este pequeño componente cuando la cuota cambia, optimizando el rendimiento.
/// 
/// Composición visual:
/// - Tooltip: Muestra un mensaje flotante accesible al mantener presionado.
/// - InkWell: Permite pulsar el indicador para abrir un SnackBar con el tiempo de reinicio.
/// - Stack: Superpone dos elementos en el mismo espacio: el aro de progreso circular de fondo
///   y el icono del rayo (Icons.bolt) exactamente en el centro.
/// - Semáforo dinámico: El color del aro, del rayo y del texto cambia reactivamente
///   (verde, ámbar o rojo) según el estado de la cuota calculada por el servicio.
class CuotaApiInfo extends StatelessWidget {
  const CuotaApiInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RateLimitService.instance,
      builder: (context, _) {
        final remaining = RateLimitService.instance.remaining;
        final limit = RateLimitService.instance.limit;
        final progress = RateLimitService.instance.percentage;
        final color = RateLimitService.instance.color;

        return Tooltip(
          message: 'Cuota API GitHub: $remaining/$limit peticiones disponibles',
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cuota GitHub: $remaining de $limit restantes. '
                    '${RateLimitService.instance.resetTimeString}.',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Superposición con Stack: Aro circular exterior + Rayo en el centro
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          value: progress, // Valor entre 0.0 y 1.0
                          strokeWidth: 2.8,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      Icon(
                        Icons.bolt,
                        size: 15,
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Contador numérico de peticiones restantes
                  Text(
                    '$remaining',
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
