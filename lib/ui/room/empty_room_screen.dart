import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/class_slot.dart';
import '../../domain/model/room_info.dart';
import '../components/cute_face_kind.dart';
import '../components/cute_header.dart';
import '../components/cute_page.dart';
import '../components/cute_pill.dart';
import '../components/cute_primary_button.dart';
import '../components/empty_hint.dart';
import '../theme/app_colors.dart';
import 'components/select_option_modal.dart';
import 'room_view_model.dart';

class EmptyRoomScreen extends StatelessWidget {
  const EmptyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoomViewModel>();
    final state = viewModel.state;
    final text = Theme.of(context).textTheme;

    return CutePage(
      children: [
        const CuteHeader(
          title: 'খালি রুম',
          subtitle: 'দিন ও সময় বেছে ফাঁকা ক্লাসরুম খুঁজে নাও',
          faceKind: CuteFaceKind.bear,
        ),
        const SizedBox(height: 18),
        _FilterCard(viewModel: viewModel, state: state),
        const SizedBox(height: 18),
        if (!state.isSubmitted)
          const EmptyHint(
            title: 'খালি রুম খুঁজো',
            body:
                'উপরে দিন ও সময় বেছে "খুঁজো" চাপো — ফাঁকা ক্লাসরুমগুলো দেখাবে।',
            tint: mint,
          )
        else if (state.errorMessage != null)
          EmptyHint(
            title: 'কিছু একটা হলো',
            body: state.errorMessage!,
            tint: rose,
          )
        else ...[
          Text(
            state.selectedTimeIndex > 0
                ? '${state.results.length} খালি রুম'
                : '${state.results.length} ফ্রি রুম',
            style: text.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _resultsSubtitle(state),
            style: text.labelSmall,
          ),
          const SizedBox(height: 14),
          if (state.results.isEmpty)
            const EmptyHint(
              title: 'কোনো ম্যাচ নেই',
              body: 'অন্য দিন বা সময় স্লট চেষ্টা করো।',
              tint: peach,
            )
          else
            for (final room in state.results)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RoomCard(roomInfo: room),
              ),
        ],
        const SizedBox(height: 28),
      ],
    );
  }

  String _resultsSubtitle(RoomUiState state) {
    final day = state.selectedDayIndex > 0
        ? state.selectedDayLabel
        : state.resolvedDay.fullLabel;
    if (state.selectedTimeIndex > 0) {
      return '$day · ${state.selectedTimeLabel}';
    }
    return day;
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.viewModel,
    required this.state,
  });

  final RoomViewModel viewModel;
  final RoomUiState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: lavender.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CutePill(
                    expand: true,
                    label: state.selectedDayLabel,
                    onTap: () async {
                      final choice = await SelectOptionModal.show(
                        context: context,
                        title: 'Select Day',
                        options: RoomUiState.daysOptions,
                        selectedIndex: state.selectedDayIndex,
                      );
                      if (choice != null) viewModel.selectDayIndex(choice);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CutePill(
                    expand: true,
                    label: state.selectedTimeLabel,
                    onTap: () async {
                      final choice = await SelectOptionModal.show(
                        context: context,
                        title: 'Select Time',
                        options: RoomUiState.timeOptions,
                        selectedIndex: state.selectedTimeIndex,
                      );
                      if (choice != null) viewModel.selectTimeIndex(choice);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CutePill(
              expand: true,
              label: state.selectedDeptLabel,
              onTap: () async {
                final choice = await SelectOptionModal.show(
                  context: context,
                  title: 'Select Department',
                  options: RoomUiState.deptOptions,
                  selectedIndex: state.selectedDeptIndex,
                );
                if (choice != null) viewModel.selectDeptIndex(choice);
              },
            ),
            const SizedBox(height: 14),
            CutePrimaryButton(
              label: 'খুঁজো',
              loading: state.isLoading,
              onTap: viewModel.searchEmptyRooms,
            ),
          ],
        ),
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
    final text = Theme.of(context).textTheme;
    final tint = isFree ? mint : peach;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isFree ? Icons.door_sliding : Icons.meeting_room,
                        color: ink,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  room.roomName,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusChip(free: isFree),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            room.daySlots.isEmpty
                                ? '${room.building} · এই স্লটে ফাঁকা'
                                : '${room.building} · আজ ${room.daySlots.length} ক্লাস',
                            style: text.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded && room.daySlots.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('আজকের শিডিউল', style: text.labelSmall),
                        const SizedBox(height: 8),
                        for (final slot in room.daySlots)
                          _SlotRow(slot: slot),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.free});

  final bool free;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: free ? mint : rose,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        free ? 'FREE' : 'BUSY',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot});

  final ClassSlot slot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final label = slot.courseTitle.isNotEmpty
        ? '${slot.courseTitle} · ${slot.course}(${slot.group}) — ${slot.teacher}'
        : '${slot.course} (${slot.group}) — ${slot.teacher}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${slot.start}-${slot.end}',
              style: text.labelSmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
