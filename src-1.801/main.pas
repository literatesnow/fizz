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

unit main;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Menus, Registry, ToolWin, StdCtrls, ImgList,
  ShellAPI, Clipbrd, Winsock, Masks, TB2Item, TB2Dock, TB2Toolbar; //clean this up

const
  WM_ShellIcon = WM_USER + 1;

type
  TOptions = record
    DblClickToLaunch: Boolean;
    MinimizeToTray: Boolean;
    WhenLaunchGameDo: Integer;
    ICQIntegration: Boolean;
    ICQState: Integer;
    ICQMessage: String;
    TimeOut: Integer;
    RefreshNum: Integer;
  end;

type
  TFilterData = record
    Name: String;
    Data: String;
  end;

type
  TGameData = record
    CommandLine1: String[127];
    CommandLine2: String[127];
    Param1: String[127];
    Param2: String[127];
    CreateTextFile: Boolean;
    TextFileName: String[127];
    TextFileContents: String[255];
    Installed: Boolean;
    Filter: Array[0..31] of TFilterData;
  end;

type
  TNameData = record
    DisplayName: String[128];
    Name: String[128];
    Enabled: Boolean;
  end;

type
  TServerData = record
    ServerName: String; //ZFREE Clear TF2.9
    Ping: String; //6
    Address: String; //games3.clear.net.nz (230.96.54.7)
    Map: String; //demoz2a
    Players: String; //20/32
    Game: Integer; //0..
    GameMod: String; //QuakeWorld/fortress
    IP: String; //230.96.54.7
    Port: Integer; //27500
    Image: Integer; //23
    PlayerData: String; //jimmy, 0, 0 "fg"\bob etc
    RuleData: String; //rule, value\rule value etc
  end;

type
  TfrmMain = class(TForm)
    splHorizontal: TSplitter;
    splVertical: TSplitter;
    lvwServer: TListView;
    lvwPlayer: TListView;
    lvwRule: TListView;
    tbrDock: TTBDock;
    tbrMain: TTBToolbar;
    imgPlayer: TImageList;
    imgToolbar: TImageList;
    imgServer: TImageList;
    StatusBar: TStatusBar;
    mnuServer: TPopupMenu;
    mniJoin: TMenuItem;
    mniSpec: TMenuItem;
    mniSep1: TMenuItem;
    mniDNSIP: TMenuItem;
    mniIPDNS: TMenuItem;
    mniSep2: TMenuItem;
    mniCopyIP: TMenuItem;
    mniPassword: TMenuItem;
    mniPwdJoin: TMenuItem;
    mniPwdSpec: TMenuItem;
    mniCustomJoin: TMenuItem;
    mnuTray: TPopupMenu;
    mniTrayRestore: TMenuItem;
    mniTrayExit: TMenuItem;
    mnuMain: TTBToolbar;
    mniFile: TTBSubmenuItem;
    mniServerListImport: TTBItem;
    mniServerListExport: TTBItem;
    mniExit: TTBItem;
    mniServer: TTBSubmenuItem;
    mniAddServer: TTBItem;
    mniRemoveServer: TTBItem;
    mniRefreshAll: TTBItem;
    mniRefreshSelected: TTBItem;
    mniView: TTBSubmenuItem;
    mniName: TTBSubmenuItem;
    mniName1: TTBItem;
    mniName2: TTBItem;
    mniName3: TTBItem;
    mniName4: TTBItem;
    mniName5: TTBItem;
    mniLockList: TTBItem;
    mniGameSetup: TTBItem;
    mniOptions: TTBItem;
    mniHelp: TTBSubmenuItem;
    mniAbout: TTBItem;
    mniFilterSetup: TTBItem;
    mniCopyInfo: TMenuItem;
    N1: TTBSeparatorItem;
    N2: TTBSeparatorItem;
    N3: TTBSeparatorItem;
    N4: TTBSeparatorItem;
    tbrSeparator2: TTBSeparatorItem;
    tbrSeparator3: TTBSeparatorItem;
    tbrSeparator4: TTBSeparatorItem;
    tbrSeparator5: TTBSeparatorItem;
    tbrAddServer: TTBItem;
    tbrRemoveServer: TTBItem;
    tbrSeparator1: TTBSeparatorItem;
    tbrRefreshAll: TTBItem;
    tbrRefreshSelected: TTBItem;
    tbrGameSetup: TTBItem;
    tbrOptions: TTBItem;
    tbcboGame: TTBControlItem;
    tbrHelp: TTBItem;
    tbrFilterSetup: TTBItem;
    tbrcboFilter: TTBControlItem;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    cboGame: TComboBox;
    cboFilter: TComboBox;
    mniHelpMe: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    mniHelpQuickStart: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbrAddServerClick(Sender: TObject);
    procedure tbrRefreshAllClick(Sender: TObject);
    procedure tbrRefreshSelectedClick(Sender: TObject);
    procedure tbrRemoveServerClick(Sender: TObject);
    procedure tbrGameSetupClick(Sender: TObject);
    procedure tbrOptionsClick(Sender: TObject);
    procedure mniAboutClick(Sender: TObject);
    procedure mniExitClick(Sender: TObject);
    procedure mniJoinClick(Sender: TObject);
    procedure mniSpecClick(Sender: TObject);
    procedure mniPwdJoinClick(Sender: TObject);
    procedure mniPwdSpecClick(Sender: TObject);
    procedure mniCopyIPClick(Sender: TObject);
    procedure mniDNSIPClick(Sender: TObject);
    procedure mniServerListImportClick(Sender: TObject);
    procedure mniServerListExportClick(Sender: TObject);
    procedure mniName1Click(Sender: TObject);
    procedure mniName2Click(Sender: TObject);
    procedure mniName3Click(Sender: TObject);
    procedure mniName4Click(Sender: TObject);
    procedure mniName5Click(Sender: TObject);
    procedure mniIPDNSClick(Sender: TObject);
    procedure mniTrayExitClick(Sender: TObject);
    procedure mniTrayRestoreClick(Sender: TObject);
    procedure mniLockListClick(Sender: TObject);
    procedure mniCustomJoinClick(Sender: TObject);
    procedure cboGameChange(Sender: TObject);
    procedure lvwServerSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvwServerColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvwServerContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure lvwServerDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lvwServerDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure lvwServerDblClick(Sender: TObject);
    procedure lvwPlayerColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvwPlayerCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvwPlayerCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure cboGameDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure tbrFilterSetupClick(Sender: TObject);
    procedure cboFilterChange(Sender: TObject);
    procedure tbrHelpClick(Sender: TObject);
    procedure mniCopyInfoClick(Sender: TObject);
    procedure mniHelpQuickStartClick(Sender: TObject);
  public
    gameData: Array[0..7] of TGameData; //GAME_ADD 0:VQ, 1:QW, 2:Q2, 3:Q3, 4:HL, 5:WF, 6:T1, 7:T2
    nameData: Array[0..4] of TNameData;
    serverData: Array[0..1023] of TServerData; //all server details
    options: TOptions;
    activeGame: Integer;
    ServerColOrder: Array[0..5] of Integer; //serverColOrder(0: Server Name, 1: Ping, 2: Addy, 3: Map, 4: Players, 5: Game/Mod)
    PlayerColOrder: Array[0..5] of Integer; //playerColOrder(0: Player Name, 1: Frags, 2: Skin, 3: Ping, 4: Connect, 5: UserID)
    ServerSortAsc: Boolean;
    ServerSortCol: Integer;
    PlayerSortAsc: Boolean;
    PlayerSortCol: Integer;
    PlayerSortName: Integer;
    procedure SetServerItem(index: Integer; column: Integer; data: String); //adds data to lvwServer
    procedure SetPlayerItem(index: Integer; column: Integer; data: String); //adds data to lvwPlayer
    procedure Display(index: Integer);
    procedure SortPlayer;
    procedure SortServer;
    procedure SetGameBox;
    procedure SetFilterBox;
    procedure IsGame;
    procedure UpdateList(filterServer: Boolean);
    function ShellOpenFile(hWnd: HWND; operation, fileName, params, defaultDir: String; min: Boolean): Integer;
    function GetPlayerName(b: Boolean): String;
    function GetServerItem(index: Integer; column: Integer): String; //returns data from lvwServer
    function FilterItem(s: TServerData; filterServer: Boolean): Boolean;
  private
    notifyIconData : TNotifyIconData;
    procedure ShellIcon(var Msg: TMessage); message WM_ShellIcon;
    procedure MinimizeToTray(Sender: TObject);
    procedure Status(text: String);
    procedure LaunchGame(cl1, cl2, p1, p2, s, p, n, tfn, tfc: String; tf, spc, pwd: Boolean);
    procedure CheckNameMenu(index: Integer);
    function ParsePercent(line, sFrom, sTo: String): String; //returns parsed %s/%p string
    function ParseGamePercent(line, s, p, sp, pw, n: String): String;
    function ParseICQPercent(line, s, p, h, g, d, t: String): String;
    function IPToHost(IPAddr: String): String;
  end;

