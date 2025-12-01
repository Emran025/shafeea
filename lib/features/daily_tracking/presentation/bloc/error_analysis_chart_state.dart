part of 'error_analysis_chart_bloc.dart';

abstract class ErrorAnalysisChartState extends Equatable {
  const ErrorAnalysisChartState();

  @override
  List<Object> get props => [];
}

class ErrorAnalysisChartInitial extends ErrorAnalysisChartState {}

class ErrorAnalysisChartLoading extends ErrorAnalysisChartState {}

class ErrorAnalysisChartLoaded extends ErrorAnalysisChartState {
  final List<BarChartDatas> chartData;
  final ChartFilter filter;

  const ErrorAnalysisChartLoaded({
    required this.chartData,
    required this.filter,
  });

  @override
  List<Object> get props => [chartData, filter];
}

class ErrorAnalysisChartError extends ErrorAnalysisChartState {
  final String message;

  const ErrorAnalysisChartError({required this.message});

  @override
  List<Object> get props => [message];
}
