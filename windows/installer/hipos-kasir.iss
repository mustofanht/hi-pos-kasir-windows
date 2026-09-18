; Installer HI-POS Kasir (Inno Setup 6)
; Dipanggil dari GitHub Actions setelah "flutter build windows --release".
; SourceDir = folder hasil build (build\windows\x64\runner\Release) dikirim
; lewat /DSourceDir=... ; AppVersion lewat /DAppVersion=...

#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

#define MyAppName "HI-POS Kasir"
#define MyAppPublisher "HI-POS"
#define MyAppExeName "hi-pos-kasir.exe"

[Setup]
; AppId menentukan identitas aplikasi saat upgrade/uninstall. JANGAN diubah.
AppId={{8E4B2F1A-9C37-4D8E-B5A1-0F6C7D2E3A94}
AppName={#MyAppName}
AppVersion={#AppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\HI-POS Kasir
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputDir=.
OutputBaseFilename=HI-POS-Kasir-Setup
SetupIconFile=..\runner\resources\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
; Install untuk semua user (butuh admin); user bisa pilih install per-user
; lewat dialog kalau tidak punya hak admin.
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Buat shortcut di Desktop"; GroupDescription: "Shortcut tambahan:"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Jalankan {#MyAppName}"; Flags: nowait postinstall skipifsilent
