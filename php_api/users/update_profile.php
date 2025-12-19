<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::methodNotAllowed();
}

// Get raw POST data
$input = json_decode(file_get_contents('php://input'), true);

$id = $input['id'] ?? null;
$name = $input['name'] ?? null;
$phone = $input['phone'] ?? null;
$avatar = $input['avatar'] ?? null;

if (!$id) {
    Response::error('User ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Check if user exists
    $stmt = $db->prepare("SELECT id FROM users WHERE id = ?");
    $stmt->execute([$id]);
    if (!$stmt->fetch()) {
        Response::notFound('User tidak ditemukan');
    }

    // Build update query dynamically
    $fields = [];
    $params = [];

    if ($name !== null) {
        $fields[] = "name = ?";
        $params[] = $name;
    }

    if ($phone !== null) {
        $fields[] = "phone = ?";
        $params[] = $phone;
    }

    if ($avatar !== null) {
        $fields[] = "avatar = ?";
        $params[] = $avatar;
    }

    if (empty($fields)) {
        Response::error('No fields to update', 400);
    }

    $params[] = $id;
    $query = "UPDATE users SET " . implode(', ', $fields) . " WHERE id = ?";
    
    $stmt = $db->prepare($query);
    $stmt->execute($params);

    // Fetch updated user
    $stmt = $db->prepare("SELECT id, name, email, phone, avatar, role, created_at FROM users WHERE id = ?");
    $stmt->execute([$id]);
    $updatedUser = $stmt->fetch();

    Response::success($updatedUser, 'Profile updated successfully');

} catch (Exception $e) {
    Response::serverError('Failed to update profile: ' . $e->getMessage());
}
