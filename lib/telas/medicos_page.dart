import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_medico_page.dart';

class MedicosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Médicos")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicos').snapshots(),
        builder: (context, snapshot) {

          // 🔴 MOSTRA ERRO REAL
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          // ⏳ CARREGANDO
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          // 📭 LISTA VAZIA
          if (docs.isEmpty) {
            return Center(child: Text("Nenhum médico cadastrado"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              // 🔥 PROTEÇÃO
              var data = docs[index].data() as Map<String, dynamic>? ?? {};

              var nome = data['nome'] ?? 'Sem nome';
              var especialidade = data['especialidade'] ?? 'Sem especialidade';

              return Card(
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(especialidade),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FormMedicoPage()),
          );
        },
      ),
    );
  }
}