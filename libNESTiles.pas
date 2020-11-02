{$WARN UNSAFE_CODE OFF}
unit libNESTiles;

interface

uses Windows, Graphics;

const
  MAX_PRG = 255;
  MAX_CHR = 255 shl 1;

type
  TiNESHeader = record
    Sign: longint;
    PRGBank: Byte;
    CHRBank: Byte;
    ROMCtrl1: Byte;
    ROMCtrl2: Byte;
    Zero: array [0 .. 7] of Byte;
  end;

  TTile = array [0 .. 15] of Byte;

  TNESFile = record
    Header: TiNESHeader;
    PRGSize, CHRSize: longint;
    PRGData, CHRData: Pointer;
  end;

const
  DRAW_NORMAL = 0;
  DRAW_VERTICAL = 1;
  DRAW_8X16 = 2;
  TILE_NES = 0;
  TILE_GB = 1;

const
  DrawMode: Byte = DRAW_NORMAL;
  TileFormat: Byte = TILE_NES;
  NESPalette: Array [0 .. 3] of longint = (
    $00000000,
    $00FFFFFF,
    $00BBBBBB,
    $00888888);

Function NESFileRead(Name: String; var NES: TNESFile): Integer;
Function TilemapRead(Name: String; var NES: TNESFile): Integer;
Function PatternsRead(Name: String; var NES: TNESFile): Integer;

Function PRGFileSave(Name: String; var NES: TNESFile): Integer;
Function NESFileSave(Name: String; var NES: TNESFile): Integer;

Procedure NESFileFree(var NES: TNESFile);

Procedure DrawPatterns(var Bitmap: TBitmap; var NES: TNESFile;
  CHROffset: longint);
Procedure DrawTilemap(var Bitmap: TBitmap; var NES: TNESFile;
  CHROffset, PRGOffset: Integer; Sx, Sy: Integer);
Procedure DrawSelection(var Bitmap: TBitmap; Selection: TRect);
Procedure DrawGrid(var Bitmap: TBitmap; A, B: Integer);
Procedure DrawUsedTiles(var Bitmap: TBitmap; Ofs, Sx: Integer; Area: TRect;
  var NES: TNESFile);

implementation

// ------------------------------------------------------------
// -- Internal Procedures -------------------------------------
// ------------------------------------------------------------

Procedure DrawTileLine(Buf: Pointer; TileLineA, TileLineB: Byte);
  assembler; stdcall;
asm
  push     edi
  push     ecx
  mov      edi, Buf
  mov      ecx, 8
@1:
  xor      eax, eax
  shl      TileLineB, 1
  rcl      al, 1
  shl      TileLineA, 1
  rcl      al, 1
  mov      eax, dword ptr NESPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4
  dec      ecx
  jnz      @1
  pop      ecx
  pop      edi
end;

Procedure DrawTile(var Bitmap: TBitmap; X, Y: Integer; var Tile: TTile);
var
  j, YY, XX: Integer;
  TileA, TileB: Byte;
  DIBScanline: Pointer;
begin
  XX := X shl 3;
  YY := Y shl 1;
  for j := 0 to 7 do
  begin
    case TileFormat of
      TILE_NES:
        begin
          TileA := Tile[j];
          TileB := Tile[j + 8];
        end;
      TILE_GB:
        begin
          TileA := Tile[(j * 2) + 0];
          TileB := Tile[(j * 2) + 1];
        end;
    end;
    DIBScanline := Bitmap.Scanline[YY];
    Inc(longint(DIBScanline), XX);
    DrawTileLine(DIBScanline, TileA, TileB);
    DIBScanline := Bitmap.Scanline[YY + 1];
    Inc(longint(DIBScanline), XX);
    DrawTileLine(DIBScanline, TileA, TileB);
    Inc(YY, 2);
  end;
end;

// ------------------------------------------------------------
// -- External Procedures -------------------------------------
// ------------------------------------------------------------

Procedure DrawPatterns(var Bitmap: TBitmap; var NES: TNESFile;
  CHROffset: longint);
var
  i, j: Integer;
  Offset: longint;
  CurTile: TTile;
begin
  with NES do
    if PRGData <> nil then
    begin
      Offset := longint(CHRData) + CHROffset;
      for i := 0 to 255 do
      begin
        for j := 0 to 15 do
          if ((Offset + j) < (longint(CHRData) + CHRSize)) then
            CurTile[j] := Byte(ptr(Offset + j)^)
          else
            CurTile[j] := 0;
        case DrawMode of
          DRAW_NORMAL:
            DrawTile(Bitmap, (i mod 16) shl 3, (i shr 4) shl 3, CurTile);
          DRAW_8X16:
            DrawTile(Bitmap, ((i mod 32) shr 1) shl 3,
              ((i mod 2) shl 3) + ((i shr 5) shl 4), CurTile);
          DRAW_VERTICAL:
            DrawTile(Bitmap, (i shr 4) shl 3, (i mod 16) shl 3, CurTile);
        end;
        Inc(Offset, 16);
      end;
    end;
