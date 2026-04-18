import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('pagamentos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          double totalPago = 0;
          double totalPendente = 0;

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>? ?? {};

            // 🔥 CORREÇÃO AQUI
            double valor = double.tryParse(data['valor'].toString()) ?? 0.0;

            if (data['status'] == 'Pago') {
              totalPago += valor;
            } else {
              totalPendente += valor;
            }
          }

          return Column(
            children: [
              SizedBox(height: 20),

              _card("💰 Total Recebido", totalPago, Colors.green),
              _card("🟠 Pendente", totalPendente, Colors.orange),

              SizedBox(height: 20),

              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('agendamentos')
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    int totalAgendamentos = snap.data!.docs.length;

                    return _cardGrande(
                      "📅 Agendamentos",
                      totalAgendamentos.toDouble(),
                      Colors.blue,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String titulo, double valor, Color cor) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(titulo),
        trailing: Text(
          "R\$ ${valor.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 18,
            color: cor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _cardGrande(String titulo, double valor, Color cor) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Container(
        height: 250,
        child: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset('assets/logo1.png', width: 400),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 24,
                      color: cor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    valor.toInt().toString(),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
