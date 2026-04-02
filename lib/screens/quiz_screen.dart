import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';

// Brand Design Constants
const Color kPrimaryColor = Color(0xFF2563EB);
const Color kDarkSlate = Color(0xFF1E293B);
const Color kCorrectGreen = Color(0xFF16A34A);
const Color kAmberAccent = Color(0xFFF59E0B);

class QuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late ConfettiController _confettiController;
  
  // Interaction State
  Offset _dragDelta = Offset.zero;
  bool _isSwipeHandled = false;
  int? _hoveredIndex;

  // Connect Mode State - STABLE & STATIC
  final GlobalKey _stackKey = GlobalKey();
  final Map<int, GlobalKey> _leftKeys = {};
  final Map<int, GlobalKey> _rightKeys = {};
  List<int> _shuffledLeftIndices = [];
  List<int> _shuffledRightIndices = [];
  Offset? _dragPosition;
  int? _activeDraggingIdx;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    Future.microtask(() => ref.read(quizProvider.notifier).initQuiz(widget.quiz.questions));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleSelection(AnswerOption selection) {
    if (ref.read(quizProvider).isAnswerChecked) return;
    HapticFeedback.heavyImpact();
    ref.read(quizProvider.notifier).selectOption(selection);
    ref.read(quizProvider.notifier).checkAnswer();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    if (quizState.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kPrimaryColor)));
    }

    if (quizState.isQuizFinished) {
      _confettiController.play();
      return _buildResultsScreen(quizState);
    }

    final question = quizState.questions[quizState.currentQuestionIndex];
    
    // Ensure randomized Column B is stable and doesn't "crazy jump" during builds
    if (question.mode == 'connect' && (_shuffledLeftIndices.isEmpty || _shuffledLeftIndices.length != question.pairs.length)) {
       _shuffledLeftIndices = List.generate(question.pairs.length, (i) => i)..shuffle();
       _shuffledRightIndices = List.generate(question.pairs.length, (i) => i)..shuffle();
    }

    Widget bodyContent;
    switch (question.mode) {
      case 'press':
        bodyContent = _buildPressMode(question, quizState);
        break;
      case 'connect':
        bodyContent = _buildConnectMode(question, quizState);
        break;
      default:
        bodyContent = _buildSwipeMode(question, quizState);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(quizState.progress),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: Container(
          key: ValueKey(quizState.currentQuestionIndex),
          child: bodyContent,
        ),
      ),
    );
  }

  // ==========================================
  // MODE 3: CONNECT (ABSOLUTELY STATIC CARDS)
  // ==========================================
  Widget _buildConnectMode(Question question, QuizState quizState) {
    for (int i = 0; i < question.pairs.length; i++) {
      _leftKeys.putIfAbsent(i, () => GlobalKey());
      _rightKeys.putIfAbsent(i, () => GlobalKey());
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildMascotSpeechHeader(question.text, "Draw lines between matching dots!"),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              key: _stackKey,
              children: [
                // Lines Layer
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConnectionPainter(
                      leftKeys: _leftKeys,
                      rightKeys: _rightKeys,
                      matches: quizState.connectMatches,
                      dragPosition: _dragPosition,
                      activeDraggingIdx: _activeDraggingIdx,
                      stackBox: _stackKey.currentContext?.findRenderObject() as RenderBox?,
                    ),
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Column A (Left - RIGID STATIC)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(question.pairs.length, (idx) {
                            final originalLeftIdx = _shuffledLeftIndices[idx];
                            final lText = question.pairs[originalLeftIdx].left;
                            final isMatched = quizState.connectMatches.containsKey(originalLeftIdx);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onPanStart: (details) {
                                  if (isMatched) return;
                                  setState(() {
                                    _activeDraggingIdx = originalLeftIdx;
                                    _dragPosition = _getStackPos(details.globalPosition);
                                  });
                                },
                                onPanUpdate: (details) {
                                  if (_activeDraggingIdx == originalLeftIdx) {
                                    setState(() {
                                      _dragPosition = _getStackPos(details.globalPosition);
                                    });
                                  }
                                },
                                onPanEnd: (details) {
                                  if (_activeDraggingIdx == originalLeftIdx) {
                                    _checkConnection(originalLeftIdx);
                                    setState(() {
                                      _activeDraggingIdx = null;
                                      _dragPosition = null;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Expanded(child: _buildMatchCard(
                                      lText, 
                                      isMatched 
                                        ? (quizState.isAnswerChecked ? (quizState.connectMatches[originalLeftIdx] == originalLeftIdx ? kCorrectGreen : Colors.red) : kDarkSlate.withOpacity(0.1)) 
                                        : kPrimaryColor, 
                                      isMatched,
                                      isGrading: quizState.isAnswerChecked
                                    )),
                                    const SizedBox(width: 8),
                                    Container(
                                      key: _leftKeys[originalLeftIdx], 
                                      width: 16, height: 16, 
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle, 
                                        color: isMatched 
                                          ? (quizState.isAnswerChecked ? (quizState.connectMatches[originalLeftIdx] == originalLeftIdx ? kCorrectGreen : Colors.red) : kDarkSlate.withOpacity(0.5))
                                          : Colors.grey.shade300
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Column B (Right - RIGID STATIC)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(question.pairs.length, (idx) {
                            final originalIdx = _shuffledRightIndices[idx];
                            final rText = question.pairs[originalIdx].right;
                            int? matchedLeft;
                            quizState.connectMatches.forEach((l, r) { if(r == originalIdx) matchedLeft = l; });

                            final bool isThisRightCorrect = matchedLeft != null && matchedLeft == originalIdx;
                            final Color rColor = matchedLeft != null 
                              ? (quizState.isAnswerChecked ? (isThisRightCorrect ? kCorrectGreen : Colors.red) : kDarkSlate.withOpacity(0.1)) 
                              : kDarkSlate;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    key: _rightKeys[originalIdx], 
                                    width: 16, height: 16, 
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: (matchedLeft != null) ? (quizState.isAnswerChecked ? (isThisRightCorrect ? kCorrectGreen : Colors.red) : kDarkSlate.withOpacity(0.5)) : Colors.grey.shade300)
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildMatchCard(rText, rColor, matchedLeft != null, isGrading: quizState.isAnswerChecked)),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildBottomFeedback(quizState),
        ],
      ),
    );
  }

  Offset _getStackPos(Offset globalPos) {
    if (_stackKey.currentContext == null) return globalPos;
    final RenderBox box = _stackKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(globalPos);
  }

  void _checkConnection(int leftIdx) {
    if (_dragPosition == null || _stackKey.currentContext == null) return;
    final RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
    for (int rIdx in _shuffledRightIndices) {
      final key = _rightKeys[rIdx];
      if (key?.currentContext == null) continue;
      
      final RenderBox targetBox = key!.currentContext!.findRenderObject() as RenderBox;
      final Offset targetCenterGlobal = targetBox.localToGlobal(Offset(targetBox.size.width / 2, targetBox.size.height / 2));
      final Offset targetCenterLocal = stackBox.globalToLocal(targetCenterGlobal);
      
      // Distance-based snapping
      final double distance = (targetCenterLocal - _dragPosition!).distance;

      if (distance < 50) { 
        // Check if this right-side dot is already taken
        bool isAlreadyTaken = ref.read(quizProvider).connectMatches.containsValue(rIdx);
        if (isAlreadyTaken) return;

        HapticFeedback.mediumImpact();
        ref.read(quizProvider.notifier).selectMatch(leftIdx, rIdx);
        return;
      }
    }
  }

  Widget _buildMatchCard(String text, Color color, bool isMatched, {bool isGrading = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isGrading ? color : (isMatched ? Colors.grey.shade100 : Colors.white), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: color, width: isMatched ? 3 : 1.5)
      ),
      child: Text(
        text, 
        textAlign: TextAlign.center, 
        style: GoogleFonts.outfit(color: isGrading ? Colors.white : kDarkSlate, fontWeight: FontWeight.bold, fontSize: 13)
      ),
    );
  }

  // ==========================================
  // OTHERS (APP BAR, FEEDBACK, ETC)
  // ==========================================

  Widget _buildSwipeMode(Question question, QuizState quizState) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) { setState(() { _dragDelta = Offset.zero; _isSwipeHandled = false; _hoveredIndex = null; }); },
      onPanUpdate: (details) {
        if (quizState.isAnswerChecked || _isSwipeHandled) return;
        setState(() {
          _dragDelta += details.delta;
          final absX = _dragDelta.dx.abs();
          final absY = _dragDelta.dy.abs();
          if (_dragDelta.distance > 20) {
            _hoveredIndex = (absX > absY) ? (_dragDelta.dx > 0 ? 3 : 2) : (_dragDelta.dy > 0 ? 1 : 0);
          }
          if (absX > 100 || absY > 100) {
            if (_hoveredIndex != null && _hoveredIndex! < question.options.length) { _isSwipeHandled = true; _handleSelection(question.options[_hoveredIndex!]); }
          }
        });
      },
      onPanEnd: (_) => setState(() => _dragDelta = Offset.zero),
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 16),
          _buildMascotSpeechHeader(question.text, "Swipe to select!"),
          Expanded(child: Center(child: SizedBox(width: 310, height: 310, child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            _buildStaticSlot(Alignment.topCenter), _buildStaticSlot(Alignment.bottomCenter), _buildStaticSlot(Alignment.centerLeft), _buildStaticSlot(Alignment.centerRight),
            for (int i = 0; i < question.options.length; i++) _buildDirectionalCard(i, question.options[i], _dragDelta, quizState),
          ])))),
          _buildBottomFeedback(quizState),
        ]),
      ),
    );
  }

  Widget _buildPressMode(Question question, QuizState quizState) {
    return SafeArea(
      child: Column(children: [
        const SizedBox(height: 16),
        _buildMascotSpeechHeader(question.text, "Tap your answer!"),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: question.options.map((option) {
          final isSel = quizState.selectedOption == option;
          Color bg = isSel ? (quizState.isAnswerChecked ? (option.isCorrect ? kCorrectGreen : kAmberAccent) : kPrimaryColor) : Colors.white;
          return GestureDetector(onTap: () => _handleSelection(option), child: Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20), width: double.infinity, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSel ? bg : Colors.grey.shade200, width: isSel ? 3 : 1.5)), child: Text(option.text, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isSel ? Colors.white : kDarkSlate))));
        }).toList()))),
        _buildBottomFeedback(quizState),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar(double prog) => AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: kDarkSlate), onPressed: () => Navigator.pop(context)), title: ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(height: 8, width: 180, color: Colors.grey.shade100, child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: prog, child: Container(color: kPrimaryColor)))), centerTitle: true);

  Widget _buildMascotSpeechHeader(String txt, String sub) => Container(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [const Icon(Icons.auto_awesome, size: 50, color: kPrimaryColor), const SizedBox(width: 12), Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade100, width: 2)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(txt, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: kDarkSlate)), Text(sub, style: const TextStyle(color: kPrimaryColor, fontSize: 11, fontWeight: FontWeight.bold))])))]));

  Widget _buildStaticSlot(Alignment ali) => Align(alignment: ali, child: Container(width: 100, height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.grey.shade100))));

  Widget _buildDirectionalCard(int i, AnswerOption opt, Offset d, QuizState s) {
    final isS = s.selectedOption == opt;
    final isH = _hoveredIndex == i && !s.isAnswerChecked;
    Color c = isS ? (s.isAnswerChecked ? (opt.isCorrect ? kCorrectGreen : kAmberAccent) : kPrimaryColor) : Colors.white;
    double t = 105, l = 105;
    if (!isS) { if (i == 0) t = 0; if (i == 1) t = 210; if (i == 2) l = 0; if (i == 3) l = 210; }
    return AnimatedPositioned(left: l, top: t, duration: const Duration(milliseconds: 300), child: AnimatedScale(scale: isS ? 1.6 : (isH ? 1.2 : 1.0), duration: const Duration(milliseconds: 200), child: Opacity(opacity: (s.selectedOption != null && !isS) ? 0.2 : 1.0, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(28), border: Border.all(color: isS ? c : (isH ? kPrimaryColor : Colors.grey.shade200), width: isS ? 4 : 2)), child: Center(child: Text(opt.text, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isS ? Colors.white : kDarkSlate)))))));
  }

  Widget _buildBottomFeedback(QuizState state) {
    if (!state.isAnswerChecked) return const SizedBox(height: 120);
    final correct = state.selectedOption!.isCorrect;
    final color = correct ? kCorrectGreen : kAmberAccent;
    return Container(padding: const EdgeInsets.all(24), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(correct ? Icons.verified : Icons.error, color: color), const SizedBox(width: 8), Text(correct ? "SMASHED IT!" : "NOT QUITE", style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w900, fontSize: 20))]), const SizedBox(height: 16), ElevatedButton(onPressed: () { setState(() { _isSwipeHandled = false; _hoveredIndex = null; _dragDelta = Offset.zero; }); ref.read(quizProvider.notifier).nextQuestion(); }, style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("CONTINUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]));
  }

  Widget _buildResultsScreen(QuizState state) => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.emoji_events, size: 100, color: kAmberAccent), const SizedBox(height: 24), Text("QUIZ COMPLETE!", style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold)), Text("Score: ${state.correctAnswersCount} / ${state.questions.length}", style: const TextStyle(fontSize: 18, color: Colors.grey)), const SizedBox(height: 40), Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: ElevatedButton(onPressed: () => ref.read(quizProvider.notifier).restartQuiz(), style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("PLAY AGAIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), TextButton(onPressed: () => Navigator.pop(context), child: const Text("LOBBY", style: TextStyle(color: kDarkSlate)))])));
}

class _ConnectionPainter extends CustomPainter {
  final Map<int, GlobalKey> leftKeys;
  final Map<int, GlobalKey> rightKeys;
  final Map<int, int> matches;
  final Offset? dragPosition;
  final int? activeDraggingIdx;
  final RenderBox? stackBox;

  _ConnectionPainter({required this.leftKeys, required this.rightKeys, required this.matches, this.dragPosition, this.activeDraggingIdx, this.stackBox});

  @override
  void paint(Canvas canvas, Size size) {
    final correctPaint = Paint()..color = kCorrectGreen..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final wrongPaint = Paint()..color = Colors.red..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final activePaint = Paint()..color = kPrimaryColor.withOpacity(0.6)..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    
    matches.forEach((l, r) {
      final start = _getCenter(leftKeys[l]);
      final end = _getCenter(rightKeys[r]);
      if (start != null && end != null) {
        final bool isMatchCorrect = (l == r);
        // Only show red if the entire set is finished (checked)
        final bool shouldShowGrading = matches.length >= (leftKeys.length);
        final Paint connectionPaint = Paint()
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = shouldShowGrading 
              ? (isMatchCorrect ? kCorrectGreen : Colors.red) 
              : kDarkSlate.withOpacity(0.4);
        
        _drawCurve(canvas, start, end, connectionPaint);
        canvas.drawCircle(start, 5, Paint()..color = connectionPaint.color);
        canvas.drawCircle(end, 6, Paint()..color = connectionPaint.color);
      }
    });

    if (activeDraggingIdx != null && dragPosition != null) {
       final start = _getCenter(leftKeys[activeDraggingIdx!]);
       if (start != null) {
         _drawCurve(canvas, start, dragPosition!, activePaint);
         canvas.drawCircle(start, 6, Paint()..color = kPrimaryColor);
       }
    }
  }

  Offset? _getCenter(GlobalKey? key) {
    if (key == null || key.currentContext == null || stackBox == null) return null;
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    // Get the center of the dot relative to the common Stack ancestor
    final Offset offset = box.localToGlobal(
      Offset(box.size.width / 2, box.size.height / 2),
      ancestor: stackBox,
    );
    return offset;
  }

  void _drawCurve(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path()..moveTo(start.dx, start.dy);
    final cp1 = Offset(start.dx + (end.dx - start.dx).abs() / 2, start.dy);
    final cp2 = Offset(end.dx - (end.dx - start.dx).abs() / 2, end.dy);
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}
