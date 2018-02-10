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

unit gamesetup;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, ComCtrls, StrUtils, Dialogs;

type
  TGameData = record
    CommandLine1: String[127];
    CommandLine2: String[127];
    Param1: String[127];
    Param2: String[127];
    CreateTextFile: Boolean;
    TextFileName: String[127];
    TextFileContents: String[255];
    Installed: Boolean;
  end;

type
  TfrmGameSetup = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    lblCmdLine1: TLabel;
    lblCmdLine2: TLabel;
    txtCmdLine1: TEdit;
    txtCmdLine2: TEdit;
    mmoFileContents: TMemo;
    chkFile: TCheckBox;
    txtFileName: TEdit;
    cbxGame: TComboBox;
    lblGame: TLabel;
    txtParam1: TEdit;
    txtParam2: TEdit;
    lblParam1: TLabel;
    lblParam2: TLabel;
    cmdCmdLine1Browse: TButton;
    cmdCmdLine2Browse: TButton;
    cmdCreateFileBrowse: TButton;
    cmdDefault: TButton;
    chkInstalled: TCheckBox;
    procedure cbxGameChange(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCmdLine1BrowseClick(Sender: TObject);
    procedure cmdCmdLine2BrowseClick(Sender: TObject);
    procedure cmdCreateFileBrowseClick(Sender: TObject);
    procedure cmdDefaultClick(Sender: TObject);
    public
      last: Integer;
      tmpGameData: Array[0..63] of TGameData;
  end;

var
  frmGameSetup : TfrmGameSetup;

implementation

uses main;

{$R *.DFM}

procedure TfrmGameSetup.cbxGameChange(Sender: TObject);
begin
  with tmpGameData[last] do begin //save
    CommandLine1 := Trim(txtCmdLine1.Text);
    CommandLine2 := Trim(txtCmdLine2.Text);
    Param1 := Trim(txtParam1.Text);
    Param2 := Trim(txtParam2.Text);
    CreateTextFile := chkFile.Checked;
    TextFileName := Trim(txtFileName.Text);
    TextFileContents := mmoFileContents.Text;
    Installed := chkInstalled.Checked;
  end;
  with tmpGameData[cbxGame.ItemIndex] do begin //load
    txtCmdLine1.Text := CommandLine1;
    txtCmdLine2.Text := CommandLine2;
    txtParam1.Text := Param1;
    txtParam2.Text := Param2;
    chkFile.Checked := CreateTextFile;
    txtFileName.Text := TextFileName;
    mmoFileContents.Text := TextFileContents;
    chkInstalled.Checked := Installed;
  end;
  last := cbxGame.ItemIndex;
end;

procedure TfrmGameSetup.cmdOKClick(Sender: TObject);
var
  i: Integer;
begin
  with tmpGameData[cbxGame.ItemIndex] do begin //save
    CommandLine1 := Trim(txtCmdLine1.Text);
    CommandLine2 := Trim(txtCmdLine2.Text);
    Param1 := Trim(txtParam1.Text);
    Param2 := Trim(txtParam2.Text);
    CreateTextFile := chkFile.Checked;
    TextFileName := Trim(txtFileName.Text);
    TextFileContents := mmoFileContents.Text;
    Installed := chkInstalled.Checked;
  end;
  for i := 0 to 63 do begin //GAME_ADD
    with frmMain.GameData[i] do begin
      CommandLine1 := tmpGameData[i].CommandLine1;
      CommandLine2 := tmpGameData[i].CommandLine2;
      Param1 := tmpGameData[i].Param1;
      Param2 := tmpGameData[i].Param2;
      CreateTextFile := tmpGameData[i].CreateTextFile;
      TextFileName := tmpGameData[i].TextFileName;
      TextFileContents := tmpGameData[i].TextFileContents;
      Installed := tmpGameData[i].Installed;
    end;
  end;
end;

procedure TfrmGameSetup.cmdCmdLine1BrowseClick(Sender: TObject);
begin
  frmMain.dlgOpen.FileName := '';
  frmMain.dlgOpen.Filter := 'Executable Files|*.exe;*.com;*.bat|All Files|*.*';
  frmMain.dlgOpen.Title := 'Choose Executable';
  if frmMain.dlgOpen.Execute then txtCmdLine1.Text := frmMain.dlgOpen.FileName;
end;

procedure TfrmGameSetup.cmdCmdLine2BrowseClick(Sender: TObject);
begin
  frmMain.dlgOpen.FileName := '';
  frmMain.dlgOpen.Filter := 'Executable Files|*.exe;*.com;*.bat|All Files|*.*';
  frmMain.dlgOpen.Title := 'Choose Executable';
  if frmMain.dlgOpen.Execute then txtCmdLine2.Text := frmMain.dlgOpen.FileName;
end;

procedure TfrmGameSetup.cmdCreateFileBrowseClick(Sender: TObject);
begin
  frmMain.dlgSave.FileName := '';
  frmMain.dlgSave.Filter := 'All Files|*.*';
  frmMain.dlgSave.Title := 'Choose File';
  if frmMain.dlgSave.Execute then begin
    txtFileName.Text := frmMain.dlgSave.FileName;
    chkFile.Checked := True;
  end;
end;

procedure TfrmGameSetup.cmdDefaultClick(Sender: TObject);
begin
{  if MessageDlg('Reset Default for '+cbxGame.Text+'?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then Exit;
  case cbxGame.ItemIndex of //fix me
    0: begin
         txtCmdLine1.Text := 'c:\quake\quake.exe';
         txtParam1.Text := '+name %n% +connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
    1: begin
         txtCmdLine1.Text := 'c:\quake\qwcl.exe';
         txtParam1.Text := '+name %n% +spectator %sp% +password %pw% +connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
    2: begin
         txtCmdLine1.Text := 'c:\quake2\quake2.exe';
         txtParam1.Text := '+name %n% +spectator %sp% +password %pw% +connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
    3: begin
         txtCmdLine1.Text := 'c:\quake3\quake3.exe';
         txtParam1.Text := '+name %n% +spectator %sp% +password %pw% +connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
    4: begin
         txtCmdLine1.Text := 'c:\half-life\hl.exe';
         txtParam1.Text := '-console +name %n% +password %p% +connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
    5: begin
         txtCmdLine1.Text := 'c:\wolf\wolfmp.exe';
         txtParam1.Text := '+name %n% +spectator %sp% +password %pw% +connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
    6: begin
         txtCmdLine1.Text := 'c:\tribes\tribes.exe';
         txtParam1.Text := '+connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
    7: begin
         txtCmdLine1.Text := 'c:\tribes2\tribes2.exe';
         txtParam1.Text := '-connect %s%:%p%';
         txtCmdLine2.Text := '';
         txtParam2.Text := '';
         chkFile.Checked := False;
         txtFileName.Text := '';
         mmoFileContents.Lines.Clear;
       end;
  end;}
end;

end.
