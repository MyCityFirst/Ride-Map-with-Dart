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

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UserLocationDetails extends StatefulWidget {
  const UserLocationDetails({
    Key? key,
    this.width,
    this.height,
    this.fontSize = 16,
    required this.startCoordinate,
    required this.endCoordinate,
    required this.iOSGoogleMapsApiKey,
    required this.androidGoogleMapsApiKey,
    required this.webGoogleMapsApiKey,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double fontSize;
  final LatLng startCoordinate;
  final LatLng endCoordinate;
  final String iOSGoogleMapsApiKey;
  final String androidGoogleMapsApiKey;
  final String webGoogleMapsApiKey;

  @override
  State<UserLocationDetails> createState() => _UserLocationDetailsState();
}

class _UserLocationDetailsState extends State<UserLocationDetails> {
  String durationString = '';

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

  _retrieveDuration() async {
    double startLatitude = widget.startCoordinate.latitude;
    double startLongitude = widget.startCoordinate.longitude;
    double destinationLatitude = widget.endCoordinate.latitude;
    double destinationLongitude = widget.endCoordinate.longitude;

    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$destinationLatitude,$destinationLongitude&origins=$startLatitude,$startLongitude&key=$googleMapsApiKey',
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final String durationText =
          jsonResponse['rows'][0]['elements'][0]['duration']['text'];
      setState(() {
        durationString = durationText;
      });
    }
  }

  @override
  void initState() {
    _retrieveDuration();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          durationString,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        Visibility(
          visible: durationString.isNotEmpty,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Text(
              ' de distância',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}