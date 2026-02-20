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
  String? _userName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _userEmail = args?['email'];
    _userRole = args?['role'] ?? 'ALUNO'; 
    _userName = args?['name'] ?? 'Aluno';
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (_userEmail == null) return;
    setState(() => _isLoading = true);
    
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
    final end = start.add(const Duration(days: 1));

    try {
      // Nota: Para o aluno, buscaríamos a agenda do Personal dele. 
      // Por simplicidade neste MVP, estamos usando o próprio e-mail para teste.
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

  Future<void> _doReserve(DateTime time) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/reserve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'personalEmail': _userEmail, 
          'studentEmail': _userEmail, 
          'startTime': time.toIso8601String(),
          'recurrence': 'NENHUMA',
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horário reservado!')));
        _loadSlots();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao reservar.')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    bool isPersonal = _userRole == 'PERSONAL';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isPersonal ? 'Gestão de Agenda' : 'Marcar Aula'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildDateSelector(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : isPersonal ? _buildPersonalGrid() : _buildStudentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(_userRole == 'PERSONAL' ? Icons.psychology : Icons.person, color: Colors.teal, size: 28),
          const SizedBox(width: 12),
          Text(
            _userRole == 'PERSONAL' ? 'Minha Disponibilidade' : '👤 $_userName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    String dayName = DateFormat('EEEE', 'pt_BR').format(_selectedDate);
    dayName = dayName[0].toUpperCase() + dayName.substring(1);
    final String dateStr = DateFormat('dd/MM').format(_selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
            _loadSlots();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.teal),
              const SizedBox(width: 10),
              Text('📅 $dayName $dateStr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    // Lista simplificada para o Aluno (☐ 06:00)
    final List<DateTime> availableTimes = [];
    for (int h = 6; h <= 22; h++) {
      final time = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, 0);
      final slot = _slots.firstWhere((s) => DateTime.parse(s['startTime']).hour == h, orElse: () => null);
      
      // Oculta se estiver ocupado (RESERVADO ou CONFIRMADO)
      if (slot == null || slot['status'] == 'CANCELADO') {
        availableTimes.add(time);
      }
    }

    if (availableTimes.isEmpty) {
      return const Center(child: Text('Nenhum horário disponível para este dia.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: availableTimes.length,
      itemBuilder: (context, index) {
        final time = availableTimes[index];
        return ListTile(
          leading: const Icon(Icons.check_box_outline_blank, color: Colors.grey),
          title: Text(DateFormat('HH:mm').format(time), style: const TextStyle(fontSize: 18)),
          onTap: () => _confirmReservation(time),
        );
      },
    );
  }

  void _confirmReservation(DateTime time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Text('Deseja marcar sua aula para às ${DateFormat('HH:mm').format(time)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NÃO')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _doReserve(time); }, child: const Text('SIM')),
        ],
      ),
    );
  }

  Widget _buildPersonalGrid() {
    // Visão Inteligente para o Personal: Grid compacto
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 17, // 06:00 as 22:00
      itemBuilder: (context, index) {
        int hour = 6 + index;
        final slot = _slots.firstWhere((s) => DateTime.parse(s['startTime']).hour == hour, orElse: () => null);
        
        String status = slot != null ? slot['status'] : 'LIVRE';
        Color color = Colors.grey[100]!;
        Color textColor = Colors.black54;

        if (status == 'RESERVADO') { color = Colors.yellow[400]!; textColor = Colors.black; }
        else if (status == 'CONFIRMADO') { color = Colors.green[400]!; textColor = Colors.white; }
        else if (status == 'CANCELADO') { color = Colors.red[400]!; textColor = Colors.white; }

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${hour.toString().padLeft(2, '0')}:00', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              if (slot != null && slot['studentEmail'] != null)
                Text(slot['studentEmail'].split('@')[0], style: TextStyle(fontSize: 10, color: textColor), overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }
}
