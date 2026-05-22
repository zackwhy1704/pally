import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final appLog = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 10,
    lineLength: 100,
    colors: false,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: kReleaseMode ? Level.warning : Level.trace,
);
