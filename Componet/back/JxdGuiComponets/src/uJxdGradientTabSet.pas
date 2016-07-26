{
����ɫTabSet
����: Terry(������)
QQ:   67068633
Email:jxd524@163.com
2010-5-8 ����11�㴴��  2010-06-03 �ع��뷨
����޸�ʱ�� 2010-06-06
}
unit uJxdGradientTabSet;

interface
uses
  uJxdGradientPanel, Classes, Windows, Controls, Graphics, Messages, ExtCtrls, uBitmapHandle, uJxdCustomButton,
  SysUtils;

type
  //ÿ��ҳ����Ϣ
  PTabSetInfo = ^TTabSetInfo;
  TTabSetInfo = record
    FTitle: string;
    FData: Pointer;
    FPos: TRect;
  end;
  //����ƶ�����Ϣ
  PMousePosInfo = ^TMousePosInfo;
  TMousePosInfo = record
    FIndex: Integer;
    FMouseState: TJxdControlState;
    FIsInCloseRect: Boolean;
  end;
  //�ƶ�ҳʱ����Ҫ��Ϣ
  PMoveTabSetInfo = ^TMoveTabSetInfo;
  TMoveTabSetInfo = record
    FMoveIndex: Integer;
    FMoveToLeft: Boolean;
  end;

  TOnTabSet = function(Sender: TObject; const AIndex: Integer): Boolean of object;
  TOnCurSelectIndexChanged = procedure(Sender: TObject; const ACurSelIndex, ABeforSelIndex: Integer) of object;
  TOnDrawIcon = procedure(Sender: TObject; ABmp: TBitmap; const AIconRect: TRect) of object;

  TJxdGradientTabSet = class( TJxdGradientPanel )
  public
    //��Ҫ��������
    function  AddTabSet(const ATitle: string; AData: Pointer = nil): Integer;
    function  UpdateTabSetData(const AIndex: Integer; AData: Pointer): Boolean;
    function  UpdateTabSetText(const AIndex: Integer; const ATitle: string): Boolean;
    function  GetTabSetData(const AIndex: Integer): Pointer;
    function  CanMoveTabSet(const AMoveToLeft: Boolean): Boolean;
    procedure MoveTabSet(const AMoveToLeft: Boolean);
    procedure Delete(const AIndex: Integer);

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  protected
    //��Ϣ����
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDown;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    //��Ҫ�滭����
    procedure DrawPanel(ABufBitmap: TBitmap); override;
    procedure DrawTabSet(const ATabSetIndex: Integer; p: PTabSetInfo; ABmp: TBitmap); virtual;
    //����ʱ����
    procedure Loaded; override;
  private
    //�Զ������
    FTabSetList: TList;             //���ҳ����
    FMouseMoveInfo: TMousePosInfo;  //��ǰ����ƶ�λ����Ϣ
    FTabSetHeight: Integer;   //ҳ��
    FCurTabSetWidth: Integer; //��ǰҳ��

    FTabSetCloseBmpWidth, FTabSetCloseBmpHeight: Integer;
    FCurTabSetCloseRIndex: Integer;

    //�Զ��庯��
    function  CalcPos(pt: TPoint; var ATabSetIndex: Integer; var AIsInCloseRect: Boolean): Boolean;
    function  CheckAllTabSetWidth: Boolean;
    procedure ReCalcCurTabSetWidth;
    procedure InvalidateTabSet(const AIndex: Integer; const AIsOnlyRedrawCloseRect: Boolean);
    procedure MoveToIndex(const AIndex: Integer; const AMoveToLeft: Boolean); overload;
    procedure MoveToIndex(const AIndex: Integer); overload;
    function  GetMoveTabSetIndex(const AMoveToLeft: Boolean): Integer;
    function  IsTabSetVisible(const ATabSetIndex: Integer): Boolean;
    function  FormatTitle(const ATitle: WideString): string;
    function  TabSetRectToCloseRect(const ARect: TRect): TRect;
    function  IconRect(const ATabSetRect: TRect): TRect;

    procedure DoMoveTabSetEvent(Sender: TObject);
    procedure DoMoveTabSetByDeleteEvent(Sender: TObject);

    function  DoDeleteTabSet(const AIndex: Integer): Boolean;
    procedure DoTabSetChanged(const ABeforSelIndex: Integer);
    procedure DoShowTabSetHint;
    procedure DoDrawIcon(ABmp: TBitmap; const ABmpRect: TRect);
  private
    //�Զ����ɱ���
    FCurSelIndex: Integer;
    FLeftSpace: Integer;
    FRightSpace: Integer;
    FTabSetSpace: Integer;
    FMoveSpeed: Integer;
    FTabSetBitmap: TBitmap;
    FTabSetCloseBitmap: TBitmap;
    FTabSetCloseTopSpace: Integer;
    FTabSetCloseRightSpace: Integer;
    FFontMargins: TRect;
    FOnTabSetChanged: TOnCurSelectIndexChanged;
    FOnDeleteTabSet: TOnTabSet;
    FOnHintTabSet: TOnTabSet;
    FOnTabSetDrawIcon: TOnDrawIcon;
    FIconHeight: Integer;
    FIconWidth: Integer;
    FIconLeftSpace: Integer;
    FIconDraw: Boolean;
    FIconTopSpace: Integer;
    //�Զ����ɺ���
    function  GetTabSetCount: Integer;
    procedure SetLeftSpace(const Value: Integer);
    procedure SetMoveSpeed(const Value: Integer);
    procedure SetTabSetBmp(const Value: TBitmap);
    procedure SetFontMargins(const Value: TRect);
    procedure SetRightSpace(const Value: Integer);
    procedure SetTabSetCloseBitmap(const Value: TBitmap);
    procedure SetCurSelTabSetIndex(const Value: Integer);
    procedure SetTabSetCloseTopSpace(const Value: Integer);
    procedure SetTabSetCloseRightSpace(const Value: Integer);
    procedure SetOnTabSetChanged(const Value: TOnCurSelectIndexChanged);
    procedure SetTabSetSpace(const Value: Integer);
    procedure SetIconHeight(const Value: Integer);
    procedure SetIconWidth(const Value: Integer);
    procedure SetIconLeftSpace(const Value: Integer);
    procedure SetIconDraw(const Value: Boolean);
    procedure SetIconTopSpace(const Value: Integer);
  published
    property CurSelTabSetIndex: Integer read FCurSelIndex write SetCurSelTabSetIndex;
    property LeftSpace: Integer read FLeftSpace write SetLeftSpace;
    property RightSpace: Integer read FRightSpace write SetRightSpace;
    property MoveSpeed: Integer read FMoveSpeed write SetMoveSpeed;
    property TabSetSpace: Integer read FTabSetSpace write SetTabSetSpace;
    property TabSetBitmap: TBitmap read FTabSetBitmap write SetTabSetBmp;
    property TabSetCloseBitmap: TBitmap read FTabSetCloseBitmap write SetTabSetCloseBitmap;
    property TabSetCloseTopSpace: Integer read FTabSetCloseTopSpace write SetTabSetCloseTopSpace;
    property TabSetCloseRightSpace: Integer read FTabSetCloseRightSpace write SetTabSetCloseRightSpace;
    property CurTabSetCount: Integer read GetTabSetCount;
    property FontMargins: TRect read FFontMargins write SetFontMargins;
    property IconDraw: Boolean read FIconDraw write SetIconDraw;
    property IconWidth: Integer read FIconWidth write SetIconWidth;
    property IconHeight: Integer read FIconHeight write SetIconHeight;
    property IconLeftSpace: Integer read FIconLeftSpace write SetIconLeftSpace;
    property IconTopSpace: Integer read FIconTopSpace write SetIconTopSpace;
    //�¼�
    property OnTabSetChanged: TOnCurSelectIndexChanged read FOnTabSetChanged write SetOnTabSetChanged;
    property OnTabSetDelete: TOnTabSet read FOnDeleteTabSet write FOnDeleteTabSet;
    property OnTabSetShowHint: TOnTabSet read FOnHintTabSet write FOnHintTabSet;
    property OnTabSetDrawIcon: TOnDrawIcon read FOnTabSetDrawIcon write FOnTabSetDrawIcon; 
  end;

