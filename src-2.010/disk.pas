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

unit disk; //saves/loads settings/server lists

interface

uses
  Windows, Registry, SysUtils, Forms, Classes, Controls,
  Graphics, ShellAPI, CommCtrl, Dialogs; //fix dialogs


procedure LoadSettings;
procedure SaveSettings;
procedure LoadServerList(filename: String);
procedure SaveServerList(filename: String);

implementation

uses Main, GameSetup, Options;

function ReadIntFromReg(reg: TRegistry; name: String; def: Integer): Integer;
begin
  if reg.ValueExists(name) then
    result := reg.ReadInteger(name)
  else
    result := def;
end;

procedure LoadSettings;
type
  TDet = function: PChar;
var
  cnx: TDet;
  vnx: TGet;
  hmod: THandle;
  i, j, gindex, findex, state: Integer;
  reg: TRegistry;
  searchRec: TSearchRec;
  s, t: String;
  serverColWidth: Array[0..6] of Integer;
  playerColWidth: Array[0..5] of Integer;
  ruleColWidth: Array[0..1] of Integer;
  tb, bmp, mask: TBitmap;
  r: TRect;
const
  DEFAULTSERVERCOLWIDTH: Array[0..5] of Integer = (180, 50, 150, 50, 50, 50);
  DEFAULTPLAYERCOLWIDTH: Array[0..5] of Integer = (130, 40, 40, 50, 50, 50);
  DEFAULTRULECOLWIDTH: Array[0..1] of Integer = (80, 50);
  DEFAULTSERVERCOLORDER: Array[0..5] of Integer = (-1, 0, 1, 2, 3, 4); //-999 = hidden, -1 = caption
  DEFAULTPLAYERCOLORDER: Array[0..5] of Integer = (-1, 0, 1, 2, 3, 4); //-999 = hidden, -1 = caption
  SERVERCOLNAME: Array[0..5] of String = ('Server Name', 'Ping', 'Address', 'Map', 'Players', 'Game/Mod'); //also in mniOptionsClick
  PLAYERCOLNAME: Array[0..5] of String = ('Player Name', 'Frags', 'Skin', 'Ping', 'Connect', 'User ID');
  RESOURCENAME: Array[0..7] of String = ('REFRESHING', 'NORESPONCE', 'NONE', 'EMPTY', 'FULL', 'PW', 'PWEMPTY', 'PWFULL');
