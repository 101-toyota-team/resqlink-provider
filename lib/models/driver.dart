class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final String ambulancePlate;
  final String ambulanceId;
  final bool isAvailable;
  final String ambulanceType;

  Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.ambulancePlate,
    required this.ambulanceId,
    required this.isAvailable,
    required this.ambulanceType,
  });
}

final List<Driver> dummyDrivers = [
  Driver(
    id: '7ee455c9-dabb-42ac-ad1c-25e993d97283',
    name: 'Wildan Arifin',
    phoneNumber: '08111111111',
    ambulancePlate: 'B 7726 SIX',
    ambulanceId: "a3daf71c-ff1a-4a13-a63e-1bb71eb676c5",
    isAvailable: true,
    ambulanceType: 'Ambulance Medis',
  ),
  Driver(
    id: 'DRV002',
    name: 'Eko Prasetyo',
    phoneNumber: '081234567891',
    ambulancePlate: 'B 5678 DEF',
    ambulanceId: "idabc",
    isAvailable: true,
    ambulanceType: 'Ambulance Medis',
  ),
  Driver(
    id: 'DRV003',
    name: 'Iwan Setiawan',
    phoneNumber: '081234567892',
    ambulancePlate: 'B 9012 GHI',
    ambulanceId: "iddef",
    isAvailable: true,
    ambulanceType: 'Ambulance Sosial',
  ),
  Driver(
    id: 'DRV004',
    name: 'Rudi Hermawan',
    phoneNumber: '081234567893',
    ambulancePlate: 'B 3456 JKL',
    ambulanceId: "idghi",
    isAvailable: true,
    ambulanceType: 'Ambulance Jenazah',
  ),
];