implementation

const
  CtMaxTabSetWidth = 250;
  CtMinTabSetWidth = 100;

{ TJxdGradientTabSet }

function TJxdGradientTabSet.AddTabSet(const ATitle: string; AData: Pointer): Integer;
var
  p, pPre: PTabSetInfo;
begin
  New( p );
  p^.FTitle := ATitle;
  p^.FData := AData;
  if FTabSetList.Count > 0 then
  begin
    pPre := FTabSetList[FTabSetList.Count - 1];
    with p^.FPos do
    begin
      Left := pPre^.FPos.Right + FTabSetSpace;
      Right := Left + FCurTabSetWidth;
      Top := pPre^.FPos.Top;
      Bottom := pPre^.FPos.Bottom;
    end;
  end
  else
  begin
    with p^.FPos do
    begin
      Left := 0;
      Right := Left + FCurTabSetWidth;
      Top := Self.Height - FTabSetHeight;
      Bottom := Top + FTabSetHeight;
    end;
  end;
  Result := FTabSetList.Add( p );
  CheckAllTabSetWidth;
  if FCurSelIndex = -1 then
  begin
    FCurSelIndex := Result;
    DoTabSetChanged( -1 );
  end;
  Invalidate;
end;

function TJxdGradientTabSet.CalcPos(pt: TPoint; var ATabSetIndex: Integer; var AIsInCloseRect: Boolean): Boolean;
var
  p: PTabSetInfo;
  R: TRect;
  nCount: Integer;
begin
  Result := False;
  nCount := FTabSetList.Count;
  if (nCount > 0) and     //�ж�List
     (pt.Y <= Height) and (pt.Y >= Height - FTabSetHeight) and //�ж�����λ��
     (pt.X <= Width - FRightSpace) and (pt.X >= FLeftSpace) then //�ж�����λ��
  begin
    p := FTabSetList[ 0 ];
    pt.X := pt.X - FLeftSpace;
    ATabSetIndex := ( pt.X + abs(p^.FPos.Left) ) div ( FCurTabSetWidth + FTabSetSpace );
    if (ATabSetIndex >= 0) and (ATabSetIndex < nCount) then
    begin
      p := FTabSetList[ ATabSetIndex ];
      if not PtInRect(p^.FPos, pt) then Exit;
      R := TabSetRectToCloseRect( p^.FPos );
      AIsInCloseRect := PtInRect( R, pt );
      Result := True;
    end;
  end;
