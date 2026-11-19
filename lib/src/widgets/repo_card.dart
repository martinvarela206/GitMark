import 'package:flutter/material.dart';
import '../models/repository_model.dart';
import '../theme/app_theme.dart';
import 'repo_avatar.dart';
import 'repo_description.dart';
import 'repo_info.dart';

/// Tarjeta visual que presenta un repositorio en las listas de la aplicación.
/// 
/// Puntos de diseño y arquitectura:
/// 1. Encapsulación por modelo: En lugar de recibir 8 parámetros sueltos (nombre, estrellas, avatar, etc.),
///    recibe directamente la instancia inmutable RepositoryModel, manteniendo el código limpio y seguro.
/// 2. Efecto táctil (InkWell): Envuelve el contenido en un InkWell para proporcionar la animación de
///    onda táctil (ripple effect) típica de Material Design respetando las esquinas redondeadas.
/// 3. Composición modular: Compuesta en una fila (Row) con 3 sub-widgets especializados:
///    - RepoAvatar: Muestra el avatar o icono por defecto.
///    - Expanded + Column: Ocupa todo el espacio horizontal restante con título, descripción y métricas.
///    - Icon: Flecha indicadora (chevron_right) que sugiere navegación al usuario.
class RepoCard extends StatelessWidget {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepoAvatar(avatarUrl: repository.avatarUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              const Icon(
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
