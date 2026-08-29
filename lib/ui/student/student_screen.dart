import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/pdf_exporter.dart';
import '../../domain/model/class_status.dart';
import '../../domain/model/routine_day.dart';
import '../theme/app_colors.dart';
import 'components/class_timeline.dart';
import 'components/date_strip.dart';
import 'components/decor_blobs.dart';
import 'components/empty_hint.dart';
import 'components/next_class_banner.dart';
import 'components/quick_chips.dart';
import 'components/search_row.dart';
import 'components/student_header.dart';
import 'components/summary_card.dart';
import 'student_view_model.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentViewModel>();
    final state = viewModel.state;
    final showChips = state.suggestions.isNotEmpty &&
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
              const StudentHeader(),
              const SizedBox(height: 18),
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
                  child: _body(state, viewModel),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _body(StudentUiState state, StudentViewModel viewModel) {
    switch (_contentKey(state)) {
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
          body: 'এই ব্যাচ/সেকশনের ক্লাস রুটিনে পাওয়া যায়নি — অন্য চিপ চেষ্টা করো',
          tint: sky,
        );
      case _BodyKey.ready:
        return _ReadyBody(
          state: state,
          onDaySelected: viewModel.onDaySelected,
          onDownload: () { PdfExporter.share(); },
        );
    }
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.state,
    required this.onDaySelected,
    required this.onDownload,
  });

  final StudentUiState state;
  final ValueChanged<RoutineDay> onDaySelected;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final statuses = state.classStatuses.values;
    final allDone = statuses.isNotEmpty &&
        statuses.every((status) => status == ClassStatus.done);

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
          ClassTimeline(items: state.timeline, statuses: state.classStatuses),
        ] else ...[
          const SizedBox(height: 18),
          ClassTimeline(items: state.timeline, statuses: state.classStatuses),
        ],
      ],
    );
  }
}

enum _BodyKey { blank, invalid, noMatch, ready }

_BodyKey _contentKey(StudentUiState state) {
  if (state.queryText.trim().isEmpty) return _BodyKey.blank;
  if (state.invalidQuery) return _BodyKey.invalid;
  if (!state.hasMatches) return _BodyKey.noMatch;
  return _BodyKey.ready;
}
