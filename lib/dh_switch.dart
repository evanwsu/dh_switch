import 'package:flutter/material.dart';

///@author Evan
///@since 2019-11-04
///@describe: switch组件

const double _defaultWidth = 44;
const double _defaultHeight = 24;
const double _ratio = 1.35; // track高度和thumb高度比
const double _defaultBorderWidth = 0.3;
const Duration _sToggleDuration = Duration(milliseconds: 200);

class DHSwitch extends StatefulWidget {
  /// 当前状态值
  final bool value;

  /// 状态改变回调，未设置不会响应手势
  final ValueChanged<bool>? onChanged;

  /// 开启状态thumb颜色
  final Color activeThumbColor;

  /// 开启状态轨道颜色
  final Color activeTrackColor;

  /// 关闭状态thumb颜色
  final Color inactiveThumbColor;

  /// 关闭状态轨道颜色
  final Color inactiveTrackColor;

  /// 边框颜色
  final Color borderColor;

  /// 自定义switch尺寸
  final SwitchSize switchSize;

  /// 边框样式， BorderStyle.none不设置边框
  final BorderStyle borderStyle;

  /// 是否可用
  final bool disabled;

  /// 动画状态改变
  final AnimationStatusListener? onAnimationStatusChanged;

  /// 节流时间，在节流时间内忽略交互
  final Duration? throttleDuration;

  /// 是否第一时间渲染（动画）；为 false 时仅触发 onChanged
  final bool isFirstRender;

  DHSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.disabled = false,
    this.activeThumbColor = const Color(0xFFFFFFFF),
    this.inactiveThumbColor = const Color(0xFFFFFFFF),
    this.activeTrackColor = const Color(0xFF47D7EC),
    this.inactiveTrackColor = const Color(0xFFF0F0F0),
    this.borderColor = const Color(0x1A000000),
    this.switchSize = const SwitchSize(),
    this.borderStyle = BorderStyle.solid,
    this.onAnimationStatusChanged,
    this.throttleDuration,
    this.isFirstRender = true,
  }) : super(key: key);

  @override
  _DHSwitchState createState() => _DHSwitchState();
}

class _DHSwitchState extends State<DHSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _positionController;
  late Animation<Alignment> _circleAnimation;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(
      vsync: this,
      duration: _sToggleDuration,
      value: value,
    );
    _circleAnimation = AlignmentTween(
            begin: Alignment.centerLeft, end: Alignment.centerRight)
        .animate(
            CurvedAnimation(parent: _positionController, curve: Curves.linear))
      ..addStatusListener(_handlePositionStateChanged);
  }

  @override
  void didUpdateWidget(DHSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _positionController.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final switchSize = widget.switchSize;
    final borderSide = BorderSide(
      style: widget.borderStyle,
      color: widget.borderColor,
      width: switchSize.borderWidth,
    );

    return AnimatedBuilder(
      animation: _positionController,
      builder: (BuildContext context, Widget? _) {
        final isActive = _circleAnimation.value == Alignment.centerRight;
        Widget current = Container(
          width: switchSize.trackWidth,
          height: switchSize.trackHeight,
          alignment: _circleAnimation.value,
          padding: EdgeInsets.symmetric(horizontal: switchSize.margin),
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(switchSize.trackHeight / 2),
                  side: borderSide),
              color: isActive
                  ? widget.activeTrackColor
                  : widget.inactiveTrackColor),
          child: DecoratedBox(
            decoration: ShapeDecoration(
                shape: CircleBorder(side: borderSide),
                color: isActive
                    ? widget.activeThumbColor
                    : widget.inactiveThumbColor),
            child: SizedBox(
              width: switchSize.thumbSize,
              height: switchSize.thumbSize,
            ),
          ),
        );
        if (!widget.disabled) {
          current = GestureDetector(
            onTap: _handleTap,
            child: current,
          );
        }
        return current;
      },
    );
  }

  void _handleTap() {
    if (_shouldThrottle()) {
      return;
    }

    if (widget.isFirstRender) {
      if (_positionController.isCompleted) {
        _positionController.reverse();
      } else if (_positionController.isDismissed) {
        _positionController.forward();
      }
    } else {
      // 不立即渲染，仅回调，等待外部更新 value 后触发同步
      final nextValue = !widget.value;
      widget.onChanged?.call(nextValue);
    }
  }

  /// 检查是否应该节流，返回 true 表示应该忽略本次交互
  bool _shouldThrottle() {
    final throttleDuration = widget.throttleDuration;
    if (throttleDuration == null) {
      return false;
    }

    final now = DateTime.now();
    if (_lastTapTime != null) {
      final timeSinceLastTap = now.difference(_lastTapTime!);
      if (timeSinceLastTap < throttleDuration) {
        return true;
      }
    }
    _lastTapTime = now;
    return false;
  }

  void _handlePositionStateChanged(AnimationStatus status) {
    if (!widget.isFirstRender) {
      return;
    }
    widget.onAnimationStatusChanged?.call(status);
    if (status == AnimationStatus.completed && !widget.value) {
      widget.onChanged?.call(true);
    } else if (status == AnimationStatus.dismissed && widget.value) {
      widget.onChanged?.call(false);
    }
  }

  double get value => widget.value ? 1.0 : 0.0;

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }
}

/// 处理switch属性大小
class SwitchSize {
  final double _borderWidth;
  final double _trackWidth;
  final double _trackHeight;

  const SwitchSize({
    double? width,
    double? height,
    double? borderWidth,
  })  : _trackWidth = width ?? _defaultWidth,
        _trackHeight = height ?? _defaultHeight,
        _borderWidth = borderWidth ?? _defaultBorderWidth;

  double get trackWidth => _trackWidth;

  double get trackHeight => _trackHeight;

  double get borderWidth => _borderWidth;

  double get margin => (trackHeight - trackHeight / _ratio) / 2;

  double get thumbSize => trackHeight - margin * 2;
}
