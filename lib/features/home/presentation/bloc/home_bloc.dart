import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/features/auth/data/repositories/auth_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository _repo;

  HomeBloc({AuthRepository? repo})
      : _repo = repo ?? AuthRepository(),
        super(HomeInitial()) {
    on<HomeLoadData>(_onLoadData);
  }

  Future<void> _onLoadData(HomeLoadData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final profile = await _repo.fetchCurrentProfile();
      final name = profile?.parentName ?? "Parent";

      emit(HomeLoaded(
        parentName: name,
        todayTip:
            'Try the "Feelings" game — it helps children identify and express emotions through fun visual cards.',
        hasNotification: true,
        isOfflineReady: true,
      ));
    } catch (_) {
      emit(HomeLoaded(
        parentName: "Parent",
        todayTip: "Let's explore some games today!",
        hasNotification: false,
        isOfflineReady: true,
      ));
    }
  }
}
