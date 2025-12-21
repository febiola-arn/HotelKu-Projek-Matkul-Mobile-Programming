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

        // Get Room Types with Inventory Stats
        $stmtRoom = $db->prepare("SELECT type, price, capacity, total_rooms FROM room_types WHERE hotel_id = ?");
        $stmtRoom->execute([$hotelId]);
        $roomTypes = $stmtRoom->fetchAll(PDO::FETCH_ASSOC);

        foreach ($roomTypes as &$room) {
            $stmtBooked = $db->prepare("
                SELECT COUNT(*) 
                FROM bookings 
                WHERE hotel_id = ? 
                AND room_type = ? 
                AND status IN ('Confirmed', 'Pending')
            ");
            $stmtBooked->execute([$hotelId, $room['type']]);
            $room['booked_count'] = (int) $stmtBooked->fetchColumn();
            $room['available_count'] = (int) $room['total_rooms'] - $room['booked_count'];
            
            // Ensure values are numbers
            $room['price'] = (float) $room['price'];
            $room['capacity'] = (int) $room['capacity'];
            $room['total_rooms'] = (int) $room['total_rooms'];
        }
        unset($room);
        $hotel['room_types'] = $roomTypes;

        // Cast types
        $hotel['rating'] = (float) $hotel['rating'];
        $hotel['price_per_night'] = (float) $hotel['price_per_night'];
        $hotel['rooms_available'] = (int) $hotel['rooms_available'];
    }
    
    Response::success($hotels, 'Hotels retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get hotels: ' . $e->getMessage());
}
