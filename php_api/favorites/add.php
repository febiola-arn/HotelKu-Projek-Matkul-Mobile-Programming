<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$raw = file_get_contents('php://input');
$input = json_decode($raw, true);
if (!is_array($input)) { $input = $_POST; }

$userId = $input['user_id'] ?? ($_GET['user_id'] ?? null);
$hotelId = $input['hotel_id'] ?? ($_GET['hotel_id'] ?? null);

if (!$userId) Response::error('User ID is required', 400);
if (!$hotelId) Response::error('Hotel ID is required', 400);

try {
    $db = Database::getInstance()->getConnection();
    
    // Check if already favorited
    $stmt = $db->prepare("SELECT id FROM favorites WHERE user_id = ? AND hotel_id = ?");
    $stmt->execute([$userId, $hotelId]);
    if ($stmt->fetch()) {
        Response::error('Hotel sudah ada di favorites', 400);
    }
    
    // Generate unique ID for favorites.id (table uses VARCHAR PK, not auto-increment)
    $favoriteId = 'fav_' . str_replace('.', '', uniqid('', true));
    
    // Add to favorites with explicit id to avoid duplicate primary key on empty id
    $stmt = $db->prepare("
        INSERT INTO favorites (id, user_id, hotel_id, added_at) 
        VALUES (?, ?, ?, NOW())
    ");
    $stmt->execute([$favoriteId, $userId, $hotelId]);
    
    Response::created([
        'id' => $favoriteId,
        'user_id' => $userId,
        'hotel_id' => $hotelId
    ], 'Berhasil ditambahkan ke favorites');
    
} catch (Exception $e) {
    Response::serverError('Gagal menambahkan favorite: ' . $e->getMessage());
}