end;

function TJxdGradientTabSet.CanMoveTabSet(const AMoveToLeft: Boolean): Boolean;
var
  p: PTabSetInfo;
begin
  Result := False;
  if FTabSetList.Count <= 1 then Exit;

  if AMoveToLeft then
  begin
    p := FTabSetList[ FTabSetList.Count - 1 ];
    Result := p^.FPos.Right > Width - FRightSpace;
  end
  else
  begin
    p := FTabSetList[ 0 ];
    Result := p^.FPos.Left < 0;
  end;
end;

function TJxdGradientTabSet.CheckAllTabSetWidth: Boolean;
var
  i: Integer;
  p, pPre: PTabSetInfo;
begin
  Result := False;
  if FTabSetList.Count = 0 then Exit;
  ReCalcCurTabSetWidth;

  pPre := FTabSetList[0];
  pPre^.FPos.Right := pPre^.FPos.Left + FCurTabSetWidth;
  for i := 1 to FTabSetList.Count - 1 do
  begin
    p := FTabSetList[i];
    p^.FPos.Left := pPre^.FPos.Right + FTabSetSpace;
    p^.FPos.Right := p^.FPos.Left + FCurTabSetWidth;
    pPre := p;
  end;
end;

procedure TJxdGradientTabSet.CMHintShow(var Message: TMessage);
begin
  if FMouseMoveInfo.FIndex <> -1 then
    DoShowTabSetHint;
end;

procedure TJxdGradientTabSet.CMMouseEnter(var Message: TMessage);
begin
  inherited;
end;

procedure TJxdGradientTabSet.CMMouseLeave(var Message: TMessage);
var
  nIndex: Integer;
begin
  inherited;
  if FMouseMoveInfo.FIndex <> -1 then
  begin
    nIndex := FMouseMoveInfo.FIndex;
    FMouseMoveInfo.FIndex := -1;
    InvalidateTabSet( nIndex, False );
  end;
end;

constructor TJxdGradientTabSet.Create(AOwner: TComponent);
begin
  inherited;
  DoubleBuffered         := True;
  Caption                := '';
  FTabSetList            := TList.Create;
  FLeftSpace             := 20;
  FRightSpace            := 40;
  FTabSetSpace           := 4;
  FTabSetHeight          := 29;
  FMoveSpeed             := 20;
  FCurTabSetWidth        := CtMaxTabSetWidth;
  FCurSelIndex           := -1;
  FTabSetBitmap          := TBitmap.Create;
  FFontMargins.Left      := 5;
  FFontMargins.Right     := 5;
  FFontMargins.Top       := 5;
  FFontMargins.Bottom    := 0;
  FTabSetCloseBitmap     := TBitmap.Create;
  FTabSetCloseBmpWidth   := 0;
  FTabSetCloseBmpHeight  := 0;
  FTabSetCloseTopSpace   := 4;
  FTabSetCloseRightSpace := 4;
  FCurTabSetCloseRIndex  := -1;
  FIconHeight            := 16;
  FIconWidth             := 16;
  FIconLeftSpace         := 3;
  FIconTopSpace          := -1;
  FIconDraw              := True;
  FMouseMoveInfo.FIndex := -1;
  ShowHint := True;
end;

procedure TJxdGradientTabSet.Delete(const AIndex: Integer);
  //���¼���TabSet����ҳ��λ�ã�ABeginIndexָ����ҳ��Left������Ҫ���ⲿ��������
  procedure ReCalcTabSet(const ABeginIndex, AEndIndex: Integer);
  var
    i: Integer;
    pre, p: PTabSetInfo;
  begin
    pre := FTabSetList[ ABeginIndex ];
    pre^.FPos.Right := pre^.FPos.Left + FCurTabSetWidth;
    for i := ABeginIndex + 1 to AEndIndex do
    begin
      p := FTabSetList[i];
      p^.FPos.Left := pre^.FPos.Right + FTabSetSpace;
      p^.FPos.Right := p^.FPos.Left + FCurTabSetWidth;
      pre := p;
    end;
  end;
var
  p, pTemp: PTabSetInfo;
  nCount, nOldWidth: Integer;
  R: TRect;
begin
  if (AIndex < 0) or (AIndex >= FTabSetList.Count) or (not DoDeleteTabSet(AIndex)) then Exit;

  p := FTabSetList[ AIndex ];
  nCount := FTabSetList.Count;
  FTabSetList.Delete( AIndex );
  Dispose( p );
  nOldWidth := FCurTabSetWidth;
  ReCalcCurTabSetWidth;

  if FTabSetList.Count = 0 then
  begin
    nCount := CurSelTabSetIndex;
    FCurSelIndex := -1;
    DoTabSetChanged( nCount );
    Invalidate;
    Exit;
  end;


  //ɾ��ѡ��ҳ
  if AIndex = FCurSelIndex then
  begin
    CurSelTabSetIndex := AIndex mod FTabSetList.Count;
    DoTabSetChanged( -1 );
  end
  else if AIndex < FCurSelIndex then
    Dec( FCurSelIndex ); 
  
  if AIndex = 0 then
  begin
    //ɾ����һ��
    ReCalcTabSet( 0, FTabSetList.Count - 1 );
    MoveToIndex( 0 );
  end
  else if AIndex = nCount - 1 then
  begin
    //ɾ�����һ��
    ReCalcTabSet( 0, FTabSetList.Count - 1 );
    Invalidate;
  end
  else
  begin
    //ɾ���м�ĳһҳ
    ReCalcTabSet( 0, AIndex - 1 );
    p := FTabSetList[ AIndex - 1 ];
    R.Left := FLeftSpace;
    R.Top := p^.FPos.Top;
    R.Bottom := p^.FPos.Bottom;
    R.Right := p^.FPos.Right + FLeftSpace;
    InvalidateRect( Handle, @R, False );

    pTemp := FTabSetList[ AIndex ];
    pTemp^.FPos.Left := p^.FPos.Right + FTabSetSpace + nOldWidth;
    ReCalcTabSet( AIndex, FTabSetList.Count - 1 );
    MoveToIndex( AIndex );
  end;
