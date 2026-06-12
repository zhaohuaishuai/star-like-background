import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';

class ScrollTabBar extends StatefulWidget {
  final double padding;
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int>? onChanged;

  /// 是否缓存页面默认fasle
  final bool keepAlive;
  const ScrollTabBar({
    super.key,
    required this.padding,
    required this.tabs,
    this.currentIndex = 0,
    this.onChanged,
    this.keepAlive = false,
  }) : assert(currentIndex >= 0 && currentIndex < tabs.length);

  @override
  State<ScrollTabBar> createState() => _ScrollTabBarState();
}

class _ScrollTabBarState extends State<ScrollTabBar>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  final List<GlobalKey> _keys = [];
  final List<(Size?, Offset?)> _positions = [];
  double left = 0;
  double width = 0;
  double _oldLeft = 0;
  double _oldWidth = 0;
  late AnimationController _amimController;
  late ScrollController _scrollController;
  ScrollMetrics? metrics;
  @override
  void initState() {
    super.initState();

    _amimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scrollController = ScrollController();
    init();
    debugPrint('init');
    WidgetsBinding.instance
        .addPostFrameCallback((Duration duration) => updatePositions());
  }

  void init() {
    for (var _ in widget.tabs) {
      _keys.add(GlobalKey());
    }
    _currentIndex.value = widget.currentIndex;
    _currentIndex.addListener(onChange);
    _amimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('completed');
        _oldLeft = left;
        _oldWidth = width;
        boundaryCalibration();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ScrollTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex.value = widget.currentIndex;
    }
    if (oldWidget.tabs.length != widget.tabs.length) {
      debugPrint('didUpdate tabs change');
      WidgetsBinding.instance
          .addPostFrameCallback((Duration duration) => updatePositions());
      _currentIndex.value = _currentIndex.value > widget.tabs.length - 1
          ? widget.tabs.length - 1
          : _currentIndex.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.only(left: widget.padding, right: widget.padding),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 46,
            color: Theme.of(context).scaffoldBackgroundColor,
            // padding: EdgeInsets.only(left: widget.padding, right: widget.padding),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) => _onScroll(notification),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: ValueListenableBuilder(
                  valueListenable: _currentIndex,
                  builder: (context, value, child) {
                    return _buildTabs(context);
                  },
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _amimController,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: _oldLeft + (left - _oldLeft) * _amimController.value,
                width: _oldWidth + (width - _oldWidth) * _amimController.value,
                child: child!,
              );
            },
            child: Container(
                height: 2,
                color: context.isDarkMode
                    ? Theme.of(context).indicatorColor
                    : Theme.of(context).primaryColor),
          )
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    if (widget.tabs.isEmpty) return Container();
    List<Widget> tabs = widget.tabs.asMap().keys.map((index) {
      final title = widget.tabs[index];
      final padding = index == 0
          ? EdgeInsets.only(right: StarThemeData.spacing)
          : index == widget.tabs.length - 1
              ? EdgeInsets.only(left: StarThemeData.spacing)
              : EdgeInsets.symmetric(horizontal: StarThemeData.spacing);
      return InkWell(
        onTap: () {
          _currentIndex.value = index;
        },
        onTapCancel: () {
          _currentIndex.value = index;
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          key: _keys[index],
          padding: padding,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
                color: _currentIndex.value == index
                    ? context.isDarkMode
                        ? Theme.of(context).indicatorColor
                        : Theme.of(context).primaryColor
                    : Theme.of(context).hintColor,
                fontWeight: _currentIndex.value == index
                    ? FontWeight.bold
                    : FontWeight.normal),
          ),
        ),
      );
    }).toList();

    return Row(children: tabs);
  }

  void onChange() {
    widget.onChanged?.call(_currentIndex.value);
    initLayout(isAnim: true);
  }

  void updatePositions() {
    debugPrint('updatePositions');
    _positions.clear();
    for (var gkey in _keys) {
      RenderBox? renderBoxRed =
          gkey.currentContext?.findRenderObject() as RenderBox?;
      Size? sizeRed = renderBoxRed?.size;
      Offset? offsetRed = renderBoxRed?.localToGlobal(Offset.zero);

      _positions.add((sizeRed, offsetRed));
    }
    if (_scrollController.hasClients) {
      // 获取一个ScrollMmetrics对像
      _scrollController.jumpTo(1);
    }
    initLayout(isAnim: true);
  }

  void initLayout({bool? isAnim}) {
    final (size, offset) = _currentRenderBox;
    Future.delayed(Duration.zero, () {
      left = (offset?.dx ?? 0) -
          (metrics?.pixels ?? 0) -
          (_currentIndex.value == 0
              ? _currentIndex.value == widget.tabs.length - 1
                  ? -StarThemeData.spacing
                  : StarThemeData.spacing
              : 0);
      width = (size?.width ?? 0) -
          StarThemeData.spacing *
              (_currentIndex.value == 0 ||
                      _currentIndex.value == widget.tabs.length - 1
                  ? 1
                  : 2);
      if (isAnim == true) {
        _amimController.reset();
        _amimController.forward();
      } else {
        setState(() {
          left = left;
          width = width;
          _oldLeft = left;
          _oldWidth = width;
        });
      }
    });
  }

  (Size? size, Offset? offset) get _currentRenderBox {
    return _positions[_currentIndex.value];
  }

  bool _onScroll(ScrollNotification notification) {
    metrics = notification.metrics;
    initLayout();
    return false;
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    _amimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void boundaryCalibration() {
    if (metrics != null && _scrollController.hasClients) {
      if (left < 0) {
        _scrollController.animateTo(metrics!.pixels + left,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      } else if (left + width > metrics!.extentInside) {
        double newLeft =
            metrics!.pixels - (metrics!.extentInside - left - width);
        if (newLeft > metrics!.extentInside) {
          // 防止回弹效果
          newLeft = metrics!.extentInside - StarThemeData.spacing - 1;
        }

        _scrollController.animateTo(newLeft - 1,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    }
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
