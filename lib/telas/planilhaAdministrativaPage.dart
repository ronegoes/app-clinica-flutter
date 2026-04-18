import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanilhaAdministrativaPage extends StatefulWidget {
  const PlanilhaAdministrativaPage({super.key});

  @override
  State<PlanilhaAdministrativaPage> createState() =>
      _PlanilhaAdministrativaPageState();
}

class _PlanilhaAdministrativaPageState
    extends State<PlanilhaAdministrativaPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> linhas = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  // 🔥 CARREGA DADOS AO ABRIR A TELA
  Future<void> carregarDados() async {
    final doc = await db.collection('planilha_temp').doc('rascunho').get();

    if (doc.exists) {
      setState(() {
        linhas = List<Map<String, dynamic>>.from(doc.data()?['linhas'] ?? []);
      });
    }
  }

  // 🔥 SALVA AUTOMATICAMENTE
  Future<void> salvarParcial() async {
    await db.collection('planilha_temp').doc('rascunho').set({
      'linhas': linhas,
      'totalReceita': totalReceita,
      'totalCusto': totalCusto,
      'lucroTotal': lucroTotal,
      'data': DateTime.now(),
    });
  }

  void adicionarLinha() {
    setState(() {
      linhas.add({'procedimento': '', 'qtd': 1, 'valor': 0.0, 'custo': 0.0});
    });

    salvarParcial();
  }

  double get totalReceita {
    double total = 0;
    for (var l in linhas) {
      total += (l['valor'] * l['qtd']);
    }
    return total;
  }

  double get totalCusto {
    double total = 0;
    for (var l in linhas) {
      total += (l['custo'] * l['qtd']);
    }
    return total;
  }

  double get lucroTotal => totalReceita - totalCusto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planilha Administrativa"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: adicionarLinha),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: linhas.length,
              itemBuilder: (context, index) {
                final item = linhas[index];

                double total = (item['valor'] * item['qtd']);
                double lucro = (item['valor'] - item['custo']) * item['qtd'];

                return Card(
                  margin: const EdgeInsets.all(6),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // PROCEDIMENTO
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                              text: item['procedimento'],
                            ),
                            decoration: const InputDecoration(
                              labelText: "Procedimento",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              item['procedimento'] = v;
                              salvarParcial();
                            },
                          ),
                        ),

                        const SizedBox(width: 6),

                        // QTD
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Qtd",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              setState(() {
                                item['qtd'] = int.tryParse(v) ?? 1;
                              });
                              salvarParcial();
                            },
                          ),
                        ),

                        const SizedBox(width: 6),

                        // VALOR
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Valor",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              setState(() {
                                item['valor'] = double.tryParse(v) ?? 0.0;
                              });
                              salvarParcial();
                            },
                          ),
                        ),

                        const SizedBox(width: 6),

                        // CUSTO
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Custo",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              setState(() {
                                item['custo'] = double.tryParse(v) ?? 0.0;
                              });
                              salvarParcial();
                            },
                          ),
                        ),

                        const SizedBox(width: 6),

                        // TOTAL
                        Expanded(child: Text(total.toStringAsFixed(2))),

                        const SizedBox(width: 6),

                        // LUCRO
                        Expanded(
                          child: Text(
                            lucro.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              linhas.removeAt(index);
                            });
                            salvarParcial();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // RESUMO
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Receita: R\$ ${totalReceita.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Custo: R\$ ${totalCusto.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Lucro: R\$ ${lucroTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
