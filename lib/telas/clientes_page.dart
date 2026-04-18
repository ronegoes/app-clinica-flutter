import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_cliente_page.dart';
import 'odontograma_page.dart'; // 🔥 IMPORTANTE

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clientes")),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('clientes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Nenhum cliente cadastrado"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(data['nome'] ?? 'Sem nome'),
                  subtitle: Text(data['telefone'] ?? ''),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // 🦷 ODONTOGRAMA
                      IconButton(
                        icon: const Icon(Icons.medical_services, color: Colors.green),
                        tooltip: "Odontograma",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OdontogramaPage(
                                clienteId: docs[index].id,
                              ),
                            ),
                          );
                        },
                      ),

                      // ✏️ EDITAR
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: "Editar",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormClientePage(
                                id: docs[index].id,
                                dados: data,
                              ),
                            ),
                          );
                        },
                      ),

                      // 🗑 EXCLUIR
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Excluir",
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('clientes')
                              .doc(docs[index].id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: "Novo Cliente",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FormClientePage()),
          );
        },
      ),
    );
  }
}