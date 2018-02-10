object frmJoin: TfrmJoin
  Left = 258
  Top = 193
  HelpContext = 6
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'Custom Join'
  ClientHeight = 273
  ClientWidth = 409
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
  object lblCmdLine1: TLabel
    Left = 8
    Top = 8
    Width = 82
    Height = 13
    Caption = 'Command Line 1:'
  end
  object lblCmdLine2: TLabel
    Left = 8
    Top = 56
    Width = 82
    Height = 13
    Caption = 'Command Line 2:'
  end
  object lblParam1: TLabel
    Left = 208
    Top = 8
    Width = 65
    Height = 13
    Caption = 'Parameters 1:'
  end
  object lblParam2: TLabel
    Left = 208
    Top = 56
    Width = 65
    Height = 13
    Caption = 'Parameters 2:'
  end
  object txtCmdLine2: TEdit
    Left = 8
    Top = 72
    Width = 193
    Height = 21
    MaxLength = 127
    TabOrder = 2
  end
  object mmoFileContents: TMemo
    Left = 8
    Top = 152
    Width = 393
    Height = 73
    MaxLength = 255
    TabOrder = 6
  end
  object chkFile: TCheckBox
    Left = 8
    Top = 104
    Width = 73
    Height = 17
    Caption = '&Create File:'
    TabOrder = 4
  end
  object txtFileName: TEdit
    Left = 8
    Top = 128
    Width = 393
    Height = 21
    MaxLength = 127
    TabOrder = 5
  end
  object txtParam1: TEdit
    Left = 208
    Top = 24
    Width = 193
    Height = 21
    MaxLength = 127
    TabOrder = 1
  end
  object txtParam2: TEdit
    Left = 208
    Top = 72
    Width = 193
    Height = 21
    MaxLength = 127
    TabOrder = 3
  end
  object cboCmdLine1: TComboBox
    Left = 8
    Top = 24
    Width = 193
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object cmdOK: TButton
    Left = 264
    Top = 240
    Width = 65
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 9
  end
  object cmdCancel: TButton
    Left = 336
    Top = 240
    Width = 65
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 10
  end
  object chkPassword: TCheckBox
    Left = 8
    Top = 251
    Width = 70
    Height = 17
    Caption = '&Password'
    TabOrder = 8
  end
  object chkSpec: TCheckBox
    Left = 8
    Top = 232
    Width = 73
    Height = 17
    Caption = '&Spectator'
    TabOrder = 7
  end
end