begin
  ShowWindow(frmMain.Handle, SW_HIDE);
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Software\Fizz', True);
    with frmMain do begin
      lvwServer.Height := ReadIntFromReg(reg, 'List1', lvwServer.Height);
      lvwPlayer.Width := ReadIntFromReg(reg, 'List2', lvwPlayer.Width);
      if reg.ValueExists('ServerColOrder') then //server column order
        reg.ReadBinaryData('ServerColOrder', serverColOrder, SizeOf(serverColOrder))
      else
        for i := 0 to 5 do
          serverColOrder[i] := DEFAULTSERVERCOLORDER[i];
      if reg.ValueExists('ServerColWidth') then //server column width
        reg.ReadBinaryData('ServerColWidth', serverColWidth, SizeOf(serverColWidth))
      else
        for i := 0 to 5 do
          serverColWidth[i] := DEFAULTSERVERCOLWIDTH[i];
      for i := 0 to 5 do //update lvwServer
        if serverColOrder[i] <> -999 then
          lvwServer.Columns.Add;
      for i := 0 to 5 do
        if serverColOrder[i] <> -999 then begin
          lvwServer.Columns[serverColOrder[i]+1].Caption := SERVERCOLNAME[i];
          lvwServer.Columns[serverColOrder[i]+1].Width := serverColWidth[i];
        end;
      if reg.ValueExists('PlayerColOrder') then //player column order
        reg.ReadBinaryData('PlayerColOrder', playerColOrder, SizeOf(playerColOrder))
      else
        for i := 0 to 5 do
          playerColOrder[i] := DEFAULTPLAYERCOLORDER[i];
      if reg.ValueExists('PlayerColWidth') then //player column width
        reg.ReadBinaryData('PlayerColWidth', playerColWidth, SizeOf(playerColWidth))
      else
        for i := 0 to 5 do
          playerColWidth[i] := DEFAULTPLAYERCOLWIDTH[i];
      for i := 0 to 5 do //update lvwPlayer
        if playerColOrder[i] <> -999 then
          lvwPlayer.Columns.Add;
      for i := 0 to 5 do
        if playerColOrder[i] <> -999 then begin
          lvwPlayer.Columns[playerColOrder[i]+1].Caption := PLAYERCOLNAME[i];
          lvwPlayer.Columns[playerColOrder[i]+1].Width := playerColWidth[i];
        end;
      if reg.ValueExists('RuleColWidth') then //rule column width
        reg.ReadBinaryData('RuleColWidth', ruleColWidth, SizeOf(ruleColWidth))
      else
        for i := 0 to 1 do
          ruleColWidth[i] := DEFAULTRULECOLWIDTH[i];
      for i := 0 to 1 do
        lvwrule.Columns[i].Width := ruleColWidth[i];
      if reg.ValueExists('NameData') then begin
        reg.ReadBinaryData('NameData', nameData, SizeOf(nameData));
        if nameData[0].Enabled then mniName1.Caption := nameData[0].DisplayName;
        if nameData[1].Enabled then mniName2.Caption := nameData[1].DisplayName;
        if nameData[2].Enabled then mniName3.Caption := nameData[2].DisplayName;
        if nameData[3].Enabled then mniName4.Caption := nameData[3].DisplayName;
        if nameData[4].Enabled then mniName5.Caption := nameData[4].DisplayName;
      end;
      i := ReadIntFromReg(reg, 'NameIndex', 0);
      case i of
        0: mniName1.Checked := True;
        1: mniName2.Checked := True;
        2: mniName3.Checked := True;
        3: mniName4.Checked := True;
        4: mniName5.Checked := True;
      end;
      if reg.ValueExists('PlayerSortAsc') then
        playerSortAsc := reg.ReadBool('PlayerSortAsc');
      if reg.ValueExists('ServerSortAsc') then
        serverSortAsc := reg.ReadBool('ServerSortAsc');
      if reg.ValueExists('ICQIntegration') then
        options.ICQIntegration := reg.ReadBool('ICQIntegration');
      if reg.ValueExists('DblLaunch') then
        options.DblClickToLaunch := reg.ReadBool('DblLaunch');
      if reg.ValueExists('MinToTray') then
        options.MinimizeToTray := reg.ReadBool('MinToTray');
      if reg.ValueExists('LockList') then begin
        mniLockList.Checked := reg.ReadBool('LockList');
        if mniLockList.Checked then begin
          lvwServer.DragMode := dmManual;
          lvwServer.ColumnClick := False;
          lvwPlayer.ColumnClick := False;
        end
        else begin
          lvwServer.DragMode := dmAutomatic;
          lvwServer.ColumnClick := True;
          lvwPlayer.ColumnClick := True;
        end;
      end;
      if reg.ValueExists('ICQMessage') then
        options.ICQMessage := reg.ReadString('ICQMessage');
      options.ICQState := ReadIntFromReg(reg, 'ICQState', 0);
      playerSortCol := ReadIntFromReg(reg, 'PlayerSortCol', 0);
      playerSortName := ReadIntFromReg(reg, 'PlayerSortName', 1);
      serverSortCol := ReadIntFromReg(reg, 'ServerSortCol', 0);
      options.TimeOut := ReadIntFromReg(reg, 'TimeOut', 3000);
      options.RefreshNum := ReadIntFromReg(reg, 'RefreshNum', 4);
      frmMain.Top := ReadIntFromReg(reg, 'Top', frmMain.Top);
      frmMain.Left := ReadIntFromReg(reg, 'Left', frmMain.Left);
      frmMain.Height := ReadIntFromReg(reg, 'Height', frmMain.Height);
      frmMain.Width := ReadIntFromReg(reg, 'Width', frmMain.Width);
      state := ReadIntFromReg(reg, 'State', 0);
      options.WhenLaunchGameDo := ReadIntFromReg(reg, 'Join', 1);
      gindex := ReadIntFromReg(reg, 'GameIndex', 0);
      findex := ReadIntFromReg(reg, 'FilterIndex', 0);

      //DATA KEY BELOW
      reg.OpenKey('Data', True);
      //load plugins
      i := 0;
      s := ExtractFilePath(ParamStr(0)) + 'plugins\';
      if FindFirst(s + '??.dll', faAnyFile, searchRec) = 0 then begin
        repeat
          hmod := LoadLibrary(PChar(s + searchRec.Name));
          if hmod = 0 then
            FreeLibrary(hmod)
          else begin
            @cnx := GetProcAddress(hmod, 'Info');
            @vnx := GetProcAddress(hmod, 'Main');
            if (@cnx = nil) or (@vnx = nil) then //check
              FreeLibrary(hmod)
            else begin //dll is ok
              t := cnx;
              if Copy(t, 1, 5) = 'Fizz'#10 then begin
                Delete(t, 1, 5);
                gameData[i].GameName := Copy(t, 1, Pos(#10, t)-1); //ie. QuakeWorld, Quake, etc
                Delete(t, 1, Pos(#10, t));
                gameData[i].Author := Copy(t, 1, Pos(#10, t)-1); //ie. bliP
                Delete(t, 1, Pos(#10, t));
                gameData[i].Version := Copy(t, 1, Pos(#10, t)-1); //ie. 1.00
                Delete(t, 1, Pos(#10, t));
                gameData[i].DefaultPort := Copy(t, 1, Pos(#10, t)-1); //ie. 27500
                Delete(t, 1, Pos(#10, t));
                gameData[i].QueryPort := StrToInt(Copy(t, 1, Pos(#10, t)-1)); //ie. 27500
                Delete(t, 1, Pos(#10, t));
                gameData[i].DefaultCommandLine := Copy(t, 1, Pos(#10, t)-1); //ie. c:\quake\q.exe
                Delete(t, 1, Pos(#10, t));
                gameData[i].DefaultParameters := Copy(t, 1, Pos(#10, t)-1); //ie. +connect %ip%
                Delete(t, 1, Pos(#10, t));
                gameData[i].ID := UpperCase(Copy(searchRec.Name, 1, 2)); //ie QW
                //images
                gameData[i].Icons := TImageList.Create(nil);
                gameData[i].Icons.Width := 25;
                gameData[i].Icons.Height := 16;
                gameData[i].Icons.Masked := True;
                r := Rect(0,0,25,16);
                tb := TBitmap.Create;
                tb.Width := 25;
                tb.Height := 16;
                bmp := TBitmap.Create;
                bmp.LoadFromResourceName(hmod, 'MAIN'); //icon in dll
                mask := TBitmap.Create;
                mask.Width := 25;
                mask.Height := 16;
                for j := 0 to 7 do begin
                  mask.LoadFromResourceName(hInstance, RESOURCENAME[j]); //icon in fizz.exe
                  tb.LoadFromResourceName(hInstance, 'NONE');
                  tb.Canvas.CopyMode := cmSrcInvert;
                  tb.Canvas.CopyRect(r, bmp.Canvas, r);
                  tb.Canvas.CopyMode := cmSrcErase;
                  tb.Canvas.CopyRect(r, mask.Canvas, r);
                  gameData[i].Icons.Add(tb, tb);
                end;
                bmp.Free;
                mask.Free;
                tb.Free;
                //hi
                gameData[i].GetData := vnx;
                gameData[i].Hwn := hmod;
                //settings
                if reg.ValueExists(GameData[i].ID+'_C1') then
                  gameData[i].CommandLine1 := reg.ReadString(GameData[i].ID+'_C1');
                if reg.ValueExists(GameData[i].ID+'_C2') then
                  gameData[i].CommandLine2 := reg.ReadString(GameData[i].ID+'_C2');
                if reg.ValueExists(GameData[i].ID+'_P1') then
                  gameData[i].Param1 := reg.ReadString(GameData[i].ID+'_P1');
                if reg.ValueExists(GameData[i].ID+'_P2') then
                  gameData[i].Param2 := reg.ReadString(GameData[i].ID+'_P2');
                if reg.ValueExists(GameData[i].ID+'_CF') then
                  gameData[i].CreateTextFile := reg.ReadBool(GameData[i].ID+'_CF');
                if reg.ValueExists(GameData[i].ID+'_FN') then
                  gameData[i].TextFileName := reg.ReadString(GameData[i].ID+'_FN');
                if reg.ValueExists(GameData[i].ID+'_FC') then
                  gameData[i].TextFileContents := reg.ReadString(GameData[i].ID+'_FC');
                if reg.ValueExists(GameData[i].ID+'_IN') then
                  gameData[i].Installed := reg.ReadBool(GameData[i].ID+'_IN')
                else
                  gameData[i].Installed := False;
                //filters
                for j := 0 to 31 do begin
                  gameData[i].Filter[j].Name := '';
                  gameData[i].Filter[j].Data := '';
                  if reg.ValueExists(gameData[i].ID + '_FI' + IntToStr(j)) then begin
                    t := reg.ReadString(gameData[i].ID + '_FI' + IntToStr(j));
                    gameData[i].Filter[j].Name := Copy(s, 1, Pos('\', t) - 1);
                    gameData[i].Filter[j].Data := Copy(s, Pos('\', t) + 1, Length(t));
                  end;
                end;
                //ShowMessage('loaded ' + gameData[i].ID);
                Inc(i);
                if (i > 63) then break;
              end
              else //bad header
                FreeLibrary(hmod);
            end;
          end;
        until FindNext(searchRec) <> 0;
      end;
      FindClose(searchRec);
    end;
  finally
    reg.Free;
  end;
  LoadServerList(ExtractFilePath(ParamStr(0)) + 'server.fzs');
  with frmMain do begin
    SetGameBox;
    cboGame.ItemIndex := gindex;
    activeGame := gindex;
    IsGame;
    SetFilterBox;
    cboFilter.ItemIndex := findex;
    UpdateList(True);
  end;
  if state = 1 then
    ShowWindow(frmMain.Handle, SW_MAXIMIZE) //wtf wsMaximized makes window screwy if you can see any scrollbars in lvwServer
  else
    ShowWindow(frmMain.Handle, SW_SHOW);
end;

procedure SaveSettings;
var
  reg: TRegistry;
  state, i, j, playerName: Integer;
  pl: TWindowPlacement;
  r: TRect;
  serverColWidth: Array[0..5] of Integer;
  playerColWidth: Array[0..5] of Integer;
  ruleColWidth: Array[0..1] of Integer;
begin
  pl.Length := SizeOf(TWindowPlacement); //form pos
  GetWindowPlacement(frmMain.Handle, @pl);
  r := pl.rcNormalPosition;
  ShowWindow(frmMain.Handle, SW_HIDE);
  with frmMain do begin
    for i := 0 to 5 do
      if serverColOrder[i] <> -999 then
        serverColWidth[i] := lvwServer.Columns[serverColOrder[i]+1].Width
      else
        serverColWidth[i] := 100;
    for i := 0 to 5 do
      if playerColOrder[i] <> -999 then
        playerColWidth[i] := lvwPlayer.Columns[playerColOrder[i]+1].Width
      else
        playerColWidth[i] := 100;
    for i := 0 to 1 do //rule column width
      ruleColWidth[i] := lvwRule.Columns[i].Width;
    playerName := 0;
    if mniName1.Checked then playerName := 0;
    if mniName2.Checked then playerName := 1;
    if mniName3.Checked then playerName := 2;
    if mniName4.Checked then playerName := 3;
    if mniName5.Checked then playerName := 4;
    if (frmMain.WindowState = wsMaximized) or (frmMain.WindowState = wsMinimized) then
      state := 1
    else
      state := 0;

    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey('Software\Fizz', True);
      reg.WriteInteger('Width', r.Right-r.Left);
      reg.WriteInteger('Height', r.Bottom-r.Top);
      reg.WriteInteger('Left', r.Left);
      reg.WriteInteger('Top', r.Top);
      reg.WriteInteger('List1', lvwServer.Height);
      reg.WriteInteger('List2', lvwPlayer.Width);
      reg.WriteInteger('NameIndex', playerName);
      reg.WriteBool('ServerSortAsc', serverSortAsc);
      reg.WriteInteger('ServerSortCol', serverSortCol);
      reg.WriteBool('PlayerSortAsc', playerSortAsc);
      reg.WriteInteger('PlayerSortCol', playerSortCol);
      reg.WriteInteger('PlayerSortName', playerSortName);
      reg.WriteInteger('TimeOut', options.TimeOut);
      reg.WriteInteger('RefreshNum', options.RefreshNum);
      reg.WriteInteger('GameIndex', cboGame.ItemIndex);
      reg.WriteInteger('FilterIndex', cboFilter.ItemIndex);
      reg.WriteInteger('Join', options.WhenLaunchGameDo);
      reg.WriteBool('MinToTray', options.MinimizeToTray);
      reg.WriteBool('DblLaunch', options.DblClickToLaunch);
      reg.WriteBool('LockList', mniLockList.Checked);
      reg.WriteBool('ICQIntegration', options.ICQIntegration);
      reg.WriteInteger('ICQState', options.ICQState);
      reg.WriteString('ICQMessage', options.ICQMessage);
      reg.WriteBinaryData('ServerColWidth', serverColWidth, SizeOf(serverColWidth));
      reg.WriteBinaryData('PlayerColWidth', playerColWidth, SizeOf(playerColWidth));
      reg.WriteBinaryData('RuleColWidth', ruleColWidth, SizeOf(ruleColWidth));
      reg.WriteBinaryData('NameData', nameData, SizeOf(nameData));
      reg.WriteInteger('State', state);

      //DATA KEY BELOW
      reg.OpenKey('Data', True); //Software\Fizz\
      i := 0;
      while GameData[i].GameName <> '' do begin
        gameData[i].Icons.Free;
        //gamedata
        reg.WriteString(GameData[i].ID+'_C1', GameData[i].CommandLine1);
        reg.WriteString(GameData[i].ID+'_C2', GameData[i].CommandLine2);
        reg.WriteString(GameData[i].ID+'_P1', GameData[i].Param1);
        reg.WriteString(GameData[i].ID+'_P2', GameData[i].Param2);
        reg.WriteBool(GameData[i].ID+'_CF', GameData[i].CreateTextFile);
        reg.WriteString(GameData[i].ID+'_FN', GameData[i].TextFileName);
        reg.WriteString(GameData[i].ID+'_FC', GameData[i].TextFileContents);
        reg.WriteBool(GameData[i].ID+'_IN', GameData[i].Installed);
        //filters
        for j := 0 to 31 do
          if reg.ValueExists(GameData[i].ID + '_FI' + IntToStr(j)) then
            reg.DeleteValue(GameData[i].ID + '_FI' + IntToStr(j));
        for j := 0 to 31 do
          if (GameData[i].Filter[j].Name <> '') then
            reg.WriteString(GameData[i].ID + '_FI' + IntToStr(j),
                GameData[i].Filter[j].Name + '\' +
                GameData[i].Filter[j].Data);
        Inc(i);
      end;
    finally
     reg.Free;
    end;
  end;
  SaveServerList(ExtractFilePath(ParamStr(0)) + 'server.fzs');
  //unload dll
  i := 0;
  with frmMain do
    while (gameData[i].GameName <> '') and (i <= 63) do begin
      FreeLibrary(gameData[i].Hwn);
      Inc(i);
    end;
end;

procedure LoadServerList(filename: String);
var
  tmp: String;
  loadServer: Array[0..7] of String;
  i, j, m, n: Integer;
  serverList: TextFile;
begin
  i := 0;
  with frmMain do
    while serverData[i].ServerName <> '' do
      Inc(i);
  if FileExists(filename) then begin
    AssignFile(serverList, filename);
    try
      Reset(serverList);
      while not EOF(serverList) do begin
        ReadLn(serverList, tmp);
        if Copy(tmp, 1, 1) <> '#' then begin //# ingore line
          for j := 0 to 7 do //clear
            loadServer[j] := '';
          m := 1;
          n := 0;
          while m <= Length(tmp) do begin //parse
            if (tmp[m] = '\') then
              Inc(n)
            else
              loadServer[n] := loadServer[n] + tmp[m];
            Inc(m);
          end;
          with frmMain do begin
            j := 0;
            while (GameData[j].ID <> '') and (j <= 64) do begin
              if GameData[j].ID = loadServer[0] then begin
                serverData[i].Game := j;
                serverData[i].ServerName := loadServer[1];
                serverData[i].Ping := loadServer[2];
                serverData[i].Address := loadServer[3];
                serverData[i].Map := '';
                serverData[i].Players := 0;
                serverData[i].MaxPlayers := 0;
                serverData[i].GameMod := loadServer[4];
                serverData[i].IP := loadServer[5];
                serverData[i].Port := StrToInt(loadServer[6]);
                serverData[i].IconIndex := StrToInt(loadServer[7]);
                Inc(i);
                Break;
              end;
              Inc(j);
            end;
          end;
        end;
      end;
    finally
      CloseFile(serverList);
    end;
  end;
end;

procedure SaveServerList(filename: String);
var
  serverList: TextFile;
  serverString: String;
  i: Integer;
begin
  AssignFile(serverList, filename);
  try
    ReWrite(serverList);
    WriteLn(serverList, '# Fizz Server List (resist the urge to modify)');
    with frmMain do begin
      for i := 0 to 1023 do begin
        if serverData[i].ServerName <> '' then begin
          if serverData[i].IconIndex = 0 then //dont save refresh icon
            serverData[i].IconIndex := 2;
          serverString := GameData[serverData[i].Game].ID + '\' + //game
                          serverData[i].ServerName + '\' +
                          serverData[i].Ping + '\' +
                          serverData[i].Address + '\' +
                          serverData[i].GameMod + '\' +
                          serverData[i].IP + '\' +
                          IntToStr(serverData[i].Port) + '\' +
                          IntToStr(serverData[i].IconIndex);
          WriteLn(serverList, serverString);
        end;
      end;
    end;
  finally
    CloseFile(serverList);
  end;
end;

end.

