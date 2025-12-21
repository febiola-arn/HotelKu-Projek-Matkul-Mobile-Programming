<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

$userId = $_GET['user_id'] ?? null;

if (!$userId) {
    Response::error('User ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Get favorites with hotel data
    $stmt = $db->prepare("
        SELECT f.*, h.name as hotel_name, h.city, h.rating, h.price_per_night, h.images
        FROM favorites f
        LEFT JOIN hotels h ON f.hotel_id = h.id
        WHERE f.user_id = ?
        ORDER BY f.added_at DESC
    ");
    $stmt->execute([$userId]);
    $favorites = $stmt->fetchAll();
    
    // Parse hotel data
    foreach ($favorites as &$fav) {
        $fav['rating'] = (float) ($fav['rating'] ?? 0);
        $fav['price_per_night'] = (float) ($fav['price_per_night'] ?? 0);
        $fav['images'] = json_decode($fav['images'] ?? '[]', true) ?: [];
    }
    
    Response::success($favorites, 'Favorites retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get favorites: ' . $e->getMessage());
}
