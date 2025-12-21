<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

$hotelId = $_GET['hotel_id'] ?? null;
if (!$hotelId) {
    Response::error('Hotel ID is required', 400);
}

try {
    $db = Database::getInstance()->getConnection();
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM favorites WHERE hotel_id = ?");
    $stmt->execute([$hotelId]);
    $row = $stmt->fetch();
    $count = isset($row['count']) ? (int)$row['count'] : 0;
    Response::success(['count' => $count], 'Favorite count retrieved successfully');
} catch (Exception $e) {
    Response::serverError('Failed to get favorite count: ' . $e->getMessage());
}
