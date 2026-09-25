import 'package:flutter/material.dart';
import 'package:gitmark/src/widgets/repo_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RepoCard(
          fullName: 'LeCoupa/awesome-cheatsheets',
          description: 'Colección curada de cheatsheets para desarrolladores móviles, frontend y backend.',
          starsCount: 38400,
          language: 'Markdown',
          onTap: () {
            // Acción táctil de prueba
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Tocaste la tarjeta!')),
            );
          },
        ),
      ),
    );
  }
}
