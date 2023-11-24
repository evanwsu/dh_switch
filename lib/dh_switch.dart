import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  }) : super(key: key);

  @override
  _DHSwitchState createState() => _DHSwitchState();
}

class _DHSwitchState extends State<DHSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _positionController;
  late Animation<Alignment> _circleAnimation;

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
    SwitchSize switchSize = widget.switchSize;
    final BorderSide borderSide = BorderSide(
        style: widget.borderStyle,
        color: widget.borderColor,
        width: switchSize.borderWidth);

    return AnimatedBuilder(
      animation: _positionController,
      builder: (BuildContext context, Widget? _) {
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
              color: _circleAnimation.value == Alignment.centerLeft
                  ? widget.inactiveTrackColor
                  : widget.activeTrackColor),
          child: DecoratedBox(
            decoration: ShapeDecoration(
                shape: CircleBorder(side: borderSide),
                color: _circleAnimation.value == Alignment.centerLeft
                    ? widget.inactiveThumbColor
                    : widget.activeThumbColor),
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
    if (_positionController.isCompleted) {
      _positionController.reverse();
    } else if (_positionController.isDismissed) {
      _positionController.forward();
    }
  }

  void _handlePositionStateChanged(AnimationStatus status) {
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

  const SwitchSize({width, height, borderWidth})
      : _trackWidth = width ?? _defaultWidth,
        _trackHeight = height ?? _defaultHeight,
        _borderWidth = borderWidth ?? _defaultBorderWidth;

  double get trackWidth => _trackWidth;

  double get trackHeight => _trackHeight;

  double get borderWidth => _borderWidth;

  double get margin => (trackHeight - trackHeight / _ratio) / 2;

  double get thumbSize => trackHeight - margin * 2;
}
