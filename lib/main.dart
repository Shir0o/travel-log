import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'screens/scrapbook_screen.dart';
import 'screens/typewriter_screen.dart';
import 'screens/evidence_screen.dart';
import 'screens/banger_screen.dart';
import 'widgets/brutal_widgets.dart';

void main() {
  runApp(const TravelLogApp());
}

class TravelLogApp extends StatelessWidget {
  const TravelLogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: BrutalTheme.backgroundLight,
        primaryColor: BrutalTheme.primary,
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTabIndex = 0; // 0: Scrapbook, 1: Studio, 2: Profile
  
  // Custom navigation state for nested/direct sub-screens
  // 'tabs', 'typewriter', 'evidence'
  String _currentDirectScreen = 'tabs';

  void _navigateToDirectScreen(String screenName) {
    setState(() {
      _currentDirectScreen = screenName;
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentDirectScreen = 'tabs';
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If we have an overlay screen (Typewriter or Evidence), render it directly
    if (_currentDirectScreen.toLowerCase() == 'typewriter') {
      return TypewriterScreen(
        onBack: () => _navigateToDirectScreen('tabs'),
        onProduceTrack: () => _navigateToTab(1), // Navigates to Studio tab
      );
    } else if (_currentDirectScreen.toLowerCase() == 'evidence') {
      return EvidenceScreen(
        onBack: () => _navigateToDirectScreen('tabs'),
      );
    }

    // Render Bottom Nav Shell
    return Scaffold(
      backgroundColor: BrutalTheme.backgroundLight,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          ScrapbookScreen(
            onNavigateToTab: _navigateToTab,
            onNavigateToDirectScreen: _navigateToDirectScreen,
          ),
          BangerScreen(
            onBack: () => _navigateToTab(0), // Back to Scrapbook tab
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: BrutalTheme.backgroundLight,
          border: Border(
            top: BorderSide(color: BrutalTheme.inkBlack, width: 4.0),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 12.0, top: 8.0, left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              index: 0,
              icon: Icons.book,
              label: 'Scrapbook',
            ),
            _buildBottomNavItem(
              index: 1,
              icon: Icons.play_circle,
              label: 'Studio',
            ),
            _buildBottomNavItem(
              index: 2,
              icon: Icons.person,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = _currentTabIndex == index;
    final Color itemColor = isActive ? BrutalTheme.inkBlack : BrutalTheme.graphite;
    
    return GestureDetector(
      onTap: () => _navigateToTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: itemColor,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: itemColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Profile screen just to complete the bottom nav options
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutalTheme.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66.0),
        child: Container(
          decoration: const BoxDecoration(
            color: BrutalTheme.backgroundLight,
            border: Border(
              bottom: BorderSide(color: BrutalTheme.inkBlack, width: 4.0),
            ),
          ),
          alignment: Alignment.center,
          child: SafeArea(
            child: Text(
              'MY PROFILE',
              style: GoogleFonts.spaceMono(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
                color: BrutalTheme.inkBlack,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BrutalCard(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: BrutalTheme.inkBlack, width: 3),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBq7EdCTPva73qwA0b7XoYyRoEyBXhGAw90E67gUzc0psJTDFanyVZs3kELGIGm_4vjezb5wLlMQMocryuJkkDRatqU5kQvwmCTg-whLJk3Q5Qh4BzcImyTZ4bxX-KAYh_xIBpNO8NYsdHnvkNDCoM5ECzF-GZk7AWbGz_pvX79MKljzYpXzfPiUi821FTgllT3Eq9eDcTpdC3px5WggNXfh5Hby8W8K1e9LLYMBRpPicZfj35Fb_Rsjzk4CUyamP1MJ30tuxdMt6Y',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '@ALEX_CHAOS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BrutalTheme.inkBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trip Lead & Seagull Fighter',
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BrutalTheme.graphite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
