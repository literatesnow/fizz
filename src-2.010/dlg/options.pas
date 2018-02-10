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

unit options;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, ComCtrls, Registry, Dialogs, CheckLst;

type
  TfrmOptions = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    pgePageControl: TPageControl;
    tabGeneral: TTabSheet;
    tabColOrder: TTabSheet;
    lblTimeOut: TLabel;
    txtTimeOut: TEdit;
    cmdServerUp: TButton;
    cmdServerDown: TButton;
    cmdPlayerUp: TButton;
    cmdPlayerDown: TButton;
    lblServerColOrder: TLabel;
    lblPlayercolOrder: TLabel;
    lstServerColOrder: TCheckListBox;
    lstPlayerColOrder: TCheckListBox;
    tabPlayerName: TTabSheet;
    txtName1: TEdit;
    txtDisplayName2: TEdit;
    txtName2: TEdit;
    txtName4: TEdit;
    txtDisplayName4: TEdit;
    txtName3: TEdit;
    txtDisplayName3: TEdit;
    txtName5: TEdit;
    txtDisplayName5: TEdit;
    lblDisplayName: TLabel;
    lblName: TLabel;
    txtDisplayName1: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    grpJoin: TGroupBox;
    radJoinClose: TRadioButton;
    radJoinMinimize: TRadioButton;
    radJoinNothing: TRadioButton;
    chkDblLaunch: TCheckBox;
    chkIntICQ: TCheckBox;
    cboICQState: TComboBox;
    txtICQMsg: TEdit;
    lblSetMode: TLabel;
    lblMessage: TLabel;
    chkMinimizeTray: TCheckBox;
    txtRefreshNum: TEdit;
    lblRefreshNum: TLabel;
    procedure cmdOKClick(Sender: TObject);
    procedure cmdServerUpClick(Sender: TObject);
    procedure cmdServerDownClick(Sender: TObject);
    procedure cmdPlayerUpClick(Sender: TObject);
    procedure cmdPlayerDownClick(Sender: TObject);
    procedure lstServerColOrderClick(Sender: TObject);
    procedure lstPlayerColOrderClick(Sender: TObject);
    procedure chkIntICQClick(Sender: TObject);
  end;

var
  frmOptions: TfrmOptions;
  changedColOrder: Boolean;

implementation

uses Main;

{$R *.DFM}

procedure TfrmOptions.cmdOKClick(Sender: TObject);
var
  i, j: Integer;
  reg: TRegistry;
  newServerColOrder: Array[0..5] of Integer;
  newPlayerColOrder: Array[0..5] of Integer;
