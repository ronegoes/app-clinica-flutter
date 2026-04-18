import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'atestado_page.dart';
import 'form_agendamento_page.dart';

class AgendamentosPage extends StatelessWidget {
  final String usuarioId;
  final String tipo;

  const AgendamentosPage({
    super.key,
    required this.usuarioId,
    required this.tipo,
  });

  Color corStatus(String status) {
    switch (status) {
      case 'Confirmado':
        return Colors.green;
      case 'Cancelado':
        return Colors.red;
      case 'Finalizado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color corFundo(String status) {
    switch (status) {
      case 'Confirmado':
        return Colors.green.shade50;
      case 'Cancelado':
        return Colors.red.shade50;
      case 'Finalizado':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Future<void> adicionarProcedimento(
    BuildContext context,
    String agendamentoId,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('procedimentos')
        .get();

    final lista = snapshot.docs;
    List<String> selecionados = [];

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Adicionar Procedimentos"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: lista.map((doc) {
                    final data = doc.data();

                    return CheckboxListTile(
                      title: Text(data['nome']),
                      subtitle: Text("R\$ ${data['valor']}"),
                      value: selecionados.contains(doc.id),
                      onChanged: (value) {
                        setStateDialog(() {
                          if (value == true) {
                            selecionados.add(doc.id);
                          } else {
                            selecionados.remove(doc.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final novos = lista
                        .where((doc) => selecionados.contains(doc.id))
                        .map((doc) {
                          final d = doc.data();
                          return {
                            'nome': d['nome'],
                            'valor':
                                double.tryParse(d['valor'].toString()) ?? 0,
                          };
                        })
                        .toList();

                    final ref = FirebaseFirestore.instance
                        .collection('agendamentos')
                        .doc(agendamentoId);

                    final doc = await ref.get();
                    final data = doc.data() ?? {};

                    List atuais = List.from(data['procedimentos'] ?? []);

                    atuais.addAll(novos);

                    double total = 0;

                    for (var p in atuais) {
                      final v = p['valor'];

                      if (v is int) {
                        total += v.toDouble();
                      } else if (v is double) {
                        total += v;
                      } else if (v is String) {
                        total += double.tryParse(v) ?? 0;
                      }
                    }

                    await ref.update({'procedimentos': atuais, 'valor': total});

                    Navigator.pop(context);
                  },
                  child: const Text("Adicionar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agendamentos")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormAgendamentoPage()),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: tipo == 'recepcao'
            ? FirebaseFirestore.instance
                  .collection('agendamentos')
                  .orderBy('dataHora', descending: true)
                  .snapshots()
            : FirebaseFirestore.instance
                  .collection('agendamentos')
                  .where('medicoId', isEqualTo: usuarioId)
                  .orderBy('dataHora', descending: true)
                  .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final agendamentos = snapshot.data!.docs;

          // ativos primeiro
          final ativos = agendamentos.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] != 'Finalizado';
          }).toList();

          final finalizados = agendamentos.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'Finalizado';
          }).toList();

          final listaOrdenada = [...ativos, ...finalizados];

          return ListView.builder(
            itemCount: listaOrdenada.length,
            itemBuilder: (context, index) {
              final ag = listaOrdenada[index];
              final dataAg = ag.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('clientes')
                    .doc(dataAg['clienteId'])
                    .get(),
                builder: (context, snapshotCliente) {
                  if (!snapshotCliente.hasData) {
                    return const ListTile(title: Text("Carregando..."));
                  }

                  final cliente =
                      snapshotCliente.data!.data() as Map<String, dynamic>;

                  final nome = cliente['nome'] ?? '';
                  final status = dataAg['status'] ?? 'Pendente';

                  final lista = dataAg['procedimentos'] ?? [];

                  double valor = 0;
                  for (var p in lista) {
                    valor += (p['valor'] ?? 0);
                  }

                  DateTime? dataHora;
                  final raw = dataAg['dataHora'];
                  if (raw is Timestamp) {
                    dataHora = raw.toDate();
                  }

                  final dataFormatada = dataHora != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(dataHora)
                      : '';

                  return Card(
                    color: corFundo(status),
                    child: ListTile(
                      title: Text(nome),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...lista.map<Widget>((p) {
                            return Text("• ${p['nome']} - R\$ ${p['valor']}");
                          }),

                          Text(
                            "Total: R\$ ${valor.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Text("Data: $dataFormatada"),
                          Text(
                            "Status: $status",
                            style: TextStyle(color: corStatus(status)),
                          ),
                        ],
                      ),

                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          final ref = FirebaseFirestore.instance
                              .collection('agendamentos')
                              .doc(ag.id);

                          if (value == 'confirmar') {
                            await ref.update({'status': 'Confirmado'});
                          }

                          if (value == 'add_procedimento') {
                            await adicionarProcedimento(context, ag.id);
                          }

                          if (value == 'finalizar') {
                            final docAtualizado = await ref.get();
                            final dataAtual = docAtualizado.data() ?? {};

                            final lista = dataAtual['procedimentos'] ?? [];

                            double total = 0;
                            for (var p in lista) {
                              total += (p['valor'] ?? 0);
                            }

                            await ref.update({'status': 'Finalizado'});

                            final pagamentosRef = FirebaseFirestore.instance
                                .collection('pagamentos');

                            final existing = await pagamentosRef
                                .where('agendamentoId', isEqualTo: ag.id)
                                .get();

                            if (existing.docs.isEmpty) {
                              await pagamentosRef.add({
                                'agendamentoId': ag.id,
                                'clienteId': dataAg['clienteId'],
                                'clienteNome': nome,
                                'procedimentos': lista,
                                'valor': total,
                                'status': 'Pendente',
                              });
                            }
                          }

                          if (value == 'cancelar') {
                            await ref.update({'status': 'Cancelado'});
                          }

                          if (value == 'atestado') {
                            await gerarAtestadoModelo(
                              nome: nome,
                              rg: cliente['rg'] ?? '',
                              endereco: cliente['endereco'] ?? '',
                              data: dataFormatada,
                              horaInicio: '',
                              horaFim: '',
                              cidade: 'Cuiabá',
                              cid: dataAg['cid'] ?? '',
                              convalescenca: dataAg['convalescenca'] ?? '',
                              medico: dataAg['medico'] ?? '',
                            );
                          }
                        },

                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'confirmar',
                            child: Text('Confirmar'),
                          ),
                          PopupMenuItem(
                            value: 'add_procedimento',
                            child: Text('Adicionar Procedimento'),
                          ),
                          PopupMenuItem(
                            value: 'finalizar',
                            child: Text('Finalizar'),
                          ),
                          PopupMenuItem(
                            value: 'cancelar',
                            child: Text('Cancelar'),
                          ),
                          PopupMenuItem(
                            value: 'atestado',
                            child: Text('Gerar Atestado'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
