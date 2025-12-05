import 'package:flutter/material.dart';
import 'package:shafeea/core/entities/tracking_unit.dart';

import '../../../../core/models/tracking_type.dart';
import '../../../../core/models/tracking_units.dart';


@immutable
class PlanForTheDayEntity {
  final DateTime endDate;
  final List<PlanForTheDaySection> section;

  const PlanForTheDayEntity({
    required this.endDate,
    required this.section
    });
}

class PlanForTheDaySection {
  final TrackingType type;
  final TrackingUnitTyps unit;
  final TrackingUnitDetail fromTrackingUnitId;
  final TrackingUnitDetail toTrackingUnitId;
  final double gap;

  const PlanForTheDaySection({
    required this.type,
    required this.unit,
    required this.fromTrackingUnitId,
    required this.toTrackingUnitId,
    required this.gap,
  });
}
