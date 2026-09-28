import 'package:flutter/material.dart';
import 'package:gitmark/src/theme/app_theme.dart';

class RepoDescription extends StatelessWidget {
  final String fullName;
  final String description;

  const RepoDescription({ // Este widget recibe 2 argumentos: fullName y description
    super.key,
    required this.fullName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text( // Titulo/url del repo, si desborda se coloca "..." (con ellipsis), para indicar que no entro todo el texto.
          fullName,
          style: const TextStyle(
            color: AppTheme.textoPrincipal,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, 
        ),
        
        const SizedBox(height: 4), // Separador tipo gap vertical
        
        Text(
          description,
          style: const TextStyle(
            color: AppTheme.textoSecundario,
            fontSize: 13,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}