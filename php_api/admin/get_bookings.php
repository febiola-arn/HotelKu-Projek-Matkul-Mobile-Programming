<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

$userId = $_GET['user_id'] ?? null;
if (!$userId) Response::error('User ID is required', 400);

try {
    $db = Database::getInstance()->getConnection();
    
    // Get hotel ID owned by user
    $stmt = $db->prepare("SELECT id FROM hotels WHERE owner_id = ?");
    $stmt->execute([$userId]);
    $hotel = $stmt->fetch();
    
    if (!$hotel) {
        Response::error('Hotel not found for this user', 404);
    }
    
    $hotelId = $hotel['id'];
    
    // Get bookings for this hotel
    $stmt = $db->prepare("
        SELECT * FROM bookings 
        WHERE hotel_id = ? 
        ORDER BY booking_date DESC
    ");
    $stmt->execute([$hotelId]);
    $bookings = $stmt->fetchAll();
    
    // Process types
    foreach ($bookings as &$booking) {
         $booking['total_nights'] = (int) $booking['total_nights'];
         $booking['total_price'] = (float) $booking['total_price'];
    }
    
    Response::success($bookings, 'Bookings retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get bookings: ' . $e->getMessage());
}
