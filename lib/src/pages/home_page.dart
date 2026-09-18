import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            'Hola Mundo',
            style: Theme.of(context).textTheme.displayLarge, // Uso del tema definido
        ),
      ),
    );
  }
}