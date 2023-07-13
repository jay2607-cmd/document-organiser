import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticateWithBioMetrics extends StatefulWidget {
  const AuthenticateWithBioMetrics({super.key});

  @override
  State<AuthenticateWithBioMetrics> createState() =>
      _AuthenticateWithBioMetricsState();
}

class _AuthenticateWithBioMetricsState
    extends State<AuthenticateWithBioMetrics> {
  bool? _hasBioSensor;

  LocalAuthentication localAuthentication = LocalAuthentication();



  Future<void> checkBio() async {
    try {
      _hasBioSensor = await localAuthentication.canCheckBiometrics;

      print(_hasBioSensor);

    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    checkBio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
