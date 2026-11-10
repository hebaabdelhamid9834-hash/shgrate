import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart' as productMini;
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';

import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card_black.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/l10n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FlashDealProducts extends StatefulWidget {
  const FlashDealProducts({super.key, required this.slug});
  final String? slug;

  @override
  FlashDealProductsState createState() => FlashDealProductsState();
}

class FlashDealProductsState extends State<FlashDealProducts> {
  static const int _pageLimit = 20;

  CountdownTimerController? countdownTimerController;
  final List<productMini.Product> _products = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _hasError = false;

  FlashDealResponseDatum? flashDealInfo;

  // String timeText(String txt, {default_length = 3}) {
  //   var blank_zeros = default_length == 3 ? "000" : "00";
  //   var leading_zeros = "";
  //   if (txt != null) {
  //     if (default_length == 3 && txt.length == 1) {
  //       leading_zeros = "00";
  //     } else if (default_length == 3 && txt.length == 2) {
  //       leading_zeros = "0";
  //     } else if (default_length == 2 && txt.length == 1) {
  //       leading_zeros = "0";
  //     }
  //   }

  //   var newtxt = (txt == null || txt == "" || txt == null.toString())
  //       ? blank_zeros
  //       : txt;

  //   if (default_length > txt.length) {
  //     newtxt = leading_zeros + newtxt;
  //   }
  //   //print(newtxt);

  //   return newtxt;
  // }
  String timeText(String txt, {default_length = 3}) {
    var blankZeros = default_length == 3 ? "000" : "00";
    var leadingZeros = "";
    if (default_length == 3 && txt.length == 1) {
      leadingZeros = "00";
    } else if (default_length == 3 && txt.length == 2) {
      leadingZeros = "0";
    } else if (default_length == 2 && txt.length == 1) {
      leadingZeros = "0";
    }

    var newtxt = (txt == "" || txt == null.toString()) ? blankZeros : txt;

    if (default_length > txt.length) {
      newtxt = leadingZeros + newtxt;
    }

    return newtxt;
  }

  getInfo() async {
    try {
      var res = await FlashDealRepository().getFlashDealInfo(widget.slug);
      final info = res.flashDeals?.isNotEmpty == true ? res.flashDeals!.first : null;

      if (info != null) {
        flashDealInfo = info;

        if (info.date != null) {
          DateTime end = convertTimeStampToDateTime(info.date!);
          DateTime now = DateTime.now();
          int diff = end.difference(now).inMilliseconds;
          int endTime = diff + now.millisecondsSinceEpoch;

          countdownTimerController = CountdownTimerController(
            endTime: endTime,
            onEnd: () {},
          );
        }
      }
    } catch (_) {
      // The products remain usable even if the optional deal header fails.
    }

    if (mounted) setState(() {});
  }

  DateTime convertTimeStampToDateTime(int timeStamp) {
    var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return dateToTimeStamp;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getInfo();
    _fetchPage(1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 250 && _currentPage < _lastPage) {
      _fetchPage(_currentPage + 1);
    }
  }

  Future<void> _fetchPage(int page) async {
    if (_isLoading || page > _lastPage) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ProductRepository().getFlashDealProducts(
        dealId: widget.slug,
        page: page,
        limit: _pageLimit,
      );

      if (!mounted) return;

      final nextProducts = response.products ?? const <productMini.Product>[];
      setState(() {
        if (page == 1) _products.clear();
        _products.addAll(nextProducts);
        _currentPage = response.meta?.currentPage ?? page;
        _lastPage = response.meta?.lastPage ?? (nextProducts.length < _pageLimit ? page : page + 1);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: buildProductList(context),
      ),
    );
  }

