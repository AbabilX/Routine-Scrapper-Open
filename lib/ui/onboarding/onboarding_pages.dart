import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'onboarding_page.dart';

const onboardingPages = [
  OnboardingPage(
    kicker: 'Open source  ·  Privacy-focused',
    title: 'DIU-তে স্বাগতম',
    body:
        'DIU ক্লাস রুটিন — অ্যাকাউন্ট নেই, সার্ভার নেই, ইন্টারনেট লাগে না। '
        'সবকিছু ফোনেই থাকে। কোড GPL-3.0 লাইসেন্সে খোলা।',
    tint: peach,
    showFace: true,
  ),
  OnboardingPage(
    kicker: 'সার্চ',
    title: 'ব্যাচ লিখো, রুটিন পাও',
    body:
        '68_C, 71_B, বা শুধু 68 — আজকের ক্লাস, ব্রেক, আর এখন/পরের ক্লাস এক স্ক্রিনে। '
        'ল্যাব সাবসেকশনও মিলে যায়।',
    tint: sky,
    icon: Icons.search_rounded,
  ),
  OnboardingPage(
    kicker: 'রিমাইন্ডার',
    title: 'ক্লাসের আগে বেল',
    body:
        'কার্ডের ঘণ্টায় ৫ / ১০ / ১৫ / ২০ / ৩০ মিনিট আগে মনে করাও। '
        'নোটিফিকেশন লোকাল — ফোনের বাইরে যায় না।',
    tint: mint,
    icon: Icons.notifications_active_rounded,
  ),
  OnboardingPage(
    kicker: 'ডাউনলোড + প্রাইভেসি',
    title: 'নিজের সপ্তাহের PDF',
    body:
        'সার্চ করা সেকশনের যে দিনে ক্লাস আছে, শুধু সেই শিডিউল শেয়ার করো। '
        'কোনো ট্র্যাকিং নেই। Open source, privacy-focused।',
    tint: lavender,
    icon: Icons.picture_as_pdf_outlined,
  ),
];