var
  frmMain: TfrmMain;

const
  FIZZ_VERSION: String = '1.8.0.1'; //Version changes: Project->Options...->Version Info and fizz.txt


implementation

uses Server, Player, Disk, AddServer, GameSetup, Options, Splash, About, Join, Refresh, Filter;

{$R *.dfm}

procedure TfrmMain.Status(text: String);
begin
  StatusBar.Panels[0].Text := text;
  StatusBar.Refresh;
end;

procedure TfrmMain.SetServerItem(index: integer; column: integer; data: string); //index - place in list, column - column: -1 for caption, 0 - x for subitems, data - stuff to add
begin
  if column > 5 then
    lvwServer.Items[index].SubItems[column-1] := data
  else begin
    if serverColOrder[column] = -999 then Exit; //column is hidden, do nothing
    if serverColOrder[column] = -1 then
      lvwServer.Items[index].Caption := data
    else
      lvwServer.Items[index].SubItems[serverColOrder[column]] := data;
  end;
end;

function TfrmMain.GetServerItem(index: integer; column: integer): string;
begin
  if column > 5 then
    result := lvwServer.Items[index].SubItems[column-1]
  else begin
    if serverColOrder[column] = -999 then Exit; //column is hidden, do nothing
    if serverColOrder[column] = -1 then
      result := lvwServer.Items[index].Caption
    else
      result := lvwServer.Items[index].SubItems[serverColOrder[column]];
  end;
end;

procedure TfrmMain.SetPlayerItem(index: integer; column: integer; data: string); //index - place in list, column - column: -1 for caption, 0 - x for subitems, data - stuff to add
begin
  if column > 5 then
    lvwPlayer.Items[index].SubItems[column] := data
  else begin
    if playerColOrder[column] = -999 then Exit; //column is hidden, do nothing
    if playerColOrder[column] = -1 then
      lvwPlayer.Items[index].Caption := data
    else
      lvwPlayer.Items[index].SubItems[playerColOrder[column]] := data;
  end;
end;

function CompareInt(i1: Integer; i2: Integer): Integer;
begin
  if i1 > i2 then
    Result := 1
  else
    Result := -1;
  if i1 = i2 then Result := 0;
end;

function ServerSortByColumn(Item1, Item2: TListItem; Data: Integer): Integer; Stdcall;
var
  s1, s2: String;
  i1, i2: Integer;
begin
  if Data = 0 then begin
    s1 := Item1.Caption;
    s2 := Item2.Caption;
  end
  else begin
    s1 := Item1.SubItems[Data-1];
    s2 := Item2.SubItems[Data-1];
  end;
  if (Data = frmMain.serverColOrder[4]+1) and //players
     (s1 <> '') and
     (s2 <> '') then begin
    i1 := StrToInt(LeftStr(s1, Pos('/', s1)-1));
    i2 := StrToInt(LeftStr(s2, Pos('/', s2)-1));
    Result := CompareInt(i1, i2)
  end
  else
    Result := CompareText(s1, s2);
  if frmMain.serverSortAsc then Result := -Result;
end;

function PlayerSortByColumn(Item1, Item2: TListItem; Data: Integer): Integer; Stdcall;
var
  s1, s2: String;
  i1, i2: Integer;
begin
  Result := 0;
  if (Data = frmMain.playerColOrder[0]+1) and (frmMain.activeGame in [0, 1]) then begin //QW
    case frmMain.playerSortName of
      1,2: begin
           s1 := Item1.Caption;
           s2 := Item2.Caption;
           Result := CompareText(s1, s2);
         end;
      3,4: begin
           i1 := StrToInt(Item1.SubItems[6]);
           i2 := StrToInt(Item2.SubItems[6]);
           Result := CompareInt(i1, i2);
         end;
      5,6: begin
           i1 := StrToInt(Item1.SubItems[7]);
           i2 := StrToInt(Item2.SubItems[7]);
           Result := CompareInt(i1, i2);
         end;
    end;
  end
  else begin
    if Data = 0 then begin
      s1 := Item1.Caption;
      s2 := Item2.Caption;
    end
    else begin
      s1 := Item1.SubItems[Data-1];
      s2 := Item2.SubItems[Data-1];
    end;
    if (Data in [frmMain.playerColOrder[1]+1,
                 frmMain.playerColOrder[3]+1,
                 frmMain.playerColOrder[4]+1,
                 frmMain.playerColOrder[5]+1]) and
       (s1 <> '') and
       (s2 <> '') then begin
      i1 := StrToInt(s1);
      i2 := StrToInt(s2);
      Result := CompareInt(i1, i2)
    end
    else
      Result := CompareText(s1, s2);
  end;
  if frmMain.playerSortAsc then Result := -Result;
end;

function TfrmMain.GetPlayerName(b: Boolean): String;
begin
  if b then begin
    if mniName1.Checked then Result := nameData[0].Name;
    if mniName2.Checked then Result := nameData[1].Name;
    if mniName3.Checked then Result := nameData[2].Name;
    if mniName4.Checked then Result := nameData[3].Name;
    if mniName5.Checked then Result := nameData[4].Name;
  end
  else begin
    if mniName1.Checked then Result := nameData[0].DisplayName;
    if mniName2.Checked then Result := nameData[1].DisplayName;
    if mniName3.Checked then Result := nameData[2].DisplayName;
    if mniName4.Checked then Result := nameData[3].DisplayName;
    if mniName5.Checked then Result := nameData[4].DisplayName;
  end;
end;

function TfrmMain.ParsePercent(line, sFrom, sTo: String): String;
var
  tmp: String;
  i, j: Integer;
