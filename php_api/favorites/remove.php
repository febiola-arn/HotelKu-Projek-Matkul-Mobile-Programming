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
    
    // Delete from favorites
    $stmt = $db->prepare("DELETE FROM favorites WHERE user_id = ? AND hotel_id = ?");
    $stmt->execute([$userId, $hotelId]);
    
    if ($stmt->rowCount() === 0) {
        Response::notFound('Favorite tidak ditemukan');
    }
    
    Response::success(null, 'Berhasil dihapus dari favorites');
    
} catch (Exception $e) {
    Response::serverError('Gagal menghapus favorite: ' . $e->getMessage());
}