end;

Procedure DrawTilemap(var Bitmap: TBitmap; var NES: TNESFile;
  CHROffset, PRGOffset: Integer; Sx, Sy: Integer);
var
  i, j, Tile: Integer;
  Offset: longint;
  Blank: TRect;
begin
  with NES do
    if PRGData <> nil then
    begin
      Offset := 0;
      for i := 0 to Sy - 1 do
        for j := 0 to Sx - 1 do
        begin
          if PRGOffset + Offset < PRGSize then
          begin
            Tile := Byte(ptr(longint(PRGData) + PRGOffset + Offset)^) shl 4;
            DrawTile(Bitmap, j shl 3, i shl 3,
              TTile(ptr(longint(CHRData) + CHROffset + Tile)^))
          end
          else
          begin
            Blank.Left := j shl 4;
            Blank.Top := i shl 4;
            Blank.Right := Blank.Left + 16;
            Blank.Bottom := Blank.Top + 16;
            Bitmap.Canvas.Brush.Color := $00FFFFFF;
            Bitmap.Canvas.FillRect(Blank);
          end;
          Inc(Offset);
        end;
    end;
  if Sx < 32 then
  begin
    Blank.Left := Sx shl 4;
    Blank.Top := 0;
    Blank.Right := Blank.Left + (32 - Sx) shl 4;
    Blank.Bottom := Blank.Top + Sy * 16;
    Bitmap.Canvas.Brush.Color := clWhite;
    Bitmap.Canvas.FillRect(Blank);
  end;
end;

Procedure DrawSelection(var Bitmap: TBitmap; Selection: TRect);
begin
  Bitmap.Canvas.Brush.Color := $000000FF;
  Bitmap.Canvas.FrameRect(Selection);
end;

Procedure DrawGrid(var Bitmap: TBitmap; A, B: Integer);
var
  i: Integer;
begin
  with Bitmap.Canvas do
  begin
    Pen.Color := $00FF0000;
    for i := 0 to A - 1 do
    begin
      MoveTo(i shl 4, 0);
      LineTo(i shl 4, B shl 4);
    end;
    for i := 0 to B - 1 do
    begin
      MoveTo(0, i shl 4);
      LineTo(A shl 4, i shl 4);
    end;
  end;
end;

Procedure DrawUsedTiles(var Bitmap: TBitmap; Ofs, Sx: Integer; Area: TRect;
  var NES: TNESFile);
var
  i, j, CurTile: Integer;
  CurPtr: Pointer;
  TileRect: TRect;
begin
  with NES do
    if PRGData <> nil then
    begin
      Bitmap.Canvas.Brush.Color := $00FF00FF;
      with Area do
      begin
        Left := Left shr 4;
        Right := Right shr 4 - 1;
        Top := Top shr 4;
        Bottom := Bottom shr 4 - 1;
        for i := Top to Bottom do
          for j := Left to Right do
          begin
            CurPtr := NES.PRGData;
            Inc(longint(CurPtr), Ofs);
            Inc(longint(CurPtr), Sx * i + j);
            CurTile := Byte(CurPtr^);
            case DrawMode of
              DRAW_NORMAL:
                begin
                  TileRect.Left := 1 + (CurTile mod 16) shl 4;
                  TileRect.Top := 1 + (CurTile shr 4) shl 4;
                end;
              DRAW_VERTICAL:
                begin
                  TileRect.Left := 1 + (CurTile shr 4) shl 4;
                  TileRect.Top := 1 + (CurTile mod 16) shl 4;
                end;
              DRAW_8X16: // DONE
                begin
                  TileRect.Left := 1 + ((CurTile mod 32) shr 1) shl 4;
                  TileRect.Top :=
                    1 + (((CurTile mod 2) shl 4) + ((CurTile shr 5) shl 5));
                end;
            end;
            TileRect.Right := TileRect.Left + 15;
            TileRect.Bottom := TileRect.Top + 15;
            Bitmap.Canvas.FrameRect(TileRect);
          end;
      end;
    end;
end;

Function NESFileRead(Name: String; var NES: TNESFile): Integer;
var
  IFile: THandle;
  err: dword;
