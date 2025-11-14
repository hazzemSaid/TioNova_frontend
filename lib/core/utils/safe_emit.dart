import 'package:flutter_bloc/flutter_bloc.dart';

/// Provides a safe way to emit states from a Cubit.
/// It prevents calling `emit` after the Cubit has been closed,
/// which would otherwise throw "Bad state: emit() called after an event completed".
extension SafeEmitExtension<T> on Cubit<T> {
  void safeEmit(T state) {
    if (!isClosed) {
      emit(state);
    }
  }
}