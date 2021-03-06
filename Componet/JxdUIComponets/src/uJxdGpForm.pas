unit uJxdGpForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ExtCtrls,
  Dialogs, uJxdGpStyle, uJxdGPSub, GDIPAPI, GDIPOBJ;

type
  TTieStyle = (tsNULL, tsLeft, tsTop, tsRight, tsBottom);
  TxdForm = class(TForm)
  public
    ImageBK2: TGPBitmap;

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;  
  protected
    procedure Resize; override;
    procedure DoShow; override;
    procedure DoClose(var Action: TCloseAction); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    {窗口过程}
    procedure WndProc(var msg: TMessage); override;

    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  private
    {绘制相关变量}
    FBmpDC: HDC;
    FBufBmp: HBITMAP;
    FCurBmpWidth, FCurBmpHeight: Integer;
    FDelDrawObjectTimer: TTimer;
    
    FAnimateTimer: TTimer;
    FAnimateClose: Boolean;
    FAnimateSpeed, FAnimateVale: Integer;
    FAnimateAlphaValueSpeed: Integer;
    function  DoXorCombiPixel(const Ap: PArghInfo): Boolean;
    procedure CheckSize;
    function  CheckToAnimateHide: Boolean;    
    procedure ClearBkRes;
    procedure DoTimerToDeleteDrawObject(Sender: TObject);
    procedure DoTimerToAnimateShow(Sender: TObject); 
    procedure DoTimerToAnimateHide(Sender: TObject);    

    {绘制使用方法}
    procedure DoDrawObjectChagned(Sender: TObject);
  private
    {自动依靠信息}
    FCurTieStyle: TTieStyle;
    FCurTieWnd: TxdForm;
    FWinRect: TRect;
    FTieSubWndList: TList;
    
    procedure AddTieWnd(AForm: TxdForm);
    procedure DelTieWnd(AForm: TxdForm);
    procedure CheckCurTieWnd;
    function  CheckTieStyle(AForm: TxdForm): TTieStyle;
    procedure DoMoveSubWndPos(const AOldR, ACurR: TRect);
    procedure DoHandleWM_Moving(var pCurRect: PRect);
  private
    FImageInfo: TImageInfo;
    FAutoSizeByImage: Boolean;
    FAutoTieSpace: Integer;
    FMoveForm: Boolean;
    FAnimate: Boolean;
    FCreateFormStyleByImage: Boolean;
    FAutoTie: Boolean;
    FImgDrawMethod: TDrawMethod;
    FCreateFormStyleByAlphaValue: Byte;
    FAutoChangedSize: Boolean;
    procedure SetAnimate(const Value: Boolean);
    procedure SetAutoSizeByImage(const Value: Boolean);
    procedure SetAutoTie(const Value: Boolean);
    procedure SetAutoTieSpace(const Value: Integer);
    procedure SetCreateFormStyleByImage(const Value: Boolean);
    procedure SetImageInfo(const Value: TImageInfo);
    procedure SetImgDrawMethod(const Value: TDrawMethod);
  published
    //自动移动窗口
    property AutoMoveForm: Boolean read FMoveForm write FMoveForm default True;
    property AutoChangedSize: Boolean read FAutoChangedSize write FAutoChangedSize;
    {自动停靠}
    property AutoTie: Boolean read FAutoTie write SetAutoTie;
    property AutoTieSpace: Integer read FAutoTieSpace write SetAutoTieSpace;
    {显示或隐藏动态效果}
    property Animate: Boolean read FAnimate write SetAnimate; //窗口显示或隐藏时，是否以动画的效果来表现
    {窗口背景与形状}
    property AutoSizeByImage: Boolean read FAutoSizeByImage write SetAutoSizeByImage; //使用图像的大小来设置窗口的大小
    property CreateFormStyleByImage: Boolean read FCreateFormStyleByImage write SetCreateFormStyleByImage; //根据图像的透明来设置窗口的样式
        //使用图像的Aplha值来创建窗口，当图像中的Aplha值小于指定值时，其位置将被透明掉
    property CreateFormStyleByAlphaValue: Byte read FCreateFormStyleByAlphaValue write FCreateFormStyleByAlphaValue; 
    property ImageInfo: TImageInfo read FImageInfo write SetImageInfo; //图像信息
    property ImageDrawMethod: TDrawMethod read FImgDrawMethod write SetImgDrawMethod; //绘制方式
  end;