end;

destructor TJxdGradientTabSet.Destroy;
var
  i: Integer;
begin
  for i := 0 to FTabSetList.Count - 1 do
    Dispose( PTabSetInfo(FTabSetList[i]) );
  FTabSetList.Free;
  FTabSetBitmap.Free;
  FTabSetCloseBitmap.Free;
  inherited;
end;

function TJxdGradientTabSet.DoDeleteTabSet(const AIndex: Integer): Boolean;
begin
  Result := True;
  if Assigned(OnTabSetDelete) then
    Result := OnTabSetDelete( Self, AIndex ); 
end;

procedure TJxdGradientTabSet.DoDrawIcon(ABmp: TBitmap; const ABmpRect: TRect);
begin
  if Assigned(OnTabSetDrawIcon) then
    OnTabSetDrawIcon( Self, ABmp, IconRect(ABmpRect) );
end;

procedure TJxdGradientTabSet.DoMoveTabSetByDeleteEvent(Sender: TObject);
var
  tmr: TTimer;
  i, nValue, nMoveIndex, nMoveLeftMost: Integer;
  bFinished: Boolean;
  pTabSet: PTabSetInfo;
  R: TRect;
begin
  if not (Sender is TTimer) then Exit;
  tmr := Sender as TTimer;
  tmr.Enabled := False;
  nMoveIndex := tmr.Tag;
  if ( nMoveIndex < 0) or (nMoveIndex > FTabSetList.Count) then
  begin
    tmr.Free;
    Exit;
  end;
  if nMoveIndex = 0 then
    nMoveLeftMost := 0
  else
  begin
    pTabSet := FTabSetList[ nMoveIndex - 1 ];
    nMoveLeftMost := pTabSet^.FPos.Right + FTabSetSpace;
  end;
  bFinished := False;
  R.Left := nMoveLeftMost;
  try
    pTabSet := FTabSetList[ nMoveIndex ];
    R.Top := pTabSet^.FPos.Top;
    R.Bottom := pTabSet^.FPos.Bottom;
    if pTabSet^.FPos.Left - FMoveSpeed > nMoveLeftMost then
      nValue := FMoveSpeed
    else
    begin
      nValue := pTabSet^.FPos.Left - nMoveLeftMost;
      bFinished := True;
    end;
    nValue := -nValue;
    for i := nMoveIndex to FTabSetList.Count - 1 do
    begin
      pTabSet := FTabSetList[i];
      Inc( pTabSet^.FPos.Left, nValue );
      Inc( pTabSet^.FPos.Right, nValue );
    end;
    R.Right := Width - FRightSpace;
    InvalidateRect( Handle, @R, False );
  finally
    if bFinished then
      tmr.Free
    else
      tmr.Enabled := True;
  end;
end;

procedure TJxdGradientTabSet.DoMoveTabSetEvent(Sender: TObject);
var
  tmr: TTimer;
  i, nValue: Integer;
  pTabSet: PTabSetInfo;
  pMove: PMoveTabSetInfo;
  bFinished: Boolean;
begin
  if not (Sender is TTimer) then Exit;
  tmr := Sender as TTimer;
  tmr.Enabled := False;
  pMove := PMoveTabSetInfo( tmr.Tag );
  if (not Assigned(pMove)) or ( pMove^.FMoveIndex < 0) or (pMove^.FMoveIndex > FTabSetList.Count) then
  begin
    tmr.Free;
    Exit;
  end;
  bFinished := False;
  try
    pTabSet := FTabSetList[ pMove^.FMoveIndex ];
    if pMove^.FMoveToLeft then
    begin
      if pTabSet^.FPos.Right + FLeftSpace - FMoveSpeed > Width - FRightSpace then
        nValue := FMoveSpeed
      else
      begin
        nValue := pTabSet^.FPos.Right + FLeftSpace - Width + FRightSpace;
        bFinished := True;
      end;
      nValue := -nValue;
    end
    else
    begin
      if pTabSet^.FPos.Left + FMoveSpeed < 0 then
        nValue := FMoveSpeed
      else
      begin
        nValue := - pTabSet^.FPos.Left;
        bFinished := True;
      end;
    end;

    for i := 0 to FTabSetList.Count - 1 do
    begin
      pTabSet := FTabSetList[i];
      Inc( pTabSet^.FPos.Left, nValue );
      Inc( pTabSet^.FPos.Right, nValue );
    end;
    Invalidate;
  finally
    if bFinished then
    begin
      tmr.Free;
      Dispose( pMove );
    end
    else
      tmr.Enabled := True;
  end;
