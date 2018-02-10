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

unit filter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Main;

type
  TfrmFilter = class(TForm)
    lvwFilter: TListView;
    cmdOK: TButton;
    cmdCancel: TButton;
    cmdAdd: TButton;
    grpRule: TGroupBox;
    txtRS: TEdit;
    cboRO: TComboBox;
    txtRD: TEdit;
    cmdRAdd: TButton;
    grpServer: TGroupBox;
    cboSO: TComboBox;
    cboSS: TComboBox;
    cmdSAdd: TButton;
    txtSD: TEdit;
    lvwFilterItems: TListView;
    txtName: TEdit;
    lblName: TLabel;
    cmdRemove: TButton;
    cmdDelete: TButton;
    procedure cmdAddClick(Sender: TObject);
    procedure cmdSAddClick(Sender: TObject);
    procedure cmdRAddClick(Sender: TObject);
    procedure lvwFilterSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure cmdDeleteClick(Sender: TObject);
    procedure lvwFilterItemsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure cmdRemoveClick(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
  private
    function IsInt(num: String): Integer;
  public
    newFilter: Array[0..31] of TFilterData;
  end;

var
  frmFilter: TfrmFilter;

implementation

{$R *.dfm}

procedure TfrmFilter.cmdAddClick(Sender: TObject);
begin
  if txtName.Text <> '' then begin
    if lvwFilter.Items.Count <= 32 then begin
      lvwFilter.Items.Add;
      lvwFilter.Items[lvwFilter.Items.Count-1].Caption := txtName.Text;
      lvwFilter.Items[lvwFilter.Items.Count-1].SubItems.Add('*empty');
      //lvwFilter.Items[lvwFilter.Items.Count-1].Selected := True;
      lvwFilter.SetFocus;
    end
    else
      ShowMessage('Filter limit reached (32)');
  end;
end;

procedure TfrmFilter.cmdSAddClick(Sender: TObject);
var
  t, s: String;
  i, j: Integer;
const
  SDEF: Array[0..5] of String = ('name', 'ping', 'map', 'players', 'mod', 'responds');
  ODEF: Array[0..3] of String = ('<', '>', '==', '!=');
begin
  if (txtSD.Text = '') then Exit;
  if cboSO.ItemIndex in [0, 1] then
    if (IsInt(txtSD.Text) = 0) then Exit;
  s := '1,' +
       IntToStr(cboSS.ItemIndex) + ',' +
       IntToStr(cboSO.ItemIndex) + ',' +
       txtSD.Text + '\';
  t := 'server ' + SDEF[cboSS.ItemIndex] + ' ' +
       ODEF[cboSO.ItemIndex] + ' ' +
       '"' + txtSD.Text + '"';
  lvwFilterItems.Items.Add;
  lvwFilterItems.Items[lvwFilterItems.Items.Count-1].Caption := t;
  lvwFilterItems.Items[lvwFilterItems.Items.Count-1].SubItems.Add(s);
  txtSD.Text := '';
  j := lvwFilterItems.Items.Count;
  s := '';
  if j > 32 then
    ShowMessage('Can''t have more that 32 filter items (over by '+ IntToStr(j-32) + ')')
  else begin
    for i := 0 to j-1 do
      s := s + lvwFilterItems.Items[i].SubItems[0];
    i := lvwFilter.Selected.Index;
    lvwFilter.Items[i].Caption := txtName.Text;
    if s = '' then s := '*empty';
    lvwFilter.Items[i].SubItems[0] := s;
  end;
  cboSS.SetFocus;
end;

procedure TfrmFilter.cmdRAddClick(Sender: TObject);
var
  t, s: String;
  i, j: Integer;
const
  ODEF: Array[0..3] of String = ('<', '>', '==', '!=');
begin
  if (txtRS.Text = '') or (txtRD.Text = '') then Exit;
  if cboRO.ItemIndex in [0, 1] then
    if (IsInt(txtRD.Text) = 0) then Exit;
  s := '0,' +
       txtRS.Text + ',' +
       IntToStr(cboRO.ItemIndex) + ',' +
       txtRD.Text + '\';
  t := 'rule "' + txtRS.Text + '" ' +
       ODEF[cboRO.ItemIndex] + ' ' +
       '"' + txtRD.Text + '"';
  lvwFilterItems.Items.Add;
  lvwFilterItems.Items[lvwFilterItems.Items.Count-1].Caption := t;
  lvwFilterItems.Items[lvwFilterItems.Items.Count-1].SubItems.Add(s);
  txtRD.Text := '';
  txtRS.Text := '';
  j := lvwFilterItems.Items.Count;
  s := '';
  if j > 32 then
    ShowMessage('Can''t have more that 32 filter items (over by '+ IntToStr(j-32) + ')')
  else begin
    for i := 0 to j-1 do
      s := s + lvwFilterItems.Items[i].SubItems[0];
    i := lvwFilter.Selected.Index;
    lvwFilter.Items[i].Caption := txtName.Text;
    if s = '' then s := '*empty';
    lvwFilter.Items[i].SubItems[0] := s;
  end;
  txtRS.SetFocus;
end;

procedure TfrmFilter.lvwFilterSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  i, j: Integer;
  s, t: String;
  a: Array[0..3] of String;
const
  SDEF: Array[0..5] of String = ('name', 'ping', 'map', 'players', 'mod', 'responds');
  ODEF: Array[0..3] of String = ('<', '>', '==', '!=');
begin
  if Selected and (lvwFilter.SelCount = 1) then begin
    cmdRemove.Enabled := True;
    cboRO.Enabled := True;
    cboSO.Enabled := True;
    cboSS.Enabled := True;
    txtRD.Enabled := True;
    txtRS.Enabled := True;
    txtSD.Enabled := True;
    cmdRAdd.Enabled := True;
    cmdSAdd.Enabled := True;
    lvwFilterItems.Enabled := True;
    txtName.Text := Item.Caption;
    s := Item.SubItems[0];
    if s <> '*empty' then
      while Length(s) > 0 do begin
        lvwFilterItems.Items.Add;
        t := Copy(s, 1, Pos('\', s));
        lvwFilterItems.Items[lvwFilterItems.Items.Count-1].SubItems.Add(t);
        Delete(t, Pos('\', t), 1);
        for i := 0 to 3 do
          a[i] := '';
        j := 0;
        i := 1;
        while i <= Length(t) do begin
          if t[i] = ',' then
            Inc(j)
          else
            a[j] := a[j] + t[i];
          Inc(i);
        end;
        if a[0] = '0' then
          t := 'rule "' + a[1] + '" ' +
          ODEF[StrToInt(a[2])] + ' ' +
          '"' + a[3] + '"';
        if a[0] = '1' then
          t := 'server ' + SDEF[StrToInt(a[1])] + ' ' +
          ODEF[StrToInt(a[2])] + ' ' +
          '"' + a[3] + '"';
        lvwFilterItems.Items[lvwFilterItems.Items.Count-1].Caption := t;
        Delete(s, 1, Pos('\', s));
      end;
  end
  else begin
    cmdRemove.Enabled := False;
    cboRO.Enabled := False;
    cboSO.Enabled := False;
    cboSS.Enabled := False;
    txtRD.Enabled := False;
    txtRS.Enabled := False;
    txtSD.Enabled := False;
    cmdRAdd.Enabled := False;
    cmdSAdd.Enabled := False;
    lvwFilterItems.Enabled := False;
    lvwFilterItems.Items.Clear;
    txtName.Text := '';
  end;
end;

procedure TfrmFilter.cmdDeleteClick(Sender: TObject);
begin
  lvwFilterItems.Items[lvwFilterItems.Selected.Index].Delete;
  lvwFilterItems.SetFocus;
end;

procedure TfrmFilter.lvwFilterItemsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  cmdDelete.Enabled := (Selected and (lvwFilterItems.SelCount = 1));
end;

procedure TfrmFilter.cmdRemoveClick(Sender: TObject);
begin
  lvwFilter.Items[lvwFilter.Selected.Index].Delete;
end;

procedure TfrmFilter.cmdOKClick(Sender: TObject);
var
  i, j: Integer;
begin
  for i := 0 to 31 do
    newFilter[i].Name := '';
  j := lvwFilter.Items.Count;
  if j > 0 then
    for i := 0 to j-1 do
      if lvwFilter.Items[i].SubItems[0] <> '*empty' then begin
        newFilter[i].Name := lvwFilter.Items[i].Caption;
        newFilter[i].Data := lvwFilter.Items[i].SubItems[0];
      end;
end;

function TfrmFilter.IsInt(num: String): Integer;
var
  tmp, errno: Integer;
begin
  Val(num, tmp, errno);
  if errno <> 0 then begin
    ShowMessage('"' + num + '" is not an integer');
    result := 0;
  end
  else
    result := tmp - tmp + 1; //is a num
end;

end.
