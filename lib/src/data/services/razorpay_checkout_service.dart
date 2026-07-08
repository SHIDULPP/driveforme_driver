import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayCheckoutService {
  RazorpayCheckoutService() : _razorpay = Razorpay();

  final Razorpay _razorpay;
  void Function(PaymentSuccessResponse response)? _onSuccess;
  void Function(PaymentFailureResponse response)? _onFailure;

  String get keyId => dotenv.env['RAZORPAY_KEY_ID']?.trim() ?? '';

  bool get isConfigured => keyId.isNotEmpty;

  void open({
    required String orderId,
    required double amount,
    required String name,
    required String contact,
    required void Function(PaymentSuccessResponse response) onSuccess,
    required void Function(PaymentFailureResponse response) onFailure,
  }) {
    if (!isConfigured) {
      throw StateError('Razorpay key is not configured.');
    }

    disposeListeners();
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleFailure);

    _razorpay.open({
      'key': keyId,
      'amount': (amount * 100).round(),
      'currency': 'INR',
      'name': 'Drive For Me',
      'order_id': orderId,
      'description': 'Wallet recharge',
      'prefill': {
        'contact': contact,
        'name': name,
      },
      'theme': {
        'color': '#1F4FD8',
      },
    });
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    _onSuccess?.call(response);
    disposeListeners();
  }

  void _handleFailure(PaymentFailureResponse response) {
    _onFailure?.call(response);
    disposeListeners();
  }

  void disposeListeners() {
    _razorpay.clear();
    _onSuccess = null;
    _onFailure = null;
  }

  void dispose() {
    disposeListeners();
  }
}
