import 'package:flutter/material.dart';

// Clase simple para guardar nuestros estilos y no repetir código
class AppTheme {
  // Valores preestablecidos
  static const Color fondoPrincipal = Color(0xFF0D1117);
  static const Color colorPrimario = Colors.blue;
  static const Color textoBlanco = Colors.white;
  static const double sizeH1 = 32.0;

  // Uso de variable estática con un objeto ThemeData(). Es un objeto gigante con todas las configuraciones de estilo de la aplicación flutter.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true, // Define que se utilice la versión mas reciente de diseño de Material Design (versión 3).
    brightness: Brightness.dark, // Define que se va a utilizar como base el tema oscuro. El tema propio de la aplicación se construye sobre el Light Theme o el Dark Theme de Google.
    scaffoldBackgroundColor: fondoPrincipal, // De modifica el color de fondo de las pantallas
    
    // Aquí guardamos los estilos de texto para reutilizarlos
    textTheme: const TextTheme(
      displayLarge: TextStyle( // Estilo para los Títulos principales (H1)
        fontSize: sizeH1,
        fontWeight: FontWeight.bold,
        color: textoBlanco,
      ),
    ),
  );
}