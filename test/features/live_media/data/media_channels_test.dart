import 'package:flutter_test/flutter_test.dart';
import 'package:mfb_think_tank/features/live_media/data/media_channels.dart';

void main() {
  test('channel ids are unique', () {
    final ids = mediaChannels.map((channel) => channel.id).toSet();
    expect(ids, hasLength(mediaChannels.length));
  });

  test('channels play over https and declare an ISO 639-1 language', () {
    for (final channel in mediaChannels) {
      expect(channel.hls, startsWith('https://'), reason: channel.id);
      expect(channel.hls, contains('.m3u8'), reason: channel.id);
      expect(
        channel.language,
        matches(RegExp(r'^[a-z]{2}$')),
        reason: channel.id,
      );
    }
  });

  test('mediaChannelFor falls back to the first channel', () {
    expect(mediaChannelFor('dw').id, 'dw');
    expect(mediaChannelFor('missing').id, mediaChannels.first.id);
    expect(mediaChannelFor(null).id, mediaChannels.first.id);
  });
}
