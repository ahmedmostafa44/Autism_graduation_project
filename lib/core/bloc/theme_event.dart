part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ThemeToggled extends ThemeEvent {}

class ThemeSet extends ThemeEvent {
  final bool isDark;
  ThemeSet(this.isDark);
}
