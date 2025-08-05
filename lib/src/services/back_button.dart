part of '../../twa.dart';

abstract class BackButton {
  abstract final bool isVisible;

  abstract final void Function(void Function() callback) onClick;
  abstract final void Function(void Function() callback) offClick;

  abstract final void Function() hide;
  abstract final void Function() show;

  const BackButton();
}

final class BackButtonImpl implements BackButton {
  @override
  bool get isVisible => _isVisible();

  final bool Function() _isVisible;

  @override
  final void Function(void Function() callback) onClick;

  @override
  final void Function(void Function() callback) offClick;

  @override
  final void Function() hide;

  @override
  final void Function() show;

  const BackButtonImpl({
    required bool Function() isVisible,
    required this.onClick,
    required this.offClick,
    required this.hide,
    required this.show,
  }) : _isVisible = isVisible;
}
