import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content/site_content.dart';
import '../../services/launcher.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';

/// About Jyotessa — story, the safety test, beliefs, how it works, journey and contact.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _reasonIcons = [
    Icons.shield_outlined,
    Icons.autorenew_rounded,
    Icons.local_fire_department_outlined,
    Icons.science_outlined,
    Icons.favorite_border_rounded,
    Icons.card_giftcard_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Jyotessa')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Brand header
          Container(
            color: AppColors.charcoal,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                Image.asset('assets/images/logo_light.png', height: 110),
                const SizedBox(height: 12),
                Text(
                  'A candle that survives real life.',
                  textAlign: TextAlign.center,
                  style: AppText.serif(size: 22, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  Site.mission,
                  textAlign: TextAlign.center,
                  style: AppText.sans(size: 13, color: Colors.white.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
          // Proof numbers
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                for (final (value, label) in aboutProof)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          value,
                          style: AppText.sans(size: 20, weight: FontWeight.w800, color: AppColors.terracotta),
                        ),
                        Text(label, style: AppText.muted(size: 11.5)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Our story',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AspectRatio(aspectRatio: 16 / 9, child: AppImage(SiteImages.livingRoom, radius: 12)),
                const SizedBox(height: 12),
                for (final p in aboutStory)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(p, style: AppText.sans(size: 13.5, color: AppColors.ash, height: 1.6)),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Why Jyotessa',
            child: Column(
              children: [
                for (var i = 0; i < whyUs.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.sand,
                          child: Icon(_reasonIcons[i], size: 18, color: AppColors.terracotta),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(whyUs[i].title, style: AppText.sans(size: 14, weight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(whyUs[i].body, style: AppText.muted(size: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Candle care',
            child: Column(
              children: [
                for (var i = 0; i < howItWorks.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        AppImage(howItWorks[i].image, width: 64, height: 64, radius: 10),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${i + 1}. ${howItWorks[i].title}', style: AppText.sans(size: 14, weight: FontWeight.w700)),
                              Text(howItWorks[i].body, style: AppText.muted(size: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Our journey',
            child: Column(
              children: [
                for (var i = 0; i < milestones.length; i++)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                milestones[i].year,
                                style: AppText.sans(size: 12, weight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                            if (i < milestones.length - 1) Expanded(child: Container(width: 2, color: AppColors.linen)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: i < milestones.length - 1 ? 16 : 0, top: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(milestones[i].title, style: AppText.sans(size: 14, weight: FontWeight.w700)),
                                Text(milestones[i].body, style: AppText.muted(size: 12.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 8), child: ContactLinks()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ElevatedButton(onPressed: () => context.push('/shop'), child: const Text('SHOP THE CANDLES')),
          ),
        ],
      ),
    );
  }
}

/// WhatsApp, call, email, hours, studio, social — as one menu group.
class ContactLinks extends StatelessWidget {
  const ContactLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuGroup(
      title: 'Get in touch',
      children: [
        MenuTile(icon: Icons.chat_outlined, title: 'WhatsApp', subtitle: Site.whatsapp, onTap: Launcher.whatsapp, color: const Color(0xFF128C7E)),
        MenuTile(icon: Icons.call_outlined, title: 'Call us', subtitle: Site.phone, onTap: Launcher.call),
        MenuTile(icon: Icons.mail_outline_rounded, title: 'Email', subtitle: Site.supportEmail, onTap: Launcher.email),
        const MenuTile(icon: Icons.access_time_rounded, title: 'Hours', subtitle: Site.hours),
        MenuTile(icon: Icons.location_on_outlined, title: 'Our studio', subtitle: Site.address, onTap: Launcher.maps),
        MenuTile(icon: Icons.camera_alt_outlined, title: 'Instagram', subtitle: '@jyotessa', onTap: () => Launcher.open(Site.instagram)),
        MenuTile(icon: Icons.facebook_rounded, title: 'Facebook', subtitle: 'jyotessa', onTap: () => Launcher.open(Site.facebook)),
      ],
    );
  }
}
