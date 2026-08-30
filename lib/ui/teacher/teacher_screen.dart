import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/course_catalog.dart';
import '../../data/pdf_exporter.dart';
import '../../domain/model/class_slot.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/model/student_summary.dart';
import '../../domain/routine_queries.dart';
import '../room/components/select_option_modal.dart';
import '../student/student_view_model.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final TextEditingController _searchController = TextEditingController(
    text: 'TRA',
  );
  String _query = 'TRA';
  int _selectedDeptIndex = 0;
  bool _isWeekView = false;
  RoutineDay _selectedDay = RoutineQueries.todayOrSaturday();
  CourseCatalog? _catalog;

  static const List<String> _deptOptions = ['CSE', 'BBA'];

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
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentViewModel>();
    final slots = viewModel.repository.slots;
    final meta = viewModel.repository.meta;

    final queryClean = _query.trim().toUpperCase();

    // Matched slots for the teacher
    final teacherSlots = queryClean.isEmpty
        ? <ClassSlot>[]
        : slots
              .where((s) => s.teacher.trim().toUpperCase() == queryClean)
              .toList();

    final hasMatches = teacherSlots.isNotEmpty;

    // Derived statistics
    final sections = teacherSlots.map((s) => s.group).toSet().toList()..sort();
    final courses = teacherSlots.map((s) => s.course).toSet().toList()..sort();
    final classesPerWeek = teacherSlots.length;
    final weeklyMap = RoutineQueries.weeklyBlocks(teacherSlots);

    return Scaffold(
      backgroundColor: const Color(0xFF13141F),
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
                            color: const Color(0xFF1E1F2E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2E3048)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                queryClean,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.close,
                                color: Colors.white70,
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
                  ] else if (queryClean.isNotEmpty) ...[
                    _buildEmptyState(
                      'No Teacher Found',
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
          // Purple Teacher logo badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.badge, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Teacher',
            style: TextStyle(
              color: Colors.white,
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
              color: const Color(0xFF0B281B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF166534)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
                SizedBox(width: 6),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
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
              color: const Color(0xFF1E1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white70,
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
              color: const Color(0xFF1E1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white70, size: 22),
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
              color: const Color(0xFF1B1C2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2B2D42)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
                hintText: 'Search Teacher Initial (e.g. TRA)',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
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
        // Dept Dropdown Button: CSE v
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
              color: const Color(0xFF1B1C2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2B2D42)),
            ),
            child: Row(
              children: [
                Text(
                  _deptOptions[_selectedDeptIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white54,
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
        color: const Color(0xFF1B1C2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B2D42)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                'Registered Courses',
                style: TextStyle(
                  color: Colors.white,
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
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF9D8CFF),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              // Bell Icon Button matching screenshot
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A82F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
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

          // Download PDF for TRA button matching screenshot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Download PDF for $teacherName',
                style: const TextStyle(
                  color: Colors.white70,
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
                    color: const Color(0xFF8B5CF6),
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
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
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
                gradient: !_isWeekView
                    ? const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFF)],
                      )
                    : null,
                color: _isWeekView ? const Color(0xFF1B1C2A) : null,
                borderRadius: BorderRadius.circular(14),
                border: _isWeekView
                    ? Border.all(color: const Color(0xFF2B2D42))
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: !_isWeekView ? Colors.white : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Day View',
                    style: TextStyle(
                      color: !_isWeekView ? Colors.white : Colors.white54,
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
                gradient: _isWeekView
                    ? const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFF)],
                      )
                    : null,
                color: !_isWeekView ? const Color(0xFF1B1C2A) : null,
                borderRadius: BorderRadius.circular(14),
                border: !_isWeekView
                    ? Border.all(color: const Color(0xFF2B2D42))
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: _isWeekView ? Colors.white : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Week View',
                    style: TextStyle(
                      color: _isWeekView ? Colors.white : Colors.white54,
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
    // Map dates matching screenshot: 29 Sat, 30 Sun, 31 Mon, 1 Tue, 2 Wed, 3 Thu
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
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: !isSelected ? const Color(0xFF1B1C2A) : null,
                  borderRadius: BorderRadius.circular(16),
                  border: !isSelected
                      ? Border.all(color: const Color(0xFF2B2D42))
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF6C5CE7,
                            ).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      dateNum,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.shortLabel,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.white54,
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
          color: const Color(0xFF1B1C2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2B2D42)),
        ),
        child: Column(
          children: const [
            Icon(Icons.event_available, color: Color(0xFF22C55E), size: 40),
            SizedBox(height: 10),
            Text(
              'Off Day',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'No classes scheduled for this teacher on this day.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
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
            color: const Color(0xFF1B1C2A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2B2D42)),
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
                      color: Colors.white,
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
                          ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                          : const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOffDay ? 'Off Day' : '${dayBlocks.length} Classes',
                      style: TextStyle(
                        color: isOffDay
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF9D8CFF),
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
                    style: TextStyle(color: Colors.white38, fontSize: 13),
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
        color: const Color(0xFF171826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF282A40)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column (Left) matching screenshot
          Column(
            children: [
              Text(
                block.start,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.white24,
              ),
              Text(
                block.end,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 70, color: const Color(0xFF282A40)),
          const SizedBox(width: 16),

          // Details Column matching screenshot
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF91A7FF),
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
                  valueColor: const Color(0xFF8B5CF6),
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
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
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
        color: const Color(0xFF1B1C2A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B2D42)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 48,
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
