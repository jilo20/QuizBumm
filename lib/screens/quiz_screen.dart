import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late ConfettiController _confettiController;

  static const Color kPrimaryColor = Color(0xFF2563EB);
  static const Color kDarkSlate = Color(0xFF1E293B);
  static const Color kOffWhite = Color(0xFFF8FAFC);
  static const Color kCorrectGreen = Color(0xFF16A34A);
  static const Color kAmberAccent = Color(0xFFF59E0B);

  Offset _dragDelta = Offset.zero;
  bool _isSwipeHandled = false;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleSwipeSelection(int index, List<AnswerOption> options) {
    if (index >= options.length) return;
    _isSwipeHandled = true;
    _hoveredIndex = index;
    final selection = options[index];
    HapticFeedback.heavyImpact();
    ref.read(quizProvider.notifier).selectOption(selection);
    ref.read(quizProvider.notifier).checkAnswer();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final question = mockQuestions[quizState.currentQuestionIndex];

    if (quizState.isQuizFinished) {
      _confettiController.play();
      return _buildResultsScreen(quizState);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(quizState.progress),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          _dragDelta = Offset.zero;
          _isSwipeHandled = false;
          _hoveredIndex = null;
        },
        onPanUpdate: (details) {
          if (quizState.isAnswerChecked || _isSwipeHandled) return;
          setState(() {
            _dragDelta += details.delta;
            final absX = _dragDelta.dx.abs();
            final absY = _dragDelta.dy.abs();
            if (_dragDelta.distance > 20) {
              _hoveredIndex =
                  (absX > absY)
                      ? (_dragDelta.dx > 0 ? 3 : 2)
                      : (_dragDelta.dy > 0 ? 1 : 0);
            } else {
              _hoveredIndex = null;
            }

            if (absX > 100 || absY > 100) {
              if (_hoveredIndex != null) {
                _handleSwipeSelection(_hoveredIndex!, question.options);
              }
            }
          });
        },
        onPanEnd: (_) => setState(() => _dragDelta = Offset.zero),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildMascotSpeechHeader(question.text),

              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 310,
                    height: 310,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Static Slots
                        _buildStaticSlot(Alignment.topCenter),
                        _buildStaticSlot(Alignment.bottomCenter),
                        _buildStaticSlot(Alignment.centerLeft),
                        _buildStaticSlot(Alignment.centerRight),

                        // Sorted Cards
                        ...() {
                          final cardOrder = [0, 1, 2, 3];
                          final selectedIdx = question.options.indexWhere(
                            (o) => o == quizState.selectedOption,
                          );
                          if (selectedIdx != -1) {
                            cardOrder.remove(selectedIdx);
                            cardOrder.add(selectedIdx);
                          } else if (_hoveredIndex != null) {
                            cardOrder.remove(_hoveredIndex);
                            cardOrder.add(_hoveredIndex!);
                          }
                          return cardOrder.map((i) {
                            if (i < question.options.length) {
                              return _buildDirectionalCard(
                                i,
                                question.options[i],
                                _dragDelta,
                                quizState,
                              );
                            }
                            return const SizedBox.shrink();
                          });
                        }().toList(),
                      ],
                    ),
                  ),
                ),
              ),

              _buildBottomFeedback(quizState),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double progress) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: kDarkSlate),
        onPressed: () => Navigator.pop(context),
      ),
      title: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 10,
          width: 200,
          color: Colors.grey.shade100,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(color: kPrimaryColor),
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMascotSpeechHeader(String text) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(
            Icons.psychology,
            size: 64,
            color: kPrimaryColor,
          ).animate().scale(curve: Curves.elasticOut),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkSlate,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticSlot(Alignment align) {
    return Align(
      alignment: align,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.shade100, width: 2),
        ),
      ),
    );
  }

  Widget _buildDirectionalCard(
    int index,
    AnswerOption option,
    Offset drag,
    QuizState state,
  ) {
    final isSelected = state.selectedOption == option;
    final isHovered = _hoveredIndex == index && !state.isAnswerChecked;
    final isChecked = state.isAnswerChecked;

    Alignment align;
    IconData arrowIcon;
    switch (index) {
      case 0:
        align = Alignment.topCenter;
        arrowIcon = Icons.arrow_upward_rounded;
        break;
      case 1:
        align = Alignment.bottomCenter;
        arrowIcon = Icons.arrow_downward_rounded;
        break;
      case 2:
        align = Alignment.centerLeft;
        arrowIcon = Icons.arrow_back_rounded;
        break;
      case 3:
        align = Alignment.centerRight;
        arrowIcon = Icons.arrow_forward_rounded;
        break;
      default:
        align = Alignment.center;
        arrowIcon = Icons.help_outline;
    }

    double scale = 1.0;
    if (isSelected) {
      scale = 1.7;
    } else if (isHovered) {
      final ratio = (drag.distance / 100).clamp(0.0, 1.0);
      scale = 1.0 + (ratio * 0.4);
    }

    Color bgColor = Colors.white;
    Color border = Colors.grey.shade200;
    Color textColor = kDarkSlate;
    double opacity = 1.0;

    if (isSelected) {
      border =
          isChecked
              ? (option.isCorrect ? kCorrectGreen : kAmberAccent)
              : kPrimaryColor;
      bgColor = border;
      textColor = Colors.white;
    } else if (isHovered) {
      final ratio = (drag.distance / 100).clamp(0.0, 1.0);
      border = Color.lerp(Colors.grey.shade200, kPrimaryColor, ratio)!;
      bgColor =
          Color.lerp(
            Colors.white,
            kPrimaryColor.withValues(alpha: 0.1),
            ratio,
          )!;
    }

    if (state.selectedOption != null && !isSelected)
      opacity = 0.15;
    else if (_hoveredIndex != null &&
        _hoveredIndex != index &&
        !state.isAnswerChecked)
      opacity = 0.4;

    // Fixed pixel positions for each slot in a 310x310 box with 100x100 cards
    const double center = 105.0; // (310 - 100) / 2
    double targetLeft = center;
    double targetTop = center;
    switch (index) {
      case 0:
        targetLeft = center;
        targetTop = 0;
        break; // Top
      case 1:
        targetLeft = center;
        targetTop = 210;
        break; // Bottom
      case 2:
        targetLeft = 0;
        targetTop = center;
        break; // Left
      case 3:
        targetLeft = 210;
        targetTop = center;
        break; // Right
    }

    // Only the selected card moves to center
    if (isSelected) {
      targetLeft = center;
      targetTop = center;
    }

    return AnimatedPositioned(
      left: targetLeft,
      top: targetTop,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: border, width: isSelected ? 5 : 2),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: border.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ]
                      : [],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: index == 0 ? -10 : null,
                  bottom: index == 1 ? -10 : null,
                  left: index == 2 ? -10 : null,
                  right: index == 3 ? -10 : null,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(arrowIcon, color: Colors.white, size: 12),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      option.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFeedback(QuizState state) {
    if (!state.isAnswerChecked) return const SizedBox(height: 120);
    final isCorrect = state.selectedOption!.isCorrect;
    final color = isCorrect ? kCorrectGreen : kAmberAccent;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? "CLEARED!" : "INCORRECT",
                style: GoogleFonts.outfit(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSwipeHandled = false;
                _hoveredIndex = null;
                _dragDelta = Offset.zero;
              });
              ref.read(quizProvider.notifier).nextQuestion();
            },
            child: Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container()
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 2.seconds, color: Colors.white24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "CONTINUE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().scale(curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildResultsScreen(QuizState state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.stars_rounded,
              size: 100,
              color: kAmberAccent,
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              "MISSION OVER",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSwipeHandled = false;
                  _hoveredIndex = null;
                  _dragDelta = Offset.zero;
                });
                ref.read(quizProvider.notifier).restartQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                "RESTART",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
