enum BookingStatus {
  draft,
  confirmed,
  en_route,
  arrived,
  to_hospital,
  completed,
  cancelled
}

extension BookingStatusExtension on BookingStatus {
  String get name => toString().split('.').last;
}

BookingStatus parseBookingStatus(String status) {
  return BookingStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => BookingStatus.draft,
  );
}

class Booking {
  final String id;
  final String? ambulanceId;
  final String? providerId;
  final String? driverId;
  final String bookingType;
  final String patientCondition;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String pickupH3;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final String userId;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    this.ambulanceId,
    this.providerId,
    this.driverId,
    required this.bookingType,
    required this.patientCondition,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupH3,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      ambulanceId: json['ambulance_id'],
      providerId: json['provider_id'],
      driverId: json['driver_id'],
      bookingType: json['booking_type'],
      patientCondition: json['patient_condition'],
      pickupAddress: json['pickup_address'],
      pickupLat: (json['pickup_lat'] as num).toDouble(),
      pickupLng: (json['pickup_lng'] as num).toDouble(),
      pickupH3: json['pickup_h3'],
      destinationAddress: json['destination_address'],
      destinationLat: (json['destination_lat'] as num).toDouble(),
      destinationLng: (json['destination_lng'] as num).toDouble(),
      userId: json['user_id'],
      status: parseBookingStatus(json['status']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Booking copyWith({
    String? ambulanceId,
    String? driverId,
    BookingStatus? status,
  }) {
    return Booking(
      id: id,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      providerId: providerId,
      driverId: driverId ?? this.driverId,
      bookingType: bookingType,
      patientCondition: patientCondition,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupH3: pickupH3,
      destinationAddress: destinationAddress,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      userId: userId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
