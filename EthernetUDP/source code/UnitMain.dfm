object FormMain: TFormMain
  Left = 207
  Top = 114
  BorderStyle = bsDialog
  Caption = 'EthernetUDP'
  ClientHeight = 410
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object LabelSourceMAC: TLabel
    Left = 26
    Top = 20
    Width = 63
    Height = 13
    Alignment = taRightJustify
    Caption = 'Source MAC:'
  end
  object LabelDestinationMAC: TLabel
    Left = 7
    Top = 44
    Width = 82
    Height = 13
    Alignment = taRightJustify
    Caption = 'Destination MAC:'
  end
  object LabelSourceIP: TLabel
    Left = 39
    Top = 68
    Width = 50
    Height = 13
    Alignment = taRightJustify
    Caption = 'Source IP:'
  end
  object LabelDestinationIP: TLabel
    Left = 20
    Top = 92
    Width = 69
    Height = 13
    Alignment = taRightJustify
    Caption = 'Destination IP:'
  end
  object LabelPayloadLenght: TLabel
    Left = 16
    Top = 116
    Width = 73
    Height = 13
    Alignment = taRightJustify
    Caption = 'Payload length:'
  end
  object LabelSourcePort: TLabel
    Left = 199
    Top = 68
    Width = 18
    Height = 13
    Alignment = taRightJustify
    Caption = 'port'
  end
  object LabelDestinationPort: TLabel
    Left = 199
    Top = 92
    Width = 18
    Height = 13
    Alignment = taRightJustify
    Caption = 'port'
  end
  object EditDestinationMAC_Address: TEdit
    Left = 96
    Top = 40
    Width = 89
    Height = 21
    MaxLength = 12
    TabOrder = 2
    Text = '0010A47BEA80'
  end
  object EditSourceMAC_Address: TEdit
    Left = 96
    Top = 16
    Width = 89
    Height = 21
    MaxLength = 12
    TabOrder = 1
    Text = '001234567890'
  end
  object ButtonSend: TButton
    Left = 208
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Send!'
    TabOrder = 0
    OnClick = ButtonSendClick
  end
  object SpinEditPayloadLength: TSpinEdit
    Left = 96
    Top = 112
    Width = 49
    Height = 22
    MaxValue = 1500
    MinValue = 1
    TabOrder = 7
    Value = 18
  end
  object EditSourceIP: TEdit
    Left = 96
    Top = 64
    Width = 89
    Height = 21
    MaxLength = 15
    TabOrder = 3
    Text = '192.168.0.44'
  end
  object EditDestinationIP: TEdit
    Left = 96
    Top = 88
    Width = 89
    Height = 21
    MaxLength = 15
    TabOrder = 5
    Text = '192.168.0.4'
  end
  object Memo: TMemo
    Left = 8
    Top = 152
    Width = 497
    Height = 249
    ScrollBars = ssVertical
    TabOrder = 8
  end
  object SpinEditSourcePort: TSpinEdit
    Left = 224
    Top = 64
    Width = 57
    Height = 22
    MaxValue = 65535
    MinValue = 0
    TabOrder = 4
    Value = 1024
  end
  object SpinEditDestinationPort: TSpinEdit
    Left = 224
    Top = 88
    Width = 57
    Height = 22
    MaxValue = 65535
    MinValue = 0
    TabOrder = 6
    Value = 1024
  end
  object ButtonClear: TButton
    Left = 432
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 9
    OnClick = ButtonClearClick
  end
end
