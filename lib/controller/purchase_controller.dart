import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:footwear_client/pages/home_page.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'login_controller.dart'; // Assuming the LoginController is defined in this file

class PurchaseController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference orderCollection;

  TextEditingController addressController = TextEditingController();

  double orderPrice = 0;
  String itemName = '';
  String orderAddress = '';

  @override
  void onInit() {
    orderCollection = firestore.collection('orders');
    super.onInit();
  }

  void submitOrder({
    required double price,
    required String item,
    required String description,
  }) {
    orderPrice = price;
    itemName = item;
    orderAddress = addressController.text;

    Razorpay _razorpay = Razorpay();
    var options = {
      'key': 'rzp_test_aVs4LnmntAwFri',
      'amount': price * 100,
      'name': item,
      'description': description,
    };

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await orderSuccess(transactionId: response.paymentId);
    Get.snackbar('Success', 'Payment is successful', colorText: Colors.green);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Error', '${response.message}', colorText: Colors.red);
  }

  Future<void> orderSuccess({required String? transactionId}) async {
    try {
      LoginController loginController = Get.find();
      var loginUsers = loginController.loginUsers;
      if (transactionId != null && loginUsers != null) {
        DocumentReference docRef = await orderCollection.add({
          'customer': loginUsers.name,
          'phone': loginUsers.number,
          'item': itemName,
          'price': orderPrice,
          'address': orderAddress,
          'transactionId': transactionId,
          'dateTime': DateTime.now().toString(),
        });
        print("Order Created Successfully: ${docRef.id}");
        showOrderSuccessDialog(docRef.id);
        Get.snackbar('Success', 'Order Created Successfully',
            colorText: Colors.green);
      } else {
        Get.snackbar('Error', 'Please fill all the fields',
            colorText: Colors.red);
      }
    } catch (error) {
      print("Failed to create order: $error");
      Get.snackbar('Error', 'Failed to create order', colorText: Colors.red);
    }
  }
}

void showOrderSuccessDialog(String orderId) {
  Get.defaultDialog(
    title: 'Order Success',
    content: Text("Your OrderId is $orderId"),
    confirm: ElevatedButton(
        onPressed: () {
          Get.off(const HomePage());
        },
        child: const Text('Close')),
  );
}
