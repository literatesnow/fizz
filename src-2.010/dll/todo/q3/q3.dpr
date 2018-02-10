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

library q3;

(* Quake 3 Area Plugin for Fizz
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
  srv, plr, s, t: String;
  b: Boolean;
  i, j, m, k, l, plri, rlei: Integer;
  plrnfo: Array[0..7] of String;
begin
  IdUdp := TIdUDPClient.Create(nil); //create udp
  try
    IdUdp.ReceiveTimeout := to;
    IdUdp.Host := ip;
    IdUdp.Port := port;
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send('ÿÿÿÿgetstatus'+Chr(0));
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);
  finally
    IdUdp.Free;
  end;

  srv := Copy(s, 7, Pos(#10, s)-7)+'\';
  plr := Copy(s, Pos(#10, s), Length(s));

  //plr
  if plr = '' then
    info.Players := 0
  else begin
    i := 0;
    while Pos(#10, plr) > 0 do begin
      plr[Pos(#10, plr)] := ' ';
      Inc(i);
    end;
    info.Players := i - 1;
  end;

  //srv and rules
  info.GameMod := 'Quake 3 Arena';
  rlei := 0;
  while (Length(srv) > 2) and (rlei <= 255) do begin
    info.RuleData[rlei].Name := Copy(srv, 1, Pos('\', srv)-1);
    Delete(srv, 1, Pos('\', srv));
    info.RuleData[rlei].Value := Copy(srv, 1, Pos('\', srv)-1);
    Delete(srv, 1, Pos('\', srv));
    if key = 'sv_hostname' then info.ServerName := info.RuleData[rlei].Value;
    if key = 'mapname' then info.Map := info.RuleData[rlei].Value;
    if key = 'gamename' then info.GameMod := info.GameMod + '/' + info.RuleData[rlei].Value;
    if key = 'sv_maxclients' then info.MaxPlayers := StrToInt(info.RuleData[rlei].Value);
    if key = 'g_needpass' then s := info.RuleData[rlei].Value;
    Inc(rlei);
  end;

  //icon
  info.IconIndex := 6;
  if info.Players = info.MaxPlayers then info.IconIndex := 2; //full
  if info.Players = 0 then info.IconIndex := 1; //empty
  if s <> '' then
    if StrToInt(s) > 0 then begin
      if (info.Players <> 0) and (info.Players <> info.MaxPlayers) then info.IconIndex := 7; //pw
      if info.Players = 0 then info.IconIndex := 4; //pw empty
      if info.Players = info.MaxPlayers then info.IconIndex := 5; //pw full
    end;

  //players
  plri := 0;
  while Pos(#10, plr) > 0 do begin
    k := Pos(#10, plr);
    p[Pos(#10, plr)] := ' ';
    t := Copy(p, k+1, Pos(#10, p)-k-1);
    if (t <> '') and (plri <= 127) then begin
      for i := 0 to 7 do //clear source array first
        plrnfo[i] := '';
      i := 1;
      m := 0;
      b := False;
      while i <= Length(b) do begin //loop though the entire string
        if (not b) and (t[i] = ' ') then //check if we are inside our quotes, if we are then ignore the delimiter, else move to the next position in our parsed array
          Inc(m)
        else if t[i] = '"' then //will turn true the first time we hit a quote, False the second time we hit a quote
          b := not b
        else
          plrnfo[m] := plrnfo[m] + t[i];
        Inc(i);
      end;

      i := 1;
      s := plrnfo[2];
      if Pos('^', plrnfo[2]) > 0 then begin
        s := '';
        while i <= Length(plrnfo[2]) do begin
          if (plrnfo[2][i] = '^') and (Ord(plrnfo[2][i+1]) in [48..57]) then
            Inc(i, 2)
          else begin
            s := s + plrnfo[2][i];
            Inc(i);
          end;
        end;
      end;

      info.PlayerData[plri].Name := s;
      info.PlayerData[plri].Frags := StrToInt(plrnfo[0]);
      info.PlayerData[plri].Connect := StrToInt(plrnfo[1]);
      info.PlayerData[plri].UserID := plri + 1;
      info.PlayerData[plr].TopColour := -1;
      info.PlayerData[plr].BottomColour := -1;
      Inc(plri);
    end;
  end;

  result := info;
end;

function Info: PChar;
begin
  Result := 'Fizz'+#0+
            'Quake 3 Arena'+#0+
            'bliP'+#0+
            '1.00'+#0;
end;

exports Main, Info;

end.
