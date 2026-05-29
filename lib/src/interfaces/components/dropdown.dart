import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedDropdown<T> extends StatefulWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T) itemLabel;
  final String Function(T)? itemIcon;
  final double borderRadius;
  final double height;
  final double maxMenuHeight;

  const AnimatedDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.itemIcon,
    this.borderRadius = 12,
    this.height = 52,
    this.maxMenuHeight = 240,
    this.borderColor,
  });

  final Color? borderColor;

  @override
  State<AnimatedDropdown<T>> createState() => _AnimatedDropdownState<T>();
}

class _AnimatedDropdownState<T> extends State<AnimatedDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool openUpwards = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 230),
      vsync: this,
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    _calculateDirection();
    _configureSlideAnimation();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    _controller.forward();
  }

  void _closeDropdown() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _calculateDirection() {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset offset = box.localToGlobal(Offset.zero);

    double screenHeight = MediaQuery.of(context).size.height;

    double spaceBelow = screenHeight - (offset.dy + widget.height);
    double spaceAbove = offset.dy;

    // If below space < required height, open upwards
    openUpwards = spaceBelow < 200 && spaceAbove > spaceBelow;
  }

  void _configureSlideAnimation() {
    _slide = Tween<Offset>(
      begin: openUpwards ? const Offset(0, 0.05) : const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox box = context.findRenderObject() as RenderBox;
    final Size size = box.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap outside to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
            ),
          ),

          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,

              // ⭐ FIXED OFFSET LOGIC
              targetAnchor: openUpwards
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              followerAnchor: openUpwards
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              offset: openUpwards
                  ? const Offset(0, -6) // place just above dropdown
                  : const Offset(0, 6), // place below dropdown

              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      constraints: BoxConstraints(
                        maxHeight: widget.maxMenuHeight,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius > 0 ? widget.borderRadius : 16,
                        ),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF3F4F6),
                        ),
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final isSelected = item == widget.value;
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.transparent,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                highlightColor: Colors.blue.withOpacity(0.05),
                                hoverColor: Colors.blue.withOpacity(0.05),
                                splashColor: Colors.blue.withOpacity(0.1),
                                onTap: () {
                                  widget.onChanged(item);
                                  _closeDropdown();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      if (widget.itemIcon != null) ...[
                                        SvgPicture.asset(
                                          widget.itemIcon!(item),
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: Text(
                                          widget.itemLabel(item),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.blue.shade700
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Colors.blue.shade600,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.borderColor == Colors.red;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: hasError
                  ? Colors.red
                  : widget.borderColor ?? const Color(0xFFE8E8EF),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.itemIcon != null && widget.value != null) ...[
                    SvgPicture.asset(
                      widget.itemIcon!(widget.value as T),
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.value == null
                        ? widget.hint
                        : widget.itemLabel(widget.value as T),
                    style: TextStyle(
                      fontFamily: 'ClashGrotesk',
                      color: widget.value == null
                          ? const Color(0xFF9C9C9C)
                          : const Color(0xFF141414),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(
                openUpwards
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF111111),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
