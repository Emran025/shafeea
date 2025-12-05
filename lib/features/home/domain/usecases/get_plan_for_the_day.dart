import 'package:dartz/dartz.dart';
import 'package:shafeea/features/home/domain/entities/plan_for_the_day_entity.dart';
import 'package:shafeea/features/home/domain/repositories/student_repository.dart';

import '../../../../core/error/failures.dart';
import 'usecase.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class GetPlanForTheDay implements UseCase<PlanForTheDayEntity, NoParams> {
  final StudentRepository repository;

  GetPlanForTheDay(this.repository);

  @override
  Future<Either<Failure, PlanForTheDayEntity>> call(NoParams params) async {
    return await repository.getPlanForTheDay();
  }
}
