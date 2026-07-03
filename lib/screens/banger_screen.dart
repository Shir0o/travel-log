import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme.dart';
import '../widgets/brutal_widgets.dart';

enum StudioState { setup, generating, playback }

class BangerScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String tripName;
  final String lyrics;

  const BangerScreen({
    Key? key,
    required this.onBack,
    required this.tripName,
    required this.lyrics,
  }) : super(key: key);

  @override
  _BangerScreenState createState() => _BangerScreenState();
}

class _BangerScreenState extends State<BangerScreen> with TickerProviderStateMixin {
  StudioState _currentState = StudioState.setup;
  
  // Vibe Selection
  String _selectedVibe = "Pop-Punk (2000s)";
  final List<String> _vibes = [
    "Pop-Punk (2000s)",
    "Euro-Trash Synth",
    "Sad Boy Indie",
    "Chaotic Rap"
  ];

  // ElevenLabs API Settings
  String _elevenlabsApiKey = '';
  int _musicLengthSeconds = 30;

  // Audio Player
  late AudioPlayer _audioPlayer;
  Uint8List? _audioBytes;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;

  // Generating State Animation
  List<double> _waveHeights = List.generate(35, (index) => 0.1);
  Timer? _generatorTimer;
  Timer? _generatingStateTransitionTimer;

  // Playback State Animation
  late AnimationController _vinylSpinController;
  bool _isPlaying = true;
  int _currentLyricIndex = 0;
  Timer? _lyricScrollTimer;
  
