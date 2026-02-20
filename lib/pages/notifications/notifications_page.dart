import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  Future<void> _confirmReserva(String slotId, bool confirm) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'slotId': slotId,
          'confirm': confirm,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(confirm ? 'Reserva confirmada!' : 'Reserva recusada.')),
        );
        _loadNotifications();
      }
    } catch (e) {
      print('Erro ao confirmar reserva: $e');
    }
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
                          leading: Icon(
                            notif['type'] == 'RESERVA' ? Icons.event : Icons.notifications,
                            color: isRead ? Colors.grey : Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            notif['title'] ?? 'Notificação',
                            style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                          ),
                          subtitle: Text(DateFormat('dd/MM HH:mm').format(date)),
                          onExpansionChanged: (expanded) {
                            if (expanded && !isRead) {
                              _markAsRead(notif['id']);
                            }
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif['message'] ?? ''),
                                  if (notif['type'] == 'RESERVA' && (notif['status'] == null || notif['status'] == 'PENDENTE')) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => _confirmReserva(notif['slotId'], false),
                                          child: const Text('Recusar', style: TextStyle(color: Colors.red)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => _confirmReserva(notif['slotId'], true),
                                          child: const Text('Confirmar'),
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
