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

List<dynamic> getKeysOrValues(
  dynamic map,
  bool keys,
  int start,
  int end,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  List<dynamic> allItems = keys ? map.keys.toList() : map.values.toList();

  if (start == -1 && end == -1) {
    return allItems;
  } else {
    return allItems.sublist(start, end);
  }

  /// MODIFY CODE ONLY ABOVE THIS LINE
}