begin
  if Pos('%', line) > 0 then begin //anything to do
    i := 1;
    while i <= Length(line) do begin
      if line[i] = '%' then begin
        if Copy(line, i, Length(sFrom)) = sFrom then begin
          for j := 1 to Length(sTo) do
            tmp := tmp + sTo[j];
          Inc(i, Length(sFrom)-1);
        end
        else
          tmp := tmp + '%';
      end
      else
        tmp := tmp + line[i];
      Inc(i);
    end;
    Result := tmp;
  end
  else
    Result := line;
end;

function TfrmMain.ParseGamePercent(line, s, p, sp, pw, n: String): String; //ip,port,spec,pass,name
var
  newLine: String;
begin
  newLine := line;
  newLine := ParsePercent(newLine, '%s%', s);
  newLine := ParsePercent(newLine, '%p%', p);
  newLine := ParsePercent(newLine, '%sp%', sp);
  newLine := ParsePercent(newLine, '%pw%', pw);
  newLine := ParsePercent(newLine, '%n%', n);
  Result := newLine;
end;

function TfrmMain.ParseICQPercent(line, s, p, h, g, d, t: String): String; //ip,port,hostname,game,date,time
var
  newLine: String;
begin
  newLine := line;
  newLine := ParsePercent(newLine, '%s%', s);
  newLine := ParsePercent(newLine, '%p%', p);
  newLine := ParsePercent(newLine, '%h%', h);
  newLine := ParsePercent(newLine, '%g%', g);
  newLine := ParsePercent(newLine, '%d%', d);
  newLine := ParsePercent(newLine, '%t%', t);
  Result := newLine;
end;

function TfrmMain.ShellOpenFile(hWnd: HWND; operation, fileName, params, defaultDir: String; min: Boolean): Integer;
begin
  if min then
    Result := ShellExecute(hWnd, PChar(operation), PChar(fileName), PChar(params), PChar(defaultDir), SW_MINIMIZE)
  else
    Result := ShellExecute(hWnd, PChar(operation), PChar(fileName), PChar(params), PChar(defaultDir), SW_SHOWDEFAULT);
  case Result of
    0:
      raise Exception.Create('The operating system is out of memory or resources ('+fileName+')');
    ERROR_FILE_NOT_FOUND:
      raise Exception.Create('Can''t find file "'+fileName+'"');
    ERROR_PATH_NOT_FOUND:
      raise Exception.Create('The specified path was not found ('+fileName+')');
    ERROR_BAD_FORMAT:
      raise Exception.Create('The .EXE file is invalid (non-Win32 .EXE or error in .EXE image) ('+fileName+')');
    SE_ERR_ACCESSDENIED:
      raise Exception.Create('The operating system denied access to the specified file ('+fileName+')');
    SE_ERR_ASSOCINCOMPLETE:
      raise Exception.Create('The filename association is incomplete or invalid ('+fileName+')');
    SE_ERR_DDEBUSY:
      raise Exception.Create('The DDE transaction could not be completed because other DDE transactions were being processed ('+fileName+')');
    SE_ERR_DDEFAIL:
      raise Exception.Create('The DDE transaction failed ('+fileName+')');
    SE_ERR_DDETIMEOUT:
      raise Exception.Create('The DDE transaction could not be completed because the request timed out ('+fileName+')');
    SE_ERR_DLLNOTFOUND:
      raise Exception.Create('The specified dynamic-link library was not found ('+fileName+')');
    SE_ERR_NOASSOC:
      raise Exception.Create('There is no application associated with the given filename extension ('+fileName+')');
    SE_ERR_OOM:
      raise Exception.Create('There was not enough memory to complete the operation ('+fileName+')');
    SE_ERR_SHARE:
      raise Exception.Create('A sharing violation occurred ('+fileName+')');
  end;
end;

procedure TfrmMain.mniAboutClick(Sender: TObject);
begin
  Application.CreateForm(TfrmAbout, frmAbout);
  frmAbout.lblFizz.Caption := 'Fizz v' + FIZZ_VERSION;
  frmAbout.ShowModal;
  frmAbout.Release;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Disk.LoadSettings;
  StatusBar.Panels[1].Text := GetPlayerName(False);
  Application.ShowHint := True;
  with NotifyIconData do begin
    cbSize := SizeOf(NotifyIconData);
    Wnd := frmMain.Handle;
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ShellIcon;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, Application.Title);
  end;
  Application.OnMinimize := MinimizeToTray;
  Application.HelpFile := ChangeFileExt(Application.ExeName, '.hlp');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Disk.SaveSettings;
end;

procedure TfrmMain.tbrAddServerClick(Sender: TObject);
begin
  if activeGame > -1 then begin
    Application.CreateForm(TfrmAddServer, frmAddServer);
    frmAddServer.Caption := 'Add Server [' + cboGame.Text + ']';
    frmAddServer.ShowModal;
    frmAddServer.Release;
    UpdateList(True);
    Status('Ready');
  end;
end;

procedure TfrmMain.tbrRemoveServerClick(Sender: TObject);
var
  i, j, k: Integer;
  item: TListItem;
