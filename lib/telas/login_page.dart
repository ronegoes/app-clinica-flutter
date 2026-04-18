import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> login() async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final uid = cred.user!.uid;

      print("UID LOGADO: $uid"); // 🔥 DEBUG

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      print("DOC EXISTS: ${userDoc.exists}"); // 🔥 DEBUG

      if (!userDoc.exists) {
        throw Exception("Usuário NÃO cadastrado no Firestore");
      }

      final tipo = userDoc.data()?['tipo'] ?? 'recepcao';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPage(usuarioId: uid, tipo: tipo),
        ),
      );
    } catch (e) {
      print("ERRO LOGIN COMPLETO: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Entrar")),
          ],
        ),
      ),
    );
  }
}
