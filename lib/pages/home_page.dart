import 'package:flutter/material.dart';
import 'package:footwear_client/controller/home_controller.dart';
import 'package:footwear_client/pages/login_page.dart';
import 'package:footwear_client/pages/product_description_page.dart';
import 'package:footwear_client/widgets/drop_down_button.dart';
import 'package:footwear_client/widgets/multi_select_drop_down.dart';
import 'package:footwear_client/widgets/product_card.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (ctrl) {
      return RefreshIndicator(
        onRefresh: () async {
          ctrl.fetchProducts();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Footwear Store',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
            ),
            centerTitle: true,
            actions: [IconButton(onPressed: () {
              GetStorage box = GetStorage();
              box.erase();
              Get.offAll(LoginPage());
            }, icon: Icon(Icons.logout))
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ctrl.productsCategory.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){
                         ctrl.filterByCategory(ctrl.productsCategory[index].name ?? '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Chip(label: Text(ctrl.productsCategory[index].name ?? 'Error')),
                        ),
                      );
                    }),
              ),
              Row(
                children: [
                  Flexible(
                    child: DropDownButton(
                        items: ['Price: Low to High', 'Price: High to Low'],
                        selectedItemText: 'Sort',
                        onSelected: (selected) {
                          ctrl.sortByPrice(ascending : selected == 'Price: Low to High' ? true : false);
                        }),
                  ),
                  Flexible(
                      child: MultiSelectDropDown(
                        items: ['Puma', 'Skechers', 'Adidas', 'Nike'],
                        onSelectionChanged: (selectedItems) {
                          ctrl.filterByBrand(selectedItems);
                        },
                      )),
                ],
              ),
              Expanded(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: ctrl.productsShowInUi.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        name: ctrl.productsShowInUi[index].name ?? 'No name',
                        imageUrl:
                            ctrl.productsShowInUi[index].image ?? 'url',
                        price: ctrl.productsShowInUi[index].price ?? 00,
                        offerTag: '20% off',
                        onTap: () {
                         Get.to(ProductDescriptionPage(),
                         arguments: {
                           'data': ctrl.productsShowInUi[index]
                         });
                        },
                      );
                    }),
              )
            ],
          ),
        ),
      );
    });
  }
}