implementation

{$R *.dfm}

const
  CtAnimateSpaceTime = 20; //动画窗口间隔时间
  CtAnimateExcuteCount = 5; //动画窗口次数

var
  _TieFormManage: TList = nil;

procedure AddTieWndToManage(f: TxdForm);
var
  i: Integer;
  bAdd: Boolean;
begin
  if not Assigned(_TieFormManage) then
  begin
    _TieFormManage := TList.Create;
    _TieFormManage.Add( f );
  end
  else
  begin
    bAdd := True;
    for i := 0 to _TieFormManage.Count - 1 do
    begin
      if _TieFormManage[i] = f then
      begin
        bAdd := False;
        Break;
      end;
    end;
    if bAdd then
      _TieFormManage.Add( f );
  end;
end;

procedure DeleteTieWndFromManage(f: TxdForm);
var
  i: Integer;
  xdF: TxdForm;
begin
  if not Assigned(_TieFormManage) then Exit;

  for i := 0 to _TieFormManage.Count - 1 do
  begin
    if _TieFormManage[i] = f then
    begin
      _TieFormManage.Delete( i );
      Break;
    end;
  end;
  for i := 0 to _TieFormManage.Count - 1 do
  begin
    xdF := _TieFormManage[i];
    xdF.DelTieWnd( f );
  end;
  if _TieFormManage.Count = 0 then
    FreeAndNil( _TieFormManage );
end;

{ TxdForm }

procedure TxdForm.AddTieWnd(AForm: TxdForm);
var
  i: Integer;
  bAdd: Boolean;
begin
  bAdd := True;
  for i := 0 to FTieSubWndList.Count - 1 do
  begin
    if FTieSubWndList[i] = AForm then
    begin
      bAdd := False;
      Break;
    end;
  end;
  if bAdd then
    FTieSubWndList.Add( AForm );
end;

procedure TxdForm.CheckCurTieWnd;
  function IsSubTieForm(AForm: TxdForm): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := 0 to FTieSubWndList.Count - 1 do
    begin
      if FTieSubWndList[i] = AForm then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
var
  i: Integer;
  f: TxdForm;
begin
  if not Assigned(FTieSubWndList) then Exit;  
  if Assigned(FCurTieWnd) and IsWindowVisible(FCurTieWnd.Handle) then
    FCurTieStyle := CheckTieStyle( FCurTieWnd )
  else
    FCurTieStyle := tsNULL;

  if FCurTieStyle = tsNULL then
  begin
    for i := 0 to _TieFormManage.Count - 1 do
    begin
      f := _TieFormManage[i];
      if IsWindowVisible(f.Handle) and (f <> Self) and (f <> FCurTieWnd) and not IsSubTieForm(f) then
      begin
        FCurTieStyle := CheckTieStyle( f );
        if FCurTieStyle <> tsNULL then
        begin
          FCurTieWnd := f;
          FCurTieWnd.AddTieWnd( Self );
          Break;
        end;
      end;
    end;
  end;
  
  if FCurTieStyle = tsNULL then
  begin
    if Assigned(FCurTieWnd) then
    begin
      FCurTieWnd.DelTieWnd( Self );
      FCurTieWnd := nil;
    end;
  end
  else
  begin
    for i := 0 to FTieSubWndList.Count - 1 do
    begin
      if FTieSubWndList[i] = FCurTieWnd then
      begin
        FTieSubWndList.Delete( i );
        Break;
      end;
    end;
  end;
