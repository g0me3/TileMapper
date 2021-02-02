{$WARN UNSAFE_CODE OFF}
unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, libNESTiles, Buttons, ComCtrls;

type
  TfmMainDialog = class(TForm)
    mmMain: TMainMenu;
    mnFile: TMenuItem;
    mnExit: TMenuItem;
    mnLoadFromNES: TMenuItem;
    odOpen: TOpenDialog;
    spbTilemapUp: TSpeedButton;
    spbTilemapDown: TSpeedButton;
    spbPatternsUp: TSpeedButton;
    spbPatternsDown: TSpeedButton;
    spbTilemapLineUp: TSpeedButton;
    spbTilemapLineDown: TSpeedButton;
    spbTilemapPageUp: TSpeedButton;
    spbTilemapPageDown: TSpeedButton;
    spbPatternsLineUp: TSpeedButton;
    spbPatternsTileUp: TSpeedButton;
    spbPatternsTileDown: TSpeedButton;
    spbPatternsLineDown: TSpeedButton;
    spbTilemapHome: TSpeedButton;
    spbTilemapEnd: TSpeedButton;
    spbPatternsEnd: TSpeedButton;
    spbPatternsHome: TSpeedButton;
    spbPatternsPageUp: TSpeedButton;
    spbPatternsPageDown: TSpeedButton;
    pbTilemapSize: TProgressBar;
    pnTilemap: TPanel;
    pnPatterns: TPanel;
    mnLoadTilemap: TMenuItem;
    mnLoadPatterns: TMenuItem;
    mnOptions: TMenuItem;
    cbDrawPatternsGrid: TMenuItem;
    cbDrawTilemapGrid: TMenuItem;
    N1: TMenuItem;
    cbDrawUsedTiles: TMenuItem;
    sbMain: TStatusBar;
    N2: TMenuItem;
    N3: TMenuItem;
    mnSaveTilemap: TMenuItem;
    sdSave: TSaveDialog;
    mnVerticalDraw: TMenuItem;
    mnSaveNES: TMenuItem;
    mnDecodeView: TMenuItem;
    mnPLain: TMenuItem;
    mnNormalDraw: TMenuItem;
    mn8x16Draw: TMenuItem;
    N5: TMenuItem;
    mnNESTiles: TMenuItem;
    mnGBTiles: TMenuItem;
    mn1BPPTiles: TMenuItem;
    pmnContextMenu: TPopupMenu;
    pmnTilesGoto: TMenuItem;
    pmnPatternsGoto: TMenuItem;
    mnGENTiles: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnExitClick(Sender: TObject);
    procedure mnLoadFromNESClick(Sender: TObject);
    procedure spbTilemapUpClick(Sender: TObject);
    procedure spbTilemapDownClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure spbTilemapLineUpClick(Sender: TObject);
    procedure spbTilemapLineDownClick(Sender: TObject);
    procedure spbTilemapPageUpClick(Sender: TObject);
    procedure spbTilemapPageDownClick(Sender: TObject);
    procedure spbTilemapHomeClick(Sender: TObject);
    procedure spbTilemapEndClick(Sender: TObject);
    procedure spbPatternsUpClick(Sender: TObject);
    procedure spbPatternsDownClick(Sender: TObject);
    procedure spbPatternsTileUpClick(Sender: TObject);
    procedure spbPatternsTileDownClick(Sender: TObject);
    procedure spbPatternsLineUpClick(Sender: TObject);
    procedure spbPatternsLineDownClick(Sender: TObject);
    procedure spbPatternsHomeClick(Sender: TObject);
    procedure spbPatternsEndClick(Sender: TObject);
    procedure spbPatternsPageUpClick(Sender: TObject);
    procedure spbPatternsPageDownClick(Sender: TObject);
    procedure pbTilemapSizeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbTilemapSizeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbTilemapSizeMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure mnLoadTilemapClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbDrawPatternsGridClick(Sender: TObject);
    procedure cbDrawTilemapGridClick(Sender: TObject);
    procedure cbDrawUsedTilesClick(Sender: TObject);
    procedure mnSaveTilemapClick(Sender: TObject);
    procedure mnVerticalDrawClick(Sender: TObject);
    procedure mnLoadPatternsClick(Sender: TObject);
    procedure mnSaveNESClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure mn8x16DrawClick(Sender: TObject);
    procedure mnNormalDrawClick(Sender: TObject);
    procedure mnNESTilesClick(Sender: TObject);
    procedure mnGBTilesClick(Sender: TObject);
    procedure mn1BPPTilesClick(Sender: TObject);
    procedure pmnPatternsGotoClick(Sender: TObject);
    procedure pmnTilesGotoClick(Sender: TObject);
    procedure mnGENTilesClick(Sender: TObject);
  private
    { Private declarations }
    fPatterns, fTileMap, fPalette: TBitmap;

    PatternsOffset: Longint;
    TilemapOffset: Longint;

    TilemapSx, TilemapSy, TilemapSS: Integer;

    fNESFile: TNESFile;
    fisNESLoaded, fisBarDragged, fisSelDragged, fisTilemapChanged,
      fisTileDragged, fisTilemapModified: Boolean;

    fSelection: TRect;
    fDraggedTile: Integer;
    fCurTile: Integer;
    fXOrigin, fYOrigin: Integer;
    fTileName: string;
    fPatternName: string;
    procedure RedrawTilemap;
    procedure RedrawPatterns;
    procedure RedrawPalette;
    procedure LoadInit;
    procedure TileFormatUpdate;
    procedure DrawModeUpdate;
    procedure SetApplicationTitle;
  public
    { Public declarations }
  end;

