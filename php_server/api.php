<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$dataFile = __DIR__ . '/data/quizzes.json';

// Initialize data file if it doesn't exist
if (!file_exists(__DIR__ . '/data')) {
    mkdir(__DIR__ . '/data', 0777, true);
}
if (!file_exists($dataFile)) {
    file_put_contents($dataFile, json_encode([]));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if ($data) {
        $quizzes = json_decode(file_get_contents($dataFile), true);
        $data['id'] = uniqid('quiz_');
        $data['created_at'] = date('c');
        $quizzes[] = $data;
        
        file_put_contents($dataFile, json_encode($quizzes, JSON_PRETTY_PRINT));
        
        echo json_encode(["status" => "success", "message" => "Quiz received", "id" => $data['id']]);
    } else {
        http_response_code(400);
        echo json_encode(["status" => "error", "message" => "Invalid JSON data"]);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Return all quizzes
    echo file_get_contents($dataFile);
}
?>
