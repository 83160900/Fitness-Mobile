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
  String? _coachEmail; // Personal vinculado ao aluno

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _userEmail = args['email'];
      _userRole = args['role'] ?? 'ALUNO'; 
      _userName = args['name'] ?? 'Usuário';
      if (_userEmail != null && _userEmail!.isNotEmpty) {
        if (_userRole == 'ALUNO') {
          _loadCoachEmail().then((_) => _loadSlots());
        } else {
          _loadSlots();
        }
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      // Evita tela branca se não houver argumentos
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSlots() async {
    if (_userEmail == null || _userEmail!.isEmpty) return;
    setState(() => _isLoading = true);
    
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
    final end = start.add(const Duration(days: 1));

    // Se for aluno, carrega a agenda do Personal vinculado
    final String targetPersonal = _userRole == 'PERSONAL' ? _userEmail! : (_coachEmail ?? '');

    if (targetPersonal.isEmpty) {
      setState(() => _isLoading = false);
      if (_userRole == 'ALUNO') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum Personal vinculado encontrado. Solicite um convite.'))
        );
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse(
        '$baseUrl/schedule/personal/$targetPersonal?start=${start.toIso8601String()}&end=${end.toIso8601String()}'
      )).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _slots = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Erro ao carregar agenda: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível carregar a agenda. Tente novamente.'))
        );
      }
    }
  }

  Future<void> _doReserve(DateTime time) async {
    setState(() => _isLoading = true);
    try {
      final String personalEmailToUse = _userRole == 'PERSONAL' ? (_userEmail ?? '') : (_coachEmail ?? '');
      if (personalEmailToUse.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum Personal vinculado.')));
        return;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/reserve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'personalEmail': personalEmailToUse,
          'studentEmail': _userEmail,
          'startTime': time.toIso8601String(),
          'recurrence': 'NENHUMA',
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horário reservado!')));
        _loadSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao reservar: ${response.statusCode}')));
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
    final Map<String, String> dayNamesPt = {
      'Monday': 'Segunda-feira',
      'Tuesday': 'Terça-feira',
      'Wednesday': 'Quarta-feira',
      'Thursday': 'Quinta-feira',
      'Friday': 'Sexta-feira',
      'Saturday': 'Sábado',
      'Sunday': 'Domingo',
    };
    String dayNameEn = DateFormat('EEEE').format(_selectedDate);
    String dayName = dayNamesPt[dayNameEn] ?? dayNameEn;
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

  Future<void> _loadCoachEmail() async {
    if (_userRole != 'ALUNO' || _userEmail == null || _userEmail!.isEmpty) return;
    try {
      final resp = await http.get(Uri.parse('$baseUrl/student/${_userEmail}/professionals')).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final List pros = jsonDecode(resp.body);
        if (pros.isNotEmpty) {
          setState(() { _coachEmail = pros.first['email']; });
        }
      }
    } catch (e) {
      // Silencia erros, fallback trata ausência de coach
    }
  }

  Widget _buildStudentList() {
    // Lista do Aluno: horários disponíveis + suas aulas do dia + histórico do dia
    final List<DateTime> availableTimes = [];
    final List<dynamic> mySlotsToday = [];
    final List<dynamic> historyToday = [];

    for (int h = 6; h <= 22; h++) {
      final time = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, 0);

      // Verifica se o horário está ocupado (reservado/confirmado) — CANCELADO volta a ficar livre
      final slot = _slots.firstWhere((s) {
        try {
          final startTime = DateTime.parse(s['startTime']);
          return startTime.year == _selectedDate.year && startTime.month == _selectedDate.month && startTime.day == _selectedDate.day && startTime.hour == h && s['status'] != 'CANCELADO';
        } catch (e) {
          return false;
        }
      }, orElse: () => null);

      // Aluno só vê horários que NÃO estão ocupados
      if (slot == null) {
        availableTimes.add(time);
      }
    }

    // Minhas aulas do dia (RESERVADO/CONFIRMADO) e histórico (CANCELADO)
    for (final s in _slots) {
      try {
        final dt = DateTime.parse(s['startTime']);
        if (dt.year == _selectedDate.year && dt.month == _selectedDate.month && dt.day == _selectedDate.day && s['studentEmail'] == _userEmail) {
          final status = s['status'];
          if (status == 'RESERVADO' || status == 'CONFIRMADO') {
            mySlotsToday.add(s);
          } else if (status == 'CANCELADO') {
            historyToday.add(s);
          }
        }
      } catch (_) {}
    }

    // Constrói a lista com seções
    final List<Widget> children = [];

    // Seção: Horários marcados
    if (mySlotsToday.isNotEmpty) {
      children.add(
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 4),
          child: Text('Horários marcados', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      );
      for (final s in mySlotsToday) {
        final dt = DateTime.parse(s['startTime']);
        final status = s['status'];
        Color badgeColor = Colors.amber;
        String label = 'Aguardando aprovação';
        if (status == 'CONFIRMADO') { badgeColor = Colors.green; label = 'Confirmada'; }
        if (status == 'RESERVADO') { badgeColor = Colors.yellow[700]!; label = 'Aguardando aprovação'; }

        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 0,
              color: badgeColor.withOpacity(0.08),
              margin: const EdgeInsets.only(bottom: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: CircleAvatar(radius: 14, backgroundColor: badgeColor, child: const Icon(Icons.fitness_center, color: Colors.white, size: 14)),
                title: Text('${DateFormat('HH:mm').format(dt)} Aula', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ),
            ),
          ),
        );
      }
      children.add(const SizedBox(height: 4));
      children.add(const Divider());
    }

    // Seção: Horários disponíveis
    if (availableTimes.isNotEmpty) {
      children.add(
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
          child: Text('Horários disponíveis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      );
      for (final time in availableTimes) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 0,
              color: Colors.teal.withOpacity(0.05),
              margin: const EdgeInsets.only(bottom: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.check_box_outline_blank, color: Colors.teal, size: 20),
                title: Text(
                  '${DateFormat('HH:mm').format(time)} Horário',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.add_circle_outline, color: Colors.teal, size: 20),
                onTap: () => _confirmReservation(time),
              ),
            ),
          ),
        );
      }
    } else {
      children.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Nenhum horário livre para este dia.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    // Seção: Histórico do dia (Canceladas/Rejeitadas)
    if (historyToday.isNotEmpty) {
      children.add(const SizedBox(height: 8));
      children.add(const Divider());
      children.add(
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
          child: Text('Histórico (dia selecionado)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      );
      for (final s in historyToday) {
        final dt = DateTime.parse(s['startTime']);
        final byMe = s['studentEmail'] == _userEmail; // ainda é minha, mas verifica quem cancelou via mensagem
        final reason = (s['rejectionReason'] ?? '').toString();
        final subtitle = reason.isNotEmpty ? 'Rejeitada pelo personal' : (byMe ? 'Cancelada por você' : 'Cancelada');
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 0,
              color: Colors.red.withOpacity(0.04),
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: Text(
                  '${DateFormat('HH:mm').format(dt)} $subtitle',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
                ),
                subtitle: reason.isNotEmpty ? Text('Motivo: $reason') : null,
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      children: children,
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
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 17, // 06:00 as 22:00
      itemBuilder: (context, index) {
        int hour = 6 + index;
        final slot = _slots.firstWhere((s) {
          try {
            return DateTime.parse(s['startTime']).hour == hour && s['status'] != 'CANCELADO';
          } catch (e) {
            return false;
          }
        }, orElse: () => null);
        
        String status = slot != null ? slot['status'] : 'LIVRE';
        Color color = Colors.grey[100]!;
        Color textColor = Colors.black54;

        if (status == 'RESERVADO') { color = Colors.yellow[600]!; textColor = Colors.black; }
        else if (status == 'CONFIRMADO') { color = Colors.green[600]!; textColor = Colors.white; }

        return InkWell(
          onTap: (slot != null && (status == 'RESERVADO' || status == 'CONFIRMADO'))
            ? () => _showPersonalActions(slot)
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Apenas alunos podem marcar novos horários.'))
                );
              },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: status == 'LIVRE' ? Border.all(color: Colors.grey[300]!) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${hour.toString().padLeft(2, '0')}:00', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                if (slot != null && slot['studentEmail'] != null)
                  Text(slot['studentEmail'].split('@')[0], style: TextStyle(fontSize: 10, color: textColor), overflow: TextOverflow.ellipsis),
                if (status == 'RESERVADO')
                  Text('AGUARDANDO', style: TextStyle(fontSize: 9, color: textColor.withOpacity(0.9))),
                if (status == 'CONFIRMADO')
                  Text('CONFIRMADO', style: TextStyle(fontSize: 9, color: textColor.withOpacity(0.9))),
                if (status == 'LIVRE')
                  const Text('LIVRE', style: TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPersonalActions(dynamic slot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gestão da Aula', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text('Aluno: ${slot['studentEmail']}', style: const TextStyle(fontSize: 16)),
            Text('Horário: ${DateFormat('HH:mm').format(DateTime.parse(slot['startTime']))}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.cancel, color: Colors.red),
              ),
              title: const Text('Cancelar Aula', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Respeitando a regra de 24h'),
              onTap: () {
                Navigator.pop(context);
                _cancelSlot(slot['id']);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.swap_horiz, color: Colors.blue),
              ),
              title: const Text('Trocar Data/Horário', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              subtitle: const Text('Mover reserva para outro dia'),
              onTap: () {
                Navigator.pop(context);
                _showMoveSelection(slot);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelSlot(String slotId) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'slotId': slotId}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horário cancelado!')));
        _loadSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao cancelar.')));
    }
    setState(() => _isLoading = false);
  }

  void _showMoveSelection(dynamic slot) {
    DateTime selectedMoveDate = _selectedDay;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const Text('Selecione Novo Dia e Horário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CalendarDatePicker(
                initialDate: selectedMoveDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                onDateChanged: (date) {
                  setModalState(() => selectedMoveDate = date);
                },
              ),
              const Divider(),
              const Text('Horários Disponíveis (Geral)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(15, (index) {
                    int h = 7 + index;
                    String timeLabel = '${h.toString().padLeft(2, '0')}:00';
                    return ElevatedButton(
                      onPressed: () {
                        DateTime newTime = DateTime(selectedMoveDate.year, selectedMoveDate.month, selectedMoveDate.day, h);
                        Navigator.pop(context);
                        _doMoveSlot(slot['id'], newTime);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50], foregroundColor: Colors.blue),
                      child: Text(timeLabel),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doMoveSlot(String slotId, DateTime newTime) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule/move'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'slotId': slotId,
          'startTime': newTime.toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula movida com sucesso!')));
        _loadSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao mover aula.')));
    }
    setState(() => _isLoading = false);
  }
}
