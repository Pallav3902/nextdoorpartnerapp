import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nextdoorpartner/bloc/coupon_product_bloc.dart';
import 'package:nextdoorpartner/bloc/product_templates_bloc.dart';
import 'package:nextdoorpartner/bloc/products_bloc.dart';
import 'package:nextdoorpartner/models/coupon_product_model.dart';
import 'package:nextdoorpartner/models/product_model.dart';
import 'package:nextdoorpartner/models/product_template_model.dart';
import 'package:nextdoorpartner/resources/api_response.dart';
import 'package:nextdoorpartner/resources/db_operation_response.dart';
import 'package:nextdoorpartner/ui/app_bar.dart';
import 'package:nextdoorpartner/ui/product.dart';
import 'package:nextdoorpartner/ui/product_category.dart';
import 'package:nextdoorpartner/util/app_theme.dart';
import 'package:nextdoorpartner/util/strings_en.dart';
import 'package:shimmer/shimmer.dart';

import 'data_placeholder.dart';

class CouponProduct extends StatefulWidget {
  final List<int> selectedProductIds;

  CouponProduct(this.selectedProductIds);

  @override
  _CouponProductState createState() => _CouponProductState();
}

class _CouponProductState extends State<CouponProduct> {
  CouponProductsBloc couponProductsBloc;
  ScrollController scrollController;
  bool isEnd = false;
  String searchQuery = '';
  TextEditingController searchTextEditingController = TextEditingController();
  BoxDecoration boxDecoration = BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5)));

  bool showBackButton = false;

  select(int index) {
    couponProductsBloc.selectProduct(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.background_grey,
        appBar: CustomAppBar(),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return true;
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                controller: scrollController,
                child: StreamBuilder(
                  stream: couponProductsBloc.productsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<ApiResponse<List<CouponProductModel>>>
                          snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        margin: EdgeInsets.only(top: 10),
                        color: Colors.white,
                        child: Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          baseColor: Colors.grey[200],
                          highlightColor: Colors.grey[100],
                          enabled: true,
                          child: SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: ListView.separated(
                                separatorBuilder: (context, index) => SizedBox(
                                  height: 30,
                                ),
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                itemCount: 6,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 80,
                                        decoration: boxDecoration,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            height: 20,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                130,
                                            decoration: boxDecoration,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 20,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                160,
                                            decoration: boxDecoration,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 20,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                190,
                                            decoration: boxDecoration,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      if (snapshot.data.message == 'end' ||
                          snapshot.data.data.length < 6) {
                        isEnd = true;
                      }
                      return snapshot.data.data.length == 0
                          ? Center(
                              child: NoDataPlaceholderWidget(
                                imageUrl: 'product_placeholder.png',
                                info: Strings.productPlaceholder,
                              ),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: AppTheme.grey,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: TextFormField(
                                          controller:
                                              searchTextEditingController,
                                          cursorColor: AppTheme.secondary_color,
                                          onFieldSubmitted: (value) => {},
                                          onChanged: (value) {
                                            searchQuery = value;
                                            couponProductsBloc
                                                .getProducts(searchQuery);
                                            isEnd = false;
                                          },
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.secondary_color,
                                              fontSize: 18),
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              hintStyle: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.grey,
                                                  fontSize: 18),
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: 10,
                                                  bottom: 11,
                                                  top: 11,
                                                  right: 10),
                                              hintText: Strings.search),
                                          onEditingComplete: () {},
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.highlight_off,
                                            color: AppTheme.grey,
                                          ),
                                          onPressed: () {
                                            if (searchTextEditingController.text
                                                    .trim() ==
                                                '') {
                                              return;
                                            }
                                            searchTextEditingController.clear();
                                            couponProductsBloc.getProducts('');
                                            isEnd = false;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50))),
                                ),
                                ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 2),
                                  itemCount: snapshot.data.data.length + 1,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    ///Return Single Widget
                                    return index == snapshot.data.data.length
                                        ? isEnd
                                            ? SizedBox()
                                            : Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: SizedBox(
                                                  height: 25,
                                                  width: 25,
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                        : ProductTemplateWidget(
                                            index: index,
                                            callback: select,
                                            couponProductModel:
                                                snapshot.data.data[index],
                                          );
                                  },
                                ),
                              ],
                            );
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(
                        context, couponProductsBloc.selectedProductIds);
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: AppTheme.green),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          Strings.done,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    couponProductsBloc = CouponProductsBloc(widget.selectedProductIds);
    couponProductsBloc.getProducts(searchQuery);
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (!isEnd) {
          couponProductsBloc.getProducts(searchQuery);
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    couponProductsBloc.dispose();
    super.dispose();
  }
}

class ProductTemplateWidget extends StatelessWidget {
  final Function callback;
  final int index;
  final CouponProductModel couponProductModel;

  ProductTemplateWidget({this.callback, this.index, this.couponProductModel});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        callback(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: Strings.hostUrl +
                        couponProductModel.productModel.images[0].imageUrl,
//                  imageUrl,
                    height: 80,
                    width: 80,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      couponProductModel.productModel.name,
//                      name,
                      style: TextStyle(
                          color: AppTheme.secondary_color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    Text(
                      couponProductModel.productModel.brand,
//                      brand,
                      style: TextStyle(
                          color: AppTheme.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    Text(
                      '${Strings.mrp}: Rs. ${couponProductModel.productModel.mrp}',
                      style: TextStyle(
                          color: AppTheme.secondary_color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    Text(
                      '${Strings.selling}: Rs. ${(couponProductModel.productModel.mrp - (couponProductModel.productModel.mrp * couponProductModel.productModel.discountPercentage / 100)).toStringAsFixed(1)}',
                      style: TextStyle(
                          color: AppTheme.secondary_color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    )
                  ],
                )
              ],
            ),
            Expanded(
                child: SizedBox(
              width: 10,
            )),
            Checkbox(
              value: couponProductModel.isSelected,
              onChanged: (value) {
                callback(index);
              },
            ),
            SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }
}