begin
  if MessageDlg('Delete selected server(s)?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then Exit;
  item := lvwServer.Selected;
  while item <> nil do begin
    item := lvwServer.GetNextItem(item, sdAll, [isSelected]);
    j := StrToInt(GetServerItem(lvwServer.Selected.Index, 6));
    i := 0;
    while (serverData[i].ServerName <> '') and (i <= 1023) do
      Inc(i);
    Dec(i);
    if i = j then //last in list
      serverData[i].ServerName := ''
    else begin //somewhere else, swap it for last in list
      serverData[j] := serverData[i];
      serverData[i].ServerName := '';
      for k := 0 to lvwServer.Items.Count-1 do
        if GetServerItem(k, 6) = IntToStr(i) then
          SetServerItem(k, 6, IntToStr(j));
    end;
    lvwServer.Items.Delete(lvwServer.Selected.Index);
  end;
  lvwPlayer.Items.BeginUpdate;
  lvwPlayer.Items.Clear;
  lvwPlayer.Items.EndUpdate;
  lvwRule.Items.BeginUpdate;
  lvwRule.Items.Clear;
  lvwRule.Items.EndUpdate;
end;

procedure TfrmMain.Display(index: Integer);
var
  i: Integer;
begin
  lvwPlayer.Items.BeginUpdate;
  lvwPlayer.Items.Clear;
  i := StrToInt(GetServerItem(index, 6));
  case activeGame of //GAME_ADD
    0: VQ_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
    1: QW_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
    2: Q2_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
    3: Q3_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
    4: HL_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
    5: WF_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
    6: T1_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
    7: T2_ParsePlayers(index, serverData[i].RuleData, serverData[i].PlayerData);
  end;
  lvwPlayer.Items.EndUpdate;
  lvwRule.Items.BeginUpdate;
  lvwRule.Items.Clear;
  DisplayRules(index, serverData[i].RuleData);
  lvwRule.Items.EndUpdate;
end;

procedure TfrmMain.lvwServerSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and (lvwServer.SelCount = 1) then Display(Item.Index);
end;

procedure TfrmMain.tbrRefreshAllClick(Sender: TObject);
var
  i, j: Integer;
begin
  for i := 0 to lvwServer.Items.Count-1 do //refresh icon
    lvwServer.Items[i].ImageIndex := activeGame * 10;
  with RefreshList.Create(True) do begin
    FreeOnTerminate := True;
    i := 0;
    j := 0;
    while (serverData[i].ServerName <> '') and (i <= 1023) do begin
      if (serverData[i].Game = activeGame) then begin
        refreshList[j].Index := i;
        refreshList[j].Address := serverData[i].IP;
        refreshList[j].Port := serverData[i].Port;
        Inc(j);
      end;
      Inc(i);
    end;
    qrGame := activeGame;
    qrTimeOut := options.TimeOut;
    refreshNum := options.RefreshNum;
    numServers := i;
    Resume; //resume thread
  end;
end;

procedure TfrmMain.tbrRefreshSelectedClick(Sender: TObject);
var
  item: TListItem;
  i, j: Integer;
begin
  j := 0;
  item := lvwServer.Selected;
  with RefreshList.Create(True) do begin
    FreeOnTerminate := True;
    while item <> nil do begin
      lvwServer.Items[item.Index].ImageIndex := 10 * activeGame; //icon
      i := StrToInt(GetServerItem(item.Index, 6)); //tag (place in array)
      refreshList[j].Index := i; //tag
      refreshList[j].Address := serverData[i].IP;
      refreshList[j].Port := serverData[i].Port;
      Inc(j);
      item := lvwServer.GetNextItem(item, sdAll, [isSelected]);
    end;
    qrGame := activeGame;
    qrTimeOut := options.TimeOut;
    refreshNum := options.RefreshNum;
    Resume; //resume thread
  end;
end;

procedure TfrmMain.lvwServerColumnClick(Sender: TObject; Column: TListColumn);
begin
  Column.Tag := 1 - Column.Tag;
  serverSortAsc := Column.Tag = 1;
  lvwServer.CustomSort(@ServerSortByColumn, Column.Index);
  serverSortCol := Column.Index;
end;

procedure TfrmMain.lvwPlayerColumnClick(Sender: TObject; Column: TListColumn);
begin
  if playerColOrder[0]+1 = Column.Index then begin
    case playerSortName of
      1,3,5: playerSortAsc := True;
      2,4,6: playerSortAsc := False;
    end;
    Column.Tag := playerSortName;
    if playerSortName = 6 then
      playerSortName := 1
    else
      Inc(playerSortName);
  end
  else begin
    Column.Tag := 1 - Column.Tag;
    playerSortAsc := Column.Tag = 1;
  end;
  lvwPlayer.CustomSort(@PlayerSortByColumn, Column.Index);
  playerSortCol := Column.Index;
end;

procedure TfrmMain.SortPlayer;
begin
  lvwPlayer.CustomSort(@PlayerSortByColumn, playerSortCol);
end;

procedure TfrmMain.SortServer;
begin
  lvwServer.CustomSort(@ServerSortByColumn, serverSortCol);
end;

procedure TfrmMain.LaunchGame(cl1, cl2, p1, p2, s, p, n, tfn, tfc: String; tf, spc, pwd: Boolean);
var
  pw, sp, icqmsg: String;
  createFile: TextFile;
  b: Boolean;
  hMod: THandle;
  i: Integer;
  ICQAPICall_SetOwnerState: function (iState: integer): BOOL; stdcall;//external 'ICQMAPI.dll';
  ICQAPICall_SetLicenseKey: function ( pszName: PChar; pszPassword: PChar; pszLicense: PChar): BOOL; stdcall;
begin
  if pwd then begin
    b := InputQuery('Join '+s+':'+p, 'Enter server password', pw);
    if not b then pw := '""';
  end
  else
    pw := '""';
  if spc then
    if pwd then begin
      sp := pw;
      pw := '""';
    end
    else
      sp := '1'
  else
    sp := '""'; //lets clear it not set to 0

  if tf then begin
    AssignFile(createFile, gameData[activeGame].TextFileName);
    try
      ReWrite(createFile);
      WriteLn(createFile, ParseGamePercent(tfc, s, p, sp, pw, n));
    finally
      CloseFile(createFile);
    end;
  end;
  if options.ICQIntegration then begin
    i := StrToInt(GetServerItem(lvwServer.Selected.Index, 6));
    icqmsg := ParseICQPercent(options.ICQMessage,
                              serverData[i].IP,
                              IntToStr(serverData[i].Port),
                              serverData[i].ServerName,
                              serverData[i].GameMod,
                              DateToStr(Now),
                              TimeToStr(Now));
    hMod := LoadLibrary('ICQMAPI.dll'); //load dll
    if hMod >= 32 then begin
      ICQAPICall_SetLicenseKey := GetProcAddress(hMod, 'ICQAPICall_SetLicenseKey'); //licence
      ICQAPICall_SetLicenseKey(PChar('bliP'), PChar('fizz_f5y7uj'), PChar('8B0A1B85F8C8E673'));
      ICQAPICall_SetOwnerState := GetProcAddress(hMod, 'ICQAPICall_SetOwnerState'); //set state
      ICQAPICall_SetOwnerState(options.ICQState);
      if options.ICQState in [1..5] then begin //message
        Keybd_Event(Vk_Tab, 1, 0, 0); //select messagebox
        Keybd_Event(Vk_Tab, 1, KEYEVENTF_KEYUP, 0);
        for i := 1 to Length(icqmsg) do //type message
          if icqmsg[i] in ['A'..'Z', '!'..'&', '('..'+', ':', '<', '>'..'@', '{'..'~', '^'] then begin //uppercase
            Keybd_Event(VK_SHIFT, 1, 0,0);
            Keybd_Event(VkKeyScan(icqmsg[i]), 1, 0, 0);
            Keybd_Event(VkKeyScan(icqmsg[i]), 1, KEYEVENTF_KEYUP, 0);
            Keybd_event(VK_SHIFT, 1, KEYEVENTF_KEYUP, 0);
          end
          else begin //lowercase
            Keybd_Event(VkKeyScan(icqmsg[i]), 1, 0, 0);
            Keybd_Event(VkKeyScan(icqmsg[i]), 1, KEYEVENTF_KEYUP, 0);
          end;
        Keybd_Event(Vk_Tab, 1, 0, 0); //select button
        Keybd_Event(Vk_Tab, 1, KEYEVENTF_KEYUP, 0);
        Keybd_Event(Vk_Tab, 1, 0, 0);
        Keybd_Event(Vk_Tab, 1, KEYEVENTF_KEYUP, 0);
        Keybd_Event(VK_RETURN, 1, 0, 0); //press it
        Keybd_Event(VK_RETURN, 1, KEYEVENTF_KEYUP, 0);
      end;
      FreeLibrary(hMod);
    end
    else
      MessageDlg('Error: could not find ICQMAPI.DLL, get it from files section at http://nisda.net/', mtError, [mbOk], 0);
  end;
  if options.WhenLaunchGameDo in [2,3] then Application.Minimize;//ShowWindow(Application.Handle, SW_MINIMIZE);
  if cl2 <> '' then
    ShellOpenFile(0, 'open', PChar(cl2), PChar(ParseGamePercent(p1, s, p, sp, pw, n)), PChar(ExtractFilePath(cl2)), True);
  if cl1 <> '' then
    ShellOpenFile(0, 'open', PChar(cl1), PChar(ParseGamePercent(p1, s, p, sp, pw, n)), PChar(ExtractFilePath(cl1)), False);
  if options.WhenLaunchGameDo = 3 then Application.Terminate;
end;

procedure TfrmMain.mniExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.lvwServerContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  if (lvwServer.Items.Count = 0) or not (lvwServer.SelCount >= 1) then begin
    mniJoin.Enabled := False;
    mniSpec.Enabled := False;
    mniPassword.Enabled := False;
    mniDNSIP.Enabled := False;
    mniIPDNS.Enabled := False;
    mniCopyIP.Enabled := False;
    mniCustomJoin.Enabled := False;
    mniCopyInfo.Enabled := False;
  end
  else begin
    mniSpec.Enabled := True;
    mniPwdSpec.Enabled := True;
    mniJoin.Enabled := True;
    mniPassword.Enabled := True;
    mniDNSIP.Enabled := True;
    mniIPDNS.Enabled := True;
    mniCopyIP.Enabled := True;
    mniCustomJoin.Enabled := True;
    mniCopyInfo.Enabled := True;
  end;
end;

procedure TfrmMain.lvwServerDblClick(Sender: TObject);
begin
  if (options.DblClickToLaunch) and (lvwServer.Items.Count > 0) and (lvwServer.SelCount = 1) then
    LaunchGame(gameData[activeGame].CommandLine1,
               gameData[activeGame].CommandLine2,
               gameData[activeGame].Param1,
               gameData[activeGame].Param2,
               serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].IP,
               IntToStr(serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].Port),
               GetPlayerName(True),
               gameData[activeGame].TextFileName,
               gameData[activeGame].TextFileContents,
               gameData[activeGame].CreateTextFile,
               False,
               False);
