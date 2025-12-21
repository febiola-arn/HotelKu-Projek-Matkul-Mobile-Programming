<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

$hotelId = $_GET['hotel_id'] ?? null;
if (!$hotelId) {
    Response::error('Hotel ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();

    // Total favorites for the hotel
    $stmt = $db->prepare("SELECT COUNT(*) AS count FROM favorites WHERE hotel_id = ?");
    $stmt->execute([$hotelId]);
    $row = $stmt->fetch();
    $count = isset($row['count']) ? (int)$row['count'] : 0;

    // Optionally, add more stats fields later
    $data = [
        'hotel_id' => $hotelId,
        'count' => $count,
    ];

    Response::success($data, 'Favorite stats retrieved successfully');
} catch (Exception $e) {
    Response::serverError('Failed to get favorite stats: ' . $e->getMessage());
}

