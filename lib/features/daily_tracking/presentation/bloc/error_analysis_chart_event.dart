part of 'error_analysis_chart_bloc.dart';

abstract class ErrorAnalysisChartEvent extends Equatable {
  const ErrorAnalysisChartEvent();

  @override
  List<Object> get props => [];
}

class LoadErrorAnalysisChartData extends ErrorAnalysisChartEvent {
  final ChartFilter filter;

  const LoadErrorAnalysisChartData({
    required this.filter,
  });

  @override
  List<Object> get props => [ filter];
}

class UpdateErrorAnalysisChartFilter extends ErrorAnalysisChartEvent {
  final ChartFilter filter;

  const UpdateErrorAnalysisChartFilter({required this.filter});

  @override
  List<Object> get props => [filter];
}
