<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

// Get POST data
$input = json_decode(file_get_contents('php://input'), true);

$bookingId = $input['booking_id'] ?? null;
$status = $input['status'] ?? null;

// Validate
if (!$bookingId) {
    Response::error('Booking ID is required', 400);
}
if (!$status) {
    Response::error('Status is required', 400);
}

// Valid statuses
$validStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];
if (!in_array($status, $validStatuses)) {
    Response::error('Invalid status. Valid: ' . implode(', ', $validStatuses), 400);
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Check if booking exists
    $stmt = $db->prepare("SELECT id FROM bookings WHERE id = ?");
    $stmt->execute([$bookingId]);
    if (!$stmt->fetch()) {
        Response::notFound('Booking tidak ditemukan');
    }
    
    // Update status
    $stmt = $db->prepare("UPDATE bookings SET status = ? WHERE id = ?");
    $stmt->execute([$status, $bookingId]);
    
    // Get updated booking
    $stmt = $db->prepare("SELECT * FROM bookings WHERE id = ?");
    $stmt->execute([$bookingId]);
    $booking = $stmt->fetch();
    
    $booking['total_nights'] = (int) $booking['total_nights'];
    $booking['total_price'] = (float) $booking['total_price'];
    
    Response::success($booking, 'Status booking berhasil diupdate');
    
} catch (Exception $e) {
    Response::serverError('Update gagal: ' . $e->getMessage());
}
