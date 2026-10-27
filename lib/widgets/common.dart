import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';

/// Toast at the bottom of the screen.
void showToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : AppColors.charcoal,
        duration: const Duration(seconds: 5),
        persist: false,
      ),
    );
}

/// "Bestsellers ……… View all >" row above a rail or grid.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.action = 'View all', this.onAction, this.padding = const EdgeInsets.fromLTRB(16, 22, 8, 10)});
  final String title;
  final String? subtitle;
  final String action;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title()),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: AppText.muted(size: 12.5)),
                  ),
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Text(action), const Icon(Icons.chevron_right_rounded, size: 18)]),
            ),
        ],
      ),
    );
  }
}

/// White surface used for app sections and cards.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.radius = AppTheme.radius,
    this.borderColor,
    this.onTap,
    this.margin,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final Color? borderColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}

/// Full-width white block with a title, used to group content on detail screens.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, this.trailing, required this.child, this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16)});
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: Text(title!, style: AppText.title(size: 15.5))),
                  ?trailing,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// Green "4.8 ★" badge like shopping apps, with the review count.
class RatingBadge extends StatelessWidget {
  const RatingBadge(this.rating, {super.key, this.count, this.small = false});
  final double rating;
  final int? count;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 11.0 : 12.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: small ? 5 : 7, vertical: small ? 1.5 : 3),
          decoration: BoxDecoration(color: const Color(0xFF168A4C), borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: AppText.sans(size: size, weight: FontWeight.w700, color: Colors.white, height: 1.2),
              ),
              const SizedBox(width: 2),
              Icon(Icons.star_rounded, size: size + 1, color: Colors.white),
            ],
          ),
        ),
        if (count != null) ...[const SizedBox(width: 5), Text('($count)', style: AppText.muted(size: size - 0.5))],
      ],
    );
  }
}

/// 5-star rating (supports halves).
class RatingStars extends StatelessWidget {
  const RatingStars(this.rating, {super.key, this.size = 14, this.color = AppColors.gold});
  final double rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(rating >= i ? Icons.star_rounded : (rating >= i - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded), size: size, color: color),
      ],
    );
  }
}

/// ₹899  ₹1,099  18% off
class PriceText extends StatelessWidget {
  const PriceText({super.key, required this.price, this.compareAt, this.size = 15});
  final int price;
  final int? compareAt;
  final double size;

  @override
  Widget build(BuildContext context) {
    final off = discountPercent(price, compareAt);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          formatPrice(price),
          style: AppText.sans(size: size, weight: FontWeight.w800),
        ),
        if (off > 0)
          Text(
            formatPrice(compareAt!),
            style: AppText.muted(size: size * 0.78).copyWith(decoration: TextDecoration.lineThrough),
          ),
        if (off > 0)
          Text(
            '$off% off',
            style: AppText.sans(size: size * 0.8, weight: FontWeight.w700, color: const Color(0xFF168A4C)),
          ),
      ],
    );
  }
}

/// Icon + message + optional button, for empty lists and errors.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.actionLabel, this.onAction});
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(color: AppColors.sand, shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: AppColors.terracotta),
            ),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: AppText.title(size: 18)),
            if (message != null) ...[const SizedBox(height: 6), Text(message!, textAlign: TextAlign.center, style: AppText.muted(size: 14))],
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: 220,
                child: ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error with a retry button (network failures).
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      EmptyState(icon: Icons.wifi_off_rounded, title: 'Couldn’t load', message: message, actionLabel: 'Try again', onAction: onRetry);
}

/// Small rounded label (badges, perks).
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = AppColors.charcoal, this.textColor = AppColors.cream, this.size = 10.5});
  final String text;
  final Color color;
  final Color textColor;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
    child: Text(
      text,
      style: AppText.sans(size: size, weight: FontWeight.w700, color: textColor, height: 1.1),
    ),
  );
}

/// − 2 + quantity control.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.max = 20, this.compact = false});
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 42.0;
    Widget btn(IconData icon, int next, bool enabled) => SizedBox(
      width: size,
      height: size,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: compact ? 16 : 18,
        onPressed: enabled ? () => onChanged(next) : null,
        icon: Icon(icon, color: enabled ? AppColors.terracotta : AppColors.mist),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.linen),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, value - 1, value > min),
          SizedBox(
            width: compact ? 22 : 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppText.sans(weight: FontWeight.w700, size: compact ? 14 : 16),
            ),
          ),
          btn(Icons.add_rounded, value + 1, value < max),
        ],
      ),
    );
  }
}

/// Brand mark + JYOTESSA wordmark.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 34, this.light = false});
  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(light ? 'assets/images/logo_mark_light.png' : 'assets/images/logo_mark.png', height: size),
        const SizedBox(width: 6),
        Text(
          'JYOTESSA',
          style: AppText.brand(size: size * 0.5, color: light ? AppColors.caramel : AppColors.terracotta),
        ),
      ],
    );
  }
}

/// Label/value row for price details.
class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.accent = false, this.bold = false});
  final String label;
  final String value;
  final bool accent;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: bold ? AppText.sans(weight: FontWeight.w700, size: 15) : AppText.sans(size: 14, color: AppColors.ash),
          ),
        ),
        Text(
          value,
          style: AppText.sans(
            size: bold ? 16 : 14,
            weight: bold || accent ? FontWeight.w700 : FontWeight.w500,
            color: accent ? const Color(0xFF168A4C) : AppColors.charcoal,
          ),
        ),
      ],
    ),
  );
}

/// Bar fixed at the bottom of a screen (Add to bag, Place order…).
class StickyBar extends StatelessWidget {
  const StickyBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2))],
    ),
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: SafeArea(top: false, child: child),
  );
}

/// One row in a settings-style list.
class MenuTile extends StatelessWidget {
  const MenuTile({super.key, required this.icon, required this.title, this.subtitle, this.onTap, this.trailing, this.color});
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.terracotta),
    title: Text(
      title,
      style: AppText.sans(size: 15, weight: FontWeight.w500, color: color ?? AppColors.charcoal),
    ),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right_rounded, color: AppColors.mist)),
    onTap: onTap,
  );
}

/// White group of menu tiles with dividers and an optional header.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(title!.toUpperCase(), style: AppText.eyebrow(color: AppColors.ash)),
        ),
      Container(
        color: Colors.white,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(indent: 56), children[i]],
          ],
        ),
      ),
    ],
  );
}

/// Bottom-sheet title row.
class SheetHeader extends StatelessWidget {
  const SheetHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
    child: Row(
      children: [
        Expanded(child: Text(title, style: AppText.title(size: 18))),
        ?trailing,
      ],
    ),
  );
}

/// Small white button with a spinner while busy.
class BusyLabel extends StatelessWidget {
  const BusyLabel({super.key, required this.busy, required this.label, this.color = Colors.white});
  final bool busy;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => busy ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: color)) : Text(label);
}
