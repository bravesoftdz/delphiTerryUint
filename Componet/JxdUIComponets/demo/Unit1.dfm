object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 282
  ClientWidth = 579
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object xdgptbst1: TxdGpTabSet
    Left = 0
    Top = 0
    Width = 579
    Height = 25
    Align = alTop
    AllowMoveByMouse = False
    HandleMouseMoveOnDrawByInfo = True
    AutoSizeByImage = False
    ImageInfo.ImageFileName = 'E:\CompanyWork\MusicT\KBox2.1\Res\'#25353#38062'\'#25353#38062'_01.png'
    ImageDrawMethod.AutoSort = False
    ImageDrawMethod.CenterOnPaste = True
    ImageDrawMethod.DrawStyle = dsDrawByInfo
    FontInfo.FontName = 'Tahoma'
    FontInfo.FontSize = 10
    FontInfo.FontColor = -4369
    FontInfo.FontTrimming = StringTrimmingEllipsisCharacter
    FontInfo.FontAlignment = StringAlignmentCenter
    FontInfo.FontLineAlignment = StringAlignmentCenter
    CaptionPosition.Left = 0
    CaptionPosition.Top = 0
    CaptionPosition.Width = 0
    CaptionPosition.Height = 0
    ImageTabItemClose.ImageFileName = 'E:\CompanyWork\MusicT\KBox2.1\Res\'#25353#38062'\'#25353#38062'_07.png'
    TabItemDrawStyle = dsStretchAll
    ItemIndex = -1
    ExplicitLeft = 48
    ExplicitTop = 64
    ExplicitWidth = 500
  end
  object btn4: TxdButton
    Left = 290
    Top = 31
    Width = 145
    Height = 122
    Caption = 'btn4'
    AllowMoveByMouse = False
    HandleMouseMoveOnDrawByInfo = True
    AutoSizeByImage = False
    ImageInfo.ImageFileName = 
      'E:\CompanyWork\MusicT\KBox2.1\Bin\Skins\TestSkin1\WebLoginReg.pn' +
      'g'
    ImageInfo.ImageCount = 1
    ImageDrawMethod.AutoSort = True
    ImageDrawMethod.CenterOnPaste = True
    ImageDrawMethod.DrawStyle = dsStretchByVH
    FontInfo.FontName = 'Tahoma'
    FontInfo.FontSize = 10
    FontInfo.FontColor = -16777216
    FontInfo.FontTrimming = StringTrimmingEllipsisCharacter
    FontInfo.FontAlignment = StringAlignmentNear
    FontInfo.FontLineAlignment = StringAlignmentCenter
    CaptionPosition.Left = 0
    CaptionPosition.Top = 0
    CaptionPosition.Width = 0
    CaptionPosition.Height = 0
    Selected = False
  end
  object btn1: TButton
    Left = 48
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 0
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 129
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Del'
    TabOrder = 1
    OnClick = btn2Click
  end
  object edt1: TEdit
    Left = 224
    Top = 242
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object btn3: TButton
    Left = 360
    Top = 240
    Width = 75
    Height = 25
    Caption = 'btn3'
    TabOrder = 3
    OnClick = btn3Click
  end
  object mmo1: TMemo
    Left = 48
    Top = 80
    Width = 241
    Height = 137
    Lines.Strings = (
      '%CA%E4%C8%EB'
      '%B5%C4%D1%E9%D6%A4%C2%EB'
      '%B2%BB%D5%FD%C8%B7')
    TabOrder = 4
    OnDblClick = mmo1DblClick
    OnDragDrop = mmo1DragDrop
    OnDragOver = mmo1DragOver
  end
end