end;

procedure TxdForm.CheckSize;
begin
  if FCreateFormStyleByImage and Assigned(FImageInfo.Image) and AutoSizeByImage then
    SetWindowPos( Handle, 0, 0, 0, FImageInfo.Image.GetWidth, FImageInfo.Image.GetHeight, SWP_NOMOVE );
end;

function TxdForm.CheckTieStyle(AForm: TxdForm): TTieStyle;
  function CheckCombin(A1, B1, A2, B2: Integer): Boolean;
  begin
    Result := (((A1 >= A2) and (A1 <= B2)) or ((B1 >= A2) and (B1 <= B2))) or
              (((A2 >= A1) and (A2 <= B1)) or ((B2 >= A1) and (B2 <= B1)));
  end;
var
  R1, R2: TRect;
begin
  {
    A  B
    R1 R2
    口 口
    
    以B为参照点，tsLeft 表示 A在B的左边，差值在范围之内； tsTop 表示 A在B的上边，差值在范围之内；
  }
  R1 := FWinRect;
  R2 := AForm.FWinRect;
  
  Result := tsNULL;
  if CheckCombin(R1.Top, R1.Bottom, R2.Top, R2.Bottom) then
  begin
    if Abs(R1.Right - R2.Left) <= AutoTieSpace then
      Result := tsLeft
    else if Abs(R1.Left - R2.Right) <= AutoTieSpace then
      Result := tsRight
    else if Abs(R1.Top - R2.Bottom) <= AutoTieSpace then
      Result := tsBottom
    else if Abs(R1.Bottom - R2.Top) <= AutoTieSpace then
      Result := tsTop
  end
  else if CheckCombin(R1.Left, R1.Right, R2.Left, R2.Right) then
  begin
    if Abs(R1.Top - R2.Bottom) <= AutoTieSpace then
      Result := tsBottom
    else if Abs(R1.Bottom - R2.Top) <= AutoTieSpace then
      Result := tsTop
    else if Abs(R1.Right - R2.Left) <= AutoTieSpace then
      Result := tsLeft
    else if Abs(R1.Left - R2.Right) <= AutoTieSpace then
      Result := tsRight
  end;
        
end;

function TxdForm.CheckToAnimateHide: Boolean;
begin
  Result := False;
  if Animate and not FAnimateClose and not Assigned(FAnimateTimer) then
  begin    
    Result := True;
    FAnimateClose := True;
    
    FAnimateTimer := TTimer.Create( Self );
    FAnimateTimer.Interval := CtAnimateSpaceTime;
    FAnimateTimer.OnTimer := DoTimerToAnimateHide;
    
    FAnimateSpeed := 6;    
    FAnimateVale := -FAnimateSpeed * CtAnimateExcuteCount;

    FAnimateAlphaValueSpeed := -20;
    AlphaBlendValue := 255;
    AlphaBlend := True;    
    
    FAnimateTimer.Enabled := True;
  end;  
end;

procedure TxdForm.ClearBkRes;
begin
  FCurBmpWidth := 0;
  FCurBmpHeight := 0;
  if FBufBmp <> 0 then
  begin
    DeleteObject( FBufBmp );
    FBufBmp := 0;
  end;
  if FBmpDC <> 0 then
  begin
    DeleteDC( FBmpDC );
    FBmpDC := 0;
  end;
end;

procedure TxdForm.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Cursor := crDefault;
end;

