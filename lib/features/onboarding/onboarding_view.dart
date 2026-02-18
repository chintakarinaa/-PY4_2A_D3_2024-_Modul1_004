import 'package:flutter/material.dart';
import 'package:logbook_app_004/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/ungu1.png',
    'assets/images/ungu2.png',
    'assets/images/ungu3.png',
  ];

  final List<String> _titles = [
    "Kelola Aktivitas dengan Mudah",
    "Belajar Lebih Terstruktur",
    "Produktif Setiap Saat",
  ];

  final List<String> _descriptions = [
    "Catat dan pantau aktivitas harianmu langsung dari genggaman.",
    "Atur target dan lihat progres aktivitasmu dengan rapi.",
    "Pantau riwayat dan perkembanganmu kapan saja, di mana saja.",
  ];

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.deepPurple
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _images[_currentPage],
              height: 250,
            ),
            const SizedBox(height: 30),
            Text(
              _titles[_currentPage],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _descriptions[_currentPage],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            _buildIndicator(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _nextPage,
              child: Text(
                _currentPage == 2 ? "Masuk" : "Lanjut",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
