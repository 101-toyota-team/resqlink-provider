enum BookingStatus { pending, assigned, inProgress, completed, cancelled }

class Booking {
  final String id;
  final String patientName;
  final String pickupLocation;
  final String destination;
  final DateTime timestamp;
  final BookingStatus status;
  final String? assignedDriverId;
  final String ambulanceType;

  Booking({
    required this.id,
    required this.patientName,
    required this.pickupLocation,
    required this.destination,
    required this.timestamp,
    required this.status,
    this.assignedDriverId,
    required this.ambulanceType,
  });

  Booking copyWith({
    String? assignedDriverId,
    BookingStatus? status,
  }) {
    return Booking(
      id: id,
      patientName: patientName,
      pickupLocation: pickupLocation,
      destination: destination,
      timestamp: timestamp,
      status: status ?? this.status,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      ambulanceType: ambulanceType,
    );
  }
}

final List<Booking> dummyBookings = [
  Booking(
    id: 'BK001',
    patientName: 'Budi Santoso',
    pickupLocation: 'Jl. Merdeka No. 10, Jakarta',
    destination: 'RS Pusat Nasional Dr. Cipto Mangunkusumo',
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    status: BookingStatus.pending,
    ambulanceType: 'Ambulance Medis',
  ),
  Booking(
    id: 'BK002',
    patientName: 'Siti Aminah',
    pickupLocation: 'Jl. Thamrin No. 5, Jakarta',
    destination: 'RS Fatmawati',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    status: BookingStatus.assigned,
    assignedDriverId: 'DRV001',
    ambulanceType: 'Ambulance Sosial',
  ),
  Booking(
    id: 'BK003',
    patientName: 'Sara Latifa',
    pickupLocation: 'Jl. Gatot Subroto No. 20, Jakarta',
    destination: 'RS Siloam Semanggi',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    status: BookingStatus.pending,
    ambulanceType: 'Ambulance Jenazah',
  ),
];
