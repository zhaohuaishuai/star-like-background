import 'dart:js' as js;
import './utils.dart';

void setTitle(String title) {
  if (PlatformUtils.isWeb) {
    js.context.callMethod('setTitle', [title]);
  }
}

void webDebug() {
  if (PlatformUtils.isWeb) {
    js.context.callMethod('webDebug');
  }
}

bool isAndroid() {
  if (PlatformUtils.isWeb) {
    return js.context.callMethod('isAndroid');
  }
  return false;
}

bool isIOS() {
  if (PlatformUtils.isWeb) {
    return js.context.callMethod('isIOS');
  }
  return false;
}

int webHistoryLength() {
  if (PlatformUtils.isWeb) {
    return js.context.callMethod('webHistoryLength');
  }
  return 1;
}
