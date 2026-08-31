const DAYS = ['SATURDAY', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY'];

// State
let currentQuery = '68_C';
let selectedDay = getTodayOrSaturday();
let allSlots = [];
let metaInfo = {};

// DOM Elements
const searchInput = document.getElementById('searchInput');
const clearSearchBtn = document.getElementById('clearSearchBtn');
const themeToggleBtn = document.getElementById('themeToggleBtn');
const dayTabsContainer = document.getElementById('dayTabsContainer');
const currentDayTitle = document.getElementById('currentDayTitle');
const dayMetaStats = document.getElementById('dayMetaStats');
const timelineContainer = document.getElementById('timelineContainer');
const emptyState = document.getElementById('emptyState');
const emptyStateMsg = document.getElementById('emptyStateMsg');
const summaryTarget = document.getElementById('summaryTarget');
const summaryCourses = document.getElementById('summaryCourses');
const summaryClasses = document.getElementById('summaryClasses');
const summaryVersion = document.getElementById('summaryVersion');
const coursesGrid = document.getElementById('coursesGrid');

// Initialize
async function init() {
  try {
    const res = await fetch('/app/src/main/assets/routine/cse_summer_2026_v5.json');
    const routineData = await res.json();
    allSlots = routineData.slots || [];
    metaInfo = routineData.meta || {};
    summaryVersion.textContent = `${metaInfo.department || 'CSE'} ${metaInfo.version || 'V5'} (${metaInfo.semester || 'Summer 2026'})`;
  } catch (e) {
    console.error('Failed to load routine JSON:', e);
    summaryVersion.textContent = 'CSE V5 (Summer 2026)';
  }
  
  setupEventListeners();
  updateUI();
}

function setupEventListeners() {
  // Theme Toggle
  themeToggleBtn.addEventListener('click', () => {
    document.body.classList.toggle('light');
    document.body.classList.toggle('dark');
  });

  // Search input
  searchInput.addEventListener('input', (e) => {
    currentQuery = e.target.value;
    clearSearchBtn.style.display = currentQuery ? 'flex' : 'none';
    updateUI();
  });

  clearSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    currentQuery = '';
    clearSearchBtn.style.display = 'none';
    searchInput.focus();
    updateUI();
  });

  // Preset chips
  document.querySelectorAll('.chip').forEach(chip => {
    chip.addEventListener('click', () => {
      const q = chip.getAttribute('data-query');
      searchInput.value = q;
      currentQuery = q;
      clearSearchBtn.style.display = 'flex';
      updateUI();
    });
  });

  // Day tabs
  dayTabsContainer.querySelectorAll('.day-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      selectedDay = tab.getAttribute('data-day');
      updateDayTabsActiveState();
      renderTimeline();
    });
  });
}

function getTodayOrSaturday() {
  const dayNames = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
  const todayName = dayNames[new Date().getDay()];
  return DAYS.includes(todayName) ? todayName : 'SATURDAY';
}

function parseQuery(raw) {
  const cleaned = raw.trim().toUpperCase().replace(/\s+/g, '');
  if (!cleaned) return null;

  // Pattern 1: Batch + Section, e.g., 68_C or 68C
  const fullMatch = cleaned.match(/^(\d{2,3})_?([A-Z]\d?)$/);
  if (fullMatch) {
    return { type: 'STUDENT', batch: fullMatch[1], section: fullMatch[2] };
  }

  // Pattern 2: Batch only, e.g. 68
  const batchMatch = cleaned.match(/^(\d{2,3})$/);
  if (batchMatch) {
    return { type: 'STUDENT', batch: batchMatch[1], section: '' };
  }

  // Generic Search: Teacher initial, Room code, Course code
  return { type: 'GENERIC', raw: cleaned };
}

