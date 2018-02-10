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

unit server;

interface

uses
  Classes, WinProcs, StrUtils, SysUtils, IdUDPClient, IdIcmpClient;

type
  GetServer = class(TThread)
  public
    qryAddress: String;
    qryPort, qryGame, timeOut, arrayIndex: Integer;
    startTime: LongInt;
    last: Boolean;
  private
    recData,
    s_Info, p_Info,
    s_HostName, s_Map, s_GameDir, s_Ping,
    p_Total: String;
    s_Image: Integer;
    replyTime: LongInt;
  protected
    procedure Execute; override;
    procedure VQ_ParseInfo;
    procedure QW_ParseInfo;
    procedure Q2_ParseInfo;
    procedure Q3_ParseInfo;
    procedure WF_ParseInfo;
    procedure T1_ParseInfo;
    procedure T2_ParseInfo1;
    procedure T2_ParseInfo2;
    procedure HL_ParseInfo1;
    procedure HL_ParseInfo2;
    procedure SetInfo;
  end;

implementation

uses Main;

{ GetServer }

procedure GetServer.Execute;
var
  IdUdp: TIdUDPClient;
begin
  if Terminated then Exit;
  try
    IdUdp := TIdUDPClient.Create(nil); //create udp
    try
      IdUdp.ReceiveTimeout := timeOut;
      IdUdp.Host := qryAddress;
      IdUdp.Port := qryPort;
      case qryGame of //GAME_ADD
        0: begin //VQ
             try
               IdUdp.Send(#128+#00+#00+#12+#02+'QUAKE'+#00+#03);
               recData := IdUdp.ReceiveString;
               if recData <> '' then VQ_ParseInfo;
             finally
               Synchronize(SetInfo);
             end;
           end;
        1: begin //QW
             try
               IdUdp.Send('ÿÿÿÿstatus'+Chr(0)); //send packet
               recData := IdUdp.ReceiveString; //receive packet
               if recData <> '' then QW_ParseInfo; //parse it
             finally
               Synchronize(SetInfo); //update lvwServer
             end;
           end;
        2: begin //Q2
             try
               IdUdp.Send('ÿÿÿÿstatus'+Chr(0));
               recData := IdUdp.ReceiveString;
               if recData <> '' then Q2_ParseInfo;
             finally
               Synchronize(SetInfo);
             end;
           end;
        3: begin //Q3
             try
               IdUdp.Send('ÿÿÿÿgetstatus'+Chr(0));
               recData := IdUdp.ReceiveString;
               if recData <> '' then Q3_ParseInfo;
             finally
               Synchronize(SetInfo);
             end;
            end;
        4: begin //HL
             try
               IdUdp.Send('ÿÿÿÿinfo'+Chr(0));
               recData := IdUdp.ReceiveString;
               if recData <> '' then HL_ParseInfo1;
               IdUdp.Send('ÿÿÿÿrules'+Chr(0));
               recData := IdUdp.ReceiveString;
               if recData <> '' then HL_ParseInfo2;
               IdUdp.Send('ÿÿÿÿplayers'+Chr(0));
               recData := IdUdp.ReceiveString;
               if recData <> '' then p_Info := recData;
             finally
               Synchronize(SetInfo);
             end;
           end;
        5: begin //WF
             try
               IdUdp.Send('ÿÿÿÿgetstatus'+Chr(0));
               recData := IdUdp.ReceiveString;
               if recData <> '' then WF_ParseInfo;
             finally
               Synchronize(SetInfo);
             end;
           end;
        6: begin //T1
             try
               IdUdp.Send('b++');
               recData := IdUdp.ReceiveString;
               if recData <> '' then T1_ParseInfo;
             finally
               Synchronize(SetInfo);
             end;
           end;
        7: begin //T2
             try
               IdUdp.Send(#14+#2+#1+#1+#1+#1+#0); //ping
               recData := IdUdp.ReceiveString;
               if recData <> '' then T2_ParseInfo1;
               IdUdp.Send(#18+#2+#1+#1+#1+#1+#0); //query
               recData := IdUdp.ReceiveString;
               if recData <> '' then T2_ParseInfo2;
             finally
               Synchronize(SetInfo);
             end;
           end;
      end;
    finally
      IdUdp.Free;
    end;
  finally
    Terminate;
  end;
end;

procedure GetServer.SetInfo;
var
  i, j: Integer;
  b: Boolean;
begin
  with frmMain do begin
    if recData <> '' then begin //got reply update serverData
      s_Ping := IntToStr(replyTime - startTime);
      serverData[arrayIndex].ServerName := s_HostName;
      serverData[arrayIndex].Ping := s_Ping;
      serverData[arrayIndex].Map := s_Map;
      serverData[arrayIndex].Players := p_Total;
      serverData[arrayIndex].GameMod := s_GameDir;
      serverData[arrayIndex].PlayerData := p_Info;
      serverData[arrayIndex].RuleData := s_Info;
      serverData[arrayIndex].Image := s_Image;
    end
    else begin //no reply
      s_HostName := serverData[arrayIndex].ServerName;
      s_Ping := '999';
      s_Map := '';
      p_Total := '';
      s_Image := (10 * qryGame) + 3;
      s_GameDir := serverData[arrayIndex].GameMod;
      serverData[arrayIndex].Ping := '999';
      serverData[arrayIndex].PlayerData := '*none';
      serverData[arrayIndex].RuleData := '*none';
      serverData[arrayIndex].Image := s_Image;
    end;

    b := False;  //assume server not in list
    j := lvwServer.Items.Count - 1;
    i := 0;
    if j > -1 then begin //look for server in lvwServer
      repeat
        if GetServerItem(i, 6) = IntToStr(arrayIndex) then
          b := True //found server in list
        else
          Inc(i);
      until b or (i > j);
    end;

    //add/update server in lvwserver
    if FilterItem(serverData[arrayIndex], True) then begin //action: update, remove, add
      //passed filter
      if not b then begin //not in list, add
        i := j + 1;
        lvwServer.Items.Add;
        for j := 0 to 6 do
          lvwServer.Items[i].SubItems.Add('');
      end;
      //update
      SetServerItem(i, 0, s_HostName);
      SetServerItem(i, 1, s_Ping);
      SetServerItem(i, 2, serverData[arrayIndex].Address);
      SetServerItem(i, 3, s_Map);
      SetServerItem(i, 4, p_Total);
      SetServerItem(i, 5, s_GameDir);
      SetServerItem(i, 6, IntToStr(arrayIndex));
      lvwServer.Items[i].ImageIndex := s_Image;
    end
    else //didnt pass filter
      if b then //in list remove it
        lvwServer.Items[i].Delete;

    if last then SortServer;
    if lvwServer.SelCount > 0 then
      if IntToStr(arrayIndex) = GetServerItem(lvwServer.Selected.Index, 6) then begin
        Sleep(500);
        Display(lvwServer.Selected.Index);
      end;
  end;
end;

procedure GetServer.VQ_ParseInfo;
var
  s: String;
  i, j, m: Integer;
  IdUdp: TIdUDPClient;
begin
  replyTime := GetTickCount;
  s := recData;
  //serverinfo
  Delete(s, 1, 5);
  //serverip := Copy(s, 1, Pos(#0, s) - 1); //server address
  Delete(s, 1, Pos(#0, s));
  s_HostName := Copy(s, 1, Pos(#0, s) - 1); //hostname
  Delete(s, 1, Pos(#0, s));
  s_Map := Copy(s, 1, Pos(#0, s) - 1); //map
  Delete(s, 1, Pos(#0, s));
  i := Ord(s[1]);
  j := Ord(s[2]);
  p_Total := IntToStr(i) + '/' + //num players
             IntToStr(j); //max players
  //prot := IntToStr(Ord(s[3])); //protocol
  //icons
  s_Image := 6;
  if i = j then s_Image := 2; //full
  if i = 0 then s_Image := 1; //empty
  p_Info := '';
  s_Info := '';
  IdUdp := TIdUDPClient.Create(nil);
  try
    IdUdp.ReceiveTimeout := 1000;//timeOut;
    IdUdp.Host := qryAddress;
    IdUdp.Port := qryPort;
    //players
    for m := 0 to i-1 do begin
      j := 0;
      repeat
        Inc(j);
        IdUdp.Send(#128+#00+#00+#6+#03+Chr(m));
        s := IdUdp.ReceiveString;
      until (j > 4) or (s <> '');
      if s <> '' then p_Info := p_Info + '\' + s;
    end;
    //rules
    IdUdp.Send(#128+#00+#00+#06+#04+#0);
    s := IdUdp.ReceiveString;
    IdUdp.Send(#128+#00+#00+#06+'sv_maxspeed'+#0);
    s := IdUdp.ReceiveString;
    s_Info := s;
  finally
    IdUdp.Free;
  end;
end;

procedure GetServer.QW_ParseInfo;
var
  ts_Info, tp_Info, s_PwdReq, p_Num, p_Max, key, value: String;
  i, ts_Image: Integer;
  b: Boolean;
begin
  replyTime := GetTickCount;
  ts_Info := Copy(recData, 7, Pos(Chr(10), recData)-7)+'\';
  tp_Info := Copy(recData, Pos(Chr(10), recData), Length(recData));
  b := True;
  for i := 1 to Length(ts_Info) do
    if (ts_Info[i] = '\') then begin
      if b then
        ts_Info[i] := ',';
      b := not b;
    end;
  s_Info := ts_Info; //server info
  p_Info := tp_Info; //player info
  //serverinfo
  s_GameDir := 'QuakeWorld';
  while ts_Info <> '' do begin
    key := LeftStr(ts_Info, Pos(',', ts_Info)-1);
    value := Copy(ts_Info, Pos(',', ts_Info)+1, Pos('\', ts_Info)-1-Pos(',', ts_Info));
    if key = 'hostname' then s_HostName := value;
    if key = 'map' then s_Map := value;
    if key = '*gamedir' then s_GameDir := s_GameDir + '/' + value;
    if key = 'maxclients' then p_Max := value;
    if key = 'needpass' then s_PwdReq := value;
    ts_Info := Copy(ts_Info, Pos('\', ts_Info)+1, Length(ts_Info));
  end;
  //players
  if tp_Info = '' then
    p_Num := '0'
  else begin
    i := 0;
    while Pos(Chr(10), tp_Info) > 0 do begin
      tp_Info[Pos(Chr(10), tp_Info)] := ' ';
      Inc(i);
    end;
    p_Num := IntToStr(i-1);
  end;
  if p_Max = '' then p_Max := '0';
  p_Total := p_Num + '/' + p_Max;
  //icons
  ts_Image := 16;
  if p_Num = p_Max then ts_Image := 12; //full
  if p_Num = '0' then ts_Image := 11; //empty
  if s_PwdReq <> '' then
    if StrToInt(s_PwdReq) > 0 then begin
      if (p_Num <> '0') and (p_Num <> p_Max) then ts_Image := 17; //pw
      if p_Num = '0' then ts_Image := 14; //pw empty
      if p_Num = p_Max then ts_Image := 15; //pw full
    end;
  s_Image := ts_Image;
end;

procedure GetServer.Q3_ParseInfo;
var
  ts_Info, tp_Info, s_PwdReq, p_Num, p_Max, key, value: String;
  i, ts_Image: Integer;
  b: Boolean;
begin
  replyTime := GetTickCount;
  recData[Pos(Chr(10), recData)] := ' ';
  ts_Info := Copy(recData, 21, Pos(Chr(10), recData)-21)+'\';
  tp_Info := Copy(recData, Pos(Chr(10), recData), Length(recData));
  b := True;
  for i := 1 to Length(ts_Info) do
    if (ts_Info[i] = '\') then begin
      if b then
        ts_Info[i] := ',';
      b := not b;
    end;
  s_Info := ts_Info;
  p_Info := tp_Info;
  s_GameDir := 'Quake 3';
  while ts_Info <> '' do begin
    key := LeftStr(ts_Info, Pos(',', ts_Info)-1);
    value := Copy(ts_Info, Pos(',', ts_Info)+1, Pos('\', ts_Info)-1-Pos(',', ts_Info));
    if key = 'sv_hostname' then s_HostName := value;
    if key = 'mapname' then s_Map := value;
    if key = 'gamename' then s_GameDir := s_GameDir + '/'+value;
    if key = 'sv_maxclients' then p_Max := value;
    if key = 'g_needpass' then s_PwdReq := value;
    ts_Info := Copy(ts_Info, Pos('\', ts_Info)+1, Length(ts_Info));
  end;
  //players
  if tp_Info = '' then
    p_Num := '0'
  else begin
    i := 0;
    while Pos(Chr(10), tp_Info) > 0 do begin
      tp_Info[Pos(Chr(10), tp_Info)] := ' ';
      Inc(i);
    end;
    p_Num := IntToStr(i-1);
  end;
  if p_Max = '' then p_Max := '0';
  p_Total := p_Num + '/' + p_Max;
  //icons
  ts_Image := 36;
  if p_Num = p_Max then ts_Image := 32; //full
  if p_Num = '0' then ts_Image := 31; //empty
  if s_PwdReq <> '' then
    if StrToInt(s_PwdReq) > 0 then begin
      if (p_Num <> '0') and (p_Num <> p_Max) then ts_Image := 37; //pw
      if p_Num = '0' then ts_Image := 34; //pw empty
      if p_Num = p_Max then ts_Image := 35; //pw full
    end;
  s_Image := ts_Image;
end;

procedure GetServer.HL_ParseInfo1;
var
  ts_Info: String;
begin
  replyTime := GetTickCount;
  s_GameDir := 'Half-Life';
  ts_Info := Copy(recData, Pos(Chr(0), recData)+1, Length(recData));
  s_HostName := Copy(ts_Info, 1, Pos(Chr(0), ts_Info)-1);
  ts_Info := Copy(ts_Info, Pos(Chr(0), ts_Info)+1, Length(ts_Info));
  s_Map := Copy(ts_Info, 1, Pos(Chr(0), ts_Info)-1);
  ts_Info := Copy(ts_Info, Pos(Chr(0), ts_Info)+1, Length(ts_Info));
  s_GameDir := s_GameDir+'/'+Copy(ts_Info, 1, Pos(Chr(0), ts_Info)-1);
  p_Total := IntToStr(Ord(ts_Info[Length(ts_Info)-2])) + '/' + IntToStr(Ord(ts_Info[Length(ts_Info)-1]));
end;

procedure GetServer.HL_ParseInfo2;
var
  ts_Info, s_PwdReq, p_Num, p_Max, key, value: String;
  b: Boolean;
  i: Integer;
begin
  ts_Info := Copy(recData, 8, Length(recData));
  //p_Num := IntToStr(Ord(recData[5]));
  b := True;
  for i := 1 to Length(ts_Info) do
    if (ts_Info[i] = Chr(0)) then begin
      if b then
        ts_Info[i] := ','
      else
        ts_Info[i] := '\';
      b := not b;
    end;
  while ts_Info[Length(ts_Info)] <> '\' do
    ts_Info := Copy(ts_Info, 1, Length(ts_Info)-1);
  s_Info := ts_Info;
  b := False;
  while (ts_Info <> '') and not b do begin
    key := LeftStr(ts_Info, Pos(',', ts_Info)-1);
    value := Copy(ts_Info, Pos(',', ts_Info)+1, Pos('\', ts_Info)-1-Pos(',', ts_Info));
    if key = 'sv_password' then begin
      s_PwdReq := value;
      b := True;
    end;
    ts_Info := Copy(ts_Info, Pos('\', ts_Info)+1, Length(ts_Info));
  end;
  p_Num := Copy(p_Total, 1, Pos('/', p_Total)-1);
  p_Max := Copy(p_Total, Pos('/', p_Total)+1, Length(p_Total));
  if p_Num <> p_Max then s_Image := 46; //players
  if p_Num = '0' then s_Image := 41; //empty
  if p_Num = p_Max then s_Image := 42; //full
  if StrToInt(s_PwdReq) = 1 then
    case s_Image of
      16: s_Image := 47; //pw
      11: s_Image := 44; //pw empty
      12: s_Image := 45 //pw full
    end;
end;

procedure GetServer.Q2_ParseInfo;
var
  ts_Info, tp_Info, s_PwdReq, p_Num, p_Max, key, value: String;
  i, ts_Image: Integer;
  b: Boolean;
begin
  replyTime := GetTickCount;
  recData[Pos(Chr(10), recData)] := ' ';
  ts_Info := Copy(recData, 12, Pos(Chr(10), recData)-12)+'\';
  tp_Info := Copy(recData, Pos(Chr(10), recData), Length(recData));
  b := True;
  for i := 1 to Length(ts_Info) do
    if (ts_Info[i] = '\') then begin
      if b then
        ts_Info[i] := ',';
      b := not b;
    end;
  s_Info := ts_Info;
  p_Info := tp_Info;
  s_GameDir := 'Quake 2';
  while ts_Info <> '' do begin
    key := LeftStr(ts_Info, Pos(',', ts_Info)-1);
    value := Copy(ts_Info, Pos(',', ts_Info)+1, Pos('\', ts_Info)-1-Pos(',', ts_Info));
    if key = 'hostname' then s_HostName := value;
    if key = 'mapname' then s_Map := value;
    if key = 'game' then s_GameDir := s_GameDir+'/'+value;
    if key = 'maxclients' then p_Max := value;
    if key = 'needpass' then s_PwdReq := value;
    ts_Info := Copy(ts_Info, Pos('\', ts_Info)+1, Length(ts_Info));
  end;
  //players
  if tp_Info = '' then
    p_Num := '0'
  else begin
    i := 0;
    while Pos(Chr(10), tp_Info) > 0 do begin
      tp_Info[Pos(Chr(10), tp_Info)] := ' ';
      Inc(i);
    end;
    p_Num := IntToStr(i-1);
  end;
  if p_Max = '' then p_Max := '0';
  p_Total := p_Num + '/' + p_Max;
  //icons
  ts_Image := 26;
  if p_Num = p_Max then ts_Image := 22; //full
  if p_Num = '0' then ts_Image := 21; //empty
  if s_PwdReq <> '' then
    if StrToInt(s_PwdReq) > 0 then begin
      if (p_Num <> '0') and (p_Num <> p_Max) then ts_Image := 27; //pw
      if p_Num = '0' then ts_Image := 24; //pw empty
      if p_Num = p_Max then ts_Image := 25; //pw full
    end;
  s_Image := ts_Image;
end;

procedure GetServer.WF_ParseInfo;
var
  ts_Info, tp_Info, s_PwdReq, p_Num, p_Max, key, value: String;
  i, ts_Image: Integer;
  b: Boolean;
begin
  replyTime := GetTickCount;
  recData[Pos(Chr(10), recData)] := ' ';
  ts_Info := Copy(recData, 21, Pos(Chr(10), recData)-21)+'\';
  tp_Info := Copy(recData, Pos(Chr(10), recData), Length(recData));
  b := True;
  for i := 1 to Length(ts_Info) do
    if (ts_Info[i] = '\') then begin
      if b then
        ts_Info[i] := ',';
      b := not b;
    end;
  s_Info := ts_Info;
  p_Info := tp_Info;
  s_GameDir := 'Wolfenstein';
  while ts_Info <> '' do begin
    key := LeftStr(ts_Info, Pos(',', ts_Info)-1);
    value := Copy(ts_Info, Pos(',', ts_Info)+1, Pos('\', ts_Info)-1-Pos(',', ts_Info));
    if key = 'sv_hostname' then s_HostName := value;
    if key = 'mapname' then s_Map := value;
    if key = 'gamename' then s_GameDir := s_GameDir+'/'+value;
    if key = 'sv_maxclients' then p_Max := value;
    if key = 'g_needpass' then s_PwdReq := value;
    ts_Info := Copy(ts_Info, Pos('\', ts_Info)+1, Length(ts_Info));
  end;
  //players
  if tp_Info = '' then
    p_Num := '0'
  else begin
    i := 0;
    while Pos(Chr(10), tp_Info) > 0 do begin
      tp_Info[Pos(Chr(10), tp_Info)] := ' ';
      Inc(i);
    end;
    p_Num := IntToStr(i-1);
  end;
  if p_Max = '' then p_Max := '0';
  p_Total := p_Num + '/' + p_Max;
  //icons
  ts_Image := 56;
  if p_Num = p_Max then ts_Image := 52; //full
  if p_Num = '0' then ts_Image := 51; //empty
  if s_PwdReq <> '' then
    if StrToInt(s_PwdReq) > 0 then begin
      if (p_Num <> '0') and (p_Num <> p_Max) then ts_Image := 57; //pw
      if p_Num = '0' then ts_Image := 54; //pw empty
      if p_Num = p_Max then ts_Image := 55; //pw full
    end;
  s_Image := ts_Image;
end;

procedure GetServer.T1_ParseInfo;
var
  s, ver, ded, gname, needpass, players, maxplayers, cpu, mods, mission: String;
  teamName: Array[0..3] of String;
  i, j, numTeams, ts_Image: Integer;
begin
  replyTime := GetTickCount;
  s := recData;
  if Copy(s, 6, 6) <> 'Tribes' then Exit;
  s_GameDir := 'Tribes';
  gname := Copy(s, 6, 6); //Tribes
  Delete(s, 1, 11);
  j := Ord(s[1]);
  ver := Copy(s, 2, j);
  Delete(s, 1, j+1);
  j := Ord(s[1]);
  s_HostName := Copy(s, 2, j);
  Delete(s, 1, j+1);
  ded := IntToStr(Ord(s[1]));
  needpass := IntToStr(Ord(s[2]));
  players := IntToStr(Ord(s[3]));
  maxplayers := IntToStr(Ord(s[4]));
  cpu := IntToStr((Ord(s[5])+Ord(s[6])*256));
  j := Ord(s[7]);
  Delete(s, 1, 7);
  mods := Copy(s, 1, j);
  Delete(s, 1, j);
  j := Ord(s[1]);
  mission := Copy(s, 2, j);
  s_GameDir := s_GameDir+'/'+mission;
  Delete(s, 1, j+1);
  j := Ord(s[1]);
  s_Map := Copy(s, 2, j);
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
    teamName[i] := Copy(s, 2, j);
    Delete(s, 1, j+1);
    j := Ord(s[1]);
    Delete(s, 1, j+1);
  end;
  if players = '0' then
    p_Info := '*none' //no players
  else
    p_Info := Copy(s, 1, Length(s)); //players

  s_Info := 'gamename, '+gname+'\'+
            'version, '+ver+'\'+
            'hostname, '+s_HostName+'\'+
            'needpass, '+needpass+'\'+
            'dedicated, '+ded+'\'+
            'cpu, '+cpu+'\'+
            'mods, '+mods+'\'+
            'mission, '+mission+'\';
  for i := 0 to numTeams-1 do
    s_Info := s_Info+'team'+IntToStr(i+1)+', '+teamName[i]+'\';
  p_Total := players+'/'+maxplayers;
  //icons
  ts_Image := 66;
  if players = maxplayers then ts_Image := 62; //full
  if players = '0' then ts_Image := 61; //empty
  if needpass = '1' then begin
    if (players <> '0') and (players <> maxplayers) then ts_Image := 67; //pw
    if players = '0' then ts_Image := 64; //pw empty
    if players = maxplayers then ts_Image := 65; //pw full
  end;
  s_Image := ts_Image;
end;

procedure GetServer.T2_ParseInfo1;
var
  s: String;
  j: Integer;
begin
  replyTime := GetTickCount;
  s := recData;
  if Copy(s, 1, 6) <> #$10+#2+#1+#1+#1+#1 then Exit;
  Delete(s, 1, 6);
  j := Ord(s[1]);
  s_Info := 'version, '+Copy(s, 2, j)+'\';
  Delete(s, 1, j+1);
  s_Info := s_Info + 'net protocol, '+IntToStr(Ord(s[1]))+'\';
  s_Info := s_Info + 'min net protocol, '+IntToStr(Ord(s[5]))+'\';
  Delete(s, 1, 8);
  s_Info := s_Info + 'build version, '+IntToStr(Ord(s[1])+Ord(s[2])*256)+'\';
  Delete(s, 1, 4);
  s_HostName := Copy(s, 2, Ord(s[1]));
end;

procedure GetServer.T2_ParseInfo2;
var
  s, players, maxplayers, passw: String;
  i, j, numTeams, ts_Image: Integer;
begin
  s := recData;
  if Copy(s, 1, 6) <> #20+#2+#1+#1+#1+#1 then Exit;
  j := Ord(s[7]);
  s_Info := s_Info + 'game, '+Copy(s, 8, j)+'\'; //mod
  Delete(s, 1, 7+j);
  j := Ord(s[1]);
  s_GameDir := 'Tribes 2/'+Copy(s, 2, j); //mission
  Delete(s, 1, j+1);
  j := Ord(s[1]);
  s_Map := Copy(s, 2, j); //map
  Delete(s, 1, j+1);
  j := Ord(s[1]); //status byte
  players := IntToStr(Ord(s[2]));
  maxplayers := IntToStr(Ord(s[3]));
  passw := IntToStr((j and 2) div 2);
  s_Info := s_Info +
            'dedicated, '+IntToStr(j and 1)+'\'+
            'passworded, '+passw+'\'+
            'linux, '+IntToStr((j and 4) div 4)+'\'+
            'tourniment, '+IntToStr((j and 8) div 8)+'\'+
            'noalias, '+IntToStr((j and 16) div 16)+'\'+
            'bot count, '+IntToStr(Ord(s[4]))+'\'+
            'cpu, '+IntToStr(Ord(s[5])+Ord(s[6])*256)+'\';
  p_Total := players+'/'+maxplayers; //players & max
  Delete(s, 1, 6);
  j := Ord(s[1]);
  s_Info := s_Info + 'server info, '+Copy(s, 2, j)+'\';
  Delete(s, 1, j+1);
  Delete(s, 1, 2); //this is for .. ?
  numTeams := StrToInt(s[1]); //num teams
  Delete(s, 1, 2);
  for i := 0 to numTeams-1 do begin
    s_Info := s_Info+'team'+IntToStr(i+1)+', '+Copy(s, 1, Pos(#9, s)-1)+'\';
    Delete(s, 1, Pos(#$A, s));
  end;
  if s = '0' then
    p_Info := '*none'
  else
    p_Info := Copy(s, Pos(#$A, s), Length(s))+#$A;
  //icons
  ts_Image := 76;
  if players = maxplayers then ts_Image := 72; //full
  if players = '0' then ts_Image := 71; //empty
  if passw = '1' then begin
    if (players <> '0') and (players <> maxplayers) then ts_Image := 77; //pw
    if players = '0' then ts_Image := 74; //pw empty
    if players = maxplayers then ts_Image := 75; //pw full
  end;
  s_Image := ts_Image;
end;

end.
