import 'package:flutter/material.dart';
import '../../models/hotel.dart';

class RoomTypeList extends StatelessWidget {
  final List<RoomType> roomTypes;
  final bool showEditButton;
  final Function(RoomType)? onEdit;

  const RoomTypeList({
    Key? key,
    required this.roomTypes,
    this.showEditButton = false,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Daftar Tipe Kamar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...roomTypes.map((room) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              room.type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Kapasitas: ${room.capacity} orang'),
                const SizedBox(height: 2),
                Text('Harga: ${_formatCurrency(room.price)}/malam'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusChip(
                      'Total: ${room.totalRooms}',
                      Colors.blue[700]!,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'Terisi: ${room.bookedRooms}',
                      Colors.orange[700]!,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'Tersedia: ${room.availableRooms}',
                      room.availableRooms > 0 ? Colors.green[700]! : Colors.red[700]!,
                    ),
                  ],
                ),
              ],
            ),
            trailing: showEditButton && onEdit != null
                ? IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => onEdit!(room),
                  )
                : null,
          ),
        )).toList(),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
