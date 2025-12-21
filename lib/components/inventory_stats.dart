import 'package:flutter/material.dart';
import '../../models/hotel.dart';

class InventoryStats extends StatelessWidget {
  final Hotel hotel;
  
  const InventoryStats({
    Key? key,
    required this.hotel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hitung total kamar, terisi, dan tersedia
    final totalRooms = hotel.roomTypes.fold(0, (sum, room) => sum + room.totalRooms);
    final totalBooked = hotel.roomTypes.fold(0, (sum, room) => sum + room.bookedRooms);
    final totalAvailable = hotel.roomTypes.fold(0, (sum, room) => sum + room.availableRooms);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Ringkasan Inventaris Kamar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Total Kamar',
                totalRooms.toString(),
                Icons.hotel,
                Colors.blue[700]!,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Terisi',
                totalBooked.toString(),
                Icons.king_bed,
                Colors.orange[700]!,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Tersedia',
                totalAvailable.toString(),
                Icons.meeting_room,
                Colors.green[700]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
