class Quiz {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Quiz',
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
    );
  }
}

class Question {
  final int id;
  final String text;
  final List<AnswerOption> options;
  final String mode;
  final List<MatchPair> pairs;

  Question({
    required this.id,
    required this.text,
    required this.options,
    this.mode = 'swipe',
    this.pairs = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List<dynamic>? ?? [];
    int correctIndex = json['correctIndex'] ?? 0;
    
    List<AnswerOption> parsedOptions = [];
    for (int i = 0; i < rawOptions.length; i++) {
      parsedOptions.add(AnswerOption(
        id: i,
        text: rawOptions[i].toString(),
        isCorrect: i == correctIndex,
      ));
    }

    List<MatchPair> parsedPairs = (json['pairs'] as List<dynamic>?)
            ?.map((p) => MatchPair.fromJson(p))
            .toList() ??
        [];

    return Question(
      id: 0,
      text: json['question'] ?? 'No question text',
      options: parsedOptions,
      mode: json['mode'] ?? 'swipe',
      pairs: parsedPairs,
    );
  }
}

class MatchPair {
  final String left;
  final String right;

  MatchPair({required this.left, required this.right});

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    return MatchPair(
      left: json['left'] ?? '',
      right: json['right'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'left': left,
    'right': right,
  };
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
