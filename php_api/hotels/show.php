<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Validate ID parameter
$id = $_GET['id'] ?? null;
if (!$id) {
    Response::error('Hotel ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    $stmt = $db->prepare("SELECT * FROM hotels WHERE id = ?");
    $stmt->execute([$id]);
    $hotel = $stmt->fetch();
    
    if (!$hotel) {
        Response::notFound('Hotel not found');
    }
    
    // Get Images
    $stmtImg = $db->prepare("SELECT image_url FROM hotel_images WHERE hotel_id = ?");
    $stmtImg->execute([$id]);
    $hotel['images'] = $stmtImg->fetchAll(PDO::FETCH_COLUMN);

    // Get Facilities
    $stmtFac = $db->prepare("SELECT facility FROM hotel_facilities WHERE hotel_id = ?");
    $stmtFac->execute([$id]);
    $hotel['facilities'] = $stmtFac->fetchAll(PDO::FETCH_COLUMN);

    // Get Room Types
    $stmtRoom = $db->prepare("SELECT type, price, capacity FROM room_types WHERE hotel_id = ?");
    $stmtRoom->execute([$id]);
    $hotel['room_types'] = $stmtRoom->fetchAll(PDO::FETCH_ASSOC);

    // Cast types
    $hotel['rating'] = (float) $hotel['rating'];
    $hotel['price_per_night'] = (float) $hotel['price_per_night'];
    $hotel['rooms_available'] = (int) $hotel['rooms_available'];
    
    Response::success($hotel, 'Hotel retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get hotel: ' . $e->getMessage());
}
