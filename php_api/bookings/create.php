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
if (empty($roomType)) Response::error('Room Type is required', 400);

try {
    $db = Database::getInstance()->getConnection();
    
    // Begin Transaction to prevent race conditions
    $db->beginTransaction();

    // 1. Check Room Inventory
    $stmtRoom = $db->prepare("SELECT total_rooms FROM room_types WHERE hotel_id = ? AND type = ?");
    $stmtRoom->execute([$hotelId, $roomType]);
    $roomInfo = $stmtRoom->fetch();

    if (!$roomInfo) {
        $db->rollBack();
        Response::error('Tipe kamar tidak ditemukan', 404);
    }

    $totalRooms = (int)$roomInfo['total_rooms'];

    // 2. Count Active Bookings for this room type
    // In a real system, you'd check for date overlaps, but for this project scope
    // we use the 'Confirmed'/'Pending' status as defined by the user's dashboard requirement.
    $stmtBooked = $db->prepare("
        SELECT COUNT(*) 
        FROM bookings 
        WHERE hotel_id = ? 
        AND room_type = ? 
        AND status IN ('confirmed', 'pending')
    ");
    $stmtBooked->execute([$hotelId, $roomType]);
    $bookedCount = (int)$stmtBooked->fetchColumn();

    // 3. Validate Availability
    if ($bookedCount >= $totalRooms) {
        $db->rollBack();
        Response::error('Maaf, tipe kamar ' . $roomType . ' sudah penuh dipesan.', 400);
    }

    // 4. Create Booking
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
    
    $db->commit();

    // Get the new booking
    $stmtFetch = $db->prepare("SELECT * FROM bookings WHERE id = ?");
    $stmtFetch->execute([$bookingId]);
    $booking = $stmtFetch->fetch();
    
    $booking['total_nights'] = (int) $booking['total_nights'];
    $booking['total_price'] = (float) $booking['total_price'];
    
    Response::created($booking, 'Booking berhasil dibuat');
    
} catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    Response::serverError('Booking gagal: ' . $e->getMessage());
}
