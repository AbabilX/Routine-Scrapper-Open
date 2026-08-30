import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/class_status.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/model/student_summary.dart';
import '../theme/app_colors.dart';
import 'components/class_timeline.dart';
import 'components/date_strip.dart';
import 'components/decor_blobs.dart';
import 'components/empty_hint.dart';
import 'components/next_class_banner.dart';
import 'components/quick_chips.dart';
import 'components/reminder_picker_sheet.dart';
import 'components/search_row.dart';
import 'components/student_header.dart';
import 'components/summary_card.dart';
import 'components/upload_routine_card.dart';
import 'student_view_model.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentViewModel>();
    final state = viewModel.state;
    final showChips =
        state.suggestions.isNotEmpty &&
        (state.queryText.trim().isEmpty ||
            (state.parsedQuery?.section.isEmpty ?? true));

    return ColoredBox(
      color: bg,
      child: Stack(
        children: [
          const DecorBlobs(),
          ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
            children: [
              StudentHeader(
                profile: state.profile,
                onReplacePdf: state.hasRoutine
                    ? () => _upload(context, viewModel)
                    : null,
                replacing: state.isImporting,
              ),
              const SizedBox(height: 18),
              if (state.hasRoutine) ...[
                SearchRow(
                  query: state.queryText,
                  onQueryChange: viewModel.onQueryChange,
                ),
                if (showChips) ...[
                  const SizedBox(height: 18),
                  QuickChips(
                    chips: state.suggestions,
                    onSelect: viewModel.onChipSelected,
                  ),
                ],
                const SizedBox(height: 18),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_contentKey(state)),
                  child: _body(context, state, viewModel),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _upload(BuildContext context, StudentViewModel viewModel) async {
    final error = await viewModel.importRoutinePdf();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _useExisting(
    BuildContext context,
    StudentViewModel viewModel,
  ) async {
    final error = await viewModel.useBundledRoutine();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Widget _body(
    BuildContext context,
    StudentUiState state,
    StudentViewModel viewModel,
  ) {
    switch (_contentKey(state)) {
      case _BodyKey.needsUpload:
        return UploadRoutineCard(
          busy: state.isImporting,
          onUpload: () => _upload(context, viewModel),
          onUseExisting: () => _useExisting(context, viewModel),
        );
      case _BodyKey.blank:
        return const EmptyHint(
          title: 'শুরু করো',
          body: 'ব্যাচ লিখো, অথবা নিচের চিপ ট্যাপ করো — যেমন 68_C',
          tint: peach,
        );
      case _BodyKey.invalid:
        return const EmptyHint(
          title: 'উফ, ফরম্যাট মিলেনি',
          body: 'চেষ্টা করো: 68_C  বা শুধু  68',
          tint: rose,
        );
      case _BodyKey.noMatch:
        return const EmptyHint(
          title: 'কেউ নেই',
          body:
              'এই ব্যাচ/সেকশনের ক্লাস রুটিনে পাওয়া যায়নি — অন্য চিপ চেষ্টা করো',
          tint: sky,
        );
      case _BodyKey.ready:
        return _ReadyBody(
          state: state,
          onDaySelected: viewModel.onDaySelected,
          onDownload: viewModel.downloadSchedule,
          onReminderPicked: viewModel.onReminderPicked,
        );
    }
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.state,
    required this.onDaySelected,
    required this.onDownload,
    required this.onReminderPicked,
  });

  final StudentUiState state;
  final ValueChanged<RoutineDay> onDaySelected;
  final Future<void> Function() onDownload;
  final Future<bool> Function(ClassBlock block, int? minutes) onReminderPicked;

  @override
  Widget build(BuildContext context) {
    final statuses = state.classStatuses.values;
    final allDone =
        statuses.isNotEmpty &&
        statuses.every((status) => status == ClassStatus.done);
    final reminderMinutes = {
      for (final reminder in state.reminders)
        reminder.id: reminder.minutesBefore,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DateStrip(
          selected: state.resolvedSelectedDay,
          today: state.resolvedToday,
          onSelect: onDaySelected,
        ),
        if (state.summary != null) ...[
          const SizedBox(height: 18),
          SummaryCard(summary: state.summary!, onDownload: onDownload),
        ],
        const SizedBox(height: 18),
        NextClassBanner(hint: state.nowNext),
        if (state.timeline.isEmpty) ...[
          const SizedBox(height: 18),
          const EmptyHint(
            title: 'Off day',
            body: 'এই দিনে ক্লাস নেই — অন্য দিনে তাকাও',
            tint: mint,
          ),
        ] else if (state.resolvedSelectedDay == state.resolvedToday &&
            state.nowNext == null &&
            allDone) ...[
          const SizedBox(height: 18),
          const EmptyHint(
            title: 'দিন শেষ',
            body: 'আজকের সব ক্লাস হয়ে গেছে — কাল দেখা হবে',
            tint: lavender,
          ),
          const SizedBox(height: 18),
          ClassTimeline(
            items: state.timeline,
            statuses: state.classStatuses,
            reminderMinutes: reminderMinutes,
            onReminderTap: (block) => _pickReminder(context, block),
          ),
        ] else ...[
          const SizedBox(height: 18),
          ClassTimeline(
            items: state.timeline,
            statuses: state.classStatuses,
            reminderMinutes: reminderMinutes,
            onReminderTap: (block) => _pickReminder(context, block),
          ),
        ],
      ],
    );
  }

  Future<void> _pickReminder(BuildContext context, ClassBlock block) async {
    final choice = await showReminderPickerSheet(
      context: context,
      course: block.course,
      selected: state.reminderMinutesFor(block),
    );
    if (choice == null || !context.mounted) return;
    final allowed = await onReminderPicked(block, choice.minutes);
    if (!allowed && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('নোটিফিকেশন পারমিশন দরকার')));
    }
  }
}

enum _BodyKey { needsUpload, blank, invalid, noMatch, ready }

_BodyKey _contentKey(StudentUiState state) {
  if (!state.hasRoutine) return _BodyKey.needsUpload;
  if (state.queryText.trim().isEmpty) return _BodyKey.blank;
  if (state.invalidQuery) return _BodyKey.invalid;
  if (!state.hasMatches) return _BodyKey.noMatch;
  return _BodyKey.ready;
}
