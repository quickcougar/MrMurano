[Setup]
AppName=MrMurano
AppVersion={%MRVERSION}
DefaultDirName={pf}\MrMurano
DefaultGroupName=MrMurano
ChangesEnvironment=yes
OutputBaseFileName=MrMuranoSetup
AppPublisher=Exosite
AppPublisherURL=http://exosite.com/
AppCopyright=Copyright (C) 2016 Exosite
LicenseFile=LICENSE.txt

[Files]
Source: "mr.exe"; DestDir: "{app}\bin"
Source: "LICENSE.txt"; DestDir: "{app}"
Source: "ReadMe.txt"; DestDir: "{app}"; Flags: isreadme


;;;;;;;;;;;;;;;;;;;;;;;;;
; http://stackoverflow.com/questions/3304463/how-do-i-modify-the-path-environment-variable-when-running-an-inno-setup-install/3431379
[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\bin"; \
    Check: NeedsAddPath('{app}\bin')

;;; Not working.
[Code]

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  // look for the path with leading and trailing semicolon
  // Pos() returns 0 if not found
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;


