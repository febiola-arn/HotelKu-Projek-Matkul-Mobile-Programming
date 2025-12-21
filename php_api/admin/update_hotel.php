<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$input = json_decode(file_get_contents('php://input'), true);

$userId = $input['user_id'] ?? null;
$hotelId = $input['hotel_id'] ?? null;

// Basic hotel info to update
$name = $input['name'] ?? null;
$description = $input['description'] ?? null;
$address = $input['address'] ?? null;
$city = $input['city'] ?? null;
$roomTypes = $input['room_types'] ?? null;
$facilities = $input['facilities'] ?? null;

if (!$userId || !$hotelId) {
    Response::error('User ID and Hotel ID are required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Begin transaction
    $db->beginTransaction();
    
    // Verify ownership
    $stmt = $db->prepare("SELECT id FROM hotels WHERE id = ? AND owner_id = ?");
    $stmt->execute([$hotelId, $userId]);
    if (!$stmt->fetch()) {
        $db->rollBack();
        Response::unauthorized('You do not own this hotel');
    }
    
    // Build update query dynamically for hotels table
    $fields = [];
    $params = [];
    
    if (!is_null($name)) { $fields[] = "name = ?"; $params[] = $name; }
    if (!is_null($description)) { $fields[] = "description = ?"; $params[] = $description; }
    if (!is_null($address)) { $fields[] = "address = ?"; $params[] = $address; }
    if (!is_null($city)) { $fields[] = "city = ?"; $params[] = $city; }
    
    if (!empty($fields)) {
        $params[] = $hotelId;
        $sql = "UPDATE hotels SET " . implode(', ', $fields) . " WHERE id = ?";
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
    }
    
    // Update Room Types if provided
    if (!is_null($roomTypes) && is_array($roomTypes)) {
        foreach ($roomTypes as $room) {
            $type = $room['type'] ?? null;
            $roomPrice = $room['price'] ?? null;
            $capacity = $room['capacity'] ?? null;
            $totalRooms = $room['total_rooms'] ?? null; // New field
            
            if ($type !== null) {
                // Update room_types
                $stmtRoom = $db->prepare("UPDATE room_types SET price = ?, capacity = ?, total_rooms = ? WHERE hotel_id = ? AND type = ?");
                $stmtRoom->execute([$roomPrice, $capacity, $totalRooms, $hotelId, $type]);
            }
        }
    }

    // Update Facilities if provided (replace-all strategy)
    if (!is_null($facilities) && is_array($facilities)) {
        // Delete existing facilities
        $stmtDel = $db->prepare("DELETE FROM hotel_facilities WHERE hotel_id = ?");
        $stmtDel->execute([$hotelId]);

        // Insert new facilities (skip empty strings)
        $stmtIns = $db->prepare("INSERT INTO hotel_facilities (hotel_id, facility) VALUES (?, ?)");
        foreach ($facilities as $fac) {
            $facStr = trim((string)$fac);
            if ($facStr === '') continue;
            $stmtIns->execute([$hotelId, $facStr]);
        }
    }

    // Auto-sync hotels.price_per_night based on minimum room_types.price
    $stmtMin = $db->prepare("SELECT MIN(price) as min_price FROM room_types WHERE hotel_id = ?");
    $stmtMin->execute([$hotelId]);
    $minPrice = $stmtMin->fetchColumn();

    if ($minPrice !== false) {
        $stmtSync = $db->prepare("UPDATE hotels SET price_per_night = ? WHERE id = ?");
        $stmtSync->execute([$minPrice, $hotelId]);
    }

    // Auto-sync hotels.rooms_available based on sum of room_types.total_rooms - bookings
    // Actually, for simplicity, let's just sum room_types.total_rooms for now as "Max Rooms"
    // The "Available" logic is handled dynamically in get_my_hotel.php dashboard
    $stmtSum = $db->prepare("SELECT SUM(total_rooms) as total FROM room_types WHERE hotel_id = ?");
    $stmtSum->execute([$hotelId]);
    $totalRoomsSum = $stmtSum->fetchColumn();

    if ($totalRoomsSum !== false) {
        $stmtSyncRooms = $db->prepare("UPDATE hotels SET rooms_available = ? WHERE id = ?");
        $stmtSyncRooms->execute([(int)$totalRoomsSum, $hotelId]);
    }
    
    $db->commit();
    Response::success(null, 'Hotel and room types inventory updated successfully');
    
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    Response::serverError('Update failed: ' . $e->getMessage());
}
