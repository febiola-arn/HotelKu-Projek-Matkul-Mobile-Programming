<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

Response::headers();

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

// Read JSON body first; if empty, fallback to form-encoded ($_POST)
$raw = file_get_contents('php://input');
$input = json_decode($raw, true);
if (!is_array($input) || empty($input)) {
    $input = $_POST ?? [];
}

$hotelId = $input['hotel_id'] ?? null;
$userId = $input['user_id'] ?? null;
$bookingId = $input['booking_id'] ?? null;
$userName = $input['user_name'] ?? '';
$userAvatar = $input['user_avatar'] ?? '';
$isAnonymous = filter_var($input['anonymous'] ?? false, FILTER_VALIDATE_BOOLEAN);
$rating = isset($input['rating']) ? (float)$input['rating'] : 0;
$comment = trim($input['comment'] ?? '');

// Normalize & validate
if (!$userId) Response::error('User ID is required', 400);
if (empty($comment)) Response::error('Komentar harus diisi', 400);
if ($rating < 1 || $rating > 5) Response::error('Rating harus 1-5', 400);

try {
    $db = Database::getInstance()->getConnection();

    // Optional: if booking_id provided, validate it and derive hotel_id (and enforce Completed)
    $hasBookingIdColumn = false;
    $stmtCol = $db->prepare("SHOW COLUMNS FROM reviews LIKE 'booking_id'");
    if ($stmtCol->execute()) {
        $hasBookingIdColumn = (bool)$stmtCol->fetch();
    }

    if ($bookingId) {
        $stmtBk = $db->prepare("SELECT id, hotel_id, user_id, status FROM bookings WHERE id = ? LIMIT 1");
        $stmtBk->execute([$bookingId]);
        $bk = $stmtBk->fetch();
        if (!$bk) {
            Response::error('Transaksi tidak ditemukan', 404);
        }
        if ($bk['user_id'] !== $userId) {
            Response::unauthorized('Booking tidak dimiliki oleh pengguna ini');
        }
        // Normalize status comparison
        $bkStatus = strtolower(trim($bk['status'] ?? ''));
        if (!in_array($bkStatus, ['completed', 'selesai'])) {
            Response::error('Ulasan hanya dapat diberikan setelah checkout (status Selesai)', 400);
        }
        // Derive hotel_id if not provided or mismatch
        if (empty($hotelId)) {
            $hotelId = $bk['hotel_id'];
        } elseif ($hotelId !== $bk['hotel_id']) {
            Response::error('Hotel pada ulasan tidak sesuai dengan transaksi', 400);
        }
    }

    if (!$hotelId) Response::error('Hotel ID is required', 400);

    // Prevent duplicate review per transaction (booking). If booking_id not provided or column doesn't exist, fallback to per user+hotel
    if ($bookingId && $hasBookingIdColumn) {
        $stmt = $db->prepare("SELECT id FROM reviews WHERE booking_id = ? LIMIT 1");
        $stmt->execute([$bookingId]);
        if ($stmt->fetch()) {
            Response::error('Anda sudah memberikan ulasan untuk transaksi ini', 409);
        }
    } else {
        $stmt1 = $db->prepare("SELECT COUNT(*) FROM reviews WHERE hotel_id = ? AND user_id = ?");
        $stmt1->execute([$hotelId, $userId]);
        $reviewCount = (int)$stmt1->fetchColumn();

        $stmt2 = $db->prepare("SELECT COUNT(*) FROM bookings WHERE hotel_id = ? AND user_id = ? AND LOWER(status) IN ('completed','selesai')");
        $stmt2->execute([$hotelId, $userId]);
        $completedCount = (int)$stmt2->fetchColumn();

        if ($completedCount <= 0 || $reviewCount >= $completedCount) {
            Response::error('Anda sudah memberikan ulasan sesuai jumlah transaksi yang selesai', 409);
        }
    }

    // Manually generate ID for VARCHAR PK to avoid empty-string duplicates
    $id = uniqid('r');

    // Handle anonymity
    if ($isAnonymous) {
        $userName = 'Anonim';
        $userAvatar = '';
    }

    // Insert review with explicit ID (and optional booking_id if column exists)
    if ($hasBookingIdColumn) {
        $stmt = $db->prepare("
            INSERT INTO reviews (id, hotel_id, user_id, booking_id, user_name, user_avatar, rating, comment, date)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$id, $hotelId, $userId, $bookingId, $userName, $userAvatar, $rating, $comment]);
    } else {
        $stmt = $db->prepare("
            INSERT INTO reviews (id, hotel_id, user_id, user_name, user_avatar, rating, comment, date)
            VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$id, $hotelId, $userId, $userName, $userAvatar, $rating, $comment]);
    }

    // Get the new review
    $stmt = $db->prepare("SELECT * FROM reviews WHERE id = ?");
    $stmt->execute([$id]);
    $review = $stmt->fetch();

    // Cast rating to float for JSON
    if (isset($review['rating'])) {
        $review['rating'] = (float)$review['rating'];
    }

    // Update hotel rating average
    $stmt = $db->prepare("
        UPDATE hotels SET rating = (
            SELECT AVG(rating) FROM reviews WHERE hotel_id = ?
        ) WHERE id = ?
    ");
    $stmt->execute([$hotelId, $hotelId]);

    Response::created($review, 'Review berhasil ditambahkan');

} catch (Exception $e) {
    Response::serverError('Gagal menambahkan review: ' . $e->getMessage());
}
