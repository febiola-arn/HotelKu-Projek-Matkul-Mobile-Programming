CREATE DATABASE hotelku;
USE hotelku;

CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    phone VARCHAR(20),
    avatar TEXT,
    role VARCHAR(20) DEFAULT 'customer',
    created_at DATETIME
);

CREATE TABLE hotels (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150),
    description TEXT,
    address VARCHAR(255),
    city VARCHAR(100),
    rating FLOAT,
    price_per_night INT,
    rooms_available INT,
    owner_id VARCHAR(50),
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE hotel_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id VARCHAR(50),
    image_url TEXT,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

CREATE TABLE hotel_facilities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id VARCHAR(50),
    facility VARCHAR(100),
    FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

CREATE TABLE room_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id VARCHAR(50),
    type VARCHAR(100),
    price INT,
    capacity INT,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

CREATE TABLE bookings (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    hotel_id VARCHAR(50),
    hotel_name VARCHAR(150),
    room_type VARCHAR(100),
    check_in DATE,
    check_out DATE,
    total_nights INT,
    total_price INT,
    status VARCHAR(50),
    booking_date DATETIME,
    guest_name VARCHAR(100),
    guest_phone VARCHAR(20),
    special_request TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (hotel_id) REFERENCES hotels(id)
);

CREATE TABLE favorites (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    hotel_id VARCHAR(50),
    added_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (hotel_id) REFERENCES hotels(id)
);

