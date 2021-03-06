{
单元名称: uJxdDataStream
单元作者: 江晓德(Terry)
邮    箱: jxd524@163.com
说    明: 基本通信能力, 使用事件模式
开始时间: 2010-09-21
修改时间: 2011-03-08 (最后修改)

类：TxdStreamBasic

TxdStreamBasic：
  定义基于流的相关操作，子类实现（*必须实现，-可实现）
    ReadStream     *
    WriteStream    *
    Position，Size *
    ReadLong       -
    WriteLong      -
    CheckReadSize  -
    CheckWriteSize -

数据流类结构：

                                          TxdMemoryStream
                                          TxdFileStream
                     / TxdStreamHandle
                    |
    TxdStreamBasic <                       TxdOuterMemory
                    |                      TxdDynamicMemory
                     \ TxdMemoryHandle     TxdStaticMemory_1K
                                           TxdStaticMemory_2K
                                           TxdStaticMemory_4K
                                           TxdStaticMemory_8K
                                           TxdMemoryFile

TxdMemoryStream:    内存流，使用TMemoryStream
TxdFileStream:      文件流, 使用TFileStream
TxdOuterMemory:     外部数据流，使用外部提供的数据来进行读写
TxdDynamicMemory:   动态流，使用类自身动态申请的数据进行读写
TxdStaticMemory_xK: 静态流，流本身自带静态的数据进行读写
TxdMemoryFile：     内存映射文件读写
}
unit uJxdDataStream;

interface
uses
  Windows, Classes, SysUtils;

