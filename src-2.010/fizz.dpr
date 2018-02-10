{
    Copyright (C) 2001-2002 Chris Cuthbertson

    This file is part of Fizz.

    Fizz is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Fizz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Fizz; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

program fizz;

uses
  Forms,
  WinProcs,
  Registry,
  Dialogs,
  Controls,
  main in 'main.pas' {frmMain},
  gamesetup in 'dlg\gamesetup.pas' {frmGameSetup},
  disk in 'disk.pas',
  addserver in 'dlg\addserver.pas' {frmAddServer},
  options in 'dlg\options.pas' {frmOptions},
  splash in 'dlg\splash.pas' {frmSplash},
  about in 'dlg\about.pas' {frmAbout},
  server in 'server.pas',
  join in 'dlg\join.pas' {frmJoin},
  refresh in 'refresh.pas',
  filter in 'dlg\filter.pas' {frmFilter},
  dllinfo in 'dllinfo.pas' {frmDLLInfo};

{$R *.res}

var
  reg : TRegistry;

begin
  if (ParamStr(1) = '-reset') and (MessageDlg('Reset Everything? This will remove all Fizz''s registry entries', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.DeleteKey('Software\Fizz');
    finally
      reg.CloseKey;
      reg.Free;
    end;
    ShowMessage('Done, Fizz will now close.');
    Application.Terminate;
  end
  else begin
    if ParamStr(1) = '-nosplash' then begin //debug
      Application.Initialize;
      Application.Title := 'Fizz';
      Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmDLLInfo, frmDLLInfo);
  end
    else begin
      try
        frmSplash := TfrmSplash.Create(Application);
        frmSplash.Show;
        frmSplash.Update;
        repeat
          Application.ProcessMessages;
        until frmSplash.CloseQuery;
        Application.Initialize;
        Application.Title := 'Fizz';
        Application.HelpFile := 'fizz.hlp';
  Application.CreateForm(TfrmMain, frmMain);
        frmSplash.Close;
      finally
        frmSplash.Release;
      end;
    end;
    Application.Run;
  end;
end.