const
  TILEMAP_LEFT = 2;
  TILEMAP_TOP = 16;
  PATTERNS_LEFT = 543;
  PATTERNS_TOP = TILEMAP_TOP;
  PAL_LEFT = PATTERNS_LEFT;
  PAL_TOP = PATTERNS_TOP + 256 + 16;

var
  fmMainDialog: TfmMainDialog;

implementation

{$R *.DFM}

procedure TfmMainDialog.RedrawTilemap;
begin
  DrawTilemap(fTileMap, fNESFile, PatternsOffset, TilemapOffset, TilemapSx,
    TilemapSy);

  if cbDrawTilemapGrid.Checked then
    DrawGrid(fTileMap, TilemapSx, TilemapSy);

  DrawSelection(fTileMap, fSelection);

  pnTilemap.Caption := IntToHex(TilemapOffset, 6) + ' \ ' +
    IntToHex(fNESFile.PRGSize, 6) + ' PRG BANK [8K:' +
    IntToHex(TilemapOffset shr 13, 3) + ', 16K:' +
    IntToHex(TilemapOffset shr 14, 2) + ', 32K:' +
    IntToHex(TilemapOffset shr 15, 2) + '] SELECTION (' +
    IntToHex(fSelection.Left shr 4, 2) + ',' + IntToHex(fSelection.Top shr 4,
    2) + ',' + IntToHex(fSelection.Right shr 4 - 1, 2) + ',' +
    IntToHex(fSelection.Bottom shr 4 - 1, 2) + ')';
  pnTilemap.Repaint;
  Canvas.Draw(TILEMAP_LEFT, TILEMAP_TOP, fTileMap);

  if fisTilemapChanged then
    RedrawPatterns; // pattern used grid may change
end;

procedure TfmMainDialog.RedrawPatterns;
var
  fCurTileRect: TRect;
