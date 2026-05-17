class AppIcons {
  // Base Path
  static const String _base = 'assets/android_icons/';

  // Tab Icons
  static const String home = '${_base}home_tab_icon.svg';
  static const String songs = '${_base}songs_tab_icon.svg';
  static const String library = '${_base}library_tab_icon.svg';
  static const String search = '${_base}search_icon.svg';
  static const String settings = '${_base}settings_icon.svg';

  // Playback Controls
  static const String play = '${_base}play_icon.svg';
  static const String pause = '${_base}pause_icon.svg';
  static const String next = '${_base}next_button_icon.svg';
  static const String prev = '${_base}previous_button_icon.svg'; // Using left_arrow for prev
  static const String shuffle = '${_base}shuffle_button_icon.svg';
  static const String repeat = '${_base}repeat_mode_icon.svg';
  static const String queue = '${_base}queue_icon.svg';
  static const String lyrics = '${_base}lyrics_button_icon.svg';

  // Common Actions
  static const String heart = '${_base}liked_icon.svg';
  static const String more = '${_base}menu_button_icon.svg'; // more/menu
  static const String back = '${_base}left_arrow_icon.svg';
  static const String close = '${_base}down_arrow_icon.svg';
  static const String backVector = '${_base}Vector (7).svg';
  
  // Icon Sizes (Raw values, will be scaled using .s extension in UI)
  static const double sizeTiny = 14.0;
  static const double sizeSmall = 18.0;
  static const double sizeMedium = 24.0;
  static const double sizeLarge = 28.0;
  static const double sizeExtraLarge = 32.0;
  static const double sizeHuge = 48.0;

  // Specific UI component sizes
  static const double navbarIcon = 20.0;
  static const double miniPlayerIcon = 20.0;
  static const double expandedPlayerMainControl = 20.0;
  static const double expandedPlayerSecondaryControl = 18.0;
  static const double sidebarIcon = 17.0;
  static const double headerIcon = 12.0;
}
