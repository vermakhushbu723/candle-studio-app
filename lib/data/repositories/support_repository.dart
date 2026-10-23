import '../../core/network/api_client.dart';

/// Contact form, chatbot callbacks and notification settings.
class SupportRepository {
  /// POST /inquiries — Contact page form. Returns the thank-you message.
  Future<String> sendInquiry({required String name, required String email, String? phone, required String topic, required String message}) async {
    final r = await api.post('/inquiries', {
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'topic': topic,
      'message': message,
    });
    return '${r['message'] ?? 'Thanks! We’ll get back to you within 24 hours.'}';
  }

  /// POST /tickets — chatbot "call me back" request. Returns the ticket ID (e.g. CD-123456).
  Future<String> createTicket({required String name, required String phone, required String topic, required String message}) async {
    final r = await api.post('/tickets', {'name': name, 'phone': phone, 'topic': topic, 'message': message});
    return '${r['ticketId'] ?? ''}';
  }

  /// POST /notifications/devices — link this phone's push token to the account.
  Future<void> addDevice(String token, String device) => api.post('/notifications/devices', {'token': token, 'device': device});

  /// DELETE /notifications/devices — on logout.
  Future<void> removeDevice(String token) => api.delete('/notifications/devices', {'token': token});

  /// GET /notifications/preferences
  Future<bool> offersEnabled() async => (await api.get('/notifications/preferences'))['notifyOffers'] != false;

  /// PUT /notifications/preferences
  Future<void> setOffers(bool value) => api.put('/notifications/preferences', {'notifyOffers': value});
}