end;

procedure TJxdGradientTabSet.DoShowTabSetHint;
begin
  if Assigned(OnTabSetShowHint) then
    OnTabSetShowHint( Self, FMouseMoveInfo.FIndex );
end;

procedure TJxdGradientTabSet.DoTabSetChanged(const ABeforSelIndex: Integer);
begin
  if Assigned(FOnTabSetChanged) then
    FOnTabSetChanged( Self, CurSelTabSetIndex, ABeforSelIndex );
end;

procedure TJxdGradientTabSet.DrawPanel(ABufBitmap: TBitmap);
var
  i: Integer;
  p: PTabSetInfo;
  nRight: Integer;
  Bmp: TBitmap;
  xDest, xSrc, nW: Integer;
begin
  inherited;
  if FTabSetList.Count = 0 then Exit;
  nRight := Width - FRightSpace;
  Bmp := TBitmap.Create;
  try
    Bmp.Width := FCurTabSetWidth;
    Bmp.Height := FTabSetHeight;
    for i := 0 to FTabSetList.Count - 1 do
    begin
      if not IsTabSetVisible( i ) then Continue;
      p := FTabSetList[i];
      DrawTabSet( i, p, Bmp );

      if p^.FPos.Left >= 0 then
      begin
        xDest := p^.FPos.Left + FLeftSpace;
        xSrc := 0;
        nW := FCurTabSetWidth;
      end
      else
      begin
        xDest := FLeftSpace;
        xSrc := abs(p^.FPos.Left);
        nW := FCurTabSetWidth - xSrc;
      end;
      if xDest + nW > nRight then
        nW := nRight - xDest;
      ABufBitmap.Canvas.Brush.Style := bsClear;
      SetBkMode( ABufBitmap.Canvas.Handle, TRANSPARENT );
      ABufBitmap.Canvas.BrushCopy( Rect(xDest, p^.FPos.Top, xDest + nW, p^.FPos.Top + FTabSetHeight ),
                                   Bmp, Rect(xSrc, 0, xSrc + nW, FTabSetHeight ), clFuchsia );
    end;
  finally
    Bmp.Free;
  end;
end;

procedure TJxdGradientTabSet.DrawTabSet(const ATabSetIndex: Integer; p: PTabSetInfo; ABmp: TBitmap);
var
  TabSetSrcBmpRt, TabSetCloseSrcBmpRt, R, CloseDestBmpRt: TRect;
  strTitle: string;
  nSpace: Integer;
