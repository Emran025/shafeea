import 'package:shafeea_student/core/l10n/app_strings.dart';
import 'package:shafeea/core/models/bar_chart_datas.dart';
import 'package:shafeea/core/models/chart_data_point.dart';
import 'package:shafeea/core/models/composite_performance_data.dart';
import 'package:shafeea/features/home/data/models/line_chart_data.dart';
import 'package:shafeea/features/home/data/models/line_chart_datas.dart';

import '../../core/models/mistake_type.dart';

/// بيانات وهمية (Mock Data) لتشغيل واختبار المخططات البيانية.

// =============================================================================
// 1. بيانات مخطط تحليل الأخطاء (Bar Chart)
//    (يستخدم في StudentErrorAnalysisChart)
// =============================================================================

final List<ChartDataPoint> mockErrorData = const [
  ChartDataPoint(value: 15, label: AppStrings.str_student_rem_275_c25f),
  ChartDataPoint(value: 25, label: AppStrings.str_student_37_506b),
  ChartDataPoint(value: 10, label: AppStrings.str_student_rem_276_a6b8),
  ChartDataPoint(value: 5, label: AppStrings.str_student_rem_277_f369),
  ChartDataPoint(value: 18, label: AppStrings.str_student_rem_278_f52b),
  ChartDataPoint(value: 12, label: AppStrings.str_student_rem_279_9b3e),
];

// =============================================================================
// 2. بيانات مخطط التقدم مقابل الخطة (Line Chart)
//    (يستخدم في StudentProgressChart)
// =============================================================================

final LineChartDatas mockProgressData = LineChartDatas(
  xAxisLabel: AppStrings.str_student_rem_280_d333,
  yAxisLabel: AppStrings.str_student_rem_281_6623,
  maxY: 100,
  plannedData: const [
    ChartDataPoint(value: 10, label: AppStrings.str_student_rem_282_bbd1),
    ChartDataPoint(value: 20, label: AppStrings.str_student_rem_283_30a1),
    ChartDataPoint(value: 30, label: AppStrings.str_student_rem_284_7d26),
    ChartDataPoint(value: 40, label: AppStrings.str_student_rem_285_0dc1),
    ChartDataPoint(value: 50, label: AppStrings.str_student_rem_286_7948),
    ChartDataPoint(value: 60, label: AppStrings.str_student_rem_287_4a1a),
  ],
  actualData: const [
    ChartDataPoint(value: 8, label: AppStrings.str_student_rem_282_bbd1),
    ChartDataPoint(value: 25, label: AppStrings.str_student_rem_283_30a1),
    ChartDataPoint(value: 28, label: AppStrings.str_student_rem_284_7d26),
    ChartDataPoint(value: 35, label: AppStrings.str_student_rem_285_0dc1),
    ChartDataPoint(value: 55, label: AppStrings.str_student_rem_286_7948),
    ChartDataPoint(value: 62, label: AppStrings.str_student_rem_287_4a1a),
  ],
);

// =============================================================================
// 3. بيانات مخطط تقييم جودة الإتقان (Composite Performance Chart)
//    (يستخدم في StudentQualityAssessmentChart)
// =============================================================================

final CompositePerformanceData mockQualityData = CompositePerformanceData(
  // title: 'تقييم جودة الإتقان (شهري)',
  xAxisLabel: AppStrings.str_student_rem_288_3e72,
  yAxisLabel: AppStrings.str_student_rem_289_6cc8,
  maxY: 100,
  performanceScores: const [
    ChartDataPoint(value: 85, label: AppStrings.str_student_rem_290_4a39),
    ChartDataPoint(value: 92, label: AppStrings.str_student_rem_291_5343),
    ChartDataPoint(value: 78, label: AppStrings.str_student_rem_292_92bc),
    ChartDataPoint(value: 95, label: AppStrings.str_student_rem_293_fd02),
    ChartDataPoint(value: 88, label: AppStrings.str_student_rem_294_954d),
    ChartDataPoint(value: 90, label: AppStrings.str_student_rem_295_9810),
  ],
);

// =============================================================================
// 4. بيانات مخطط الأداء العام المركب (Composite Performance Chart)
//    (يستخدم في مخطط StudentOverallPerformanceChart - لم يتم إنشاؤه بعد)
// =============================================================================

final CompositePerformanceData mockOverallPerformanceData =
    CompositePerformanceData(
      // title: 'مؤشر الأداء العام المركب (ربع سنوي)',
      xAxisLabel: AppStrings.str_student_rem_296_8d83,
      yAxisLabel: AppStrings.str_student_rem_297_fe6a,
      maxY: 100,
      performanceScores: const [
        ChartDataPoint(value: 75, label: AppStrings.str_student_rem_298_ce68),
        ChartDataPoint(value: 82, label: AppStrings.str_student_rem_299_87b9),
        ChartDataPoint(value: 88, label: AppStrings.str_student_rem_300_7a62),
        ChartDataPoint(value: 91, label: AppStrings.str_student_rem_301_6f6c),
      ],
    );