type
  {$M+}
  TxdStreamBasic = class
  public
    {数据读取}
    //读取失败则抛出异常
    procedure ReadLong(var ABuffer; const ACount: Integer; const AutoIncPos: Boolean = True); virtual;
    function  ReadByte: Byte;
    function  ReadWord: Word;
    function  ReadCardinal: Cardinal;
    function  ReadInteger: Integer;
    function  ReadInt64: Int64;
    function  ReadString: string;   //读取1位长度，再读对应长度的字符串
    function  ReadStringEx: string; //读取2位长度，再读取对应长度的字符串
    {数据写入}
    //写入失败则抛出异常
    procedure WriteLong(const ABuffer; const ACount: Integer; const AutoIncPos: Boolean = True); virtual;
    procedure WriteByte(const AValue: Byte);
    procedure WriteWord(const AValue: Word);
    procedure WriteCardinal(const AValue: Cardinal);
    procedure WriteInteger(const AValue: Integer);
    procedure WriteInt64(const AValue: Int64);
    procedure WriteString(const AValue: string);    //写入1位长度，再写入应长度的字符串
    procedure WriteStringEx(const AValue: string);  //写入2位长度，再写入对应长度的字符串
    {清空数据}
    procedure Clear; virtual;
  published
  protected
    {数据读与写的控制方法}
    function ReadStream(var ABuffer; const AByteCount: Integer): Integer; virtual; abstract;
    function WriteStream(const ABuffer; const AByteCount: Integer): Integer; virtual; abstract;

    procedure RaiseReadError;
    procedure RaiseWriteError;
    function  GetPos: Int64; virtual; abstract;
    procedure SetPos(const Value: Int64); virtual; abstract;
    function  GetSize: Int64; virtual; abstract;
    procedure SetSize(const Value: Int64); virtual; abstract;
    function  CheckReadSize(const ACount: Integer): Boolean; virtual;
    function  CheckWriteSize(const ACount: Integer): Boolean; virtual;
  published
    property Position: Int64 read GetPos write SetPos;
    property Size: Int64 read GetSize write SetSize;
  end;

  {TxdStreamHandle 以实现系统自带TStream, 不能被实例化}
  TxdStreamHandle = class(TxdStreamBasic)
  public
    procedure ReadLong(var ABuffer; const ACount: Integer; const AutoIncPos: Boolean = True); override;
    procedure WriteLong(const ABuffer; const ACount: Integer; const AutoIncPos: Boolean = True); override;
    destructor Destroy; override;
  protected
    FStream: TStream;
    function  GetPos: Int64; override;
    procedure SetPos(const Value: Int64); override;
    function  GetSize: Int64; override;
    procedure SetSize(const Value: Int64); override;
    function ReadStream(var ABuffer; const AByteCount: Integer): Integer; override;
    function WriteStream(const ABuffer; const AByteCount: Integer): Integer; override;
  end;
  {TMemoryStream 的具体化}
  TxdMemoryStream = class(TxdStreamHandle)
  public
    constructor Create(const AInitMemorySize: Integer);
    procedure Clear; override;
    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);
  end;
  {TFileStream 具体化}
  TxdFileStream = class(TxdStreamHandle)
  private
    function GetFileName: string;
  public
    constructor Create(const AFileName: string; Mode: Word); overload;
    constructor Create(const AFileName: string; Mode: Word; Rights: Cardinal); overload;
    property FileName: string read GetFileName;
  protected
    function  CheckWriteSize(const ACount: Integer): Boolean; override;
  end;

  {TxdMemoryHandle 对外部或自我申请的数据进行处理，不能被实例化}
  TxdMemoryHandle = class(TxdStreamBasic)
  public
    constructor Create; virtual;
    function CurAddress: PChar;
  protected
    FMemory: PChar;
    FSize: Int64;
    FPosition: Int64;
    function  GetPos: Int64; override;
    procedure SetPos(const Value: Int64); override;
    function  GetSize: Int64; override;
    procedure SetSize(const Value: Int64); override;
    function ReadStream(var ABuffer; const AByteCount: Integer): Integer; override;
    function WriteStream(const ABuffer; const AByteCount: Integer): Integer; override;
  public
    property Memory: PChar read FMemory;
  end;

  TxdMemoryFile = class(TxdMemoryHandle)
  public
    constructor Create(const AFileName: string; const AFileSize: Int64 = 0; const ACreateAlways: Boolean = False; const AOnlyRead: Boolean = False); reintroduce;
    destructor Destroy; override;

    function  MapFileToMemory(const ABeginPos: Int64; const AMapSize: Cardinal): Boolean;
    procedure Flush;
  protected
    function  WriteStream(const ABuffer; const AByteCount: Integer): Integer; override;
    procedure SetSize(const Value: Int64); override; //只改变当前映射大小，不改文件大小
  private
    FFileMap: Cardinal;
    FFile: Cardinal;
    FFileName: string;
    FCurMapPos: Int64;
    FIsOnlyRead: Boolean;
    function  GetFileSize: Int64;
    procedure SetFileSize(const ANewFileSize: Int64);
  published
    property IsOnlyRead: Boolean read FIsOnlyRead;
    property FileName: string read FFileName;
    property FileSize: Int64 read GetFileSize write SetFileSize;
    property CurMapPos: Int64 read FCurMapPos;
    property CurMapSize: Int64 read FSize;
  end;

  TxdMemoryMapFile = class(TxdMemoryHandle)
  public
    constructor Create(const AFileName: string;
                       const AShareName: string = '';
                       const AFileShareMoe: Cardinal = FILE_SHARE_READ;
                       const ACreateAways: Boolean = False; const AOnlyRead: Boolean = False); reintroduce;
    destructor  Destroy; override;

    //AMapSize: 0表示映射所有，此时Size属性为MAXDWORD 
    function MapFileToMemory(const ABeginPos: Int64; const AMapSize: Cardinal): Boolean;


  private
    function  CreateMap: Boolean;
    procedure CloseMap;
    function  GetFileSizeInfo(var AdwHigh, AdwLow: Cardinal): Boolean;
  private
    FFileHanlde, FFileMap: Cardinal;
    FFileName, FShareName: string;
    FIsOnlyRead: Boolean;
    FCurMapBeginPos: Int64;
    function  GetFileSize: Int64; overload;
    procedure SetFileSize(const Value: Int64);
  published
    //property Size: 表示当前映射的大小，并非文件大小
    //property Position: 表示当前映射对应的位置
    property IsOnlyRead: Boolean read FIsOnlyRead;
    property FileName: string read FFileName;
    property ShareName: string read FShareName;
    property FileSize: Int64 read GetFileSize write SetFileSize;
    property CurMapBeginPos: Int64 read FCurMapBeginPos;
  end;

  {TxdOuterMemory 操作使用外部的内存}
  TxdOuterMemory = class(TxdMemoryHandle)
  public
    procedure InitMemory(const AMemory: PChar; const ASize: Int64);
  end;
  
  {TxdDynamicMemory 对象本身会申请内存，将是本身内存操作}
  TxdDynamicMemory = class(TxdMemoryHandle)
  public
    procedure InitMemory(const ASize: Int64);
    procedure Clear; override;
  end;

  {TxdStaticMemory 静态内存处理，分为16, 32, 64, 128, 512Byte和1, 2, 4, 8K 主要为了方便}
  TxdStaticMemory_16Byte = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 16;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_32Byte = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 32;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_64Byte = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 64;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_128Byte = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 128;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_256Byte = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 256;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_512Byte = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 512;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_1K = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 1024;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;

  TxdStaticMemory_2K = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 1024 * 2;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;

  TxdStaticMemory_4K = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 1024 * 4;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;

  TxdStaticMemory_8K = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 1024 * 8;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_16K = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 1024 * 16;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;
  TxdStaticMemory_32K = class(TxdMemoryHandle)
  public
    constructor Create; override;
    procedure Clear; override;
  private
    const DataSize = 1024 * 32;
  private
    FData: array[ 0..DataSize - 1] of Byte;
  end;

  {$M-}
