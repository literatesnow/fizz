object frmAddServer: TfrmAddServer
  Left = 265
  Top = 211
  HelpContext = 3
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'Add Server'
  ClientHeight = 337
  ClientWidth = 441
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
  object lblDelimiter: TLabel
    Left = 56
    Top = 307
    Width = 43
    Height = 13
    Caption = 'Delimiter:'
    Enabled = False
  end
  object cmdDone: TButton
    Left = 376
    Top = 304
    Width = 59
    Height = 25
    Cancel = True
    Caption = '&Done'
    TabOrder = 2
    OnClick = cmdDoneClick
  end
  object cmdAdd: TButton
    Left = 312
    Top = 304
    Width = 57
    Height = 25
    Caption = '&Add'
    TabOrder = 1
    OnClick = cmdAddClick
  end
  object mmoServers: TMemo
    Left = 8
    Top = 8
    Width = 425
    Height = 185
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object mmoResult: TMemo
    Left = 8
    Top = 200
    Width = 425
    Height = 97
    Color = clInactiveCaptionText
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object txtDil: TEdit
    Left = 104
    Top = 304
    Width = 17
    Height = 21
    Enabled = False
    MaxLength = 1
    TabOrder = 7
    Text = ':'
  end
  object cmdLoadFile: TButton
    Left = 240
    Top = 304
    Width = 57
    Height = 25
    Caption = '&Load File'
    TabOrder = 3
    OnClick = cmdLoadFileClick
  end
  object cmdClear: TButton
    Left = 176
    Top = 304
    Width = 57
    Height = 25
    Caption = '&Clear'
    TabOrder = 4
    OnClick = cmdClearClick
  end
  object chkList: TCheckBox
    Left = 8
    Top = 306
    Width = 41
    Height = 17
    Caption = '&List'
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = chkListClick
  end
end
