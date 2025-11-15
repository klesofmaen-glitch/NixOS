{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader - GRUB
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";  
      efiSupport = true;
    
      useOSProber = true; 
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  # Ядро и драйверы NVIDIA
  boot = {
    # Используем последнее LTS ядро для лучшей совместимости
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Параметры ядра для NVIDIA
    kernelParams = [ 
      "nvidia-drm.modeset=1"
      "quiet"
    ];
    
    # Модули ядра
    kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    
    # Blacklist nouveau
    blacklistedKernelModules = [ "nouveau" ];
  };

  # Драйверы NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware = {
    # Конфигурация NVIDIA
    nvidia = {
      # Используем проприетарные драйверы
      open = false;
      
      # Включение Wayland поддержки
      modesetting.enable = true;
      
      # Включение поддержки NVENC кодировщика
      nvidiaSettings = true;
      
      # Пакет драйверов (последняя стабильная версия)
      package = config.boot.kernelPackages.nvidiaPackages.stable;
     };
 };        


  # Сетевые настройки
  networking = {
    hostName = "nixos-gaming";
    networkmanager.enable = true;  # Простой менеджер сетей
  };

  # Локализация и время
  time.timeZone = "Europe/Moscow";  # Укажите вашу временную зону
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Пользователи
  users.users.resets = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel"  # sudo права
      "networkmanager" 
      "video" 
      "audio" 
      "libvirtd"  # Для виртуализации
    ];
    shell = pkgs.zsh;
  };

  # Системные пакеты
  environment.systemPackages = with pkgs; [
    # Базовые утилиты
    vim
    wget
    cava
    nftables
    curl
    git
    htop
    file
    fastfetch
    neofetch
    mpvpaper
    gtk3
    nwg-look
   
    # Wayland композитор и окружение
    hyprland
    waybar
    rofi
    dunst
    
    # OBS Studio с поддержкой NVENC
    obs-studio
    obs-studio-plugins.obs-vaapi
    
    # Steam и игровые утилиты
    steam
    steam-run
    gamemode
    gamescope
    
    # Мультимедиа
    vlc
    mpv
    pavucontrol
    flameshot
    # Графические утилиты
    firefox
    obsidian
    alacritty
    kitty
    discord
    telegram-desktop
    xfce.thunar
    nvidia-vaapi-driver
    ayugram-desktop
  ];
#шрифты
fonts.packages = with pkgs; [
font-awesome
jetbrains-mono
nerd-fonts.jetbrains-mono
noto-fonts
noto-fonts-emoji
];


#zsh 
programs.zsh = { 
enable = true;
};

  # OBS Studio с поддержкой NVENC
  nixpkgs.config.allowUnfree = true;  # Разрешить несвободные пакеты

  # Steam настройки
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Wayland и Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;  # Поддержка XWayland для X11 приложений
  };

  # XWayland поддержка
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    
    # Display Manager (SDDM)
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "where_is_my_sddm_theme";  # Можно установить свою тему
    };
  };

  # Аудио

  hardware.pulseaudio.enable = false;  # Отключаем PulseAudio в пользу PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Дополнительные сервисы
  services = {
    # DBus для межпроцессного взаимодействия
    dbus.enable = true;
    
    # CUPS для принтеров
    printing.enable = true;
    
    # Bluetooth
    blueman.enable = true;
  };

  # Файловая система
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Garbage Collection для Nix
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than-7d";
    };
  };

  # Системные настройки
  system = {
    # Автоматическое обновление
    autoUpgrade = {
      enable = true;
      channel = "https://nixos.org/channels/nixos-unstable";
    };
    
    stateVersion = "23.11";  # Не меняйте без необходимости
  };

  # Файрвол
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # Переменные окружения для лучшей совместимости
  environment.sessionVariables = {
    # Wayland переменные
    WLR_NO_HARDWARE_CURSORS = "2";
    LIBVA_DRIVER_NAME = "nvidia";
    
    # NVIDIA переменные
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "2";
    __GL_VRR_ALLOWED = "2";
    
    # Поддержка игр
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "2";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "2";
    
    # Steam переменные
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
