import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class IncidentLiveMapScreen extends StatefulWidget {
  const IncidentLiveMapScreen({super.key});
  @override
  State<IncidentLiveMapScreen> createState() => _IncidentLiveMapScreenState();
}

class _IncidentLiveMapScreenState extends State<IncidentLiveMapScreen> {
  MapboxMap? mapboxMap;

  void _onMapCreated(MapboxMap controller) {
    mapboxMap = controller;
    mapboxMap!.setCamera(CameraOptions(
      center: Point(coordinates: Position(106.67393252105423, 10.831951418898154)),
      zoom: 12.0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final styleUrl = dotenv.env['GOONG_STYLE_URL']!;
    return Scaffold(
      body: MapWidget(
        key: const ValueKey("map"),
        styleUri: styleUrl,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}