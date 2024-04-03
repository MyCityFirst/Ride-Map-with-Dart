// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide LatLng;
import 'package:google_maps_flutter/google_maps_flutter.dart' as latlng;
import 'dart:math' show cos, sqrt, asin;

class RideRouteDetailsPopupView extends StatefulWidget {
  const RideRouteDetailsPopupView({
    Key? key,
    this.width,
    this.height,
    required this.startCoordinate,
    required this.endCoordinate,
    required this.updateInterval,
    required this.iOSGoogleMapsApiKey,
    required this.androidGoogleMapsApiKey,
    required this.webGoogleMapsApiKey,
    required this.rideDetailsReference,
    this.lineColor = Colors.black,
    this.startAddress,
    this.destinationAddress,
    required this.isDriver,
  }) : super(key: key);

  final double? height;
  final double? width;
  final int updateInterval;
  final Color lineColor;
  final LatLng startCoordinate;
  final LatLng endCoordinate;
  final String? startAddress;
  final String? destinationAddress;
  final String iOSGoogleMapsApiKey;
  final String androidGoogleMapsApiKey;
  final String webGoogleMapsApiKey;
  final DocumentReference rideDetailsReference;
  final bool isDriver;

  @override
  _RideRouteDetailsPopupViewState createState() =>
      _RideRouteDetailsPopupViewState();
}

class _RideRouteDetailsPopupViewState extends State<RideRouteDetailsPopupView> {
  Timer? _timer;
  late final CameraPosition _initialLocation;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Map<PolylineId, Polyline> initialPolylines = {};

  String get googleMapsApiKey {
    if (kIsWeb) {
      return widget.webGoogleMapsApiKey;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
      case TargetPlatform.iOS:
        return widget.iOSGoogleMapsApiKey;
      case TargetPlatform.android:
        return widget.androidGoogleMapsApiKey;
      default:
        return widget.webGoogleMapsApiKey;
    }
  }

  Future<Map<PolylineId, Polyline>?> _calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    if (markers.isNotEmpty) markers.clear();