end;

procedure TfrmMain.mniJoinClick(Sender: TObject);
begin
  LaunchGame(gameData[activeGame].CommandLine1,
             gameData[activeGame].CommandLine2,
             gameData[activeGame].Param1,
             gameData[activeGame].Param2,
             serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].IP,
             IntToStr(serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].Port),
             GetPlayerName(True),
             gameData[activeGame].TextFileName,
             gameData[activeGame].TextFileContents,
             gameData[activeGame].CreateTextFile,
             False,
             False);
end;

procedure TfrmMain.mniSpecClick(Sender: TObject);
begin
  LaunchGame(gameData[activeGame].CommandLine1,
             gameData[activeGame].CommandLine2,
             gameData[activeGame].Param1,
             gameData[activeGame].Param2,
             serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].IP,
             IntToStr(serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].Port),
             GetPlayerName(True),
             gameData[activeGame].TextFileName,
             gameData[activeGame].TextFileContents,
             gameData[activeGame].CreateTextFile,
             True,
             False);
end;

procedure TfrmMain.mniPwdJoinClick(Sender: TObject);
begin
  LaunchGame(gameData[activeGame].CommandLine1,
             gameData[activeGame].CommandLine2,
             gameData[activeGame].Param1,
             gameData[activeGame].Param2,
             serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].IP,
             IntToStr(serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].Port),
             GetPlayerName(True),
             gameData[activeGame].TextFileName,
             gameData[activeGame].TextFileContents,
             gameData[activeGame].CreateTextFile,
             False,
             True);
end;

procedure TfrmMain.mniPwdSpecClick(Sender: TObject);
begin
  LaunchGame(gameData[activeGame].CommandLine1,
             gameData[activeGame].CommandLine2,
             gameData[activeGame].Param1,
             gameData[activeGame].Param2,
             serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].IP,
             IntToStr(serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].Port),
             GetPlayerName(True),
             gameData[activeGame].TextFileName,
             gameData[activeGame].TextFileContents,
             gameData[activeGame].CreateTextFile,
             True,
             True);
end;

procedure TfrmMain.mniCopyIPClick(Sender: TObject);
begin
  clipboard.AsText := serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].IP + ':' +
                      IntToStr(serverData[StrToInt(GetServerItem(lvwServer.Selected.Index, 6))].Port)
end;

function TfrmMain.IPToHost(IPAddr: String): String;
var
  sockAddrIn: TSockAddrIn;
  hostEnt: PHostEnt;
  WSAData: TWSAData;
begin
  WSAStartup($101, WSAData);
  try
    sockAddrIn.sin_addr.s_addr := inet_addr(PChar(IPAddr));
    HostEnt := GetHostByAddr(@sockAddrIn.sin_addr.S_addr, 4, AF_INET);
    if Assigned(hostEnt) then
      Result := StrPas(hostent^.h_name)
    else
      Result := IPAddr;
  finally
    WSACleanup;
  end;
end;

procedure TfrmMain.mniDNSIPClick(Sender: TObject);
var
  item: TListItem;
  i: Integer;
  s: String;
begin
  item := lvwServer.Selected;
  while item <> nil do begin
    i := StrToInt(GetServerItem(item.Index, 6));
    s := serverData[i].IP+':'+IntToStr(serverData[i].Port);
    Status('DNS to IP: '+s);
    SetServerItem(item.Index, 2, s);
    serverData[i].Address := s;
    item := lvwServer.GetNextItem(item, sdAll, [isSelected]);
  end;
  Status('Ready');
end;

procedure TfrmMain.mniIPDNSClick(Sender: TObject);
var
  item: TListItem;
  i: Integer;
  s: String;
begin
  item := lvwServer.Selected;
  while item <> nil do begin
    i := StrToInt(GetServerItem(item.Index, 6));
    s := IPToHost(serverData[i].IP)+':'+IntToStr(serverData[i].Port);
    Status('IP to DNS: '+s);
    SetServerItem(item.Index, 2, s);
    serverData[i].Address := s;
    item := lvwServer.GetNextItem(item, sdAll, [isSelected]);
  end;
  Status('Ready');
end;

procedure TfrmMain.mniServerListImportClick(Sender: TObject);
begin
  dlgOpen.FileName := 'server.fzs';
  dlgOpen.Filter := 'Fizz Server List|*.fzs|All Files|*.*';
  dlgOpen.Title := 'Server List Import';
  if dlgOpen.Execute then LoadServerList(dlgOpen.FileName);
end;

procedure TfrmMain.mniServerListExportClick(Sender: TObject);
begin
  dlgSave.FileName := 'server.fzs';
  dlgSave.Filter := 'Fizz Server List|*.fzs|All Files|*.*';
  dlgSave.Title := 'Server List Export';
  if dlgSave.Execute then SaveServerList(dlgSave.FileName);
  Status('Export Complete');
end;

procedure TfrmMain.CheckNameMenu(index: Integer);
begin
  mniName1.Checked := False;
  mniName2.Checked := False;
  mniName3.Checked := False;
  mniName4.Checked := False;
  mniName5.Checked := False;
  case index of
    1: mniName1.Checked := True;
    2: mniName2.Checked := True;
    3: mniName3.Checked := True;
    4: mniName4.Checked := True;
    5: mniName5.Checked := True;
  end;
  frmMain.StatusBar.Panels[1].Text := GetPlayerName(False);
end;

procedure TfrmMain.mniName1Click(Sender: TObject);
begin
  if nameData[0].Enabled then CheckNameMenu(1);
end;

procedure TfrmMain.mniName2Click(Sender: TObject);
begin
  if nameData[1].Enabled then CheckNameMenu(2);
end;

procedure TfrmMain.mniName3Click(Sender: TObject);
begin
  if nameData[2].Enabled then CheckNameMenu(3);
end;

procedure TfrmMain.mniName4Click(Sender: TObject);
begin
  if nameData[3].Enabled then CheckNameMenu(4);
end;

procedure TfrmMain.mniName5Click(Sender: TObject);
begin
  if nameData[4].Enabled then CheckNameMenu(5);
end;

