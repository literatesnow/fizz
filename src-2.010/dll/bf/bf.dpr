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

library bf;

(* BattleField 1942 Plugin for Fizz
 * Copyright (C) 2003 bliP
 * Version 1.00
 * http://nisda.net
 *)

uses IdUDPClient, IdException, SysUtils, WinProcs;

{$R *.res}

type
  TPlayerData = record
    Name: PChar;
    Frags: Integer;
    Skin: PChar;
    Ping: Integer;
    Connect: Integer;
    UserID: Integer;
    TopColour: Integer;
    BottomColour: Integer;
  end;

type
  TRuleData = record
    Name: PChar;
    Value: PChar;
  end;

type
  TServerData = record
    ServerName: PChar;
    Map: PChar;
    Ping: Integer;
    Players: Integer;
    MaxPlayers: Integer;
    GameMod: PChar;
    IconIndex: Integer;
    PlayerData: Array[0..127] of TPlayerData;
    RuleData: Array[0..255] of TRuleData;
  end;

type
  TThisServer = record
    IP: PChar;
    Port: Integer;
    TimeOut: Integer;
  end;

function Main(var server: TThisServer; var info: TServerData): boolean; stdcall; export;
var
  IdUdp: TIdUDPClient;
  i, pw, pl, px, j: Integer;
  s, t, key, value, last: String;
  b, f: Boolean;
  p: Array[0..5] of String;
  time: Cardinal;
begin
  GetMem(info.ServerName, Length('Unknown') + 1);
  StrCopy(info.ServerName, PChar('Unknown'));
  GetMem(info.GameMod, Length('Battlefield 1942') + 1);
  StrCopy(info.GameMod, PChar('Battlefield 1942'));
  info.Players := -1;
  info.MaxPlayers := 0;
  info.Ping := 999;
  info.IconIndex := 1;

