import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> salvarHistorico({
  required String tipo,
  required String descricao,
  String? clienteId,
}) async {
  await FirebaseFirestore.instance.collection('historico').add({
    'tipo': tipo,
    'descricao': descricao,
    'clienteId': clienteId,
    'data': FieldValue.serverTimestamp(),
  });
}