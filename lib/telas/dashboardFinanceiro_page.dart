import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardFinanceiroPage extends StatefulWidget {
  const DashboardFinanceiroPage({super.key});

  @override
  State<DashboardFinanceiroPage> createState() =>
      _DashboardFinanceiroPageState();
}

class _DashboardFinanceiroPageState
    extends State<DashboardFinanceiroPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> dados = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final snapshot = await db.collection('planilha_adm').get();

    List<Map<String, dynamic>> temp = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      temp.add({
        'lucro': data['lucroTotal'] ?? 0,
        'data': data['data'],
      });
    }

    setState(() {
      dados = temp;
    });
  }

  double get totalLucro {
    double total = 0;
    for (var d in dados) {
      total += (d['lucro'] ?? 0);
    }
    return total;
  }

  double get totalReceita => dados.length * 1000; // opcional mock
  double get totalCusto => dados.length * 500; // opcional mock

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Financeiro"),
        backgroundColor: Colors.orange,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔥 CARDS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _card("Lucro Total", totalLucro, Colors.green),
                _card("Registros", dados.length.toDouble(), Colors.blue),
              ],
            ),

            const SizedBox(height: 20),

            // 📊 GRÁFICO
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _maxLucro(),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(" ${value.toInt()}");
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBars(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 BARRAS DO GRÁFICO
  List<BarChartGroupData> _buildBars() {
    return List.generate(dados.length, (i) {
      final lucro = (dados[i]['lucro'] ?? 0).toDouble();

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: lucro,
            color: Colors.green,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  double _maxLucro() {
    if (dados.isEmpty) return 100;
    return dados
        .map((e) => (e['lucro'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  // 🧩 CARD UI
  Widget _card(String title, double value, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}