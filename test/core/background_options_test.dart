import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/core/theme/background_options.dart';

void main() {
  group('background options', () {
    test('none is the default and has no asset', () {
      expect(kNoneBackground.asset, isNull);
      expect(kNoneBackground.isImage, isFalse);
      expect(kNoneBackground.isCustom, isFalse);
      expect(backgroundOptionById(null).id, 'none');
      expect(backgroundOptionById('does-not-exist').id, 'none');
    });

    test('resolves a known id to its image option', () {
      final ravens = backgroundOptionById('ravens');
      expect(ravens.id, 'ravens');
      expect(ravens.isImage, isTrue);
      expect(ravens.isCustom, isFalse);
    });

    test('a custom photo option reports as a custom image', () {
      const custom = BackgroundOption(
          id: kCustomBackgroundId, label: 'Your photo', filePath: '/tmp/x.jpg');
      expect(custom.isImage, isTrue);
      expect(custom.isCustom, isTrue);
      expect(custom.asset, isNull);
    });

    test('every catalog option is well-formed with a unique id', () {
      final ids = <String>{};
      for (final o in kBackgroundOptions) {
        expect(ids.add(o.id), isTrue, reason: 'duplicate id ${o.id}');
        expect(o.label, isNotEmpty);
        expect(o.scrim, inInclusiveRange(0.0, 1.0));
        expect(o.isCustom, isFalse);
        if (o.isImage) {
          expect(o.asset, startsWith('assets/backgrounds/'));
          expect(o.scrim, greaterThan(0.0),
              reason: '${o.id} needs a scrim to keep text legible');
        }
      }
    });

    test('the bright Ravens image gets a heavier scrim than dark ones', () {
      expect(backgroundOptionById('ravens').scrim,
          greaterThan(backgroundOptionById('spotlight').scrim));
    });
  });

  group('scrimFromLuminance', () {
    test('grows with brightness within a safe band', () {
      expect(scrimFromLuminance(0.0), 0.30);
      expect(scrimFromLuminance(1.0), lessThanOrEqualTo(0.70));
      expect(
          scrimFromLuminance(1.0), greaterThan(scrimFromLuminance(0.0)));
      expect(
          scrimFromLuminance(0.5), greaterThan(scrimFromLuminance(0.1)));
    });

    test('clamps out-of-range input', () {
      expect(scrimFromLuminance(-1), 0.30);
      expect(scrimFromLuminance(2), lessThanOrEqualTo(0.70));
    });
  });
}
