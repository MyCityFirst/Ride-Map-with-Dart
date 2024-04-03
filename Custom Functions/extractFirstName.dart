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

String? extractFirstName(String? currentUserDisplayName) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  String? name = currentUserDisplayName;
  if (name == null || name.isEmpty) {
    return null;
  }
  final List<String> parts = name.split(' ');
  if (parts.isEmpty) {
    return null;
  }
  final String firstName = parts.first;
  return firstName.substring(0, 1).toUpperCase() +
      firstName.substring(1).toLowerCase();

  /// MODIFY CODE ONLY ABOVE THIS LINE
}