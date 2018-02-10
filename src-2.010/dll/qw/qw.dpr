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

library qw;

(* QuakeWorld Plugin for Fizz
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
  srv, plr, s, t, p, name: String;
  newChar: Char;
  b: Boolean;
  plrs, maxplrs, i, m, k, plri, rlei: Integer;
  plrnfo: Array[0..7] of String;
  time: Cardinal;
begin
  GetMem(info.ServerName, Length('Unknown') + 1);
  StrCopy(info.ServerName, PChar('Unknown'));
  GetMem(info.GameMod, Length('QuakeWorld') + 1);
  StrCopy(info.GameMod, PChar('QuakeWorld'));
  info.Players := -1;
  info.Ping := 999;
  info.IconIndex := 1;

  IdUdp := TIdUDPClient.Create(nil); //create udp
  time := GetTickCount;
  try
    IdUdp.ReceiveTimeout := (server.TimeOut div 3);
    IdUdp.Host := server.IP;
    IdUdp.Port := server.Port;
    i := 0;
    repeat
      try
        IdUdp.Send('ÿÿÿÿstatus'+Chr(0));
        s := IdUdp.ReceiveString;
        Inc(i);
      except on E: EIdSocketError do begin end; end;
    until (s <> '') or (i > 2);
  finally
    IdUdp.Free;
  end;
  i := (GetTickCount - time);
  if (i > 999) then i := 999;
  info.Ping := i;

  if (Copy(s, 1, 5) = 'ÿÿÿÿn') then begin
    srv := Copy(s, 7, Pos(#10, s)-7)+'\';
    plr := Copy(s, Pos(#10, s), Length(s));

    //plr
    maxplrs := 0;
    t := plr;
    if t = '' then
      plrs := 0
    else begin
      i := 0;
      while Pos(#10, t) > 0 do begin
        t[Pos(#10, t)] := ' ';
        Inc(i);
      end;
      plrs := i - 1;
    end;

    //srv and rules
    rlei := 0;
    m := 0;
    p := '';
    while (Length(srv) > 2) and (rlei <= 255) do begin
      s := Copy(srv, 1, Pos('\', srv)-1);
      Delete(srv, 1, Pos('\', srv));
      t := Copy(srv, 1, Pos('\', srv)-1);
      Delete(srv, 1, Pos('\', srv));
      if s = 'hostname' then begin
        GetMem(info.ServerName, Length(t) + 1);
        StrCopy(info.ServerName, PChar(t));
      end;
      if s = 'map' then begin
        GetMem(info.Map, Length(t) + 1);
        StrCopy(info.Map, PChar(t));
      end;
      if s = '*gamedir' then begin
        GetMem(info.GameMod, Length('QuakeWorld/' + t) + 1);
        StrCopy(info.GameMod, PChar('QuakeWorld/' + t));
      end;
      if s = 'maxclients' then maxplrs := StrToInt(t);
      if s = 'needpass' then m := StrToInt(t);
      GetMem(info.RuleData[rlei].Name, Length(s) + 1);
      StrCopy(info.RuleData[rlei].Name, PChar(s));
      GetMem(info.RuleData[rlei].Value, Length(t) + 1);
      StrCopy(info.RuleData[rlei].Value, PChar(t));
      Inc(rlei);
    end;
    info.Players := plrs;
    info.MaxPlayers := maxplrs;
    //icon
    {0:refreshing
    1:server not respond
    2:none
    3:server empty
    4:server full
    5:server password
    6:server password empty
    7:server password full}
    plrs := info.Players;
    maxplrs := info.MaxPlayers;
    i := 2;
    if plrs = 0 then i := 3 //empty
    else if plrs = maxplrs then i := 4; //full
    if (m > 0) then Inc(i, 3);
    info.IconIndex := i;

    //players
    plri := 0;
    while Pos(#10, plr) > 0 do begin
      k := Pos(#10, plr);
      plr[Pos(#10, plr)] := ' ';
      t := Copy(plr, k+1, Pos(#10, plr)-k-1);
      if (t <> '') and (plri <= 127) then begin
        for i := 0 to 7 do //clear source array first
          plrnfo[i] := '';
        i := 1;
        m := 0;
        b := False;
        while i <= Length(t) do begin //loop though the entire string
          if (not b) and (t[i] = ' ') then //check if we are inside our quotes, if we are then ignore the delimiter, else move to the next position in our parsed array
            Inc(m)
          else if t[i] = '"' then //will turn true the first time we hit a quote, False the second time we hit a quote
            b := not b
          else
            plrnfo[m] := plrnfo[m] + t[i];
          Inc(i);
        end;

        name := plrnfo[4];
        for i := 1 to Length(name) do begin //loop thru line
          case Ord(name[i]) of //this took a while to do :/
            001: newChar := ''; 002: newChar := ''; 003: newChar := ''; 004: newChar := ''; 005: newChar := '.'; 006: newChar := ''; 007: newChar := ''; 008: newChar := ''; 009: newChar := ''; 010: newChar := ' '; 011: newChar := ''; 012: newChar := ' '; 013: newChar := ' '; 014: newChar := '.'; 015: newChar := '.'; 016: newChar := '['; 017: newChar := ']'; 018: newChar := '0'; 019: newChar := '1'; 020: newChar := '2';
            021: newChar := '3'; 022: newChar := '4'; 023: newChar := '5'; 024: newChar := '6'; 025: newChar := '7'; 026: newChar := '8'; 027: newChar := '9'; 028: newChar := '.'; 029: newChar := '<'; 030: newChar := '-'; 031: newChar := '>'; 032: newChar := ' ';
            //33 - 126 are ok (normal white characters)
            127: newChar := '<'; 128: newChar := '('; 129: newChar := '='; 130: newChar := ')'; 131: newChar := '+'; 132: newChar := ''; 133: newChar := '.'; 134: newChar := ''; 135: newChar := ''; 136: newChar := ''; 137: newChar := ''; 138: newChar := ' '; 139: newChar := ''; 140: newChar := ' '; 141: newChar := '>'; 142: newChar := '.'; 143: newChar := '.'; 144: newChar := '['; 145: newChar := ']'; 146: newChar := '0';
            147: newChar := '1'; 148: newChar := '2'; 149: newChar := '3'; 150: newChar := '4'; 151: newChar := '5'; 152: newChar := '6'; 153: newChar := '7'; 154: newChar := '8'; 155: newChar := '9'; 156: newChar := '.'; 157: newChar := '<'; 158: newChar := '-'; 159: newChar := '>'; 160: newChar := ' '; 161: newChar := '!'; 162: newChar := '"'; 163: newChar := '#'; 164: newChar := '$'; 165: newChar := '%'; 166: newChar := '&';
            167: newChar := '''';168: newChar := '('; 169: newChar := ')'; 170: newChar := '*'; 171: newChar := '+'; 172: newChar := ','; 173: newChar := '-'; 174: newChar := '.'; 175: newChar := '/'; 176: newChar := '0'; 177: newChar := '1'; 178: newChar := '2'; 179: newChar := '3'; 180: newChar := '4'; 181: newChar := '5'; 182: newChar := '6'; 183: newChar := '7'; 184: newChar := '8'; 185: newChar := '9'; 186: newChar := ':';
            187: newChar := ';'; 188: newChar := '<'; 189: newChar := '='; 190: newChar := '>'; 191: newChar := '?'; 192: newChar := '@'; 193: newChar := 'A'; 194: newChar := 'B'; 195: newChar := 'C'; 196: newChar := 'D'; 197: newChar := 'E'; 198: newChar := 'F'; 199: newChar := 'G'; 200: newChar := 'H'; 201: newChar := 'I'; 202: newChar := 'J'; 203: newChar := 'K'; 204: newChar := 'L'; 205: newChar := 'M'; 206: newChar := 'N';
            207: newChar := 'O'; 208: newChar := 'P'; 209: newChar := 'Q'; 210: newChar := 'R'; 211: newChar := 'S'; 212: newChar := 'T'; 213: newChar := 'U'; 214: newChar := 'V'; 215: newChar := 'W'; 216: newChar := 'X'; 217: newChar := 'Y'; 218: newChar := 'Z'; 219: newChar := '['; 220: newChar := '\'; 221: newChar := ']'; 222: newChar := '^'; 223: newChar := '_'; 224: newChar := '`'; 225: newChar := 'a'; 226: newChar := 'b';
            227: newChar := 'c'; 228: newChar := 'd'; 229: newChar := 'e'; 230: newChar := 'f'; 231: newChar := 'g'; 232: newChar := 'h'; 233: newChar := 'i'; 234: newChar := 'j'; 235: newChar := 'k'; 236: newChar := 'l'; 237: newChar := 'm'; 238: newChar := 'n'; 239: newChar := 'o'; 240: newChar := 'p'; 241: newChar := 'q'; 242: newChar := 'r'; 243: newChar := 's'; 244: newChar := 't'; 245: newChar := 'u'; 246: newChar := 'v';
            247: newChar := 'w'; 248: newChar := 'x'; 249: newChar := 'y'; 250: newChar := 'z'; 251: newChar := '{'; 252: newChar := '|'; 253: newChar := '}'; 254: newChar := '~'; 255: newChar := '<';
          else
            newChar := name[i];
          end;
          name[i] := newChar;
        end;

        GetMem(info.PlayerData[plri].Name, Length(name) + 1);
        StrCopy(info.PlayerData[plri].Name, PChar(name));
        info.PlayerData[plri].Frags := StrToInt(plrnfo[1]);
        GetMem(info.PlayerData[plri].Skin, Length(plrnfo[5]) + 1);
        StrCopy(info.PlayerData[plri].Skin, PChar(plrnfo[5]));
        info.PlayerData[plri].Ping := StrToInt(plrnfo[3]);
        info.PlayerData[plri].Connect := StrToInt(plrnfo[2]);
        info.PlayerData[plri].UserID := StrToInt(plrnfo[0]);
        info.PlayerData[plri].TopColour := StrToInt(plrnfo[6]);
        info.PlayerData[plri].BottomColour := StrToInt(plrnfo[7]);
        Inc(plri);
      end;
    end;

    while (plri < 128) do begin
      info.PlayerData[plri].Ping := -1; //this player isn't used not used
      Inc(plri);
    end;
  end;

  Result := True;
end;

function Info: PChar; export;
begin
  Result := 'Fizz' +#10+ //uhh..
            'QuakeWorld' +#10+ //game name
            'bliP' +#10+ //author
            '1.00' +#10 + //version
            '27500' +#10+ //default
            '27500' +#10+ //query
            'c:\quake\q.exe' +#10+ //default exe
            '+connect %ip%'; //default params
end;

exports Main, Info;

end.
