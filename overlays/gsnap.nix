final: prev: {
  gnomeExtensions = prev.gnomeExtensions // {
    gsnap = prev.gnomeExtensions.gsnap.overrideAttrs (oldAttrs: {
      # Patch metadata.json to include GNOME Shell 49
      postPatch = (oldAttrs.postPatch or "") + ''
        # Add GNOME Shell 49 to supported versions
        substituteInPlace metadata.json \
          --replace-fail '"shell-version": [' '"shell-version": ["49",' || \
        substituteInPlace metadata.json \
          --replace '"shell-version": [' '"shell-version": ["49",'
      '';
    });
  };
}
