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

library t2;

(* Tribes 2 Plugin for Fizz
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
    //ServerIcon: T...;
    //PlayerIcon: T...;
    PlayerIcons;
    PlayerData: Array[0..127] of TPlayerData;
    RuleData: Array[0..255] of TRuleData;
  end;

function Main(ip: PChar; port: Integer; to: Integer): TServerData; export;
var
  IdUdp: TIdUDPClient;
  info: TServerData;
  s, t: String;
  i, plri, rlei: Integer;
begin
  IdUdp := TIdUDPClient.Create(nil); //create udp
  try
    IdUdp.ReceiveTimeout := to;
    IdUdp.Host := ip;
    IdUdp.Port := port;
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send(#14+#2+#1+#1+#1+#1+#0);
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);

    //if Copy(s, 1, 6) <> #$10+#2+#1+#1+#1+#1 then Exit;
    Delete(s, 1, 6);
    i := Ord(s[1])
    info.RuleData[rlei].Name := 'version';
    info.RuleData[rlei].Value := Copy(s, 2, i);
    Inc(rlei);
    Delete(s, 1, i+1);
    info.RuleData[rlei].Name := 'net protocol';
    info.RuleData[rlei].Value := IntToStr(Ord(s[1]));
    Inc(rlei);
    info.RuleData[rlei].Name := 'min net protocol';
    info.RuleData[rlei].Value := IntToStr(Ord(s[5]));
    Inc(rlei);
    Delete(s, 1, 8);
    info.RuleData[rlei].Name := 'build version';
    info.RuleData[rlei].Value := IntToStr(Ord(s[1])+Ord(s[2])*256);
    Delete(s, 1, 4);
    info.ServerName := Copy(s, 2, Ord(s[1]));

    i := 0;
    repeat
      Inc(i);
      IdUdp.Send(#18+#2+#1+#1+#1+#1+#0);
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);
    //if Copy(s, 1, 6) <> #20+#2+#1+#1+#1+#1 then Exit;
    i := Ord(s[7]);
    info.RuleData[rlei].Name := 'game';
    info.RuleData[rlei].Value := Copy(s, 8, i); //mod
    Inc(rlei);
    Delete(s, 1, 7 + i);
    i := Ord(s[1]);
    info.GameMod := 'Tribes 2/'+Copy(s, 2, i); //mission
    Delete(s, 1, i + 1);
    i := Ord(s[1]);
    info.Map := Copy(s, 2, i); //map
    Delete(s, 1, i + 1);
    i := Ord(s[1]); //status byte
    info.Players := Ord(s[2]);
    info.MaxPlayers := Ord(s[3]);
    info.RuleData[rlei].Name := 'dedicated';
    info.RuleData[rlei].Value := IntToStr(i and 1);
    Inc(rlei);
    info.RuleData[rlei].Name := 'passworded';
    passw := IntToStr((i and 2) div 2));
    info.RuleData[rlei].Value := passw;
    Inc(rlei);
    info.RuleData[rlei].Name := 'linux';
    info.RuleData[rlei].Value := IntToStr((i and 4) div 4));
    Inc(rlei);
    info.RuleData[rlei].Name := 'tourniment';
    info.RuleData[rlei].Value := IntToStr((i and 8) div 8));
    Inc(rlei);
    info.RuleData[rlei].Name := 'noalias';
    info.RuleData[rlei].Value := IntToStr((i and 16) div 16));
    Inc(rlei);
    info.RuleData[rlei].Name := 'bot count';
    info.RuleData[rlei].Value := IntToStr(Ord(s[4]));
    Inc(rlei);
    info.RuleData[rlei].Name := 'cpu';
    info.RuleData[rlei].Value := IntToStr(Ord(s[5])+Ord(s[6])*256);
    Delete(s, 1, 6);
    i := Ord(s[1]);
    info.RuleData[rlei].Name := 'server info';
    info.RuleData[rlei].Value := Copy(s, 2, i);
    Inc(rlei);
    Delete(s, 1, i + 1);
    Delete(s, 1, 2); //this is for .. ?
    numTeams := StrToInt(s[1]); //num teams
    Delete(s, 1, 2);
    for i := 0 to numTeams-1 do begin
      info.RuleData[rlei].Name := 'team' + IntToStr(i + 1);
      info.RuleData[rlei].Value := Copy(s, 1, Pos(#9, s) - 1);
      Inc(rlei);
      Delete(s, 1, Pos(#$A, s));
    end;

    //icons
    info.IconIndex := 6;
    if info.Players = info.MaxPlayers then info.IconIndex := 2; //full
    if info.Players = '0' then info.IconIndex := 1; //empty
    if passw = '1' then begin
      if (info.Players <> 0) and (info.Players <> info.MaxPlayers) then info.IconIndex := 7; //pw
      if info.Players = 0 then info.IconIndex := 4; //pw empty
      if info.Players = info.MaxPlayers then info.IconIndex := 5; //pw full
    end;

    //players
    if s <> '0' then begin
      s := Copy(s, Pos(#$A, s), Length(s)) + #$A;
      plri := 0;
      while s <> #$A do begin

      t := Copy(s, 4, Pos(#$11, s) - 4);
      for i := 1 to Length(t) do
        if Ord(t[j]) > 31 then
          info.PlayerData[plri].Name := info.PlayerData[plri].Name + t[j]
        else
          info.PlayerData[plri].Name := info.PlayerData[plri].Name + ' ';
      Delete(t, 1, Pos(#$11, t) + 1);
      Delete(t, 1, Pos(#9, t));
      info.PlayerData[plri].Frags := StrToInt(Copy(p, 1, Pos(#$A, t) - 1));
      Delete(t, 1, Pos(#$A, t) - 1);
      info.PlayerData[plri].UserID := plri;
      info.PlayerData[plri].TopColour := -1;
      info.PlayerData[plri].BottomColour := -1;
      Inc(plri);
  finally
    IdUdp.Free;
  end;

  result := info;
end;

function Info: PChar; export;
begin
  Result := 'Fizz'+#0+
            'Tribes 2'+#0+
            'bliP'+#0+
            '1.00'+#0;
end;

exports Main, Info;

end.
