import 'package:flutter/material.dart';

/// Centralización de estilos, tokens de diseño y tema visual oscuro de GitMark.
/// 
/// ¿Por qué centralizar los estilos en una clase con constantes (`static const`)?
/// 1. Evita repetir colores mágicos como Color(0xFF0D1117) en decenas de widgets distintos.
/// 2. Al ser 'static const', los colores se resuelven en tiempo de compilación y no ocupan
///    memoria duplicada al construir las pantallas.
/// 3. Si se desea cambiar la identidad visual (por ejemplo, el color cyan de acento),
///    se modifica en una sola línea y se actualiza en toda la app de forma instantánea.
class AppTheme {
  // --- Colores Base de la Paleta GitMark (inspirada en la interfaz oscura de GitHub) ---
  static const Color fondoPrincipal = Color(0xFF0D1117); // Fondo general de Scaffold
  static const Color fondoTarjeta   = Color(0xFF161B22); // Superficie de las tarjetas
  static const Color bordeSutil      = Color(0xFF30363D); // Bordes tenues de división
  static const Color fondoAvatar     = Color(0xFF21262D); // Contenedor del icono/avatar

  // --- Colores de Acento e Identidad ---
  static const Color acentoCyan      = Color(0xFF00BCD4); // Identidad de GitMark
  static const Color acentoEstrellas = Color(0xFFFFD54F); // Color ámbar para estrellas ⭐
  static const Color colorPrimario   = Colors.blue;

  // --- Tipografías y Textos ---
  static const Color textoBlanco     = Colors.white;
  static const Color textoPrincipal  = Colors.white;
  static const Color textoSecundario = Color(0xFF8B949E);
  static const Color iconoMuted      = Color(0xFF484F58);

  // Verde característico de GitHub para resaltar bloques de código Markdown
  static const Color codigoVerde     = Color(0xFF7EE787);

  static const double sizeH1 = 32.0;

  /// Configuración global de ThemeData inyectada en MaterialApp.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: fondoPrincipal,

    // Estilo predeterminado para todas las tarjetas (Cards) de la aplicación
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
