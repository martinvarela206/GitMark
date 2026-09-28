import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

class DrawerApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.fondoTarjeta,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
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
          ListTile(
            leading: const Icon(Icons.explore, color: AppTheme.acentoCyan),
            title: const Text('Explorar Repositorios', style: TextStyle(color: AppTheme.textoPrincipal)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.textoSecundario),
            title: const Text('Configuración', style: TextStyle(color: AppTheme.textoPrincipal)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}