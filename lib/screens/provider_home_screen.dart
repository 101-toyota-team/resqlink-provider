import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/driver.dart';
import '../themes/app_theme.dart';
import 'assign_driver_screen.dart';
import 'login_screen.dart';

import '../services/booking_service.dart';
import '../services/auth_service.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  List<Booking> bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = AuthService.currentUser;
      final providerId = user?.userMetadata?['provider_id'];

      if (providerId == null) {
        throw Exception('Provider ID not found in user metadata');
      }

      final fetchedBookings = await BookingService.getProviderBookings(providerId);
      setState(() {
        bookings = fetchedBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _assignDriver(String bookingId, String driverId) async {
    // In real app, driverId might be ambulanceId or we get ambulanceId from driver
    // For now, let's just use the driverId as ambulanceId for demonstration
    try {
      await BookingService.assignAmbulance(bookingId, driverId, driverId: driverId);
      await _fetchBookings(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign driver: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(String bookingId, BookingStatus status) async {
    try {
      await BookingService.updateBookingStatus(bookingId, status.name);
      await _fetchBookings(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
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
            icon: const Icon(Icons.refresh, color: C.bg),
            onPressed: _fetchBookings,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: C.bg),
            onPressed: () async {
              await AuthService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
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
                        child: RefreshIndicator(
                          onRefresh: _fetchBookings,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Booking Aktif', style: T.h3),
                                    TextButton(
                                      onPressed: _fetchBookings,
                                      child: Text('Refresh', style: T.btnSm.copyWith(color: C.red)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                bookings.isEmpty
                                    ? const Center(child: Padding(
                                        padding: EdgeInsets.only(top: 40),
                                        child: Text('Tidak ada booking aktif'),
                                      ))
                                    : ListView.separated(
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
            bookings.where((b) => b.status == BookingStatus.draft).length.toString(),
            C.amber,
            Icons.timer_outlined,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Ditugaskan',
            bookings.where((b) => b.status == BookingStatus.confirmed).length.toString(),
            Colors.blue,
            Icons.local_shipping_outlined,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Berjalan',
            bookings.where((b) => b.status == BookingStatus.en_route || b.status == BookingStatus.to_hospital).length.toString(),
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
    final bool isAssigned = booking.status != BookingStatus.draft;
    // In real app, we fetch driver details. For now use dummy if assigned.
    final driver = isAssigned && booking.driverId != null
        ? dummyDrivers.firstWhere((d) => d.id == booking.driverId, orElse: () => dummyDrivers.first)
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
                        _getAmbulanceIcon(booking.bookingType),
                        const SizedBox(width: 8),
                        Text(
                          booking.bookingType.toUpperCase(),
                          style: T.caption.copyWith(fontWeight: FontWeight.w800, color: C.textGrey),
                        ),
                      ],
                    ),
                    _getStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 16),
                Text(booking.patientCondition, style: T.title.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                _buildLocationLine(Icons.radio_button_checked, Colors.green, booking.pickupAddress),
                const SizedBox(height: 8),
                _buildLocationLine(Icons.location_on, C.red, booking.destinationAddress),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isAssigned
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: C.textGrey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver?.name ?? 'Driver Assigned', style: T.title.copyWith(fontSize: 14)),
                            Text(driver?.ambulancePlate ?? '...', style: T.captionSmall),
                          ],
                        ),
                      ),
                      if (booking.status == BookingStatus.confirmed)
                        ElevatedButton(
                          onPressed: () => _updateStatus(booking.id, BookingStatus.en_route),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('En Route'),
                        )
                      else if (booking.status == BookingStatus.en_route)
                        ElevatedButton(
                          onPressed: () => _updateStatus(booking.id, BookingStatus.arrived),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Arrived'),
                        )
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
    if (type.contains('medis')) color = Colors.orange;
    else if (type.contains('sosial')) color = Colors.blue;
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
      // Result is ambulanceId
      _assignDriver(booking.id, result);
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.draft: return C.amber;
      case BookingStatus.confirmed: return Colors.blue;
      case BookingStatus.en_route: return Colors.orange;
      case BookingStatus.arrived: return Colors.blueAccent;
      case BookingStatus.to_hospital: return Colors.indigo;
      case BookingStatus.completed: return Colors.green;
      case BookingStatus.cancelled: return Colors.grey;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.draft: return 'Menunggu';
      case BookingStatus.confirmed: return 'Dikonfirmasi';
      case BookingStatus.en_route: return 'Dalam Perjalanan';
      case BookingStatus.arrived: return 'Tiba di Lokasi';
      case BookingStatus.to_hospital: return 'Ke Rumah Sakit';
      case BookingStatus.completed: return 'Selesai';
      case BookingStatus.cancelled: return 'Dibatalkan';
    }
  }
}
