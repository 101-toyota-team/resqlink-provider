import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/driver.dart';
import '../themes/app_theme.dart';
import 'assign_driver_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  List<Booking> bookings = List.from(dummyBookings);

  void _assignDriver(String bookingId, String driverId) {
    setState(() {
      final index = bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        bookings[index] = bookings[index].copyWith(
          assignedDriverId: driverId,
          status: BookingStatus.assigned,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('ResQLink Dashboard', style: T.h3.copyWith(color: C.bg)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: C.bg),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: C.bg),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSummarySection(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Booking Aktif', style: T.h3),
                        TextButton(
                          onPressed: () {},
                          child: Text('Lihat Semua', style: T.btnSm.copyWith(color: C.red)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bookings.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return _buildModernBookingCard(booking);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      color: Colors.white,
      child: Row(
        children: [
          _buildSummaryCard(
            'Menunggu',
            bookings.where((b) => b.status == BookingStatus.pending).length.toString(),
            C.amber,
            Icons.timer_outlined,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Ditugaskan',
            bookings.where((b) => b.status == BookingStatus.assigned).length.toString(),
            Colors.blue,
            Icons.local_shipping_outlined,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Driver Online',
            dummyDrivers.where((d) => d.isAvailable).length.toString(),
            Colors.green,
            Icons.people_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: T.h2.copyWith(color: color, height: 1)),
            const SizedBox(height: 4),
            Text(label, style: T.captionSmall.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBookingCard(Booking booking) {
    final bool isAssigned = booking.status == BookingStatus.assigned;
    final driver = isAssigned 
        ? dummyDrivers.firstWhere((d) => d.id == booking.assignedDriverId)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _getAmbulanceIcon(booking.ambulanceType),
                        const SizedBox(width: 8),
                        Text(
                          booking.ambulanceType.toUpperCase(),
                          style: T.caption.copyWith(fontWeight: FontWeight.w800, color: C.textGrey),
                        ),
                      ],
                    ),
                    _getStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 16),
                Text(booking.patientName, style: T.title.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                _buildLocationLine(Icons.radio_button_checked, Colors.green, booking.pickupLocation),
                const SizedBox(height: 8),
                _buildLocationLine(Icons.location_on, C.red, booking.destination),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isAssigned && driver != null
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: C.textGrey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver.name, style: T.title.copyWith(fontSize: 14)),
                            Text(driver.ambulancePlate, style: T.captionSmall),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _navigateToAssignDriver(booking),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE9ECEF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Ganti Driver', style: T.btnSm.copyWith(color: C.bg)),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToAssignDriver(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cari & Tugaskan Driver', style: T.btn),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationLine(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: T.body.copyWith(fontSize: 13, color: C.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _getAmbulanceIcon(String type) {
    Color color;
    if (type.contains('Medis')) color = Colors.orange;
    else if (type.contains('Sosial')) color = Colors.blue;
    else color = Colors.green;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.emergency, size: 14, color: color),
    );
  }

  Widget _getStatusChip(BookingStatus status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getStatusText(status),
        style: T.captionSmall.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _navigateToAssignDriver(Booking booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignDriverScreen(booking: booking),
      ),
    );

    if (result != null && result is String) {
      _assignDriver(booking.id, result);
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return C.amber;
      case BookingStatus.assigned: return Colors.blue;
      case BookingStatus.inProgress: return Colors.orange;
      case BookingStatus.completed: return Colors.green;
      case BookingStatus.cancelled: return Colors.grey;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return 'Menunggu';
      case BookingStatus.assigned: return 'Driver Ditugaskan';
      case BookingStatus.inProgress: return 'Dalam Perjalanan';
      case BookingStatus.completed: return 'Selesai';
      case BookingStatus.cancelled: return 'Dibatalkan';
    }
  }
}
