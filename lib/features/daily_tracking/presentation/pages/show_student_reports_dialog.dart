import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/di/injection.dart';
import '../bloc/tracking_session_bloc.dart';
import '../widgets/follow_up_report_dialog.dart';

class ShowStudentReportsDialog extends StatefulWidget {
  const ShowStudentReportsDialog({super.key});

  @override
  State<ShowStudentReportsDialog> createState() =>
      _ShowStudentReportsDialogState();
}

class _ShowStudentReportsDialogState extends State<ShowStudentReportsDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<TrackingSessionBloc>()..add(FollowUpReportFetched()),
      child: BlocBuilder<TrackingSessionBloc, TrackingSessionState>(
        builder: (dialogContext, state) {
          print("DIALOG: --- 3. BlocBuilder is rebuilding! ---");
          print(
            "DIALOG: Current followUpReportStatus is: ${state.followUpReportStatus}",
          );
          print(
            "DIALOG: Is followUpReport null? --> ${state.followUpReport == null}",
          );
          if (state.followUpReportStatus == FollowUpReportStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state.followUpReportStatus == FollowUpReportStatus.success &&
              state.followUpReport != null) {
            return FollowUpReportDialog(bundle: state.followUpReport!);
          }

          if (state.followUpReportStatus == FollowUpReportStatus.failure) {
            return AlertDialog(
              title: const Text('wrong'),
              content: Text("Failed to load details"),
              actions: [
                TextButton(
                  onPressed: () {
                    dialogContext.read<TrackingSessionBloc>().add(
                      FollowUpReportFetched(),
                    );
                  },
                  child: const Text('Try Again'),
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }
}
