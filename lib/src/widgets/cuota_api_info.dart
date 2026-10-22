import 'package:flutter/material.dart';

// Muestra la cuota consumida de consultas gratuitas a la API de GitHub, con un rayo verde, en la esquina superior derecha.

class CuotaApiInfo extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.bolt, color: Colors.green),
      tooltip: 'Cuota API: 60/60',
      onPressed: () {},
    );
  }
}
