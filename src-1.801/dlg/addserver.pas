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

unit addserver;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Winsock, ComCtrls;

type
  TfrmAddServer = class(TForm)
    cmdDone: TButton;
    cmdAdd: TButton;
    mmoServers: TMemo;
    mmoResult: TMemo;
    txtDil: TEdit;
    lblDelimiter: TLabel;
    cmdLoadFile: TButton;
    cmdClear: TButton;
    chkList: TCheckBox;
    procedure cmdDoneClick(Sender: TObject);
    procedure cmdAddClick(Sender: TObject);
    procedure cmdLoadFileClick(Sender: TObject);
    procedure cmdClearClick(Sender: TObject);
    procedure chkListClick(Sender: TObject);
  private
    procedure AddToList(ipPort, ip, port: String);
    function ResolveIP(addy: String): String;
  end;

var
  frmAddServer: TfrmAddServer;

implementation

uses Main;

{$R *.dfm}

procedure TfrmAddServer.cmdDoneClick(Sender: TObject);
begin
  frmAddServer.ModalResult := mrOK;  //close dialog
end;

procedure TfrmAddServer.cmdAddClick(Sender: TObject);
var
  s, t, ip, addy, port, ipPort: String;
  j, k, m, p, addnum: Integer;
  b: Boolean;
  d: Char;
const
  gameDefPort: Array [0..7] of String = ('26000', '27500', '27910', '27960', '27015', '27960', '28001', '28000');
begin
  mmoResult.Lines.Clear;
  mmoResult.Lines.Text := 'Working...';
  addnum := 0;
  d := txtDil.Text[1];
  for p := 0 to mmoServers.Lines.Count-1 do begin
    s := mmoServers.Lines.Strings[p];
    if chkList.Checked then begin //its single ip/dns'
      if Pos(':', s) > 0 then begin
        addy := Copy(Trim(s), 0, Pos(':', Trim(s))-1);
        port := Copy(Trim(s), Pos(':', Trim(s))+1, Length(Trim(s))-Pos(':', Trim(s)));
        ipPort := Trim(s);
      end
      else begin
        addy := Trim(s);
        port := gameDefPort[frmMain.activeGame];
        ipPort := addy + ':' + port;
      end;
      ip := ResolveIP(addy);
      if ip <> '' then begin
        AddToList(ipPort, ip, port);
        Inc(addnum);
      end
      else
        mmoResult.Lines.Add('Can''t resolve address ' + ipPort);
    end
    else begin //its a ip list to parse, get ips
      while Length(s) > 1 do begin
        if Ord(s[1]) in [48..57] then begin
          j := 1;
          while Ord(s[j]) in [46, 48..57] do
            Inc(j);
          if (s[j] = d) and (Ord(s[j+1]) in [48..57]) then begin
           Inc(j);
           while Ord(s[j]) in [48..57] do
              Inc(j);
          end;
          t := Copy(s, 1, j-1);
          Delete(s, 1, j-1);
          b := False;
          k := 1;
          m := 0;
          //check its an ip
          repeat
            if not (Ord(t[k]) in [48..57, 46, Ord(d)]) then b := True;
            if t[k] = '.' then Inc(m);
            Inc(k);
          until b or (k > Length(t));
          if not b and (m = 3) then begin
            if d <> ':' then //change all dils to :
              while Pos(d, t) > 0 do
                t[Pos(d, t)] := ':';
            //got an ip add to list
            if Pos(':', t) > 0 then begin
              addy := Copy(Trim(t), 0, Pos(':', Trim(t))-1);
              port := Copy(Trim(t), Pos(':', Trim(t))+1, Length(Trim(t))-Pos(':', Trim(t)));
              ipPort := Trim(t);
            end
            else begin
              addy := Trim(t);
              port := gameDefPort[frmMain.activeGame];
              ipPort := addy + ':' + port;
            end;
            //add item to server list
            AddToList(ipPort, ip, port);
            Inc(addnum);
          end;
        end;
        Delete(s, 1, 1);
      end;
    end;
  end;
  mmoResult.Lines.Add('Added ' + IntToStr(addnum) + ' server(s)');