begin
  with frmMain do begin
    if (txtDisplayName1.Text <> '') and (txtName1.Text <> '') then begin
      mniName1.Caption := txtDisplayName1.Text;
      nameData[0].DisplayName := txtDisplayName1.Text;
      nameData[0].Name := txtName1.Text;
      nameData[0].Enabled := True;
    end
    else begin
      nameData[0].Enabled := False;
      mniName1.Caption := '(empty)';
    end;

    if (txtDisplayName2.Text <> '') and (txtName2.Text <> '') then begin
      mniName2.Caption := txtDisplayName2.Text;
      nameData[1].DisplayName := txtDisplayName2.Text;
      nameData[1].Name := txtName2.Text;
      nameData[1].Enabled := True;
    end
    else begin
      nameData[1].Enabled := False;
      mniName2.Caption := '(empty)';
    end;

    if (txtDisplayName3.Text <> '') and (txtName3.Text <> '') then begin
      mniName3.Caption := txtDisplayName3.Text;
      nameData[2].DisplayName := txtDisplayName3.Text;
      nameData[2].Name := txtName3.Text;
      nameData[2].Enabled := True;
    end
    else begin
      nameData[2].Enabled := False;
      mniName3.Caption := '(empty)';
    end;

    if (txtDisplayName4.Text <> '') and (txtName4.Text <> '') then begin
      mniName4.Caption := txtDisplayName4.Text;
      nameData[3].DisplayName := txtDisplayName4.Text;
      nameData[3].Name := txtName4.Text;
      nameData[3].Enabled := True;
    end
    else begin
      nameData[3].Enabled := False;
      mniName4.Caption := '(empty)';
    end;

    if (txtDisplayName5.Text <> '') and (txtName5.Text <> '') then begin
      mniName5.Caption := txtDisplayName5.Text;
      nameData[4].DisplayName := txtDisplayName5.Text;
      nameData[4].Name := txtName5.Text;
      nameData[4].Enabled := True;
    end
    else begin
      nameData[4].Enabled := False;
      mniName5.Caption := '(empty)';
    end;

    StatusBar.Panels[1].Text := GetPlayerName(False);
    i := StrToInt(txtTimeOut.Text);
    if (i < 1000) then i := 1000;
    options.TimeOut := i;
    i := StrToInt(txtRefreshNum.Text);
    if (i < 1) then i := 4;
    options.RefreshNum := i;
    options.DblClickToLaunch := chkDblLaunch.Checked;
    options.WhenLaunchGameDo := 0;
    options.MinimizeToTray := chkMinimizeTray.Checked;
    if radJoinNothing.Checked then options.WhenLaunchGameDo := 1;
    if radJoinMinimize.Checked then options.WhenLaunchGameDo := 2;
    if radJoinClose.Checked then options.WhenLaunchGameDo := 3;
    options.ICQIntegration := chkIntICQ.Checked;
    options.ICQState := cboICQState.ItemIndex;
    options.ICQMessage := txtICQMsg.Text;
  end;

  j := -1;
  if changedColOrder then begin
    for i := 0 to lstServerColOrder.Items.Count-1 do begin
      if lstServerColOrder.Items.Strings[i] = 'Server Name' then
        if lstServerColOrder.Checked[i] then begin
          newServerColOrder[0] := j;
          Inc(j);
        end
        else
          newServerColOrder[0] := -999;
      if lstServerColOrder.Items.Strings[i] = 'Ping' then
        if lstServerColOrder.Checked[i] then begin
          newServerColOrder[1] := j;
          Inc(j);
        end
        else
          newServerColOrder[1] := -999;
      if lstServerColOrder.Items.Strings[i] = 'Address' then
        if lstServerColOrder.Checked[i] then begin
          newServerColOrder[2] := j;
          Inc(j);
        end
        else
          newServerColOrder[2] := -999;
      if lstServerColOrder.Items.Strings[i] = 'Map' then
        if lstServerColOrder.Checked[i] then begin
          newServerColOrder[3] := j;
          Inc(j);
        end
        else
          newServerColOrder[3] := -999;
      if lstServerColOrder.Items.Strings[i] = 'Players' then
        if lstServerColOrder.Checked[i] then begin
          newServerColOrder[4] := j;
          Inc(j);
        end
        else
          newServerColOrder[4] := -999;
      if lstServerColOrder.Items.Strings[i] = 'Game/Mod' then
        if lstServerColOrder.Checked[i] then begin
          newServerColOrder[5] := j;
          Inc(j);
        end
        else
          newServerColOrder[5] := -999;
    end;

    j := -1;

    for i := 0 to lstPlayerColOrder.Items.Count-1 do begin
      if lstPlayerColOrder.Items.Strings[i] = 'Player Name' then
       if lstPlayerColOrder.Checked[i] then begin
          newPlayerColOrder[0] := j;
          Inc(j);
        end
        else
          newPlayerColOrder[0] := -999;
      if lstPlayerColOrder.Items.Strings[i] = 'Frags' then
       if lstPlayerColOrder.Checked[i] then begin
          newPlayerColOrder[1] := j;
          Inc(j);
        end
        else
          newPlayerColOrder[1] := -999;
      if lstPlayerColOrder.Items.Strings[i] = 'Skin' then
       if lstPlayerColOrder.Checked[i] then begin
          newPlayerColOrder[2] := j;
          Inc(j);
        end
        else
          newPlayerColOrder[2] := -999;
      if lstPlayerColOrder.Items.Strings[i] = 'Ping' then
       if lstPlayerColOrder.Checked[i] then begin
          newPlayerColOrder[3] := j;
          Inc(j);
        end
        else
          newPlayerColOrder[3] := -999;
      if lstPlayerColOrder.Items.Strings[i] = 'Connect' then
       if lstPlayerColOrder.Checked[i] then begin
          newPlayerColOrder[4] := j;
          Inc(j);
        end
        else
          newPlayerColOrder[4] := -999;
      if lstPlayerColOrder.Items.Strings[i] = 'User ID' then
       if lstPlayerColOrder.Checked[i] then begin
          newPlayerColOrder[5] := j;
          Inc(j);
        end
        else
          newPlayerColOrder[5] := -999;
    end;
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey('Software\Fizz', True);
      reg.WriteBinaryData('ServerColOrder', newServerColOrder, SizeOf(newServerColOrder));
      reg.WriteBinaryData('PlayerColOrder', newPlayerColOrder, SizeOf(newPlayerColOrder));
    finally
      reg.CloseKey;
      reg.Free;
    end;
    ShowMessage('Restart Fizz');
    Halt(0);
  end;
