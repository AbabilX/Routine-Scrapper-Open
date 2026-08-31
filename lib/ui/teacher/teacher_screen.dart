import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/model/routine_day.dart';
import '../../domain/model/student_summary.dart';
import '../../domain/routine_queries.dart';
import '../components/cute_face_kind.dart';
import '../components/cute_header.dart';
import '../components/cute_page.dart';
import '../components/cute_pill.dart';
import '../components/cute_primary_button.dart';
import '../components/date_strip.dart';
import '../components/empty_hint.dart';
import '../components/search_row.dart';
import '../components/suggestion_list.dart';
import '../room/components/select_option_modal.dart';
import '../theme/app_colors.dart';
import 'teacher_view_model.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class TeacherScreen extends StatelessWidget {
  const TeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherVm = context.watch<TeacherViewModel>();
    final state = teacherVm.state;

    return CutePage(
      header: [
        const CuteHeader(
          title: 'টিচার',
          subtitle: 'ইনিশিয়াল দিয়ে রুটিন খুঁজে নাও',
          faceKind: CuteFaceKind.fox,
        ),
        const SizedBox(height: 18),
        SearchRow(
          query: state.query,
          onQueryChange: teacherVm.onQueryChanged,
          hintText: 'TRA',
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [UpperCaseTextFormatter()],
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
            teacherVm.search();
          },
          trailing: CutePill(
            label: state.selectedDeptLabel,
            onTap: () async {
              final choice = await SelectOptionModal.show(
                context: context,
                title: 'Select Department',
                options: TeacherUiState.deptOptions,
                selectedIndex: state.selectedDeptIndex,
              );
              if (choice != null) teacherVm.selectDeptIndex(choice);
            },
          ),
        ),
        const SizedBox(height: 12),
        CutePrimaryButton(
          label: 'খুঁজো',
          loading: state.isLoading,
          enabled: state.query.trim().isNotEmpty,
          onTap: () {
            FocusScope.of(context).unfocus();
            teacherVm.search();
          },
        ),
        if (state.cleanQuery.isNotEmpty && state.hasMatches) ...[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: teacherVm.clear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: lavender,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.cleanQuery,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.close, color: textMuted, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
      body: [
        if (state.suggestions.isNotEmpty)
          SuggestionList(
            items: state.suggestions,
            onSelect: teacherVm.onSuggestionTapped,
          )
        else if (state.hasMatches) ...[
          _TeacherSummaryCard(
            teacherName: state.cleanQuery,
            sections: state.sections,
            totalCourses: state.courses.length,
            version: state.meta?.version ?? '',
            classesPerWeek: state.classesPerWeek,
            onDownloadPdf: teacherVm.downloadPdf,
          ),
          const SizedBox(height: 18),
          _ViewToggle(isWeekView: state.isWeekView, onToggle: teacherVm.toggleView),
          const SizedBox(height: 16),
          if (!state.isWeekView) ...[
            DateStrip(
              selected: state.resolvedDay,
              today: RoutineQueries.todayOrSaturday(),
              onSelect: teacherVm.selectDay,
            ),
            const SizedBox(height: 16),
            _DayClassesView(blocks: state.selectedDayClasses),
          ] else
            _WeekScheduleView(weeklyMap: state.weeklyMap),
        ] else if (state.isLoading) ...[
          const EmptyHint(
            title: 'খুঁজছি',
            body: 'টিচারের রুটিন আনছি…',
            tint: sky,
          ),
        ] else if (state.cleanQuery.isNotEmpty) ...[
          EmptyHint(
            title: 'কেউ নেই',
            body: state.errorMessage ??
                '"${state.cleanQuery}" এর ক্লাস পাওয়া যায়নি',
            tint: rose,
          ),
        ] else ...[
          const EmptyHint(
            title: 'শুরু করো',
            body: 'টিচার ইনিশিয়াল লিখো — যেমন TRA, MRN',
            tint: peach,
          ),
        ],
      ],
    );
  }
}

class _TeacherSummaryCard extends StatelessWidget {
  const _TeacherSummaryCard({
    required this.teacherName,
    required this.sections,
    required this.totalCourses,
    required this.version,
    required this.classesPerWeek,
    required this.onDownloadPdf,
  });

  final String teacherName;
  final List<String> sections;
  final int totalCourses;
  final String version;
  final int classesPerWeek;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: lavender,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('রেজিস্টার্ড কোর্স', style: text.titleLarge),
            const SizedBox(height: 14),
            _summaryRow('Teacher', teacherName),
            const SizedBox(height: 8),
            _summaryRow('Sections', sections.join(', ')),
            const SizedBox(height: 8),
            _summaryRow('Total Courses', '$totalCourses'),
            const SizedBox(height: 8),
            _summaryRow('Routine Version', version),
            const SizedBox(height: 8),
            _summaryRow('Classes / week', '$classesPerWeek'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'PDF ডাউনলোড — $teacherName',
                    style: text.bodyMedium,
                  ),
                ),
                Material(
                  color: ink,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onDownloadPdf,
                    borderRadius: BorderRadius.circular(16),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.file_download_outlined,
                        color: onInk,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isWeekView, required this.onToggle});

  final bool isWeekView;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleChip(
              label: 'দিন',
              selected: !isWeekView,
              onTap: () => onToggle(false),
            ),
          ),
          Expanded(
            child: _ToggleChip(
              label: 'সপ্তাহ',
              selected: isWeekView,
              onTap: () => onToggle(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ink : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? onInk : textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayClassesView extends StatelessWidget {
  const _DayClassesView({required this.blocks});

  final List<ClassBlock> blocks;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const EmptyHint(
        title: 'Off day',
        body: 'এই দিনে এই টিচারের ক্লাস নেই',
        tint: mint,
      );
    }
    return Column(
      children: [for (final block in blocks) _ClassCard(block: block)],
    );
  }
}

class _WeekScheduleView extends StatelessWidget {
  const _WeekScheduleView({required this.weeklyMap});

  final Map<RoutineDay, List<ClassBlock>> weeklyMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final day in RoutineDay.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          day.fullLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (weeklyMap[day] ?? []).isEmpty
                                ? mint
                                : lavender,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            (weeklyMap[day] ?? []).isEmpty
                                ? 'Off'
                                : '${weeklyMap[day]!.length} ক্লাস',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if ((weeklyMap[day] ?? []).isEmpty)
                      const Text(
                        'ক্লাস নেই',
                        style: TextStyle(color: textMuted, fontSize: 13),
                      )
                    else
                      for (final block in weeklyMap[day]!)
                        _ClassCard(block: block),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.block});

  final ClassBlock block;

  @override
  Widget build(BuildContext context) {
    final title =
        block.courseTitle.isNotEmpty ? block.courseTitle : block.course;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: peach.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                block.start,
                style: const TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: line,
              ),
              Text(
                block.end,
                style: const TextStyle(color: textMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${block.course} · ${block.group} · ${block.room}',
                  style: const TextStyle(color: textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
