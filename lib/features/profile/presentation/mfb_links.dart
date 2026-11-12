import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mfb_think_tank/features/readers_digest/application/external_link_provider.dart';

/// Where to find the people who built the app.
class MfbLink {
  const MfbLink(this.id, this.label, this.url, this.icon);

  final String id;
  final String label;
  final String url;
  final IconData icon;
}

const mfbLinks = [
  MfbLink(
    'labs',
    'MFB Labs',
    'https://labs.mfbservicesinc.com',
    Icons.science_outlined,
  ),
  MfbLink('github', 'GitHub', 'https://github.com/rudysanchez-mfb', Icons.code),
  MfbLink(
    'linkedin',
    'LinkedIn',
    'https://www.linkedin.com/in/rudy10sanchez/',
    Icons.work_outline,
  ),
];

/// "Built by MFB Services, Inc." with one row per link, opened in the browser.
class MfbLinks extends ConsumerWidget {
  const MfbLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final open = ref.watch(externalLinkProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Built by MFB Services, Inc.', style: theme.textTheme.titleSmall),
        for (final link in mfbLinks)
          ListTile(
            key: Key('mfb-link-${link.id}'),
            contentPadding: EdgeInsets.zero,
            leading: Icon(link.icon),
            title: Text(link.label),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => open(Uri.parse(link.url)),
          ),
      ],
    );
  }
}
