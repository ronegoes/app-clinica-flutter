import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'historico_service.dart';

class PagamentosPage extends StatefulWidget {
  const PagamentosPage({super.key});

  @override
  State<PagamentosPage> createState() => _PagamentosPageState();
}

class _PagamentosPageState extends State<PagamentosPage> {
  final CollectionReference pagamentos = FirebaseFirestore.instance.collection(
    'pagamentos',
  );

  final List<String> formas = [
    'PIX',
    'Cartão Crédito',
    'Cartão Débito',
    'Dinheiro',
    'Boleto',
  ];

  Map<String, String> cacheClientes = {};

  Future<String> getCliente(String? id) async {
    if (id == null) return 'Sem cliente';
    if (cacheClientes.containsKey(id)) return cacheClientes[id]!;

    final doc = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(id)
        .get();

    String nome = 'Cliente não encontrado';
    if (doc.exists && doc.data() != null) {
      nome = doc.data()!['nome'] ?? nome;
    }

    cacheClientes[id] = nome;
    return nome;
  }

  void editarPagamento(String id, Map<String, dynamic> data) {
    final valorController = TextEditingController(
      text: data['valor'].toString(),
    );

    String formaSelecionada = data['formaPagamento'] ?? 'PIX';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Pagamento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Valor"),
            ),
            DropdownButtonFormField<String>(
              value: formaSelecionada,
              items: formas
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => formaSelecionada = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await pagamentos.doc(id).update({
                'valor': double.tryParse(valorController.text) ?? 0,
                'formaPagamento': formaSelecionada,
              });
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future<void> gerarPdf(
    Map<String, dynamic> pagamento,
    String clienteNome,
  ) async {
    final pdf = pw.Document();

    final logo = await imageFromAssetBundle('assets/logo.png');

    final procedimentos = pagamento['procedimentos'] ?? [];

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Image(logo, width: 80)),

            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text(
                "CLÍNICA ODONTOLÓGICA",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.Center(
              child: pw.Text(
                "ADÉLIA PACHECO",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 30),

            pw.Center(
              child: pw.Text(
                "RECIBO DE PAGAMENTO",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 40),

            pw.Text("Cliente: $clienteNome"),

            pw.SizedBox(height: 15),

            // 🔥 PROCEDIMENTOS CORRIGIDO
            pw.Text(
              "Procedimentos:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            ...procedimentos.map<pw.Widget>((p) {
              return pw.Text("• ${p['nome']} - R\$ ${p['valor']}");
            }).toList(),

            pw.SizedBox(height: 15),

            pw.Text(
              "Total: R\$ ${pagamento['valor']}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            pw.Text("Status: ${pagamento['status']}"),

            pw.SizedBox(height: 10),

            pw.Text("Forma: ${pagamento['formaPagamento'] ?? 'Não informado'}"),

            pw.SizedBox(height: 50),
            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text(
                "Clínica Odontológica - Adélia Pacheco",
                style: pw.TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagamentos")),
      body: StreamBuilder<QuerySnapshot>(
        stream: pagamentos.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;

              double valor = double.tryParse(d['valor'].toString()) ?? 0.0;

              final status = d['status']?.toString().toLowerCase() ?? '';

              final isPago = status == 'pago';
              final isPendente = !isPago;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("💰 R\$ ${valor.toStringAsFixed(2)}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: getCliente(d['clienteId']),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Text("Carregando...");
                          }
                          return Text("Cliente: ${snap.data}");
                        },
                      ),
                      Text("Status: ${d['status'] ?? 'Pendente'}"),
                      Text("Forma: ${d['formaPagamento'] ?? '-'}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editarPagamento(id, d),
                      ),

                      isPendente
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                await pagamentos.doc(id).update({
                                  'status': 'Pago',
                                  'dataPagamento': FieldValue.serverTimestamp(),
                                });

                                await salvarHistorico(
                                  tipo: 'Pagamento',
                                  descricao:
                                      'Pagamento realizado - R\$ ${d['valor']}',
                                  clienteId: d['clienteId'],
                                );

                                final nomeCliente = await getCliente(
                                  d['clienteId'],
                                );

                                await gerarPdf({
                                  ...d,
                                  'status': 'Pago',
                                }, nomeCliente);
                              },
                              child: const Text("Pagar"),
                            )
                          : const Icon(Icons.check, color: Colors.green),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
