{$WARN UNSAFE_CODE OFF}
unit libNESTiles;

interface

uses Windows, Graphics;

type
  TiNESHeader = record
    Sign: longint;
    PRGBank: Byte;
    CHRBank: Byte;
    ROMCtrl1: Byte;
    ROMCtrl2: Byte;
    Zero: array [0 .. 7] of Byte;
  end;

  TTile = array [0 .. 32] of Byte;

  TNESFile = record
    Header: TiNESHeader;
    PRGSize, CHRSize: longint;
    PRGData, CHRData: Pointer;
  end;

const
  MAX_PRG = 255;
  MAX_CHR = 255 shl 1;

  DRAW_NORMAL = 0;
  DRAW_VERTICAL = 1;
  DRAW_8X16 = 2;
  TILE_1BPP = 0;
  TILE_NES = 1;
  TILE_GB = 2;
  TILE_GEN = 3;

  DrawMode: Byte = DRAW_NORMAL;
  TileFormat: Byte = TILE_NES;
  PatternMul: Byte = 2;

  NESGBDefPal: Array [0 .. 3] of longint = (
    $00000000,
    $00FFFFFF,
    $00BBBBBB,
    $00888888
    );

  GENPalDecodeTbl: Array [0 .. 7] of Byte = (
   $00, $34, $57, $74, $90, $AC, $CC, $FF
  );
  GENDefPal: Array [0 .. 63] of longint = (
    $00000000,
    $00FFFFFF,
    $00BBBBBB,
    $00888888,
    $000000AA,
    $00AA00AA,
    $000055AA,
    $00AAAAAA,
    $00555555,
    $00FF5555,
    $0055FF55,
    $00FFFF55,
    $005555FF,
    $00FF55FF,
    $0055FFFF,
    $00FFFFFF,

    $00000000,
    $00141414,
    $00202020,
    $002C2C2C,
    $00383838,
    $00444444,
    $00505050,
    $00616161,
    $00717171,
    $00818181,
    $00919191,
    $00A1A1A1,
    $00B6B6B6,
    $00CACACA,
    $00E2E2E2,
    $00FFFFFF,

    $00FF0000,
    $00FF0040,
    $00FF007D,
    $00FF00BE,
    $00FF00FF,
    $00BE00FF,
    $007D00FF,
    $004000FF,
    $000000FF,
    $000040FF,
    $00007DFF,
    $0000BEFF,
    $0000FFFF,
    $0000FFBE,
    $0000FF7D,
    $0000FF40,

    $0000FF00,
    $0040FF00,
    $007DFF00,
    $00BEFF00,
    $00FFFF00,
    $00FFBE00,
    $00FF7D00,
    $00FF4000,
    $00FF7D7D,
    $00FF7D9D,
    $00FF7DBE,
    $00FF7DDE,
    $00FF7DFF,
    $00DE7DFF,
    $00BE7DFF,
    $009D7DFF
    );

var
  CurPalette: Array [0 .. 63] of longint;

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
Procedure DrawPalette(var Bitmap: TBitmap);

  Procedure DrawSelection(var Bitmap: TBitmap; Selection: TRect);
Procedure DrawGrid(var Bitmap: TBitmap; A, B: Integer);
Procedure DrawUsedTiles(var Bitmap: TBitmap; Ofs, Sx: Integer; Area: TRect;
  var NES: TNESFile);

Procedure DefPalInit;

implementation

// ------------------------------------------------------------
// -- Internal Procedures -------------------------------------
// ------------------------------------------------------------

Procedure DrawTileLine8(Buf: Pointer; TileLineA, TileLineB: Byte);
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
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4
  dec      ecx
  jnz      @1
  pop      ecx
  pop      edi
end;

Procedure DrawTileLine16(Buf: Pointer; TileLineA, TileLineB, TileLineC, TileLineD: Byte; Pal: Integer);
  assembler; stdcall;
asm
  push     edi
  mov      edi, Buf

  xor      eax, eax
  mov      al, TileLineA
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineA
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineB
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineB
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineC
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineC
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineD
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineD
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  pop      edi
end;

