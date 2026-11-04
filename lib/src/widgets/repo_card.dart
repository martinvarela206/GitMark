import 'package:flutter/material.dart';
import '../models/repository_model.dart';
import '../theme/app_theme.dart';
import 'repo_avatar.dart';
import 'repo_description.dart';
import 'repo_info.dart';

// Este widget le da forma a la cards para mostrar los repositorios y poder accederlos.

class RepoCard extends StatelessWidget {
  // Al definir el modelo del repositorio, no hace falta poner cada una de sus elementos
  final RepositoryModel repository;
  final VoidCallback? onTap;

  const RepoCard({
    super.key,
    required this.repository,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.fondoTarjeta,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppTheme.bordeSutil, width: 1.0),
      ),
      child: InkWell( // Al hacer click sobre la card, produce un efecto de onda (ripple effect) de fondo de todo el contenido de la Card.
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row( // El contenido de RepoCard está compuesto por 1 fila con 3 columnas (los children: Avatar, Contenido del repo, flechita indicadora de acceso)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepoAvatar(avatarUrl: repository.avatarUrl),

              const SizedBox(width: 16), // Añade un gap entre el Avatar y el contenido del RepoCard

              Expanded( // Este widget es para ocupar todo el espacio posible en horizontal
                child: Column( // El contenido del RepoCard se distribuye en forma de columna
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ // Título, Descripción, Estrellas y Lenguajes.
                    RepoDescription(
                      fullName: repository.fullName,
                      description: repository.description,
                    ),
                    const SizedBox(height: 10),
                    RepoInfo(
                      starsCount: repository.starsCount,
                      language: repository.language,
                    ),
                  ],
                ),
              ),

              const Icon( // Flechita para indicar acceso.
                Icons.chevron_right, 
                color: AppTheme.iconoMuted, 
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}