implementation

{ TxdStreamBasic }

function TxdStreamBasic.CheckReadSize(const ACount: Integer): Boolean;
begin
  Result := (Position + Int64(ACount) <= Size) and (ACount > 0);
end;

function TxdStreamBasic.CheckWriteSize(const ACount: Integer): Boolean;
begin
  Result := (Position + Int64(ACount) <= Size) and (ACount > 0);
end;

procedure TxdStreamBasic.Clear;
begin
  Position := 0;
  Size := 0;
end;

procedure TxdStreamBasic.RaiseReadError;
begin
  raise Exception.Create( 'read data error' );
end;

procedure TxdStreamBasic.RaiseWriteError;
begin
  raise Exception.Create( 'write data error' );
end;

function TxdStreamBasic.ReadByte: Byte;
begin
  ReadLong( Result, 1 );
end;

function TxdStreamBasic.ReadCardinal: Cardinal;
begin
  ReadLong( Result, 4 );
end;

function TxdStreamBasic.ReadInt64: Int64;
begin
  ReadLong( Result, 8 );
end;

function TxdStreamBasic.ReadInteger: Integer;
begin
  ReadLong( Result, 4 );
end;

procedure TxdStreamBasic.ReadLong(var ABuffer; const ACount: Integer; const AutoIncPos: Boolean);
begin
  if not CheckReadSize(ACount) then
    RaiseReadError;
  if 0 <> ReadStream(ABuffer, ACount) then
  begin
    if AutoIncPos then
      Position := Position + ACount
  end
  else
    RaiseReadError;
end;

function TxdStreamBasic.ReadString: string;
var
  btLen: Byte;
begin
  btLen := ReadByte;
  if btLen > 0 then
  begin
    SetLength( Result, btLen );
    ReadLong( Result[1], btLen );
  end
  else
    Result := '';
end;

function TxdStreamBasic.ReadStringEx: string;
var
  dLen: Word;
begin
  dLen := ReadWord;
  if dLen > 0 then
  begin
    SetLength( Result, dLen );
    ReadLong( Result[1], dLen );
  end
  else
    Result := '';
end;

function TxdStreamBasic.ReadWord: Word;
begin
  ReadLong( Result, 2 );
end;

procedure TxdStreamBasic.WriteByte(const AValue: Byte);
begin
  WriteLong( AValue, 1 );
end;

procedure TxdStreamBasic.WriteCardinal(const AValue: Cardinal);
begin
  WriteLong( AValue, 4 );
end;

procedure TxdStreamBasic.WriteInt64(const AValue: Int64);
begin
  WriteLong( AValue, 8 );
end;

procedure TxdStreamBasic.WriteInteger(const AValue: Integer);
begin
  WriteLong( AValue, 4 );
end;

procedure TxdStreamBasic.WriteLong(const ABuffer; const ACount: Integer; const AutoIncPos: Boolean);
begin
  if not CheckWriteSize(ACount) then
    RaiseReadError;
  if 0 <> WriteStream(ABuffer, ACount) then
  begin
    if AutoIncPos then
      Position := Position + ACount
  end
  else
    RaiseReadError;
end;

procedure TxdStreamBasic.WriteString(const AValue: string);
var
  btLen: Byte;
begin
  btLen := Byte( Length(AValue) );
  WriteByte( btLen );
  if btLen > 0 then
    WriteLong( AValue[1], btLen );
end;

procedure TxdStreamBasic.WriteStringEx(const AValue: string);
var
  dLen: Word;
