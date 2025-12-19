<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

$query = $_GET['q'] ?? '';
$city = $_GET['city'] ?? '';

try {
    $db = Database::getInstance()->getConnection();
    
    $sql = "SELECT * FROM hotels WHERE 1=1";
    $params = [];
    
    // Search by name or description
    if (!empty($query)) {
        $sql .= " AND (name LIKE ? OR description LIKE ? OR address LIKE ?)";
        $searchTerm = "%{$query}%";
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $params[] = $searchTerm;
    }
    
    // Filter by city
    if (!empty($city)) {
        $sql .= " AND city LIKE ?";
        $params[] = "%{$city}%";
    }
    
    $sql .= " ORDER BY rating DESC";
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $hotels = $stmt->fetchAll();
    
    // Parse JSON fields for each hotel
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
    
    Response::success($hotels, 'Search results retrieved successfully');
    
} catch (Exception $e) {
    Response::serverError('Failed to search hotels: ' . $e->getMessage());
}
