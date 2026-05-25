import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modelos/moneda.dart';
import '../servicios/monedaservicio.dart';
import '../servicios/usuarioservicio.dart';

class MonedaVista extends StatefulWidget {
  const MonedaVista({super.key});

  @override
  State<MonedaVista> createState() => _MonedaVistaState();
}

class _MonedaVistaState extends State<MonedaVista> {
  final servicioMoneda = MonedaServicio();
  final servicioUsuario = UsuarioServicio();

  List<Moneda> monedas = [];
  Moneda? monedaSeleccionada;
  List<CambioMoneda> cambios = [];

  DateTime fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime fechaFin = DateTime.now();

  bool cargandoMonedas = true;
  bool cargandoCambios = false;

  final fmt = DateFormat('yyyy-MM-dd');
  final fmtDisplay = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _cargarMonedas();
  }

  Future<void> _cargarMonedas() async {
    setState(() => cargandoMonedas = true);
    try {
      final lista = await servicioMoneda.listar();
      if (!mounted) return;
      setState(() {
        monedas = lista;
        if (monedas.isNotEmpty) {
          if (monedaSeleccionada != null) {
            final coincidencia = monedas.where((m) => m.id == monedaSeleccionada!.id);
            if (coincidencia.isNotEmpty) {
              monedaSeleccionada = coincidencia.first;
            } else {
              monedaSeleccionada = monedas.first;
            }
          } else {
            monedaSeleccionada = monedas.first;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().replaceFirst('Exception: ', '');
      if (mensaje.toLowerCase().contains('sesión')) {
        await _cerrarSesion();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } finally {
      if (mounted) {
        setState(() => cargandoMonedas = false);
      }
    }
  }

  Future<void> _consultar() async {
    if (monedaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione una moneda")),
      );
      return;
    }
    setState(() => cargandoCambios = true);
    try {
      final lista = await servicioMoneda.listarPorPeriodo(
        monedaSeleccionada!.id,
        fmt.format(fechaInicio),
        fmt.format(fechaFin),
      );
      if (!mounted) return;
      setState(() {
        cambios = lista;
      });
      if (lista.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sin registros para ese período")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().replaceFirst('Exception: ', '');
      if (mensaje.toLowerCase().contains('sesión')) {
        await _cerrarSesion();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } finally {
      if (mounted) {
        setState(() => cargandoCambios = false);
      }
    }
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: esInicio ? fechaInicio : fechaFin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (esInicio) {
        fechaInicio = picked;
        if (fechaFin.isBefore(fechaInicio)) fechaFin = fechaInicio;
      } else {
        fechaFin = picked;
        if (fechaInicio.isAfter(fechaFin)) fechaInicio = fechaFin;
      }
    });
  }

  Future<void> _cerrarSesion() async {
    await servicioUsuario.cerrarSesion();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulta de Cambios de Moneda"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFiltros(),
            const SizedBox(height: 16),
            const Text(
              "Resultados",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            Expanded(child: _buildResultados()),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Filtros de consulta",
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            cargandoMonedas
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Moneda>(
                    value: monedaSeleccionada,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Moneda",
                      prefixIcon: const Icon(Icons.monetization_on),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    hint: const Text("Seleccione una moneda"),
                    items: monedas
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                m.moneda,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (m) =>
                        setState(() => monedaSeleccionada = m),
                  ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildCampoFecha(
                        "Desde (YYYY-MM-DD)", fechaInicio, true)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _buildCampoFecha("Hasta (YYYY-MM-DD)", fechaFin, false)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: cargandoCambios ? null : _consultar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: cargandoCambios
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Consultar Cambios"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoFecha(String label, DateTime fecha, bool esInicio) {
    return InkWell(
      onTap: () => _seleccionarFecha(esInicio),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Text(fmt.format(fecha)),
      ),
    );
  }

  Widget _buildResultados() {
    if (cargandoCambios) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cambios.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "No hay datos para mostrar",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: cambios.length,
      itemBuilder: (context, index) {
        final cambio = cambios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Fecha: ${cambio.fecha}",
                  style: const TextStyle(color: Colors.pink, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Valor: ${cambio.valor.toStringAsFixed(8)}",
                  style: const TextStyle(color: Colors.pink, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
