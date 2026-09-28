import 'package:flutter/material.dart';
import 'package:gitmark/src/widgets/repo_avatar.dart';
import 'package:gitmark/src/widgets/repo_description.dart';
import 'package:gitmark/src/widgets/repo_info.dart' show RepoInfo;
import '../theme/app_theme.dart';

class RepoCard extends StatelessWidget {
  final String fullName;
  final String description;
  final int starsCount;
  final String language;
  final VoidCallback? onTap;

  const RepoCard({ // Todos los argumentos para la RepoCard:
    super.key,
    required this.fullName,
    required this.description,
    required this.starsCount,
    required this.language,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card( // Este widget es el contenedor general de RepoCard, define una caja con elevación, bordes definidos y margen exterior.
      elevation: 0,
      color: AppTheme.fondoTarjeta,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0), // Clase de datos para definir dimensiones en los 4 costados.
      shape: RoundedRectangleBorder( // Define que la Card sea redondeada en sus esquinas
        borderRadius: BorderRadius.circular(12.0), // Establece la redondez de las esquinas de la RepoCard
        side: const BorderSide(color: AppTheme.bordeSutil, width: 1.0), // Establece el borde de la RepoCard
      ),
      child: InkWell( // Al hacer click sobre la card, produce un efecto de onda (ripple effect), de fondo de todo el contenido de la Card.
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row( // El contenido de RepoCard esta compuesto por 1 fila con 3 columnas (los children: Avatar, Contenido del repo, flechita indicadora de acceso al repo)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const RepoAvatar(),

              const SizedBox(width: 16), // Añade un gap entre el Avatar y el contenido del RepoCard

              Expanded( // Este widget es para ocupar todo lo posible en horizontal
                child: Column( // El contenido del RepoCard se distribuye en forma de columna
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ // Titulo, Descripcion, Estrellas y Lenguajes.
                    
                    RepoDescription(
                      fullName: fullName,
                      description: description,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    RepoInfo(
                      starsCount: starsCount,
                      language: language,
                    ),
                  ],
                ),
              ),

              const Icon( // Flechita para indicar acceso.
                Icons.chevron_right, 
                color: AppTheme.iconoMuted, size: 20
              ),
            ],
          ),
        ),
      ),
    );
  }
}