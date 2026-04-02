import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_models.dart';

final fetchedQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  const String apiUrl = 'http://127.0.0.1:8000/api.php';
  final res = await http.get(Uri.parse(apiUrl));
  if (res.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(res.body);
    return jsonList.map((q) => Quiz.fromJson(q)).toList();
  }
  return [];
});

class QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final AnswerOption? selectedOption;
  final bool isAnswerChecked;
  final int correctAnswersCount;
  final bool isQuizFinished;
  final Map<int, int> connectMatches; // leftIndex -> rightIndex

  QuizState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedOption,
    this.isAnswerChecked = false,
    this.correctAnswersCount = 0,
    this.isQuizFinished = false,
    this.connectMatches = const {},
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    AnswerOption? selectedOption,
    bool clearSelectedOption = false,
    bool? isAnswerChecked,
    int? correctAnswersCount,
    bool? isQuizFinished,
    Map<int, int>? connectMatches,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOption: clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
      isQuizFinished: isQuizFinished ?? this.isQuizFinished,
      connectMatches: connectMatches ?? this.connectMatches,
    );
  }

  double get progress => questions.isEmpty ? 0 : (currentQuestionIndex + 1) / questions.length;
}

class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() {
    return QuizState();
  }

  void initQuiz(List<Question> questions) {
    Future.microtask(() {
      state = QuizState(questions: questions);
    });
  }

  void selectOption(AnswerOption option) {
    if (!state.isAnswerChecked) {
      state = state.copyWith(selectedOption: option);
    }
  }

  void selectMatch(int leftIndex, int rightIndex) {
    if (state.isAnswerChecked) return;
    
    final newMatches = Map<int, int>.from(state.connectMatches);
    newMatches[leftIndex] = rightIndex;
    
    final question = state.questions[state.currentQuestionIndex];
    state = state.copyWith(connectMatches: newMatches);

    // Auto-check once all items are matched on the screen
    if (newMatches.length >= question.pairs.length && question.pairs.isNotEmpty) {
      int score = 0;
      newMatches.forEach((l, r) {
        if (l == r) score++;
      });
      
      bool allCorrect = score == question.pairs.length;
      state = state.copyWith(
        isAnswerChecked: true,
        correctAnswersCount: allCorrect ? state.correctAnswersCount + 1 : state.correctAnswersCount,
        selectedOption: AnswerOption(id: 0, text: "Result", isCorrect: allCorrect), 
      );
    }
  }

  void checkAnswer() {
    if (state.selectedOption != null) {
      final isCorrect = state.selectedOption!.isCorrect;
      state = state.copyWith(
        isAnswerChecked: true,
        correctAnswersCount: isCorrect ? state.correctAnswersCount + 1 : state.correctAnswersCount,
      );
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        clearSelectedOption: true,
        isAnswerChecked: false,
        connectMatches: {},
      );
    } else {
      state = state.copyWith(isQuizFinished: true);
    }
  }

  void restartQuiz() {
    state = QuizState(questions: state.questions);
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);
