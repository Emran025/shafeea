import 'package:flutter/material.dart';
import 'package:shafeea/features/home/domain/entities/plan_detail_entity.dart';

@immutable
class PlanForTheDayEntity {
  final PlanDetailEntity planDetail;
  final String fromSurah;
  final int fromPage;
  final int fromAyah;
  final String toSurah;
  final int toPage;
  final int toAyah;

  const PlanForTheDayEntity({
    required this.planDetail,
    required this.fromSurah,
    required this.fromPage,
    required this.fromAyah,
    required this.toSurah,
    required this.toPage,
    required this.toAyah,
  });
}
