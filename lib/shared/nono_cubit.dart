import 'package:flutter_bloc/flutter_bloc.dart';

class NonoCubit<NonoState> extends Cubit<NonoState> {
  NonoCubit(NonoState initialState) : super(initialState);

  init() {}

  @override
  void emit(NonoState state) {
    if (isClosed) {
      return;
    }
    super.emit(state);
  }
}
