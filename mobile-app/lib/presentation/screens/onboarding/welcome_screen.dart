import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../config/colors.dart';

/// Public entry point. Live inventory appears only in the authenticated,
/// Firestore-backed marketplace; this page makes no invented activity claims.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(children: [
                    const _BrandMark(large: true),
                    const SizedBox(height: 34),
                    Text('Trade across Africa',
                        textAlign: TextAlign.center,
                        style: AfrigoTypography.soraHeading1.copyWith(
                          color: AfrigoColors.primary,
                          fontSize: constraints.maxWidth > 500 ? 46 : 38,
                        )),
                    const SizedBox(height: 10),
                    Text('Find markets. Connect with buyers. Manage trade.',
                        textAlign: TextAlign.center,
                        style: AfrigoTypography.interBody1.copyWith(
                            color: AfrigoColors.textSecondary, fontSize: 17)),
                    const SizedBox(height: 18),
                    const _TradeNetwork(),
                    const SizedBox(height: 12),
                    const Row(children: [
                      Expanded(
                          child: _Value(
                              icon: Icons.query_stats_rounded,
                              title: 'Find markets',
                              body: 'Discover new opportunities')),
                      Expanded(
                          child: _Value(
                              icon: Icons.groups_rounded,
                              title: 'Connect with buyers',
                              body: 'Build trusted partnerships')),
                      Expanded(
                          child: _Value(
                              icon: Icons.description_outlined,
                              title: 'Manage trade',
                              body: 'Simplify your end-to-end journey')),
                    ]),
                    const SizedBox(height: 18),
                    Semantics(
                        button: true,
                        label: 'Create account',
                        child: SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/register'),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Create account'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AfrigoColors.primary,
                                  textStyle: AfrigoTypography.buttonLarge
                                      .copyWith(fontSize: 18)),
                            ))),
                    const SizedBox(height: 14),
                    Semantics(
                        button: true,
                        label: 'Sign in',
                        child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Sign in'),
                            ))),
                    const SizedBox(height: 26),
                    Text('An NCDF Group platform',
                        style: AfrigoTypography.interBody2
                            .copyWith(color: AfrigoColors.textSecondary)),
                    const SizedBox(height: 10),
                    Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                            color: AppColors.secondaryGold,
                            borderRadius: BorderRadius.circular(2))),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.large = false});
  final bool large;
  @override
  Widget build(BuildContext context) {
    final size = large ? 70.0 : 46.0;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/images/Afrigolg1.png', fit: BoxFit.cover)),
      SizedBox(width: large ? 14 : 10),
      Container(
          width: 1,
          height: size * .9,
          color: AfrigoColors.primary.withOpacity(.65)),
      SizedBox(width: large ? 14 : 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AfriGoOS',
            style: AfrigoTypography.soraHeading2.copyWith(
                color: AfrigoColors.primary,
                fontSize: large ? 38 : 24,
                height: 1)),
        Text('Africa Trades Together',
            style: AfrigoTypography.interBody2Semi.copyWith(
                color: AfrigoColors.primary, fontSize: large ? 16 : 12)),
      ]),
    ]);
  }
}

class _TradeNetwork extends StatelessWidget {
  const _TradeNetwork();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 270,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned(
                left: constraints.maxWidth * .22,
                right: constraints.maxWidth * .22,
                top: 10,
                bottom: 10,
                child: Image.asset(
                  'assets/images/mp1.png',
                  fit: BoxFit.contain,
                  cacheWidth: 560,
                  cacheHeight: 560,
                  color: const Color(0xFFE7EFE4),
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
              Positioned(
                left: constraints.maxWidth * .22,
                right: constraints.maxWidth * .22,
                top: 10,
                bottom: 10,
                child: const CustomPaint(painter: _TradeRoutesPainter()),
              ),
              Positioned(
                left: constraints.maxWidth * .08,
                top: 18,
                child: const _TradePhoto(
                  asset:
                      'assets/images/photorealistic-scene-with-warehouse-logistics-operations.jpg',
                ),
              ),
              Positioned(
                right: constraints.maxWidth * .08,
                top: 18,
                child: const _TradePhoto(
                  asset:
                      'assets/images/pexels-zahrah-nandoo-2147929825-29833299.jpg',
                ),
              ),
              Positioned(
                left: constraints.maxWidth * .08,
                bottom: 68,
                child: const _TradePhoto(
                  asset: 'assets/images/construction-work-site.jpg',
                ),
              ),
              Positioned(
                right: constraints.maxWidth * .08,
                bottom: 68,
                child: const _TradePhoto(
                  asset:
                      'assets/images/building-costruction-tall-dubai-marina-skyscrapers-uae.jpg',
                ),
              ),
              const Positioned(
                left: 4,
                bottom: 8,
                child:
                    _NetworkLabel(text: 'LOCAL\nBUSINESSES\nBIGGER\nMARKETS'),
              ),
              const Positioned(
                right: 4,
                bottom: 8,
                child: _NetworkLabel(
                  text: 'PEOPLE\nPRODUCTS\nOPPORTUNITIES\nA STRONGER\nAFRICA',
                ),
              ),
            ],
          ),
        ),
      );
}