  List<String> get _lyrics {
    if (widget.lyrics.trim().isEmpty) {
      return [
        "No lyrics generated yet!",
        "Go back to Scrapbook...",
        "And write lyrics first...",
        "Before producing the track!"
      ];
    }
    return widget.lyrics.split('\n').where((line) => line.trim().isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    
    // Spin Controller for Vinyl / Cassette Spools
    _vinylSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _audioPlayer = AudioPlayer();
    _loadSettings();
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _audioDuration = duration;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _audioPosition = position;
          _updateLyricIndex(position);
        });
      }
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _audioPosition = Duration.zero;
          _currentLyricIndex = 0;
        });
        _vinylSpinController.stop();
      }
    });
  }

  void _updateLyricIndex(Duration position) {
    if (_lyrics.isEmpty || _audioDuration == Duration.zero) return;
    final totalMs = _audioDuration.inMilliseconds;
    if (totalMs <= 0) return;
    
    final currentMs = position.inMilliseconds;
    final double step = totalMs / _lyrics.length;
    int index = (currentMs / step).floor();
    index = index.clamp(0, _lyrics.length - 1);
    
    if (index != _currentLyricIndex) {
      setState(() {
        _currentLyricIndex = index;
      });
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _elevenlabsApiKey = prefs.getString('elevenlabs_api_key') ?? '';
        _musicLengthSeconds = prefs.getInt('elevenlabs_music_length') ?? 30;
      });
    } catch (_) {}
  }

  Future<void> _saveSettings(String key, int duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('elevenlabs_api_key', key);
      await prefs.setInt('elevenlabs_music_length', duration);
      setState(() {
        _elevenlabsApiKey = key;
        _musicLengthSeconds = duration;
      });
    } catch (_) {}
  }

  void _showSettingsDialog() {
    final keyController = TextEditingController(text: _elevenlabsApiKey);
    int tempDuration = _musicLengthSeconds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: BrutalCard(
                color: BrutalTheme.card,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ELEVENLABS SETTINGS',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: BrutalTheme.inkBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'API KEY',
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrutalTheme.graphite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BrutalTheme.brutalDecoration(
                        color: Colors.white,
                        borderWidth: 1.0,
                        showShadow: false,
                      ),
                      child: TextField(
                        controller: keyController,
                        obscureText: true,
                        style: GoogleFonts.karla(
                          fontSize: 14,
                          color: BrutalTheme.inkBlack,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Enter ElevenLabs API key...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TRACK DURATION',
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrutalTheme.graphite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [10, 20, 30, 45, 60].map((sec) {
                        final bool isSelected = tempDuration == sec;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  tempDuration = sec;
                                });
                              },
                              child: Container(
                                height: 36,
                                decoration: BrutalTheme.brutalDecoration(
                                  color: isSelected ? BrutalTheme.yellow : Colors.white,
                                  borderWidth: 1.0,
                                  borderRadius: BorderRadius.circular(6.0),
                                  showShadow: false,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${sec}S',
                                  style: GoogleFonts.karla(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: BrutalTheme.inkBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: BrutalButton(
                            color: BrutalTheme.yellow,
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.karla(
                                  fontWeight: FontWeight.bold,
                                  color: BrutalTheme.inkBlack),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BrutalButton(
                            color: BrutalTheme.cyan,
                            onPressed: () {
                              _saveSettings(
                                keyController.text.trim(),
                                tempDuration,
                              );
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: BrutalTheme.primary,
                                  content: Text(
                                    'ELEVENLABS SETTINGS SAVED!',
                                    style: GoogleFonts.karla(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            },
                            child: Text(
                              'SAVE',
                              style: GoogleFonts.karla(
                                  fontWeight: FontWeight.bold,
                                  color: BrutalTheme.inkBlack),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startRecordFlow() {
    if (_elevenlabsApiKey.isEmpty) {
      _showOfflineNotification();
      _startMockGeneration();
    } else {
      _generateMusicWithElevenLabs();
    }
  }

  void _showOfflineNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: BrutalTheme.yellow,
        content: Text(
          "Using mock generation. Configure ElevenLabs API key in Settings (cyan gear) for real music!",
          style: GoogleFonts.spaceMono(
            color: BrutalTheme.inkBlack,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _startMockGeneration() {
    setState(() {
      _currentState = StudioState.generating;
      _audioBytes = null;
    });

    // Start generating simulated waveform animation
    _generatorTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          final random = math.Random();
          _waveHeights = List.generate(35, (index) => random.nextDouble());
        });
      }
    });

    // Automatically transition to Playback after 3 seconds
    _generatingStateTransitionTimer = Timer(const Duration(seconds: 3), () {
      _generatorTimer?.cancel();
      if (mounted) {
        setState(() {
          _currentState = StudioState.playback;
          _isPlaying = true;
        });
        _vinylSpinController.repeat();
        _startLyricsCycle();
      }
    });
  }

  Future<void> _generateMusicWithElevenLabs() async {
    setState(() {
      _currentState = StudioState.generating;
      _audioBytes = null;
    });

    // Start generating simulated waveform animation
    _generatorTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          final random = math.Random();
          _waveHeights = List.generate(35, (index) => random.nextDouble());
        });
      }
    });

    try {
      final String promptText = "A $_selectedVibe song titled '${widget.tripName}' with lyrics: ${widget.lyrics.replaceAll('\n', ' ')}";
      
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/music/stream'),
        headers: {
          'xi-api-key': _elevenlabsApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': promptText,
          'music_length_ms': _musicLengthSeconds * 1000,
        }),
      );

      _generatorTimer?.cancel();

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (mounted) {
          setState(() {
            _audioBytes = bytes;
            _currentState = StudioState.playback;
            _isPlaying = true;
          });
          
          await _audioPlayer.play(BytesSource(bytes));
          _vinylSpinController.repeat();
        }
      } else {
        final errorText = response.body;
        String friendlyError = "API Error (${response.statusCode})";
        try {
          final decoded = jsonDecode(errorText);
          if (decoded['detail'] != null && decoded['detail']['status'] != null) {
            friendlyError = "${decoded['detail']['status']}: ${decoded['detail']['message']}";
          }
        } catch (_) {}
        
        if (mounted) {
          setState(() {
            _currentState = StudioState.setup;
          });
          _showErrorDialog(friendlyError);
        }
      }
    } catch (e) {
      _generatorTimer?.cancel();
      if (mounted) {
        setState(() {
          _currentState = StudioState.setup;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BrutalCard(
            color: BrutalTheme.yellow,
            borderWidth: 4.0,
            showShadow: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'GENERATION FAILED',
                  style: GoogleFonts.spaceMono(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BrutalTheme.inkBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: BrutalTheme.inkBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                BrutalButton(
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'DISMISS',
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                      color: BrutalTheme.inkBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startLyricsCycle() {
    _currentLyricIndex = 0;
    _lyricScrollTimer?.cancel();
    _lyricScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          _currentLyricIndex = (_currentLyricIndex + 1) % _lyrics.length;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_audioBytes != null) {
      if (_isPlaying) {
        _audioPlayer.resume();
        _vinylSpinController.repeat();
      } else {
        _audioPlayer.pause();
        _vinylSpinController.stop();
      }
    } else {
      if (_isPlaying) {
        _vinylSpinController.repeat();
        _startLyricsCycle();
      } else {
        _vinylSpinController.stop();
        _lyricScrollTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _generatorTimer?.cancel();
    _generatingStateTransitionTimer?.cancel();
    _lyricScrollTimer?.cancel();
    _vinylSpinController.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
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
            color: BrutalTheme.paper2,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE7DBC0), width: 1.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BrutalTheme.brutalDecoration(
                        color: Colors.white,
                        borderWidth: 1.0,
                        showShadow: true,
                        shadowOffset: const Offset(1, 2),
                      ),
                      child: const Icon(Icons.arrow_back, color: BrutalTheme.inkBlack),
                    ),
                  ),
                  Text(
                    'THE STUDIO',
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: BrutalTheme.inkBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSettingsDialog,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BrutalTheme.brutalDecoration(
                        color: BrutalTheme.cyan,
                        borderWidth: 1.0,
                        showShadow: true,
                        shadowOffset: const Offset(1, 2),
                      ),
                      child: const Icon(Icons.settings, color: BrutalTheme.inkBlack),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: GrainOverlay(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildStateContent(),
        ),
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_currentState) {
      case StudioState.setup:
        return _buildSetupState();
      case StudioState.generating:
        return _buildGeneratingState();
      case StudioState.playback:
        return _buildPlaybackState();
    }
  }

  Widget _buildSetupState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        // Dropdown Vibe Label
        Text(
          'Select Vibe:',
          style: GoogleFonts.karla(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BrutalTheme.inkBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BrutalTheme.brutalDecoration(
            color: BrutalTheme.card,
            borderWidth: 1.0,
            showShadow: true,
            shadowOffset: const Offset(1, 2),
            shadowColor: const Color(0x59433729),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedVibe,
              dropdownColor: BrutalTheme.card,
              icon: const Icon(Icons.arrow_drop_down, color: BrutalTheme.inkBlack),
              isExpanded: true,
              style: GoogleFonts.karla(
                color: BrutalTheme.inkBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              items: _vibes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedVibe = newValue;
                  });
                }
              },
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Cassette Tape Deck Graphical Widget
        _buildCassetteWidget(),
        
        const SizedBox(height: 48),
        
        // Record Button
        BrutalButton(
          color: BrutalTheme.primary,
          fullWidth: true,
          height: 72.0,
          onPressed: _startRecordFlow,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.radio_button_checked,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'PRESS RECORD',
                style: GoogleFonts.karla(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCassetteWidget() {
    return BrutalCard(
      color: BrutalTheme.card,
      showShadow: true,
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Cassette inner gray body
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E6CD),
                  border: Border.all(color: BrutalTheme.inkBlack, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Spool left
                    _buildCassetteSpool(),
                    // Middle viewing window (transparent black cutout)
                    Container(
                      width: 90,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: BrutalTheme.inkBlack, width: 1.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 16,
                          decoration: BoxDecoration(
                            color: BrutalTheme.inkBlack.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    // Spool right
                    _buildCassetteSpool(),
                  ],
                ),
              ),
              // Tape label: Cabo Fail '23 (brutal card rotated)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: -2.0 * 3.14159 / 180,
                    child: Container(
                      decoration: BrutalTheme.brutalDecoration(
                        color: BrutalTheme.yellow,
                        borderWidth: 1.0,
                        showShadow: false,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        widget.tripName,
                        style: GoogleFonts.caveat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: BrutalTheme.inkBlack,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCassetteSpool() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: BrutalTheme.inkBlack, width: 2.0),
        color: Colors.white,
      ),
      child: Center(
        // Small inner circle
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: BrutalTheme.inkBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingState() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text(
            'Cooking the beat...',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSerif(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: BrutalTheme.inkBlack,
            ),
          ),
          const SizedBox(height: 32),
          
          // Waveform Graphic Box
          BrutalCard(
            color: BrutalTheme.card,
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _waveHeights.map((h) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      height: math.max(6.0, h * 100),
                      color: BrutalTheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          Text(
            'Synthesizing vocals...',
            textAlign: TextAlign.center,
            style: GoogleFonts.karla(
              fontSize: 15,
              color: BrutalTheme.graphite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vinyl Player container
        AspectRatio(
          aspectRatio: 1 / 1,
          child: Container(
            decoration: BrutalTheme.brutalDecoration(
              color: BrutalTheme.inkBlack,
              borderWidth: 1.0,
              showShadow: true,
              shadowOffset: const Offset(1, 2),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grooves (circular outlines)
                Positioned.fill(
                  child: Center(
                    child: RotationTransition(
                      turns: _vinylSpinController,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade800, width: 2),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          heightFactor: 0.8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade800, width: 2),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0.7,
                              heightFactor: 0.7,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade800, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Spinning Vinyl disk with Center Photo Label
                RotationTransition(
                  turns: _vinylSpinController,
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    heightFactor: 0.85,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1C1C1C),
                      ),
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 0.38,
                        heightFactor: 0.38,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: BrutalTheme.inkBlack, width: 1.5),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuClrsy9bpJ_dZjzLwUERdlOOT_9RIMz2AGSf5vn3mat7Hcqoc1Uw_DiFJl__JQrsIWZ7u_nEXa8iSGP1H4AYiO9obrwZtJcxoejz3COVRQQAy3s0JG4bFfvWW0k9TDLOrjrMRRBQB4eRjpmetKLS3z0MRUQt1Sv9rjSj864kGbTxHiyPwYmoNcRMPWQNNrksuj8RLE69I9tfcY3SIHbfO0-la0CcBoTn3c4Y4fFMT-cifzggD0dQsfqe1AibKVNylGLLJ9nZXBDE0M',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: BrutalTheme.paper2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Tone Arm graphic (fixed relative position coming from top-right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Transform.rotate(
                    angle: _isPlaying ? 0.08 : -0.15, // Swings down to record when playing
                    origin: const Offset(36, -36),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida/AP1WRLuaOl0v705Q3kV3x0sfOKOCLeNqXLeY6cIi6JTxJpnH51okohPtn0ST11E6LdkSrX38Zq-CbwwwZxeXJH2Vjf2WIrV93IojuhHevLuhEfWm7c0HingOJ6VmKFUgvGDX_D61vAgbQ9hA_UjaVvYRkkO_cVXfkGpb0Vwf55X-_CNsKgxKS-RFj1R7qYTbnhwZOOA3lgzRgfT_danV0dVpPE70zul2VAxOctZKeHg-DhJhAYX4iAmaPbX3qvM',
                      width: 50,
                      height: 110,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback tone arm drawing if network image fails
                        return Container(
                          width: 8,
                          height: 100,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Brutalist Progress Bar
        if (_audioBytes != null && _audioDuration != Duration.zero)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 16,
                  decoration: BrutalTheme.brutalDecoration(
                    color: Colors.white,
                    borderWidth: 1.0,
                    borderRadius: BorderRadius.circular(4.0),
                    showShadow: false,
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (_audioPosition.inMilliseconds / _audioDuration.inMilliseconds)
                        .clamp(0.0, 1.0),
                    child: Container(
                      color: BrutalTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_audioPosition),
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrutalTheme.inkBlack,
                      ),
                    ),
                    Text(
                      _formatDuration(_audioDuration),
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrutalTheme.inkBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),
        
        // Karaoke Lyrics Area
        BrutalCard(
          color: BrutalTheme.card,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: DymoLabel(text: 'NOW PLAYING'),
              ),
              const SizedBox(height: 16),
              // Lyric Lines
              Column(
                children: List.generate(_lyrics.length, (index) {
                  final bool isActive = index == _currentLyricIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _lyrics[index],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSerif(
                        fontSize: isActive ? 20.0 : 16.0,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive 
                            ? BrutalTheme.inkBlack
                            : BrutalTheme.graphite.withOpacity(0.5),
                        shadows: isActive 
                            ? [
                                const Shadow(
                                  color: Color(0x66D6BE8C),
                                  offset: Offset(1, 1),
                                  blurRadius: 2.0,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Playback Action Controls
        Row(
          children: [
            // Pause button
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 66,
                height: 66,
                decoration: BrutalTheme.brutalDecoration(
                  color: Colors.white,
                  borderWidth: 1.0,
                  showShadow: true,
                  shadowOffset: const Offset(1, 2),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                  color: BrutalTheme.inkBlack,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Share Button
            Expanded(
              child: BrutalButton(
                color: BrutalTheme.cyan,
                height: 66.0,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: BrutalTheme.cyan,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
                      content: Text(
                        'SHARED TO INSTAGRAM STORY!',
                        style: GoogleFonts.karla(
                          fontWeight: FontWeight.bold,
                          color: BrutalTheme.inkBlack,
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, color: BrutalTheme.inkBlack),
                    const SizedBox(width: 8),
                    Text(
                      'SHARE TO STORY',
                      style: GoogleFonts.karla(
                        color: BrutalTheme.inkBlack,
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
      ],
    );
  }
}
