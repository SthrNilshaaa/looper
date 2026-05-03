import 'package:dbus/dbus.dart';

void main() async {
  print(DBusObjectPath('/org/mpris/MediaPlayer2/TrackList/NoTrack').value);
}
