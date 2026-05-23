// ignore_for_file: uri_does_not_exist, avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;

Future<String?> predictHerb(String base64Image) async {
  try {
    final promise = js_util.callMethod(js_util.globalThis, 'predictHerb', [base64Image]);
    final result = await js_util.promiseToFuture(promise);
    return result?.toString();
  } catch (e) {
    print("JS Error: $e");
    return null;
  }
}
