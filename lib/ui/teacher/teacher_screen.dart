import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/course_catalog.dart';
import '../../data/pdf_exporter.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/model/student_summary.dart';
import '../../domain/routine_queries.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _selectedDeptIndex = 0;
  bool _isWeekView = false;
  RoutineDay _selectedDay = RoutineQueries.todayOrSaturday();
  CourseCatalog? _catalog;

  static const List<String> _deptOptions = ['CSE'];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final cat = await CourseCatalog.load();
    if (mounted) {
      setState(() => _catalog = cat);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String val) {
    setState(() => _query = val.trim());
    context.read<TeacherViewModel>().onQueryChanged(val);
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
    context.read<TeacherViewModel>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final teacherVm = context.watch<TeacherViewModel>();
    final teacherSlots = teacherVm.slots;
    final meta = teacherVm.meta;

    final queryClean = _query.trim().toUpperCase();

    final hasMatches = teacherSlots.isNotEmpty;

    // Derived statistics
    final sections = teacherSlots.map((s) => s.group).toSet().toList()..sort();
    final courses = teacherSlots.map((s) => s.course).toSet().toList()..sort();
    final classesPerWeek = teacherSlots.length;
    final weeklyMap = RoutineQueries.weeklyBlocks(teacherSlots);

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
                  _buildSearchRow(context),

                  if (queryClean.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    // Active Search Chip: "TRA x"
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: _clearQuery,
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
                                queryClean,
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

                  if (hasMatches) ...[
                    // Teacher Summary Card
                    _buildSummaryCard(
                      teacherName: queryClean,
                      sections: sections,
                      totalCourses: courses.length,
                      version: meta.version,
                      classesPerWeek: classesPerWeek,
                      onDownloadPdf: () async {
                        await PdfExporter.shareSchedule(
                          queryLabel: queryClean,
                          meta: meta,
                          week: weeklyMap,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Day View / Week View Toggle Bar
                    _buildViewToggle(),

                    const SizedBox(height: 16),

                    if (!_isWeekView) ...[
                      // Day View Date Strip
                      _buildDateStrip(),
                      const SizedBox(height: 16),
                      _buildDayClassesView(weeklyMap[_selectedDay] ?? []),
                    ] else ...[
                      // Week View Schedule (All days with Off Days)
                      _buildWeekScheduleView(weeklyMap),
                    ],
                  ] else if (teacherVm.isLoading) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else if (queryClean.isNotEmpty) ...[
                    _buildEmptyState(
                      'No Teacher Found',
                      teacherVm.error ??
                          'No classes found for teacher initial "$queryClean"',
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
          // Teacher logo badge
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
          // Online status pill
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

  Widget _buildSearchRow(BuildContext context) {
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
              onChanged: _onQueryChanged,
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
              options: _deptOptions,
              selectedIndex: _selectedDeptIndex,
            );
            if (choice != null) {
              setState(() => _selectedDeptIndex = choice);
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
                  _deptOptions[_selectedDeptIndex],
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
              // Info Icon Button
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
              // Bell Icon Button
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

          // Download PDF button
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

  Widget _buildViewToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isWeekView = false),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: !_isWeekView ? ink : surface,
                borderRadius: BorderRadius.circular(14),
                border: _isWeekView ? Border.all(color: line) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: !_isWeekView ? Colors.white : textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Day View',
                    style: TextStyle(
                      color: !_isWeekView ? Colors.white : textMuted,
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
            onTap: () => setState(() => _isWeekView = true),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _isWeekView ? ink : surface,
                borderRadius: BorderRadius.circular(14),
                border: !_isWeekView ? Border.all(color: line) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: _isWeekView ? Colors.white : textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Week View',
                    style: TextStyle(
                      color: _isWeekView ? Colors.white : textMuted,
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

  Widget _buildDateStrip() {
    final days = RoutineDay.values;
    final dateNumbers = ['29', '30', '31', '1', '2', '3'];

    return Row(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isSelected = day == _selectedDay;
        final dateNum = dateNumbers[index];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < days.length - 1 ? 6 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = day),
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
    final title = _catalog?.nameOf(block.course) ?? block.course;

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
