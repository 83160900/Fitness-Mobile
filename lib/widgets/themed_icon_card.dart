import 'package:flutter/material.dart';

/// ThemedIconCard
/// Um widget padronizado para exibir ícones no estilo "icon-card"
/// respeitando a paleta Navy/Emerald do app.
///
/// Pode ser usado com/sem label e em dois tamanhos (small/medium).
class ThemedIconCard extends StatelessWidget {
  final String? category; // ex: membros-inferiores, core, funcional, maquinas, mobilidade, reabilitacao
  final IconData? icon;   // fallback quando não for categoria mapeada
  final String? label;    // rótulo opcional
  final double size;      // tamanho do círculo do ícone (40=small, 56=medium)
  final bool filled;      // se true, usa fundo sólido; senão, leve

  const ThemedIconCard({
    super.key,
    this.category,
    this.icon,
    this.label,
    this.size = 56,
    this.filled = false,
  });

  Color get _primary => const Color(0xFF0F2A3D);
  Color get _secondary => const Color(0xFF1F6F5C);
  Color get _border => const Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = icon ?? _iconForCategory(category);
    final scheme = Theme.of(context).colorScheme;

    final bg = filled
        ? _secondary
        : _secondary.withOpacity(0.10);
    final fg = filled
        ? Colors.white
        : _secondary;

    final widgetIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: filled ? null : Border.all(color: _border),
      ),
      alignment: Alignment.center,
      child: Icon(resolvedIcon, color: fg, size: size * 0.5),
    );

    if (label == null || label!.isEmpty) {
      return widgetIcon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widgetIcon,
        const SizedBox(height: 8),
        SizedBox(
          width: size * 2,
          child: Text(
            label!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onBackground,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _iconForCategory(String? cat) {
    switch ((cat ?? '').toLowerCase()) {
      case 'membros-inferiores':
        return Icons.directions_run; // sugestão: perna/agachamento
      case 'membros-superiores':
        return Icons.fitness_center; // halteres
      case 'core':
        return Icons.self_improvement; // postura/core
      case 'funcional':
      case 'funcional / cardio':
        return Icons.timer; // cardio/funcional
      case 'maquinas':
        return Icons.precision_manufacturing; // máquinas
      case 'mobilidade':
        return Icons.accessibility_new; // alongamento/mobilidade
      case 'reabilitacao':
      case 'reabilitação':
        return Icons.healing; // reabilitação
      default:
        return Icons.apps; // genérico
    }
  }
}