begin
  dLen := Word( Length(AValue) );
  WriteWord( dLen );
  if dLen > 0 then
    WriteLong( AValue[1], dLen );
end;

procedure TxdStreamBasic.WriteWord(const AValue: Word);
begin
  WriteLong( AValue, 2 );
end;

{ TxdStreamHandle }

destructor TxdStreamHandle.Destroy;
begin
  FreeAndNil( FStream );
  inherited;
end;

function TxdStreamHandle.GetPos: Int64;
begin
  Result := FStream.Position;
end;

function TxdStreamHandle.GetSize: Int64;
begin
  Result := FStream.Size;
end;

procedure TxdStreamHandle.ReadLong(var ABuffer; const ACount: Integer; const AutoIncPos: Boolean);
begin
  inherited ReadLong(ABuffer, ACount, False);
  if not AutoIncPos then
    Position := Position - ACount;
end;

function TxdStreamHandle.ReadStream(var ABuffer; const AByteCount: Integer): Integer;
begin
  Result := FStream.Read( ABuffer, AByteCount );
end;

procedure TxdStreamHandle.SetPos(const Value: Int64);
begin
  FStream.Position := Value;
end;

procedure TxdStreamHandle.SetSize(const Value: Int64);
begin
  if (FStream.Size <> Value) and (Value >= 0) then
    FStream.Size := Value;
end;

procedure TxdStreamHandle.WriteLong(const ABuffer; const ACount: Integer; const AutoIncPos: Boolean);
begin
  inherited WriteLong( ABuffer, ACount, False );
  if not AutoIncPos then
    Position := Position - ACount;
end;

function TxdStreamHandle.WriteStream(const ABuffer; const AByteCount: Integer): Integer;
begin
  Result := FStream.Write( ABuffer, AByteCount );
end;

{ TxdMemoryStream }

procedure TxdMemoryStream.Clear;
begin
  (FStream as TMemoryStream).Clear;
end;

constructor TxdMemoryStream.Create(const AInitMemorySize: Integer);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FStream.Size := AInitMemorySize;
end;

procedure TxdMemoryStream.LoadFromFile(const FileName: string);
begin
  (FStream as TMemoryStream).LoadFromFile( FileName );
end;

procedure TxdMemoryStream.SaveToFile(const FileName: string);
begin
  (FStream as TMemoryStream).SaveToFile( FileName );
end;

{ TxdFileStream }

constructor TxdFileStream.Create(const AFileName: string; Mode: Word);
begin
  FStream := TFileStream.Create( AFileName, Mode );
end;

function TxdFileStream.CheckWriteSize(const ACount: Integer): Boolean;
begin
  Result := True;
end;

constructor TxdFileStream.Create(const AFileName: string; Mode: Word; Rights: Cardinal);
begin
  FStream := TFileStream.Create( AFileName, Mode, Rights );
end;

function TxdFileStream.GetFileName: string;
begin
  Result := (FStream as TFileStream).FileName;
end;

{ TxdMemoryHandle }

constructor TxdMemoryHandle.Create;
begin
  FPosition := 0;
  FSize := 0;
  FMemory := nil;
end;

function TxdMemoryHandle.CurAddress: PChar;
begin
  Result := FMemory + FPosition;
end;

function TxdMemoryHandle.GetPos: Int64;
begin
  Result := FPosition;
end;

function TxdMemoryHandle.GetSize: Int64;
begin
  Result := FSize;
end;

function TxdMemoryHandle.ReadStream(var ABuffer; const AByteCount: Integer): Integer;
begin
  Move( (FMemory + FPosition)^, ABuffer, AByteCount );
  Result := AByteCount;
end;

procedure TxdMemoryHandle.SetPos(const Value: Int64);
begin
  if Value <= FSize then
    FPosition := Value;
end;

procedure TxdMemoryHandle.SetSize(const Value: Int64);
begin
  FSize := Value;
  if FPosition > FSize then
    FPosition := FSize;
end;

function TxdMemoryHandle.WriteStream(const ABuffer; const AByteCount: Integer): Integer;
begin
  Move( ABuffer,(FMemory + FPosition)^, AByteCount );
  Result := AByteCount;
end;

{ TxdOuterMemory }

procedure TxdOuterMemory.InitMemory(const AMemory: PChar; const ASize: Int64);
begin
  FMemory := AMemory;
  FPosition := 0;
  FSize := ASize;
