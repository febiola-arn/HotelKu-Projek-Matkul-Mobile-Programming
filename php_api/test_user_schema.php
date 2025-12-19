<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    echo "Bookings Table Structure:\n";
    $stmt = $db->query("SHOW COLUMNS FROM bookings");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    print_r($columns);

} catch (Exception $e) {
    echo "Failed: " . $e->getMessage();
}