procedure TfrmMain.lvwServerDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  dragItem, dropItem, currentItem, nextItem: TListItem;
begin
  if Sender = Source then
    with TListView(Sender) do begin
      dropItem := GetItemAt(X,Y);
      currentItem := Selected;
      while currentItem <> nil do begin
        nextItem := GetNextItem(currentItem, SdAll, [IsSelected]);
        if dropItem = nil then dragItem := Items.Add else dragItem := Items.Insert(dropItem.Index);
        dragItem.Assign(currentItem);
        currentItem.Free;
        currentItem := nextItem;
      end;
    end;
end;

procedure TfrmMain.lvwServerDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = lvwServer;
end;

procedure TfrmMain.mniLockListClick(Sender: TObject);
begin
  mniLockList.Checked := not mniLockList.Checked;
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

procedure TfrmMain.tbrGameSetupClick(Sender: TObject);
var
  i: Integer;
begin
  Application.CreateForm(TfrmGameSetup, frmGameSetup);
  for i := 0 to 7 do begin //GAME_ADD
    with frmGameSetup.tmpGameData[i] do begin
      CommandLine1 := GameData[i].CommandLine1;
      CommandLine2 := GameData[i].CommandLine2;
      Param1 := GameData[i].Param1;
      Param2 := GameData[i].Param2;
      CreateTextFile := GameData[i].CreateTextFile;
      TextFileName := GameData[i].TextFileName;
      TextFileContents := GameData[i].TextFileContents;
      Installed := GameData[i].Installed;
    end;
  end;
  with frmGameSetup do begin
    txtCmdLine1.Text := tmpGameData[7].CommandLine1;
    txtCmdLine2.Text := tmpGameData[7].CommandLine2;
    txtParam1.Text := tmpGameData[7].Param1;
    txtParam2.Text := tmpGameData[7].Param2;
    chkFile.Checked := tmpGameData[7].CreateTextFile;
    txtFileName.Text := tmpGameData[7].TextFileName;
    mmoFileContents.Text := tmpGameData[7].TextFileContents;
    chkInstalled.Checked := tmpGameData[7].Installed;
    Last := 7;
    cbxGame.ItemIndex := 0;
  end;
  if frmGameSetup.ShowModal = mrOK then begin
    SetGameBox;
    activeGame := -1;
    if cboGame.Text = 'Quake' then activeGame := 0; //GAME_ADD
    if cboGame.Text = 'QuakeWorld' then activeGame := 1;
    if cboGame.Text = 'Quake 2' then activeGame := 2;
    if cboGame.Text = 'Quake 3 Arena' then activeGame := 3;
    if cboGame.Text = 'Half-Life' then activeGame := 4;
    if cboGame.Text = 'Wolfenstein' then activeGame := 5;
    if cboGame.Text = 'Tribes' then activeGame := 6;
    if cboGame.Text = 'Tribes 2' then activeGame := 7;
    IsGame;
    UpdateList(True);
  end;
  frmGameSetup.Release;
end;

procedure TfrmMain.tbrOptionsClick(Sender: TObject);
var
  i: Integer;
const
  SERVERCOLNAME: Array[0..5] of String = ('Server Name', 'Ping', 'Address', 'Map', 'Players', 'Game/Mod'); //also in LoadSettings
  PLAYERCOLNAME: Array[0..5] of String = ('Player Name', 'Frags', 'Skin', 'Ping', 'Connect', 'User ID');
begin
  Application.CreateForm(TfrmOptions, frmOptions);
  with frmOptions do begin
    lstServerColOrder.Items.Clear;
    for i := 0 to 5 do begin
      lstServerColOrder.Items.Add(SERVERCOLNAME[i]);
      if serverColOrder[i] <> -999 then
        lstServerColOrder.Checked[i] := True
      else
        lstServerColOrder.Checked[i] := False;
    end;
    lstPlayerColOrder.Items.Clear;
    for i := 0 to 5 do begin
      lstPlayerColOrder.Items.Add(PLAYERCOLNAME[i]);
      if playerColOrder[i] <> -999 then
        lstPlayerColOrder.Checked[i] := True
      else
        lstPlayerColOrder.Checked[i] := False;
    end;
    if nameData[0].Enabled then begin
      txtDisplayName1.Text := nameData[0].DisplayName;
      txtName1.Text := nameData[0].Name;
    end;
    if nameData[1].Enabled then begin
      txtDisplayName2.Text := nameData[1].DisplayName;
      txtName2.Text := nameData[1].Name;
    end;
    if nameData[2].Enabled then begin
      txtDisplayName3.Text := nameData[2].DisplayName;
      txtName3.Text := nameData[2].Name;
    end;
    if nameData[3].Enabled then begin
      txtDisplayName4.Text := nameData[3].DisplayName;
      txtName4.Text := nameData[3].Name;
    end;
    if nameData[4].Enabled then begin
      txtDisplayName5.Text := nameData[4].DisplayName;
      txtName5.Text := nameData[4].Name;
    end;
    txtTimeOut.Text := IntToStr(options.TimeOut);
    txtRefreshNum.Text := IntToStr(options.RefreshNum);
    chkDblLaunch.Checked := options.DblClickToLaunch;
    case options.WhenLaunchGameDo of
      1: radJoinNothing.Checked := True;
      2: radJoinMinimize.Checked := True;
      3: radJoinClose.Checked := True;
    else
      radJoinNothing.Checked := True;
    end;
    chkIntICQ.Checked := options.ICQIntegration;
    chkMinimizeTray.Checked := options.MinimizeToTray;
    cboICQState.ItemIndex := options.ICQState;
    txtICQMsg.Text := options.ICQMessage;
    cboICQState.Enabled := chkIntICQ.Checked;
    txtICQMsg.Enabled := chkIntICQ.Checked;
    lblSetMode.Enabled := chkIntICQ.Checked;
    lblMessage.Enabled := chkIntICQ.Checked;
  end;
  frmOptions.ShowModal;
  frmOptions.Release;
end;

procedure TfrmMain.mniCustomJoinClick(Sender: TObject);
var
  ip, port, path, n: String;
  index: Integer;
  searchRec: TSearchRec;
begin
  index := lvwServer.Selected.Index;
  ip := serverData[StrToInt(GetServerItem(index, 6))].IP;
  port := IntToStr(serverData[StrToInt(GetServerItem(index, 6))].Port);
  Application.CreateForm(TfrmJoin, frmJoin);
  with frmJoin do begin
    cboCmdLine1.Text := gameData[activeGame].CommandLine1;
    txtCmdLine2.Text := gameData[activeGame].CommandLine2;
    txtParam1.Text := gameData[activeGame].Param1;
    txtParam2.Text := gameData[activeGame].Param2;
    chkFile.Checked := gameData[activeGame].CreateTextFile;
    txtFileName.Text := gameData[activeGame].TextFileName;
    mmoFileContents.Lines.Add(gameData[activeGame].TextFileContents);
    n := GetPlayerName(False);
    if n <> '' then
      Caption := 'Custom Join - '+n+', '+ip+':'+port
    else
      Caption := 'Custom Join - '+ip+':'+port;
    path := ExtractFilePath(gameData[activeGame].CommandLine1);
    if FindFirst(path+'*.*', faAnyFile, searchRec) = 0 then begin
      repeat
        if MatchesMask(searchRec.Name, '*.exe') or
           MatchesMask(searchRec.Name, '*.com') or
           MatchesMask(searchRec.Name, '*.bat') then
          cboCmdLine1.Items.Add(path+searchRec.Name);
      until FindNext(searchRec) <> 0;
      FindClose(searchRec);
    end;
  end;
  if frmJoin.ShowModal = mrOK then
    with frmJoin do
      LaunchGame(cboCmdLine1.Text,
                 txtCmdLine2.Text,
                 txtParam1.Text,
                 txtParam2.Text,
                 ip,
                 port,
                 GetPlayerName(True),
                 txtFileName.Text,
                 mmoFileContents.Text,
                 chkFile.Checked,
                 chkSpec.Checked,
                 chkPassword.Checked);
  frmJoin.Release;
