import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/model/routine_day.dart';
import '../../domain/model/student_summary.dart';
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

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<TeacherViewModel>().state.query;
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teacherVm = context.watch<TeacherViewModel>();
    final state = teacherVm.state;

    // Synchronize controller text when state query is modified externally (e.g. on suggestion selection or clear)
    if (_searchController.text != state.query) {
      _searchController.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                children: [
                  // Search Bar & Department Dropdown
                  _buildSearchRow(context, teacherVm, state),

                  const SizedBox(height: 12),

                  // Search Button
                  _buildSearchButton(context, teacherVm, state),

                  if (state.suggestions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildVerticalSuggestions(teacherVm, state),
                  ],

                  if (state.cleanQuery.isNotEmpty && state.hasMatches) ...[
                    const SizedBox(height: 10),
                    // Active Search Chip
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: teacherVm.clear,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lavender.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.cleanQuery,
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.close,
                                color: textMuted,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  if (state.hasMatches) ...[
                    // Teacher Summary Card
                    _buildSummaryCard(
                      teacherName: state.cleanQuery,
                      sections: state.sections,
                      totalCourses: state.courses.length,
                      version: state.meta?.version ?? '',
                      classesPerWeek: state.classesPerWeek,
                      onDownloadPdf: teacherVm.downloadPdf,
                    ),

                    const SizedBox(height: 20),

                    // Day View / Week View Toggle Bar
                    _buildViewToggle(teacherVm, state),

                    const SizedBox(height: 16),

                    if (!state.isWeekView) ...[
                      // Day View Date Strip
                      _buildDateStrip(teacherVm, state),
                      const SizedBox(height: 16),
                      _buildDayClassesView(state.selectedDayClasses),
                    ] else ...[
                      // Week View Schedule
                      _buildWeekScheduleView(state.weeklyMap),
                    ],
                  ] else if (state.isLoading) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else if (state.suggestions.isNotEmpty) ...[
                    const SizedBox.shrink(),
                  ] else if (state.cleanQuery.isNotEmpty) ...[
                    _buildEmptyState(
                      'No Teacher Found',
                      state.errorMessage ??
                          'No classes found for teacher initial "${state.cleanQuery}"',
                    ),
                  ] else ...[
                    _buildEmptyState(
                      'Search Teacher Routine',
                      'Type a teacher initial (e.g. TRA, MRN) above',
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.badge, color: ink, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Teacher',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: mint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, color: Color(0xFF166534), size: 8),
                SizedBox(width: 6),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: line),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: ink,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: line),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: ink, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(
    BuildContext context,
    TeacherViewModel teacherVm,
    TeacherUiState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: line),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: teacherVm.onQueryChanged,
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
                teacherVm.search();
              },
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              style: const TextStyle(color: ink, fontSize: 16),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                hintText: 'Search Teacher Initial (e.g. TRA)',
                hintStyle: TextStyle(color: textMuted, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Dept Dropdown Button
        GestureDetector(
          onTap: () async {
            final choice = await SelectOptionModal.show(
              context: context,
              title: 'Select Department',
              options: TeacherUiState.deptOptions,
              selectedIndex: state.selectedDeptIndex,
            );
            if (choice != null) {
              teacherVm.selectDeptIndex(choice);
            }
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: line),
            ),
            child: Row(
              children: [
                Text(
                  state.selectedDeptLabel,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton(
    BuildContext context,
    TeacherViewModel teacherVm,
    TeacherUiState state,
  ) {
    final bool canSearch = state.query.trim().isNotEmpty;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: canSearch ? ink : ink.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: canSearch
            ? [
                BoxShadow(
                  color: ink.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state.isLoading || !canSearch
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  teacherVm.search();
                },
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSuggestions(
    TeacherViewModel teacherVm,
    TeacherUiState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: ink, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Suggestions (${state.suggestions.length})',
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: line),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.suggestions.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: line),
            itemBuilder: (context, index) {
              final suggestion = state.suggestions[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: lavender.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: ink, size: 18),
                ),
                title: Text(
                  suggestion,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.north_west,
                  color: textMuted,
                  size: 16,
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  teacherVm.onSuggestionTapped(suggestion);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String teacherName,
    required List<String> sections,
    required int totalCourses,
    required String version,
    required int classesPerWeek,
    required VoidCallback onDownloadPdf,
  }) {
    final sectionsText = sections.join(', ');

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.keyboard_arrow_down,
                color: textMuted,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                'Registered Courses',
                style: TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: lavender.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: ink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: sky.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: ink,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _summaryRow('Teacher', teacherName),
          const SizedBox(height: 8),
          _summaryRow('Sections', sectionsText),
          const SizedBox(height: 8),
          _summaryRow('Total Courses', '$totalCourses'),
          const SizedBox(height: 8),
          _summaryRow('Routine Version', version),
          const SizedBox(height: 8),
          _summaryRow('Classes per Week', '$classesPerWeek'),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Download PDF for $teacherName',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onDownloadPdf,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: textMuted, fontSize: 14),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: ink,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle(TeacherViewModel teacherVm, TeacherUiState state) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => teacherVm.toggleView(false),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: !state.isWeekView ? ink : surface,
                borderRadius: BorderRadius.circular(14),
                border: state.isWeekView ? Border.all(color: line) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: !state.isWeekView ? Colors.white : textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Day View',
                    style: TextStyle(
                      color: !state.isWeekView ? Colors.white : textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => teacherVm.toggleView(true),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: state.isWeekView ? ink : surface,
                borderRadius: BorderRadius.circular(14),
                border: !state.isWeekView ? Border.all(color: line) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: state.isWeekView ? Colors.white : textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Week View',
                    style: TextStyle(
                      color: state.isWeekView ? Colors.white : textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateStrip(TeacherViewModel teacherVm, TeacherUiState state) {
    final days = RoutineDay.values;
    final dateNumbers = ['29', '30', '31', '1', '2', '3'];

    return Row(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isSelected = day == state.resolvedDay;
        final dateNum = dateNumbers[index];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < days.length - 1 ? 6 : 0),
            child: GestureDetector(
              onTap: () => teacherVm.selectDay(day),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? ink : surface,
                  borderRadius: BorderRadius.circular(16),
                  border: !isSelected ? Border.all(color: line) : null,
                ),
                child: Column(
                  children: [
                    Text(
                      dateNum,
                      style: TextStyle(
                        color: isSelected ? Colors.white : ink,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.shortLabel,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayClassesView(List<ClassBlock> blocks) {
    if (blocks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: line),
        ),
        child: Column(
          children: const [
            Icon(Icons.event_available, color: ink, size: 40),
            SizedBox(height: 10),
            Text(
              'Off Day',
              style: TextStyle(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'No classes scheduled for this teacher on this day.',
              style: TextStyle(color: textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: blocks.map((block) => _buildClassCard(block)).toList(),
    );
  }

  Widget _buildWeekScheduleView(Map<RoutineDay, List<ClassBlock>> weeklyMap) {
    return Column(
      children: RoutineDay.values.map((day) {
        final dayBlocks = weeklyMap[day] ?? [];
        final isOffDay = dayBlocks.isEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: line),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day.fullLabel,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOffDay
                          ? mint.withValues(alpha: 0.4)
                          : lavender.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOffDay ? 'Off Day' : '${dayBlocks.length} Classes',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isOffDay)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No classes scheduled',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                )
              else
                ...dayBlocks.map(
                  (block) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildClassCard(block),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClassCard(ClassBlock block) {
    final title =
        block.courseTitle.isNotEmpty ? block.courseTitle : block.course;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column (Left)
          Column(
            children: [
              Text(
                block.start,
                style: const TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: line,
              ),
              Text(
                block.end,
                style: const TextStyle(color: textMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 70, color: line),
          const SizedBox(width: 16),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _cardDetailRow('Course', block.course),
                const SizedBox(height: 4),
                _cardDetailRow('Section', '${block.course}(${block.group})'),
                const SizedBox(height: 4),
                _cardDetailRow(
                  'Teacher',
                  block.teacher,
                  valueColor: ink,
                ),
                const SizedBox(height: 4),
                _cardDetailRow('Room', block.room),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: textMuted, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 48,
            color: ink,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