// =============================================================================
// 5. بيانات مخطط عدد الحفاظ (Bar Chart)
//    (يستخدم في HalqaGraduatesChart - لم يتم إنشاؤه بعد)
// =============================================================================

final BarChartDatas mockGraduatesData = BarChartDatas(
  // title: 'عدد الحفاظ المتخرجين (سنوي)',
  xAxisLabel: AppStrings.str_student_rem_302_5f3d,
  yAxisLabel: AppStrings.str_student_rem_102_6f0d,
  maxY: 50,
  data: const [
    ChartDataPoint(value: 15, label: '2021'),
    ChartDataPoint(value: 22, label: '2022'),
    ChartDataPoint(value: 30, label: '2023'),
    ChartDataPoint(value: 45, label: '2024'),
  ],
);

/// بيانات وهمية (Mock Data) لتشغيل واختبار المخططات البيانية
/// توفر 12 فترة زمنية (شهر) من البيانات لكل مخطط

// =============================================================================
// دالة مساعدة لإنشاء تاريخ الفترة الزمنية
// =============================================================================

DateTime _getPeriodDate(int monthsAgo) {
  final now = DateTime.now();
  return DateTime(now.year, now.month - monthsAgo, 1);
}

// =============================================================================
// 1. بيانات مخطط تحليل الأخطاء (12 فترة شهرية)
// =============================================================================

final List<BarChartDatas> mockErrorDataPeriods = List.generate(
  12,
  (index) => BarChartDatas(
    data: [
      ChartDataPoint(
        value: 25 - (index * 1),
        label: MistakeType.pronunciation.labelAr,
      ),
      ChartDataPoint(
        value: 15 + (index * 2),
        label: MistakeType.timing.labelAr,
      ),
      ChartDataPoint(
        value: 5 + (index * 0.5),
        label: MistakeType.grammar.labelAr,
      ),
      ChartDataPoint(
        value: 18 - (index * 0.8),
        label: MistakeType.memory.labelAr,
      ),
    ],
    xAxisLabel: AppStrings.str_student_rem_303_65cb,
    yAxisLabel: AppStrings.str_student_rem_304_c830,
    maxY: 50,
    periodDate: _getPeriodDate(11 - index), // من الشهر الأقدم إلى الأحدث
  ),
);

// =============================================================================
// 2. بيانات مخطط التقدم مقابل الخطة (12 فترة شهرية)
// =============================================================================

final List<LineChartData> mockProgressDataPeriods = List.generate(
  12,
  (index) => LineChartData(
    xAxisLabel: AppStrings.str_student_rem_280_d333,
    yAxisLabel: AppStrings.str_student_rem_281_6623,
    maxY: 100,
    plannedData: const [
      ChartDataPoint(value: 10, label: AppStrings.str_student_rem_282_bbd1),
      ChartDataPoint(value: 20, label: AppStrings.str_student_rem_283_30a1),
      ChartDataPoint(value: 30, label: AppStrings.str_student_rem_284_7d26),
      ChartDataPoint(value: 40, label: AppStrings.str_student_rem_285_0dc1),
    ],
    actualData: [
      ChartDataPoint(value: 8 + (index * 0.5), label: AppStrings.str_student_rem_282_bbd1),
      ChartDataPoint(value: 25 + (index * 0.3), label: AppStrings.str_student_rem_283_30a1),
      ChartDataPoint(value: 28 + (index * 0.8), label: AppStrings.str_student_rem_284_7d26),
      ChartDataPoint(value: 35 + (index * 1.2), label: AppStrings.str_student_rem_285_0dc1),
    ],
    periodDate: _getPeriodDate(11 - index),
  ),
);

// =============================================================================
// 3. بيانات مخطط تقييم جودة الإتقان (12 فترة شهرية)
// =============================================================================

final List<CompositePerformanceData> mockQualityDataPeriods = List.generate(
  12,
  (index) => CompositePerformanceData(
    // title: 'تقييم جودة الإتقان',
    xAxisLabel: AppStrings.str_student_rem_288_3e72,
    yAxisLabel: AppStrings.str_student_rem_289_6cc8,
    maxY: 100,
    performanceScores: [
      ChartDataPoint(value: 85 + (index * 0.5), label: AppStrings.str_student_rem_290_4a39),
      ChartDataPoint(value: 92 + (index * 0.3), label: AppStrings.str_student_rem_291_5343),
      ChartDataPoint(value: 78 + (index * 1.2), label: AppStrings.str_student_rem_292_92bc),
      ChartDataPoint(value: 95 - (index * 0.2), label: AppStrings.str_student_rem_293_fd02),
    ],
    periodDate: _getPeriodDate(11 - index),
  ),
);

// =============================================================================
// بيانات إضافية (اختيارية)
// =============================================================================