begin
  R := Rect( 0, 0, ABmp.Width, ABmp.Height );
  CloseDestBmpRt := R;
  if not FTabSetBitmap.Empty then
  begin
    if ATabSetIndex = FCurSelIndex then
    begin
      //�滭��ǰѡ��ҳ
      TabSetSrcBmpRt := Rect(0, FTabSetHeight * 2, FTabSetBitmap.Width, FTabSetHeight * 3 );
    end
    else if FMouseMoveInfo.FIndex = ATabSetIndex then
    begin
      //����ƶ�����ǰ�滭ҳ
      TabSetSrcBmpRt := Rect(0, FTabSetHeight, FTabSetBitmap.Width, FTabSetHeight * 2 );
    end
    else
    begin
      //ƽʱ״̬
      TabSetSrcBmpRt := Rect(0, 0, FTabSetBitmap.Width, FTabSetHeight );
    end;
    //������
    DrawRectangle( ABmp.Canvas, TabSetSrcBmpRt, R, FTabSetBitmap );
  end
  /////////////////////////////////�ޱ���ͼʱ//////////////////////////////////////////
  else
  if ATabSetIndex = FCurSelIndex then
  begin
    ABmp.Canvas.Brush.Color := $2D4FFF;
    ABmp.Canvas.FillRect( Rect(0, 0, ABmp.Width, Abmp.Height) );
  end
  else
  begin
    ABmp.Canvas.Brush.Color := Random( GetTickCount );
    ABmp.Canvas.FillRect( Rect(0, 0, ABmp.Width, Abmp.Height) );
  end;
  /////////////////////////////�����ޱ���ͼ////////////////////////////////////////////

  //����Сͼ��
  if IconDraw then
  begin
    DoDrawIcon( ABmp, Rect(0, 0, ABmp.Width, ABmp.Height) );
    nSpace := FIconWidth;
  end
  else
    nSpace := 0;

  //��������
  if p^.FTitle <> '' then
  begin
    strTitle := FormatTitle( p^.FTitle );
    Inc( R.Left, FFontMargins.Left + nSpace );
    Inc( R.Top, FFontMargins.Top );
    Dec( R.Right, FFontMargins.Right );
    Dec( R.Right, FTabSetCloseBmpWidth );
    ABmp.Canvas.Font := Font;
    ABmp.Canvas.Brush.Style := bsClear;
    DrawText(ABmp.Canvas.Handle, PChar(strTitle), Length(strTitle), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  end;

  //���ƹرհ�ť
  if not FTabSetCloseBitmap.Empty then
  begin
    //�رհ�ťͼƬλ��
    TabSetCloseSrcBmpRt := Rect(0, 0, FTabSetCloseBmpWidth, FTabSetCloseBmpHeight );
    if (ATabSetIndex = FMouseMoveInfo.FIndex) and FMouseMoveInfo.FIsInCloseRect then
    begin
      case FMouseMoveInfo.FMouseState of
        xcsActive: OffsetRect( TabSetCloseSrcBmpRt, 0, FTabSetCloseBmpHeight );
        xcsDown: OffsetRect( TabSetCloseSrcBmpRt, 0, FTabSetCloseBmpHeight * 2 );
      end;
    end;
    //��͸����ʽ������ť
    CloseDestBmpRt := TabSetRectToCloseRect( CloseDestBmpRt );
    ABmp.Canvas.Brush.Style := bsClear;
    SetBkMode( ABmp.Canvas.Handle, TRANSPARENT );
    ABmp.Canvas.BrushCopy( CloseDestBmpRt, FTabSetCloseBitmap, TabSetCloseSrcBmpRt, clFuchsia );
  end;
end;

function TJxdGradientTabSet.FormatTitle(const ATitle: WideString): string;
var
  nW, nFontLen, n: Integer;
begin
  nW := FCurTabSetWidth - FFontMargins.Left - FFontMargins.Right;
  if IconDraw then
    Dec( nW, FIconWidth );
  if FTabSetCloseBmpWidth > 0 then
    Dec( nW, FTabSetCloseBmpWidth );
    
  nFontLen := Canvas.TextWidth( ATitle );
  if nFontLen <= nW then
    Result := ATitle
  else
  begin
    Result := Copy( ATitle, 1, Length(ATitle) - 4 ) + '...';
    nFontLen := Canvas.TextWidth( Result );
    n := 4;
    while nFontLen > nW do
    begin
      Inc( n, 2 );
      Result := Copy( ATitle, 1, Length(ATitle) - n ) + '...';
      nFontLen := Canvas.TextWidth( Result );
    end;
  end;
end;

function TJxdGradientTabSet.GetMoveTabSetIndex(const AMoveToLeft: Boolean): Integer;
var
  p0, p1, nLen, nIndex: Integer;
  p: PTabSetInfo;
begin
  Result := -1;
  if AMoveToLeft then
  begin
    p := FTabSetList[ FTabSetList.Count - 1 ];
    p0 := Width - FRightSpace;
    p1 := p^.FPos.Right;
  end
  else
  begin
    p := FTabSetList[ 0 ];
    p0 := FLeftSpace;
    p1 := p^.FPos.Right;
  end;
  nLen := abs(p0 - p1);
  nIndex := nLen div (FCurTabSetWidth + FTabSetSpace);
  if AMoveToLeft then
    nIndex := FTabSetList.Count - 1 - nIndex;
  if (nIndex >= 0) and (nIndex <= FTabSetList.Count - 1) then
    Result := nIndex;
end;

function TJxdGradientTabSet.GetTabSetCount: Integer;
begin
  if Assigned(FTabSetList) then
    Result := FTabSetList.Count
  else
    Result := 0;
end;

function TJxdGradientTabSet.GetTabSetData(const AIndex: Integer): Pointer;
begin
  if (AIndex < 0) or (AIndex >= FTabSetList.Count) then
    Result := nil
  else
    Result :=  PTabSetInfo(FTabSetList[AIndex])^.FData;
end;

function TJxdGradientTabSet.IconRect(const ATabSetRect: TRect): TRect;
begin
  if (FIconHeight = 0) or (FIconWidth = 0) then
  begin
    Result := Rect(0, 0, 0, 0);
    Exit;
  end;
  Result.Left := ATabSetRect.Left + FIconLeftSpace;
  Result.Right := Result.Left + FIconWidth;
  if FIconTopSpace = -1 then
    Result.Top := (ATabSetRect.Bottom - ATabSetRect.Top - FIconHeight) div 2
  else
    Result.Top := ATabSetRect.Top + FIconTopSpace ;
  Result.Bottom := Result.Top + FIconHeight;
end;

procedure TJxdGradientTabSet.InvalidateTabSet(const AIndex: Integer; const AIsOnlyRedrawCloseRect: Boolean);
var
  p: PTabSetInfo;
  R: TRect;
begin
  if (AIndex >= 0) and (AIndex < FTabSetList.Count) then
  begin
    p := FTabSetList[ AIndex ];
    R := p^.FPos;
    Inc( R.Left, FLeftSpace );
    Inc( R.Right, FLeftSpace ); 
    if AIsOnlyRedrawCloseRect then
      R := TabSetRectToCloseRect( R );
    InvalidateRect( Handle, @R, False );
  end;
end;

function TJxdGradientTabSet.IsTabSetVisible(const ATabSetIndex: Integer): Boolean;
var
  p: PTabSetInfo;
  nW: Integer;
begin
  nW := Width - FRightSpace;
  p := FTabSetList[ ATabSetIndex ];
  Result := ( (p^.FPos.Left < 0) and (p^.FPos.Right > 0) ) or
            ( (p^.FPos.Left >= 0) and (p^.FPos.Left <= nW) );
end;

procedure TJxdGradientTabSet.Loaded;
begin
  inherited;
  if Assigned(FTabSetBitmap) and (not FTabSetBitmap.Empty) then  
    FTabSetHeight := FTabSetBitmap.Height div 3;
  if Assigned(FTabSetCloseBitmap) and (not FTabSetCloseBitmap.Empty) then
  begin
    FTabSetCloseBmpWidth := FTabSetCloseBitmap.Width;
    FTabSetCloseBmpHeight := FTabSetCloseBitmap.Height div 3;
  end;
  AutoMoveForm := False;
  ShowHint := True;
end;

procedure TJxdGradientTabSet.WMLButtonDown(var Message: TWMLButtonDown);
var
  nIndex: Integer;
  bInCloseBtn: Boolean;
begin
  inherited;
  if FMouseMoveInfo.FIndex <> -1 then
  begin
    if CalcPos( Point(Message.XPos, Message.YPos), nIndex, bInCloseBtn ) then
    begin
      if bInCloseBtn then
      begin
        //�ڹرհ�ť����
        if FMouseMoveInfo.FMouseState <> xcsDown then
        begin
          FMouseMoveInfo.FMouseState := xcsDown;
          FMouseMoveInfo.FIsInCloseRect := True;
          InvalidateTabSet( FMouseMoveInfo.FIndex, True );
        end;
      end
      else
      begin
        //��ҳ��ҳ�������
        if FMouseMoveInfo.FMouseState <> xcsDown then
        begin
          FMouseMoveInfo.FMouseState := xcsDown;
          FMouseMoveInfo.FIsInCloseRect := False;
          InvalidateTabSet( FMouseMoveInfo.FIndex, False );
        end;
      end;
    end;
  end;
end;

procedure TJxdGradientTabSet.WMLButtonUp(var Message: TWMLButtonUp);
var
  nIndex: Integer;
  bInCloseBtn: Boolean;
begin
  inherited;
  if CalcPos( Point(Message.XPos, Message.YPos), nIndex, bInCloseBtn ) then
  begin
    FMouseMoveInfo.FMouseState := xcsActive;
    if not bInCloseBtn then
      CurSelTabSetIndex := nIndex
    else
      Delete( nIndex );
  end;
end;

procedure TJxdGradientTabSet.WMMouseMove(var Message: TWMMouseMove);
var
  nTemp, nIndex: Integer;
  bIsInCloseRt: Boolean;
begin
  inherited;
  if not CalcPos( Point(Message.XPos, Message.YPos), nIndex, bIsInCloseRt ) then
  begin
    if FMouseMoveInfo.FIndex <> -1 then
    begin
      nIndex := FMouseMoveInfo.FIndex;
      FMouseMoveInfo.FIndex := -1;
      InvalidateTabSet( nIndex, False );
    end;
  end
  else
  begin
    if FMouseMoveInfo.FIndex = -1 then
    begin
      FMouseMoveInfo.FIndex := nIndex;
      FMouseMoveInfo.FIsInCloseRect := bIsInCloseRt;
      FMouseMoveInfo.FMouseState := xcsActive;
      InvalidateTabSet( nIndex, False );
    end
    else if (FMouseMoveInfo.FIndex = nIndex) and (FMouseMoveInfo.FIsInCloseRect <> bIsInCloseRt) then
    begin
      FMouseMoveInfo.FIsInCloseRect := bIsInCloseRt;
      InvalidateTabSet( nIndex, True );
    end
    else if FMouseMoveInfo.FIndex <> nIndex then
    begin
      nTemp := FMouseMoveInfo.FIndex;
      FMouseMoveInfo.FIndex := nIndex;
      FMouseMoveInfo.FMouseState := xcsActive;
      FMouseMoveInfo.FIsInCloseRect := bIsInCloseRt;
      nIndex := nTemp;
      InvalidateTabSet( nIndex, False );
      InvalidateTabSet( FMouseMoveInfo.FIndex, False );
    end;
  end;
end;

procedure TJxdGradientTabSet.MoveTabSet(const AMoveToLeft: Boolean);
var
  nMoveIndex: Integer;
begin
  if not CanMoveTabSet(AMoveToLeft) then Exit;
  nMoveIndex := GetMoveTabSetIndex( AMoveToLeft );
  if nMoveIndex = -1 then Exit;
  MoveToIndex( nMoveIndex, AMoveToLeft );
end;

procedure TJxdGradientTabSet.MoveToIndex(const AIndex: Integer);
begin
  with TTimer.Create( Self ) do
  begin
    OnTimer := DoMoveTabSetByDeleteEvent;
    Tag := AIndex;
    Interval := 50;
    Enabled := True;
  end;
end;

procedure TJxdGradientTabSet.MoveToIndex(const AIndex: Integer; const AMoveToLeft: Boolean);
var
  pMoveInfo: PMoveTabSetInfo;
begin
  New( pMoveInfo );
  pMoveInfo^.FMoveIndex := AIndex;
  pMoveInfo^.FMoveToLeft := AMoveToLeft;
  with TTimer.Create( Self ) do
  begin
    OnTimer := DoMoveTabSetEvent;
    Tag := Integer( PMoveInfo );
    Interval := 50;
    Enabled := True;
  end;
end;

procedure TJxdGradientTabSet.ReCalcCurTabSetWidth;
var
  nWidth, nUseWidth: Integer;
begin
  FCurTabSetWidth := CtMaxTabSetWidth;
  if FTabSetList.Count = 0 then Exit;
  nUseWidth := Width - FLeftSpace - FRightSpace;
  if FTabSetList.Count > 1 then
    nUseWidth := nUseWidth - (FTabSetList.Count - 1) * FTabSetSpace;

  nWidth := nUseWidth div FTabSetList.Count;

  if nWidth > CtMaxTabSetWidth then
    FCurTabSetWidth := CtMaxTabSetWidth
  else if nWidth >= CtMinTabSetWidth then
    FCurTabSetWidth := nWidth
  else
    FCurTabSetWidth := CtMinTabSetWidth;
end;

procedure TJxdGradientTabSet.SetCurSelTabSetIndex(const Value: Integer);
var
  p: PTabSetInfo;
  bMoveToLeft: Boolean;
  nTemp: Integer;
begin
  if (Value >= 0) and (Value < FTabSetList.Count) and (FCurSelIndex <> Value) then
  begin
    p := FTabSetList[Value];
    bMoveToLeft := p^.FPos.Right > Width - FRightSpace;
    if (p^.FPos.Left < 0) or bMoveToLeft then
      MoveToIndex( Value, bMoveToLeft);
    nTemp := FCurSelIndex;
    FCurSelIndex := Value;
    DoTabSetChanged( nTemp );
    InvalidateTabSet( nTemp, False );
    InvalidateTabSet( FCurSelIndex, False );
  end;
end;

procedure TJxdGradientTabSet.SetFontMargins(const Value: TRect);
begin
  FFontMargins := Value;
  Invalidate;
end;

procedure TJxdGradientTabSet.SetIconDraw(const Value: Boolean);
begin
  if FIconDraw <> Value then
  begin
    FIconDraw := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetIconHeight(const Value: Integer);
begin
  if (FIconHeight <> Value) and (Value >= 0) then
  begin
    FIconHeight := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetIconLeftSpace(const Value: Integer);
begin
  if (Value <> FIconLeftSpace) and (Value >= 0) then
  begin
    FIconLeftSpace := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetIconTopSpace(const Value: Integer);
begin
  if (Value <> FIconTopSpace) and (Value >= -1) then
  begin
    FIconTopSpace := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetIconWidth(const Value: Integer);
begin
  if (FIconWidth <> Value) and (Value >= 0) then
  begin
    FIconWidth := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetLeftSpace(const Value: Integer);
begin
  if (FLeftSpace <> Value) and (Value >= 0) then
  begin
    FLeftSpace := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetMoveSpeed(const Value: Integer);
begin
  if (FMoveSpeed <> Value) and (Value > 0) then
    FMoveSpeed := Value;
end;

procedure TJxdGradientTabSet.SetOnTabSetChanged(const Value: TOnCurSelectIndexChanged);
begin
  FOnTabSetChanged := Value;
end;

procedure TJxdGradientTabSet.SetRightSpace(const Value: Integer);
begin
  if (FRightSpace <> Value) and (Value >= 0) then
  begin
    FRightSpace := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetTabSetBmp(const Value: TBitmap);
begin
  FTabSetBitmap.Assign( Value );
  Invalidate;
end;

procedure TJxdGradientTabSet.SetTabSetCloseBitmap(const Value: TBitmap);
begin
  FTabSetCloseBitmap.Assign( Value );
  Invalidate;
end;

procedure TJxdGradientTabSet.SetTabSetCloseRightSpace(const Value: Integer);
begin
  if FTabSetCloseRightSpace <> Value then
  begin
    FTabSetCloseRightSpace := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetTabSetCloseTopSpace(const Value: Integer);
begin
  if FTabSetCloseTopSpace <> Value then
  begin
    FTabSetCloseTopSpace := Value;
    Invalidate;
  end;
end;

procedure TJxdGradientTabSet.SetTabSetSpace(const Value: Integer);
begin
  if (FTabSetSpace <> Value) and (Value >= 0) then
  begin
    FTabSetSpace := Value;
    CheckAllTabSetWidth;
    Invalidate;
  end;
end;

function TJxdGradientTabSet.TabSetRectToCloseRect(const ARect: TRect): TRect;
begin
  if (not Assigned(FTabSetCloseBitmap)) or FTabSetCloseBitmap.Empty then
  begin
    Result := Rect(0, 0, 0, 0);
    Exit;
  end;
  Result := ARect;
  Result.Left := Result.Right - FTabSetCloseBmpWidth - FTabSetCloseRightSpace;
  Result.Top := Result.Top + FTabSetCloseTopSpace;
  Result.Right := Result.Left + FTabSetCloseBmpWidth;
  Result.Bottom := Result.Top + FTabSetCloseBmpHeight;
end;

function TJxdGradientTabSet.UpdateTabSetData(const AIndex: Integer; AData: Pointer): Boolean;
begin
  if (AIndex < 0) or (AIndex >= FTabSetList.Count) then
    Result := False
  else
  begin
    PTabSetInfo(FTabSetList[AIndex])^.FData := AData;
    Result := True;
  end;
end;

function TJxdGradientTabSet.UpdateTabSetText(const AIndex: Integer; const ATitle: string): Boolean;
begin
  if (AIndex < 0) or (AIndex >= FTabSetList.Count) then
    Result := False
  else
  begin
    PTabSetInfo(FTabSetList[AIndex])^.FTitle := ATitle;
    InvalidateRect( Handle, @PTabSetInfo(FTabSetList[AIndex])^.FPos, True );
    Result := True;
  end;
end;

procedure TJxdGradientTabSet.WMSize(var Message: TWMSize);
begin
  inherited;
  CheckAllTabSetWidth;
end;

end.