begin
  fisTilemapChanged := False;
  RedrawTilemap; // redraw because it change for sure

  DrawPatterns(fPatterns, fNESFile, PatternsOffset);

  if cbDrawPatternsGrid.Checked then
    DrawGrid(fPatterns, 16, 16);

  if cbDrawUsedTiles.Checked then
    DrawUsedTiles(fPatterns, TilemapOffset, TilemapSx, fSelection,
      fNESFile);

  case DrawMode of
    DRAW_NORMAL:
      begin
        fCurTileRect.Left := (fCurTile mod 16) shl 4;
        fCurTileRect.Top := (fCurTile shr 4) shl 4;
      end;
    DRAW_VERTICAL:
      begin
        fCurTileRect.Left := (fCurTile shr 4) shl 4;
        fCurTileRect.Top := (fCurTile mod 16) shl 4;
      end;
    DRAW_8X16: // DONE
      begin
        fCurTileRect.Left := ((fCurTile mod 32) shr 1) shl 4;
        fCurTileRect.Top := ((fCurTile mod 2) shl 4) +
          ((fCurTile shr 5) shl 5);
      end;
  end;
  fCurTileRect.Right := fCurTileRect.Left + 17;
  fCurTileRect.Bottom := fCurTileRect.Top + 17;
  DrawSelection(fPatterns, fCurTileRect);

  pnPatterns.Caption := IntToHex(PatternsOffset, 6) + '\' +
    IntToHex(fNESFile.CHRSize, 6) + ' CHR BANK [1K:' +
    IntToHex(PatternsOffset shr 10, 3) + ', 8K:' +
    IntToHex(PatternsOffset shr 13, 2) + '] ' + IntToHex(fCurTile, 2);
  pnPatterns.Repaint;
  Canvas.Draw(PATTERNS_LEFT, PATTERNS_TOP, fPatterns);
end;

procedure TfmMainDialog.RedrawPalette;
begin
  DrawPalette(fPalette);
  Canvas.Draw(PAL_LEFT, PAL_TOP, fPalette);
end;

procedure TfmMainDialog.SetApplicationTitle;
var
  tmpTitle: string;
begin
  tmpTitle := 'TileMapper';
  if fTileName = fPatternName then
  begin
    if fTileName = '' then
      tmpTitle := tmpTitle + ' [NON]'
    else
      tmpTitle := tmpTitle + ' [File: "' + fTileName + '"]';
  end
  else
  begin
    tmpTitle := tmpTitle + ' [';
    if fTileName <> '' then
      tmpTitle := tmpTitle + 'TILE: "' + fTileName + '"'
    else
      tmpTitle := tmpTitle + 'TILE: NON';
    if fPatternName <> '' then
      tmpTitle := tmpTitle + ' CHR: "' + fPatternName + '"'
    else
      tmpTitle := tmpTitle + ' CHR: NON';
    tmpTitle := tmpTitle + ']';
  end;
  fmMainDialog.Caption := tmpTitle;
end;

procedure TfmMainDialog.FormCreate(Sender: TObject);
begin
  fPatterns := TBitmap.Create;
  with fPatterns as TBitmap do
  begin
    Width := 16 * 8 * 2;
    Height := 16 * 8 * 2;
    PixelFormat := pf32Bit;
  end;
  fTileMap := TBitmap.Create;
  with fTileMap as TBitmap do
  begin
    Width := 32 * 8 * 2;
    Height := 33 * 8 * 2;
    PixelFormat := pf32Bit;
  end;
  fPalette := TBitmap.Create;
  with fPalette as TBitmap do
  begin
    Width := 16 * 8 * 2;
    Height := 4 * 8 * 2;
    PixelFormat := pf32Bit;
  end;
  TilemapSx := 32;
  TilemapSy := 33;
  TilemapSS := TilemapSx * TilemapSy;
  fSelection.Left := 0;
  fSelection.Top := 0;
  fSelection.Bottom := TilemapSy * 16;
  fSelection.Right := TilemapSx * 16;
  fisTilemapChanged := False;
  fisTilemapModified := False;
  fCurTile := 0;
  fTileName := '';
  fPatternName := '';
  mnNormalDraw.Checked := true;
  mnVerticalDraw.Checked := False;
  mn8x16Draw.Checked := False;
  mn1BPPTiles.Checked := true;
  mnNESTiles.Checked := true;
  mnGBTiles.Checked := False;
  DefPalInit;
  RedrawTilemap;
  RedrawPatterns;
  RedrawPalette;
  SetApplicationTitle;
end;

procedure TfmMainDialog.FormDestroy(Sender: TObject);
begin
  fPatterns.Free;
  fTileMap.Free;
  fPalette.Free;
  NESFileFree(fNESFile);
  fTileName := '';
  fPatternName := '';
  fisNESLoaded := False;
end;

procedure TfmMainDialog.mnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMainDialog.LoadInit;
begin
  TileFormatUpdate;
  fisNESLoaded := true;
  mnLoadTilemap.Enabled := true;
  mnLoadPatterns.Enabled := true;
