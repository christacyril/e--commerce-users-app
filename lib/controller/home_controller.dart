import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:footwear_client/models/productCategory/products_category.dart';
import 'package:get/get.dart';

import '../models/product/product.dart';

class HomeController extends GetxController{
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference productsCollection;
  late CollectionReference categoryCollection;

  List<Product> products =[];
  List<Product> productsShowInUi =[];
  List<ProductsCategory> productsCategory =[];

  @override
  void onInit() async {
    productsCollection = firestore.collection("products");
    categoryCollection = firestore.collection("category");
    await fetchCategory();
    await fetchProducts();
    super.onInit();
  }



  fetchProducts() async {
    try {
      QuerySnapshot productsSnapshot = await productsCollection.get();
      final List<Product> retrievedProducts = productsSnapshot.docs.map((doc) =>
          Product.fromJson(doc.data() as Map<String, dynamic>)).toList();

      products.clear();
      products.assignAll(retrievedProducts);
      productsShowInUi.assignAll(products);
      Get.snackbar('Success', 'Product fetched successfully', colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Error',e.toString(), colorText: Colors.red);
      print(e);
    }finally{
      update();
    }
  }


  fetchCategory() async {
    try {
      QuerySnapshot categorySnapshot = await categoryCollection.get();
      final List<ProductsCategory> retrievedCategories = categorySnapshot.docs.map((doc) =>
          ProductsCategory.fromJson(doc.data() as Map<String, dynamic>)).toList();

      productsCategory.clear();
      productsCategory.assignAll(retrievedCategories);
    } catch (e) {
      Get.snackbar('Error',e.toString(), colorText: Colors.red);
      print(e);
    }finally{
      update();
    }
  }


  filterByCategory(String category) {
    productsShowInUi.clear();
    productsShowInUi = products.where((products) => products.category == category).toList();
    update();
  }

  filterByBrand(List<String> brands) {
    if (brands.isEmpty) {
      productsShowInUi = products;
    }else{
      List<String> lowerCaseBrands = brands.map((brand) => brand.toLowerCase()).toList();
      productsShowInUi = products.where((products)=> lowerCaseBrands.contains(products.brand?.toLowerCase())).toList();
    }
    update();
  }

  sortByPrice({required bool ascending}){
      List<Product> sortedProducts = List<Product>.from(productsShowInUi);
      sortedProducts.sort((a,b) => ascending ? a.price!.compareTo(b.price!) : b.price!.compareTo(a.price!));
      productsShowInUi = sortedProducts;
      update();
  }

}