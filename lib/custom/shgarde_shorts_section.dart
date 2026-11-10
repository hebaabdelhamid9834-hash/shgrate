import 'package:active_ecommerce_cms_demo_app/data_model/offer_short.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/offers_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/common_webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShgardeShortsSection extends StatefulWidget {
  const ShgardeShortsSection({super.key});

  @override
  State<ShgardeShortsSection> createState() => _ShgardeShortsSectionState();
}

class _ShgardeShortsSectionState extends State<ShgardeShortsSection> {
  late Future<List<OfferShort>> _shortsFuture;

  @override
  void initState() {
    super.initState();
    _shortsFuture = _loadShorts();
  }

  Future<List<OfferShort>> _loadShorts() async {
    try {
      return await OffersRepository().getShorts();
    } catch (_) {
      // The website is the fallback source while the mobile endpoint is empty
      // or temporarily unavailable.
      return const [];
    }
  }

  void _openShorts() {
    if (!mounted) return;
    context.push('/shorts');
  }

  void _openShort(OfferShort short) {
    final url = short.videoUrl ?? short.webUrl;
    if (url == null) {
      _openShorts();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommonWebviewScreen(
          url: url,
          page_name: 'Shgarde Shorts',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = app_language_rtl.$ ?? true;
    final title = isRtl ? 'شورتس وعروض الفيديو' : 'Shorts & video offers';
    final seeAll = isRtl ? 'عرض الكل' : 'View all';

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openShorts,
                  child: Text(seeAll),
                ),
              ],
            ),
          ),
          FutureBuilder<List<OfferShort>>(
            future: _shortsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _ShortsLoadingCard();
              }

              final shorts = snapshot.data ?? const <OfferShort>[];
              if (shorts.isEmpty) {
                return _EmptyShortsCard(onTap: _openShorts, isRtl: isRtl);
              }

              return SizedBox(
                height: 205,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  reverse: isRtl,
                  itemCount: shorts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _ShortCard(
                    short: shorts[index],
                    onTap: () => _openShort(shorts[index]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShortCard extends StatelessWidget {
  const _ShortCard({required this.short, required this.onTap});

  final OfferShort short;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 145,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ShortImage(url: short.thumbnailUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    short.title?.isNotEmpty == true ? short.title! : 'Shgarde',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortImage extends StatelessWidget {
  const _ShortImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) return const _ShortPlaceholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ShortPlaceholder(),
      loadingBuilder: (context, child, progress) => progress == null ? child : const _ShortPlaceholder(),
    );
  }
}

class _ShortPlaceholder extends StatelessWidget {
  const _ShortPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(11, 121, 191, .12),
      child: const Center(
        child: Icon(
          Icons.local_offer_outlined,
          color: MyTheme.accent_color,
          size: 42,
        ),
      ),
    );
  }
}

class _EmptyShortsCard extends StatelessWidget {
  const _EmptyShortsCard({required this.onTap, required this.isRtl});

  final VoidCallback onTap;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 150,
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xff0b79bf), Color(0xff075183)],
            ),
          ),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl ? 'شاهد عروض شقردي بالفيديو' : 'Watch Shgarde video offers',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRtl ? 'اضغط للمشاهدة' : 'Tap to watch',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortsLoadingCard extends StatelessWidget {
  const _ShortsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: MyTheme.light_grey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
