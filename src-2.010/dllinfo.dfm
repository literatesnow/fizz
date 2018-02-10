object frmDLLInfo: TfrmDLLInfo
  Left = 234
  Top = 176
  AutoSize = True
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Plugin Info'
  ClientHeight = 273
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lvwList: TListView
    Left = 0
    Top = 0
    Width = 513
    Height = 273
    Columns = <
      item
        Caption = 'Game'
        Width = 200
      end
      item
        Caption = 'Author'
        Width = 150
      end
      item
        Caption = 'Version'
        Width = 80
      end
      item
        Caption = 'ID'
      end>
    GridLines = True
    ReadOnly = True
    SortType = stData
    TabOrder = 0
    ViewStyle = vsReport
  end
end
