import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BibleScrollViewController extends ChangeNotifier {
  late int index;
  late Duration duration;
  late Cubic curve;

  void scrollTo(
      {required int index, required Duration duration, required Cubic curve}) {
    this.index = index;
    this.duration = duration;
    this.curve = curve;
    notifyListeners();
  }

}

class ItemPosition {
  final int index;
  final double y;
  final double x;
  ItemPosition(this.index, this.x, this.y);
}

class ItemsPosition {
  final List<ItemPosition> _items = [];
  void add(ItemPosition item) {
    _items.add(item);
  }

  ItemPosition? getItem(int index) {
    return _items.firstWhereOrNull(
      (item) => item.index == index,
    );
  }

  double? getY(int index) {
    return getItem(index)?.y;
  }

  void clear() {
    _items.clear();
  }
}

class BibleScrollView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final BibleScrollViewController controller;
  final bool? isScroll;
  const BibleScrollView(
      {super.key,
      required this.itemCount,
      required this.itemBuilder,
      required this.controller,
      this.isScroll
      });

  @override
  State<BibleScrollView> createState() => _BibleScrollViewState();
}

class _BibleScrollViewState extends State<BibleScrollView> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _keys = [];
  final ItemsPosition _itemsPosition = ItemsPosition();

  @override
  void initState() {
    super.initState();
    initKeys();
    widget.controller.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initKeys();
  }

  @override
  void didUpdateWidget(covariant BibleScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    initKeys();
  }

  _scrollListener() {
    int index = widget.controller.index;
    double? y = _itemsPosition.getY(index);
    if (y == null) {
      return;
    }
    _scrollController.animateTo(y,
        duration: widget.controller.duration, curve: widget.controller.curve);
  }

  void initKeys() {
    setState(() {
      _keys.clear();
      _keys = List.generate(widget.itemCount, (index) => GlobalKey());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double y = 0;
      _itemsPosition.clear();
      List.generate(_keys.length, (index) {
        final key = _keys[index];
        final renderBox = key.currentContext?.findRenderObject() as RenderBox;
        final size = renderBox.size;
        _itemsPosition.add(ItemPosition(index, size.width, y));
        y += size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_keys.isEmpty) return Container();
    return SingleChildScrollView(
      // physics: widget.isScroll ?? true ? null:const NeverScrollableScrollPhysics(),
      controller: _scrollController,
      child: Column(
        children: List.generate(
            widget.itemCount,
            (index) => Container(
                  key: _keys[index],
                  child: widget.itemBuilder.call(context, index),
                )).toList(),
      ),
    );
  }
}