end;

procedure TfrmAddServer.AddToList(ipPort, ip, port: String);
var
  i: Integer;
  b: Boolean;
const
  gameFullName: Array [0..7] of String = ('Quake', 'QuakeWorld', 'Quake 2', 'Quake 3', 'Half-Life', 'Wolfenstein', 'Tribes', 'Tribes 2');
begin
  with frmMain do begin
    i := 0;
    b := False;
    repeat //dup
      if serverData[i].ServerName <> '' then
        if (serverData[i].IP = ip) and
           (serverData[i].Port = StrToInt(port)) and
           (serverData[i].Game = activeGame) then b := True;
      Inc(i);
    until (i > 1023) or b;
    if not b then begin
      i := 0;
      b := False;
      repeat //find blank slot
        if (serverData[i].ServerName = '') then b := True;
        Inc(i);
      until (i > 1023) or b;
      if (i <= 1023) and b then begin
        Dec(i);
        serverData[i].ServerName := 'Unknown';
        serverData[i].Ping := '';
        serverData[i].Address := ipPort;
        serverData[i].Map := '';
        serverData[i].Players := '';
        serverData[i].Game := activeGame;
        serverData[i].GameMod := gameFullName[activeGame];
        serverData[i].IP := ip;
        serverData[i].Port := StrToInt(port);
        serverData[i].Image := activeGame * 10 + 6;
        serverData[i].PlayerData := '*none';
        serverData[i].RuleData := '*none';
        mmoResult.Lines.Add('Added ' + ipPort);
      end
      else
        mmoResult.Lines.Add('Can''t add server, 1024 limit reached');
    end
    else
      mmoResult.Lines.Add('Server ' + ipPort + ' already exists');
  end;
end;

function TfrmAddServer.ResolveIP(addy: String): String;
var
  hostEnt: PHostEnt;
  WSAData: TWSAData;
  addr: PChar;
  //sockAddrIn: TSockAddrIn;
  i, j: Integer;
  b: Boolean;
begin
  b := False;
  i := 1;
  j := 0;
  repeat
    if not (Ord(addy[i]) in [48..57, 46]) then b := True;
    if addy[i] = '.' then Inc(j);
    Inc(i);
  until b or (i > Length(addy));
  try
    WSAStartup ($101, WSAdata);
    if not b and (j = 3) then begin //ip
      //sockAddrIn.sin_addr.s_addr := inet_addr(PChar(addy));
      //HostEnt := GetHostByAddr(@sockAddrIn.sin_addr.S_addr, 4, AF_INET);
      Result := addy;
    end
    else begin //dns
      hostEnt := GetHostByName(PChar(addy));
      if Assigned(hostEnt) then begin //return ip
        addr := hostEnt^.h_addr_list^;
        Result := Format('%d.%d.%d.%d', [byte (addr [0]), byte (addr [1]), byte (addr [2]), byte (addr [3])]);
      end
      else
        Result := '';
    end;
  finally
    WSACleanup;
  end;
end;

procedure TfrmAddServer.cmdLoadFileClick(Sender: TObject);
begin
  frmMain.dlgOpen.FileName := '';
  frmMain.dlgOpen.Filter := 'All Files|*.*';
  frmMain.dlgOpen.Title := 'Choose File';
  if frmMain.dlgOpen.Execute then
    mmoServers.Lines.LoadFromFile(frmMain.dlgOpen.FileName);
end;

procedure TfrmAddServer.cmdClearClick(Sender: TObject);
begin
  mmoServers.Lines.Clear;
  mmoServers.Lines.Text := '';
  mmoResult.Lines.Clear;
  mmoResult.Lines.Text := '';
end;

procedure TfrmAddServer.chkListClick(Sender: TObject);
begin
  lblDelimiter.Enabled := not chkList.Checked;
  txtDil.Enabled := not chkList.Checked;
end;

end.
