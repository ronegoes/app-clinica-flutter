import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'dashboardFinanceiro_page.dart';
import 'medicos_page.dart';
import 'agendamento_page.dart';
import 'clientes_page.dart';
import 'pagamentos_page.dart';
import 'procedimentos_page.dart';
import 'HistoricoPage.dart';
import 'planilhaAdministrativaPage.dart';
import 'cadastro_usuario_page.dart';

class MenuPage extends StatefulWidget {
  final String usuarioId;
  final String tipo;

  const MenuPage({super.key, required this.usuarioId, required this.tipo});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      DashboardPage(),
      MedicosPage(),
      AgendamentosPage(usuarioId: widget.usuarioId, tipo: widget.tipo),
      ClientesPage(),
      PagamentosPage(),
      ProcedimentosPage(),
      HistoricoPage(),
      CadastroUsuarioPage(),
      PlanilhaAdministrativaPage(),
      DashboardFinanceiroPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // 🔥 BOTÃO DE CADASTRO (só recepção vê)
      floatingActionButton: (widget.tipo == 'recepcao' && _selectedIndex == 0)
          ? FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroUsuarioPage()),
                );
              },
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Médicos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pagamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing),
            label: 'Procedimentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
