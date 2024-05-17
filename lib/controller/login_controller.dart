import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:footwear_client/pages/home_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';

import '../models/users.dart';

class LoginController extends GetxController {

  GetStorage box = GetStorage();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference usersCollection;

  TextEditingController registerNameCtrl = TextEditingController();
  TextEditingController registerNumberCtrl = TextEditingController();
  TextEditingController loginNumberCtrl = TextEditingController();

  OtpFieldControllerV2 otpController = OtpFieldControllerV2();
  bool otpFieldShown = false;
  int? otpSend;
  int? otpEnter;

 Users? loginUsers;

  @override
  void onReady() {
    Map<String, dynamic>? users = box.read('loginUsers');
    if (users != null) {
      loginUsers = Users.fromJson(users);
      Get.to(const HomePage());
    }

    super.onReady();
  }

  @override
  void onInit() {
    usersCollection = firestore.collection('users');
    super.onInit();
  }

  addUsers() {
    try {
      if (otpSend == otpEnter) {
        DocumentReference doc = usersCollection.doc();
        Users users = Users(
          id: doc.id,
          name: registerNameCtrl.text,
          number: int.parse(registerNumberCtrl.text),
        );
        final usersJson = users.toJson();
        doc.set(usersJson);
        Get.snackbar('Success', 'User added successfully',
            colorText: Colors.green);
        registerNumberCtrl.clear();
        registerNameCtrl.clear();
        otpController.clear();
      } else {
        Get.snackbar('Error', 'OTP is incorrect', colorText: Colors.red);
      }
      if (registerNumberCtrl.text.isEmpty || registerNameCtrl.text.isEmpty) {
        Get.snackbar('Error', 'Please fill the fields', colorText: Colors.red);
        // to stop the code
        return;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.red);
      print(e);
    }
  }

  Future<void> sendOtp() async {
    try {
      if (registerNumberCtrl.text.isEmpty || registerNumberCtrl.text.isEmpty) {
        Get.snackbar('Error', 'Please fill the fields', colorText: Colors.red);
        return;
      }
      final random = Random();
      int otp = 1000 + random.nextInt(9000);
      //GetConnect

      print(otp); // Mocking sending OTP

      if (otp != null) {
        otpFieldShown = true;
        otpSend = otp;
        Get.snackbar('Success', 'OTP sent successfully!',
            colorText: Colors.green);
      } else {
        Get.snackbar('Error', 'OTP not sent!', colorText: Colors.red);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to send OTP', colorText: Colors.red);
    } finally {
      update();
    }
  }

  Future<void> loginWithPhone() async {
    try {
      String phoneNumber = loginNumberCtrl.text;
      if (phoneNumber.isNotEmpty) {
        var querySnapshot = await usersCollection
            .where('number', isEqualTo: int.tryParse(phoneNumber))
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          var usersDoc = querySnapshot.docs.first;
          var usersData = usersDoc.data() as Map<String, dynamic>;
          box.write('loginUsers', usersData);
          loginNumberCtrl.clear();
          Get.to(const HomePage());
          Get.snackbar('Success', 'Login Successful', colorText: Colors.green);
        } else {
          Get.snackbar("Error", 'User not found, Please Register',
              colorText: Colors.red);
        }
      } else {
        Get.snackbar('Error', 'Phone number cannot be empty',
            colorText: Colors.red);
      }
    } catch (error) {
      print("Failed to login : $error");
      Get.snackbar('Error', 'Failed to login', colorText: Colors.red);
    }
  }
}
