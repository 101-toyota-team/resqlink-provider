import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/driver.dart';
import '../themes/app_theme.dart';

class AssignDriverScreen extends StatefulWidget {
  final Booking booking;

  const AssignDriverScreen({super.key, required this.booking});

  @override
  State<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverScreen> {
  String? selectedDriverId;

  @override
  Widget build(BuildContext context) {
    // Filter drivers by matching ambulance type (case insensitive matching)
    final availableDrivers = dummyDrivers.where((driver) {
      final type = driver.ambulanceType.toLowerCase();
      final target = widget.booking.bookingType.toLowerCase();
      return type.contains(target);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Pilih Driver', style: T.h3.copyWith(color: C.bg)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: C.bg, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PENUGASAN UNTUK', style: T.captionSmall.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold, color: C.textGrey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: C.redSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: C.red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.booking.patientCondition, style: T.title),
                          Text(widget.booking.bookingType.toUpperCase(), style: T.captionSmall.copyWith(color: C.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: availableDrivers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: C.textGrey.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada driver tersedia untuk jenis\n${widget.booking.bookingType.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: T.body.copyWith(color: C.textGrey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: availableDrivers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                final driver = availableDrivers[index];
                final isSelected = selectedDriverId == driver.id;
                final isCurrentDriver = widget.booking.driverId == driver.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedDriverId = driver.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? C.red : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isSelected ? 0.08 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.local_shipping_outlined, color: C.bg, size: 24),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: driver.isAvailable ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(driver.name, style: T.title),
                                  if (isCurrentDriver)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('AKTIF', style: T.captionSmall.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${driver.ambulancePlate} • ${driver.ambulanceType}',
                                style: T.captionSmall.copyWith(color: C.textGrey),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: C.red, size: 28)
                        else
                          Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.3), size: 28),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedDriverId == null 
                      ? null 
                      : () => Navigator.pop(context, selectedDriverId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text('Konfirmasi Penugasan', style: T.btn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
