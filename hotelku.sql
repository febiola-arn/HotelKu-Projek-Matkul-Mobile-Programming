-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 18, 2025 at 01:09 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotelku`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` varchar(50) NOT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `hotel_id` varchar(50) DEFAULT NULL,
  `hotel_name` varchar(150) DEFAULT NULL,
  `room_type` varchar(100) DEFAULT NULL,
  `check_in` date DEFAULT NULL,
  `check_out` date DEFAULT NULL,
  `total_nights` int(11) DEFAULT NULL,
  `total_price` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `booking_date` datetime DEFAULT NULL,
  `guest_name` varchar(100) DEFAULT NULL,
  `guest_phone` varchar(20) DEFAULT NULL,
  `special_request` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `user_id`, `hotel_id`, `hotel_name`, `room_type`, `check_in`, `check_out`, `total_nights`, `total_price`, `status`, `booking_date`, `guest_name`, `guest_phone`, `special_request`) VALUES
('', 'user_6942b32c0b7145.90291474', 'h1', 'Grand Luxury Hotel', 'Executive Suite', '2025-12-19', '2025-12-21', 2, 5000000, 'pending', '2025-12-17 20:42:30', 'febioll', '081234567890', ''),
('book_6942b3d3d55625.64726779', 'user_6942b32c0b7145.90291474', 'h1', 'Grand Luxury Hotel', 'Executive Suite', '2025-12-19', '2025-12-21', 2, 5000000, 'cancelled', '2025-12-17 20:44:51', 'febioll', '081234567890', ''),
('book_6942b4ca486f23.31241603', 'user_6942b32c0b7145.90291474', 'h2', 'Sunset Paradise Resort', 'Villa Suite', '2025-12-18', '2025-12-20', 2, 7600000, 'pending', '2025-12-17 20:48:58', 'febioll', '081234567890', ''),
('book_6943730293b4e4.04680075', 'user_6942b32c0b7145.90291474', 'h3', 'Urban Smart Hotel', 'Smart Double', '2025-12-18', '2025-12-22', 4, 4800000, 'pending', '2025-12-18 10:20:34', 'febioll', '081234567890', ''),
('book_694375529ac610.40863334', 'user_6942b32c0b7145.90291474', 'h1', 'Grand Luxury Hotel', 'Executive Suite', '2025-12-19', '2025-12-21', 2, 5000000, 'confirmed', '2025-12-18 10:30:26', 'febioll', '081234567890', ''),
('book_6943bf16c5e337.47946178', 'user_6943bee9c27de7.47924390', 'h1', 'Grand Luxury Hotel', 'Presidential Suite', '2025-12-19', '2025-12-22', 3, 13500000, 'confirmed', '2025-12-18 15:45:10', 'vaidon', '083412567890', ''),
('book_6943c0dabfcb08.93154059', 'user_6943c0a2404cd7.64594414', 'h1', 'Grand Luxury Hotel', 'Executive Suite', '2025-12-23', '2025-12-25', 2, 5000000, 'confirmed', '2025-12-18 15:52:42', 'ririn margaretha', '089712345678', ''),
('book_6943c8b19579b2.40051888', 'user_6943c8307d2778.87650191', 'h_new_01', 'Seaside Luxury Resort', 'Family Villa', '2025-12-19', '2025-12-21', 2, 9000000, 'confirmed', '2025-12-18 16:26:09', 'shata', '081234546789', ''),
('book_6943cdf47c6df4.98691053', 'u2', 'h_new_01', 'Seaside Luxury Resort', 'Family Villa', '2025-12-19', '2025-12-20', 1, 4500000, 'confirmed', '2025-12-18 16:48:36', 'Dewi Lestari', '08991234566', '');

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` varchar(50) NOT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `hotel_id` varchar(50) DEFAULT NULL,
  `added_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`id`, `user_id`, `hotel_id`, `added_at`) VALUES
('', 'user_6943bee9c27de7.47924390', 'h1', '2025-12-18 15:48:07');

-- --------------------------------------------------------

--
-- Table structure for table `hotels`
--

