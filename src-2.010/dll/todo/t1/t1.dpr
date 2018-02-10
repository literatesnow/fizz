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

library t1;

(* Tribes Plugin for Fizz
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
begin
  IdUdp := TIdUDPClient.Create(nil); //create udp
  try
    IdUdp.ReceiveTimeout := to;
    IdUdp.Host := ip;
    IdUdp.Port := port;
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send('b++');
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);
  finally
    IdUdp.Free;
  end;

  rlei := 0;
  info.GameMod := 'Tribes';
  info.RuleData[rlei].Name := 'gamename';
  info.RuleData[rlei].Value := Copy(s, 6, 6); //Tribes
  Inc(rlei);
  Delete(s, 1, 11);
  j := Ord(s[1]);
  info.RuleData[rlei].Name := 'version';
  info.RuleData[rlei].Value := Copy(s, 2, j);
  Inc(rlei);
  Delete(s, 1, j+1);
  j := Ord(s[1]);
  info.ServerName := Copy(s, 2, j);
  Delete(s, 1, j+1);
  info.RuleData[rlei].Name := 'dedicated';
  info.RuleData[rlei].Value := IntToStr(Ord(s[1]));
  Inc(rlei);
  needpass := IntToStr(Ord(s[2]));
  info.RuleData[rlei].Name := 'needpass';
  info.RuleData[rlei].Value := needpass;
  Inc(rlei);
  info.Players := Ord(s[3]);
  info.MaxPlayers := Ord(s[4]);
  info.RuleData[rlei].Name := 'cpu';
  info.RuleData[rlei].Value := IntToStr((Ord(s[5])+Ord(s[6])*256));
  j := Ord(s[7]);
  Delete(s, 1, 7);
  info.RuleData[rlei].Name := 'mods';
  info.RuleData[rlei].Value := Copy(s, 1, j);
  Inc(rlei);
  Delete(s, 1, j);
  j := Ord(s[1]);
  info.RuleData[rlei].Name := 'mission';
  info.RuleData[rlei].Value := Copy(s, 2, j);
  Inc(rlei);
  info.GameMod := info.GameMod + '/' + Copy(s, 2, j);
  Delete(s, 1, j+1);
  j := Ord(s[1]);
  info.Map := Copy(s, 2, j);
  Delete(s, 1, j+1);
  j := Ord(s[1]);
  Delete(s, 1, j+1);
  numTeams := Ord(s[1]);
  j := Ord(s[2]);
  Delete(s, 1, j+2);
  j := Ord(s[1]);
  Delete(s, 1, j+1);

  for i := 0 to numTeams-1 do begin //rip out team header
    j := Ord(s[1]);
    info.RuleData[rlei].Name := 'team' + IntToStr(i);
    info.RuleData[rlei].Value := Copy(s, 2, j);
    Inc(rlei);
    Delete(s, 1, j+1);
    j := Ord(s[1]);
    Delete(s, 1, j+1);
  end;
  if players <> '0' then begin

  //icons
  info.IconIndex := 6;
  if info.Players = info.MaxPlayers then info.IconIndex := 2; //full
  if info.Players = 0 then info.IconIndex := 1; //empty
  if needpass = '1' then begin
    if (info.Players <> 0) and (info.Players <> info.MaxPlayers) then info.IconIndex := 7; //pw
    if info.Players = 0 then info.IconIndex := 4; //pw empty
    if info.Players = info.MAxPlayers then info.IconIndex:= 5; //pw full
  end;

  //players
  i := 0;
  while Length(s) > 2 do begin
    info.PlayerData[plri].Ping := Ord(s[1]) * 4;
    j := Ord(s[4]);
    info.PlayerData[plri].Name := Copy(s, 5, j);
    Delete(s, 1, j + 4);
    j := Ord(s[1]);
    info.PlayerData[plri].Frags := StrToInt(Trim(Copy(s, 7, 5)));
    Delete(p, 1, j + 1);
    info.PlayerData[plri].UserID := plri;
    info.PlayerData[plri].TopColour := -1;
    info.PlayerData[plri].BottomColour := -1;
    Inc(plri);
  end;

  result := info;
end;

function Info: PChar; export;
begin
  Result := 'Fizz'+#0+
            'Tribes'+#0+
            'bliP'+#0+
            '1.00'+#0;
end;

exports Main, Info;

end.
