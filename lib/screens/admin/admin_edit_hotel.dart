import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class AdminEditHotelPage extends StatefulWidget {
  final Hotel hotel;
  const AdminEditHotelPage({super.key, required this.hotel});

  @override
  State<AdminEditHotelPage> createState() => _AdminEditHotelPageState();
}

class _AdminEditHotelPageState extends State<AdminEditHotelPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _facilityController;
  late List<String> _facilities;
  
  // Controllers for room types
  late List<TextEditingController> _roomPriceControllers;
  late List<TextEditingController> _roomCapacityControllers;
  late List<TextEditingController> _roomQuantityControllers;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel.name);
    _descriptionController = TextEditingController(text: widget.hotel.description);
    _addressController = TextEditingController(text: widget.hotel.address);
    _cityController = TextEditingController(text: widget.hotel.city);
    _facilityController = TextEditingController(text: '');
    _facilities = List<String>.from(widget.hotel.facilities);

    // Initialize room type controllers
    _roomPriceControllers = widget.hotel.roomTypes
        .map((r) => TextEditingController(text: r.price.toStringAsFixed(0)))
        .toList();
    _roomCapacityControllers = widget.hotel.roomTypes
        .map((r) => TextEditingController(text: r.capacity.toString()))
        .toList();
    _roomQuantityControllers = widget.hotel.roomTypes
        .map((r) => TextEditingController(text: r.totalRooms.toString()))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    for (var c in _roomPriceControllers) c.dispose();
    for (var c in _roomCapacityControllers) c.dispose();
    for (var c in _roomQuantityControllers) c.dispose();
    _facilityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) throw Exception('User not logged in');

      // Prepare room types data
      final List<Map<String, dynamic>> roomTypesData = [];
      for (int i = 0; i < widget.hotel.roomTypes.length; i++) {
        roomTypesData.add({
          'type': widget.hotel.roomTypes[i].type,
          'price': double.parse(_roomPriceControllers[i].text),
          'capacity': int.parse(_roomCapacityControllers[i].text),
          'total_rooms': int.parse(_roomQuantityControllers[i].text),
        });
      }

      final updatedData = {
        'user_id': userId,
        'hotel_id': widget.hotel.id,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'facilities': _facilities,
        'room_types': roomTypesData,
      };

      await ApiService.updateHotel(updatedData);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel dan inventaris kamar berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui hotel: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Hotel & Inventaris'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Informasi Umum', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Hotel'),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Kota'),
                validator: (v) => v!.isEmpty ? 'Kota tidak boleh kosong' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: AppSpacing.xl),

              const Text('Fasilitas Hotel', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              if (_facilities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text('Belum ada fasilitas. Tambahkan fasilitas di bawah.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _facilities.map((f) => Chip(
                    label: Text(f, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() { _facilities.remove(f); });
                    },
                  )).toList(),
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _facilityController,
                      decoration: const InputDecoration(
                        labelText: 'Tambah fasilitas',
                      ),
                      onSubmitted: (_) {
                        final v = _facilityController.text.trim();
                        if (v.isEmpty) return;
                        if (_facilities.any((e) => e.toLowerCase() == v.toLowerCase())) { _facilityController.clear(); return; }
                        setState(() { _facilities.add(v); _facilityController.clear(); });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () {
                      final v = _facilityController.text.trim();
                      if (v.isEmpty) return;
                      if (_facilities.any((e) => e.toLowerCase() == v.toLowerCase())) { _facilityController.clear(); return; }
                      setState(() { _facilities.add(v); _facilityController.clear(); });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              const Text('Kelola Tipe Kamar & Inventaris', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Tentukan jumlah unit yang tersedia untuk setiap tipe kamar.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.md),
              
              if (widget.hotel.roomTypes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('Tidak ada data tipe kamar.', style: TextStyle(fontStyle: FontStyle.italic)),
                ),
                
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.hotel.roomTypes.length,
                itemBuilder: (context, index) {
                  final roomType = widget.hotel.roomTypes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(roomType.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _roomPriceControllers[index],
                                  decoration: const InputDecoration(labelText: 'Harga (Rp)', prefixText: 'Rp '),
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? 'Harga wajib' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _roomCapacityControllers[index],
                                  decoration: const InputDecoration(labelText: 'Kpsitas'),
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? 'Isi' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _roomQuantityControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Jml Kamar',
                                    hintText: 'Total unit',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? 'Isi jumlah' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Perubahan'),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
