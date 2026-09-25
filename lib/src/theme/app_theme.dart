import 'package:flutter/material.dart';

// Clase simple para guardar nuestros estilos y no repetir código
class AppTheme {
  // --- Colores Base de la Paleta GitMark ---
  static const Color fondoPrincipal = Color(0xFF0D1117); // Fondo general del Scaffold
  static const Color fondoTarjeta   = Color(0xFF161B22); // Superficie de la tarjeta
  static const Color bordeSutil      = Color(0xFF30363D); // Borde de la tarjeta
  static const Color fondoAvatar     = Color(0xFF21262D); // Caja del icono/avatar

  // --- Colores de Acento ---
  static const Color acentoCyan      = Color(0xFF00BCD4); // Color identidad GitMark
  static const Color acentoEstrellas = Color(0xFFFFD54F); // Color para estrellas ⭐
  static const Color colorPrimario   = Colors.blue;

  // --- Tipografías y Textos ---
  static const Color textoBlanco     = Colors.white;
  static const Color textoPrincipal  = Colors.white;
  static const Color textoSecundario = Color(0xFF8B949E);
  static const Color iconoMuted      = Color(0xFF484F58);

  static const double sizeH1 = 32.0;

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: fondoPrincipal,

    // Estilo predeterminado para las tarjetas (Cards)
    cardTheme: CardThemeData(
      color: fondoTarjeta,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: bordeSutil, width: 1.0),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: sizeH1,
        fontWeight: FontWeight.bold,
        color: textoBlanco,
      ),
    ),
  );
}