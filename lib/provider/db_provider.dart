import 'package:shared_preferences/shared_preferences.dart';

class DbProvider {
  final Future<SharedPreferences> _passcodeAuthentication =
      SharedPreferences.getInstance();

  final Future<SharedPreferences> _shareNotes = SharedPreferences.getInstance();

  final Future<SharedPreferences> _hideCreationDate =
      SharedPreferences.getInstance();

  // for authentication setting
  void saveAuthState(bool status) async {
    final instance = await _passcodeAuthentication;

    instance.setBool("status", status);
  }

  // for authentication setting
  Future<bool> getAuthState() async {
    final instance = await _passcodeAuthentication;
    if (instance.containsKey("status")) {
      final value = instance.getBool("status");

      return value!;
    } else {
      return false;
    }
  }

  // for sharing notes
  void saveSharingNotesState(bool status) async {
    final instance = await _shareNotes;
    instance.setBool("SharingNotes", status);
  }

  // for sharing notes
  Future<bool> getSharingNotesState() async {
    final instance = await _shareNotes;
    if (instance.containsKey("SharingNotes")) {
      final value = instance.getBool("SharingNotes");
      return value!;
    } else {
      return false;
    }
  }

  // for hide the creation date
  void saveHideCreationDateStatus(bool status) async {
    final instance = await _hideCreationDate;

    instance.setBool("hideCreationDate", status);
  }

  // for hide the creation date
  Future<bool> getHideCreationDateStatus() async {
    final instance = await _hideCreationDate;
    if (instance.containsKey("hideCreationDate")) {
      final value = instance.getBool("hideCreationDate");
      return value!;
    } else {
      return false;
    }
  }
}
