import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/brutal_widgets.dart';

class EvidenceScreen extends StatefulWidget {
  final VoidCallback onBack;

  const EvidenceScreen({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  _EvidenceScreenState createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Highlight states
  String? _highlightedId;

  void _scrollToMemory(String id, double offset) {
    setState(() {
      _highlightedId = id;
    });

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );

    // Clear highlight after flash
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _highlightedId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: BrutalTheme.inkBlack, width: 3.0),
            ),
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
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: BrutalTheme.inkBlack,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "THE EVIDENCE",
                        style: GoogleFonts.spaceMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BrutalTheme.inkBlack,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer matching back button
                ],
              ),
            ),
          ),
        ),
      ),
      body: GrainOverlay(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Map section (approx 35% height)
                _buildMapSection(),
                // Bottom timeline section (approx 65% height)
                Expanded(
                  child: _buildTimelineSection(),
                ),
              ],
            ),
            
            // Sticky bottom CTA banner
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: BrutalButton(
                color: BrutalTheme.primary,
                fullWidth: true,
                height: 56.0,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: BrutalTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
                      content: Text(
                        'SPILLING THE TEA... NEW MEMORY POPUP COMING SOON!',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_box, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'ADD THE TEA',
                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 240,
      decoration: const BoxDecoration(
        color: Colors.grey,
        border: Border(
          bottom: BorderSide(color: BrutalTheme.inkBlack, width: 3.0),
        ),
        image: DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDMHms3J94ZNjT47OBSVc9ASGToglMRsH4M7TugUYqZNLagdBdlXG1KkQElo-6WnvGjhEXccwWMfKlx0M3_H6tRGBmy79-ZmOSo27xJ5rrxDcID3eLSg5UuvwpTGwqDAsqWyIkgNckmm9DrKkjKi5V4Yt9S0G82nqo6IzhOScueF3PBzxCwRsaYhaj__lUaUtz_kCywpGJMPa_lIGe_qOHmc45eg0eUMTV3tJ2h_iMT8wc-vIZCMvk-V1-iymfJ0QjChcHhumJRg3w',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.multiply),
        ),
      ),
      child: Stack(
        children: [
          // Zine Overlay color filter
          Container(color: Colors.black12),
          
          // Map Pin 1: THE INCIDENT
          Positioned(
            left: 50,
            top: 50,
            child: GestureDetector(
              onTap: () => _scrollToMemory('mem-1', 0.0),
              child: Column(
                children: [
                  Transform.rotate(
                    angle: -3.0 * 3.14159 / 180,
                    child: Container(
                      decoration: BrutalTheme.brutalDecoration(
                        color: BrutalTheme.primary,
                        borderWidth: 2.0,
                        showShadow: true,
                        shadowOffset: const Offset(2, 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: Text(
                        'THE INCIDENT',
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    color: BrutalTheme.primary,
                    size: 36,
                    shadows: [
                      Shadow(
                        color: BrutalTheme.inkBlack,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Map Pin 2: BAD IDEA #4
          Positioned(
            right: 80,
            bottom: 40,
            child: GestureDetector(
              onTap: () => _scrollToMemory('mem-2', 360.0),
              child: Column(
                children: [
                  Transform.rotate(
                    angle: 4.0 * 3.14159 / 180,
                    child: Container(
                      decoration: BrutalTheme.brutalDecoration(
                        color: BrutalTheme.primary,
                        borderWidth: 2.0,
                        showShadow: true,
                        shadowOffset: const Offset(2, 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: Text(
                        'BAD IDEA #4',
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    color: BrutalTheme.primary,
                    size: 36,
                    shadows: [
                      Shadow(
                        color: BrutalTheme.inkBlack,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    final bool flashMem1 = _highlightedId == 'mem-1';
    final bool flashMem2 = _highlightedId == 'mem-2';

    return Stack(
      children: [
        // Vertical Timeline Track Line
        Positioned(
          left: 36,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            color: BrutalTheme.inkBlack,
          ),
        ),
        
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 120.0),
          child: Column(
            children: [
              // Memory 1
              _buildTimelineNode(
                id: 'mem-1',
                time: '11:42 PM',
                author: '@alex',
                rotationDegrees: -2.0,
                flash: flashMem1,
                icon: Icons.bolt,
                iconBg: BrutalTheme.yellow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: BrutalTheme.inkBlack, width: 2.0),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAqb6LbvBrW4Ue7MDpYvmzbpa3X5fcuFWPtqqrdKEiPjauXeqmVkyr1FoK2oQ86wIllp4eCLovXTDALySIyfTpuZsJKZIffX3GI4Wc4TVJgzAzWHsgNsxwMe0EDW12vTKwjH7Yo4x8epfn-t-uF4ABXKVfuhM5rJfJlCtfFIEhuWowtu075ufdeINuDczymoFN2gb7MNlwvSI5oSPkGiqsrI2KtTxhp16JhKwgBpo32ItQuvg_DLFOLCd8W8UsZtYnNhDrM9QUFG3k',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: BrutalTheme.yellow,
                        border: Border.all(color: BrutalTheme.inkBlack, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'FAIL',
                        style: GoogleFonts.courierPrime(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: BrutalTheme.inkBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Alex tried to fight a seagull for the last churro. The seagull won. We are never returning to this pier.',
                      style: GoogleFonts.courierPrime(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: BrutalTheme.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Memory 2
              _buildTimelineNode(
                id: 'mem-2',
                time: '02:15 AM',
                author: '@sarah',
                rotationDegrees: 3.0,
                flash: flashMem2,
                icon: Icons.local_fire_department,
                iconBg: BrutalTheme.primary,
                iconColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BrutalTheme.inkBlack,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"I know a shortcut through the alley."',
                            style: GoogleFonts.spaceMono(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- Famous last words',
                            style: GoogleFonts.spaceMono(
                              color: BrutalTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ended up at a 24hr laundromat playing poker with candy wrappers.',
                      style: GoogleFonts.courierPrime(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: BrutalTheme.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Memory 3
              _buildTimelineNode(
                id: 'mem-3',
                time: '04:00 AM',
                author: '@group',
                rotationDegrees: -1.0,
                flash: false,
                icon: Icons.music_note,
                iconBg: BrutalTheme.yellow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: BrutalTheme.inkBlack, width: 2.0),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAa9qiUmdAn3I64gl8K4ttDZttAwinQPlReLQZWN9kOMrbJVmCHh3RgR-xZU-4fr8CvUS5rD-ql8B8PB5XsPNnvYyZ0v00_KrlexLnLexSB_PqIX9f-lAE3tIeMZ5ijH95a1ALJfNJs-U9uEF6_kifH_8ISG6yah6Weuq6w1FO0TjnjW4VjGyIuTvrzvK6oVBs89ft5wtKJ4Cpx_SnJ4am_Tpb7T04QTErssDV2CC1yErbuA8DzUUFDrPuAefpcL8fRWO70WCXwDtM',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Karaoke meltdown. We owe the owner an apology for destroying \'Mr. Brightside\'.',
                      style: GoogleFonts.courierPrime(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: BrutalTheme.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              Text(
                '--- END OF TAPE ---',
                style: GoogleFonts.spaceMono(
                  color: BrutalTheme.graphite,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineNode({
    required String id,
    required String time,
    required String author,
    required Widget child,
    required IconData icon,
    required Color iconBg,
    Color iconColor = BrutalTheme.inkBlack,
    double rotationDegrees = 0.0,
    bool flash = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline node indicator circle
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 8.0, top: 12.0),
          decoration: BrutalTheme.brutalDecoration(
            color: iconBg,
            borderWidth: 2.0,
            showShadow: true,
            shadowOffset: const Offset(2, 2),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 16),
        // Card content
        Expanded(
          child: BrutalCard(
            color: flash ? BrutalTheme.yellow : Colors.white,
            rotationDegrees: rotationDegrees,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (dashed border)
                Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: BrutalTheme.inkBlack,
                        width: 1.5,
                        style: BorderStyle.solid, // Flutter dashed border is complex, solid is fine for scaffold
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: BrutalTheme.inkBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          time,
                          style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        author,
                        style: GoogleFonts.caveat(
                          color: BrutalTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
