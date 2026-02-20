import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    
    // Design "Sharp" (Bordas mais retas e profissionais)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 1.3,
          height: size * 1.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), // "Sharp" (menos arredondado)
            color: Colors.white,
            border: Border.all(
              color: baseColor.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Efeito "Duotone" simulado (camada de fundo suave)
              FaIcon(
                resolvedIcon,
                color: baseColor.withOpacity(0.15),
                size: size * 0.75,
              ),
              // Ícone Principal (Sharp)
              FaIcon(
                resolvedIcon,
                color: baseColor,
                size: size * 0.55,
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: size * 2.5,
            child: Text(
              label!.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F2A3D),
                letterSpacing: 1.0,
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
          'icon': FontAwesomeIcons.personRunning, 
          'color': const Color(0xFFE67E22), // Laranja Profissional
        };
      case 'membros-superiores':
        return {
          'icon': FontAwesomeIcons.dumbbell,
          'color': const Color(0xFF1F6F5C), // Verde Esmeralda
        };
      case 'core':
        return {
          'icon': FontAwesomeIcons.userNinja,
          'color': const Color(0xFF2980B9), // Azul Focado
        };
      case 'funcional':
      case 'funcional / cardio':
        return {
          'icon': FontAwesomeIcons.bolt,
          'color': const Color(0xFFF1C40F), // Amarelo Energia
        };
      case 'maquinas':
        return {
          'icon': FontAwesomeIcons.gear,
          'color': const Color(0xFF34495E), // Cinza Máquina
        };
      case 'mobilidade':
        return {
          'icon': FontAwesomeIcons.personWalking,
          'color': const Color(0xFF9B59B6), // Roxo Flexibilidade
        };
      case 'reabilitacao':
      case 'reabilitação':
        return {
          'icon': FontAwesomeIcons.kitMedical,
          'color': const Color(0xFFE74C3C), // Vermelho Cuidado
        };
      default:
        return {
          'icon': fallbackIcon ?? FontAwesomeIcons.folderOpen,
          'color': const Color(0xFF1F6F5C),
        };
    }
  }
}
