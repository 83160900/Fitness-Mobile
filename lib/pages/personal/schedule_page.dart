import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final String baseUrl = 'https://fitness-backtend-production.up.railway.app/api';
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _slots = [];
  bool _isLoading = false;
  String? _userRole;
  String? _userEmail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _userEmail = args?['email'];
    // Em um app real buscaríamos a role do estado global ou storage
    // Por enquanto vamos assumir a partir dos argumentos ou default
    _userRole = args?['role'] ?? 'PERSONAL'; 
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (_userEmail == null) return;
    setState(() => _isLoading = true);
    
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
    final end = start.add(const Duration(days: 1));

    try {
      final response = await http.get(Uri.parse(
        '$baseUrl/schedule/personal/$_userEmail?start=${start.toIso8601String()}&end=${end.toIso8601String()}'
      ));
      
      if (response.statusCode == 200) {
        setState(() {
          _slots = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar agenda: $e');
      setState(() => _isLoading = false);
    }
  }

  void _reserveSlot(DateTime time) async {
    // Diálogo de reserva
    String recurrence = 'NENHUMA';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reservar Horário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Horário: ${DateFormat('HH:mm').format(time)}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: recurrence,
              decoration: const InputDecoration(labelText: 'Recorrência'),
              items: ['NENHUMA', 'DIARIA', 'QUINZENAL', 'MENSAL'].map((r) => 
                DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => recurrence = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _doReserve(time, recurrence);
            },
            child: const Text('RESERVAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _doReserve(DateTime time, String recurrence) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/reserve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'personalEmail': _userEmail, // Em visão de aluno seria o email do personal dele
          'studentEmail': _userEmail, 
          'startTime': time.toIso8601String(),
          'recurrence': recurrence,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva realizada! Aguarde confirmação.')));
        _loadSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao reservar.')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Agenda')),
      body: Column(
        children: [
          _buildCalendarStrip(),
          const Divider(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildTimeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // 2 semanas
        itemBuilder: (context, index) {
          final day = DateTime.now().add(Duration(days: index));
          final isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = day);
              _loadSlots();
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.teal : Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(day), style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
                  Text(day.day.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeList() {
    // Gerar horários de 06:00 as 22:00
    final List<DateTime> times = [];
    for (int h = 6; h <= 22; h++) {
      times.add(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, 0));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: times.length,
      itemBuilder: (context, index) {
        final time = times[index];
        final slot = _slots.firstWhere((s) => DateTime.parse(s['startTime']).hour == time.hour, orElse: () => null);
        
        return _buildTimeCard(time, slot);
      },
    );
  }

  Widget _buildTimeCard(DateTime time, dynamic slot) {
    String status = slot != null ? slot['status'] : 'LIVRE';
    Color color = Colors.grey[200]!;
    String label = 'Disponível';

    if (status == 'RESERVADO') {
      color = Colors.yellow[100]!;
      label = 'Reservado';
    } else if (status == 'CONFIRMADO') {
      color = Colors.green[100]!;
      label = 'Confirmado';
    } else if (status == 'CANCELADO') {
      color = Colors.red[100]!;
      label = 'Cancelado';
    }

    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(DateFormat('HH:mm').format(time), style: const TextStyle(fontWeight: FontWeight.bold)),
        title: Text(label),
        subtitle: slot != null ? Text('Status: $status') : null,
        trailing: (status == 'LIVRE' || status == 'CANCELADO') 
          ? ElevatedButton(onPressed: () => _reserveSlot(time), child: const Text('MARCAR'))
          : null,
      ),
    );
  }
}
