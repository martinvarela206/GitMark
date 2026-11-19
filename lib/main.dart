import 'package:flutter/material.dart';
import 'src/app.dart';

/// Punto de entrada principal e inicializador de la aplicación (Entry Point).
/// 
/// ¿Por qué este archivo tiene solo 5 líneas y está separado de app.dart?
/// Sigue el principio de Responsabilidad Única:
/// - main.dart: Solo se encarga de iniciar la ejecución de Dart en el teléfono y levantar el entorno.
/// - app.dart: Se encarga de la configuración de la aplicación (temas, rutas, idiomas y widgets raíz).
void main() {
  // runApp() toma el widget raíz (MainApp) y lo infla para montarlo en la pantalla del dispositivo.
  runApp(const MainApp());
}
