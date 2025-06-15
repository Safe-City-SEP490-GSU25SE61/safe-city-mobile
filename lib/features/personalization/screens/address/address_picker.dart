// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class LocationPicker extends StatefulWidget {
//   const LocationPicker({super.key});
//
//   @override
//   LocationPickerState createState() => LocationPickerState();
// }
//
// class LocationPickerState extends State<LocationPicker> {
//   late GoogleMapController mapController;
//   LatLng? _currentPosition;
//   String _currentAddress = '';
//   double radius = 100.0; // Radius in meters
//
//   ScaffoldMessengerState? _scaffoldMessengerState;
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     if (kDebugMode) {
//       print('Map created');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }
//
//   Future<void> _checkPermissions() async {
//     if (await Permission.location.request().isGranted) {
//       _getCurrentLocation();
//     } else {
//       _scaffoldMessengerState?.showSnackBar(
//         const SnackBar(
//           content: Text('Location permissions are required to use this feature.'),
//         ),
//       );
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//       setState(() {
//         _currentPosition = LatLng(position.latitude, position.longitude);
//       });
//       if (kDebugMode) {
//         print('Current position: $_currentPosition');
//       }
//       _getAddressFromLatLng(_currentPosition!);
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error getting location: $e');
//       }
//     }
//   }
//
//   Future<void> _getAddressFromLatLng(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//       Placemark place = placemarks[0];
//       setState(() {
//         _currentAddress =
//         "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
//       });
//       if (kDebugMode) {
//         print('Current address: $_currentAddress');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error getting address: $e');
//       }
//     }
//   }
//
//   bool _isWithinCircle(LatLng center, LatLng point, double radius) {
//     double distance = Geolocator.distanceBetween(
//       center.latitude,
//       center.longitude,
//       point.latitude,
//       point.longitude,
//     );
//     return distance <= radius;
//   }
//
//   @override
//   void dispose() {
//     mapController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Vui lòng chọn địa chỉ'),
//       ),
//       body: _currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _currentPosition!,
//               zoom: 18,
//             ),
//             mapType: MapType.normal,
//             trafficEnabled: true,
//             myLocationEnabled: true,
//             buildingsEnabled: true,
//             onMapCreated: _onMapCreated,
//             onTap: (LatLng position) {
//               if (_isWithinCircle(_currentPosition!, position, radius)) {
//                 _getAddressFromLatLng(position);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                         'Địa chỉ đã chọn quá xa vị trí hiện tại của bạn vui lòng thử lại'),
//                   ),
//                 );
//               }
//             },
//             circles: {
//               Circle(
//                 circleId: const CircleId('restrictedArea'),
//                 center: _currentPosition!,
//                 radius: radius,
//                 fillColor: Colors.orange.withOpacity(0.2),
//                 strokeColor: Colors.orange,
//                 strokeWidth: 2,
//               ),
//             },
//           ),
//           Positioned(
//             bottom: 12,
//             left: 10,
//             right: 60,
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Địa chỉ :',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       _currentAddress,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 10),
//                     SizedBox(
//                       height: 40,
//                       width: 100,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context, {
//                             'latitude': _currentPosition!.latitude,
//                             'longitude': _currentPosition!.longitude,
//                             'address': _currentAddress,
//                           });
//                         },
//                         child: const Text('Xác nhận'),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }