import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/class_slot.dart';
import '../../domain/model/room_info.dart';
import '../theme/app_colors.dart';
import 'components/select_option_modal.dart';
import 'room_view_model.dart';

class EmptyRoomScreen extends StatelessWidget {
  const EmptyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoomViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                children: [
                  _buildFormCard(context, viewModel, state),
                  const SizedBox(height: 24),
                  if (state.isSubmitted) ...[
                    if (state.errorMessage != null) ...[
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: textMuted),
                      ),
                      const SizedBox(height: 14),
                    ],
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.meeting_room, color: ink, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Room',
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
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line, width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: ink.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: state.isLoading ? null : viewModel.searchEmptyRooms,
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
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
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: line),
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
                  style: const TextStyle(color: ink, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(RoomUiState state) {
    final count = state.results.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          state.selectedTimeIndex > 0
              ? '$count Empty Rooms Available'
              : '$count Free Rooms Available',
          style: const TextStyle(
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${state.selectedDayIndex > 0 ? state.selectedDayLabel : state.resolvedDay.fullLabel} ${state.selectedTimeIndex > 0 ? "(${state.selectedTimeLabel})" : ""}',
          style: const TextStyle(color: textMuted, fontSize: 13),
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
          style: TextStyle(color: textMuted, fontSize: 15),
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
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: Column(
        children: const [
          Icon(Icons.door_sliding_outlined, size: 48, color: ink),
          SizedBox(height: 12),
          Text(
            'Find Free Classrooms',
            style: TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select day and time slot above, then tap "Get Schedule" to see all empty rooms.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 14),
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
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFree ? mint : line),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
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
                      ? mint.withValues(alpha: 0.4)
                      : rose.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFree ? Icons.door_sliding : Icons.meeting_room,
                  color: isFree
                      ? const Color(0xFF166534)
                      : const Color(0xFF991B1B),
                  size: 22,
                ),
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      room.roomName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
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
                          ? mint.withValues(alpha: 0.4)
                          : rose.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isFree ? 'FREE' : 'BUSY',
                      style: TextStyle(
                        color: isFree
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                room.daySlots.isEmpty
                    ? '${room.building} · free this slot'
                    : '${room.building} · ${room.daySlots.length} classes scheduled today',
                style: const TextStyle(color: textMuted, fontSize: 13),
              ),
              trailing: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: textMuted,
              ),
            ),
            if (_expanded && room.daySlots.isNotEmpty) ...[
              const Divider(color: line, height: 1),
              Container(
                padding: const EdgeInsets.all(14),
                color: bg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Schedule for this room:',
                      style: TextStyle(
                        color: ink,
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
              color: lavender.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${slot.start}-${slot.end}',
              style: const TextStyle(
                color: ink,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              slot.courseTitle.isNotEmpty
                  ? '${slot.courseTitle} · ${slot.course}(${slot.group}) - ${slot.teacher}'
                  : '${slot.course} (${slot.group}) - ${slot.teacher}',
              style: const TextStyle(color: ink, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
