class Question {
  final int id;
  final String text;
  final List<AnswerOption> options;

  Question({
    required this.id,
    required this.text,
    required this.options,
  });
}

class AnswerOption {
  final int id;
  final String text;
  final bool isCorrect;

  AnswerOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}

final mockQuestions = [
  Question(
    id: 1,
    text: "Which Flutter widget is used for laying out children in a vertical array?",
    options: [
      AnswerOption(id: 1, text: "Row", isCorrect: false),
      AnswerOption(id: 2, text: "Stack", isCorrect: false),
      AnswerOption(id: 3, text: "Column", isCorrect: true),
      AnswerOption(id: 4, text: "ListView", isCorrect: false),
    ],
  ),
  Question(
    id: 2,
    text: "What command is used to create a new Flutter project?",
    options: [
      AnswerOption(id: 5, text: "flutter build", isCorrect: false),
      AnswerOption(id: 6, text: "flutter create", isCorrect: true),
      AnswerOption(id: 7, text: "flutter init", isCorrect: false),
      AnswerOption(id: 8, text: "flutter start", isCorrect: false),
    ],
  ),
  Question(
    id: 3,
    text: "Which programming language is used to develop Flutter apps?",
    options: [
      AnswerOption(id: 9, text: "Kotlin", isCorrect: false),
      AnswerOption(id: 10, text: "Swift", isCorrect: false),
      AnswerOption(id: 11, text: "Dart", isCorrect: true),
      AnswerOption(id: 12, text: "Javascript", isCorrect: false),
    ],
  ),
];
