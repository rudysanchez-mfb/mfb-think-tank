import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mfb_think_tank/features/auth/application/auth_providers.dart';
import 'package:mfb_think_tank/features/auth/data/app_user.dart';
import 'package:mfb_think_tank/features/auth/data/auth_repository.dart';
import 'package:mfb_think_tank/features/profile/presentation/profile_screen.dart';
import 'package:mfb_think_tank/features/readers_digest/application/external_link_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.deleteAccount(password: any(named: 'password')))
        .thenAnswer((_) async {});
  });

  final opened = <Uri>[];

  Future<void> pumpProfile(WidgetTester tester, List<String> providers) async {
    final user = fakeAppUser(providerIds: providers);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          externalLinkProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
          currentUserProvider.overrideWith(
            (ref) => Stream<AppUser?>.value(user),
          ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDeleteDialog(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-account')),
      200,
    );
    await tester.tap(find.byKey(const Key('delete-account')));
    await tester.pumpAndSettle();
  }

  testWidgets('password users must confirm with their password', (
    tester,
  ) async {
    await pumpProfile(tester, [AuthProviderIds.password]);
    await openDeleteDialog(tester);

    await tester.tap(find.byKey(const Key('delete-account-confirm')));
    await tester.pump();
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('delete-account-password')),
      'secret',
    );
    await tester.tap(find.byKey(const Key('delete-account-confirm')));
    await tester.pumpAndSettle();

    verify(() => repository.deleteAccount(password: 'secret')).called(1);
  });

  testWidgets('social users confirm without a password', (tester) async {
    await pumpProfile(tester, [AuthProviderIds.google]);
    await openDeleteDialog(tester);

    expect(find.byKey(const Key('delete-account-password')), findsNothing);
    await tester.tap(find.byKey(const Key('delete-account-confirm')));
    await tester.pumpAndSettle();

    verify(() => repository.deleteAccount()).called(1);
  });

  testWidgets('cancelling the dialog deletes nothing', (tester) async {
    await pumpProfile(tester, [AuthProviderIds.google]);
    await openDeleteDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(
      () => repository.deleteAccount(password: any(named: 'password')),
    );
  });

  testWidgets('links to MFB Labs, GitHub and LinkedIn', (tester) async {
    await pumpProfile(tester, [AuthProviderIds.google]);
    expect(find.text('Built by MFB Services, Inc.'), findsOneWidget);
    for (final (key, url) in const [
      ('mfb-link-labs', 'https://labs.mfbservicesinc.com'),
      ('mfb-link-github', 'https://github.com/rudysanchez-mfb'),
      ('mfb-link-linkedin', 'https://www.linkedin.com/in/rudy10sanchez/'),
    ]) {
      await tester.scrollUntilVisible(find.byKey(Key(key)), 200);
      await tester.tap(find.byKey(Key(key)));
      expect(opened.last, Uri.parse(url));
    }
  });
}
