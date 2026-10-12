import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WhatsAppFloatingButton extends StatelessWidget {
  const WhatsAppFloatingButton({super.key});

  Future<void> _openWhatsApp(BuildContext context) async {
    final whatsappUri = Uri.https('wa.me', '/${AppConfig.WHATSAPP_NUMBER}');

    try {
      final opened = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('WhatsApp is not available on this device.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Unable to open WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Positioned(
      right: 16,
      bottom: 104 + bottomInset,
      child: Semantics(
        button: true,
        label: 'Contact Shgarde on WhatsApp',
        child: Tooltip(
          message: 'WhatsApp',
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _openWhatsApp(context),
              customBorder: const CircleBorder(),
              child: Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xff25D366),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