//  all := 0;
  pw := 0;

  //info
  time := GetTickCount;
  IdUdp := TIdUDPClient.Create(nil);
  try
    IdUdp.ReceiveTimeout := server.TimeOut;
    IdUdp.Host := server.IP;
    IdUdp.Port := server.Port;
    i := 0;
    repeat
      Inc(i);
      try
        IdUdp.Send('\info\'+#0);
        s := IdUdp.ReceiveString;
      except on E: EIdSocketError do begin end; end;
    until (s <> '') or (i > 2);
  finally
    IdUdp.Free;
  end;
  i := (GetTickCount - time);
  if (i > 999) then i := 999;
  info.Ping := i;
  if (s <> '') and (s[1] = '\') then begin
//    Inc(all);
    Delete(s, 1, 1);
    while (Pos('\', s) > 0) do begin
      key := Copy(s, 1, Pos('\', s)-1);
      Delete(s, 1, Pos('\', s));
      value := Copy(s, 1, Pos('\', s)-1);
      Delete(s, 1, Pos('\', s));
      if (key = 'hostname') then begin
        GetMem(info.ServerName, Length(value) + 1);
        StrCopy(info.ServerName, PChar(value));
      end;
      if (key = 'mapname') then begin
        GetMem(info.Map, Length(value) + 1);
        StrCopy(info.Map, PChar(value));
      end;
      if (key = 'gametype') then begin
        GetMem(info.GameMod, Length('Battlefield 1942/' + value) + 1);
        StrCopy(info.GameMod, PChar('Battlefield 1942/' + value));
      end;
      if (key = 'maxplayers') then info.MaxPlayers := StrToInt(value);
      if (key = 'numplayers') then info.Players := StrToInt(value);
      if (key = 'password') then pw := StrToInt(value);
    end;
  end;

  //players
  IdUdp := TIdUDPClient.Create(nil);
  IdUdp.BufferSize := 8192;
  try
    IdUdp.ReceiveTimeout := server.TimeOut;
    IdUdp.Host := server.IP;
    IdUdp.Port := server.Port;
    i := 0;
    repeat
      Inc(i);
      try
        IdUdp.Send('\players\'+#0);
        s := IdUdp.ReceiveString;
        j := Length(s);
        if (j > 1350) then
          s := s + IdUdp.ReceiveString;
      except on E: EIdSocketError do begin end; end;
    until (s <> '') or (i > 2);
  finally
    IdUdp.Free;
  end;
  j := 0;
  if (s <> '') and (s[1] = '\') then begin
//    Inc(all);
    f := True;
    Delete(s, 1, 1);
    while (Pos('\', s) > 0) and (f) do begin
      b := True;
      for i := 0 to 5 do begin
        key := Copy(s, 1, Pos('\', s)-1);
        if (key = 'teamname_1') then begin
          b := False;
          f := False;
          break;
        end;
        if (key = 'queryid') then begin
          Delete(s, 1, Pos('\', s));
          Delete(s, 1, Pos('\', s));
        end;
        //t := Copy(s, 1, Pos('\', s) - 1);
        //Delete(t, 1, Pos('_', s));
        //if ((t <> '') and (StrToInt(t) > pw)) then b := False;
        Delete(s, 1, Pos('\', s));
        value := Copy(s, 1, Pos('\', s)-1);
        p[i] := value;
        Delete(s, 1, Pos('\', s));
      end;
      if (b) and (p[5] <> last) then begin
        GetMem(info.PlayerData[j].Name, Length(p[5]) + 1);
        StrCopy(info.PlayerData[j].Name, PChar(p[5]));
        info.PlayerData[j].Ping := StrToInt(p[1]);
        //info.PlayerData[j].Deaths := StrToInt(p[3]);
        info.PlayerData[j].Frags := StrToInt(p[4]);
        info.PlayerData[j].TopColour := -1;
        info.PlayerData[j].BottomColour := -1;
        last := p[5];
        Inc(j);
      end;
    end;
  end;
  if (j > 0) then info.Players := j;

  //icon
  //0:refreshing,1:server not respond,2:none,3:server empty,4:server full
  //5:server password,6:server password empty7:server password full
  pl := info.Players;
  px := info.MaxPlayers;
  i := 2;
  if pl = 0 then i := 3 //empty
  else if pl = px then i := 4; //full
  if (pw > 0) then Inc(i, 3);
  info.IconIndex := i;

  //rules
  Delete(s, 1, Pos('\', s));
  t := '\Team1\' + Copy(s, 1, Pos('\', s)-1) + '\';
  Delete(s, 1, Pos('\', s));
  Delete(s, 1, Pos('\', s));
  t := t + 'Team2\' + Copy(s, 1, Pos('\', s)-1) + '\';

  IdUdp := TIdUDPClient.Create(nil);
  try
    IdUdp.ReceiveTimeout := server.TimeOut;
    IdUdp.Host := server.IP;
    IdUdp.Port := server.Port;
    i := 0;
    repeat
      Inc(i);
      try
        IdUdp.Send('\rules\'+#0);
        s := IdUdp.ReceiveString;
      except on E: EIdSocketError do begin end; end;
    until (s <> '') or (i > 2);
  finally
    IdUdp.Free;
  end;

  j := 0;
  if (s <> '') and (s[1] = '\') then begin
//    Inc(all);
    Delete(s, 1, 1);
    s := s + t;
    while (Pos('\', s) > 0) do begin
      key := Copy(s, 1, Pos('\', s)-1);
      Delete(s, 1, Pos('\', s));
      value := Copy(s, 1, Pos('\', s)-1);
      Delete(s, 1, Pos('\', s));
      if ((key <> '') and (value <> '')) and (key <> 'queryid') then begin
        GetMem(info.RuleData[j].Name, Length(key) + 1);
        StrCopy(info.RuleData[j].Name, PChar(key));
        GetMem(info.RuleData[j].Value, Length(value) + 1);
        StrCopy(info.RuleData[j].Value, PChar(value));
        Inc(j);
      end;
    end;
  end;

  //if (all <> 3) then begin
  //  GetMem(info.ServerName, Length('Unknown') + 1);
  //  StrCopy(info.ServerName, PChar('Unknown'));
  //  info.IconIndex := 1;
  //end;

  Result := True;
end;

function Info: PChar; export;
begin
  Result := 'Fizz' +#10+ //uhh..
            'Battlefield 1942' +#10+ //game name
            'bliP' +#10+ //author
            '1.00' +#10 + //version
            '14567' +#10+ //default
            '23000' +#10+ //query
            'c:\bf1942\bf.exe' +#10+ //default exe
            '+connect %ip%'; //default params
end;

exports Main, Info;

end.
