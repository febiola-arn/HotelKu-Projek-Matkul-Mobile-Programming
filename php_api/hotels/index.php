<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

try {
    $db = Database::getInstance()->getConnection();
    
    // Get all hotels
    $stmt = $db->query("SELECT * FROM hotels ORDER BY rating DESC");
    $hotels = $stmt->fetchAll();
    
    foreach ($hotels as &$hotel) {
        $hotelId = $hotel['id'];

        // Get Images
        $stmtImg = $db->prepare("SELECT image_url FROM hotel_images WHERE hotel_id = ?");
        $stmtImg->execute([$hotelId]);
        $hotel['images'] = $stmtImg->fetchAll(PDO::FETCH_COLUMN);

        // Get Facilities
        $stmtFac = $db->prepare("SELECT facility FROM hotel_facilities WHERE hotel_id = ?");
        $stmtFac->execute([$hotelId]);
        $hotel['facilities'] = $stmtFac->fetchAll(PDO::FETCH_COLUMN);

        // Get Room Types
        $stmtRoom = $db->prepare("SELECT type, price, capacity FROM room_types WHERE hotel_id = ?");
        $stmtRoom->execute([$hotelId]);
        $hotel['room_types'] = $stmtRoom->fetchAll(PDO::FETCH_ASSOC);

        // Cast types
        $hotel['rating'] = (float) $hotel['rating'];
        $hotel['price_per_night'] = (float) $hotel['price_per_night'];
        $hotel['rooms_available'] = (int) $hotel['rooms_available'];
    }
    
    Response::success($hotels, 'Hotels retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get hotels: ' . $e->getMessage());
}
