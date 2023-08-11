import 'package:flutter/material.dart';

class AnimatedSearchBox extends StatelessWidget {
  const AnimatedSearchBox({
    super.key,
    required this.controller,
    this.backgroundColor,
    this.itemsTextStyle,
    this.selectedTextStyle,
    this.width = 336,
    this.height = 36,
    this.hintText = '',
    this.hintTextStyle,
    this.descriptionWidget,
  });

  final AnimatedSearchBoxController controller;
  final Color? backgroundColor;
  final TextStyle? itemsTextStyle;
  final TextStyle? selectedTextStyle;
  final double width;
  final double height;
  final String hintText;
  final TextStyle? hintTextStyle;
  final Widget? descriptionWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            descriptionWidget != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: descriptionWidget!,
                  )
                : const SizedBox.shrink(),
            ClipRect(
              child: Container(
                width: width,
                alignment: const Alignment(0, -1),
                child: _AnimatedSearchDropdown(
                  controller: controller,
                  backgroundColor: backgroundColor,
                  itemsTextStyle: itemsTextStyle,
                  selectedTextStyle: selectedTextStyle,
                  width: width,
                  hintText: hintText,
                  hintTextStyle: hintTextStyle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedSearchDropdown extends StatefulWidget {
  const _AnimatedSearchDropdown({
    required this.controller,
    this.backgroundColor,
    required this.width,
    this.itemsTextStyle,
    this.selectedTextStyle,
    this.hintText = '',
    this.hintTextStyle,
  });

  @override
  State<_AnimatedSearchDropdown> createState() => _AnimatedSearchDropdownState();
  final AnimatedSearchBoxController controller;
  final Color? backgroundColor;
  final TextStyle? itemsTextStyle;
  final TextStyle? selectedTextStyle;
  final double width;
  final String hintText;
  final TextStyle? hintTextStyle;
}

class _AnimatedSearchDropdownState extends State<_AnimatedSearchDropdown> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isInvisible = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();

  OverlayEntry? entry;
  final LayerLink _layerLink = LayerLink();
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalKey;
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    );

    widget.controller.initialize();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _toggleExpand();
      }
    });
  }

  void showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    entry = OverlayEntry(
      builder: (context) => Positioned(
        child: Stack(
          children: [
            _DropdownOverlay(onDismiss: _toggleExpand),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, renderBox.size.height),
                child: Material(
                  borderOnForeground: false,
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    opacity: _isInvisible ? 0 : 1,
                    duration: _isExpanded ? const Duration(milliseconds: 300) : const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      curve: _isExpanded ? Curves.elasticOut : Curves.easeInOut,
                      duration: _isExpanded ? const Duration(seconds: 1) : const Duration(milliseconds: 300),
                      height: _isExpanded ? 200 : 36,
                      width: renderBox.size.width,
                      child: buildOverlay(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry!);
  }

  Widget buildOverlay() {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
          alignment: Alignment.topCenter,
          width: widget.width,
          decoration: BoxDecoration(
              color: widget.backgroundColor ?? const Color.fromARGB(255, 164, 28, 255),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
          child: Column(
            children: [
              _isExpanded ? const SizedBox(height: 4) : const SizedBox.shrink(),
              _isExpanded
                  ? Expanded(
                      child: RawScrollbar(
                        thumbColor: const Color.fromARGB(255, 160, 158, 158),
                        padding: const EdgeInsets.only(right: 16),
                        thumbVisibility: true,
                        controller: _scrollController,
                        thickness: 3,
                        child: Theme(
                          data:
                              ThemeData(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.transparent)),
                          child: ListView(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            children: [
                              for (var i = 0; i < widget.controller.filteredItems.length; i++)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.controller.selectedValue = widget.controller.filteredItems[i];

                                      if (widget.controller.selectedValue != null) {
                                        widget.controller.textEditingController.text =
                                            widget.controller.selectedValue!.text;
                                        _focusNode.unfocus();
                                      }
                                    });

                                    _toggleExpand();
                                  },
                                  child: AnimatedContainer(
                                    clipBehavior: Clip.none,
                                    padding: EdgeInsets.only(top: _isExpanded ? 4 : 0, bottom: _isExpanded ? 4 : 0),
                                    curve: Curves.linear,
                                    duration: const Duration(milliseconds: 300),
                                    height: _isExpanded ? 30 : 0,
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Opacity(
                                        opacity: _isExpanded ? 1 : 0,
                                        child: Text(
                                          widget.controller.filteredItems[i].text,
                                          style: widget.itemsTextStyle ?? const TextStyle(color: Colors.black),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          )),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() async {
    if (_isExpanded == false) {
      _isInvisible = true;
      showOverlay();
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _isInvisible = false;
          _isExpanded = true;
          entry!.markNeedsBuild();
        });
      });
      _animationController.forward();
    } else {
      _isExpanded = false;
      _isInvisible = true;
      _animationController.reverse();
      entry!.markNeedsBuild();
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 400));

      entry?.remove();

      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: AnimatedContainer(
          duration: _isExpanded ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
          alignment: Alignment.topCenter,
          width: widget.width,
          height: 36,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? const Color.fromARGB(255, 164, 28, 255),
            borderRadius: _isInvisible
                ? const BorderRadius.all(
                    Radius.circular(10),
                  )
                : const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _selectedValue(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                  child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedValue() {
    return AnimatedContainer(
      alignment: Alignment.center,
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      height: 36,
      width: widget.width - 65,
      child: Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.transparent),
          primaryColor: Colors.white,
        ),
        child: TextField(
          focusNode: _focusNode,
          controller: widget.controller.textEditingController,
          onChanged: (value) {
            if (_isExpanded == false) _toggleExpand();
            setState(() {});
            widget.controller.filterItems(value);
            setState(() {});
            entry!.markNeedsBuild();
          },
          textAlignVertical: TextAlignVertical.center,
          style: widget.selectedTextStyle ?? const TextStyle(color: Colors.black),
          cursorColor: Colors.grey,
          decoration: InputDecoration(
            isCollapsed: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
            labelText: widget.hintText,
            labelStyle: widget.hintTextStyle ?? const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _DropdownOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _DropdownOverlay({required this.onDismiss});

  @override
  State<_DropdownOverlay> createState() => __DropdownOverlayState();
}

class __DropdownOverlayState extends State<_DropdownOverlay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}

class AnimatedSearchBoxController {
  final List<AnimatedDropdownItem> items;
  AnimatedDropdownItem? selectedValue;
  AnimatedDropdownItem initialValue;
  final List<AnimatedDropdownItem> filteredItems = [];
  final TextEditingController textEditingController = TextEditingController();

  AnimatedSearchBoxController({
    required this.items,
    required this.initialValue,
  })  : selectedValue = initialValue,
        assert(items.isNotEmpty);

  void filterItems(String keyword) {
    filteredItems.clear();
    if (keyword.isEmpty) {
      filteredItems.addAll(items);
    } else {
      filteredItems.addAll(items.where((item) => item.text.toLowerCase().contains(keyword.toLowerCase())));
    }
  }

  void initialize() {
    filteredItems.addAll(items);
  }
}

abstract class AnimatedDropdownItem {
  String get text;
  String get value;
}
