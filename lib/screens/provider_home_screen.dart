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

class _ProviderHomeScreenState extends State<ProviderHomeScreen> with SingleTickerProviderStateMixin {
  List<Booking> _allBookings = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        _allBookings = fetchedBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Booking> get _draftBookings => 
      _allBookings.where((b) => b.status == BookingStatus.draft).toList();
  
  List<Booking> get _activeBookings => 
      _allBookings.where((b) => [
        BookingStatus.confirmed, 
        BookingStatus.en_route, 
        BookingStatus.arrived, 
        BookingStatus.to_hospital
      ].contains(b.status)).toList();
  
  List<Booking> get _historyBookings => 
      _allBookings.where((b) => [
        BookingStatus.completed, 
        BookingStatus.cancelled
      ].contains(b.status)).toList();

  Future<void> _assignDriver(String bookingId, String driverId, String ambulanceId) async {
    try {

      await BookingService.assignAmbulance(bookingId, ambulanceId, driverId: driverId);
      await _fetchBookings(); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver berhasil ditugaskan')),
        );
      }
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
      await _fetchBookings();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Provider', style: T.h3.copyWith(color: C.bg)),
            Text('ResQLink Partner', style: T.captionSmall.copyWith(color: C.textGrey)),
          ],
        ),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: C.red,
          unselectedLabelColor: C.textGrey,
          indicatorColor: C.red,
          indicatorWeight: 3,
          labelStyle: T.label.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Permintaan'),
            Tab(text: 'Aktif'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(_draftBookings, 'Tidak ada permintaan baru'),
                    _buildBookingList(_activeBookings, 'Tidak ada misi aktif'),
                    _buildBookingList(_historyBookings, 'Belum ada riwayat pesanan'),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: C.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: T.body),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchBookings,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: _fetchBookings,
      child: bookings.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: C.textGrey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(emptyMessage, style: T.body.copyWith(color: C.textGrey)),
                    ],
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildModernBookingCard(bookings[index]),
            ),
    );
  }

  Widget _buildModernBookingCard(Booking booking) {
    final bool isAssigned = booking.status != BookingStatus.draft;
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
                Text(
                  booking.patientCondition, 
                  style: T.title.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
            child: _buildActionArea(booking, driver),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(Booking booking, Driver? driver) {
    if (booking.status == BookingStatus.draft) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _navigateToAssignDriver(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Tugaskan Driver', style: T.btn),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _updateStatus(booking.id, BookingStatus.cancelled),
            icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
            tooltip: 'Batalkan',
          ),
        ],
      );
    }

    if (booking.status == BookingStatus.completed || booking.status == BookingStatus.cancelled) {
      return Row(
        children: [
          const Icon(Icons.history, size: 16, color: C.textGrey),
          const SizedBox(width: 8),
          Text(
            booking.status == BookingStatus.completed ? 'Selesai' : 'Dibatalkan',
            style: T.captionSmall.copyWith(color: C.textGrey),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: C.textGrey, size: 20),
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
            _buildNextStatusButton(booking),
          ],
        ),
      ],
    );
  }

  Widget _buildNextStatusButton(Booking booking) {
    String label;
    BookingStatus nextStatus;
    Color color;

    switch (booking.status) {
      case BookingStatus.confirmed:
        label = 'Jalan';
        nextStatus = BookingStatus.en_route;
        color = Colors.orange;
        break;
      case BookingStatus.en_route:
        label = 'Tiba';
        nextStatus = BookingStatus.arrived;
        color = Colors.blue;
        break;
      case BookingStatus.arrived:
        label = 'Ke RS';
        nextStatus = BookingStatus.to_hospital;
        color = Colors.indigo;
        break;
      case BookingStatus.to_hospital:
        label = 'Selesai';
        nextStatus = BookingStatus.completed;
        color = Colors.green;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: () => _updateStatus(booking.id, nextStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(label, style: T.btnSm.copyWith(color: Colors.white)),
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
    if (type.toLowerCase().contains('medis')) {
      color = Colors.orange;
    } else if (type.toLowerCase().contains('sosial')) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

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

    if (result != null && result is Map<String, dynamic>) {
      final driverId = result['driverId']?.toString();
      final ambulanceId = result['ambulanceId']?.toString();

      if (driverId != null && ambulanceId != null) {
        _assignDriver(booking.id, driverId, ambulanceId);
      }
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