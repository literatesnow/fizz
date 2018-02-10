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

unit join;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmJoin = class(TForm)
    lblCmdLine1: TLabel;
    lblCmdLine2: TLabel;
    lblParam1: TLabel;
    lblParam2: TLabel;
    txtCmdLine2: TEdit;
    mmoFileContents: TMemo;
    chkFile: TCheckBox;
    txtFileName: TEdit;
    txtParam1: TEdit;
    txtParam2: TEdit;
    cboCmdLine1: TComboBox;
    cmdOK: TButton;
    cmdCancel: TButton;
    chkPassword: TCheckBox;
    chkSpec: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmJoin: TfrmJoin;

implementation

{$R *.dfm}

end.
