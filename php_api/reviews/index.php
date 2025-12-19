<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

$hotelId = $_GET['hotel_id'] ?? null;

if (!$hotelId) {
    Response::error('Hotel ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    $stmt = $db->prepare("
        SELECT * FROM reviews 
        WHERE hotel_id = ? 
        ORDER BY date DESC
    ");
    $stmt->execute([$hotelId]);
    $reviews = $stmt->fetchAll();
    
    // Convert rating to float
    foreach ($reviews as &$review) {
        $review['rating'] = (float) $review['rating'];
    }
    
    Response::success($reviews, 'Reviews retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get reviews: ' . $e->getMessage());
}
