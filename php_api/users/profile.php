<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Get user ID from query
$id = $_GET['id'] ?? null;

if (!$id) {
    Response::error('User ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    $stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
    $stmt->execute([$id]);
    $user = $stmt->fetch();
    
    if (!$user) {
        Response::notFound('User tidak ditemukan');
    }
    
    // Remove password from response
    unset($user['password']);
    
    Response::success($user, 'Profile retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get profile: ' . $e->getMessage());
}
