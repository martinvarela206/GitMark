import 'package:flutter/material.dart';
import '../services/rate_limit_service.dart';

/// Widget reactivo situado en el AppBar superior que muestra la cuota restante
/// de peticiones a la API de GitHub mediante un aro circular de carga y semáforo.
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
                  // Aro circular con el rayo en su centro
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          value: progress,
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
                  // Valor numérico de cuota restante
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