constructor TxdForm.Create(AOwner: TComponent);
begin  
  FAutoTie := False;
  FAutoSizeByImage := False;
  FAutoChangedSize := False;
  FAnimate := False;
  FAnimateTimer := nil;
  FTieSubWndList := nil;
  FCurTieWnd := nil;
  ImageBK2 := nil;
  FCurTieStyle := tsNULL;
  FAnimateClose := False;
  FAutoTieSpace := 5;
  FMoveForm := True;
  FCurBmpWidth := 0;
  FCurBmpHeight := 0;
  FBmpDC := 0;
  FBufBmp := 0;
  FCreateFormStyleByAlphaValue := 50;
  FDelDrawObjectTimer := nil;
  
  FImageInfo := TImageInfo.Create;
  FImgDrawMethod := TDrawMethod.Create;

  FImageInfo.OnChange := DoDrawObjectChagned;
  FImgDrawMethod.OnChange := DoDrawObjectChagned;
  inherited;
end;

procedure TxdForm.DelTieWnd(AForm: TxdForm);
var
  i: Integer;
begin
  for i := 0 to FTieSubWndList.Count - 1 do
  begin
    if FTieSubWndList[i] = AForm then
    begin
      FTieSubWndList.Delete( i );
      Break;
    end;
  end;
end;

destructor TxdForm.Destroy;
begin
  FreeAndNil( FImageInfo );
  FreeAndNil( FImgDrawMethod );
  FreeAndNil( FAnimateTimer );
  FreeAndNil( FTieSubWndList );
  FreeAndNil( FDelDrawObjectTimer );
  if FBmpDC <> 0 then
    DeleteDC( FBmpDC );
  if FBufBmp <> 0 then
    DeleteObject( FBufBmp );
  inherited;
end;

procedure TxdForm.DoClose(var Action: TCloseAction);
begin
  inherited;
  if (Action = caHide) and CheckToAnimateHide then
    Action := caNone;
end;

procedure TxdForm.DoDrawObjectChagned(Sender: TObject);
begin
  CheckSize;
  Invalidate;
end;

procedure TxdForm.DoHandleWM_Moving(var pCurRect: PRect);
var
  nW, nH: Integer;
  old: TRect;
begin
  old := FWinRect;
  FWinRect := pCurRect^;
  CheckCurTieWnd;
  
  if Assigned(FCurTieWnd) then
  begin    
    case FCurTieStyle of
      tsLeft:   
      begin
        nW := pCurRect^.Right - pCurRect^.Left;
        pCurRect^.Left := FCurTieWnd.FWinRect.Left - nW;
        pCurRect^.Right := pCurRect^.Left + nW;
      end;
      tsTop:    
      begin
        nH := pCurRect^.Bottom - pCurRect^.Top;
        pCurRect^.Top := FCurTieWnd.FWinRect.Top - nH;
        pCurRect^.Bottom := pCurRect^.Top + nH;
      end;
      tsRight:  
      begin
        nW := pCurRect^.Right - pCurRect^.Left;
        pCurRect^.Left := FCurTieWnd.FWinRect.Right;
        pCurRect^.Right := pCurRect^.Left + nW;
      end;
      tsBottom: 
      begin
        nH := pCurRect^.Bottom - pCurRect^.Top;
        pCurRect^.Top := FCurTieWnd.FWinRect.Bottom;
        pCurRect^.Bottom := pCurRect^.Top + nH;
      end;
    end;
  end;
  DoMoveSubWndPos( old, pCurRect^ );  
  FWinRect := pCurRect^;
end;

procedure TxdForm.DoMoveSubWndPos(const AOldR, ACurR: TRect);
var
  i: Integer;
  X, Y: Integer;
  f: TxdForm;
begin
  if Assigned(FTieSubWndList) then
  begin
    X := ACurR.Left - AOldR.Left;
    Y := ACurR.Top - AOldR.Top;
    for i := 0 to FTieSubWndList.Count - 1 do
    begin
      f := FTieSubWndList[i];
      SetWindowPos( f.Handle, 0, f.FWinRect.Left + X, f.FWinRect.Top + Y, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE );
    end;
  end;
end;

