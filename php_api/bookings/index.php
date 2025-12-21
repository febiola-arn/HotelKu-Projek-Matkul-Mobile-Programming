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
    
    $stmt = $db->prepare("
        SELECT * FROM bookings 
        WHERE user_id = ? 
        ORDER BY booking_date DESC
    ");
    $stmt->execute([$userId]);
    $bookings = $stmt->fetchAll();
    
    // Convert numeric fields
    foreach ($bookings as &$booking) {
        $booking['total_nights'] = (int) $booking['total_nights'];
        $booking['total_price'] = (float) $booking['total_price'];
    }
    
    Response::success($bookings, 'Bookings retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get bookings: ' . $e->getMessage());
}
