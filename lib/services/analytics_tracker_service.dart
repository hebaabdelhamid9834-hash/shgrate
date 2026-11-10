import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sends the app events required by the TikTok and Meta ad platforms.
///
/// All calls are best-effort: an analytics outage or a missing native
/// credential must never interrupt shopping, authentication, or checkout.
class AnalyticsTrackerService {
  AnalyticsTrackerService._();

  static final AnalyticsTrackerService instance = AnalyticsTrackerService._();

  static const MethodChannel _channel = MethodChannel('shgarde/marketing_analytics');

  final FacebookAppEvents _meta = FacebookAppEvents();
  bool _initialized = false;

  String get _currency => 'KWD';

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _meta.initializeSdk();
      await _meta.setAutoLogAppEventsEnabled(true);
    } catch (error) {
      debugPrint('Marketing analytics initialization failed: $error');
    }

    try {
      await _channel.invokeMethod<bool>('initializeTikTok');
    } catch (error) {
      debugPrint('TikTok initialization failed: $error');
    }

    _initialized = true;
  }

  Future<void> requestTrackingAuthorization() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    try {
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      await _meta.setAdvertiserIdCollectionEnabled(
        status == TrackingStatus.authorized,
      );
    } catch (error) {
      debugPrint('Tracking authorization failed: $error');
    }
  }

  Future<void> identify({
    required String userId,
    String? name,
    String? phone,
    String? email,
  }) async {
    await _ensureInitialized();
    if (userId.trim().isEmpty) return;

    try {
      await _meta.setUserID(userId);
      await _meta.setUserData(
        externalId: userId,
        email: email,
        phone: phone,
        firstName: name,
      );
    } catch (error) {
      debugPrint('Meta identify failed: $error');
    }

    try {
      await _channel.invokeMethod<void>('identifyTikTok', {
        'externalId': userId,
        'externalUserName': name,
        'phone': phone,
        'email': email,
      });
    } catch (error) {
      debugPrint('TikTok identify failed: $error');
    }
  }

  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic> properties = const {},
    double? value,
  }) async {
    await _ensureInitialized();
    try {
      await _meta.logEvent(
        name: eventName,
        parameters: properties,
        valueToSum: value,
      );
    } catch (error) {
      debugPrint('Meta event $eventName failed: $error');
    }

    await _trackTikTok(eventName, properties);
  }

  Future<void> _trackTikTok(
    String eventName,
    Map<String, dynamic> properties,
  ) async {
    try {
      await _channel.invokeMethod<void>('trackTikTok', {
        'eventName': eventName,
        'properties': properties,
      });
    } catch (error) {
      debugPrint('TikTok event $eventName failed: $error');
    }
  }

  Future<void> logRegistration({required String method}) async {
    await _ensureInitialized();
    try {
      await _meta.logCompletedRegistration(registrationMethod: method);
    } catch (error) {
      debugPrint('Meta registration event failed: $error');
    }
    await _trackTikTok('Registration', {'method': method});
  }

  Future<void> logLogin({required String method}) async {
    await _ensureInitialized();
    await trackEvent('Login', properties: {'method': method});
  }

  Future<void> logViewContent({
    required String contentId,
    required String contentName,
    required double price,
  }) async {
    await _ensureInitialized();
    try {
      await _meta.logViewContent(
        id: contentId,
        type: 'product',
        currency: _currency,
        price: price,
        content: {'name': contentName},
      );
    } catch (error) {
      debugPrint('Meta view content event failed: $error');
    }
    await _trackTikTok(
      'ViewContent',
      {
        'content_id': contentId,
        'content_name': contentName,
        'content_type': 'product',
        'currency': _currency,
        'value': price,
      },
    );
  }

  Future<void> logAddToCart({
    required String contentId,
    required String contentName,
    required double price,
    required int quantity,
  }) async {
    await _ensureInitialized();
    try {
      await _meta.logAddToCart(
        id: contentId,
        type: 'product',
        currency: _currency,
        price: price,
        content: {'name': contentName, 'quantity': quantity},
      );
    } catch (error) {
      debugPrint('Meta add to cart event failed: $error');
    }
    await _trackTikTok(
      'AddToCart',
      {
        'content_id': contentId,
        'content_name': contentName,
        'content_type': 'product',
        'currency': _currency,
        'value': price,
        'quantity': quantity,
      },
    );
  }

  Future<void> logInitiateCheckout({
    required double total,
    int? itemCount,
  }) async {
    await _ensureInitialized();
    try {
      await _meta.logInitiatedCheckout(
        totalPrice: total,
        currency: _currency,
        contentType: 'product',
        numItems: itemCount,
      );
    } catch (error) {
      debugPrint('Meta initiate checkout event failed: $error');
    }
    await _trackTikTok(
      'InitiateCheckout',
      {
        'currency': _currency,
        'value': total,
        if (itemCount != null) 'quantity': itemCount,
      },
    );
  }

  Future<void> logPurchase({required double total}) async {
    await _ensureInitialized();
    try {
      await _meta.logPurchase(amount: total, currency: _currency);
    } catch (error) {
      debugPrint('Meta purchase event failed: $error');
    }
    await _trackTikTok(
      'Purchase',
      {'currency': _currency, 'value': total},
    );
  }

  Future<void> logSearch(String query) async {
    await _ensureInitialized();
    if (query.trim().isEmpty) return;
    try {
      await _meta.logSearched(searchString: query);
    } catch (error) {
      debugPrint('Meta search event failed: $error');
    }
    await _trackTikTok('Search', {'query': query});
  }

  Future<void> logContact() async {
    await _ensureInitialized();
    try {
      await _meta.logContact();
    } catch (error) {
      debugPrint('Meta contact event failed: $error');
    }
    await _trackTikTok('Contact', const {});
  }

  Future<void> logAddPaymentInfo() async {
    await _ensureInitialized();
    try {
      await _meta.logAddedPaymentInfo();
    } catch (error) {
      debugPrint('Meta add payment info event failed: $error');
    }
    await _trackTikTok('AddPaymentInfo', const {});
  }
}
