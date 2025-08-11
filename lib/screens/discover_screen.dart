import 'package:flutter/material.dart';
import '../shared/widgets/index.dart';
import '../app/routes.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final tags = [
    '#trending',
    '#viral',
    '#fyp',
    '#explore',
    '#music',
    '#dance',
    '#comedy',
    '#lifestyle',
    '#travel',
    '#food',
    '#art',
    '#nature',
    '#tech',
    '#sports',
    '#gaming',
    '#fashion'
  ];
  String _query = '';

  Future<void> _refresh() async {
    setState(() => tags.shuffle());
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = tags
        .where((t) => t.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 108),
          children: [
            const GlassHeader(title: 'Quantum'),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Glass(
                borderRadius: BorderRadius.circular(18),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search hashtags',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) => _trendCard(context, i),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: 6,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Trending Hashtags',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filtered
                    .map((t) => InkWell(
                          onTap: () => t == '#live'
                              ? Navigator.of(context)
                                  .pushNamed(RouteNames.liveSetup)
                              : Navigator.of(context).pushNamed(RouteNames.tag,
                                  arguments: {'tag': t}),
                          child: GradientPill(text: t),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _trendCard(BuildContext context, int i) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        RouteNames.tag,
        arguments: {'tag': '#tag$i'},
      ),
      child: Glass(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: i == 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Text('LIVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      )
                    : const SizedBox.shrink(),
              ),
              const Spacer(),
              Text(i == 0 ? 'Amazing sunset dance' : 'Cooking hack that works',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(i == 0 ? '@dance_vibes' : '@chef_pro',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(i == 0 ? '2.1M views' : '1.8M views',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