//mnDecodeView.Enabled := true;
  fisTilemapModified := False;
  sbMain.Panels[1].Text := '';
  TilemapOffset := 0;
  PatternsOffset := 0;
  RedrawPatterns;
  RedrawTilemap;
  RedrawPalette;
end;

procedure TfmMainDialog.mnLoadFromNESClick(Sender: TObject);
begin
  with odOpen as TOpenDialog do
  begin
    Filter := 'All Files|*.*';
    if Execute then
    begin
      NESFileFree(fNESFile);
      fTileName := '';
      fPatternName := '';
      fisNESLoaded := False;
      if NESFileRead(Filename, fNESFile) <> 0 then
      begin
        Application.MessageBox('Error Opening File', 'Error!', 0);
        Close;
      end;
      LoadInit;
      fTileName := Filename;
      fPatternName := Filename;
      SetApplicationTitle;
    end;
  end;
end;

procedure TfmMainDialog.mnLoadTilemapClick(Sender: TObject);
begin
  with odOpen as TOpenDialog do
  begin
    Filter := 'All Files|*.*';
    if Execute then
    begin
      if TilemapRead(Filename, fNESFile) <> 0 then
      begin
        Application.MessageBox('Error Opening File', 'Error!', 0);
        Close;
      end;
      TilemapOffset := 0;
      fisTilemapChanged := true;
      RedrawTilemap;
      fTileName := Filename;
      SetApplicationTitle;
    end;
  end;
end;

procedure TfmMainDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [ssShift] then
  begin
    if Key = 45 then
      spbPatternsUpClick(Sender);
    if Key = 46 then
      spbPatternsDownClick(Sender);
    if Key = 37 then
      spbPatternsTileUpClick(Sender);
    if Key = 39 then
      spbPatternsTileDownClick(Sender);
    if Key = 38 then
      spbPatternsLineUpClick(Sender);
    if Key = 40 then
      spbPatternsLineDownClick(Sender);
    if Key = 33 then
      spbPatternsPageUpClick(Sender);
    if Key = 34 then
      spbPatternsPageDownClick(Sender);
    if Key = 36 then
      spbPatternsHomeClick(Sender);
    if Key = 35 then
      spbPatternsEndClick(Sender);
  end
  else
  begin
    if Key = 37 then
      spbTilemapUpClick(Sender);
    if Key = 39 then
      spbTilemapDownClick(Sender);
    if Key = 38 then
      spbTilemapLineUpClick(Sender);
    if Key = 40 then
      spbTilemapLineDownClick(Sender);
    if Key = 33 then
      spbTilemapPageUpClick(Sender);
    if Key = 34 then
      spbTilemapPageDownClick(Sender);
    if Key = 36 then
      spbTilemapHomeClick(Sender);
    if Key = 35 then
      spbTilemapEndClick(Sender);
    if Key = 188 then
    begin
      if TilemapSx > 1 then
      begin
        dec(TilemapSx);
        pbTilemapSize.Position := TilemapSx;
        TilemapSS := TilemapSy * TilemapSx;
        fisTilemapChanged := true;
        RedrawTilemap;
        pbTilemapSize.Repaint;
      end;
    end;
    if Key = 190 then
    begin
      if TilemapSx < 40 then
      begin
        inc(TilemapSx);
        pbTilemapSize.Position := TilemapSx;
        TilemapSS := TilemapSy * TilemapSx;
        fisTilemapChanged := true;
        RedrawTilemap;
        pbTilemapSize.Repaint;
      end;
    end;
  end;
end;

procedure TfmMainDialog.FormPaint(Sender: TObject);
begin
  Canvas.Draw(PATTERNS_LEFT, PATTERNS_TOP, fPatterns);
  Canvas.Draw(TILEMAP_LEFT, TILEMAP_TOP, fTileMap);
  Canvas.Draw(PAL_LEFT, PAL_TOP, fPalette);
end;

procedure TfmMainDialog.spbTilemapUpClick(Sender: TObject);
begin
  if TilemapOffset > 0 then
  begin
    dec(TilemapOffset);
    fisTilemapChanged := true;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.spbTilemapDownClick(Sender: TObject);
