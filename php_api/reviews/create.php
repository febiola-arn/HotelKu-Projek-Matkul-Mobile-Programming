<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$input = json_decode(file_get_contents('php://input'), true);

$hotelId = $input['hotel_id'] ?? null;
$userId = $input['user_id'] ?? null;
$userName = $input['user_name'] ?? '';
$userAvatar = $input['user_avatar'] ?? '';
$rating = $input['rating'] ?? 0;
$comment = trim($input['comment'] ?? '');

// Validate
if (!$hotelId) Response::error('Hotel ID is required', 400);
if (!$userId) Response::error('User ID is required', 400);
if (empty($comment)) Response::error('Komentar harus diisi', 400);
if ($rating < 1 || $rating > 5) Response::error('Rating harus 1-5', 400);

try {
    $db = Database::getInstance()->getConnection();
    
    // Insert review
    $stmt = $db->prepare("
        INSERT INTO reviews (hotel_id, user_id, user_name, user_avatar, rating, comment, date) 
        VALUES (?, ?, ?, ?, ?, ?, NOW())
    ");
    $stmt->execute([$hotelId, $userId, $userName, $userAvatar, $rating, $comment]);
    
    $reviewId = $db->lastInsertId();
    
    // Get the new review
    $stmt = $db->prepare("SELECT * FROM reviews WHERE id = ?");
    $stmt->execute([$reviewId]);
    $review = $stmt->fetch();
    
    $review['rating'] = (float) $review['rating'];
    
    // Update hotel rating average
    $stmt = $db->prepare("
        UPDATE hotels SET rating = (
            SELECT AVG(rating) FROM reviews WHERE hotel_id = ?
        ) WHERE id = ?
    ");
    $stmt->execute([$hotelId, $hotelId]);
    
    Response::created($review, 'Review berhasil ditambahkan');
    
} catch (Exception $e) {
    Response::serverError('Gagal menambahkan review: ' . $e->getMessage());
}
