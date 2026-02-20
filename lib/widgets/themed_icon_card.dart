import 'dart:ui';
import 'package:flutter/material.dart';

class ThemedIconCard extends StatelessWidget {
  final String? category; 
  final IconData? icon;   
  final String? label;    
  final double size;      
  final bool filled;      

  const ThemedIconCard({
    super.key,
    this.category,
    this.icon,
    this.label,
    this.size = 56,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> style = _getStyleForCategory(category, icon);
    final IconData resolvedIcon = style['icon'];
    final Color baseColor = style['color'];
    
    // Design Glassmorphism / Premium
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 1.4,
          height: size * 1.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withOpacity(0.2),
                baseColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: baseColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Center(
                child: Icon(
                  resolvedIcon,
                  color: baseColor,
                  size: size * 0.7,
                ),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: size * 2.2,
            child: Text(
              label!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F2A3D),
                letterSpacing: -0.5,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ],
    );
  }

  Map<String, dynamic> _getStyleForCategory(String? cat, IconData? fallbackIcon) {
    switch ((cat ?? '').toLowerCase()) {
      case 'membros-inferiores':
        return {
          'icon': Icons.airline_seat_legroom_extra, 
          'color': Colors.orange[700]!,
        };
      case 'membros-superiores':
        return {
          'icon': Icons.fitness_center,
          'color': const Color(0xFF1F6F5C),
        };
      case 'core':
        return {
          'icon': Icons.accessibility_new,
          'color': Colors.blue[600]!,
        };
      case 'funcional':
      case 'funcional / cardio':
        return {
          'icon': Icons.bolt,
          'color': Colors.amber[800]!,
        };
      case 'maquinas':
        return {
          'icon': Icons.settings_input_component,
          'color': Colors.blueGrey[700]!,
        };
      case 'mobilidade':
        return {
          'icon': Icons.self_improvement,
          'color': Colors.purple[400]!,
        };
      case 'reabilitacao':
      case 'reabilitação':
        return {
          'icon': Icons.medical_services,
          'color': Colors.red[400]!,
        };
      default:
        return {
          'icon': fallbackIcon ?? Icons.grid_view_rounded,
          'color': const Color(0xFF1F6F5C),
        };
    }
  }
}
