import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class ShareChallengeScreen extends StatelessWidget {
  final String challengeName;
  final int questionsCount;
  final int durationMinutes;
  final String inviteCode;

  const ShareChallengeScreen({
    super.key,
    required this.challengeName,
    this.questionsCount = 10,
    this.durationMinutes = 15,
    this.inviteCode = 'TSPHO5',
  });

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _greenCardBg => const Color(0xFF0F1A13);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _divider => const Color(0xFF2C2C2E);
  Color get _green => const Color(0xFF30D158);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 900;
    final maxContentWidth = 520.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _panelBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: _divider),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Share Challenge',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 32, height: 32),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? (width - maxContentWidth) / 2 : 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWeb ? maxContentWidth : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildChallengeCard(context),
                        const SizedBox(height: 20),
                        _buildQRSection(context),
                        const SizedBox(height: 20),
                        _buildCodeSection(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Start challenge
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text(
                    'Start Challenge',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
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

  Widget _buildChallengeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_greenCardBg, _greenCardBg.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _green.withOpacity(0.3)),
            ),
            child: Icon(Icons.emoji_events, color: _green, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            challengeName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$questionsCount questions • $durationMinutes minutes',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _green.withOpacity(0.3)),
            ),
            child: Text(
              'Ready to Start',
              style: TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Column(
        children: [
          Text(
            'Scan to Join',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Dummy QR code placeholder
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(painter: _DummyQRPainter()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Friends can scan this QR code to join instantly',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Column(
        children: [
          Text(
            'Or Share Code',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _panelBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  inviteCode,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _panelBg,
                        content: Text(
                          'Code copied to clipboard',
                          style: TextStyle(color: _textPrimary),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _divider),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: _textSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite Code',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Share functionality
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textPrimary,
                    side: BorderSide(color: _divider),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Save QR functionality
                  },
                  icon: const Icon(Icons.save_alt, size: 16),
                  label: const Text('Save QR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textPrimary,
                    side: BorderSide(color: _divider),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Dummy QR code painter (simple pattern)
class _DummyQRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final blockSize = size.width / 12;

    // Draw a simple QR-like pattern
    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < 12; j++) {
        // Create a pseudo-random pattern
        if ((i + j * 3) % 5 == 0 ||
            (i * 2 + j) % 7 == 0 ||
            (i == 0 || i == 11 || j == 0 || j == 11)) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * blockSize,
              j * blockSize,
              blockSize * 0.9,
              blockSize * 0.9,
            ),
            paint,
          );
        }
      }
    }

    // Draw corner markers (QR style)
    final cornerSize = blockSize * 3;
    final corners = [
      Offset(0, 0),
      Offset(size.width - cornerSize, 0),
      Offset(0, size.height - cornerSize),
    ];

    for (final corner in corners) {
      // Outer square
      canvas.drawRect(
        Rect.fromLTWH(corner.dx, corner.dy, cornerSize, cornerSize),
        paint,
      );
      // Inner square (make hollow)
      canvas.drawRect(
        Rect.fromLTWH(
          corner.dx + blockSize,
          corner.dy + blockSize,
          blockSize,
          blockSize,
        ),
        Paint()..color = Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
