class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final String ambulancePlate;
  final bool isAvailable;
  final String ambulanceType;

  Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.ambulancePlate,
    required this.isAvailable,
    required this.ambulanceType,
  });
}

final List<Driver> dummyDrivers = [
  Driver(
    id: 'DRV001',
    name: 'Andi Wijaya',
    phoneNumber: '081234567890',
    ambulancePlate: 'B 1234 ABC',
    isAvailable: false,
    ambulanceType: 'Ambulance Medis',
  ),
  Driver(
    id: 'DRV002',
    name: 'Eko Prasetyo',
    phoneNumber: '081234567891',
    ambulancePlate: 'B 5678 DEF',
    isAvailable: true,
    ambulanceType: 'Ambulance Medis',
  ),
  Driver(
    id: 'DRV003',
    name: 'Iwan Setiawan',
    phoneNumber: '081234567892',
    ambulancePlate: 'B 9012 GHI',
    isAvailable: true,
    ambulanceType: 'Ambulance Sosial',
  ),
  Driver(
    id: 'DRV004',
    name: 'Rudi Hermawan',
    phoneNumber: '081234567893',
    ambulancePlate: 'B 3456 JKL',
    isAvailable: true,
    ambulanceType: 'Ambulance Jenazah',
  ),
];
