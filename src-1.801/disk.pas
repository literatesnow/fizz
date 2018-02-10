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
  Windows, Registry, SysUtils, Forms, Classes, Controls;

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
var
  i, j, gindex, findex, state: Integer;
  reg: TRegistry;
  gameName, s: String;
  serverColWidth: Array[0..6] of Integer;
  playerColWidth: Array[0..5] of Integer;
  ruleColWidth: Array[0..1] of Integer;
const
  DEFAULTSERVERCOLWIDTH: Array[0..5] of Integer = (180, 50, 150, 50, 50, 50);
  DEFAULTPLAYERCOLWIDTH: Array[0..5] of Integer = (130, 40, 40, 50, 50, 50);
  DEFAULTRULECOLWIDTH: Array[0..1] of Integer = (80, 50);
  DEFAULTSERVERCOLORDER: Array[0..5] of Integer = (-1, 0, 1, 2, 3, 4); //-999 = hidden, -1 = caption
  DEFAULTPLAYERCOLORDER: Array[0..5] of Integer = (-1, 0, 1, 2, 3, 4); //-999 = hidden, -1 = caption
  SERVERCOLNAME: Array[0..5] of String = ('Server Name', 'Ping', 'Address', 'Map', 'Players', 'Game/Mod'); //also in mniOptionsClick
  PLAYERCOLNAME: Array[0..5] of String = ('Player Name', 'Frags', 'Skin', 'Ping', 'Connect', 'User ID');
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
      for i := 0 to 7 do begin
        case i of //GAME_ADD
          0: gameName := 'VQ';
          1: gameName := 'QW';
          2: gameName := 'Q2';
          3: gameName := 'Q3';
          4: gameName := 'HL';
          5: gameName := 'WF';
          6: gameName := 'T1';
          7: gameName := 'T2';
        end;
        //gamedata
        if reg.ValueExists(gameName+'_C1') then
          GameData[i].CommandLine1 := reg.ReadString(gameName+'_C1');
        if reg.ValueExists(gameName+'_C2') then
          GameData[i].CommandLine2 := reg.ReadString(gameName+'_C2');
        if reg.ValueExists(gameName+'_P1') then
          GameData[i].Param1 := reg.ReadString(gameName+'_P1');
        if reg.ValueExists(gameName+'_P2') then
          GameData[i].Param2 := reg.ReadString(gameName+'_P2');
        if reg.ValueExists(gameName+'_CF') then
          GameData[i].CreateTextFile := reg.ReadBool(gameName+'_CF');
        if reg.ValueExists(gameName+'_FN') then
          GameData[i].TextFileName := reg.ReadString(gameName+'_FN');
        if reg.ValueExists(gameName+'_FC') then
          GameData[i].TextFileContents := reg.ReadString(gameName+'_FC');
        if reg.ValueExists(gameName+'_IN') then
          GameData[i].Installed := reg.ReadBool(gameName+'_IN')
        else
          GameData[i].Installed := False;
        //filters
        for j := 0 to 31 do begin
          GameData[i].Filter[j].Name := '';
          GameData[i].Filter[j].Data := '';
          if reg.ValueExists(gameName + '_FI' + IntToStr(j)) then begin
            s := reg.ReadString(gameName + '_FI' + IntToStr(j));
            GameData[i].Filter[j].Name := Copy(s, 1, Pos('\', s) - 1);
            GameData[i].Filter[j].Data := Copy(s, Pos('\', s) + 1, Length(s));
          end;
        end;
      end;
    end;
  finally
    reg.Free;
  end;
  LoadServerList('server.fzs');
  with frmMain do begin
    SetGameBox;
    cboGame.ItemIndex := gindex;
    activeGame := -1;
    if cboGame.Text = 'Quake' then activeGame := 0;
    if cboGame.Text = 'QuakeWorld' then activeGame := 1; //GAME_ADD
    if cboGame.Text = 'Quake 2' then activeGame := 2;
    if cboGame.Text = 'Quake 3 Arena' then activeGame := 3;
    if cboGame.Text = 'Half-Life' then activeGame := 4;
    if cboGame.Text = 'Wolfenstein' then activeGame := 5;
    if cboGame.Text = 'Tribes' then activeGame := 6;
    if cboGame.Text = 'Tribes 2' then activeGame := 7;
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
  gameName: String;
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
      for i := 0 to 7 do begin //GAME_ADD
        case i of
          0: gameName := 'VQ';
          1: gameName := 'QW';
          2: gameName := 'Q2';
          3: gameName := 'Q3';
          4: gameName := 'HL';
          5: gameName := 'WF';
          6: gameName := 'T1';
          7: gameName := 'T2';
        end;
        //gamedata
        reg.WriteString(gameName+'_C1', GameData[i].CommandLine1);
        reg.WriteString(gameName+'_C2', GameData[i].CommandLine2);
        reg.WriteString(gameName+'_P1', GameData[i].Param1);
        reg.WriteString(gameName+'_P2', GameData[i].Param2);
        reg.WriteBool(gameName+'_CF', GameData[i].CreateTextFile);
        reg.WriteString(gameName+'_FN', GameData[i].TextFileName);
        reg.WriteString(gameName+'_FC', GameData[i].TextFileContents);
        reg.WriteBool(gameName+'_IN', GameData[i].Installed);
        //filters
        for j := 0 to 31 do
          if reg.ValueExists(gameName + '_FI' + IntToStr(j)) then
            reg.DeleteValue(gameName + '_FI' + IntToStr(j));
        for j := 0 to 31 do
          if (GameData[i].Filter[j].Name <> '') then
            reg.WriteString(gameName + '_FI' + IntToStr(j),
                GameData[i].Filter[j].Name + '\' +
                GameData[i].Filter[j].Data);
      end;
    finally
     reg.Free;
    end;
  end;
  SaveServerList('server.fzs');
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
            serverData[i].ServerName := loadServer[1];
            serverData[i].Ping := loadServer[2];
            serverData[i].Address := loadServer[3];
            serverData[i].Map := '';
            serverData[i].Players := '';
            serverData[i].GameMod := loadServer[4];
            serverData[i].IP := loadServer[5];
            serverData[i].Port := StrToInt(loadServer[6]);
            serverData[i].Image := StrToInt(loadServer[7]);
            serverData[i].PlayerData := '*none';
            serverData[i].RuleData := '*none';
            if loadServer[0] = 'VQ' then serverData[i].Game := 0; //GAME_ADD
            if loadServer[0] = 'QW' then serverData[i].Game := 1;
            if loadServer[0] = 'Q2' then serverData[i].Game := 2;
            if loadServer[0] = 'Q3' then serverData[i].Game := 3;
            if loadServer[0] = 'HL' then serverData[i].Game := 4;
            if loadServer[0] = 'WF' then serverData[i].Game := 5;
            if loadServer[0] = 'T1' then serverData[i].Game := 6;
            if loadServer[0] = 'T2' then serverData[i].Game := 7;
          end;
          Inc(i);
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
const
  gameName: Array [0..7] of String = ('VQ', 'QW', 'Q2', 'Q3', 'HL', 'WF', 'T1', 'T2'); //GAME_ADD
begin
  AssignFile(serverList, filename);
  try
    ReWrite(serverList);
    WriteLn(serverList, '# Fizz Server List (resist the urge to modify)');
    with frmMain do begin
      for i := 0 to 1023 do begin
        if serverData[i].ServerName <> '' then begin
          if serverData[i].Image in [0, 10, 20, 30, 40, 50, 60, 70] then //dont save refresh icon GAME_ADD
            serverData[i].Image := (serverData[i].Image * 10) + 6;
          serverString := gameName[serverData[i].Game] + '\' + //game
                          serverData[i].ServerName + '\' +
                          serverData[i].Ping + '\' +
                          serverData[i].Address + '\' +
                          serverData[i].GameMod + '\' +
                          serverData[i].IP + '\' +
                          IntToStr(serverData[i].Port) + '\' +
                          IntToStr(serverData[i].Image);
          WriteLn(serverList, serverString);
        end;
      end;
    end;
  finally
    CloseFile(serverList);
  end;
end;

end.

