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
$price = $input['price_per_night'] ?? null;
$roomsAvailable = $input['rooms_available'] ?? null;

if (!$userId || !$hotelId) {
    Response::error('User ID and Hotel ID are required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Verify ownership
    $stmt = $db->prepare("SELECT id FROM hotels WHERE id = ? AND owner_id = ?");
    $stmt->execute([$hotelId, $userId]);
    if (!$stmt->fetch()) {
        Response::unauthorized('You do not own this hotel');
    }
    
    // Build update query dynamically
    $fields = [];
    $params = [];
    
    if ($name) { $fields[] = "name = ?"; $params[] = $name; }
    if ($description) { $fields[] = "description = ?"; $params[] = $description; }
    if ($price) { $fields[] = "price_per_night = ?"; $params[] = $price; }
    if ($roomsAvailable) { $fields[] = "rooms_available = ?"; $params[] = $roomsAvailable; }
    
    if (empty($fields)) {
        Response::error('No fields to update', 400);
    }
    
    $params[] = $hotelId;
    
    $sql = "UPDATE hotels SET " . implode(', ', $fields) . " WHERE id = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    
    Response::success(null, 'Hotel updated successfully');
    
} catch (Exception $e) {
    Response::serverError('Update failed: ' . $e->getMessage());
}
