import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('historico')
            .orderBy('data', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Sem histórico"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;

              DateTime? data;
              if (d['data'] is Timestamp) {
                data = d['data'].toDate();
              }

              final dataFormatada = data != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(data)
                  : '';

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(d['descricao'] ?? ''),
                subtitle: Text("${d['tipo']} • $dataFormatada"),
              );
            },
          );
        },
      ),
    );
  }
}
