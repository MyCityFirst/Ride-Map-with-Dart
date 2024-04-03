import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/flutter_flow/custom_functions.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/firebase_auth/auth_util.dart';

double calculateTripPrice(
  LatLng? userLocation,
  LatLng? destinationLocation,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  if (userLocation == null || destinationLocation == null) {
    return 0.0;
  }

  // Definição das tarifas
  final double baseFare = 1.82;
  final double pricePerKm = 1.25;
  final double pricePerMinute = 0.21;
  final double averageSpeedKmh = 60;
  final double insuranceFee = 0.35;

  var p = 0.017453292519943295;
  var c = math.cos;
  var a = 0.5 -
      c((destinationLocation.latitude - userLocation.latitude) * p) / 2 +
      c(userLocation.latitude * p) *
          c(destinationLocation.latitude * p) *
          (1 -
              c((destinationLocation.longitude - userLocation.longitude) * p)) /
          2;
  double distanceKm = 12742 * math.asin(math.sqrt(a));

  int durationMinutes = ((distanceKm / averageSpeedKmh) * 60).ceil();

  double distanceCost = distanceKm * pricePerKm;
  double timeCost = durationMinutes * pricePerMinute;

  double totalTripPrice = baseFare + distanceCost + timeCost + insuranceFee;
  double roundedPrice = double.parse(totalTripPrice.toStringAsFixed(2));
  return roundedPrice;

  /// MODIFY CODE ONLY ABOVE THIS LINE
}