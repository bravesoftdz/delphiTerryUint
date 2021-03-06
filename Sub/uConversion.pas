unit uConversion;

interface
uses SysUtils, Windows;

//将一个整形的第ABit位置1
procedure MakeBit1(var AValue: Integer; ABit: Byte);
//将一个整形的第ABit位置0
procedure MakeBit0(var AValue: Integer; ABit: Byte);
//获取一个整形的第ABit位的值
function GetBit(const AValue: Integer; ABit: Byte): Boolean;
procedure SetBit(var AValue: Integer; ABit: Byte; BitValue: Boolean);

function ConverByte(const AByteCount: Int64): string;
function ConverSpeek(const AByteCount: Cardinal): string;
function FormatSpeek(const AByteCount: Int64; const AMilliSecondTime: Cardinal): string; overload;
function FormatSpeek(const B_MS: Integer): string; overload;

function IsNumber(const AChar: char): Boolean; overload; //是否是数字
function IsNumber(const AByte: Byte): Boolean; overload;
function IsNumber(const AText: string): Boolean; overload;
function IsLowerLetter(const AChar: char): Boolean; overload; //是否为小字字母
function IsLowerLetter(const AByte: Byte): Boolean; overload;
function IsUpperLetter(const AChar: char): Boolean; overload; //是否为大字字母
function IsUpperLetter(const AByte: Byte): Boolean; overload;
function IsLetter(const AChar: char): Boolean; overload; //是否为字母
function IsLetter(const AByte: Byte): Boolean; overload;
function IsLetter(const AStrText: string): Boolean; overload;
function IsVisibleChar(const AChar: Char): Boolean; overload;    //是否为可见字符
function IsVisibleChar(const AChar: Byte): Boolean; overload;
function IsVisibleChar(const AText: string): Boolean; overload;

//时间戳
function GetTimeStamp: Cardinal;
function SystemTimeToTimeStamp(const ASystemTime: TSystemTime): Cardinal;
function TimeStampToStr(ATimeStamp: Cardinal): string;
function MSecToTime(mSec: Cardinal): string;

//字符串转换
function AnsiToUTF8Encode(const AString: string): string;
function UTF8ToAnsiDecode(const AString: string): string;

function GBCht2Chs(GBStr: string): AnsiString;
function GBChs2Cht(GBStr: string): AnsiString;

implementation

function GBCht2Chs(GBStr: string): AnsiString;
{进行GBK繁体转简体}
//var
//  Len: integer;
//  pGBCHTChar: PWideChar;
//  pGBCHSChar: PWideChar;
begin
//  pGBCHTChar := PWideChar(GBStr);
//  Len := MultiByteToWideChar(936, 0, PAnsiChar(GBStr), -1, nil, 0);
//  GetMem(pGBCHSChar, Len * 2 + 1);
//  try
//    ZeroMemory(pGBCHSChar, Len * 2 + 1);
//    //GB CHS -> GB CHT
//    LCMapString($804, LCMAP_SIMPLIFIED_CHINESE, pGBCHTChar, -1, pGBCHSChar, Len * 2);
//    result := string(pGBCHSChar);
//    //FreeMem(pGBCHTChar);
//  finally
//    FreeMem(pGBCHSChar);
//  end;
  Result := '';
end;

function GBChs2Cht(GBStr: string): AnsiString;
{进行GBK简体转繁体}
//var
//  Len: integer;
//  pGBCHTChar: PChar;
//  pGBCHSChar: PChar;
begin
//  pGBCHSChar := PChar(GBStr);
//  Len := MultiByteToWideChar(936, 0, pGBCHSChar, -1, nil, 0);
//  GetMem(pGBCHTChar, Len * 2 + 1);
//  try
//    ZeroMemory(pGBCHTChar, Len * 2 + 1);
//    //GB CHS -> GB CHT
//    LCMapString($804, LCMAP_TRADITIONAL_CHINESE, pGBCHSChar, -1, pGBCHTChar, Len * 2);
//    result := string(pGBCHTChar);
//  finally
//    FreeMem(pGBCHTChar);
//  end;
  Result := '';
end;

function AnsiToUTF8Encode(const AString: string): string;
var
  strU: UTF8String;
  i, nLen: Integer;
begin
  strU := UTF8Encode( wideString(AString) );
  nLen := Length( strU );
  Result := '';
  for i := 1 to nLen do
  begin
    if strU[i] >= #128 then
      Result := Result + '%' + IntToHex( ord(strU[i]), 2 )
    else
      Result := Result + Char(strU[i]);
  end;
end;

function UTF8ToAnsiDecode(const AString: string): string;
var
  i, nLen: Integer;
  s, sTemp: string;
  strU: UTF8String;
