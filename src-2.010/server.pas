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
  Classes, WinProcs, StrUtils, SysUtils, Main;

type
  GetServer = class(TThread)
  public
    qryAddress: String;
    qryPort, qryGame, timeOut, arrayIndex: Integer;
    qryFunc: TGet;
    last: Boolean;
  private
    serverReply: TDLLServerData;
  protected
    procedure Execute; override;
    procedure SetInfo;
  end;

implementation

{ GetServer }

procedure GetServer.Execute;
var
  sd: TThisServer;
begin
  if Terminated then Exit;
  try
    sd.IP := PChar(qryAddress);
    sd.Port := qryPort;
    sd.TimeOut := timeOut;
    qryFunc(sd, serverReply); //get info from dll
    Synchronize(SetInfo);
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
    serverData[arrayIndex].ServerName := StrPas(serverReply.ServerName);
    serverData[arrayIndex].Ping := IntToStr(serverReply.Ping);
    serverData[arrayIndex].Map := StrPas(serverReply.Map);
    serverData[arrayIndex].Players := serverReply.Players;
    serverData[arrayIndex].MaxPlayers := serverReply.MaxPlayers;
    serverData[arrayIndex].GameMod := StrPas(serverReply.GameMod);
    serverData[arrayIndex].IconIndex := serverReply.IconIndex;

    //players
    b := True;
    i := 0;
    while (i < 128) and (b) do begin
      serverData[arrayIndex].PlayerData[i].Name := StrPas(serverReply.PlayerData[i].Name);
      serverData[arrayIndex].PlayerData[i].Frags := serverReply.PlayerData[i].Frags;
      serverData[arrayIndex].PlayerData[i].Skin := StrPas(serverReply.PlayerData[i].Skin);
      serverData[arrayIndex].PlayerData[i].Ping := serverReply.PlayerData[i].Ping;
      serverData[arrayIndex].PlayerData[i].Connect := serverReply.PlayerData[i].Connect;
      serverData[arrayIndex].PlayerData[i].UserID := serverReply.PlayerData[i].UserID;
      serverData[arrayIndex].PlayerData[i].TopColour := serverReply.PlayerData[i].TopColour;
      serverData[arrayIndex].PlayerData[i].BottomColour := serverReply.PlayerData[i].BottomColour;
      if (serverData[arrayIndex].PlayerData[i].Name = '') then b := False;
      Inc(i);
    end;
    //rules
    b := True;
    i := 0;
    while (i < 256) and (b) do begin
      serverData[arrayIndex].RuleData[i].Name := StrPas(serverReply.RuleData[i].Name);
      serverData[arrayIndex].RuleData[i].Value := StrPas(serverReply.RuleData[i].Value);
      if (serverData[arrayIndex].RuleData[i].Name = '') then b := False;
      Inc(i);
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
      SetServerItem(i, 0, serverData[arrayIndex].ServerName);
      SetServerItem(i, 1, serverData[arrayIndex].Ping);
      SetServerItem(i, 2, serverData[arrayIndex].Address);
      SetServerItem(i, 3, serverData[arrayIndex].Map);
      if (serverData[arrayIndex].Players > -1) then
        SetServerItem(i, 4, IntToStr(serverData[arrayIndex].Players) + '/' + IntToStr(serverData[arrayIndex].MaxPlayers));
      SetServerItem(i, 5, serverData[arrayIndex].GameMod);
      SetServerItem(i, 6, IntToStr(arrayIndex));
      lvwServer.Items[i].ImageIndex := serverData[arrayIndex].IconIndex;
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

end.