class _TradePhoto extends StatelessWidget {
  const _TradePhoto({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) => Container(
        width: 58,
        height: 58,
        padding: const EdgeInsets.all(4),
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
            child: Image.asset(asset,
                fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160)),
      );
}

class _NetworkLabel extends StatelessWidget {
  const _NetworkLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: AfrigoTypography.interBody3.copyWith(
                  color: AfrigoColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.1,
                  height: 1.45)),
          const SizedBox(height: 8),
          Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                  color: AppColors.secondaryGold,
                  borderRadius: BorderRadius.circular(2))),
        ],
      );
}

class _TradeRoutesPainter extends CustomPainter {
  const _TradeRoutesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipPath(_africaPath(size));
    final routePaint = Paint()
      ..color = AppColors.secondaryGold.withOpacity(.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final points in [
      [
        Offset(size.width * .28, size.height * .27),
        Offset(size.width * .54, size.height * .35),
        Offset(size.width * .66, size.height * .53)
      ],
      [
        Offset(size.width * .20, size.height * .43),
        Offset(size.width * .47, size.height * .50),
        Offset(size.width * .56, size.height * .76)
      ],
      [
        Offset(size.width * .30, size.height * .42),
        Offset(size.width * .40, size.height * .64),
        Offset(size.width * .49, size.height * .88)
      ],
    ]) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var index = 1; index < points.length; index++) {
        path.quadraticBezierTo((points[index - 1].dx + points[index].dx) / 2,
            points[index - 1].dy, points[index].dx, points[index].dy);
      }
      canvas.drawPath(path, routePaint);
      for (final point in points) {
        canvas.drawCircle(point, 7, Paint()..color = Colors.white);
        canvas.drawCircle(point, 5, Paint()..color = AppColors.secondaryGold);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path _africaPath(Size size) {
  const points = [
    Offset(.24, .08),
    Offset(.39, .05),
    Offset(.52, .10),
    Offset(.67, .16),
    Offset(.79, .25),
    Offset(.84, .37),
    Offset(.94, .45),
    Offset(.84, .52),
    Offset(.76, .56),
    Offset(.71, .66),
    Offset(.78, .84),
    Offset(.69, .94),
    Offset(.54, 1),
    Offset(.43, .94),
    Offset(.36, .80),
    Offset(.29, .68),
    Offset(.20, .61),
    Offset(.14, .51),
    Offset(.06, .45),
    Offset(.10, .34),
    Offset(.17, .25),
  ];
  final path = Path()
    ..moveTo(size.width * points.first.dx, size.height * points.first.dy);
  for (final point in points.skip(1)) {
    path.lineTo(size.width * point.dx, size.height * point.dy);
  }
  return path..close();
}

class _Value extends StatelessWidget {
  const _Value({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(children: [
          CircleAvatar(
              radius: 25,
              backgroundColor: AfrigoColors.primary.withOpacity(.09),
              child: Icon(icon, color: AfrigoColors.primary)),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: AfrigoTypography.interBody2Semi
                  .copyWith(color: AfrigoColors.primary)),
          const SizedBox(height: 4),
          Text(body,
              textAlign: TextAlign.center,
              style: AfrigoTypography.interBody3
                  .copyWith(color: AfrigoColors.textSecondary)),
        ]),
      );
}
