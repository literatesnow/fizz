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

unit about;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg;

type
  TfrmAbout = class(TForm)
    lblWeb: TLabel;
    lblFizz: TLabel;
    lblCopyright: TLabel;
    lblCreatedBy: TLabel;
    lblTestingIdeas: TLabel;
    lblSoulless: TLabel;
    lblmpx1: TLabel;
    lblShoyu: TLabel;
    lblJonan: TLabel;
    lblPurge: TLabel;
    lblbliP: TLabel;
    cmdClose: TButton;
    Image1: TImage;
    lblGraphics: TLabel;
    lblmpx2: TLabel;
    imgFizzIcon: TImage;
    procedure lblWebClick(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses Main;

{$R *.dfm}

procedure TfrmAbout.lblWebClick(Sender: TObject);
begin
  frmMain.ShellOpenFile(0, 'open', 'http://nisda.net', '', '', False);
end;

procedure TfrmAbout.cmdCloseClick(Sender: TObject);
begin
  Close;
end;

end.
