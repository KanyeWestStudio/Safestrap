import 'package:flutter_test/flutter_test.dart';
import 'package:safestrap/models/launch_profile.dart';
import 'package:safestrap/services/launcher_service.dart';

void main() {
  const profile = LaunchProfile(
    placeId: 1818,
    privateServerCode: 'abc-123',
  );

  test('desktop deep link carries place and private server', () {
    expect(
      LauncherService.desktopDeepLink(profile),
      'roblox-player:1+launchmode:play+placeId:1818+linkCode:abc-123',
    );
    expect(
      LauncherService.desktopDeepLink(const LaunchProfile()),
      'roblox-player:1',
    );
  });

  test('mobile deep link carries place and private server', () {
    expect(
      LauncherService.mobileDeepLink(profile),
      'roblox://placeId=1818&linkCode=abc-123',
    );
    expect(LauncherService.mobileDeepLink(const LaunchProfile()), 'roblox://');
  });

  test('install page is not the iOS store on desktop', () {
    expect(LauncherService.installPageUrl(), isNot(contains('apps.apple.com')));
  });
}
