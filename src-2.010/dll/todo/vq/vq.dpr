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

library vq;

(* Quake Plugin for Fizz
 * Copyright (C) 2003 bliP
 * Version 1.00
 * http://nisda.net
 *)

uses IdUDPClient, IdException, SysUtils;

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
    Ping: PChar;
    Players: Integer;
    MaxPlayers: Integer;
    GameMod: PChar;
    IP: PChar;
    Port: Integer;
    IconIndex: Integer;
    PlayerData: Array[0..127] of TPlayerData;
    RuleData: Array[0..255] of TRuleData;
  end;

type
  TThisServer = record
    IP: PChar;
    Port: Integer;
    TimeOut: Integer;
    Game: Integer;
  end;

function Main(var server: TThisServer; var info: TServerData): boolean; stdcall; export;
var
  IdUdp: TIdUDPClient;
  s, t: String;
  newChar: Char;
  rlei, i, m: Integer;
begin
  IdUdp := TIdUDPClient.Create(nil); //create udp
  try
    IdUdp.ReceiveTimeout := server.TimeOut;
    IdUdp.Host := server.IP;
    IdUdp.Port := server.Port;
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send(#128+#00+#00+#12+#02+'QUAKE'+#00+#03);
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);

    //serverinfo
    rlei := 0;
    Delete(s, 1, 5);
    //serverip := Copy(s, 1, Pos(#0, s) - 1); //server address
    Delete(s, 1, Pos(#0, s));

    t := Copy(s, 1, Pos(#0, s) - 1); //hostname
    GetMem(info.ServerName, Length(t) + 1);
    StrCopy(info.ServerName, PChar(t));
    Delete(s, 1, Pos(#0, s));

    t := Copy(s, 1, Pos(#0, s) - 1); //map
    GetMem(info.Map, Length(t) + 1);
    StrCopy(info.Map, PChar(t));
    Delete(s, 1, Pos(#0, s));

    info.Players := Ord(s[1]);
    info.MaxPlayers := Ord(s[2]);

    t := 'protocol';
    GetMem(info.RuleData[rlei].Name, Length(s) + 1);
    StrCopy(info.RuleData[rlei].Name, PChar(s));
    t := IntToStr(Ord(s[3]));
    GetMem(info.RuleData[rlei].Value, Length(s) + 1);
    StrCopy(info.RuleData[rlei].Value, PChar(s));
    Inc(rlei);

    s := 'Quake';
    GetMem(info.GameMod, Length(s) + 1);
    StrCopy(info.GameMod, PChar(s));

    //icons
    info.IconIndex := 3;
    if info.Players = info.MaxPlayers then info.IconIndex := 2; //full
    if info.Players = 0 then info.IconIndex := 1; //empty

    //rules
    i := 0;
    repeat
      Inc(i);
      IdUdp.Send(#128+#00+#00+#06+#04+#00); //rule request
      s := IdUdp.ReceiveString;
    until (s <> '') or (i > 3);
    while (Length(s) > 5) do begin
      Delete(s, 1, 5);
      t := Trim(Copy(s, 1, Pos(#0, s)-1));
      GetMem(info.RuleData[rlei].Name, Length(t) + 1);
      StrCopy(info.RuleData[rlei].Name, PChar(t));

      Delete(s, 1, Pos(#0, s));
      t := Trim(Copy(s, 1, Pos(#0, s)-1));
      GetMem(info.RuleData[rlei].Value, Length(t) + 1);
      StrCopy(info.RuleData[rlei].Value, PChar(t));

      t := #128+#00+#00+' '+#04 + info.RuleData[rlei].Name; //make next packet to send
      t[4] := Chr(Length(t));
      Inc(rlei);
      i := 0;
      repeat
        Inc(i);
        IdUdp.send(t);
        s := IdUdp.ReceiveString;
      until (s <> '') or (i > 3);
     end;

    //players
    for m := 0 to info.Players-1 do begin
      i := 0;
      repeat
        Inc(i);
        IdUdp.Send(#128+#00+#00+#6+#03+Chr(m));
        s := IdUdp.ReceiveString;
      until (i > 3) or (s <> '');
      if s <> '' then begin
        Delete(s, 1, 7); //header junk
        t := Copy(s, 1, Pos(#0, s)-1); //name
        for i := 1 to Length(t) do begin //loop thru line
          case Ord(t[i]) of //this took a while to do :/
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
            newChar := t[i];
          end;
          t[i] := newChar;
        end;

        GetMem(info.PlayerData[m].Name, Length(t) + 1);
        StrCopy(info.PlayerData[m].Name, PChar(t));

        i := Ord(s[1]);
        info.PlayerData[m].TopColour := i shr 4;
        info.PlayerData[m].BottomColour := i and $F;
        Delete(s, 1, 4);

        i := Ord(s[1+3]);
        i := (i shl 8) + Ord(s[1+2]);
        i := (i shl 8) + Ord(s[1+1]);
        i := (i shl 8) + Ord(s[1]);
        info.PlayerData[m].Frags := i;
        Delete(s, 1, 4);

        i := Ord(s[1+3]);
        i := (i shl 8) + Ord(s[1+2]);
        i := (i shl 8) + Ord(s[1+1]);
        i := (i shl 8) + Ord(s[1]);
        info.PlayerData[m].Connect := (i div 60);
        Delete(s, 1, 4);

        t := Copy(s, 1, Pos(#0, s)-1);
        GetMem(info.PlayerData[m].Skin, Length(t) + 1);
        StrCopy(info.PlayerData[m].Skin, PChar(t));

        Delete(s, 1, Pos(#0, s));
        //Inc(plri);
      end;
    end;
  finally
    IdUdp.Free;
  end;

  Result := true;
end;

function Info: PChar; export;
begin
  Result := 'Fizz' +#10+
            'Quake' +#10+
            '26000' +#10+
            'bliP' +#10+
            '1.00' +#10;
end;

exports Main, Info;

end.
