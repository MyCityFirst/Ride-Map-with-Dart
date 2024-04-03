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

dynamic convertProductToJSON(ProductRecord? productDoc) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  if (productDoc == null) {
    return null;
  }

  Map<String, Object> productJson = {
    'type': productDoc.type,
    'name': productDoc.name,
    'description': productDoc.description,
    'mass': productDoc.mass,
    'volume': productDoc.volume,
    'quantity': productDoc.quantity
  };

  return productJson;

  /// MODIFY CODE ONLY ABOVE THIS LINE
}