function matchesSlot(slot, parsedQuery) {
  if (!parsedQuery) return true;

  if (parsedQuery.type === 'STUDENT') {
    const group = (slot.group || '').toUpperCase();
    const batch = parsedQuery.batch;
    const section = parsedQuery.section;

    if (!section) {
      return group === batch || group.startsWith(`${batch}_`);
    }

    const exact = `${batch}_${section}`;
    if (group === exact) return true;
    if (group.startsWith(exact) && group.length > exact.length) {
      const nextChar = group[exact.length];
      return /\d/.test(nextChar);
    }
    return false;
  } else {
    // Generic match on group, teacher, room, course
    const q = parsedQuery.raw;
    return (
      (slot.group || '').toUpperCase().includes(q) ||
      (slot.teacher || '').toUpperCase().includes(q) ||
      (slot.room || '').toUpperCase().includes(q) ||
      (slot.course || '').toUpperCase().includes(q)
    );
  }
}

function filterSlots(slots, queryStr) {
  const parsed = parseQuery(queryStr);
  if (!parsed && queryStr.trim()) {
    const q = queryStr.trim().toUpperCase();
    return slots.filter(s =>
      (s.group || '').toUpperCase().includes(q) ||
      (s.teacher || '').toUpperCase().includes(q) ||
      (s.room || '').toUpperCase().includes(q) ||
      (s.course || '').toUpperCase().includes(q)
    );
  }
  return slots.filter(s => matchesSlot(s, parsed));
}

function mergeContiguousSlots(slots) {
  const ordered = [...slots].sort((a, b) => a.slot - b.slot);
  const blocks = [];

  for (const slot of ordered) {
    const last = blocks[blocks.length - 1];
    if (
      last &&
      last.course === slot.course &&
      last.group === slot.group &&
      last.teacher === slot.teacher &&
      last.room === slot.room &&
      last.endSlot + 1 === slot.slot
    ) {
      last.endSlot = slot.slot;
      last.end = slot.end;
      last.isLab = true;
    } else {
      blocks.push({
        day: slot.day,
        startSlot: slot.slot,
        endSlot: slot.slot,
        start: slot.start,
        end: slot.end,
        course: slot.course,
        group: slot.group,
        teacher: slot.teacher,
        room: slot.room,
        isLab: (slot.room && slot.room.includes('LAB')) || (slot.course && /\d{3}[13579]/.test(slot.course))
      });
    }
  }

  return blocks;
}

function timeToMinutes(hhmm) {
  if (!hhmm) return 0;
  const [hStr, mStr] = hhmm.split(':');
  let hour = parseInt(hStr, 10);
  const minute = parseInt(mStr, 10);
  if (hour < 8) hour += 12; // Normalize 01:00 -> 13:00 PM for afternoon slots
  return hour * 60 + minute;
}

function formatDuration(mins) {
  const h = Math.floor(mins / 60);
  const m = mins % 60;
  if (h > 0 && m > 0) return `${h}h ${m}m`;
  if (h > 0) return `${h}h`;
  return `${m}m`;
}

function buildTimelineItems(daySlots) {
  const blocks = mergeContiguousSlots(daySlots);
  if (blocks.length === 0) return [];

  const items = [];
  blocks.forEach((block, idx) => {
    if (idx > 0) {
      const prev = blocks[idx - 1];
      const gap = timeToMinutes(block.start) - timeToMinutes(prev.end);
      if (gap >= 30) {
        items.push({
          type: 'BREAK',
          start: prev.end,
          end: block.start,
          duration: gap
        });
      }
    }
    items.push({
      type: 'CLASS',
      block
    });
  });

  return items;
}

function updateUI() {
  const filtered = filterSlots(allSlots, currentQuery);

  // Update Summary Card
  const parsed = parseQuery(currentQuery);
  if (parsed && parsed.type === 'STUDENT') {
    summaryTarget.textContent = parsed.section ? `${parsed.batch}_${parsed.section}` : `${parsed.batch} (All Sections)`;
  } else if (currentQuery.trim()) {
    summaryTarget.textContent = currentQuery.trim().toUpperCase();
  } else {
    summaryTarget.textContent = 'All Classes';
  }

  const uniqueCourses = new Set(filtered.map(s => s.course)).size;
  summaryCourses.textContent = uniqueCourses;
  summaryClasses.textContent = filtered.length;

  // Update Day Tabs Badges
  DAYS.forEach(day => {
    const daySlots = filtered.filter(s => s.day === day);
    const badgeEl = dayTabsContainer.querySelector(`[data-day="${day}"] .count-badge`);
    if (badgeEl) {
      badgeEl.textContent = daySlots.length;
    }
  });

  updateDayTabsActiveState();
  renderTimeline();
  renderCoursesGrid(filtered);
}