procedure TxdForm.DoShow;
begin        
  if Animate and not Assigned(FAnimateTimer) then
  begin
    FAnimateTimer := TTimer.Create( Self );
    FAnimateTimer.Interval := CtAnimateSpaceTime;
    FAnimateTimer.OnTimer := DoTimerToAnimateShow;
    
    FAnimateSpeed := 6;    
    FAnimateVale := FAnimateSpeed * CtAnimateExcuteCount;

    FAnimateAlphaValueSpeed := 20;
    AlphaBlend := True;
    AlphaBlendValue := 10;
    
    FAnimateTimer.Enabled := True;
  end; 
  inherited DoShow;
  FAnimateClose := False;
end;

procedure TxdForm.DoTimerToAnimateHide(Sender: TObject);
var
  rgn: HRGN;
begin
  Invalidate;
  if FAnimateVale <= 0 then
  begin
    rgn := CreateRectRgn( -FAnimateVale, -FAnimateVale, Width + FAnimateVale, Height + FAnimateVale );
    SetWindowRgn( Handle, rgn, False );
    DeleteObject( rgn );

    if FAnimateAlphaValueSpeed + AlphaBlendValue <= 255 then    
      AlphaBlendValue := FAnimateAlphaValueSpeed + AlphaBlendValue;
    Inc(FAnimateVale, FAnimateSpeed);
  end
  else
  begin   
    FAnimateClose := True; 
    Close;    
    FreeAndNil( FAnimateTimer );
  end;
end;

procedure TxdForm.DoTimerToAnimateShow(Sender: TObject);
var
  rgn: HRGN;
begin
  Invalidate;
  if FAnimateVale >= 0 then
  begin
    rgn := CreateRectRgn( FAnimateVale, FAnimateVale, Width - FAnimateVale, Height - FAnimateVale );
    SetWindowRgn( Handle, rgn, False );
    DeleteObject( rgn );    
    
    if FAnimateAlphaValueSpeed + AlphaBlendValue <= 255 then    
      AlphaBlendValue := FAnimateAlphaValueSpeed + AlphaBlendValue;
    Dec(FAnimateVale, FAnimateSpeed);
  end
  else
  begin
    AlphaBlendValue := 255;
    AlphaBlend := False;
    FreeAndNil( FAnimateTimer );
    ClearBkRes;
  end;  
end;

procedure TxdForm.DoTimerToDeleteDrawObject(Sender: TObject);
begin
  ClearBkRes;
  FreeAndNil( FDelDrawObjectTimer );
end;

function TxdForm.DoXorCombiPixel(const Ap: PArghInfo): Boolean;
begin
  Result := Ap^.FAlpha < CreateFormStyleByAlphaValue;
end;

procedure TxdForm.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  case Cursor of
    crSizeNWSE:
    begin
      if AutoChangedSize and (WindowState <> wsMaximized) then
      begin
        ReleaseCapture;
        PostMessage(Handle, WM_NCLBUTTONDOWN, HTBOTTOMRIGHT, 0);
      end;
    end;
    crSizeWE:
    begin
      if AutoChangedSize and (WindowState <> wsMaximized) then
      begin
        ReleaseCapture;
        PostMessage(Handle, WM_NCLBUTTONDOWN, HTRIGHT, 0);
      end;
    end;
    crSizeNS:
    begin
      if AutoChangedSize and (WindowState <> wsMaximized) then
      begin
        ReleaseCapture;
        PostMessage(Handle, WM_NCLBUTTONDOWN, HTBOTTOM, 0);
      end;
    end
    else
    begin
     if AutoMoveForm and (WindowState <> wsMaximized) then
      begin
        ReleaseCapture;
        PostMessage(Handle, WM_SYSCOMMAND, 61458, 0);
      end;
    end;       
  end;  
end;

procedure TxdForm.MouseMove(Shift: TShiftState; X, Y: Integer);
const
  CtSpace = 10;
var
  nW, nH: Integer;
  R: TRect;
