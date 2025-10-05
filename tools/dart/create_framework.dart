import 'dart:io';

import 'util.dart';

Future<void> createFramework({
  required String frameworkName,
  required String pathToDylib,
  required String targetDirFrameworks,
}) async {
  // Create the framework directory
  final frameworkDir = Directory(
    "$targetDirFrameworks"
    "${Platform.pathSeparator}$frameworkName.framework",
  );
  await frameworkDir.create(recursive: true);

  // Create Versions/A structure
  final versionsDir = Directory("${frameworkDir.path}${Platform.pathSeparator}Versions${Platform.pathSeparator}A");
  await versionsDir.create(recursive: true);
  
  final resourcesDir = Directory("${versionsDir.path}${Platform.pathSeparator}Resources");
  await resourcesDir.create(recursive: true);
  
  final macosDir = Directory("${versionsDir.path}${Platform.pathSeparator}MacOS");
  await macosDir.create(recursive: true);

  // Change directory to the framework directory and run commands
  final temp = Directory.current;
  Directory.current = frameworkDir;
  
  // Create the binary in Versions/A/MacOS
  await runAsync(
    "lipo",
    [
      "-create",
      pathToDylib,
      "-output",
      "${versionsDir.path}${Platform.pathSeparator}MacOS${Platform.pathSeparator}$frameworkName",
    ],
  );
  
  await runAsync("install_name_tool", [
    "-id",
    "@rpath"
        "${Platform.pathSeparator}$frameworkName.framework"
        "${Platform.pathSeparator}$frameworkName",
    "${versionsDir.path}${Platform.pathSeparator}MacOS${Platform.pathSeparator}$frameworkName",
  ]);
  
  // Create symlinks
  await runAsync("ln", ["-sf", "A", "Versions${Platform.pathSeparator}Current"]);
  await runAsync("ln", ["-sf", "Versions${Platform.pathSeparator}Current${Platform.pathSeparator}Resources", "Resources"]);
  await runAsync("ln", ["-sf", "Versions${Platform.pathSeparator}Current${Platform.pathSeparator}MacOS", "MacOS"]);
  
  // Create hybrid structure for compatibility:
  // Copy binary to root for linker compatibility
  await runAsync("cp", [
    "${versionsDir.path}${Platform.pathSeparator}MacOS${Platform.pathSeparator}$frameworkName",
    "${frameworkDir.path}${Platform.pathSeparator}$frameworkName"
  ]);
  
  // Copy Info.plist to root for linker compatibility
  await runAsync("cp", [
    "${resourcesDir.path}${Platform.pathSeparator}Info.plist",
    "${frameworkDir.path}${Platform.pathSeparator}Info.plist"
  ]);
  
  Directory.current = temp;

  // Create Info.plist file in Versions/A/Resources
  final plistFile = File(
    "${resourcesDir.path}${Platform.pathSeparator}Info.plist",
  );
  await plistFile.writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$frameworkName</string>
    <key>CFBundleIdentifier</key>
    <string>com.cypherstack.$frameworkName</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$frameworkName</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
</dict>
</plist>
''');

  l("Framework $frameworkName created successfully in ${frameworkDir.path}");
}