end;

{ TxdDynamicMemory }

procedure TxdDynamicMemory.Clear;
begin
  inherited;
  FreeMemory( FMemory );
end;

procedure TxdDynamicMemory.InitMemory(const ASize: Int64);
begin
  FreeMemory( FMemory );
  FMemory := AllocMem( ASize );
  FSize := ASize;
  FPosition := 0;
end;

{ TxdStaticMemory_1K }

procedure TxdStaticMemory_1K.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_1K.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_2K }

procedure TxdStaticMemory_2K.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_2K.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_4K }

procedure TxdStaticMemory_4K.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_4K.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_8K }

procedure TxdStaticMemory_8K.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_8K.Create;
begin
  inherited;
  Clear;
end;

{ TxdMemoryFile }

constructor TxdMemoryFile.Create(const AFileName: string; const AFileSize: Int64; const ACreateAlways: Boolean; const AOnlyRead: Boolean);
var
  Style: Cardinal;
  nSize: Int64;
  strDir: string;
begin
  inherited Create;
  if ACreateAlways or (not FileExists(AFileName)) then
  begin
    Style := CREATE_ALWAYS;
    strDir := ExtractFilePath( AFileName );
    if not DirectoryExists(strDir) then
      ForceDirectories( strDir );
  end
  else
    Style := OPEN_ALWAYS;
  if AOnlyRead then
    FFile := CreateFile(PAnsiChar(AFileName), GENERIC_READ, FILE_SHARE_READ, nil, Style, 0, 0)
  else
    FFile := CreateFile(PAnsiChar(AFileName), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, Style, 0, 0);
  if FFile = INVALID_HANDLE_VALUE then
    raise Exception.Create(SysErrorMessage(GetLastError));

  if AFileSize <> 0 then
  begin
    nSize := Windows.GetFileSize( FFile, nil );
    if nSize <> AFileSize then
    begin
      FileSeek( FFile, AFileSize, FILE_BEGIN );
      SetEndOfFile( FFile );
    end;
  end;
  nSize := Windows.GetFileSize( FFile, nil );
  FCurMapPos := -1;
  FSize := 0;

  if nSize > 0 then
  begin
    if AOnlyRead then
      FFileMap := CreateFileMapping( FFile, nil, PAGE_READONLY, 0, nSize, nil )
    else
      FFileMap := CreateFileMapping( FFile, nil, PAGE_READWRITE, 0, nSize, nil );

    if FFileMap = 0 then
      raise Exception.Create(SysErrorMessage(GetLastError));
  end;

  FFileName := AFileName;
  FIsOnlyRead := AOnlyRead;
end;

destructor TxdMemoryFile.Destroy;
begin
  if Assigned(FMemory) then
  begin
    FlushViewOfFile( FMemory, 0 );
    UnmapViewOfFile( FMemory );
  end;
  CloseHandle( FFileMap );
  CloseHandle( FFile );
  inherited;
end;

procedure TxdMemoryFile.Flush;
begin
  if FMemory <> nil then
    FlushViewOfFile( FMemory, 0 );
end;

function TxdMemoryFile.GetFileSize: Int64;
begin
  Result := Windows.GetFileSize( FFile, nil );
end;

function TxdMemoryFile.MapFileToMemory(const ABeginPos: Int64; const AMapSize: Cardinal): Boolean;
var
  nHighOffset, nLowOffset, nMapSize: Cardinal;
  sf: TSystemInfo;
begin
  Result := (FFileMap <> 0) and (ABeginPos >= 0);
  if not Result then Exit;
  nHighOffset := ABeginPos shr 32;
  nLowOffset := Cardinal(ABeginPos);
  nMapSize := AMapSize;
  if nMapSize <> 0 then
  begin
    GetSystemInfo(sf);
    if (nMapSize mod sf.dwAllocationGranularity) <> 0 then
      nMapSize := (nMapSize + sf.dwAllocationGranularity - 1) div sf.dwAllocationGranularity * sf.dwAllocationGranularity;
  end;

  if nMapSize >= FileSize then
    nMapSize := 0;

  if Assigned(FMemory) then
    UnmapViewOfFile( FMemory );

  if IsOnlyRead then
    FMemory := MapViewOfFile( FFileMap, FILE_MAP_READ, nHighOffset, nLowOffset, nMapSize )
  else
    FMemory := MapViewOfFile( FFileMap, FILE_MAP_ALL_ACCESS, nHighOffset, nLowOffset, nMapSize );
  Result := Assigned(FMemory);
  if not Result then
  begin
    FSize := 0;
    FPosition := 0;
    FCurMapPos := -1;
    Exit;
  end;
  if AMapSize <> 0 then
    FSize := AMapSize
  else
    FSize := Windows.GetFileSize( FFile, nil );
  FCurMapPos := ABeginPos;
  FPosition := 0;