begin
  inherited;
  if (csDesigning in ComponentState) or not AutoChangedSize or (WindowState = wsMaximized) then  Exit;
  nW := Width;
  nH := Height;
  R := Rect( nW - CtSpace, nH - CtSpace, nW, nH );
  if PtInRect( R, Point(x, y)) then
    Cursor := crSizeNWSE
  else
  begin
    R := Rect( nW - CtSpace, 0, nW, nH );
    if PtInRect( R, Point(x, y)) then
      Cursor := crSizeWE
    else
    begin
      R := Rect( 0, nH - CtSpace, nW, nH );
      if PtInRect( R, Point(x, y)) then
        Cursor := crSizeNS
      else
        Cursor := crDefault;      
    end;
  end;    
end;

procedure TxdForm.Resize;
begin
  inherited; 
  GetWindowRect( Handle, FWinRect );
  Invalidate;
end;

procedure TxdForm.SetAnimate(const Value: Boolean);
begin
  FAnimate := Value;
end;

procedure TxdForm.SetAutoSizeByImage(const Value: Boolean);
begin
  if FAutoSizeByImage <> Value then
  begin
    FAutoSizeByImage := Value;
    if FAutoSizeByImage then
      CheckSize;
  end;
end;

procedure TxdForm.SetAutoTie(const Value: Boolean);
begin
  if FAutoTie <> Value then
  begin
    FAutoTie := Value;
    if (csDesigning in ComponentState) then  Exit;    
    if FAutoTie then
    begin
      if not Assigned(FTieSubWndList) then
        FTieSubWndList := TList.Create;
      AddTieWndToManage( Self );
      GetWindowRect( Handle, FWinRect );
      CheckCurTieWnd;
    end
    else
    begin
      if Assigned(FTieSubWndList) then
        FreeAndNil( FTieSubWndList );
      DeleteTieWndFromManage( Self );
    end;
  end;
end;

procedure TxdForm.SetAutoTieSpace(const Value: Integer);
begin
  FAutoTieSpace := Value;
end;

procedure TxdForm.SetCreateFormStyleByImage(const Value: Boolean);
begin
  if FCreateFormStyleByImage <> Value then
  begin
    FCreateFormStyleByImage := Value;
    CheckSize;    
    Invalidate;
  end;
end;

procedure TxdForm.SetImageInfo(const Value: TImageInfo);
begin
  FImageInfo.Assign( Value );
end;

procedure TxdForm.SetImgDrawMethod(const Value: TDrawMethod);
begin
  FImgDrawMethod.Assign( Value );
end;

procedure TxdForm.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  Message.Result := 1;
end;

procedure TxdForm.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
  bmp: TGPBitmap;
  bmpG: TGPGraphics;
  h: HRGN;
  bAllReDraw: Boolean;
  
  MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
begin
//  OutputDebugString( Pchar(IntToStr(Message.DC)));
  if (Message.DC = 0) and Assigned(FImageInfo.Image) then
  begin    
    DC := BeginPaint(Handle, PS);
    try 
      bAllReDraw := False;
      if (FCurBmpWidth <> Width) or (FCurBmpHeight <> Height) or 
         ((PS.rcPaint.Right - PS.rcPaint.Left = Width) and (PS.rcPaint.Bottom - PS.rcPaint.Top = Height)) then
      begin
        if FBufBmp <> 0 then
          DeleteObject( FBufBmp );
        if FBmpDC <> 0 then
          DeleteDC( FBmpDC );  
                
        FCurBmpWidth := Width;
        FCurBmpHeight := Height;
        bAllReDraw := True;
        
        bmp := TGPBitmap.Create( FCurBmpWidth, FCurBmpHeight);
        bmpG := TGPGraphics.Create( bmp );

        //绘制背景到临时图片
        DrawImageCommon( bmpG, MakeRect(0, 0, FCurBmpWidth, FCurBmpHeight), FImageInfo, FImgDrawMethod, nil, nil, nil, nil );

