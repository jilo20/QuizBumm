import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_models.dart';

class QuizState {
  final int currentQuestionIndex;
  final AnswerOption? selectedOption;
  final bool isAnswerChecked;
  final int correctAnswersCount;
  final bool isQuizFinished;

  QuizState({
    this.currentQuestionIndex = 0,
    this.selectedOption,
    this.isAnswerChecked = false,
    this.correctAnswersCount = 0,
    this.isQuizFinished = false,
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    AnswerOption? selectedOption,
    bool clearSelectedOption = false,
    bool? isAnswerChecked,
    int? correctAnswersCount,
    bool? isQuizFinished,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOption: clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
      isQuizFinished: isQuizFinished ?? this.isQuizFinished,
    );
  }

  double get progress => (currentQuestionIndex + 1) / mockQuestions.length;
}

class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() {
    return QuizState();
  }

  void selectOption(AnswerOption option) {
    if (!state.isAnswerChecked) {
      state = state.copyWith(selectedOption: option);
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
    if (state.currentQuestionIndex < mockQuestions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        clearSelectedOption: true,
        isAnswerChecked: false,
      );
    } else {
      state = state.copyWith(isQuizFinished: true);
    }
  }

  void restartQuiz() {
    state = QuizState();
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);