begin
  i := 1;
  nLen := Length( AString );
  SetLength( strU, 3 );
  while i <= nLen do
  begin       
    if AString[i] = '%' then
    begin
      s := Copy( AString, i, 9 );
      Inc( i, 9 );
      strU[1] := AnsiChar(StrToInt( '$' + Copy( s, 2, 2 ) ));
      strU[2] := AnsiChar(StrToInt( '$' + Copy( s, 5, 2 ) ));
      strU[3] := AnsiChar(StrToInt( '$' + Copy( s, 8, 2 ) ));
      sTemp := Utf8ToAnsi( strU );
      Result := Result + sTemp;
    end
    else
    begin
      Result := Result + AString[i];
      Inc( i );
    end;
  end;
end;

function ConverByte(const AByteCount: Int64): string;
begin
  if AByteCount <= 0 then
    Result := '0'
  else if AByteCount > 1024 * 1024 * 1024 then
    Result := Format('%0.2f G', [AByteCount / (1024 * 1024 * 1024)])
  else if AByteCount > 1024 * 1024 then
    Result := Format('%0.2f Mb', [AByteCount / (1024 * 1024)])
  else if AByteCount > 1024 then
    Result := Format('%0.2f Kb', [AByteCount / 1024])
  else
    Result := Format('%3d B', [AByteCount]);
end;

function ConverSpeek(const AByteCount: Cardinal): string;
begin
  if AByteCount < 1024 then
    Result := Format('%dB/S', [AByteCount])
  else
    Result := Format('%dK/S', [AByteCount div 1024]);
end;

function FormatSpeek(const AByteCount: Int64; const AMilliSecondTime: Cardinal): string;
const
  CtK  = 1024;
var
  dTime, dSpeed: Double;
begin
  try
    dTime := AMilliSecondTime / 1000;
    dSpeed := (AByteCount div CtK) / dTime;
    if dSpeed >= 1024 then
      Result := Format( '%0.2f MB/S', [dSpeed / 1024] )
    else if dSpeed >= 1.0 then
      Result := Format( '%0.2f KB/S', [dSpeed] )
    else
      Result := Format( '%0.2f B/S', [AByteCount / dTime] );
  except
    Result := '0 B/S';
  end;
end;

function FormatSpeek(const B_MS: Integer): string;
var
  dSpeed: Double;
begin
  try
    if B_MS = 0 then
    begin
      Result := '0 B/S';
      Exit;
    end;
    
    dSpeed := B_MS * 1024 / 1000;
    if dSpeed >= 1024 then
      Result := Format( '%0.2f MB/S', [dSpeed / 1024] )
    else if dSpeed >= 1.0 then
      Result := Format( '%0.2f KB/S', [dSpeed] )
    else
      Result := Format( '%0.2f B/S', [B_MS] );
  except
    Result := '0 B/S';
  end;
end;

function IsCharInArea(const AChar: char; const AMin, AMax: Byte): Boolean; inline; overload;
var
  cByte: Byte;
begin
  cByte := Ord(AChar);
  if (cByte >= AMin) and (cByte <= AMax) then
    Result := True
  else
    Result := False;
end;

function IsCharInArea(const AByte: Byte; const AMin, AMax: Byte): Boolean; inline; overload;
begin
  if (AByte >= AMin) and (AByte <= AMax) then
    Result := True
  else
    Result := False;
end;

function IsNumber(const AChar: char): Boolean;
begin
  Result := IsCharInArea(AChar, $30, $39);
end;

function IsNumber(const AByte: Byte): Boolean;
begin
  Result := IsCharInArea(AByte, $30, $39);
end;

function IsNumber(const AText: string): Boolean; overload;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(AText) do
  begin
    if not IsNumber(AText[i]) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsLowerLetter(const AChar: char): Boolean;
begin
  Result := IsCharInArea(AChar, $61, $7A);
end;

function IsLowerLetter(const AByte: Byte): Boolean; overload;
begin
  Result := IsCharInArea(AByte, $61, $7A);
end;

function IsUpperLetter(const AChar: char): Boolean;
begin
  Result := IsCharInArea(AChar, $41, $5A);
end;

function IsUpperLetter(const AByte: Byte): Boolean; overload;
begin
  Result := IsCharInArea(AByte, $41, $5A);
end;

function IsLetter(const AChar: char): Boolean; overload;
begin
  Result := IsLowerLetter(AChar) or IsUpperLetter(AChar);
end;

function IsLetter(const AStrText: string): Boolean; overload;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(AStrText) do
  begin
    if not IsLetter(AStrText[i]) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsLetter(const AByte: Byte): Boolean; overload;
begin
  Result := IsLowerLetter(AByte) or IsUpperLetter(AByte);
end;

