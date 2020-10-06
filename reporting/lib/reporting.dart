/// Support for doing something awesome.
///
/// More dartdocs go here.
library reporting;

export 'src/reporting_base.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:usage/usage_io.dart';
import 'package:tool_base/tool_base.dart';

part 'src/crash_reporting.dart';
part 'src/disabled_usage.dart';
part 'src/events.dart';
part 'src/usage.dart';