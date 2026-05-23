import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final fontData = File('test/fonts/Nunito-Regular.ttf').readAsBytesSync();
  final fontLoader = FontLoader('Nunito')
    ..addFont(Future.value(ByteData.view(fontData.buffer)));
  await fontLoader.load();

  await testMain();
}