    try {
      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: latlng.LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Local de Partida $startCoordinatesString',
          snippet: widget.startAddress ?? '',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: latlng.LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Local de Destino $destinationCoordinatesString',
          snippet: widget.destinationAddress ?? '',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers.add(startMarker);
      markers.add(destinationMarker);

      log(
        'MAP::START COORDINATES: ($startLatitude, $startLongitude)',
      );
      log(
        'MAP::DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: latlng.LatLng(northEastLatitude, northEastLongitude),
            southwest: latlng.LatLng(southWestLatitude, southWestLongitude),
          ),
          60.0,
        ),
      );

      final result = await _createPolylines(
        startLatitude,
        startLongitude,
        destinationLatitude,
        destinationLongitude,
      );

      final polylines = result.item1;
      final polylineCoordinates = result.item2;

      double totalDistance = 0.0;

      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      final placeDistance = totalDistance.toStringAsFixed(2);
      debugPrint('MAP::DISTANCE: $placeDistance km');
      FFAppState().update(() {
        FFAppState().routeDistance = '$placeDistance km';
      });

      var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$destinationLatitude,$destinationLongitude&origins=$startLatitude,$startLongitude&key=$googleMapsApiKey',
      );
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        final String durationText =
            jsonResponse['rows'][0]['elements'][0]['duration']['text'];
        log('MAP::$durationText');
        FFAppState().update(() {
          FFAppState().routeDuration = '$durationText';
        });
      } else {
        log('ERROR in distance matrix API');
      }

      return polylines;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Tuple2<Map<PolylineId, Polyline>, List<latlng.LatLng>>>
      _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapsApiKey,
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    List<latlng.LatLng> polylineCoordinates = [];

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(latlng.LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: widget.lineColor,
      points: polylineCoordinates,
      width: 3,
    );

    return Tuple2({id: polyline}, polylineCoordinates);
  }

  initPolylines() async {
    double startLatitude = widget.startCoordinate.latitude;
    double startLongitude = widget.startCoordinate.longitude;

    double destinationLatitude = widget.endCoordinate.latitude;
    double destinationLongitude = widget.endCoordinate.longitude;
    final initPolylines = await _calculateDistance(
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
    );
    if (initPolylines != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          initialPolylines = initPolylines;
        });
      });
    }
  }

  void updateLocation() async {
    _timer =
        Timer.periodic(Duration(seconds: widget.updateInterval), (timer) async {
      LatLng currentUserLocationValue = await getCurrentUserLocation(
        defaultLocation: const LatLng(0.0, 0.0),
      );

      DocumentSnapshot rideSnapshot = await widget.rideDetailsReference.get();
      var rideData = rideSnapshot.data() as Map<String, dynamic>;

      double distanceToDestination = _coordinateDistance(
        widget.isDriver
            ? currentUserLocationValue.latitude
            : rideData['userLocation']['latitude'],
        widget.isDriver
            ? currentUserLocationValue.longitude
            : rideData['userLocation']['longitude'],
        rideData['destinationLocation']['latitude'],
        rideData['destinationLocation']['longitude'],
      );

      if (distanceToDestination <= 50) {
        await widget.rideDetailsReference.update({
          'going_destination': true,
        });
      } else {
        await widget.rideDetailsReference.update({
          'going_destination': false,
        });
      }

      Map<String, dynamic> rideUpdateData;

      if (widget.isDriver) {
        rideUpdateData = createRideRecordData(
          driverLocation: currentUserLocationValue,
        );
      } else {
        rideUpdateData = createRideRecordData(
          userLocation: currentUserLocationValue,
        );
      }

      await widget.rideDetailsReference.update(
        rideUpdateData,
      );
    });
  }

  @override
  void initState() {
    final _startCoordinate = latlng.LatLng(
      widget.startCoordinate.latitude,
      widget.startCoordinate.longitude,
    );
    _initialLocation = CameraPosition(
      target: _startCoordinate,
      zoom: 14,
    );

    updateLocation();

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RideRecord>(
      stream: RideRecord.getDocument(widget.rideDetailsReference),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: widget.height,
            width: widget.width,
            child: GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(initialPolylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                initPolylines();
              },
            ),
          );
        }

        final rideRecord = snapshot.data;

        return Container(
          height: widget.height,
          width: widget.width,
          child: FutureBuilder<Map<PolylineId, Polyline>?>(
            future: _calculateDistance(
              startLatitude: widget.isDriver
                  ? rideRecord!.driverLocation!.latitude
                  : rideRecord!.userLocation!.latitude,
              startLongitude: widget.isDriver
                  ? rideRecord!.driverLocation!.longitude
                  : rideRecord!.userLocation!.longitude,
              destinationLatitude: rideRecord.destinationLocation!.latitude,
              destinationLongitude: rideRecord.destinationLocation!.longitude,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return GoogleMap(
                  markers: Set<Marker>.from(markers),
                  initialCameraPosition: CameraPosition(
                    target: latlng.LatLng(
                      widget.isDriver
                          ? rideRecord!.driverLocation!.latitude
                          : rideRecord!.userLocation!.latitude,
                      widget.isDriver
                          ? rideRecord!.driverLocation!.longitude
                          : rideRecord!.userLocation!.longitude,
                    ),
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(initialPolylines.values),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                );
              }

              return GoogleMap(
                markers: Set<Marker>.from(markers),
                initialCameraPosition: CameraPosition(
                  target: latlng.LatLng(
                    widget.isDriver
                        ? rideRecord!.driverLocation!.latitude
                        : rideRecord!.userLocation!.latitude,
                    widget.isDriver
                        ? rideRecord!.driverLocation!.longitude
                        : rideRecord!.userLocation!.longitude,
                  ),
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                polylines: Set<Polyline>.of(snapshot.data!.values),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              );
            },
          ),
        );
      },
    );
  }
}