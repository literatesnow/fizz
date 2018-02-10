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

unit player;

interface

uses
  StrUtils, SysUtils, Dialogs;

procedure VQ_ParsePlayers(index: Integer; s, p: String);
procedure QW_ParsePlayers(index: Integer; s, p: String);
function QW_ConvertLine(oldLine: String): String;
//function QW_PlayerColour(playerColour: String): Integer;
procedure HL_ParsePlayers(index: Integer; s, p: String);
procedure Q3_ParsePlayers(index: Integer; s, p: String);
function Q3_ConvertLine(oldLine: String): String;
procedure Q2_ParsePlayers(index: Integer; s, p: String);
procedure WF_ParsePlayers(index: Integer; s, p: String);
procedure T1_ParsePlayers(index: Integer; s, p: String);
procedure T2_ParsePlayers(index: Integer; s, p: String);
procedure DisplayRules(index: Integer; s: String);

implementation

uses main;

procedure DisplayRules(index: Integer; s: String);
var
  key, value: String;
  i: Integer;
begin
  if (s <> '*none') and (Length(s) > 10) then begin
    i := 0;
    while s <> '' do begin
      if i > 9000 then begin
        ShowMessage('Oops: DisplayRules Overflow');
        Exit;
      end;
      key := LeftStr(s, Pos(',', s)-1);
      value := Copy(s, Pos(',', s)+1, Pos('\', s)-1-Pos(',', s));
      frmMain.lvwRule.Items.Add;
      frmMain.lvwRule.Items[i].Caption := key;
      frmMain.lvwRule.Items[i].SubItems.Add(value);
      s := Copy(s, Pos('\', s)+1, Length(s));
      Inc(i);
    end;
  end;
end;

procedure VQ_ParsePlayers(index: Integer; s, p: String);
var
  i, j, top, bot, frags: Integer;
  connect: Single;
  name, ip: String;
begin
  with frmMain do begin
    lvwPlayer.SmallImages := imgPlayer;
    lvwPlayer.SmallImages.Width := 34;
  end;
  if (p <> '*none') and (s <> '*none') then begin
    j := 0;
    while Length(p) > 2 do begin
      Delete(p, 1, 7); //header crap
      name := Copy(p, 1, Pos(#0, p)-1); //name
      Delete(p, 1, Pos(#0, p));

      i := Ord(p[1]);
      top := i shr 4; //top colour
      bot := i and $F; //bottom colour
      Delete(p, 1, 4);

      i := Ord(p[1+3]);
      i := (i shl 8) + Ord(p[1+2]);
      i := (i shl 8) + Ord(p[1+1]);
      i := (i shl 8) + Ord(p[1]);
      frags := i; //frags
      Delete(p, 1, 4);

      i := Ord(p[1+3]);
      i := (i shl 8) + Ord(p[1+2]);
      i := (i shl 8) + Ord(p[1+1]);
      i := (i shl 8) + Ord(p[1]);
      connect := (i div 60); //connect time
      Delete(p, 1, 4);

      ip := Copy(p, 1, Pos(#0, p)-1);
      Delete(p, 1, Pos(#0, p));

      frmMain.lvwPlayer.Items.Add;
      for i := 0 to frmMain.lvwPlayer.Columns.Count-1+2 do
        frmMain.lvwPlayer.Items[j].SubItems.Add('');
      frmMain.SetPlayerItem(j, 0, QW_ConvertLine(name));
      frmMain.SetPlayerItem(j, 1, IntToStr(frags));
      frmMain.SetPlayerItem(j, 2, ip);
      frmMain.SetPlayerItem(j, 4, FloatToStr(connect));
      frmMain.SetPlayerItem(j, 5, IntToStr(j));
      frmMain.SetPlayerItem(j, 6, IntToStr(top)); //top
      frmMain.SetPlayerItem(j, 7, IntToStr(bot)); //bottom
      Inc(j);
    end;
    frmMain.SortPlayer;  //sort
  end;
end;

function QW_ConvertLine(oldLine: String): String; //fix this char=char|128 will do?
var
  i: Integer;
  newLine: String;
  newChar: Char;
begin
  newLine := '';
  for i := 1 to Length(oldLine) do begin //loop thru line
    case Ord(oldLine[i]) of //this took a while to do :/
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
      newChar := oldLine[i];
    end;
    newLine := newLine + newChar; //generate new line
  end;
  Result := newLine;
end;

{function QW_PlayerColour(playerColour: String): Integer; oh this isn't used anymore
begin
  case StrToInt(playerColour) of
    0: Result := 0; 4: Result := 1; 14: Result := 2; 24: Result := 3; 34: Result := 4; 44: Result := 5;
    54: Result := 6; 64: Result := 7; 74: Result := 8; 84: Result := 9; 94: Result := 10; 104: Result := 11;
    114: Result := 12; 124: Result := 13; 134: Result := 14; 13: Result := 15; 113: Result := 16; 213: Result := 17;
    313: Result := 18; 413: Result := 19; 513: Result := 20; 613: Result := 21; 713: Result := 22; 813: Result := 23;
    913: Result := 24; 1013: Result := 25; 1113: Result := 26; 1213: Result := 27; 1313: Result := 28; 11: Result := 29;
    111: Result := 30; 211: Result := 31; 311: Result := 32; 411: Result := 33; 511: Result := 34; 611: Result := 35;
    711: Result := 36; 811: Result := 37; 911: Result := 38; 1011: Result := 39; 1111: Result := 40; 1211: Result := 41;
    1311: Result := 42; 12: Result := 43; 112: Result := 44; 212: Result := 45; 312: Result := 46; 412: Result := 47;
    512: Result := 48; 612: Result := 49; 712: Result := 50; 812: Result := 51; 912: Result := 52; 1012: Result := 53;
    1112: Result := 54; 1212: Result := 55; 1312: Result := 56;
  else
    Result := 0;
  end;
end;}

procedure QW_ParsePlayers(index: Integer; s, p: String);
var
  insideQuotes: Boolean;
  i, j, m, k, l: Integer;
  parseThis: String;
  playerInfo: Array[0..7] of String;
begin
  with frmMain do begin
    lvwPlayer.SmallImages := imgPlayer;
    lvwPlayer.SmallImages.Width := 34;
  end;
  if (p <> '*none') and (s <> '*none') then begin
    //players
    j := 0;
    while Pos(Chr(10), p) > 0 do begin
      k := Pos(Chr(10), p);
      p[Pos(Chr(10), p)] := ' ';
      parseThis := Copy(p, k+1, Pos(Chr(10), p)-k-1);
      if parseThis <> '' then begin
        for i := 0 to 7 do //clear source array first
          playerInfo[i] := '';
        i := 1;
        m := 0;
        insideQuotes := False;
        while i <= Length(parseThis) do begin //loop though the entire string
          if (not insideQuotes) and (parseThis[i] = ' ') then //check if we are inside our quotes, if we are then ignore the delimiter, else move to the next position in our parsed array
            Inc(m)
          else if parseThis[i] = '"' then // will turn true the first time we hit a quote, False the second time we hit a quote
            insideQuotes := not insideQuotes
          else
            playerInfo[m] := playerInfo[m] + parseThis[i];
          Inc(i);
        end;
        frmMain.lvwPlayer.Items.Add;
        for l := 0 to frmMain.lvwPlayer.Columns.Count-1+2 do
          frmMain.lvwPlayer.Items[j].SubItems.Add('');
        frmMain.SetPlayerItem(j, 0, QW_ConvertLine(playerInfo[4]));
        frmMain.SetPlayerItem(j, 1, playerInfo[1]);
        frmMain.SetPlayerItem(j, 2, playerInfo[5]);
        frmMain.SetPlayerItem(j, 3, playerInfo[3]);
        frmMain.SetPlayerItem(j, 4, playerInfo[2]);
        frmMain.SetPlayerItem(j, 5, playerInfo[0]);
        frmMain.SetPlayerItem(j, 6, playerInfo[6]); //top
        frmMain.SetPlayerItem(j, 7, playerInfo[7]); //bottom
        Inc(j);
      end;
    end;
    frmMain.SortPlayer;  //sort
  end;
end;

procedure HL_ParsePlayers(index: Integer; s, p: String);
var
  name, userid, frags, time: String;
  i, j, k, l: Integer;
begin
  if (p <> '*none') and (s <> '*none') then begin
    j := 7;
    l := 0;
    for i := 1 to Ord(p[6]) do begin
      userid := IntToStr(Ord(p[j]));
      Inc(j);
      name := '';
      time := '';
      while p[j] <> Chr(0) do begin
        name := name + p[j];
        Inc(j);
      end;
      Inc(j);
      frags := IntToStr(Ord(p[j]));
      Inc(j, 4);
      for k := 1 to 4 do begin
        time := time + p[j];
        Inc(j);
      end;
      time := '';
      frmMain.lvwPlayer.Items.Add;
      for k := 0 to frmMain.lvwPlayer.Columns.Count-1 do
        frmMain.lvwPlayer.Items[l].SubItems.Add('');
      frmMain.SetPlayerItem(l, 0, name);
      frmMain.SetPlayerItem(l, 1, frags);
      frmMain.SetPlayerItem(l, 4, time);
      frmMain.SetPlayerItem(l, 5, userid);
      Inc(l);
    end;
    frmMain.SortPlayer;
  end;
end;

procedure Q3_ParsePlayers(index: Integer; s, p: String);
var
  insideQuotes: Boolean;
  i, j, m, k, l: Integer;
  parseThis: String;
  playerInfo: Array[0..2] of String;
begin
  if (p <> '*none') and (s <> '*none') then begin
    //players
    j := 0;
    while Pos(Chr(10), p) > 0 do begin
      k := Pos(Chr(10), p);
      p[Pos(Chr(10), p)] := ' ';
      parseThis := Copy(p, k+1, Pos(Chr(10), p)-k-1);
      if parseThis <> '' then begin
        for i := 0 to 2 do //clear source array first
          playerInfo[i] := '';
        i := 1;
        m := 0;
        insideQuotes := False;
        while i <= Length(parseThis) do begin //loop though the entire string
          if (not insideQuotes) and (parseThis[i] = ' ') then //check if we are inside our quotes, if we are then ignore the delimiter, else move to the next position in our parsed array
            Inc(m)
          else if parseThis[i] = '"' then // will turn true the first time we hit a quote, False the second time we hit a quote
            insideQuotes := not insideQuotes
          else
            playerInfo[m] := playerInfo[m] + parseThis[i];
          Inc(i);
        end;
        frmMain.lvwPlayer.Items.Add;
        for l := 0 to frmMain.lvwPlayer.Columns.Count-1 do
          frmMain.lvwPlayer.Items[j].SubItems.Add('');
        frmMain.SetPlayerItem(j, 0, Q3_ConvertLine(playerInfo[2]));
        frmMain.SetPlayerItem(j, 1, playerInfo[0]);
        frmMain.SetPlayerItem(j, 3, playerInfo[1]);
        frmMain.SetPlayerItem(j, 5, IntToStr(j+1));
        Inc(j);
      end;
    end;
    frmMain.SortPlayer; //sort
  end;
end;

function Q3_ConvertLine(oldLine: String): String;
var
  i: Integer;
  newLine: String;
begin
  i := 1;
  if Pos('^', oldLine) > 0 then begin
    while i < Length(oldLine)+1 do begin
      if (oldLine[i] = '^') and (Ord(oldLine[i+1]) in [48..57]) then
        Inc(i, 2)
      else begin
        newLine := newLine + oldLine[i];
        Inc(i);
      end;
    end;
    Result := newLine;
  end
  else
    Result := oldLine;
end;

procedure Q2_ParsePlayers(index: Integer; s, p: String);
var
  insideQuotes: Boolean;
  i, j, m, k, l: Integer;
  parseThis: String;
  playerInfo: Array[0..3] of String;
begin
  if (p <> '*none') and (s <> '*none') then begin
    //players
    j := 0;
    while Pos(Chr(10), p) > 0 do begin
      k := Pos(Chr(10), p);
      p[Pos(Chr(10), p)] := ' ';
      parseThis := Copy(p, k+1, Pos(Chr(10), p)-k-1);
      if parseThis <> '' then begin
        for i := 0 to 2 do //clear source array first
          playerInfo[i] := '';
        i := 1;
        m := 0;
        insideQuotes := False;
        while i <= Length(parseThis) do begin //loop though the entire string
          if (not insideQuotes) and (parseThis[i] = ' ') then //check if we are inside our quotes, if we are then ignore the delimiter, else move to the next position in our parsed array
            Inc(m)
          else if parseThis[i] = '"' then // will turn true the first time we hit a quote, False the second time we hit a quote
            insideQuotes := not insideQuotes
          else
            playerInfo[m] := playerInfo[m] + parseThis[i];
          Inc(i);
        end;
        frmMain.lvwPlayer.Items.Add;
        for l := 0 to frmMain.lvwPlayer.Columns.Count-1 do
          frmMain.lvwPlayer.Items[j].SubItems.Add('');
        frmMain.SetPlayerItem(j, 0, playerInfo[2]);
        frmMain.SetPlayerItem(j, 1, playerInfo[0]);
        frmMain.SetPlayerItem(j, 3, playerInfo[1]);
        frmMain.SetPlayerItem(j, 5, IntToStr(j+1));
        Inc(j);
      end;
    end;
    frmMain.SortPlayer; //sort
  end;
end;

procedure WF_ParsePlayers(index: Integer; s, p: String);
var
  insideQuotes: Boolean;
  i, j, m, k, l: Integer;
  parseThis: String;
  playerInfo: Array[0..2] of String;
begin
  if (p <> '*none') and (s <> '*none') then begin
    //players
    j := 0;
    while Pos(Chr(10), p) > 0 do begin
      k := Pos(Chr(10), p);
      p[Pos(Chr(10), p)] := ' ';
      parseThis := Copy(p, k+1, Pos(Chr(10), p)-k-1);
      if parseThis <> '' then begin
        for i := 0 to 2 do //clear source array first
          playerInfo[i] := '';
        i := 1;
        m := 0;
        insideQuotes := False;
        while i <= Length(parseThis) do begin //loop though the entire string
          if (not insideQuotes) and (parseThis[i] = ' ') then //check if we are inside our quotes, if we are then ignore the delimiter, else move to the next position in our parsed array
            Inc(m)
          else if parseThis[i] = '"' then // will turn true the first time we hit a quote, False the second time we hit a quote
            insideQuotes := not insideQuotes
          else
            playerInfo[m] := playerInfo[m] + parseThis[i];
          Inc(i);
        end;
        frmMain.lvwPlayer.Items.Add;
        for l := 0 to frmMain.lvwPlayer.Columns.Count-1 do
          frmMain.lvwPlayer.Items[j].SubItems.Add('');
        frmMain.SetPlayerItem(j, 0, Q3_ConvertLine(playerInfo[2])); //name0r
        frmMain.SetPlayerItem(j, 1, playerInfo[0]);
        frmMain.SetPlayerItem(j, 3, playerInfo[1]);
        frmMain.SetPlayerItem(j, 5, IntToStr(j+1));
        Inc(j);
      end;
    end;
    frmMain.SortPlayer; //sort
  end;
end;

procedure T1_ParsePlayers(index: Integer; s, p: String);
var
  i, j: Integer;
  name, ping, frags: String;
begin
  if (s <> '*none') and (p <> '*none') then begin
    i := 0;
    while p <> '' do begin
      ping := IntToStr(Ord(p[1])*4);
      j := Ord(p[4]);
      name := Copy(p, 5, j);
      Delete(p, 1, j+4);
      j := Ord(p[1]);
      frags := Trim(Copy(p, 7, 5));
      Delete(p, 1, j+1);

      frmMain.lvwPlayer.Items.Add;
      for j := 0 to frmMain.lvwPlayer.Columns.Count-1 do
        frmMain.lvwPlayer.Items[i].SubItems.Add('');
      frmMain.SetPlayerItem(i, 0, name);
      frmMain.SetPlayerItem(i, 1, frags);
      frmMain.SetPlayerItem(i, 3, ping);
      frmMain.SetPlayerItem(i, 5, IntToStr(i));
      Inc(i);
      //Delete(p, 1, 11);
    end;
    frmMain.SortPlayer; //sort
  end;
end;

procedure T2_ParsePlayers(index: Integer; s, p: String);
var
  i, j: Integer;
  tmp, name, frags: String;
begin
  if (s <> '*none') and (p <> '*none') then begin
    i := 0;
    while p <> #$A do begin
      name := '';
      tmp := Copy(p, 4, Pos(#$11, p)-4);
      for j := 1 to Length(tmp) do
        if Ord(tmp[j]) > 31 then
          name := name + tmp[j]
        else
          name := name + ' ';
      Delete(p, 1, Pos(#$11, p)+1);
      Delete(p, 1, Pos(#9, p));
      frags := Copy(p, 1, Pos(#$A, p)-1);
      Delete(p, 1, Pos(#$A, p)-1);

      frmMain.lvwPlayer.Items.Add;
      for j := 0 to frmMain.lvwPlayer.Columns.Count-1 do
        frmMain.lvwPlayer.Items[i].SubItems.Add('');
      frmMain.SetPlayerItem(i, 0, name);
      frmMain.SetPlayerItem(i, 1, frags);
      frmMain.SetPlayerItem(i, 5, IntToStr(i));
      Inc(i);
    end;
    frmMain.SortPlayer; //sort
  end;
end;

end.