CREATE TABLE `hotels` (
  `id` varchar(50) NOT NULL,
  `name` varchar(150) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `rating` float DEFAULT NULL,
  `price_per_night` int(11) DEFAULT NULL,
  `rooms_available` int(11) DEFAULT NULL,
  `owner_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hotels`
--

INSERT INTO `hotels` (`id`, `name`, `description`, `address`, `city`, `rating`, `price_per_night`, `rooms_available`, `owner_id`) VALUES
('h1', 'Grand Luxury Hotel', 'Hotel mewah bintang 5 ', 'Jl. Sudirman No. 21', 'Jakarta', 4.8, 1500000, 8, 'user_6942b32c0b7145.90291474'),
('h2', 'Sunset Paradise Resort', 'Resort tepi pantai dengan pemandangan laut terbaik.', 'Jl. Pantai Kuta No. 3', 'Bali', 4.7, 1700000, 12, 'u1'),
('h3', 'Urban Smart Hotel', 'Hotel modern dengan desain minimalis dan teknologi smart-room.', 'Jl. Asia Afrika No. 11', 'Bandung', 4.5, 900000, 15, 'u2'),
('h_balige_01', 'Labersa Toba Hotel & Convention', 'Hotel bintang 4 termewah di Balige dengan waterpark dan pemandangan Danau Toba yang spektakuler.', 'Jl. Tampubolon No. 1, Balige', 'Balige', 4.7, 1200000, 15, 'u_balige_01'),
('h_balige_02', 'Tiara Bunga Hotel & Villa', 'Penginapan unik dengan akses perahu pribadi dan suasana alam yang tenang di tepi danau.', 'Jl. Tulpang, Balige (Akses via Kapal)', 'Balige', 4.5, 850000, 8, 'u_balige_02'),
('h_new_01', 'Seaside Luxury Resort', 'Resort mewah dengan pemandangan laut yang menakjubkan.', 'Jl. Pantai Indah No. 99', 'Bali', 4.9, 2500000, 10, 'admin_user_01');

-- --------------------------------------------------------

--
-- Table structure for table `hotel_facilities`
--

CREATE TABLE `hotel_facilities` (
  `id` int(11) NOT NULL,
  `hotel_id` varchar(50) DEFAULT NULL,
  `facility` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hotel_facilities`
--

INSERT INTO `hotel_facilities` (`id`, `hotel_id`, `facility`) VALUES
(1, 'h1', 'Free Wifi'),
(2, 'h1', 'Swimming Pool'),
(3, 'h1', 'Spa'),
(4, 'h1', 'Restaurant'),
(5, 'h1', 'Gym'),
(6, 'h2', 'Beach Access'),
(7, 'h2', 'Free Breakfast'),
(8, 'h2', 'Swimming Pool'),
(9, 'h2', 'Bar & Cafe'),
(10, 'h2', 'Airport Shuttle'),
(11, 'h3', 'Smart TV'),
(12, 'h3', 'Self Check-in'),
(13, 'h3', 'Meeting Room'),
(14, 'h3', 'Coffee Shop'),
(15, 'h3', 'Parking Area'),
(16, 'h_new_01', 'Private Beach'),
(17, 'h_new_01', 'Infinity Pool'),
(18, 'h_new_01', 'Spa & Massage'),
(19, 'h_new_01', 'Fine Dining'),
(20, 'h_balige_01', 'Waterpark'),
(21, 'h_balige_01', 'Lake View'),
(22, 'h_balige_01', 'Convention Hall'),
(23, 'h_balige_01', 'Restaurant'),
(24, 'h_balige_01', 'Free WiFi'),
(25, 'h_balige_02', 'Private Boat Access'),
(26, 'h_balige_02', 'Fishing Area'),
(27, 'h_balige_02', 'Floating Restaurant'),
(28, 'h_balige_02', 'Garden');

-- --------------------------------------------------------

--
-- Table structure for table `hotel_images`
--

CREATE TABLE `hotel_images` (
  `id` int(11) NOT NULL,
  `hotel_id` varchar(50) DEFAULT NULL,
  `image_url` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hotel_images`
--

INSERT INTO `hotel_images` (`id`, `hotel_id`, `image_url`) VALUES
(1, 'h1', 'https://picsum.photos/seed/h1a/800/500'),
(2, 'h1', 'https://picsum.photos/seed/h1b/800/500'),
(3, 'h1', 'https://picsum.photos/seed/h1c/800/500'),
(4, 'h2', 'https://picsum.photos/seed/h2a/800/500'),
(5, 'h2', 'https://picsum.photos/seed/h2b/800/500'),
(6, 'h3', 'https://picsum.photos/seed/h3a/800/500'),
(7, 'h3', 'https://picsum.photos/seed/h3b/800/500'),
(8, 'h_new_01', 'https://picsum.photos/seed/sea1/800/500'),
(9, 'h_new_01', 'https://picsum.photos/seed/sea2/800/500'),
(10, 'h_balige_01', 'https://picsum.photos/seed/labersa1/800/500'),
(11, 'h_balige_01', 'https://picsum.photos/seed/labersa2/800/500'),
(12, 'h_balige_01', 'https://picsum.photos/seed/labersa3/800/500'),
(13, 'h_balige_02', 'https://picsum.photos/seed/tiara1/800/500'),
(14, 'h_balige_02', 'https://picsum.photos/seed/tiara2/800/500');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` varchar(50) NOT NULL,
  `hotel_id` varchar(50) DEFAULT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `user_avatar` text DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `hotel_id`, `user_id`, `user_name`, `user_avatar`, `rating`, `comment`, `date`) VALUES
('r1', 'h1', 'u1', 'Gilbert', 'https://i.pravatar.cc/150?img=12', 5, 'Pengalaman luar biasa, pelayanan sangat ramah.', '2025-12-15 13:15:51'),
('r2', 'h1', 'u2', 'Dewi Lestari', 'https://i.pravatar.cc/150?img=32', 4, 'Hotel sangat bersih dan nyaman.', '2025-12-15 13:15:51'),
('r3', 'h2', 'u1', 'Gilbert', 'https://i.pravatar.cc/150?img=12', 5, 'Pemandangan sunset sangat indah!', '2025-12-15 13:15:51'),
('r4', 'h3', 'u2', 'Dewi Lestari', 'https://i.pravatar.cc/150?img=32', 4, 'Lokasi strategis, smart-room keren.', '2025-12-15 13:15:51');

-- --------------------------------------------------------

--
-- Table structure for table `room_types`
--

CREATE TABLE `room_types` (
  `id` int(11) NOT NULL,
  `hotel_id` varchar(50) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `room_types`
--

INSERT INTO `room_types` (`id`, `hotel_id`, `type`, `price`, `capacity`) VALUES
(1, 'h1', 'Deluxe Room', 1500000, 2),
(2, 'h1', 'Executive Suite', 2500000, 3),
(3, 'h1', 'Presidential Suite', 4500000, 5),
(4, 'h2', 'Standard Room', 1700000, 2),
(5, 'h2', 'Beachfront Room', 2500000, 3),
(6, 'h2', 'Villa Suite', 3800000, 4),
(7, 'h3', 'Smart Single', 900000, 1),
(8, 'h3', 'Smart Double', 1200000, 2),
(9, 'h3', 'Family Room', 1800000, 4),
(10, 'h_new_01', 'Ocean View Suite', 2500000, 2),
(11, 'h_new_01', 'Family Villa', 4500000, 4),
(12, 'h_balige_01', 'Deluxe Lake View', 1200000, 2),
(13, 'h_balige_01', 'Executive Suite', 2100000, 3),
(14, 'h_balige_02', 'Superior Villa', 850000, 2),
(15, 'h_balige_02', 'Family Villa', 1500000, 4);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` varchar(50) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `role` enum('customer','hotel_admin') DEFAULT 'customer'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `phone`, `avatar`, `created_at`, `role`) VALUES
('admin_user_01', 'Nadya Lahfah', 'Nadya@hotel.com', '123456', '081234567890', NULL, '2025-12-18 16:17:04', 'hotel_admin'),
('u1', 'Gilbert', 'gilbert@example.com', '123456', '08123456789', 'https://i.pravatar.cc/150?img=12', '2025-12-15 13:15:51', 'hotel_admin'),
('u2', 'Dewi Lestari', 'dewi@example.com', '123456', '08991234566', 'https://i.pravatar.cc/150?img=32', '2025-12-15 13:15:51', 'customer'),
('user_6942b32c0b7145.90291474', 'febioll', 'febioll@gmail.com', 'febioll123', '081234567890', 'https://i.pravatar.cc/150?img=11', '2025-12-17 20:42:04', 'hotel_admin'),
('user_6943bee9c27de7.47924390', 'vaidon', 'vaidon@gmail.com', 'vaidon123', '083412567890', 'https://i.pravatar.cc/150?img=59', '2025-12-18 15:44:25', 'hotel_admin'),
('user_6943c0a2404cd7.64594414', 'ririn margaretha', 'ririn@gmail.com', 'ririn123', '089712345678', 'https://i.pravatar.cc/150?img=24', '2025-12-18 15:51:46', 'customer'),
('user_6943c8307d2778.87650191', 'shata', 'shata@gmail.com', 'shata123', '081234546789', 'https://i.pravatar.cc/150?img=6', '2025-12-18 16:24:00', 'customer'),
('u_balige_01', 'Evan Hotel', 'evan@mail.com', '123456', '081234567891', NULL, '2025-12-18 16:52:28', 'hotel_admin'),
('u_balige_02', 'Elaine Rooms', 'elaine@mail.com', '123456', '081234567892', NULL, '2025-12-18 16:52:28', 'hotel_admin');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `hotels`
--
ALTER TABLE `hotels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hotel_facilities`
--
ALTER TABLE `hotel_facilities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `hotel_images`
--
ALTER TABLE `hotel_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `room_types`
--
ALTER TABLE `room_types`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `hotel_facilities`
--
ALTER TABLE `hotel_facilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `hotel_images`
--
ALTER TABLE `hotel_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `room_types`
--
ALTER TABLE `room_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `hotel_facilities`
--
ALTER TABLE `hotel_facilities`
  ADD CONSTRAINT `hotel_facilities_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `hotel_images`
--
ALTER TABLE `hotel_images`
  ADD CONSTRAINT `hotel_images_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `room_types`
--
ALTER TABLE `room_types`
  ADD CONSTRAINT `room_types_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
