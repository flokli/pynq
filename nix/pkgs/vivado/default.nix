{ stdenv
, pkgs
, requireFile
, makeWrapper
, bash
, autoPatchelfHook
, breakpointHook
, strace
, alsaLib
, boost166
, gdk-pixbuf
, gtk3
, gtk2
, glib
, pango
, ncurses5
, zlib
, xorg
, libX11
, libXext
, libXi
, libXtst
, libxml2
, libxslt
, patchelf
, symlinkJoin
}:

# This was a lot of work. If you find this useful, please consider sending
# @flokli coffee :-)

let
  pname = "vivado";
  version = "2019.2";

  src = requireFile {
    name = "Xilinx_Vivado_${version}_1106_2127.tar.gz";
    url = "https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Vivado_2019.2_1106_2127.tar.gz";
    sha256 = "15hfkb51axczqmkjfmknwwmn8v36ss39wdaay14ajnwlnb7q2rxh";
  };

  # custom JRE, installation with a newer JRE fails due to
  # javax.xml.bind.JAXBException Implementation of JAXB-API has not been found
  # on module path or classpath
  vivadoJre = stdenv.mkDerivation {
    pname = "vivado-jre";
    version = "9.0.4";

    inherit src;
    buildInputs = [
      alsaLib.out
      boost166
      gdk-pixbuf
      glib.out
      gtk2
      gtk3
      libX11
      libXext
      libXi
      libXtst
      libxml2
      libxslt
      pango
      stdenv.cc.cc.lib
      zlib
    ];
    nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

    installPhase = ''
      # copy JRE
      mkdir -p $out
      cp -R tps/lnx64/jre9.0.4/* $out
      rm $out/lib/libav* # seriously, pre-ffmpeg_2…

      # copy and cleanup libraries needed to run the installer
      cp -R lib/lnx64.o/*.so lib/lnx64/Default/*.so $out/lib
      # libboost_iostreams.so has a NEEDED librdizlib.so, which seems to be vivado-specific
      # let's pretend we never saw any of that, and let autoPatchelfHook replace it with a regular boost
      rm $out/lib/libboost*

      # we still need to set LD_LIBRARY_PATH, as otherwise some dlopen() still fails
      wrapProgram $out/bin/java --prefix LD_LIBRARY_PATH : $out/lib
    '';
  };

  vivado-unwrapped = stdenv.mkDerivation {
    pname = "vivado-unwrapped";
    inherit src version;

    buildInputs = [
      bash
    ];

    nativeBuildInputs = [ makeWrapper patchelf ];

    doConfigure = false;
    doBuild = false;

    installPhase = ''
      mkdir -p $out/opt/vivado
      ${stdenv.lib.getBin vivadoJre}/bin/java \
        --add-modules java.se.ee --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.desktop/sun.swing=ALL-UNNAMED --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.desktop/javax.swing.tree=ALL-UNNAMED --add-opens=java.desktop/sun.awt.X11=ALL-UNNAMED \
        -Dsun.java2d.d3d=false \
        -Duser.dir=$PWD \
        -DLOAD_64_NATIVE=true \
        -DDYNAMIC_LANGUAGE_BUNDLE=$PWD/data \
        -DIDATA_LOCATION_FROM_USER=$PWD/data/idata.dat \
        -Dlog4j.configuration=$PWD/data/log4j.xml \
        -DHAS_DYNAMIC_LANGUAGE_BUNDLE=true \
        -DOS_ARCH=64 \
        -cp $PWD"/lib/classes/*" \
        com.xilinx.installer.api.InstallerLauncher \
        --batch install \
        --edition "Vivado HL System Edition" \
        --location $out/opt/vivado \
        --agree XilinxEULA,3rdPartyEULA,WebTalkTerms

      patchShebangs $out/opt/vivado

      # remove .xinstall, it contains two JREs, vivadoLibs and isn't used at all
      rm -R $out/opt/vivado/.xinstall

      # fix interpreter paths
      for exe in $(find $out/opt/vivado/Vivado/${version}/bin/unwrapped/lnx64.o $out/opt/vivado/xic/tps/lnx64/jre9.0.4/bin -executable -type f); do
        isELF "$exe" || continue
        if [[ "$(basename $exe)" == "rlwrap" ]]; then continue; fi
        echo "patching $exe..."
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$exe"
      done

      # provide some libraries, that are required at runtime, but not shipped in their library bundle

      # provide libtinfo.so.5 and libX11.so.6 are only shipped in the SuSE bundle
      ln -s ${ncurses5.out}/lib/libtinfo.so.5 $out/opt/vivado/Vivado/${version}/lib/lnx64.o/
      ln -s ${xorg.libX11.out}/lib/libX11.so.6 $out/opt/vivado/Vivado/${version}/lib/lnx64.o/

      # libzip.so needs libz.so.1, which is missing
      ln -s ${zlib.out}/lib/libz.so.1 $out/opt/vivado/Vivado/${version}/lib/lnx64.o/

      # these are also required
      ln -s ${xorg.libXext.out}/lib/libXext.so.6 $out/opt/vivado/Vivado/${version}/lib/lnx64.o/
      ln -s ${xorg.libXrender.out}/lib/libXrender.so.1 $out/opt/vivado/Vivado/${version}/lib/lnx64.o/
      ln -s ${xorg.libXi.out}/lib/libXi.so.6 $out/opt/vivado/Vivado/${version}/lib/lnx64.o/
      ln -s ${xorg.libXtst.out}/lib/libXtst.so.6 $out/opt/vivado/Vivado/${version}/lib/lnx64.o/
    '';
  };

  in symlinkJoin {
    name = "vivado-${version}";

    nativeBuildInputs = [ makeWrapper ];

    paths = [ vivado-unwrapped ];

    postBuild = ''
      # make some binaries available in $out/bin
      mkdir -p $out/bin
      for exe in bootgen bootgen_utility vivado vivado_hls xsim; do
        makeWrapper $out/opt/vivado/Vivado/${version}/bin/$exe $out/bin/$exe
      done
    '';
  }