begin
  result := 0;
  IFile := CreateFile(PChar(Name), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  if IFile = INVALID_HANDLE_VALUE then
  begin
    result := GetLastError;
    Exit;
  end;
  with NES do
  begin
      if not ReadFile(IFile, Header, 16, err, nil) then
    begin
      result := GetLastError;
      Exit;
    end;

    if Header.Sign = $1A53454E then
    begin
      PRGSize := Header.PRGBank * 16384;
      CHRSize := Header.CHRBank * 8192;

      if PRGSize = 0 then
        PRGSize := 256 * 16384;

      GetMem(PRGData, PRGSize);
      if not ReadFile(IFile, PRGData^, PRGSize, err, nil) then
      begin
        result := GetLastError;
        Exit;
      end;

      if CHRSize = 0 then
      begin
        CHRSize := PRGSize;
        GetMem(CHRData, CHRSize);
        Move(PRGData^, CHRData^, CHRSize);
      end
      else
      begin
        GetMem(CHRData, CHRSize);
        if not ReadFile(IFile, CHRData^, CHRSize, err, nil) then
        begin
          result := GetLastError;
          Exit;
        end;
      end;
    end
    else
    begin
      SetFilePointer(IFile, 0, 0, FILE_BEGIN);
      PRGSize := GetFileSize(IFile, nil);
      CHRSize := PRGSize;
      GetMem(PRGData, PRGSize);
      if not ReadFile(IFile, PRGData^, PRGSize, err, nil) then
      begin
        result := GetLastError;
        Exit;
      end;
      GetMem(CHRData, CHRSize);
      if not ReadFile(IFile, CHRData^, CHRSize, err, nil) then
      begin
        result := GetLastError;
        Exit;
      end;
    end;
  end;
  CloseHandle(IFile);
end;

Function TilemapRead(Name: String; var NES: TNESFile): Integer;
var
  IFile: THandle;
  err: dword;
begin
  result := 0;
  IFile := CreateFile(PChar(Name), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  if IFile = INVALID_HANDLE_VALUE then
  begin
    result := GetLastError;
    Exit;
  end;

  with NES do
  begin
    if PRGData <> nil then
      FreeMem(PRGData, PRGSize);
    PRGSize := GetFileSize(IFile, nil);
    GetMem(PRGData, PRGSize);
    if not ReadFile(IFile, PRGData^, PRGSize, err, nil) then
    begin
      result := GetLastError;
      Exit;
    end;
  end;
  CloseHandle(IFile);
end;

Function PatternsRead(Name: String; var NES: TNESFile): Integer;
var
  IFile: THandle;
  err: dword;
begin
  result := 0;
  IFile := CreateFile(PChar(Name), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  with NES do
  begin
    if CHRData <> nil then
      FreeMem(CHRData, CHRSize);
    CHRSize := GetFileSize(IFile, nil);
    GetMem(CHRData, CHRSize);
    if not ReadFile(IFile, CHRData^, CHRSize, err, nil) then
    begin
      result := GetLastError;
      Exit;
    end;
  end;
  CloseHandle(IFile);
end;

Function PRGFileSave(Name: String; var NES: TNESFile): Integer;
var
  IFile: THandle;
  err: dword;
begin
  result := 0;
  IFile := CreateFile(PChar(Name), GENERIC_WRITE, FILE_SHARE_READ, nil,
    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

  with NES do
  begin
    if not WriteFile(IFile, PRGData^, PRGSize, err, nil) then
    begin
      result := GetLastError;
      Exit;
    end;
  end;
  CloseHandle(IFile);
end;

Function NESFileSave(Name: String; var NES: TNESFile): Integer;
var
  IFile: THandle;
  err: dword;
begin
  result := 0;
  IFile := CreateFile(PChar(Name), GENERIC_WRITE, FILE_SHARE_READ, nil,
    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

  with NES do
  begin
    if not WriteFile(IFile, Header, SizeOf(TiNESHeader), err, nil) then
    begin
      result := GetLastError;
      Exit;
    end;
    if not WriteFile(IFile, PRGData^, PRGSize, err, nil) then
    begin
      result := GetLastError;
      Exit;
    end;
    if Header.CHRBank > 0 then
      if not WriteFile(IFile, CHRData^, CHRSize, err, nil) then
      begin
        result := GetLastError;
        Exit;
      end;
  end;
  CloseHandle(IFile);
end;

Procedure NESFileFree(var NES: TNESFile);
begin
  with NES do
  begin
    if PRGData <> nil then
      FreeMem(PRGData, PRGSize);
    if CHRData <> nil then
      FreeMem(CHRData, CHRSize);
  end;
end;

end.