function updateDayTabsActiveState() {
  dayTabsContainer.querySelectorAll('.day-tab').forEach(tab => {
    if (tab.getAttribute('data-day') === selectedDay) {
      tab.classList.add('active');
    } else {
      tab.classList.remove('active');
    }
  });
}

function renderTimeline() {
  const filtered = filterSlots(allSlots, currentQuery);
  const daySlots = filtered.filter(s => s.day === selectedDay);

  const formattedDay = selectedDay.charAt(0) + selectedDay.slice(1).toLowerCase();
  currentDayTitle.textContent = `${formattedDay} Schedule`;
  dayMetaStats.textContent = `${daySlots.length} ${daySlots.length === 1 ? 'Class' : 'Classes'}`;

  timelineContainer.innerHTML = '';

  if (daySlots.length === 0) {
    emptyState.classList.remove('hidden');
    emptyStateMsg.textContent = currentQuery.trim()
      ? `No classes found for "${currentQuery}" on ${formattedDay}.`
      : `No classes scheduled on ${formattedDay}.`;
    return;
  }

  emptyState.classList.add('hidden');
  const items = buildTimelineItems(daySlots);

  items.forEach(item => {
    if (item.type === 'BREAK') {
      const breakEl = document.createElement('div');
      breakEl.className = 'break-card';
      breakEl.innerHTML = `
        <div class="break-info">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
          </svg>
          <span>Break</span>
        </div>
        <div class="break-time">${item.start} - ${item.end} (${formatDuration(item.duration)})</div>
      `;
      timelineContainer.appendChild(breakEl);
    } else {
      const b = item.block;
      const card = document.createElement('div');
      const isLab = b.isLab;
      card.className = `class-card ${isLab ? 'lab-card' : ''}`;
      
      card.innerHTML = `
        <div class="time-box">
          <div class="time-range">${b.start} - ${b.end}</div>
          <div class="slot-tag">${b.startSlot === b.endSlot ? `Slot ${b.startSlot + 1}` : `Slots ${b.startSlot + 1}-${b.endSlot + 1}`}</div>
        </div>
        <div class="class-details">
          <div class="course-row">
            <h3 class="course-code">${b.course}</h3>
            <span class="badge ${isLab ? 'lab' : 'theory'}">${isLab ? 'Lab / Practical' : 'Theory'}</span>
          </div>
          <div class="meta-row">
            <div class="meta-item">
              <svg class="meta-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
              </svg>
              <span>Sec: <strong>${b.group}</strong></span>
            </div>
            <div class="meta-item">
              <svg class="meta-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
              </svg>
              <span>Teacher: <strong>${b.teacher}</strong></span>
            </div>
            <div class="meta-item">
              <svg class="meta-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>
              </svg>
              <span>Room: <strong>${b.room}</strong></span>
            </div>
          </div>
        </div>
      `;
      timelineContainer.appendChild(card);
    }
  });
}

function renderCoursesGrid(slots) {
  coursesGrid.innerHTML = '';

  const courseMap = new Map();
  slots.forEach(s => {
    if (!courseMap.has(s.course)) {
      courseMap.set(s.course, { count: 0, teacher: s.teacher, group: s.group });
    }
    courseMap.get(s.course).count += 1;
  });

  if (courseMap.size === 0) {
    coursesGrid.innerHTML = '<p style="color: var(--text-muted); font-size: 0.9rem;">No course data available.</p>';
    return;
  }

  courseMap.forEach((info, courseCode) => {
    const card = document.createElement('div');
    card.className = 'course-card-mini';
    card.innerHTML = `
      <div class="course-mini-code">${courseCode}</div>
      <div class="course-mini-meta">
        <span>${info.count} ${info.count === 1 ? 'class' : 'classes'}/wk</span>
        <span>${info.group}</span>
      </div>
    `;
    coursesGrid.appendChild(card);
  });
}

// Start app
document.addEventListener('DOMContentLoaded', init);
