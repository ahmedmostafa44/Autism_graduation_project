import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeLoadData>(_onLoadData);
  }

  Future<void> _onLoadData(HomeLoadData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(HomeLoaded(
      parentName: "Sarah's Parent",
      todayTip:
          'Try the "Feelings" game — it helps children identify and express emotions through fun visual cards.',
      hasNotification: true,
      isOfflineReady: true,
    ));
  }
}
