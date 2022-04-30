object mainform: Tmainform
  Left = 344
  Height = 202
  Top = 302
  Width = 366
  Caption = 'smallpt'
  ClientHeight = 202
  ClientWidth = 366
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  OnClose = FormClose
  OnCreate = FormCreate
  LCLVersion = '2.1.0.0'
  object imgRender: TImage
    Left = 160
    Height = 188
    Top = 4
    Width = 184
  end
  object lblTime: TLabel
    Left = 17
    Height = 13
    Top = 144
    Width = 60
    Caption = 'Time Taken:'
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
    Left = 77
    Height = 25
    Top = 112
    Width = 75
    Caption = '&Render'
    OnClick = cmdRenderClick
    TabOrder = 0
  end
  object cmdSave: TButton
    Left = 77
    Height = 25
    Top = 168
    Width = 75
    Caption = '&Save Image'
    OnClick = cmdSaveClick
    TabOrder = 1
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
  object sd: TSaveDialog
    Filter = 'Bitmap files (*.BMP)|*.bmp'
    Left = 13
    Top = 111
  end
  object tmr_update: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tmr_updateTimer
    Left = 176
    Top = 104
  end
end