begin
  if (TilemapOffset + TilemapSS) < fNESFile.PRGSize then
  begin
    inc(TilemapOffset);
    fisTilemapChanged := true;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.spbTilemapLineUpClick(Sender: TObject);
begin
  if TilemapOffset >= TilemapSx then
  begin
    dec(TilemapOffset, TilemapSx);
    fisTilemapChanged := true;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.spbTilemapLineDownClick(Sender: TObject);
begin
  if (TilemapOffset + TilemapSS + TilemapSx) < fNESFile.PRGSize then
  begin
    inc(TilemapOffset, TilemapSx);
    fisTilemapChanged := true;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.spbTilemapPageUpClick(Sender: TObject);
begin
  if TilemapOffset >= TilemapSS then
  begin
    dec(TilemapOffset, TilemapSS);
    fisTilemapChanged := true;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.spbTilemapPageDownClick(Sender: TObject);
begin
  if (TilemapOffset + TilemapSS + TilemapSS) < fNESFile.PRGSize then
  begin
    inc(TilemapOffset, TilemapSS);
    fisTilemapChanged := true;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.spbTilemapHomeClick(Sender: TObject);
begin
  TilemapOffset := 0;
  fisTilemapChanged := true;
  RedrawTilemap;
end;

procedure TfmMainDialog.spbTilemapEndClick(Sender: TObject);
begin
  TilemapOffset := fNESFile.PRGSize - TilemapSS;
  fisTilemapChanged := true;
  RedrawTilemap;
end;

procedure TfmMainDialog.spbPatternsUpClick(Sender: TObject);
begin
  if PatternsOffset > 0 then
  begin
    dec(PatternsOffset);
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsDownClick(Sender: TObject);
begin
  if (PatternsOffset + (256 * 8 * PatternMul)) <= fNESFile.CHRSize then
  begin
    inc(PatternsOffset);
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsTileUpClick(Sender: TObject);
begin
  if PatternsOffset >= (8 * PatternMul) then
  begin
    dec(PatternsOffset, (8 * PatternMul));
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsTileDownClick(Sender: TObject);
begin
  if (PatternsOffset + (257 * 8 * PatternMul)) <= fNESFile.CHRSize then
  begin
    inc(PatternsOffset, (8 * PatternMul));
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsLineUpClick(Sender: TObject);
begin
  if PatternsOffset >= (16 * 8 * PatternMul) then
  begin
    dec(PatternsOffset, (16 * 8 * PatternMul));
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsLineDownClick(Sender: TObject);
begin
  if (PatternsOffset + (256 * 8 * PatternMul) + (16 * 8 * PatternMul)) <= fNESFile.CHRSize then
  begin
    inc(PatternsOffset, (16 * 8 * PatternMul));
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsPageUpClick(Sender: TObject);
begin
  if PatternsOffset >= ((256 * 8 * PatternMul) - 1) then
  begin
    dec(PatternsOffset, (256 * 8 * PatternMul));
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsPageDownClick(Sender: TObject);
begin
  if (PatternsOffset + (256 * 8 * PatternMul) + (256 * 8 * PatternMul)) <= fNESFile.CHRSize then
  begin
    inc(PatternsOffset, (256 * 8 * PatternMul));
    RedrawPatterns;
  end;
end;

procedure TfmMainDialog.spbPatternsHomeClick(Sender: TObject);
begin
  PatternsOffset := 0;
  RedrawPatterns;
end;

procedure TfmMainDialog.spbPatternsEndClick(Sender: TObject);
begin
  PatternsOffset := fNESFile.CHRSize - (256 * 8 * PatternMul);
  RedrawPatterns;
end;

procedure TfmMainDialog.pbTilemapSizeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    TilemapSx := (X shr 4) + 1;
    if X < 0 then
      TilemapSx := 1;
    if TilemapSx > 32 then
      TilemapSx := 32;
    pbTilemapSize.Position := TilemapSx;
    TilemapSS := TilemapSx * TilemapSy;
    RedrawTilemap;
    fisBarDragged := true;
  end;
end;

