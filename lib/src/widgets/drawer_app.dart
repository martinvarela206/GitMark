import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Menú lateral deslizable (Drawer) de la aplicación.
/// 
/// ¿Por qué usar un Drawer en diseño móvil?
/// Permite mantener la interfaz limpia y despejada en pantallas reducidas de teléfonos,
/// ocultando opciones secundarias de navegación (explorar, configuración) hasta que el
/// usuario las solicite mediante el botón de menú (hamburguesa) o deslizando desde el borde.
class DrawerApp extends StatelessWidget {
  const DrawerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.fondoTarjeta,
      // ListView ya incluye scroll interno por si la lista de opciones excede el alto de la pantalla
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Cabecera temática con branding y versión de la aplicación
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.fondoPrincipal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.terminal, color: AppTheme.acentoCyan, size: 36),
                SizedBox(height: 8),
                Text(
                  'GitMark Mobile',
                  style: TextStyle(
                    color: AppTheme.textoPrincipal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'v0.3 - Modo Anónimo',
                  style: TextStyle(color: AppTheme.textoSecundario, fontSize: 12),
                ),
              ],
            ),
          ),

          // Opciones de navegación:
          // Navigator.pop(context) cierra el Drawer para devolver el foco a la pantalla principal
          ListTile(
            leading: const Icon(Icons.explore, color: AppTheme.acentoCyan),
            title: const Text(
              'Explorar Repositorios',
              style: TextStyle(color: AppTheme.textoPrincipal),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.textoSecundario),
            title: const Text(
              'Configuración',
              style: TextStyle(color: AppTheme.textoPrincipal),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
