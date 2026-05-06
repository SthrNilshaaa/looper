import 'package:dbus/dbus.dart';

class MPRISPlayer extends DBusObject {
  MPRISPlayer() : super(DBusObjectPath('/org/mpris/MediaPlayer2'));

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.mpris.MediaPlayer2', methods: [
        DBusIntrospectMethod('Raise'),
        DBusIntrospectMethod('Quit'),
      ], properties: [
        DBusIntrospectProperty('CanQuit', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanRaise', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('HasTrackList', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Identity', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('DesktopEntry', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('SupportedUriSchemes', DBusSignature('as'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('SupportedMimeTypes', DBusSignature('as'), access: DBusPropertyAccess.read),
      ]),
      DBusIntrospectInterface('org.mpris.MediaPlayer2.Player', methods: [
        DBusIntrospectMethod('Next'),
        DBusIntrospectMethod('Previous'),
        DBusIntrospectMethod('Pause'),
        DBusIntrospectMethod('PlayPause'),
        DBusIntrospectMethod('Stop'),
        DBusIntrospectMethod('Play'),
        DBusIntrospectMethod('Seek', args: [
          DBusIntrospectArgument(DBusSignature('x'), DBusArgumentDirection.in_, name: 'Offset')
        ]),
        DBusIntrospectMethod('SetPosition', args: [
          DBusIntrospectArgument(DBusSignature('o'), DBusArgumentDirection.in_, name: 'TrackId'),
          DBusIntrospectArgument(DBusSignature('x'), DBusArgumentDirection.in_, name: 'Position')
        ]),
        DBusIntrospectMethod('OpenUri', args: [
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_, name: 'Uri')
        ])
      ], properties: [
        DBusIntrospectProperty('PlaybackStatus', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('LoopStatus', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Rate', DBusSignature('d'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Shuffle', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Metadata', DBusSignature('a{sv}'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Volume', DBusSignature('d'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Position', DBusSignature('x'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('MinimumRate', DBusSignature('d'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('MaximumRate', DBusSignature('d'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanGoNext', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanGoPrevious', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanPlay', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanPause', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanSeek', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanControl', DBusSignature('b'), access: DBusPropertyAccess.read),
      ]),
    ];
  }

  void Function()? onPlay;
  void Function()? onPause;
  void Function()? onNext;
  void Function()? onPrevious;
  void Function()? onPlayPause;
  void Function(int offset)? onSeek;

  String playbackStatus = 'Stopped';
  Map<String, DBusValue> metadata = {};
  int position = 0;

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.mpris.MediaPlayer2.Player') {
      switch (methodCall.name) {
        case 'Play':
          if (onPlay != null) onPlay!();
          return DBusMethodSuccessResponse([]);
        case 'Pause':
          if (onPause != null) onPause!();
          return DBusMethodSuccessResponse([]);
        case 'PlayPause':
          if (onPlayPause != null) onPlayPause!();
          return DBusMethodSuccessResponse([]);
        case 'Next':
          if (onNext != null) onNext!();
          return DBusMethodSuccessResponse([]);
        case 'Previous':
          if (onPrevious != null) onPrevious!();
          return DBusMethodSuccessResponse([]);
        case 'Seek':
          if (onSeek != null && methodCall.values.isNotEmpty) {
            onSeek!((methodCall.values.first as DBusInt64).value);
          }
          return DBusMethodSuccessResponse([]);
        case 'SetPosition':
          if (onSeek != null && methodCall.values.length > 1) {
            onSeek!((methodCall.values[1] as DBusInt64).value);
          }
          return DBusMethodSuccessResponse([]);
      }
    }
    return DBusMethodErrorResponse.unknownMethod();
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.mpris.MediaPlayer2') {
      switch (name) {
        case 'CanQuit': return DBusMethodSuccessResponse([DBusBoolean(false)]);
        case 'CanRaise': return DBusMethodSuccessResponse([DBusBoolean(false)]);
        case 'HasTrackList': return DBusMethodSuccessResponse([DBusBoolean(false)]);
        case 'Identity': return DBusMethodSuccessResponse([DBusString('Looper Player')]);
        case 'DesktopEntry': return DBusMethodSuccessResponse([DBusString('looper_player')]);
        case 'SupportedUriSchemes': return DBusMethodSuccessResponse([DBusArray.string([])]);
        case 'SupportedMimeTypes': return DBusMethodSuccessResponse([DBusArray.string([])]);
      }
    } else if (interface == 'org.mpris.MediaPlayer2.Player') {
      switch (name) {
        case 'PlaybackStatus': return DBusMethodSuccessResponse([DBusString(playbackStatus)]);
        case 'Rate': return DBusMethodSuccessResponse([DBusDouble(1.0)]);
        case 'Metadata': return DBusMethodSuccessResponse([DBusDict.stringVariant(metadata)]);
        case 'Volume': return DBusMethodSuccessResponse([DBusDouble(1.0)]);
        case 'Position': return DBusMethodSuccessResponse([DBusInt64(position)]);
        case 'MinimumRate': return DBusMethodSuccessResponse([DBusDouble(1.0)]);
        case 'MaximumRate': return DBusMethodSuccessResponse([DBusDouble(1.0)]);
        case 'CanGoNext': return DBusMethodSuccessResponse([DBusBoolean(true)]);
        case 'CanGoPrevious': return DBusMethodSuccessResponse([DBusBoolean(true)]);
        case 'CanPlay': return DBusMethodSuccessResponse([DBusBoolean(true)]);
        case 'CanPause': return DBusMethodSuccessResponse([DBusBoolean(true)]);
        case 'CanSeek': return DBusMethodSuccessResponse([DBusBoolean(true)]);
        case 'CanControl': return DBusMethodSuccessResponse([DBusBoolean(true)]);
      }
    }
    return DBusMethodErrorResponse.unknownProperty();
  }

  Future<void> updatePlaybackStatus(String status) async {
    if (playbackStatus == status) return;
    playbackStatus = status;
    await emitPropertiesChanged('org.mpris.MediaPlayer2.Player', changedProperties: {
      'PlaybackStatus': DBusString(status),
    });
  }

  Future<void> updateMetadata(Map<String, DBusValue> newMetadata) async {
    metadata = newMetadata;
    await emitPropertiesChanged('org.mpris.MediaPlayer2.Player', changedProperties: {
      'Metadata': DBusDict.stringVariant(metadata),
    });
  }
}