function IsVisibleChar(const AChar: Byte): Boolean; overload;
begin
  Result := AChar in [33..126];
end;

function IsVisibleChar(const AText: string): Boolean; overload;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(AText) do
  begin
    if not IsVisibleChar(AText[i]) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsVisibleChar(const AChar: Char): Boolean;
begin
  Result := IsVisibleChar(AChar);
end;

function GetTimeStamp: Cardinal;
var
  I: Integer;
  SystemTime: TSystemTime;
  DayTable: PDayTable;
begin
  GetLocalTime(SystemTime);
  for I := 2000 to SystemTime.wYear - 1 do
    if IsLeapYear(I) then
      Inc(SystemTime.wDay, 366)
    else
      Inc(SystemTime.wDay, 365);
  DayTable := @MonthDays[IsLeapYear(SystemTime.wYear)];
  for I := 1 to SystemTime.wMonth - 1 do
    Inc(SystemTime.wDay, DayTable^[I]);
  Result := (SystemTime.wDay - 1) * 24 * 3600 + SystemTime.wHour * 3600 +
    SystemTime.wMinute * 60 + SystemTime.wSecond;
end;

function SystemTimeToTimeStamp(const ASystemTime: TSystemTime): Cardinal;
var
  I: Integer;
  DayTable: PDayTable;
  wDay: Cardinal;
begin
  wDay := ASystemTime.wDay;
  for I := 2000 to ASystemTime.wYear - 1 do
    if IsLeapYear(I) then
      Inc(wDay, 366)
    else
      Inc(wDay, 365);
  DayTable := @MonthDays[IsLeapYear(ASystemTime.wYear)];
  for I := 1 to ASystemTime.wMonth - 1 do
    Inc(wDay, DayTable^[I]);
  Result := (wDay - 1) * 24 * 3600 + ASystemTime.wHour * 3600 +
    ASystemTime.wMinute * 60 + ASystemTime.wSecond;  
end;

procedure DivMod(Dividend, Divisor: Integer; var Result, Remainder: Integer);
begin
  Result := Dividend div Divisor;
  Remainder := Dividend mod Divisor;
end;

function TimeStampToStr(ATimeStamp: Cardinal): string;
var
  wYear, wMonth, wDay, wHour, wMinute, wSecond: Integer;
  DayTable: PDayTable;
  K: Integer;
begin
  DivMod(ATimeStamp, 3600 * 24, wDay, Integer(ATimeStamp));
  DivMod(ATimeStamp, 3600, wHour, Integer(ATimeStamp));
  DivMod(ATimeStamp, 60, wMinute, wSecond);
  wYear := 2000;
  while True do
  begin
    if IsLeapYear(wYear) then
      K := 366
    else
      K := 365;
    if wDay >= K then
    begin
      Dec(wDay, K);
      Inc(wYear);
    end
    else
      Break;
  end;
  DayTable := @MonthDays[IsLeapYear(wYear)];
  for wMonth := 1 to 12 do
  begin
    if wDay >= DayTable^[wMonth] then
      Dec(wDay, DayTable^[wMonth])
    else
      Break;
  end;
  Inc(wDay);
  Result := Format('%0.4d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d',
    [wYear, wMonth, wDay, wHour, wMinute, wSecond]);
end;

function MSecToTime(mSec: Cardinal): string;
const
  CtSecond = 1000;
  CtMinute = 60 * CtSecond;
  CtHour = 60 * CtMinute;
  CtDay = 24 * CtHour;
var
  day, hour, min, second: Cardinal;
begin
  day := mSec div CtDay;
  mSec := mSec - CtDay * day;

  hour := mSec div CtHour;
  mSec := mSec - CtHour * hour;

  min := mSec div CtMinute;
  mSec := mSec - CtMinute * min;

  second := mSec div CtSecond;

  if day > 0 then
    Result := Format( '%d天 %0.2d:%0.2d:%0.2d', [day, hour, min, second] )
  else if hour > 0 then
    Result := Format( '%0.2d:%0.2d:%0.2d', [hour, min, second] )
  else
    Result := Format( '%0.2d:%0.2d', [min, second] );
end;


procedure MakeBit1(var AValue: Integer; ABit: Byte);
begin
  AValue := AValue or (1 shl ABit);
end;

procedure MakeBit0(var AValue: Integer; ABit: Byte);
begin
  AValue := AValue and (not (1 shl ABit));
end;

function GetBit(const AValue: Integer; ABit: Byte): Boolean;
begin
  Result := (AValue and (1 shl ABit)) <> 0;
end;

procedure SetBit(var AValue: Integer; ABit: Byte; BitValue: Boolean);
begin
  if BitValue then
    MakeBit1(AValue, ABit)
  else
    MakeBit0(AValue, ABit);
end;


end.
