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
$name = trim($input['name'] ?? '');
$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';
$phone = trim($input['phone'] ?? '');
$avatar = $input['avatar'] ?? 'https://i.pravatar.cc/150?img=' . rand(1, 70);

// Validate input
if (empty($name)) {
    Response::error('Nama harus diisi', 400);
}
if (empty($email)) {
    Response::error('Email harus diisi', 400);
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    Response::error('Format email tidak valid', 400);
}
if (empty($password)) {
    Response::error('Password harus diisi', 400);
}
if (strlen($password) < 6) {
    Response::error('Password minimal 6 karakter', 400);
}
if (empty($phone)) {
    Response::error('Nomor telepon harus diisi', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Check if email already exists
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        Response::error('Email sudah terdaftar', 400);
    }
    
    // Generate UUID
    $userId = uniqid('user_', true);

$role = $input['role'] ?? 'customer';
    $validRoles = ['customer', 'hotel_admin'];
    if (!in_array($role, $validRoles)) {
        $role = 'customer';
    }

    // Insert new user
    $stmt = $db->prepare("
        INSERT INTO users (id, name, email, password, phone, avatar, role, created_at) 
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
    ");
    $stmt->execute([$userId, $name, $email, $password, $phone, $avatar, $role]);
    
    // Get the new user data
    $stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    // Remove password from response
    unset($user['password']);
    
    Response::created($user, 'Registrasi berhasil');
    
} catch (Exception $e) {
    Response::serverError('Registrasi gagal: ' . $e->getMessage());
}
