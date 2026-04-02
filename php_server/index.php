<?php
$dataFile = __DIR__ . '/data/quizzes.json';
$quizzes = [];
if (file_exists($dataFile)) {
    $quizzes = json_decode(file_get_contents($dataFile), true) ?? [];
}
// Sort newest first
usort($quizzes, function($a, $b) {
    return strtotime($b['created_at']) - strtotime($a['created_at']);
});
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QuizBumm Server Admin</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 20px; color: #1e293b; }
        .container { max-width: 800px; margin: 0 auto; }
        h1 { color: #2563eb; }
        .quiz-card { background: white; border-radius: 8px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .quiz-header { display: flex; justify-content: space-between; align-items: baseline; }
        .quiz-title { font-size: 20px; font-weight: bold; margin: 0 0 10px 0; }
        .quiz-meta { color: #64748b; font-size: 14px; margin-bottom: 15px; }
        .question-list { margin: 0; padding-left: 20px; }
        .question-item { margin-bottom: 15px; }
        .empty-state { text-align: center; padding: 40px; color: #64748b; background: white; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>QuizBumm Server Dashboard</h1>
        <p>This is your management panel. Here you can view incoming quizzes sent from the app.</p>
        
        <?php if (empty($quizzes)): ?>
            <div class="empty-state">
                No quizzes have been created yet. Open your Flutter app and build one!
            </div>
        <?php else: ?>
            <?php foreach ($quizzes as $quiz): ?>
                <div class="quiz-card">
                    <div class="quiz-header">
                        <h2 class="quiz-title"><?php echo htmlspecialchars($quiz['title']); ?></h2>
                        <span class="quiz-meta"><?php echo date('M j, Y g:i A', strtotime($quiz['created_at'])); ?></span>
                    </div>
                    <div class="quiz-meta">
                        ID: <?php echo $quiz['id']; ?> | 
                        Questions: <?php echo count($quiz['questions']); ?>
                    </div>
                    <?php if (!empty($quiz['description'])): ?>
                        <p><strong>Description:</strong> <?php echo nl2br(htmlspecialchars($quiz['description'])); ?></p>
                    <?php endif; ?>
                    
                    <h3>Questions:</h3>
                    <ul class="question-list">
                        <?php foreach ($quiz['questions'] as $i => $q): ?>
                            <li class="question-item">
                                <strong>
                                    <?php echo htmlspecialchars($q['question']); ?>
                                    <span style="font-size: 11px; padding: 2px 6px; background: #eee; border-radius: 4px; margin-left: 8px;">
                                        <?php echo strtoupper($q['mode'] ?? 'swipe'); ?> MODE
                                    </span>
                                </strong>
                                
                                <ul style="margin-top: 5px;">
                                    <?php if (($q['mode'] ?? '') === 'connect'): ?>
                                        <?php foreach(($q['pairs'] ?? []) as $pair): ?>
                                            <li style="list-style: none; font-size: 13px; color: #475569;">
                                                <span style="display:inline-block; width:100px;"><?php echo htmlspecialchars($pair['left']); ?></span>
                                                <span style="color:#2563eb;">⇠ connects to ⇢</span>
                                                <span><?php echo htmlspecialchars($pair['right']); ?></span>
                                            </li>
                                        <?php endforeach; ?>
                                    <?php else: ?>
                                        <?php foreach ($q['options'] as $j => $opt): ?>
                                            <li <?php echo ($q['correctIndex'] == $j) ? 'style="color: #16a34a; font-weight: bold;"' : ''; ?>>
                                                <?php echo htmlspecialchars($opt); ?>
                                                <?php if ($q['correctIndex'] == $j) echo ' ✓'; ?>
                                            </li>
                                        <?php endforeach; ?>
                                    <?php endif; ?>
                                </ul>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
</body>
</html>