procedure TfmMainDialog.pbTilemapSizeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (fisBarDragged) then
  begin
    TilemapSx := (X shr 4) + 1;
    if X < 0 then
      TilemapSx := 1;
    if TilemapSx > 32 then
      TilemapSx := 32;
    pbTilemapSize.Position := TilemapSx;
    TilemapSS := TilemapSx * TilemapSy;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.pbTilemapSizeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fisBarDragged := False;
end;

procedure TfmMainDialog.pmnPatternsGotoClick(Sender: TObject);
var
  value: string;
begin
  value := inputbox('Input Offset', 'Please type new Patterns starting Offset', '');
  if(value <> '') then
  begin
    try
      PatternsOffset := StrToInt(value);
      if PatternsOffset < 0 then
        PatternsOffset := 0;
      if PatternsOffset >= fNESFile.CHRSize then
        PatternsOffset := fNESFile.CHRSize - 1;
      RedrawPatterns;
    except
      on Exception : EConvertError do
      ShowMessage(Exception.Message);
    end;
  end;
end;

procedure TfmMainDialog.pmnTilesGotoClick(Sender: TObject);
var
  value: string;
begin
  value := inputbox('Input Offset', 'Please type new Tiles starting Offset', '');
  if(value <> '') then
  begin
    try
      TilemapOffset := StrToInt(value);
      if TilemapOffset < 0 then
        TilemapOffset := 0;
      if TilemapOffset >= fNESFile.PRGSize then
        TilemapOffset := fNESFile.PRGSize - 1;
      RedrawTilemap;
    except
      on Exception : EConvertError do
      ShowMessage(Exception.Message);
    end;
  end;
end;

procedure TfmMainDialog.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  XX, Sx: Integer;
begin
  if fisNESLoaded and (Button = mbLeft) then
  begin
    XX := X;
    dec(X, TILEMAP_LEFT);
    if X < 0 then
      X := 0;
    X := X shr 4;
    dec(Y, TILEMAP_TOP);
    if Y < 0 then
      Y := 0;
    Y := Y shr 4;

    Sx := TilemapSx;
    if TilemapSx >= 32 then
      Sx := 32;

    if (X >= 0) and (X < Sx) and (Y >= 0) and (Y < TilemapSy) then
    begin
      X := X shl 4;
      Y := Y shl 4;
      fisSelDragged := true;
      fXOrigin := X;
      fYOrigin := Y;
      fSelection.Left := fXOrigin;
      fSelection.Right := fXOrigin;
      fSelection.Top := fYOrigin;
      fSelection.Bottom := fYOrigin;
      RedrawTilemap;
    end;

    dec(XX, PATTERNS_LEFT);
    if XX >= 0 then
    begin
      XX := XX shr 4;

      if (XX >= 0) and (XX < 16) and (Y >= 0) and (Y < 16) then
      begin
        fisTileDragged := true;
        case DrawMode of
          DRAW_NORMAL:
            fDraggedTile := Y shl 4 + XX;
          DRAW_VERTICAL:
            fDraggedTile := XX shl 4 + Y;
          DRAW_8X16:
            fDraggedTile := (XX shl 1) + (Y mod 2) +
              (Y shr 1) shl 5;
        end;
        sbMain.Panels[0].Text := 'Dragged Tile: ' +
          IntToHex(fDraggedTile, 2);
      end;
    end;
  end;
end;

procedure TfmMainDialog.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  CurPtr: Pointer;
  XX, Sx: Integer;