end;

procedure TfrmOptions.cmdServerUpClick(Sender: TObject);
var
  item: Integer;
begin
  changedColOrder := True;
  item := lstServerColOrder.ItemIndex-1;
  if lstServerColOrder.ItemIndex > -1 then
    lstServerColOrder.Items.Move(lstServerColOrder.ItemIndex, lstServerColOrder.ItemIndex-1);
  lstServerColOrder.SetFocus;
  if item > -1 then
    lstServerColOrder.ItemIndex := item
  else
    lstServerColOrder.ItemIndex := lstServerColOrder.Items.Count-1;
end;

procedure TfrmOptions.cmdServerDownClick(Sender: TObject);
var
  item: Integer;
begin
  changedColOrder := True;
  item := lstServerColOrder.ItemIndex+1;
  if (lstServerColOrder.ItemIndex+1) > (lstServerColOrder.Items.Count-1) then
    lstServerColOrder.Items.Move(lstServerColOrder.ItemIndex, 0)
  else
    lstServerColOrder.Items.Move(lstServerColOrder.ItemIndex, lstServerColOrder.ItemIndex+1);
  lstServerColOrder.SetFocus;
  if item > lstServerColOrder.Items.Count-1 then
    lstServerColOrder.ItemIndex := 0
  else
    lstServerColOrder.ItemIndex := item;
end;

procedure TfrmOptions.cmdPlayerUpClick(Sender: TObject);
var
  item: Integer;
begin
  changedColOrder := True;
  item := lstPlayerColOrder.ItemIndex-1;
  if lstPlayerColOrder.ItemIndex > -1 then
    lstPlayerColOrder.Items.Move(lstPlayerColOrder.ItemIndex, lstPlayerColOrder.ItemIndex-1);
  lstPlayerColOrder.SetFocus;
  if item > -1 then
    lstPlayerColOrder.ItemIndex := item
  else
    lstPlayerColOrder.ItemIndex := lstPlayerColOrder.Items.Count-1;
end;

procedure TfrmOptions.cmdPlayerDownClick(Sender: TObject);
var
  item: Integer;
begin
  changedColOrder := True;
  item := lstPlayerColOrder.ItemIndex+1;
  if (lstPlayerColOrder.ItemIndex+1) > (lstPlayerColOrder.Items.Count-1) then
    lstPlayerColOrder.Items.Move(lstPlayerColOrder.ItemIndex, 0)
  else
    lstPlayerColOrder.Items.Move(lstPlayerColOrder.ItemIndex, lstPlayerColOrder.ItemIndex+1);
  lstPlayerColOrder.SetFocus;
  if item > lstPlayerColOrder.Items.Count-1 then
    lstPlayerColOrder.ItemIndex := 0
  else
    lstPlayerColOrder.ItemIndex := item;
end;

procedure TfrmOptions.lstServerColOrderClick(Sender: TObject);
begin
  changedColOrder := True;
end;

procedure TfrmOptions.lstPlayerColOrderClick(Sender: TObject);
begin
  changedColOrder := True;
end;

procedure TfrmOptions.chkIntICQClick(Sender: TObject);
begin
  cboICQState.Enabled := chkIntICQ.Checked;
  txtICQMsg.Enabled := chkIntICQ.Checked;
  lblSetMode.Enabled := chkIntICQ.Checked;
  lblMessage.Enabled := chkIntICQ.Checked;
end;

end.