//        FImageInfo.Image.Save( 'bb.bmp', GetEncoderClsid(ImgFormatBitmap) );
//        bmp.Save( 'aa.bmp', GetEncoderClsid(ImgFormatBitmap) );

        //根据图片来创建窗口形状  
        h := CreateStyleByBitmap( bmp, DoXorCombiPixel );
        SetWindowRgn( Handle, h, True );
        DeleteObject( h );

        //第二层背景
        if Assigned(ImageBK2) then
          bmpG.DrawImage( ImageBK2, MakeRect(0, 0, Width, Height),
            0, 0, ImageBK2.GetWidth, ImageBK2.GetHeight, UnitPixel );

        bmp.GetHBITMAP( 0, FBufBmp );
        bmpG.Free;        
        bmp.Free;
        
        FBmpDC := CreateCompatibleDC( DC );
        SelectObject( FBmpDC, FBufBmp );        
      end;

      if ControlCount = 0 then
      begin
        if bAllReDraw then
          BitBlt( DC, 0, 0, Width, Height, FBmpDC, 0, 0, SRCCOPY )
        else
          BitBlt( DC, PS.rcPaint.Left, PS.rcPaint.Top, 
            PS.rcPaint.Right - PS.rcPaint.Left, PS.rcPaint.Bottom - PS.rcPaint.Top,
            FBmpDC, PS.rcPaint.Left, PS.rcPaint.Top, SRCCOPY );
      end
      else
      begin
        //绘制子控件
        MemDC := CreateCompatibleDC(DC);
        MemBitmap := CreateCompatibleBitmap(DC, PS.rcPaint.Right - PS.rcPaint.Left,
          PS.rcPaint.Bottom - PS.rcPaint.Top);
        OldBitmap := SelectObject(MemDC, MemBitmap);
        try
          SetWindowOrgEx(MemDC, PS.rcPaint.Left, PS.rcPaint.Top, nil);
          BitBlt( MemDC, 0, 0, Width, Height, FBmpDC, 0, 0, SRCCOPY );
          Message.DC := MemDC;
          WMPaint(Message);
          Message.DC := 0;
          BitBlt(DC, PS.rcPaint.Left, PS.rcPaint.Top,
            PS.rcPaint.Right - PS.rcPaint.Left, PS.rcPaint.Bottom - PS.rcPaint.Top,
            MemDC, PS.rcPaint.Left, PS.rcPaint.Top, SRCCOPY);
        finally
          SelectObject(MemDC, OldBitmap);
          DeleteDC(MemDC);
          DeleteObject(MemBitmap);
        end;
      end;
    finally
      EndPaint(Handle, PS);
    end;

    if not (csDesigning in ComponentState) then
    begin
      if not Assigned(FDelDrawObjectTimer) then
      begin
        FDelDrawObjectTimer := TTimer.Create( Self );
        FDelDrawObjectTimer.OnTimer := DoTimerToDeleteDrawObject;
        FDelDrawObjectTimer.Interval := 1000;
        FDelDrawObjectTimer.Enabled := True;
      end
      else
      begin
        FDelDrawObjectTimer.Enabled := False;
        FDelDrawObjectTimer.Enabled := True;
      end;
    end;
  end
  else
    inherited;  
end;

procedure TxdForm.WndProc(var msg: TMessage);
var
  R: TRect;
begin
  inherited;  
  case msg.Msg of
    WM_MOVING: 
    begin
      if Assigned(_TieFormManage) then      
        DoHandleWM_Moving( PRect(msg.LParam) );
    end;
    WM_MOVE:       
    begin                             
      if Assigned(_TieFormManage) then
      begin
        GetWindowRect( Handle, R );
        DoMoveSubWndPos( FWinRect, R );
        FWinRect := R;
      end;
    end;
  end;
end;

end.
