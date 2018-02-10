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

unit refresh;

interface

uses
  SysUtils, Classes, WinProcs, Main, Server;

type
  TRefreshList = record
    Address: String;
    Port: Integer;
    Index: Integer;
  end;

type
  RefreshList = class(TThread)
  public
    refreshList: Array[0..1023] of TRefreshList;
    refreshNum, numServers, qrTimeOut, qrGame: Integer;
    qrFunc: TGet;
  protected
    procedure Execute; override;
  end;

implementation

{ RefreshList }

procedure RefreshList.Execute;
var
  i, j, k: Integer;
begin
  if Terminated then Exit;
  j := 0;
  k := 0;
  try
    while (refreshList[k].Address <> '') do
      Inc(k);
    for i := 0 to k-1 do begin
      if j = refreshNum then begin //pause every x servers
        Sleep(500);
        j := 1
      end
      else
        Inc(j);
      with GetServer.Create(True) do begin
        FreeOnTerminate := True;
        arrayIndex := refreshList[i].Index;
        qryAddress := refreshList[i].Address;
        qryPort := refreshList[i].Port;
        qryFunc := qrFunc;
        qryGame := qrGame;
        timeOut := qrTimeOut;
        last := i+1 = k;
        Resume; //start
      end;
    end;
  finally
    Terminate;
  end;
end;

end.
