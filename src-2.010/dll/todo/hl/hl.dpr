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

library hl;

(* Half-Life Plugin for Fizz
 * Copyright (C) 2002 bliP
 * Version 1.00
 * http://nisda.net
 *)

uses IdUDPClient, SysUtils;

{$R *.res}

type
  TPlayerData = record
    Name: String[32];
    Frags: Integer;
    Skin: String[32];
    Ping: Integer;
    Connect: Integer;
    UserID: Integer;
    TopColour: Integer;
    BottomColour: Integer;
  end;

type
  TRuleData = record
    Name: String[32];
    Value: String[32];
  end;

type
  TServerData = record
    ServerName: String[64];
    Map: String[32];
    Players: Integer;
    MaxPlayers: Integer;
    GameMod: String[64];
    IconIndex: Integer;
    PlayerData: Array[0..127] of TPlayerData;
    RuleData: Array[0..255] of TRuleData;
  end;

function Main(ip: PChar; port: Integer; to: Integer): TServerData; export;
var
  IdUdp: TIdUDPClient;
  info: TServerData;
  passw, s: String;
  i, j, plr: Integer;
  b: Boolean;
begin
  IdUdp := TIdUDPClient.Create(nil); //create udp
  try
    IdUdp.ReceiveTimeout := to;
    IdUdp.Host := ip;
    IdUdp.Port := port;

    //serverinfo
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send('ÿÿÿÿinfo'+Chr(0));
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);

    info.GameMod := 'Half-Life';
    Delete(s, 1, Pos(#0, s));
    info.ServerName := Copy(s, 1, Pos(#0, s)-1);
    Delete(s, 1, Pos(#0, s));
    info.Map := Copy(s, 1, Pos(#0, s)-1);
    Delete(s, 1, Pos(#0, s));
    info.GameMod := info.GameMod + '/' + Copy(s, 1, Pos(#0, s)-1);
    info.Players := Ord(s[Length(s)-2])
    info.MaxPlayers := Ord(s[Length(s)-1]);

    //rules
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send('ÿÿÿÿrules'+Chr(0));
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);

    Delete(s, 1, 8);
    b := False;
    while (Length(s > 1) and not b do begin
      key := Copy(s, 1, Pos(#0, s)-1);
      Delete(s, 1, Pos(#0, s));
      value := Copy(s, 1, Pos(#0, s)-1);
      Delete(s, 1, Pos(#0, s));
      if key = 'sv_password' then begin
        passw := value;
        b := True;
      end;
    end;
    if info.Players <> info.MaxPlayers then info.IconIndex := 6; //players
    if info.Players = 0 then info.IconIndex := 1; //empty
    if info.Players = info.MaxPlayers then info.IconIndex := 2; //full
    if passw = '1' then
      case info.IconIndex of
        6: info.IconIndex := 7; //pw
        1: info.IconIndex := 4; //pw empty
        2: info.IconIndex := 5 //pw full
      end;

    //players
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send('ÿÿÿÿplayers'+Chr(0));
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);

    j := 7;
    plr := 0;
    for i := 1 to Ord(s[6]) do begin
      info.PlayerData[plr].UserID := Ord(s[j]);
      Inc(j);
      while s[j] <> Chr(0) do begin
        info.PlayerData[plr].Name := info.PlayerData[plr].Name + s[j];
        Inc(j);
      end;
      Inc(j);
      info.PlayerData[plr].Frags := Ord(s[j]);
      {Inc(j, 4);
      for k := 1 to 4 do begin
        time := time + p[j];
        Inc(j);
      end;
      time := '';}
      info.PlayerData[plr].TopColour := -1;
      info.PlayerData[plr].BottomColour := -1;
      Inc(plr);
    end;

  finally
    IdUdp.Free;
  end;

  result := info;
end;

function Info: PChar; export;
begin
  Result := 'Fizz'+#0+
            'Half-Life'+#0+
            'bliP'+#0+
            '1.00'+#0;
end;

exports Parse, Info;

end.