end;

procedure TfrmMain.SetGameBox;
var
  i: Integer;
  b: Boolean;
begin
  b := False;
  cboGame.Items.Clear;
  for i := 0 to 7 do //GAME_ADD
    if gameData[i].Installed then begin
      b := True;
      case i of
        0: cboGame.Items.Add('Quake'); //GAME_ADD
        1: cboGame.Items.Add('QuakeWorld');
        2: cboGame.Items.Add('Quake 2');
        3: cboGame.Items.Add('Quake 3 Arena');
        4: cboGame.Items.Add('Half-Life');
        5: cboGame.Items.Add('Wolfenstein');
        6: cboGame.Items.Add('Tribes');
        7: cboGame.Items.Add('Tribes 2');
      end;
    end;
  if b then begin
    cboGame.Enabled := True;
    cboGame.ItemIndex := 0;
  end
  else
    cboGame.Enabled := False;
end;

procedure TfrmMain.UpdateList(filterServer: Boolean);
var
  i, j, k: Integer;
begin
  j := 0;
  lvwServer.Items.BeginUpdate;
  lvwServer.Items.Clear;
  Status('Loading '+cboGame.Text+' Server List...');
  for i := 0 to 1023 do begin
    if FilterItem(serverData[i], filterServer) then begin
      lvwServer.Items.Add;
      for k := 0 to 6 do
        lvwServer.Items[j].SubItems.Add('');
      SetServerItem(j, 0, serverData[i].ServerName);
      SetServerItem(j, 1, serverData[i].Ping);
      SetServerItem(j, 2, serverData[i].Address);
      SetServerItem(j, 3, serverData[i].Map);
      SetServerItem(j, 4, serverData[i].Players);
      SetServerItem(j, 5, serverData[i].GameMod);
      SetServerItem(j, 6, IntToStr(i)); //tag
      lvwServer.Items[j].ImageIndex := serverData[i].Image;
      Inc(j);
    end;
  end;
  Status('Ready: '+IntToStr(j)+' server(s)');
  SortServer;
  lvwServer.Items.EndUpdate;
  lvwPlayer.Items.BeginUpdate;
  lvwPlayer.Items.Clear;
  lvwPlayer.Items.EndUpdate;
  lvwRule.Items.BeginUpdate;
  lvwRule.Items.Clear;
  lvwRule.Items.EndUpdate;
end;

procedure TfrmMain.cboGameChange(Sender: TObject);
begin
  activeGame := -1; //GAME_ADD
  if cboGame.Text = 'Quake' then activeGame := 0;
  if cboGame.Text = 'QuakeWorld' then activeGame := 1;
  if cboGame.Text = 'Quake 2' then activeGame := 2;
  if cboGame.Text = 'Quake 3 Arena' then activeGame := 3;
  if cboGame.Text = 'Half-Life' then activeGame := 4;
  if cboGame.Text = 'Wolfenstein' then activeGame := 5;
  if cboGame.Text = 'Tribes' then activeGame := 6;
  if cboGame.Text = 'Tribes 2' then activeGame := 7;
  IsGame;
  UpdateList(False);
  SetFilterBox;
end;

function TfrmMain.FilterItem(s: TServerData; filterServer: Boolean): Boolean;
type
  TFilter = record
    TypeKey: Integer;
    Key: String;
    Logical: Integer;
    Value: String;
    Outcome: Boolean;
    Used: Boolean;
  end;
var
  i, j, k: Integer;
  filterString, t, y, key, value: String;
  a: Array[0..3] of String;
  filter: Array[0..31] of TFilter;
  b: Boolean;
