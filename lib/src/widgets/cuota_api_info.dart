import 'package:flutter/material.dart';

/// Indicador visual del consumo de cuota de la API REST de GitHub.
/// 
/// ¿Qué representa?
/// La API pública de GitHub impone un límite estricto de 60 peticiones gratuitas por hora
/// a usuarios anónimos (sin token). Este icono en el AppBar (rayo verde) simboliza el estado
/// de la cuota restante (60/60) para alertar al usuario antes de ser bloqueado temporalmente.
class CuotaApiInfo extends StatelessWidget {
  const CuotaApiInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.bolt, color: Colors.green),
      tooltip: 'Cuota API: 60/60 peticiones disponibles',
      onPressed: () {},
    );
  }
}
