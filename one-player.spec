Name:           one-player
Version:        1.0.0
Release:        1%{?dist}
Summary:        A modern, high-fidelity music player for Linux.

License:        MIT
URL:            https://github.com/nilshaaa/one_player
Source0:        %{name}-%{version}.tar.gz

# No BuildRequires or Requires to avoid host-check failures on non-RPM systems

%description
A modern, high-fidelity music player for Linux built with Flutter and MediaKit.

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/%{name}
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/pixmaps

# Copy the build artifacts from the source
cp -r %{_sourcedir}/bundle/* %{buildroot}/usr/lib/%{name}/

# Copy Icon
cp %{_sourcedir}/icon.png %{buildroot}/usr/share/pixmaps/%{name}.png

# Create the launcher script
cat <<EOF > %{buildroot}/usr/bin/%{name}
#!/bin/bash
/usr/lib/%{name}/one_player "\$@"
EOF
chmod +x %{buildroot}/usr/bin/%{name}

# Create the desktop file
cat <<EOF > %{buildroot}/usr/share/applications/%{name}.desktop
[Desktop Entry]
Version=%{version}
Name=OnePlayer
Comment=%{summary}
Exec=%{name} %%F
Icon=%{name}
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Music;Player;
MimeType=audio/mpeg;audio/ogg;audio/x-wav;audio/flac;audio/mp4;audio/x-mp3;audio/x-m4a;
EOF

%files
%attr(0755, root, root) /usr/bin/%{name}
/usr/lib/%{name}/
/usr/share/applications/%{name}.desktop
/usr/share/pixmaps/%{name}.png

%changelog
* Thu Apr 23 2026 Nils Haaa <nilshaaa@example.com> - 1.0.0-1
- Initial release
