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

unit splash;

interface

uses
  Classes, Forms, jpeg, ExtCtrls, Controls;

type
  TfrmSplash = class(TForm)
    imgFizzLogo: TImage;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure imgFizzLogoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.dfm}

procedure TfrmSplash.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
end;

procedure TfrmSplash.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Timer.Enabled;
end;

procedure TfrmSplash.imgFizzLogoClick(Sender: TObject);
begin
  Close;
end;

end.
