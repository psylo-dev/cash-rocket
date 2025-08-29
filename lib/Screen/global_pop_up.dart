import 'package:device_safety_info/device_safety_info.dart';
import 'package:device_safety_info/vpn_check.dart';
import 'package:device_safety_info/vpn_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ErrorType {
  VPNNotAllowed,
  ROOTNotAllowed,
  EmulatorNotAllowed,
  DeveloperOptionsNotAllowed,
}

class GlobalPopUp extends StatefulWidget {
  const GlobalPopUp({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalPopUp> createState() => _GlobalPopUpState();
}

class _GlobalPopUpState extends State<GlobalPopUp> {
  ErrorType? errorType;
  final vpnCheck = VPNCheck();

  checkVpnConnection() async {
    bool isRooted = await DeviceSafetyInfo.isRootedDevice;
    bool isEmulator = await DeviceSafetyInfo.isRealDevice;
    bool isDeveloperOptionsEnabled = await DeviceSafetyInfo.isDeveloperMode;

    if (isRooted) {
      errorType = ErrorType.ROOTNotAllowed;
    } else if (!isEmulator) {
      errorType = ErrorType.EmulatorNotAllowed;
    } else if (isDeveloperOptionsEnabled) {
      errorType = ErrorType.DeveloperOptionsNotAllowed;
    } else {
      errorType = null;
    }
    setState(() {});

    vpnCheck.vpnState.listen((state) {
      if (state == VPNState.connectedState) {
        setState(() {
          errorType = ErrorType.VPNNotAllowed;
        });
      } else {
        setState(() {
          errorType = null;
        });
      }
    });
  }

  getErrorIcon(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.VPNNotAllowed:
        return Icons.vpn_lock_sharp;
      case ErrorType.ROOTNotAllowed:
        return Icons.warning_amber_outlined;
      case ErrorType.EmulatorNotAllowed:
        return Icons.android_outlined;
      case ErrorType.DeveloperOptionsNotAllowed:
        return Icons.developer_mode_outlined;
      default:
        return null;
    }
  }

  getErrorMessage(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.VPNNotAllowed:
        return "VPN not allowed. Please disable VPN to continue using the app.";
      case ErrorType.ROOTNotAllowed:
        return "Rooted devices are not allowed.";
      case ErrorType.EmulatorNotAllowed:
        return "Emulators are not allowed.";
      case ErrorType.DeveloperOptionsNotAllowed:
        return "Developer options are not allowed.";
      default:
        return null;
    }
  }

  getErrorDescription(ErrorType? errorType) {
    switch (errorType) {
      case ErrorType.VPNNotAllowed:
        return "Please disable VPN to continue using the app.";
      case ErrorType.ROOTNotAllowed:
        return "Rooted devices can compromise security.";
      case ErrorType.EmulatorNotAllowed:
        return "Emulators can lead to unexpected behavior.";
      case ErrorType.DeveloperOptionsNotAllowed:
        return "Developer options can interfere with app functionality.";
      default:
        return null;
    }
  }

  @override
  void initState() {
    if (!kDebugMode) {
      checkVpnConnection();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (errorType != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                alignment: Alignment.center,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(getErrorIcon(errorType), color: Colors.white, size: 80),
                      SizedBox(height: 24),
                      Text(
                        getErrorMessage(errorType) ?? "Error",
                        style: TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text(
                        getErrorDescription(errorType) ?? "An error occurred.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
