{ stdenv, mkDerivation, fetchFromGitHub, pkgconfig, cmake, deepin, qttools, qtdeclarative,
 networkmanager, qtsvg, qtx11extras,  dtkcore, dtkwidget, geoip, gsettings-qt,
 dde-network-utils, networkmanager-qt, xorg, mtdev, fontconfig, freetype, dde-api,
 dde-daemon, qt5integration, deepin-desktop-base, deepin-desktop-schemas, dbus,
 systemd, dde-qt-dbus-factory, qtmultimedia, qtbase, glib, gnome3, which,
 substituteAll, tzdata, wrapGAppsHook
}:

mkDerivation rec {
  name = "${pname}-${version}";
  pname = "dde-control-center";
  version = "4.10.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "1ip8wjwf0n9q8xnqymzh8lz0j5gcnns976n291np6k5kdh2wqhr5";
  };

  nativeBuildInputs = [
    cmake
    deepin.setupHook
    pkgconfig
    wrapGAppsHook
  ];

  buildInputs = [
    dde-api
    dde-daemon
    dde-network-utils
    dde-qt-dbus-factory
    deepin-desktop-base
    deepin-desktop-schemas
    dtkcore
    dtkwidget
    fontconfig
    freetype
    geoip
    glib
    gnome3.networkmanager-l2tp
    gnome3.networkmanager-openconnect
    gnome3.networkmanager-openvpn
    gnome3.networkmanager-vpnc
    gsettings-qt
    mtdev
    networkmanager-qt
    qt5integration
    qtbase
    qtdeclarative
    qtmultimedia
    qtsvg
    qttools
    qtx11extras
    xorg.libX11
    xorg.libXext
    xorg.libXrandr
    xorg.libxcb
  ];

  cmakeFlags = [
    "-DDISABLE_SYS_UPDATE=YES"
    "-DDCC_DISABLE_GRUB=YES"
  ];

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      nmcli = "${networkmanager}/bin/nmcli";
      which = "${which}/bin/which";
      # not packaged
      # dman = "${deepin-manual}/bin/dman";
      inherit tzdata;
      # exclusive to deepin linux?
      # allows to synchronize configuration files to cloud networks
      # deepin_sync = "${deepin-sync}";
    })
  ];

  postPatch = ''
    searchHardCodedPaths

    patchShebangs translate_ts2desktop.sh
    patchShebangs translate_generation.sh
    patchShebangs translate_desktop2ts.sh

    fixPath $out /usr dde-control-center-autostart.desktop \
      com.deepin.dde.ControlCenter.service \
      src/frame/widgets/utils.h

    substituteInPlace dde-control-center.desktop \
      --replace "dbus-send" "${dbus}/bin/dbus-send"
    substituteInPlace com.deepin.controlcenter.addomain.policy \
      --replace "/bin/systemctl" "${systemd}/bin/systemctl"
  '';

  postFixup = ''
    # debuging
    searchForUnresolvedDLL $out
    searchHardCodedPaths $out
  '';

  passthru.updateScript = deepin.updateScript { inherit name; };

  meta = with stdenv.lib; {
    description = "Control panel of Deepin Desktop Environment";
    homepage = https://github.com/linuxdeepin/dde-control-center;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo worldofpeace ];
  };
}
