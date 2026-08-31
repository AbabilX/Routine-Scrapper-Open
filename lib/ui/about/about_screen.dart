import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/cute_face.dart';
import '../components/cute_face_kind.dart';
import '../components/cute_header.dart';
import '../components/cute_page.dart';
import '../components/cute_primary_button.dart';
import '../components/empty_hint.dart';
import '../theme/app_colors.dart';

/// Calm About page — Student-style hints, one soft GitHub CTA.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static final Uri repoUri = Uri.parse(
    'https://github.com/AbabilX/Routine-Scrapper-Open',
  );

  Future<void> _openRepo(BuildContext context) async {
    HapticFeedback.selectionClick();
    final ok = await launchUrl(
      repoUri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      await Clipboard.setData(ClipboardData(text: repoUri.toString()));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('লিংক কপি হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return CutePage(
      children: [
        const CuteHeader(
          title: 'আমাদের কথা',
          subtitle: 'খোলা · নিরাপদ · ফ্রি',
          faceKind: CuteFaceKind.chick,
        ),
        const SizedBox(height: 18),
        const EmptyHint(
          title: 'কেন এই অ্যাপ?',
          body:
              'ক্লাস খুঁজতে জটিল সাইট ঘোরার দরকার নেই। পুরোপুরি ওপেন সোর্স — তোমার ডেটা চাই না, রাখি না, বিক্রি করি না।',
          tint: peach,
        ),
        const SizedBox(height: 14),
        const EmptyHint(
          title: 'প্রাইভেসি ফার্স্ট',
          body:
              'অ্যাকাউন্ট নেই, ট্র্যাকিং নেই। সার্চ আর রিমাইন্ডার শুধু এই ফোনে থাকে।',
          tint: sky,
        ),
        const SizedBox(height: 14),
        const EmptyHint(
          title: 'অফলাইন-ফ্রেন্ডলি',
          body: 'একবার লোড হলে ক্যাশ থেকে চলে — দ্রুত, হালকা, বিজ্ঞাপনহীন।',
          tint: mint,
        ),
        const SizedBox(height: 22),
        Text('সোর্স কোড', style: text.titleMedium),
        const SizedBox(height: 6),
        Text(
          'AbabilX / Routine-Scrapper-Open',
          style: text.bodyMedium,
        ),
        const SizedBox(height: 14),
        CutePrimaryButton(
          label: 'GitHub-এ খোলো',
          icon: Icons.open_in_new_rounded,
          onTap: () => _openRepo(context),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CuteFace(size: 36, kind: CuteFaceKind.bunny, animate: false),
            const SizedBox(width: 10),
            Text('DIU Routine · v0.1.0', style: text.labelSmall),
          ],
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
