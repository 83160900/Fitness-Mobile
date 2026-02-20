import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitness_mobile/widgets/themed_icon_card.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String baseUrl = 'https://fitness-backtend-production.up.railway.app/api';
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final Map<String, dynamic> userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    final String userEmail = userData['email'] ?? '';

    if (userEmail.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications?email=$userEmail')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          _notifications = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Erro ao carregar notificações: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await http.post(Uri.parse('$baseUrl/notifications/$id/read'));
      _loadNotifications();
    } catch (e) {
      print('Erro ao marcar como lida: $e');
    }
  }

  Future<void> _markAsArchived(String id) async {
    try {
      // Usamos um endpoint que mude o status para ARQUIVADA
      await http.post(Uri.parse('$baseUrl/notifications/$id/archive'));
    } catch (e) {
      print('Erro ao arquivar: $e');
    }
  }

  Future<void> _confirmReserva(dynamic notificationId, dynamic slotId, bool confirm) async {
    if (slotId == null) {
      print('[DEBUG_LOG] Erro: slotId está nulo na notificação');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID da reserva não encontrado.')),
      );
      return;
    }

    String? reason;
    if (!confirm) {
      // Solicita motivo da recusa
      reason = await _showReasonDialog();
      if (reason == null) return; // Cancelou o diálogo
    }

    try {
      print('[DEBUG_LOG] Enviando confirmação de reserva: slotId=$slotId, confirm=$confirm');
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'slotId': slotId.toString(),
          'confirm': confirm,
          'reason': reason,
        }),
      ).timeout(const Duration(seconds: 15));

      print('[DEBUG_LOG] Resposta servidor: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        // Se confirmou/recusou com sucesso, marca a notificação como ARQUIVADA (Personal)
        // Isso fará sumir os botões na próxima carga
        if (notificationId != null) {
          await _markAsArchived(notificationId.toString());
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(confirm ? 'Reserva confirmada!' : 'Reserva recusada.')),
        );
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no servidor: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('[DEBUG_LOG] Erro ao confirmar reserva: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  Future<String?> _showReasonDialog() async {
    String reason = "";
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo da Recusa'),
        content: TextField(
          onChanged: (v) => reason = v,
          decoration: const InputDecoration(hintText: 'Ex: Horário indisponível'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reason.trim().isEmpty ? "Não informado" : reason),
            child: const Text('RECUSAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Nenhuma notificação encontrada.'))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final bool isRead = notif['status'] == 'LIDA';
                      final DateTime date = DateTime.parse(notif['createdAt']);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: isRead ? 0 : 2,
                        color: isRead ? Colors.grey[50] : Colors.white,
                        child: ExpansionTile(
                          leading: ThemedIconCard(
                            icon: notif['type'] == 'RESERVA' ? Icons.event : Icons.notifications,
                            size: 40,
                            filled: false,
                          ),
                          title: Text(
                            notif['title'] ?? 'Notificação',
                            style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                          ),
                          subtitle: Text(DateFormat('dd/MM HH:mm').format(date)),
                          onExpansionChanged: (expanded) {
                            if (expanded && !isRead) {
                              // Se for do aluno (CONFIRMACAO/REJEICAO), marcamos lida ao expandir
                              if (notif['type'] == 'CONFIRMACAO' || notif['type'] == 'REJEICAO') {
                                _markAsRead(notif['id']);
                              }
                            }
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif['message'] ?? ''),
                                  if (notif['type'] == 'RESERVA') ...[
                                    const SizedBox(height: 16),
                                    Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        // Botão de Recusar (visível em todos os status de reserva não cancelados)
                                        if (notif['status'] != 'ARQUIVADA')
                                          SizedBox(
                                            height: 36,
                                            width: 110,
                                            child: ElevatedButton.icon(
                                              onPressed: () => _confirmReserva(notif['id'], notif['slotId'], false),
                                              icon: const Icon(Icons.cancel, size: 14),
                                              label: const Text('RECUSAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                          ),
                                        
                                        if (notif['status'] == 'PENDENTE' || notif['status'] == null)
                                          SizedBox(
                                            height: 36,
                                            width: 110,
                                            child: ElevatedButton.icon(
                                              onPressed: () => _confirmReserva(notif['id'], notif['slotId'], true),
                                              icon: const Icon(Icons.check_circle, size: 14),
                                              label: const Text('CONFIRMAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
