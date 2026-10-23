import 'package:url_launcher/url_launcher.dart';

import '../data/content/site_content.dart';

/// Opens phone, WhatsApp, email, maps and web links outside the app.
class Launcher {
  Launcher._();

  static Future<bool> open(String url) async {
    final uri = Uri.parse(url);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> call() => open(Site.phoneUrl);
  static Future<bool> email() => open('mailto:${Site.supportEmail}');
  static Future<bool> whatsapp([String text = 'Hi Jyotessa! I have a question.']) => open('${Site.whatsappUrl}?text=${Uri.encodeComponent(text)}');
  static Future<bool> maps() => open(Site.googleMapsUrl);
  static Future<bool> review() => open(Site.googleReviewUrl);
}
