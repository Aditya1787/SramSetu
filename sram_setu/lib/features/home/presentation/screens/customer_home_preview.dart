import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neu_button.dart';
import '../../../../core/widgets/neu_container.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class CustomerHomePreview extends ConsumerWidget {
  const CustomerHomePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final customerName = authState.user?.fullName ?? 'Valued Customer';
    final customerEmail = authState.user?.email ?? '';

    final services = [
      {'title': 'Electrician', 'subtitle': 'Wiring, Fan, MCB', 'icon': Icons.bolt_rounded, 'color': AppColors.primary},
      {'title': 'Plumber', 'subtitle': 'Pipe leakage, Tap, Motor', 'icon': Icons.water_drop_rounded, 'color': AppColors.primary},
      {'title': 'Carpenter', 'subtitle': 'Furniture, Door, Lock', 'icon': Icons.handyman_rounded, 'color': AppColors.primary},
      {'title': 'AC & Appliance', 'subtitle': 'Gas refill, Cooling repair', 'icon': Icons.ac_unit_rounded, 'color': AppColors.primary},
      {'title': 'RO Technician', 'subtitle': 'Filter change, Membrane', 'icon': Icons.filter_alt_rounded, 'color': AppColors.primary},
      {'title': 'Painter', 'subtitle': 'Wall putty, Touchup paint', 'icon': Icons.format_paint_rounded, 'color': AppColors.primary},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar / Top Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          NeuContainer(
                            width: 44,
                            height: 44,
                            borderRadius: 14,
                            depthType: NeuDepthType.convex,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                            child: const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SRAM SETU',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Verified Customer Account',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      NeuContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 14,
                        depthType: NeuDepthType.convex,
                        onTap: () {
                          ref.read(authControllerProvider.notifier).signOut();
                        },
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Welcome Card with Neumorphic Relief
                  NeuContainer(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 22,
                    depthType: NeuDepthType.convex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Namaste, $customerName 👋',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary, width: 0.8),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          customerEmail,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Quotation-First Guarantee: Transparent pricing with 0 unexpected charges.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Emergency Quick-Dispatch 1-Tap Card
                  NeuContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 22,
                    depthType: NeuDepthType.accent,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: AppColors.textPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Dispatch',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Short circuit, pipe burst, gas leak? Priority technician dispatch under 15 mins.',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Service Categories Section Header
                  const Text(
                    'Book Home Service',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select a category to inspect upfront labor & material estimates',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Service Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return NeuContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 18,
                        depthType: NeuDepthType.convex,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceLight,
                              content: Text(
                                'Selected ${s['title']}. Phase 3 catalog integration coming up next!',
                                style: const TextStyle(color: AppColors.textPrimary),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NeuContainer(
                              width: 44,
                              height: 44,
                              borderRadius: 14,
                              depthType: NeuDepthType.sunken,
                              child: Icon(
                                s['icon'] as IconData,
                                color: s['color'] as Color,
                                size: 24,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['title'] as String,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s['subtitle'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Sign Out Button
                  NeuButton(
                    text: 'Sign Out of Customer Account',
                    variant: NeuButtonVariant.secondary,
                    icon: const Icon(Icons.logout, color: AppColors.textPrimary, size: 18),
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).signOut();
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