end;

procedure TxdMemoryFile.SetFileSize(const ANewFileSize: Int64);
begin
  if ANewFileSize <> 0 then
  begin
    FileSeek( FFile, ANewFileSize, FILE_BEGIN );
    SetEndOfFile( FFile );
    if FFileMap <> 0 then
    begin
      CloseHandle( FFileMap );
      FFileMap := CreateFileMapping( FFile, nil, PAGE_READWRITE, 0, FSize, nil );
      if FFileMap = 0 then
        raise Exception.Create(SysErrorMessage(GetLastError));
      if FCurMapPos + FSize <= ANewFileSize then
        MapFileToMemory( FCurMapPos, FSize )
      else
      begin
        if Assigned(FMemory) then
        begin
          UnmapViewOfFile( FMemory );
          FMemory := nil;
        end;
        FCurMapPos := -1;
        FSize := 0;
      end;
    end;
  end;
end;

procedure TxdMemoryFile.SetSize(const Value: Int64);
begin
  if FSize <> Value then
  begin
    if FCurMapPos >= 0 then
      MapFileToMemory( FCurMapPos, FSize );
  end;
end;

function TxdMemoryFile.WriteStream(const ABuffer; const AByteCount: Integer): Integer;
begin
  if IsOnlyRead then
    Result := -1
  else
    Result := inherited WriteStream(ABuffer, AByteCount);
end;

{ TxdStaticMemory_16Byte }

procedure TxdStaticMemory_16Byte.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_16Byte.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_32Byte }

procedure TxdStaticMemory_32Byte.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_32Byte.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_64Byte }

procedure TxdStaticMemory_64Byte.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_64Byte.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_256Byte }

procedure TxdStaticMemory_256Byte.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_256Byte.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_128Byte }

procedure TxdStaticMemory_128Byte.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_128Byte.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_512Byte }

procedure TxdStaticMemory_512Byte.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_512Byte.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_16K }

procedure TxdStaticMemory_16K.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_16K.Create;
begin
  inherited;
  Clear;
end;

{ TxdStaticMemory_32K }

procedure TxdStaticMemory_32K.Clear;
begin
  FPosition := 0;
  FSize := DataSize;
  FillChar( FData[0], DataSize, 0 );
  FMemory := @FData;
end;

constructor TxdStaticMemory_32K.Create;
begin
  inherited;
  Clear;
end;

{ TxdMemoryMapFile }

procedure TxdMemoryMapFile.CloseMap;
begin
  if FFileMap <> 0 then
  begin
    if Assigned(FMemory) then
    begin
      UnmapViewOfFile( FMemory );
      FMemory := nil;
    end;
    CloseHandle( FFileMap );
    FFileMap := 0;
    FCurMapBeginPos := 0;
  end;
end;

constructor TxdMemoryMapFile.Create(const AFileName, AShareName: string; const AFileShareMoe: Cardinal; const ACreateAways,
  AOnlyRead: Boolean);
var
  dwStyle: Cardinal;
begin
  FFileMap := 0;
  FFileHanlde := INVALID_HANDLE_VALUE;

  if ACreateAways or not FileExists(AFileName) then
  begin
    dwStyle := CREATE_ALWAYS;
    if not DirectoryExists(ExtractFileDir(AFileName)) then
      ForceDirectories( ExtractFileDir(AFileName) );
  end
  else
  begin
    dwStyle := OPEN_ALWAYS;
  end;

  if ACreateAways then
    FFileHanlde := CreateFile( PChar(AFileName), GENERIC_READ, AFileShareMoe, nil, dwStyle, 0, 0 )
  else
    FFileHanlde := CreateFile( PChar(AFileName), GENERIC_ALL, AFileShareMoe, nil, dwStyle, 0, 0 );

  if INVALID_HANDLE_VALUE = FFileHanlde then
  begin
    if AShareName = '' then
      raise Exception.Create( 'Can not Create File, on TxdMemoryMapFile Create!!!' );
  end;

  FSize := GetFileSize;
  FFileName := AFileName;
  FShareName := AShareName;
  FCurMapBeginPos := 0 ;
