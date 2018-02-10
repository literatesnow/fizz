object frmFilter: TfrmFilter
  Left = 350
  Top = 189
  HelpContext = 19
  ActiveControl = lvwFilter
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'Server Filter Setup'
  ClientHeight = 377
  ClientWidth = 591
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
  object lblName: TLabel
    Left = 8
    Top = 156
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object lvwFilter: TListView
    Left = 8
    Top = 8
    Width = 497
    Height = 137
    Columns = <
      item
        Caption = 'Filter Name'
        Width = 474
      end>
    ColumnClick = False
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = lvwFilterSelectItem
  end
  object cmdOK: TButton
    Left = 512
    Top = 8
    Width = 73
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 512
    Top = 40
    Width = 73
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object cmdAdd: TButton
    Left = 216
    Top = 152
    Width = 73
    Height = 21
    Caption = 'Add Ne&w'
    TabOrder = 3
    OnClick = cmdAddClick
  end
  object grpRule: TGroupBox
    Left = 8
    Top = 280
    Width = 369
    Height = 89
    Caption = 'Server Info'
    TabOrder = 4
    object txtRS: TEdit
      Left = 8
      Top = 24
      Width = 145
      Height = 21
      Enabled = False
      TabOrder = 0
    end
    object cboRO: TComboBox
      Left = 160
      Top = 24
      Width = 41
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = '<'
      Items.Strings = (
        '<'
        '>'
        '=='
        '!=')
    end
    object txtRD: TEdit
      Left = 208
      Top = 24
      Width = 153
      Height = 21
      Enabled = False
      TabOrder = 2
    end
    object cmdRAdd: TButton
      Left = 328
      Top = 56
      Width = 33
      Height = 21
      Caption = 'A&dd'
      Enabled = False
      TabOrder = 3
      OnClick = cmdRAddClick
    end
  end
  object grpServer: TGroupBox
    Left = 8
    Top = 184
    Width = 369
    Height = 89
    Caption = 'Server Status'
    TabOrder = 5
    object cboSO: TComboBox
      Left = 160
      Top = 24
      Width = 41
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = '<'
      Items.Strings = (
        '<'
        '>'
        '=='
        '!=')
    end
    object cboSS: TComboBox
      Left = 8
      Top = 24
      Width = 145
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = 'Server Name'
      Items.Strings = (
        'Server Name'
        'Ping'
        'Map'
        'Players'
        'Mod'
        'Responds')
    end
    object cmdSAdd: TButton
      Left = 328
      Top = 56
      Width = 33
      Height = 21
      Caption = '&Add'
      Enabled = False
      TabOrder = 2
      OnClick = cmdSAddClick
    end
    object txtSD: TEdit
      Left = 208
      Top = 24
      Width = 153
      Height = 21
      Enabled = False
      TabOrder = 3
    end
  end
  object lvwFilterItems: TListView
    Left = 384
    Top = 189
    Width = 201
    Height = 152
    Columns = <
      item
        Caption = 'Filter'
        Width = 180
      end>
    ColumnClick = False
    Enabled = False
    ReadOnly = True
    TabOrder = 6
    ViewStyle = vsReport
    OnSelectItem = lvwFilterItemsSelectItem
  end
  object txtName: TEdit
    Left = 48
    Top = 152
    Width = 161
    Height = 21
    TabOrder = 7
  end
  object cmdRemove: TButton
    Left = 296
    Top = 152
    Width = 73
    Height = 21
    Caption = '&Remove'
    Enabled = False
    TabOrder = 8
    OnClick = cmdRemoveClick
  end
  object cmdDelete: TButton
    Left = 512
    Top = 347
    Width = 73
    Height = 21
    Caption = 'D&elete'
    Enabled = False
    TabOrder = 9
    OnClick = cmdDeleteClick
  end
end
