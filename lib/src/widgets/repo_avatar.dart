import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

class RepoAvatar extends StatelessWidget {
  const RepoAvatar({super.key}); // El widget RepoAvatar no recibe argumentos

  @override
  Widget build(BuildContext context) {
    return Container( // Este widget contenedor es muy personalizable
      width: 40,
      height: 40,
      decoration: BoxDecoration( // Clase de datos para describir configuraciones visuales de los widgets contenedores
        color: AppTheme.fondoAvatar,
        borderRadius: BorderRadius.circular(8.0), // Clase de datos para describir la configuración visual de la curvatura de las esquinas de los widgets contenedores
      ),
      child: const Icon( // StatelessWidget para dibujar Iconos en base codepoint
        Icons.code, 
        color: AppTheme.acentoCyan, 
        size: 22,
      ),
    );
  }
}