object mainform: Tmainform
  Left = 344
  Height = 277
  Top = 302
  Width = 366
  Caption = 'smallpt'
  ClientHeight = 277
  ClientWidth = 366
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  OnClose = FormClose
  OnCreate = FormCreate
  LCLVersion = '3.6.0.0'
  object imgRender: TImage
    Left = 160
    Height = 188
    Top = 4
    Width = 184
  end
  object lblTime: TLabel
    Left = 8
    Height = 13
    Top = 130
    Width = 3
    Caption = ' '
    Color = clBtnFace
    ParentColor = False
    Transparent = False
  end
  object Label1: TLabel
    Left = 8
    Height = 13
    Top = 11
    Width = 31
    Caption = 'Width:'
    Color = clBtnFace
    ParentColor = False
    Transparent = False
  end
  object Label2: TLabel
    Left = 8
    Height = 13
    Top = 32
    Width = 34
    Caption = 'Height:'
    Color = clBtnFace
    ParentColor = False
    Transparent = False
  end
  object Label3: TLabel
    Left = 8
    Height = 13
    Top = 56
    Width = 69
    Caption = 'Sample Count:'
    Color = clBtnFace
    ParentColor = False
    Transparent = False
  end
  object Label4: TLabel
    Left = 8
    Height = 13
    Top = 82
    Width = 68
    Caption = 'Thread Count:'
    Color = clBtnFace
    ParentColor = False
    Transparent = False
  end
  object cmdRender: TButton
    Left = 8
    Height = 25
    Top = 148
    Width = 56
    Caption = '&Render'
    TabOrder = 0
    OnClick = cmdRenderClick
  end
  object cmdSave: TButton
    Left = 80
    Height = 25
    Top = 148
    Width = 75
    Caption = '&Save Image'
    Enabled = False
    TabOrder = 1
    OnClick = cmdSaveClick
  end
  object strThreadCount: TEdit
    Left = 104
    Height = 21
    Top = 80
    Width = 48
    TabOrder = 2
    Text = '8'
  end
  object strSampleCount: TEdit
    Left = 104
    Height = 21
    Top = 56
    Width = 48
    TabOrder = 3
    Text = '16'
  end
  object strWidth: TEdit
    Left = 104
    Height = 21
    Top = 8
    Width = 48
    TabOrder = 4
    Text = '1024'
  end
  object strHeight: TEdit
    Left = 104
    Height = 21
    Top = 32
    Width = 48
    TabOrder = 5
    Text = '768'
  end
  object Label5: TLabel
    Left = 8
    Height = 13
    Top = 106
    Width = 31
    Caption = 'Scene'
  end
  object SceneSelector1: TComboBox
    Left = 72
    Height = 21
    Top = 104
    Width = 80
    ItemHeight = 13
    ItemIndex = 0
    Items.Strings = (
      'Big light'
      'Small light'
    )
    ReadOnly = True
    TabOrder = 6
    Text = 'Big light'
  end
  object StopRenderBtn: TButton
    Left = 8
    Height = 25
    Top = 176
    Width = 144
    Caption = 'Stop render'
    Enabled = False
    TabOrder = 7
    OnClick = StopRenderBtnClick
  end
  object sd: TSaveDialog
    Filter = 'Bitmap files (*.BMP)|*.bmp'
    Left = 168
    Top = 16
  end
  object tmr_update: TTimer
    Enabled = False
    Interval = 200
    Left = 200
    Top = 16
  end
end
