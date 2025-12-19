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

// Required fields
$userId = $input['user_id'] ?? null;
$hotelId = $input['hotel_id'] ?? null;
$hotelName = $input['hotel_name'] ?? '';
$roomType = $input['room_type'] ?? '';
$checkIn = $input['check_in'] ?? null;
$checkOut = $input['check_out'] ?? null;
$totalNights = $input['total_nights'] ?? 0;
$totalPrice = $input['total_price'] ?? 0;
$guestName = $input['guest_name'] ?? '';
$guestPhone = $input['guest_phone'] ?? '';
$specialRequest = $input['special_request'] ?? '';

// Validate required fields
if (!$userId) Response::error('User ID is required', 400);
if (!$hotelId) Response::error('Hotel ID is required', 400);
if (!$checkIn) Response::error('Check-in date is required', 400);
if (!$checkOut) Response::error('Check-out date is required', 400);
if (empty($guestName)) Response::error('Guest name is required', 400);

try {
    $db = Database::getInstance()->getConnection();
    
    // Generate UUID
    $bookingId = uniqid('book_', true);

    $stmt = $db->prepare("
        INSERT INTO bookings 
        (id, user_id, hotel_id, hotel_name, room_type, check_in, check_out, 
         total_nights, total_price, status, booking_date, guest_name, guest_phone, special_request)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', NOW(), ?, ?, ?)
    ");
    
    $stmt->execute([
        $bookingId,
        $userId, $hotelId, $hotelName, $roomType, 
        $checkIn, $checkOut, $totalNights, $totalPrice,
        $guestName, $guestPhone, $specialRequest
    ]);
    
    // Get the new booking
    $stmt = $db->prepare("SELECT * FROM bookings WHERE id = ?");
    $stmt->execute([$bookingId]);
    $booking = $stmt->fetch();
    
    $booking['total_nights'] = (int) $booking['total_nights'];
    $booking['total_price'] = (float) $booking['total_price'];
    
    Response::created($booking, 'Booking berhasil dibuat');
    
} catch (Exception $e) {
    Response::serverError('Booking gagal: ' . $e->getMessage());
}
