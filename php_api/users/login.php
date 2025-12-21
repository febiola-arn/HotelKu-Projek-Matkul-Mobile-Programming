<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

// Get POST data
$input = json_decode(file_get_contents('php://input'), true);
$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';

// Validate input
if (empty($email) || empty($password)) {
    Response::error('Email dan password harus diisi', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Find user by email
    $stmt = $db->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user) {
        Response::error('Email tidak terdaftar', 401);
    }
    
    // Verify password (plain text comparison for now, can use password_verify later)
    if ($user['password'] !== $password) {
        Response::error('Password salah', 401);
    }
    
    // Remove password from response
    unset($user['password']);
    
    Response::success($user, 'Login berhasil');
    
} catch (Exception $e) {
    Response::serverError('Login gagal: ' . $e->getMessage());
}
