# User packages beyond DE - includes streaming + gaming
{ pkgs, home, ... }: {
  imports = [ ];

  home.packages = with pkgs; [
    # Core utils
    fd
    ripgrep

    # Development
    ormolu

    # --- Streaming & Gaming ---

    # OBS Studio for Twitch streaming
    obs-studio
    obs-studio-plugins.obs-vkcapture  # Vulkan/OpenGL capture
    obs-studio-plugins.wlrobs         # Wayland capture

    # Quick stream/recording tools
    gpu-screen-recorder               # NVENC screen recording
    slurp                             # Region selector for screenshots/recording
    wf-recorder                       # Wayland screen recorder

    # Steam and gaming tools
    mangohud                          # FPS overlay and performance metrics
    protonup-qt                       # Proton GE installer

    # Performance monitoring for overlays
    lm_sensors
    psensor
  ];
}
