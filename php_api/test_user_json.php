<?php
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/core/Response.php';

try {
    $db = Database::getInstance()->getConnection();
    
    // Get the first user
    $stmt = $db->query("SELECT * FROM users LIMIT 1");
    $user = $stmt->fetch();
    
    if ($user) {
        // Simulate what login.php does
        unset($user['password']);
        echo "Raw User Array:\n";
        print_r($user);
        echo "\nJSON Output:\n";
        echo json_encode($user);
    } else {
        echo "No users found in database.";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