begin
  //if [0: rule| 1: serverstatus] [0: < 1: > 2: = 3: !=] value  .. then show,hide
  if (s.ServerName <> '') and (s.Game = activeGame) then begin
    i := cboFilter.ItemIndex;
    if (not filterServer) or (i <= 0) then begin
      result := True;
      Exit;
    end;
    filterString := gameData[activeGame].Filter[i-1].Data;

    for i := 0 to 7 do
      filter[i].Used := False;
    k := 0;

    t := filterString;
    while filterString <> '' do begin
      for i := 0 to 3 do
        a[i] := '';
      j := 0;
      i := 1;
      while i <= Length(t) do begin
        t := Copy(filterString, 1, Pos('\', filterString)-1);
        if t[i] = ',' then
          Inc(j)
        else
          a[j] := a[j] + t[i];
        Inc(i);
      end;
      Delete(filterString, 1, Pos('\', filterString));
      filter[k].TypeKey := StrToInt(a[0]);
      filter[k].Key := a[1];
      filter[k].Logical := StrToInt(a[2]);
      filter[k].Value := a[3];
      filter[k].Used := True;
      Inc(k);
    end;
    for i := 0 to 7 do begin
      b := False;
      if filter[i].Used then begin
        filter[i].Outcome := False;
        case filter[i].TypeKey of
          0: begin
               y := s.RuleData;
               if (y <> '*none') and (Length(y) > 10) then begin
                 while y <> '' do begin
                   key := LeftStr(y, Pos(',', y)-1);
                   value := Copy(y, Pos(',', y)+1, Pos('\', y)-1-Pos(',', y));
                   if key = a[1] then begin
                     t := value;
                     y := '';
                   end;
                   y := Copy(y, Pos('\', y)+1, Length(y));
                 end;
               end;
             end;
          1: case StrToInt(filter[i].Key) of
               0: t := s.ServerName;
               1: t := s.Ping;
               2: t := s.Map;
               3: t := Copy(s.Players, 1, Pos('/', s.Players)-1); //players on server
               4: t := Copy(s.GameMod, Pos('/', s.GameMod)+1, Length(s.GameMod)); //mod
               5: if (s.PlayerData = '*none') or (s.RuleData = '*none') then
                    t := '0' //didnt respond
                  else
                    t := '1'; //responded
             end;
        end;
        if t = '' then
          b := False
        else begin
          case filter[i].Logical of
            0: if StrToInt(t) < StrToInt(filter[i].Value) then b := True;
            1: if StrToInt(t) > StrToInt(filter[i].Value) then b := True;
            2: if t = filter[i].Value then b := True;
            3: if t <> filter[i].Value then b := True;
          else
            b := False;
          end;
        end;
        filter[i].Outcome := b;
      end;
    end;

    i := 0;
    repeat
      if filter[i].Used then b := filter[i].Outcome;
      Inc(i);
    until (i > 7) or not b;
    Result := b;
  end
  else
    Result := False;
end;

procedure TfrmMain.ShellIcon(var Msg: TMessage);
var
  Point: TPoint;
begin
  case Msg.LParam of
    WM_LBUTTONDBLCLK: begin
                         Shell_NotifyIcon(NIM_DELETE, @notifyIconData);
                         Show;
                         Application.BringToFront;
                         Application.Restore;
                       end;
    WM_RBUTTONUP    : begin
                         SetForegroundWindow(Handle);
                         GetCursorPos(Point);
                         mnuTray.Popup(Point.x, Point.y);
                         PostMessage(Handle, WM_USER, 0, 0);
                       end;
  end;
end;

procedure TfrmMain.MinimizeToTray(Sender: TObject);
begin
  if options.MinimizeToTray then begin
    Shell_NotifyIcon(NIM_ADD, @notifyIconData);
    Hide
  end
  else
    Application.Minimize;
end;

procedure TfrmMain.mniTrayExitClick(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @notifyIconData);
  Application.Terminate;
end;

procedure TfrmMain.mniTrayRestoreClick(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @notifyIconData);
  Show;
  Application.BringToFront;
  Application.Restore;
end;

procedure TfrmMain.lvwPlayerCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  r: TRect;
  i: Integer;
begin
  DefaultDraw := False;
  r := Item.DisplayRect(drBounds);
  with Sender as TListView do begin
    if (activeGame in [0, 1]) and (playerColOrder[0] = -1) then begin //qw
      SmallImages.Draw(Canvas, r.Left+3, r.Top, StrToInt(Item.SubItems[7])); //first image
      SmallImages.Draw(Canvas, r.Left+21, r.Top, StrToInt(Item.SubItems[6])); //second image
      Canvas.TextOut(r.Left+39, r.Top+2, Item.Caption);
    end
    else
      Canvas.TextOut(r.Left+4, r.Top+2, Item.Caption);
    {if cdsSelected in State then begin
    ..if item is selected do something?
    end;}
  end;
  for i := 0 to Item.SubItems.Count-1 do
    lvwPlayerCustomDrawSubItem(Sender, Item, i, State, DefaultDraw);
end;

procedure TfrmMain.lvwPlayerCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  r: TRect;
  i: Integer;
begin
  DefaultDraw := False;
  r := Item.DisplayRect(drBounds);
  with Sender as TListView do begin
    if SubItem < Columns.Count-1 then begin
      for i := 0 to SubItem do
        r.Left := r.Left + Columns[i].Width;
      if (activeGame = 0) and
         (playerColOrder[0] > -1) and
         (SubItem = playerColOrder[0]) then begin //qw
        SmallImages.Draw(Canvas, r.Left+3, r.Top, StrToInt(Item.SubItems[7])); //first image
        SmallImages.Draw(Canvas, r.Left+21, r.Top, StrToInt(Item.SubItems[6])); //second image
        Canvas.TextOut(r.Left+39, r.Top+2, Item.SubItems[SubItem]);
      end
      else
        Canvas.TextOut(r.Left+4, r.Top+2, Item.SubItems[SubItem]);
    end;
  end;
end;

procedure TfrmMain.cboGameDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  icon: Integer;
begin
  icon := 8;
  if cboGame.Items[Index] = 'Quake' then icon := 6;
  if cboGame.Items[Index] = 'QuakeWorld' then icon := 16; //GAME_ADD
  if cboGame.Items[Index] = 'Quake 2' then icon := 26;
  if cboGame.Items[Index] = 'Quake 3 Arena' then icon := 36;
  if cboGame.Items[Index] = 'Half-Life' then icon := 46;
  if cboGame.Items[Index] = 'Wolfenstein' then icon := 56;
  if cboGame.Items[Index] = 'Tribes' then icon := 66;
  if cboGame.Items[Index] = 'Tribes 2' then icon := 76;
  cboGame.Canvas.FillRect(Rect);
  imgServer.Draw(cboGame.Canvas, Rect.Left, Rect.Top, icon);
  cboGame.Canvas.TextOut(Rect.Left + imgServer.Width + 5, Rect.Top + 1, cboGame.Items[Index]);
end;

procedure TfrmMain.tbrFilterSetupClick(Sender: TObject);
var
  i, j: Integer;
begin
  j := 0;
  Application.CreateForm(TfrmFilter, frmFilter);
  frmFilter.Caption := 'Server Filter Setup [' + cboGame.Text + ']';
  with frmFilter do
    for i := 0 to 31 do
      if gameData[activeGame].Filter[i].Name <> '' then begin
        //newFilter[i] := gameData[activeGame].Filter[i];
        lvwFilter.Items.Add;
        lvwFilter.Items[j].Caption := gameData[activeGame].Filter[i].Name;
        lvwFilter.Items[j].SubItems.Add(gameData[activeGame].Filter[i].Data);
        Inc(j);
      end;
  if frmFilter.ShowModal = mrOK then begin
    cboFilter.Items.Clear;
    cboFilter.Items.Add('All');
    for i := 0 to 31 do begin
      gameData[activeGame].Filter[i] := frmFilter.newFilter[i];
      if (gameData[activeGame].Filter[i].Name <> '') then
        cboFilter.Items.Add(gameData[activeGame].Filter[i].Name);
    end;
    cboFilter.ItemIndex := 0;
  end;
  frmFilter.Release;
end;

procedure TfrmMain.cboFilterChange(Sender: TObject);
begin
  UpdateList(True);
end;

procedure TfrmMain.SetFilterBox;
var
  i: Integer;
begin
  cboFilter.Items.Clear;
  cboFilter.Items.Add('All');
  if activeGame > -1 then
    for i := 0 to 31 do
      if (gameData[activeGame].Filter[i].Name <> '') then
        cboFilter.Items.Add(gameData[activeGame].Filter[i].Name);
  cboFilter.ItemIndex := 0;
end;

procedure TfrmMain.tbrHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_FINDER, 0);
end;

procedure TfrmMain.mniCopyInfoClick(Sender: TObject);
var
  i: Integer;
  s: Array[0..5] of String;
begin
  i := StrToInt(GetServerItem(lvwServer.Selected.Index, 6));
  s[0] := serverData[i].ServerName;
  s[1] := serverData[i].IP + ':' + IntToStr(serverData[i].Port);
  s[2] := serverData[i].Ping;
  s[3] := serverData[i].Map;
  s[4] := serverData[i].Players;
  s[5] := serverData[i].GameMod;
  for i := 0 to 4 do
    if s[i] <> '' then s[i] := s[i] + '  ';
  clipboard.AsText := s[0] + s[1] + s[2] + s[3] + s[4] + s[5];
end;

procedure TfrmMain.IsGame;
begin
  if activeGame > -1 then begin
    tbrAddServer.Enabled := True;
    tbrRemoveServer.Enabled := True;
    tbrRefreshAll.Enabled := True;
    tbrRefreshSelected.Enabled := True;
    tbrFilterSetup.Enabled := True;
    mniAddServer.Enabled := True;
    mniRemoveServer.Enabled := True;
    mniRefreshAll.Enabled := True;
    mniRefreshSelected.Enabled := True;
    mniFilterSetup.Enabled := True;
  end
  else begin
    tbrAddServer.Enabled := False;
    tbrRemoveServer.Enabled := False;
    tbrRefreshAll.Enabled := False;
    tbrRefreshSelected.Enabled := False;
    tbrFilterSetup.Enabled := False;
    mniAddServer.Enabled := False;
    mniRemoveServer.Enabled := False;
    mniRefreshAll.Enabled := False;
    mniRefreshSelected.Enabled := False;
    mniFilterSetup.Enabled := False;
  end;
end;

procedure TfrmMain.mniHelpQuickStartClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, 2);
end;

end.