Procedure DrawTileLine16h(Buf: Pointer; TileLineA, TileLineB, TileLineC, TileLineD: Byte; Pal: Integer);
  assembler; stdcall;
asm
  push     edi
  mov      edi, Buf

  xor      eax, eax
  mov      al, TileLineD
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineD
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineC
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineC
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineB
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineB
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineA
  and      al, 15
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  xor      eax, eax
  mov      al, TileLineA
  shr      al, 4
  add      eax, Pal
  mov      eax, dword ptr CurPalette[eax*4]
  mov      dword ptr [edi], eax
  add      edi, 4
  mov      dword ptr [edi], eax
  add      edi, 4

  pop      edi
end;

Procedure DrawTile(var Bitmap: TBitmap; X, Y: Integer; var Tile: TTile; vFlip, hFlip: Boolean; Pal: Integer);
var
  j, k, YY, XX: Integer;
  TileA, TileB, TileC, TileD: Byte;
  DIBScanline: Pointer;
begin
  XX := X shl 3;
  YY := Y shl 1;
  for j := 0 to 7 do
  begin
    if TileFormat <> TILE_GEN then
    begin
        TileA := 0;
        TileB := 0;
        case TileFormat of
          TILE_1BPP:
            begin
              TileA := Tile[j];
              TileB := 0;
            end;
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
        DrawTileLine8(DIBScanline, TileA, TileB);
        DIBScanline := Bitmap.Scanline[YY + 1];
        Inc(longint(DIBScanline), XX);
        DrawTileLine8(DIBScanline, TileA, TileB);
    end
    else
    begin
        if vFlip = false then
          k := j
        else
          k := 7 - j;
        TileA := Tile[(k * 4) + 0];
        TileB := Tile[(k * 4) + 1];
        TileC := Tile[(k * 4) + 2];
        TileD := Tile[(k * 4) + 3];
        DIBScanline := Bitmap.Scanline[YY];
        Inc(longint(DIBScanline), XX);
        if hFlip = false then
          DrawTileLine16(DIBScanline, TileA, TileB, TileC, TileD, Pal)
        else
          DrawTileLine16h(DIBScanline, TileA, TileB, TileC, TileD, Pal);
        DIBScanline := Bitmap.Scanline[YY + 1];
        Inc(longint(DIBScanline), XX);
        if hFlip = false then
          DrawTileLine16(DIBScanline, TileA, TileB, TileC, TileD, Pal)
        else
          DrawTileLine16h(DIBScanline, TileA, TileB, TileC, TileD, Pal);
    end;
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
  TileLen: Integer;
begin
  with NES do
    if PRGData <> nil then
    begin
      Offset := longint(CHRData) + CHROffset;
      case TileFormat of
        TILE_1BPP:
            TileLen := 8;
        TILE_NES:
            TileLen := 16;
        TILE_GB:
            TileLen := 16;
        TILE_GEN:
            TileLen := 32;
      end;
      for i := 0 to 255 do
      begin
        for j := 0 to (TileLen - 1) do
          if ((Offset + j) < (longint(CHRData) + CHRSize)) then
            CurTile[j] := Byte(ptr(Offset + j)^)
          else
            CurTile[j] := 0;
        case DrawMode of
          DRAW_NORMAL:
            DrawTile(Bitmap, (i mod 16) shl 3, (i shr 4) shl 3, CurTile, false, false, 0);
          DRAW_8X16:
            DrawTile(Bitmap, ((i mod 32) shr 1) shl 3,
              ((i mod 2) shl 3) + ((i shr 5) shl 4), CurTile, false, false, 0);
          DRAW_VERTICAL:
            DrawTile(Bitmap, (i shr 4) shl 3, (i mod 16) shl 3, CurTile, false, false, 0);
        end;
        Inc(Offset, TileLen);
      end;
    end;
end;

Procedure DrawTilemap(var Bitmap: TBitmap; var NES: TNESFile;
  CHROffset, PRGOffset: Integer; Sx, Sy: Integer);
