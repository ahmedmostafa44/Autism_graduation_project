import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _prefKey = 'isDark';

  ThemeBloc() : super(const ThemeState(isDark: true)) {
    on<ThemeToggled>(_onToggled);
    on<ThemeSet>(_onSet);
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey) ?? true; // default dark (space theme!)
    add(ThemeSet(saved));
  }

  Future<void> _onToggled(ThemeToggled event, Emitter<ThemeState> emit) async {
    final newDark = !state.isDark;
    emit(ThemeState(isDark: newDark));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, newDark);
  }

  Future<void> _onSet(ThemeSet event, Emitter<ThemeState> emit) async {
    emit(ThemeState(isDark: event.isDark));
  }
}