begin
  if fisNESLoaded then
  begin
    dec(Y, TILEMAP_TOP);
    if Y < 0 then
      Y := 0;
    Y := Y shr 4;
    if Y > TilemapSy then
      Y := TilemapSy;

    XX := X;
    dec(XX, PATTERNS_LEFT);
    if XX < 0 then
      XX := 0;
    XX := XX shr 4;
    if XX > 15 then
      XX := 15;

    dec(X, TILEMAP_LEFT);
    if X < 0 then
      X := 0;
    X := X shr 4;

    Sx := TilemapSx;
    if TilemapSx >= 32 then
      Sx := 32;

    if ((X < Sx) and (Y < TilemapSy)) then
    begin
      if (TilemapOffset + TilemapSx * Y + X) < fNESFile.PRGSize then
      begin
        CurPtr := fNESFile.PRGData;
        inc(Longint(CurPtr), TilemapOffset);
        inc(Longint(CurPtr), TilemapSx * Y + X);
        fCurTile := Byte(CurPtr^);
        RedrawPatterns;
      end;
    end
    else if ((XX < 16) and (Y < 16)) then
    begin
      case DrawMode of
        DRAW_NORMAL:
          fCurTile := (Y shl 4) + XX;
        DRAW_8X16:
          fCurTile := (XX shl 1) + (Y mod 2) + (Y shr 1) shl 5;
        DRAW_VERTICAL:
          fCurTile := (XX shl 4) + Y;
      end;
      RedrawPatterns;
    end;

    if fisSelDragged then
    begin
      X := X shl 4;
      Y := Y shl 4;
      if X > fXOrigin then
      begin
        fSelection.Left := fXOrigin;
        fSelection.Right := X;
      end
      else
      begin
        fSelection.Left := X;
        fSelection.Right := fXOrigin;
      end;
      if Y > fYOrigin then
      begin
        fSelection.Top := fYOrigin;
        fSelection.Bottom := Y;
      end
      else
      begin
        fSelection.Top := Y;
        fSelection.Bottom := fYOrigin;
      end;
      RedrawTilemap;
    end;
  end;
end;

procedure TfmMainDialog.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  CurPtr: Pointer;
  Sx: Integer;
begin
  if fisNESLoaded then
  begin
    fisSelDragged := False;

    if fisTileDragged then
    begin
      fisTileDragged := False;
      dec(X, TILEMAP_LEFT);
      if X < 0 then
        X := 0;
      X := X shr 4;
      dec(Y, TILEMAP_TOP);
      if Y < 0 then
        Y := 0;
      Y := Y shr 4;
      sbMain.Panels[0].Text := '';
      Sx := TilemapSx;
      if TilemapSx >= 32 then
        Sx := 32;
      if (X >= 0) and (X < Sx) and (Y >= 0) and (Y <= TilemapSy)
      then
      begin
        CurPtr := fNESFile.PRGData;
        inc(Longint(CurPtr), TilemapOffset);
        inc(Longint(CurPtr), TilemapSx * Y + X);
        Byte(CurPtr^) := fDraggedTile;
        fisTilemapModified := true;
        mnSaveTilemap.Enabled := true;
        mnSaveNES.Enabled := true;
        sbMain.Panels[1].Text := 'Tilemap modified';
      end;
    end;

    if (fSelection.Left = fSelection.Right) or
      (fSelection.Top = fSelection.Bottom) then
    begin
      fSelection.Left := 0;
      fSelection.Top := 0;
      fSelection.Bottom := TilemapSy * 16;;
      fSelection.Right := TilemapSx * 16;
    end;
    RedrawTilemap;
  end;
end;

procedure TfmMainDialog.cbDrawPatternsGridClick(Sender: TObject);
begin
  cbDrawPatternsGrid.Checked := not cbDrawPatternsGrid.Checked;
  RedrawPatterns;
end;

procedure TfmMainDialog.cbDrawTilemapGridClick(Sender: TObject);
begin
  cbDrawTilemapGrid.Checked := not cbDrawTilemapGrid.Checked;
  RedrawTilemap;
end;

procedure TfmMainDialog.cbDrawUsedTilesClick(Sender: TObject);
begin
  cbDrawUsedTiles.Checked := not cbDrawUsedTiles.Checked;
  RedrawPatterns;
end;

procedure TfmMainDialog.mnSaveTilemapClick(Sender: TObject);
var
  Error: Integer;
begin
  fisTilemapModified := False;
  with sdSave as TSaveDialog do
  begin
    InitialDir := ExtractFileDir(odOpen.Filename);
    Filename := ExtractFileName(odOpen.Filename);
    Filename := Copy(Filename, 1, Pos('.', Filename) - 1) + '.prg';
    if Execute then
    begin
      Error := PRGFileSave(Filename, fNESFile);
      if Error <> 0 then
        Application.MessageBox
          (PChar('Cannot Save PRG file!'#13#10'Error: ' +
          IntToStr(Error)), 'Error!', 0);
    end;
    mnSaveTilemap.Enabled := False;
    mnSaveNES.Enabled := False;
  end;
