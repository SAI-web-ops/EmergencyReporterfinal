import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'incident_report_screen.dart';
import 'emergency_contacts_screen.dart';
import 'panic_button_screen.dart';
import 'citizen_points_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const IncidentReportScreen(),
    const EmergencyContactsScreen(),
    const PanicButtonScreen(),
    const CitizenPointsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely present the modal after the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndShowLogin();
    });
  }

  void _checkAuthAndShowLogin() {
    final appState = context.read<AppStateProvider>();
    if (appState.accessToken == null) {
      // Present LoginScreen as a modal that cannot be dismissed.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Panic'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Points'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
