library animated_dropdown_button;

import 'package:flutter/material.dart';

class AnimatedDropdownButton extends StatelessWidget {
  const AnimatedDropdownButton({
    super.key,
    required this.controller,
    this.backgroundColor,
    this.innerTextStyle,
  });

  final AnimatedDropdownButtonController controller;
  final Color? backgroundColor;
  final TextStyle? innerTextStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRect(
          child: Container(
            width: 175,
            alignment: const Alignment(0, -1),
            child: _AnimatedDropdown(
              controller: controller,
              backgroundColor: backgroundColor,
              innerTextStyle: innerTextStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedDropdown extends StatefulWidget {
  const _AnimatedDropdown({
    required this.controller,
    this.backgroundColor,
    this.innerTextStyle,
  });

  @override
  State<_AnimatedDropdown> createState() => __AnimatedDropdownState();
  final AnimatedDropdownButtonController controller;
  final Color? backgroundColor;
  final TextStyle? innerTextStyle;
}

class __AnimatedDropdownState extends State<_AnimatedDropdown> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    entry = OverlayEntry(
      builder: (context) => Positioned(
        height: 1000,
        width: 800,
        child: Stack(
          children: [
            _DropdownOverlay(onDismiss: _toggleExpand),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Material(
                borderOnForeground: false,
                color: Colors.transparent,
                child: AnimatedContainer(
                  curve: _isExpanded ? Curves.elasticOut : Curves.easeInOut,
                  duration: _isExpanded ? const Duration(seconds: 1) : const Duration(milliseconds: 400),
                  height: _isExpanded
                      ? ((42 + (15 / widget.controller.items.length)) * widget.controller.items.length.toDouble())
                      : 40,
                  child: buildOverlay(),
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
        width: 175,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color.fromARGB(255, 164, 28, 255),
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _selectedValue(),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ),
                ),
              ],
            ),
            _isExpanded ? const SizedBox(height: 4) : const SizedBox.shrink(),
            for (var i = 0; i < widget.controller.items.length; i++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.controller.selectedValue = widget.controller.items[i];
                  });
                  _toggleExpand();
                },
                child: AnimatedContainer(
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.only(top: _isExpanded ? 4 : 0, bottom: _isExpanded ? 4 : 0),
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 300),
                  height: _isExpanded ? 34 : 0,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Opacity(
                      opacity: _isExpanded ? 1 : 0,
                      child: Text(
                        widget.controller.items[i],
                        style: widget.innerTextStyle ?? const TextStyle(color: Colors.white),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() async {
    if (_isExpanded == false) {
      showOverlay();
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _isExpanded = true;
          entry!.markNeedsBuild();
        });
      });
    }

    if (_isExpanded == true) {
      _isExpanded = false;
      entry!.markNeedsBuild();
      await Future.delayed(const Duration(milliseconds: 400));
      entry?.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
        alignment: Alignment.topCenter,
        width: 175,
        height: 40,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color.fromARGB(255, 164, 28, 255),
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _selectedValue(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedValue() {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, top: 8.0),
      child: Text(
        widget.controller.selectedValue!,
        style: widget.innerTextStyle ?? const TextStyle(color: Colors.white),
        textAlign: TextAlign.start,
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

class AnimatedDropdownButtonController {
  final List<String> items;
  String? selectedValue;
  String initialValue;

  AnimatedDropdownButtonController({
    required this.items,
    required this.initialValue,
  })  : selectedValue = initialValue,
        assert(items.contains(initialValue)),
        assert(items.isNotEmpty),
        assert(items.length < 6);
}
