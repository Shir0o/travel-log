import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/brutal_widgets.dart';

class TypewriterScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onProduceTrack;

  const TypewriterScreen({
    Key? key,
    required this.onBack,
    required this.onProduceTrack,
  }) : super(key: key);

  @override
  _TypewriterScreenState createState() => _TypewriterScreenState();
}

class _TypewriterScreenState extends State<TypewriterScreen> {
  // Animation states
  bool _isGenerating = false;
  double _noteScale = 1.0;
  double _noteOpacity = 1.0;
  Offset _noteOffset = Offset.zero;
  
  // Typewriter text state
  int _charCount = 0;
  final String _targetText = 
      "Oh Cabo, you absolute disaster\n"
      "Spinning out, losing control much faster\n"
      "Sunburns, lost phones, and a broken toe\n"
      "Best worst trip we'll ever know!";
      
  Timer? _typewriterTimer;

  void _startGeneration() {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      // Start note "suck in" animation
      _noteScale = 0.1;
      _noteOpacity = 0.0;
      _noteOffset = const Offset(120.0, -180.0);
    });

    // Simulate typing
    _charCount = 0;
    _typewriterTimer?.cancel();
    
    // Wait for suck-in animation to complete (approx 400ms) before starting text reveal
    Future.delayed(const Duration(milliseconds: 500), () {
      _typewriterTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
        if (_charCount < _targetText.length) {
          setState(() {
            _charCount++;
          });
        } else {
          timer.cancel();
          setState(() {
            _isGenerating = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

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
            boxShadow: [
              BoxShadow(
                color: BrutalTheme.inkBlack,
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BrutalTheme.brutalDecoration(
                        color: BrutalTheme.yellow,
                        borderWidth: 3.0,
                        showShadow: true,
                      ),
                      child: const Icon(Icons.arrow_back, color: BrutalTheme.inkBlack),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "CABO FAIL '23",
                        style: GoogleFonts.spaceMono(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: BrutalTheme.inkBlack,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Avatar stacked left
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: BrutalTheme.inkBlack, width: 2.0),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBaaTO7cLQFBrDukdQJfD3l7ZU6uEhLr7qQH9TyLcgNYThOs7L1vEfkg_UAYeznV4j9-TuRPuvNdEm-a8SRMfXKCouP4ktiKDDcSteE25_lXzgpKSK0ap500-fE4wOvwsjR7sPnnTbkc8-tlghvXVCjAwh9uMVjsdJcQmmUEBEgJ4mCl_lEt72jI-lgpitIkQzLHQq5irnwgSJ6lEpt1JUXp2CthNbiGI6ugpLlX-u9WonwX_UkMZN7MP8RJtCYp6KiE0phyGVbuwU'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Avatar stacked right
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: BrutalTheme.inkBlack, width: 2.0),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCghbkiryWQhllkb3HHw0EoxcfB-7EWQiMknmg3PbaUm3ONhic0-gmWdSo2UQ3b8NfhOisBharEcLXY9w9S97Cuj6Jz5rKfksZt8Le-HpOx37FOZ01gG19h-t8NKuFmSNP1hFg3edNKBbxCte9n-tsdM_WFVLJDZphFIKEwwXFoID0NQYcjVs2_2CiPpVd-R8HmnxRO78nrdnj_VkgBn5t0sSpNjBcM8feOz4HqV5jMZuTJ1zVFzoBZ_iAqnajoZXvMNtqBRSScElo'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: GrainOverlay(
        child: Stack(
          children: [
            // Editor canvas
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 76.0, bottom: 200.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildVerse1Block(),
                  const SizedBox(height: 16),
                  _buildChorusBlock(),
                  const SizedBox(height: 16),
                  _buildVerse2EmptyBlock(),
                ],
              ),
            ),
            
            // Toolbar (stuck to top of page below app bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: BrutalTheme.backgroundLight.withOpacity(0.9),
                  border: const Border(
                    bottom: BorderSide(color: Colors.black12, width: 2.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToolbarBtn("[B]"),
                    const SizedBox(width: 8),
                    _buildToolbarBtn("[I]"),
                    const SizedBox(width: 8),
                    _buildToolbarBtn("[LIST]", icon: Icons.format_list_bulleted),
                  ],
                ),
              ),
            ),
            
            // Background Note: "I lost my shoe..." (right side)
            Positioned(
              right: 12,
              top: 140,
              child: Opacity(
                opacity: 0.35,
                child: BrutalCard(
                  color: BrutalTheme.yellow,
                  rotationDegrees: 6.0,
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 100,
                    child: Text(
                      '"I lost my shoe in the ocean!"\n- Sarah',
                      style: GoogleFonts.caveat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BrutalTheme.inkBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Background Note: "Pin: The sketchy taco stand" (left side)
            Positioned(
              left: 12,
              top: 360,
              child: Opacity(
                opacity: 0.35,
                child: BrutalCard(
                  color: Colors.white,
                  rotationDegrees: -12.0,
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 100,
                    child: Text(
                      'Pin:\nThe sketchy taco stand',
                      style: GoogleFonts.caveat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BrutalTheme.inkBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Action Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: BrutalTheme.backgroundLight,
                  border: Border(
                    top: BorderSide(color: BrutalTheme.inkBlack, width: 4.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BrutalTheme.inkBlack,
                      offset: Offset(0, -4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Generate Verse button
                    BrutalButton(
                      color: BrutalTheme.primary,
                      fullWidth: true,
                      height: 56.0,
                      onPressed: _startGeneration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _isGenerating ? 'GENERATING...' : 'GENERATE VERSE',
                            style: GoogleFonts.spaceMono(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Produce Track button
                    BrutalButton(
                      color: BrutalTheme.yellow,
                      fullWidth: true,
                      height: 50.0,
                      onPressed: widget.onProduceTrack,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PRODUCE TRACK',
                            style: GoogleFonts.spaceMono(
                              color: BrutalTheme.inkBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.album, color: BrutalTheme.inkBlack),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Animated Suck-in Note: "Dave dropped his taco"
            if (_noteOpacity > 0.01)
              Positioned(
                left: 20,
                bottom: 154,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInBack,
                  transform: Matrix4.translationValues(_noteOffset.dx, _noteOffset.dy, 0)
                    ..scale(_noteScale),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _noteOpacity,
                    child: Transform.rotate(
                      angle: -3.0 * 3.14159 / 180,
                      child: BrutalCard(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sticky_note_2, size: 16, color: BrutalTheme.inkBlack),
                            const SizedBox(width: 6),
                            Text(
                              'Dave dropped his taco',
                              style: GoogleFonts.caveat(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: BrutalTheme.inkBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarBtn(String label, {IconData? icon}) {
    return Container(
      decoration: BrutalTheme.brutalDecoration(
        color: Colors.white,
        borderWidth: 2.0,
        showShadow: false,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: icon != null 
        ? Icon(icon, size: 16, color: BrutalTheme.inkBlack)
        : Text(
            label,
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: BrutalTheme.inkBlack,
            ),
          ),
    );
  }

  Widget _buildVerse1Block() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 2.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "[VERSE 1]",
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: BrutalTheme.graphite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Packed my bags, forgot my passport\n"
                "Dave threw up on the airport transport\n"
                "Tequila shots before the plane took flight\n"
                "Someone started a random fight",
                style: GoogleFonts.courierPrime(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: BrutalTheme.inkBlack,
                ),
              ),
            ],
          ),
          // Collaborative cursor for Dave
          Positioned(
            bottom: 4,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 2,
                  height: 20,
                  color: BrutalTheme.cyan,
                ),
                const SizedBox(width: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: BrutalTheme.cyan,
                    border: Border.all(color: BrutalTheme.inkBlack, width: 1.5),
                  ),
                  child: Text(
                    'Dave',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: BrutalTheme.inkBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChorusBlock() {
    final bool showGeneratingHeader = _isGenerating && (_charCount < _targetText.length);
    final String currentRevealText = _targetText.substring(0, _charCount);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 2.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showGeneratingHeader ? "[CHORUS - GENERATING...]" : "[CHORUS]",
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: showGeneratingHeader ? BrutalTheme.primary : BrutalTheme.graphite,
                ),
              ),
              const SizedBox(height: 8),
              if (_charCount > 0)
                Text(
                  currentRevealText,
                  style: GoogleFonts.courierPrime(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: BrutalTheme.inkBlack,
                  ),
                )
              else
                Text(
                  "...\n\n\n",
                  style: GoogleFonts.courierPrime(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent,
                  ),
                ),
            ],
          ),
          
          // Collaborative cursor for AI Magic
          if (showGeneratingHeader)
            Positioned(
              left: 120,
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 2,
                    height: 20,
                    color: BrutalTheme.primary,
                  ),
                  const SizedBox(width: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: BrutalTheme.primary,
                      border: Border.all(color: BrutalTheme.inkBlack, width: 1.5),
                    ),
                    child: Text(
                      'AI Magic',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerse2EmptyBlock() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "[VERSE 2]",
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: BrutalTheme.graphite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Type here or generate...",
            style: GoogleFonts.courierPrime(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: BrutalTheme.graphite,
            ),
          ),
        ],
      ),
    );
  }
}
