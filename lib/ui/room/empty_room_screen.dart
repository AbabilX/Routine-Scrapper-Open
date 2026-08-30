import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/class_slot.dart';
import '../../domain/model/room_info.dart';
import 'components/select_option_modal.dart';
import 'room_view_model.dart';

class EmptyRoomScreen extends StatelessWidget {
  const EmptyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoomViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFF13141F),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching screenshot 1
            _buildAppBar(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                children: [
                  // Form Card Box matching screenshot 1
                  _buildFormCard(context, viewModel, state),

                  const SizedBox(height: 24),

                  // Results Header & List
                  if (state.isSubmitted) ...[
                    _buildResultsHeader(state),
                    const SizedBox(height: 14),
                    _buildResultsList(context, state),
                  ] else ...[
                    _buildInitialHint(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          // Purple Room logo badge
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
            child: const Icon(
              Icons.meeting_room,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Room',
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
          // Header action buttons
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

  Widget _buildFormCard(
    BuildContext context,
    RoomViewModel viewModel,
    RoomUiState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B2D42), width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Room Number text field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13141E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E3048)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Room Number (e.g., 611)',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 15),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: viewModel.onRoomQueryChanged,
            ),
          ),

          const SizedBox(height: 14),

          // Dropdown row: Select Day & Select Time
          Row(
            children: [
              Expanded(
                child: _buildDropdownButton(
                  context,
                  label: state.selectedDayLabel,
                  onTap: () async {
                    final choice = await SelectOptionModal.show(
                      context: context,
                      title: 'Select Day',
                      options: RoomUiState.daysOptions,
                      selectedIndex: state.selectedDayIndex,
                    );
                    if (choice != null) {
                      viewModel.selectDayIndex(choice);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownButton(
                  context,
                  label: state.selectedTimeLabel,
                  onTap: () async {
                    final choice = await SelectOptionModal.show(
                      context: context,
                      title: 'Select Time',
                      options: RoomUiState.timeOptions,
                      selectedIndex: state.selectedTimeIndex,
                    );
                    if (choice != null) {
                      viewModel.selectTimeIndex(choice);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Department Dropdown: CSE
          _buildDropdownButton(
            context,
            label: state.selectedDeptLabel,
            onTap: () async {
              final choice = await SelectOptionModal.show(
                context: context,
                title: 'Select Department',
                options: RoomUiState.deptOptions,
                selectedIndex: state.selectedDeptIndex,
              );
              if (choice != null) {
                viewModel.selectDeptIndex(choice);
              }
            },
          ),

          const SizedBox(height: 20),

          // Gradient Search Button matching image 1
          Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A82F6), Color(0xFF8B5CF6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3A82F6).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: viewModel.searchEmptyRooms,
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Get Schedule',
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF13141E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3048)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(RoomUiState state) {
    final emptyCount = state.results.where((r) => r.isEmpty).length;
    final totalCount = state.results.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          state.selectedTimeIndex > 0
              ? '$emptyCount Empty Rooms Available'
              : 'All Rooms ($totalCount)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${state.selectedDayLabel} ${state.selectedTimeIndex > 0 ? "(${state.selectedTimeLabel})" : ""}',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildResultsList(BuildContext context, RoomUiState state) {
    if (state.results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          'No rooms match your search criteria',
          style: TextStyle(color: Colors.white54, fontSize: 15),
        ),
      );
    }

    return Column(
      children: state.results.map((roomInfo) {
        return _RoomCard(roomInfo: roomInfo);
      }).toList(),
    );
  }

  Widget _buildInitialHint() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C2A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B2D42)),
      ),
      child: Column(
        children: const [
          Icon(Icons.door_sliding_outlined, size: 48, color: Color(0xFF8B5CF6)),
          SizedBox(height: 12),
          Text(
            'Find Free Classrooms',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select day and time slot above, then tap "Get Schedule" to see all empty rooms.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatefulWidget {
  const _RoomCard({required this.roomInfo});

  final RoomInfo roomInfo;

  @override
  State<_RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<_RoomCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.roomInfo;
    final isFree = room.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFree
              ? const Color(0xFF22C55E).withValues(alpha: 0.4)
              : const Color(0xFF2B2D42),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFree
                    ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                    : const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isFree ? Icons.door_sliding : Icons.meeting_room,
                color: isFree
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                size: 22,
              ),
            ),
            title: Row(
              children: [
                Text(
                  room.roomName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isFree
                        ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                        : const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isFree ? 'FREE' : 'BUSY',
                    style: TextStyle(
                      color: isFree
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${room.building} · ${room.daySlots.length} classes scheduled today',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            trailing: Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white54,
            ),
          ),
          if (_expanded && room.daySlots.isNotEmpty) ...[
            const Divider(color: Color(0xFF2B2D42), height: 1),
            Container(
              padding: const EdgeInsets.all(14),
              color: const Color(0xFF151624),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Schedule for this room:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...room.daySlots.map((slot) => _buildSlotRow(slot)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlotRow(ClassSlot slot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D42),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${slot.start}-${slot.end}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${slot.course} (${slot.group}) - ${slot.teacher}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