var
  i, j, Tile, Pal: Integer;
  vFlip, hFlip: Boolean;
  Offset, TmpTile: longint;
  Blank: TRect;
begin
  with NES do
    if PRGData <> nil then
    begin
      Offset := 0;
      for i := 0 to Sy - 1 do
        for j := 0 to Sx - 1 do
        begin
          if j < 32 then
          begin
            if PRGOffset + Offset < PRGSize then
            begin
              vFlip := false;
              hFlip := false;
              Pal := 0;
              case TileFormat of
              TILE_1BPP:
                Tile := Byte(ptr(longint(PRGData) + PRGOffset + Offset)^) shl 3;
              TILE_NES:
                Tile := Byte(ptr(longint(PRGData) + PRGOffset + Offset)^) shl 4;
              TILE_GB:
                Tile := Byte(ptr(longint(PRGData) + PRGOffset + Offset)^) shl 4;
              TILE_GEN:
              begin
                TmpTile := (Byte(ptr(longint(PRGData) + PRGOffset + Offset)^) shl 8) + Byte(ptr(longint(PRGData) + PRGOffset + Offset + 1)^);
                Tile := (TmpTile and $7FF) shl 5;
                hFlip := (TmpTile and $0800) = $0800;
                vFlip := (TmpTile and $1000) = $1000;
                Pal := (TmpTile and $6000) shr (13 - 4);
              end;
              end;
              DrawTile(Bitmap, j shl 3, i shl 3,
                TTile(ptr(longint(CHRData) + CHROffset + Tile)^), vFlip, hFlip, Pal)
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
          end;
          Inc(Offset);
          case TileFormat of
            TILE_GEN:
              Inc(Offset);
          end;
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

Procedure DrawPalette(var Bitmap: TBitmap);
var
  i, j: Integer;
  Rect: TRect;
begin
  for i := 0 to 3 do
    for j := 0 to 15 do
      begin
        Rect.Left := j shl 4;
        Rect.Top := i shl 4;
        Rect.Right := Rect.Left + 16;
        Rect.Bottom := Rect.Top + 16;
        Bitmap.Canvas.Brush.Color := CurPalette[(i * 16) + j];
        Bitmap.Canvas.FillRect(Rect);
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
  tmp: longint;
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
      TileFormat := TILE_NES;
      PatternMul := 2;
      DefPalInit;

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

      // check if loaded file is in GB format, then set the proper TILE format automatically.
      SetFilePointer(IFile, $104, nil, FILE_BEGIN);
      if not ReadFile(IFile, tmp, 4, err, nil) then
      begin
        result := GetLastError;
        Exit;
      end;
      if(tmp = $6666EDCE) then
      begin
        TileFormat := TILE_GB;
        PatternMul := 2;
        DefPalInit;
      end;
      // load data RAW two copies of the same file in CHR and TILE buffers.
      PRGSize := GetFileSize(IFile, nil);
      GetMem(PRGData, PRGSize);
      SetFilePointer(IFile, 0, nil, FILE_BEGIN);
      if not ReadFile(IFile, PRGData^, PRGSize, err, nil) then
      begin
        result := GetLastError;
        Exit;
      end;
      CHRSize := PRGSize;
      GetMem(CHRData, CHRSize);
      Move(PRGData^, CHRData^, CHRSize);
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
    begin
      FreeMem(PRGData, PRGSize);
      PRGData := nil;
    end;
    if CHRData <> nil then
    begin
      FreeMem(CHRData, CHRSize);
      CHRData := nil;
    end;
  end;
end;

Procedure DefPalInit;
var
  i: Integer;
begin
    for i := 0 to 63 do CurPalette[i] := 0;
    if TileFormat <> TILE_GEN then
    begin
      for i := 0 to 3 do
        CurPalette[i] := NESGBDefPal[i];
    end
    else
    begin
      for i := 0 to 63 do CurPalette[i] := GENDefPal[i];
    end;
end;

end.
