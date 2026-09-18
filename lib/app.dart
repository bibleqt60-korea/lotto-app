import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/my_numbers_screen.dart';
import 'screens/number_generator_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/store_screen.dart';
import 'widgets/ad_banner.dart';

class LottoApp extends StatelessWidget {
  const LottoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '로또 6/45',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor:
            const Color(0xFFF7F7F9),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey<MyNumbersScreenState>
      _myNumbersKey =
      GlobalKey<MyNumbersScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const NumberGeneratorScreen(),
    const StoreScreen(),
    MyNumbersScreen(
      key: _myNumbersKey,
    ),
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 4) {
      _myNumbersKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                ),
                selectedIcon: Icon(
                  Icons.home,
                ),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.bar_chart_outlined,
                ),
                selectedIcon: Icon(
                  Icons.bar_chart,
                ),
                label: '통계',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.auto_awesome_outlined,
                ),
                selectedIcon: Icon(
                  Icons.auto_awesome,
                ),
                label: '번호생성',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.store_outlined,
                ),
                selectedIcon: Icon(
                  Icons.store,
                ),
                label: '판매점',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.bookmark_border,
                ),
                selectedIcon: Icon(
                  Icons.bookmark,
                ),
                label: '내 번호',
              ),
            ],
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}