end;

function TxdMemoryMapFile.CreateMap: Boolean;
var
  dwHigh, dwLow, dwProtect: Cardinal;
begin
  CloseMap;
  Result := GetFileSizeInfo( dwHigh, dwLow );
  if Result then
  begin
    if FIsOnlyRead then
      dwProtect := PAGE_READONLY
    else
      dwProtect := PAGE_READWRITE;

    if FShareName = '' then
      FFileMap := CreateFileMapping( FFileHanlde, nil, dwProtect, dwHigh, dwLow, nil )
    else
      FFileMap := CreateFileMapping( FFileHanlde, nil, dwProtect, dwHigh, dwLow, PChar(FShareName) );
  end
  else if FShareName <> '' then
  begin
    if FIsOnlyRead then
      dwProtect := FILE_MAP_READ
    else
      dwProtect := FILE_MAP_ALL_ACCESS;
    FFileMap := OpenFileMapping( dwProtect, False, PChar(FShareName) );
  end;

  Result := FFileMap <> 0;
end;

destructor TxdMemoryMapFile.Destroy;
begin
  CloseMap;
  if INVALID_HANDLE_VALUE <> FFileHanlde then
  begin
    CloseHandle( FFileHanlde );
    FFileHanlde := INVALID_HANDLE_VALUE;
  end;
  inherited;
end;

function TxdMemoryMapFile.GetFileSizeInfo(var AdwHigh, AdwLow: Cardinal): Boolean;
begin
  if INVALID_HANDLE_VALUE = FFileHanlde then
  begin
    Result := False;
    Exit;
  end;
  AdwLow := Windows.GetFileSize( FFileHanlde, @AdwHigh );
  Result := True;
end;

function TxdMemoryMapFile.MapFileToMemory(const ABeginPos: Int64; const AMapSize: Cardinal): Boolean;
var
  SysInfo: TSystemInfo;
  dwSysGran, dwHighOffset, dwLowOffset, dwMapSize: Cardinal;
  nPos: Int64;
begin
  if 0 = FFileMap then
  begin
    if not CreateMap then
    begin
      Result := False;
      Exit;
    end;
  end;
  GetSystemInfo( SysInfo );
  dwSysGran := SysInfo.dwAllocationGranularity;
  nPos := (ABeginPos div dwSysGran) * dwSysGran;
  dwHighOffset := nPos shr 32;
  dwLowOffset := Cardinal(nPos);
  dwMapSize := (ABeginPos mod dwSysGran) + AMapSize;

  if Assigned(FMemory) then
  begin
    UnmapViewOfFile( FMemory );
    FMemory := nil;
  end;

  if FIsOnlyRead then
    FMemory := MapViewOfFile( FFileMap, FILE_MAP_READ, dwHighOffset, dwLowOffset, dwMapSize )
  else
    FMemory := MapViewOfFile( FFileMap, FILE_MAP_ALL_ACCESS, dwHighOffset, dwLowOffset, dwMapSize );

  Result := Assigned( FMemory );
  if Result then
  begin
    if dwMapSize <> 0 then
      FSize := dwMapSize
    else
      FSize := FileSize;

    //假设都可用
    if FSize = 0 then
      FSize := MAXDWORD;

    FCurMapBeginPos := nPos;
    FPosition := ABeginPos mod dwSysGran;
  end;
end;

function TxdMemoryMapFile.GetFileSize: Int64;
var
  dwHigh, dwLow: Cardinal;
begin
  if GetFileSizeInfo(dwHigh, dwLow) then
    Result := dwHigh shl 32 or dwLow
  else
    Result := 0;
end;

procedure TxdMemoryMapFile.SetFileSize(const Value: Int64);
var
  dwHigh, dwLow: Cardinal;
begin
  if (INVALID_HANDLE_VALUE <> FFileHanlde) and (Value > 0) and (Value <> GetFileSize) then
  begin
    dwHigh := Value shr 32;
    dwLow := Cardinal( Value );
    SetFilePointer( FFileHanlde, dwLow, @dwHigh, FILE_BEGIN );
    SetEndOfFile( FFileHanlde );
    CloseMap;
  end;
end;

end.