  bool? shouldProductBoxBeVisible(productName, searchKey) {
    if (searchKey == "") {
      return true; //do not check if the search key is empty
    }
    return StringHelper().stringContains(productName, searchKey);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      toolbarHeight: 50,
      leadingWidth: 56,
      iconTheme: IconThemeData(color: MyTheme.dark_font_grey),
      leading: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          app_language_rtl.$! ? Icons.arrow_forward : Icons.arrow_back,
          color: MyTheme.dark_font_grey,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: flashDealInfo != null
          ? Text(
              '${flashDealInfo!.title}',
              style: TextStyle(
                color: Color(0xff3E4447),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          : Text('Loading.....'),
      elevation: 0.0,
      titleSpacing: 0,
      scrolledUnderElevation: 0.0,
    );
  }

  Widget buildProductList(BuildContext context) {
    final initialLoading = _isLoading && _products.isEmpty && !_hasError;

    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 0;
        _lastPage = 1;
        await _fetchPage(1);
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: buildFlashDealsBanner(context)),
          if (initialLoading)
            SliverToBoxAdapter(
              child: ShimmerHelper().buildProductGridShimmer(),
            )
          else if (_products.isEmpty && _hasError)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(context),
            )
          else if (_products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(AppLocalizations.of(context).no_product_is_available),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 10,
                left: 18,
                right: 18,
              ),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childCount: _products.length,
                itemBuilder: (context, index) => _buildProductCard(index),
              ),
            ),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (_hasError) SliverToBoxAdapter(child: _buildLoadMoreError(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = _products[index];
    return ProductCardBlack(
      id: product.id,
      slug: product.slug ?? '',
      image: product.thumbnail_image,
      name: product.name,
      main_price: product.main_price,
      stroked_price: product.stroked_price,
      has_discount: product.has_discount ?? false,
      discount: product.discount,
      is_wholesale: product.isWholesale,
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context).no_data_is_available),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _fetchPage(1),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: TextButton(
          onPressed: () => _fetchPage(_currentPage + 1),
          child: Text(AppLocalizations.of(context).load_more_ucf),
        ),
      ),
    );
  }

  Container buildFlashDealsBanner(BuildContext context) {
    return Container(
      //color: MyTheme.amber,
      height: 215,
      child: CountdownTimer(
        controller: countdownTimerController,
        widgetBuilder: (_, CurrentRemainingTime? time) {
          return Stack(
            children: [
              buildFlashDealBanner(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: DeviceInfo(context).width,
                  margin: EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: time == null
                            ? Text(
                                AppLocalizations.of(context).ended_ucf,
                                style: TextStyle(
                                  color: MyTheme.accent_color,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : buildTimerRow(time),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  headerShimmer() {
    return SizedBox(
      // color: MyTheme.amber,
      height: 215,
      child: Stack(
        children: [
          buildFlashDealBannerShimmer(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: DeviceInfo(context).width,
              margin: EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Container(child: buildTimerRowRowShimmer()),
            ),
          ),
        ],
      ),
    );
  }

  Container buildFlashDealBanner() {
    return Container(
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/placeholder_rectangle.png',
        image: flashDealInfo?.banner ?? "",
        fit: BoxFit.cover,
        width: DeviceInfo(context).width,
        height: 180,
      ),
    );
  }

  Widget buildFlashDealBannerShimmer() {
    return ShimmerHelper().buildBasicShimmerCustomRadius(
      width: DeviceInfo(context).width,
      height: 180,
      color: MyTheme.medium_grey_50,
    );
  }

  Widget buildTimerRow(CurrentRemainingTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 5),
          Column(
            children: [
              timerCircularContainer(
                time.days ?? 0,
                365,
                timeText((time.days ?? 0).toString(), default_length: 3),
              ),
              SizedBox(height: 5),
              Text('Days', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          SizedBox(width: 10),
          Column(
            children: [
              timerCircularContainer(
                time.hours ?? 0,
                24,
                timeText((time.hours ?? 0).toString(), default_length: 2),
              ),
              SizedBox(height: 5),
              Text('Hours', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          SizedBox(width: 10),
          Column(
            children: [
              timerCircularContainer(
                time.min ?? 0,
                60,
                timeText((time.min ?? 0).toString(), default_length: 2),
              ),
              SizedBox(height: 5),
              Text(
                'Minutes',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          SizedBox(width: 10),
          Column(
            children: [
              timerCircularContainer(
                time.sec ?? 0,
                60,
                timeText((time.sec ?? 0).toString(), default_length: 2),
              ),
              SizedBox(height: 5),
              Text(
                'Seconds',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          SizedBox(width: 10),
          Image.asset(
            "assets/flash_deal.png",
            height: 20,
            color: MyTheme.golden,
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
  //It is for Circular

  Widget timerCircularContainer(
    int currentValue,
    int totalValue,
    String timeText,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: currentValue / totalValue,
            backgroundColor: const Color.fromARGB(255, 240, 220, 220),
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color.fromARGB(255, 255, 80, 80),
            ),
            strokeWidth: 4.0,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          timeText,
          style: TextStyle(
            color: const Color.fromARGB(228, 218, 29, 29),
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  //
  Widget buildTimerRowRowShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 10),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          SizedBox(width: 12),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          SizedBox(width: 10),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          SizedBox(width: 10),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          SizedBox(width: 10),
          Image.asset(
            "assets/flash_deal.png",
            height: 20,
            color: MyTheme.golden,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget timerContainer(Widget child) {
    return Container(
      constraints: BoxConstraints(minWidth: 30, minHeight: 24),
      alignment: Alignment.center,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: MyTheme.accent_color,
      ),
      child: child,
    );
  }
}