end;

procedure TfmMainDialog.mnSaveNESClick(Sender: TObject);
var
  Error: Integer;
begin
  fisTilemapModified := False;
  with sdSave as TSaveDialog do
  begin
    InitialDir := ExtractFileDir(odOpen.Filename);
    Filename := ExtractFileName(odOpen.Filename);
    if Execute then
    begin
      Error := NESFileSave(Filename, fNESFile);
      if Error <> 0 then
        Application.MessageBox
          (PChar('Cannot Save NES file!'#13#10'Error: ' +
          IntToStr(Error)), 'Error!', 0);
    end;
    mnSaveTilemap.Enabled := False;
    mnSaveNES.Enabled := False;
  end;
end;

procedure TfmMainDialog.DrawModeUpdate;
begin
  mnVerticalDraw.Checked := False;
  mnNormalDraw.Checked := False;
  mn8x16Draw.Checked := False;
  case DrawMode of
    DRAW_NORMAL:
      mnNormalDraw.Checked := True;
    DRAW_VERTICAL:
      mnVerticalDraw.Checked := True;
    DRAW_8X16:
      mn8x16Draw.Checked := True;
  end;
  RedrawPatterns;
end;

procedure TfmMainDialog.mnVerticalDrawClick(Sender: TObject);
begin
  DrawMode := DRAW_VERTICAL;
  DrawModeUpdate;
end;

procedure TfmMainDialog.mnNormalDrawClick(Sender: TObject);
begin
  DrawMode := DRAW_NORMAL;
  DrawModeUpdate;
end;

procedure TfmMainDialog.mn8x16DrawClick(Sender: TObject);
begin
  DrawMode := DRAW_8X16;
  DrawModeUpdate;
end;

procedure TfmMainDialog.TileFormatUpdate;
begin
  mnNESTiles.Checked := False;
  mnGBTiles.Checked := False;
  mn1BPPTiles.Checked := False;
  mnGENTiles.Checked := False;
  case TileFormat of
    TILE_1BPP:
      mn1BPPTiles.Checked := True;
    TILE_NES:
      mnNESTiles.Checked := True;
    TILE_GB:
      mnGBTiles.Checked := True;
    TILE_GEN:
      mnGENTiles.Checked := True;
  end;
  RedrawPatterns;
  DefPalInit;
  RedrawPalette;
end;

procedure TfmMainDialog.mn1BPPTilesClick(Sender: TObject);
begin
  TileFormat := TILE_1BPP;
  PatternMul := 1;
  TileFormatUpdate;
end;

procedure TfmMainDialog.mnNESTilesClick(Sender: TObject);
begin
  TileFormat := TILE_NES;
  PatternMul := 2;
  TileFormatUpdate;
end;

procedure TfmMainDialog.mnGBTilesClick(Sender: TObject);
begin
  TileFormat := TILE_GB;
  PatternMul := 2;
  TileFormatUpdate;
end;

procedure TfmMainDialog.mnGENTilesClick(Sender: TObject);
begin
  TileFormat := TILE_GEN;
  PatternMul := 4;
  TileFormatUpdate;
end;

procedure TfmMainDialog.mnLoadPatternsClick(Sender: TObject);
begin
  with odOpen as TOpenDialog do
  begin
    Filter := 'All Files|*.*';
    if Execute then
    begin
      if PatternsRead(Filename, fNESFile) <> 0 then
      begin
        Application.MessageBox('Error Opening File', 'Error!', 0);
        Close;
      end;
      PatternsOffset := 0;
      RedrawPatterns;
      fPatternName := Filename;
      SetApplicationTitle;
    end;
  end;
end;


procedure TfmMainDialog.FormActivate(Sender: TObject);
begin
  if ParamCount = 1 then
  begin
    if NESFileRead(ParamStr(1), fNESFile) <> 0 then
      Application.MessageBox('Error Opening File', 'Error!', 0);
      LoadInit;
      fTileName := ParamStr(1);
      fPatternName := ParamStr(1);
      SetApplicationTitle;
  end;
end;

end.
