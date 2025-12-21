<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Check Method
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

// Get user_id from query (In production this should be from Token)
$userId = $_GET['user_id'] ?? null;

if (!$userId) {
    Response::error('User ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Find hotel owned by this user
    $stmt = $db->prepare("SELECT * FROM hotels WHERE owner_id = ?");
    $stmt->execute([$userId]);
    $hotel = $stmt->fetch();
    
    if (!$hotel) {
        // Return 200 with null data properly so frontend can show "Create Hotel" UI
        Response::success(null, 'Belum memiliki hotel');
    }
    
    // Get additional data (images, facilities, room types)
    $hotelId = $hotel['id'];

    // Get Images
    $stmtImg = $db->prepare("SELECT image_url FROM hotel_images WHERE hotel_id = ?");
    $stmtImg->execute([$hotelId]);
    $hotel['images'] = $stmtImg->fetchAll(PDO::FETCH_COLUMN);

    // Get Facilities
    $stmtFac = $db->prepare("SELECT facility FROM hotel_facilities WHERE hotel_id = ?");
    $stmtFac->execute([$hotelId]);
    $hotel['facilities'] = $stmtFac->fetchAll(PDO::FETCH_COLUMN);

    // Get Room Types with Total Rooms
    $stmtRoom = $db->prepare("SELECT type, price, capacity, total_rooms FROM room_types WHERE hotel_id = ?");
    $stmtRoom->execute([$hotelId]);
    $roomTypes = $stmtRoom->fetchAll(PDO::FETCH_ASSOC);

    // For each room type, count active bookings
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
    
    Response::success($hotel, 'Hotel retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to get hotel: ' . $e->getMessage());
}
