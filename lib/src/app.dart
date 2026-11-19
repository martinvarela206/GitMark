import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/routes.dart';
import 'theme/app_theme.dart';

/// Widget raíz que configura toda la aplicación mediante MaterialApp.
/// 
/// ¿Por qué es un StatelessWidget?
/// Porque la configuración global (el tema oscuro, el idioma y el diccionario de rutas)
/// es estática y no cambia durante la ejecución de la app.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitMark',
      // Oculta la etiqueta roja de "DEBUG" en la esquina superior derecha
      debugShowCheckedModeBanner: false,

      // Inyección del tema visual oscuro centralizado
      theme: AppTheme.darkTheme,

      // Sistema de rutas nombradas:
      // initialRoute define qué pantalla se abre al inicio ('/' apunta a HomePage)
      initialRoute: '/',
      // Se desacopla la lista de rutas en un archivo independiente (routes.dart)
      routes: getApplicationRoutes(),

      // Configuración de internacionalización:
      // Permite que componentes nativos (diálogos, botones estándar, textos de accesibilidad)
      // se muestren correctamente en español además de inglés.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
    );
  }
}
