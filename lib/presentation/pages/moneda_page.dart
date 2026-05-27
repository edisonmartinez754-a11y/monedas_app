import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/moneda_model.dart';
import '../../data/services/moneda_service.dart';
import '../../data/services/usuario_service.dart';

class MonedaPage extends StatefulWidget {
  const MonedaPage({super.key});

  @override
  State<MonedaPage> createState() => _MonedaPageState();
}

class _MonedaPageState extends State<MonedaPage> {
  final _monedaService = MonedaService();
  final _usuarioService = UsuarioService();

  List<Moneda> _monedas = [];
  Moneda? _selectedMoneda;
  List<CambioMoneda> _changes = [];

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool _isLoadingMonedas = true;
  bool _isLoadingChanges = false;

  final _dateFormatter = DateFormat('yyyy-MM-dd');
  final _displayDateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadMonedas();
  }

  Future<void> _loadMonedas() async {
    setState(() => _isLoadingMonedas = true);
    try {
      final list = await _monedaService.listAll();
      if (!mounted) return;
      setState(() {
        _monedas = list;
        if (_monedas.isNotEmpty) {
          if (_selectedMoneda != null) {
            final match = _monedas.where((m) => m.id == _selectedMoneda!.id);
            if (match.isNotEmpty) {
              _selectedMoneda = match.first;
            } else {
              _selectedMoneda = _monedas.first;
            }
          } else {
            _selectedMoneda = _monedas.first;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message.toLowerCase().contains('sesión')) {
        await _handleLogout();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingMonedas = false);
      }
    }
  }

  Future<void> _fetchChanges() async {
    if (_selectedMoneda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione una moneda")),
      );
      return;
    }
    setState(() => _isLoadingChanges = true);
    try {
      final list = await _monedaService.listByPeriod(
        _selectedMoneda!.id,
        _dateFormatter.format(_startDate),
        _dateFormatter.format(_endDate),
      );
      if (!mounted) return;
      setState(() {
        _changes = list;
      });
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sin registros para ese período")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message.toLowerCase().contains('sesión')) {
        await _handleLogout();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingChanges = false);
      }
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStartDate) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
        if (_startDate.isAfter(_endDate)) _startDate = _endDate;
      }
    });
  }

  Future<void> _handleLogout() async {
    await _usuarioService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mercado de Divisas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Cerrar sesión",
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _buildFilters(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                "Histórico de Cambios",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          _buildResultsSliver(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isLoadingMonedas
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ))
                : DropdownButtonFormField<Moneda>(
                    value: _selectedMoneda,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Moneda de interés",
                      prefixIcon: Icon(Icons.currency_bitcoin_rounded),
                    ),
                    items: _monedas
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.moneda),
                            ))
                        .toList(),
                    onChanged: (m) => setState(() => _selectedMoneda = m),
                  ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDateField("Desde", _startDate, true)),
                const SizedBox(width: 12),
                Expanded(child: _buildDateField("Hasta", _endDate, false)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoadingChanges ? null : _fetchChanges,
              icon: _isLoadingChanges 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.analytics_rounded),
              label: Text(_isLoadingChanges ? "Consultando..." : "Analizar Mercado"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, bool isStartDate) {
    return InkWell(
      onTap: () => _selectDate(isStartDate),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          _displayDateFormatter.format(date),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildResultsSliver() {
    if (_isLoadingChanges) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_changes.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.query_stats_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                "Sin datos para este periodo",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                "Intenta con otro rango de fechas",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final change = _changes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded, 
                        color: Theme.of(context).colorScheme.primary, 
                        size: 22
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            change.fecha,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Tasa registrada",
                            style: TextStyle(
                              color: Colors.grey.shade500, 
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          change.valor.toStringAsFixed(4),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Text(
                          "VALOR",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: _changes.length,
        ),
      ),
    );
  }
}