CREATE TABLE reviews (
    id VARCHAR(50) PRIMARY KEY,
    hotel_id VARCHAR(50),
    user_id VARCHAR(50),
    user_name VARCHAR(100),
    user_avatar TEXT,
    rating INT,
    comment TEXT,
    date DATETIME,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO users (id, name, email, password, phone, avatar, created_at)
VALUES
('u1', 'Gilbert', 'gilbert@example.com', '123456', '08123456789', 'https://i.pravatar.cc/150?img=12', NOW()),
('u2', 'Dewi Lestari', 'dewi@example.com', '123456', '08991234567', 'https://i.pravatar.cc/150?img=32', NOW());

INSERT INTO hotels (id, name, description, address, city, rating, price_per_night, rooms_available)
VALUES
('h1', 'Grand Luxury Hotel', 'Hotel mewah bintang 5 dengan kolam renang dan spa premium.', 'Jl. Sudirman No. 21', 'Jakarta', 4.8, 1500000, 8),
('h2', 'Sunset Paradise Resort', 'Resort tepi pantai dengan pemandangan laut terbaik.', 'Jl. Pantai Kuta No. 3', 'Bali', 4.7, 1700000, 12),
('h3', 'Urban Smart Hotel', 'Hotel modern dengan desain minimalis dan teknologi smart-room.', 'Jl. Asia Afrika No. 11', 'Bandung', 4.5, 900000, 15);

INSERT INTO hotel_images (hotel_id, image_url)
VALUES
('h1', 'https://picsum.photos/seed/h1a/800/500'),
('h1', 'https://picsum.photos/seed/h1b/800/500'),
('h1', 'https://picsum.photos/seed/h1c/800/500'),

('h2', 'https://picsum.photos/seed/h2a/800/500'),
('h2', 'https://picsum.photos/seed/h2b/800/500'),

('h3', 'https://picsum.photos/seed/h3a/800/500'),
('h3', 'https://picsum.photos/seed/h3b/800/500');

INSERT INTO hotel_facilities (hotel_id, facility)
VALUES
-- H1
('h1', 'Free Wifi'),
('h1', 'Swimming Pool'),
('h1', 'Spa'),
('h1', 'Restaurant'),
('h1', 'Gym'),

-- H2
('h2', 'Beach Access'),
('h2', 'Free Breakfast'),
('h2', 'Swimming Pool'),
('h2', 'Bar & Cafe'),
('h2', 'Airport Shuttle'),

-- H3
('h3', 'Smart TV'),
('h3', 'Self Check-in'),
('h3', 'Meeting Room'),
('h3', 'Coffee Shop'),
('h3', 'Parking Area');

INSERT INTO room_types (hotel_id, type, price, capacity)
VALUES
-- H1
('h1', 'Deluxe Room', 1500000, 2),
('h1', 'Executive Suite', 2500000, 3),
('h1', 'Presidential Suite', 4500000, 5),

-- H2
('h2', 'Standard Room', 1700000, 2),
('h2', 'Beachfront Room', 2500000, 3),
('h2', 'Villa Suite', 3800000, 4),

-- H3
('h3', 'Smart Single', 900000, 1),
('h3', 'Smart Double', 1200000, 2),
('h3', 'Family Room', 1800000, 4);

INSERT INTO reviews (id, hotel_id, user_id, user_name, user_avatar, rating, comment, date)
VALUES
('r1', 'h1', 'u1', 'Gilbert', 'https://i.pravatar.cc/150?img=12', 5, 'Pengalaman luar biasa, pelayanan sangat ramah.', NOW()),
('r2', 'h1', 'u2', 'Dewi Lestari', 'https://i.pravatar.cc/150?img=32', 4, 'Hotel sangat bersih dan nyaman.', NOW()),


('r3', 'h2', 'u1', 'Gilbert', 'https://i.pravatar.cc/150?img=12', 5, 'Pemandangan sunset sangat indah!', NOW()),
('r4', 'h3', 'u2', 'Dewi Lestari', 'https://i.pravatar.cc/150?img=32', 4, 'Lokasi strategis, smart-room keren.', NOW());

-- ==========================================
-- BALIGE HOTELS & ADMINS (ADDED FOR DEMO)
-- ==========================================

-- 1. Create Admin Users
INSERT INTO users (id, name, email, password, phone, role, created_at)
VALUES 
('u_balige_01', 'Andi Batak', 'andi@labersa.com', '123456', '081234567891', 'hotel_admin', NOW()),
('u_balige_02', 'Siti Toba', 'siti@tiara.com', '123456', '081234567892', 'hotel_admin', NOW());

-- 2. Create Hotels in Balige
INSERT INTO hotels (id, name, description, address, city, rating, price_per_night, rooms_available, owner_id)
VALUES 
('h_balige_01', 'Labersa Toba Hotel & Convention', 'Hotel bintang 4 termewah di Balige dengan waterpark dan pemandangan Danau Toba yang spektakuler.', 'Jl. Tampubolon No. 1, Balige', 'Balige', 4.7, 1200000, 15, 'u_balige_01'),
('h_balige_02', 'Tiara Bunga Hotel & Villa', 'Penginapan unik dengan akses perahu pribadi dan suasana alam yang tenang di tepi danau.', 'Jl. Tulpang, Balige (Akses via Kapal)', 'Balige', 4.5, 850000, 8, 'u_balige_02');

-- 3. Add Images
INSERT INTO hotel_images (hotel_id, image_url)
VALUES 
('h_balige_01', 'https://picsum.photos/seed/labersa1/800/500'),
('h_balige_01', 'https://picsum.photos/seed/labersa2/800/500'),
('h_balige_01', 'https://picsum.photos/seed/labersa3/800/500'),
('h_balige_02', 'https://picsum.photos/seed/tiara1/800/500'),
('h_balige_02', 'https://picsum.photos/seed/tiara2/800/500');

-- 4. Add Facilities
INSERT INTO hotel_facilities (hotel_id, facility)
VALUES 
('h_balige_01', 'Waterpark'),
('h_balige_01', 'Lake View'),
('h_balige_01', 'Convention Hall'),
('h_balige_01', 'Restaurant'),
('h_balige_01', 'Free WiFi'),
('h_balige_02', 'Private Boat Access'),
('h_balige_02', 'Fishing Area'),
('h_balige_02', 'Floating Restaurant'),
('h_balige_02', 'Garden');

-- 5. Add Room Types
INSERT INTO room_types (hotel_id, type, price, capacity)
VALUES 
('h_balige_01', 'Deluxe Lake View', 1200000, 2),
('h_balige_01', 'Executive Suite', 2100000, 3),
('h_balige_02', 'Superior Villa', 850000, 2),
('h_balige_02', 'Family Villa', 1500000, 4);


