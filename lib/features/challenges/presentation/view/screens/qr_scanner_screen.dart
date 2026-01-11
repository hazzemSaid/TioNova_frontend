import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/core/utils/safe_navigation.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SafeContextMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _scannedCode;

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _green => const Color.fromRGBO(0, 153, 102, 1);

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _scannedCode = code;
    });

    print('QR Scanner - Code detected: $code');

    // Join the challenge with the scanned code
    await _joinChallenge(code);
  }

  Future<void> _joinChallenge(String challengeCode) async {
    if (!contextIsValid) return;

    print('QR Scanner - Joining challenge: $challengeCode');

    // Call join challenge API using the use case
    await context.read<ChallengeCubit>().joinChallenge(
      challengeCode: challengeCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        if (!_isProcessing) return;

        if (state is ChallengeJoined) {
          // Success - navigate to waiting room using pushReplacement
          print('QR Scanner - Successfully joined challenge');
          safeContext((ctx) {
            ctx.pushReplacementNamed(
              'challenge-lobby',
              pathParameters: {'code': _scannedCode ?? ''},
              extra: {
                'challengeName': state.challengeName,
                'challengeCubit': ctx.read<ChallengeCubit>(),
                'authCubit': ctx.read<AuthCubit>(),
              },
            );
          });
        } else if (state is ChallengeError) {
          // Error - show dialog and allow rescan
          safeContext((ctx) {
            CustomDialogs.showErrorDialog(
              ctx,
              title: 'Error!',
              message: state.message,
              onPressed: () {
                setState(() {
                  _isProcessing = false;
                  _scannedCode = null;
                });
              },
            );
          });
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // Camera preview
            MobileScanner(controller: cameraController, onDetect: _onDetect),
            // Overlay
            _buildOverlay(),
            // Top bar
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  const Spacer(),
                  _buildInstructions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            // Processing indicator
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: _green),
                      const SizedBox(height: 16),
                      Text(
                        'Joining challenge...',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.safePop(fallback: '/challenges'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardBg.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: _textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              'Scan QR Code',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Flash toggle
          GestureDetector(
            onTap: () => cameraController.toggleTorch(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardBg.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.flash_on_rounded,
                color: _textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: _green, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Corner accents
              _buildCornerAccent(Alignment.topLeft),
              _buildCornerAccent(Alignment.topRight),
              _buildCornerAccent(Alignment.bottomLeft),
              _buildCornerAccent(Alignment.bottomRight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerAccent(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft
                ? const Radius.circular(20)
                : Radius.zero,
            topRight: alignment == Alignment.topRight
                ? const Radius.circular(20)
                : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft
                ? const Radius.circular(20)
                : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight
                ? const Radius.circular(20)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_scanner_rounded, color: _green, size: 40),
          const SizedBox(height: 12),
          Text(
            'Position QR Code in Frame',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Align the QR code within the frame to scan and join the challenge',
            style: TextStyle(color: _textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
