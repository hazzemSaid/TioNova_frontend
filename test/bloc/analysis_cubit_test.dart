import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import 'package:tionova/features/home/presentation/bloc/Analysiscubit.dart';

import '../mocks.dart';

void main() {
  group('AnalysisCubit', () {
    late AnalysisCubit cubit;
    late MockAnalysisUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockAnalysisUseCase();
      cubit = AnalysisCubit(analysisUseCase: mockUseCase);
    });

    test('initial state is AnalysisInitial', () {
      expect(cubit.state.runtimeType.toString(), 'AnalysisInitial');
    });

    blocTest<AnalysisCubit, dynamic>(
      'emits Loading then Loaded when usecase returns success',
      build: () {
        final model = Analysismodel(userId: 'u1');
        when(() => mockUseCase.execute()).thenAnswer((_) async => Right(model));
        return cubit;
      },
      act: (c) => c.loadAnalysisData(),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
      verify: (_) {
        verify(() => mockUseCase.execute()).called(1);
      },
    );

    blocTest<AnalysisCubit, dynamic>(
      'emits Loading then Error when usecase fails',
      build: () {
        when(
          () => mockUseCase.execute(),
        ).thenAnswer((_) async => Left(ServerFailure('nope')));
        return cubit;
      },
      act: (c) => c.loadAnalysisData(),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );
  });
}
