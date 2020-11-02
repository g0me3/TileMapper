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
    mnLoaddFromNES: TMenuItem;
    odOpenFile: TOpenDialog;
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
    sdSaveTilemap: TSaveDialog;
    mnVerticalDraw: TMenuItem;
    mnSaveNES: TMenuItem;
    mnDecodeView: TMenuItem;
    mnPLain: TMenuItem;
    N4: TMenuItem;
    mnKirbyDecode: TMenuItem;
    mnNormalDraw: TMenuItem;
    mn8x16Draw: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnExitClick(Sender: TObject);
    procedure mnLoaddFromNESClick(Sender: TObject);
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
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
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
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure mn8x16DrawClick(Sender: TObject);
    procedure mnNormalDrawClick(Sender: TObject);
  private
    { Private declarations }
    fPatterns: TBitmap;
    PatternsOffset: Longint;
    fTileMap: TBitmap;
    TilemapOffset: Longint;
    TilemapSx,
    TilemapSy,
    TilemapSS: Integer;
    fNESFile: TNESFile;
    fisNESLoaded,
    fisBarDragged,
    fisSelDragged,
    fisTilemapChanged,
    fisTileDragged,
    fisTilemapModified: Boolean;
    fSelection: TRect;
    fDraggedTile: Integer;
    fCurTile: Integer;
    fXOrigin,
    fYOrigin: Integer;
    procedure RedrawTilemap;
    procedure RedrawPatterns;
  public
    { Public declarations }
  end;

const
    TILEMAP_LEFT = 2;
    TILEMAP_TOP = 16;
    PATTERNS_LEFT = 543;
    PATTERNS_TOP = TILEMAP_TOP;
    TILEEDIT_LEFT = PATTERNS_LEFT;
    TILEEDIT_TOP = PATTERNS_TOP + 256+32;

var
    fmMainDialog: TfmMainDialog;

implementation

{$R *.DFM}

procedure TfmMainDialog.RedrawTilemap;
begin
    DrawTilemap(fTilemap,fNESFile,PatternsOffset,TilemapOffset,TilemapSx,TilemapSy);

    if cbDrawTilemapGrid.Checked then
       DrawGrid(fTilemap,TilemapSx,TilemapSy);

    DrawSelection(fTilemap,fSelection);

    pnTilemap.Caption:= IntToHex(TilemapOffset,6)+
                        ' \ '+
                        IntToHex(fNESFile.PRGSize,6)+
                        ' PRG BANK [8K:'+
                        IntToHex(TilemapOffset shr 13,3)+
                        ', 16K:'+
                        IntToHex(TilemapOffset shr 14,2)+
                        ', 32K:'+
                        IntToHex(TilemapOffset shr 15,2)+
                        '] SELECTION ('+
                        IntToHex(fSelection.Left shr 4,2)+
                        ','+
                        IntToHex(fSelection.Top shr 4,2)+
                        ','+
                        IntToHex(fSelection.Right shr 4-1,2)+
                        ','+
                        IntToHex(fSelection.Bottom shr 4-1,2)+
                        ')';
    pnTilemap.Repaint;
    Canvas.Draw(TILEMAP_LEFT,TILEMAP_TOP,fTilemap);

    if fisTilemapChanged then RedrawPatterns;   // pattern used grid may change
end;

procedure TfmMainDialog.RedrawPatterns;
var
    fCurTileRect: TRect;
begin
    fisTilemapChanged:=False;
    RedrawTilemap;                              // redraw because it change for sure

    DrawPatterns(fPatterns,fNESFile,PatternsOffset);

    if cbDrawPatternsGrid.Checked then
       DrawGrid(fPatterns,16,16);

    if cbDrawUsedTiles.Checked then
       DrawUsedTiles(fPatterns,TilemapOffset,TilemapSx,fSelection,fNESFile);

    case DrawMode of
     DRAW_NORMAL:
      begin
          fCurTileRect.Left:=(fCurTile mod 16) shl 4;
          fCurTileRect.Top:=(fCurTile shr 4) shl 4;
      end;
     DRAW_VERTICAL:
      begin
          fCurTileRect.Left:=(fCurTile shr 4) shl 4;
          fCurTileRect.Top:=(fCurTile mod 16) shl 4;
      end;
     DRAW_8X16: // DONE
      begin
          fCurTileRect.Left:=((fCurTile mod 32) shr 1) shl 4;
          fCurTileRect.Top:=((fCurTile mod 2) shl 4) + ((fCurTile shr 5) shl 5);
      end;
    end;
    fCurTileRect.Right:=fCurTileRect.Left+17;
    fCurTileRect.Bottom:=fCurTileRect.Top+17;
    DrawSelection(fPatterns,fCurTileRect);

    pnPatterns.Caption:=IntToHex(PatternsOffset,6)+
                        '\'+
                        IntToHex(fNESFile.CHRSize,6)+
                        ' CHR BANK [1K:'+
                        IntToHex(PatternsOffset shr 10,3)+
                        ', 8K:'+
                        IntToHex(PatternsOffset shr 13,2)+
                        '] '+
                        IntToHex(fCurTile,2);
    pnPatterns.Repaint;
    Canvas.Draw(PATTERNS_LEFT,PATTERNS_TOP,fPatterns);
end;

procedure TfmMainDialog.FormCreate(Sender: TObject);
begin
    fPatterns:= TBitmap.Create;
    with fPatterns as TBitmap do
     begin
         Height:=256;
         Width:=256;
         PixelFormat:=pf32Bit;
     end;
    TilemapSx:=32;
    TilemapSy:=33;
    TilemapSS:=TilemapSx*TilemapSy;
    fTilemap:= TBitmap.Create;
    with fTilemap as TBitmap do
     begin
         Height:=TilemapSy*16;
         Width:=TilemapSx*16;
         PixelFormat:=pf32Bit;
     end;
    fSelection.Left:=0;
    fSelection.Top:=0;
    fSelection.Bottom:=TilemapSy*16;
    fSelection.Right:=TilemapSx*16;
    fisTilemapChanged:=False;
    fisTilemapModified:=False;
    fCurTile:=0;
    mnNormalDraw.Checked:=true;
    mnVerticalDraw.Checked:=false;
    mn8x16Draw.Checked:=false;
    RedrawTilemap;
    RedrawPatterns;
end;

procedure TfmMainDialog.FormDestroy(Sender: TObject);
begin
    fPatterns.Free;
    fTilemap.Free;
    NESFileFree(fNESFile);
    fisNESLoaded:=False;
end;

procedure TfmMainDialog.mnExitClick(Sender: TObject);
begin
    Close;
end;

procedure TfmMainDialog.mnLoaddFromNESClick(Sender: TObject);
begin
    with odOpenFile as TOpenDialog do
     begin
         Filter:='NES File|*.nes';
         if Execute then
          begin
              NESFileFree(fNESFile);
              fisNESLoaded:=False;
              if NESFileRead(Filename, fNESFile)<>0 then
               begin
                   Application.MessageBox('Error Opening File','Error!',0);
                   Close;
               end;
              fisNESLoaded:=True;
              mnLoadTilemap.Enabled:=True;
              mnLoadPatterns.Enabled:=True;
              mnDecodeView.Enabled:=True;
              fisTilemapModified:=False;
              sbMain.Panels[1].Text:='';
              TilemapOffset:=0;
              PatternsOffset:=0;
              RedrawPatterns;
              RedrawTilemap;
          end;
     end;
end;

procedure TfmMainDialog.mnLoadTilemapClick(Sender: TObject);
begin
    with odOpenFile as TOpenDialog do
     begin
         Filter:='All Files|*.*';
         if Execute then
          begin
              if TilemapRead(Filename, fNESFile)<>0 then
               begin
                   Application.MessageBox('Error Opening File','Error!',0);
                   Close;
               end;
              TilemapOffset:=0;
              fisTilemapChanged:=True;
              RedrawTilemap;
          end;
     end;
end;

procedure TfmMainDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Shift = [ssShift] then
     begin
         if Key=45 then spbPatternsUpClick(Sender);
         if Key=46 then spbPatternsDownClick(Sender);
         if Key=37 then spbPatternsTileUpClick(Sender);
         if Key=39 then spbPatternsTileDownClick(Sender);
         if Key=38 then spbPatternsLineUpClick(Sender);
         if Key=40 then spbPatternsLineDownClick(Sender);
         if Key=33 then spbPatternsPageUpClick(Sender);
         if Key=34 then spbPatternsPageDownClick(Sender);
         if Key=36 then spbPatternsHomeClick(Sender);
         if Key=35 then spbPatternsEndClick(Sender);
     end
    else
     begin
         if Key=37 then spbTilemapUpClick(Sender);
         if Key=39 then spbTilemapDownClick(Sender);
         if Key=38 then spbTilemapLineUpClick(Sender);
         if Key=40 then spbTilemapLineDownClick(Sender);
         if Key=33 then spbTilemapPageUpClick(Sender);
         if Key=34 then spbTilemapPageDownClick(Sender);
         if Key=36 then spbTilemapHomeClick(Sender);
         if Key=35 then spbTilemapEndClick(Sender);
         if Key=188 then
          begin
              if TilemapSx>1 then dec(TilemapSx);
              pbTilemapSize.Position:=TilemapSx;
              dec(TilemapSS,TilemapSy);
              fisTilemapChanged:=True;
              RedrawTilemap;
              pbTilemapSize.Repaint;
          end;
         if Key=190 then
          begin
              if TilemapSx<32 then inc(TilemapSx);
              pbTilemapSize.Position:=TilemapSx;
              inc(TilemapSS,TilemapSy);
              fisTilemapChanged:=True;
              RedrawTilemap;
              pbTilemapSize.Repaint;
          end;
     end;
end;

procedure TfmMainDialog.FormPaint(Sender: TObject);
begin
    Canvas.Draw(PATTERNS_LEFT,PATTERNS_TOP,fPatterns);
    Canvas.Draw(TILEMAP_LEFT,TILEMAP_TOP,fTilemap);
end;

procedure TfmMainDialog.spbTilemapUpClick(Sender: TObject);
begin
    if TilemapOffset>0 then
     begin
         Dec(TilemapOffset);
         fisTilemapChanged:=True;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.spbTilemapDownClick(Sender: TObject);
begin
    if (TilemapOffset+TilemapSS)<fNESFile.PRGSize then
     begin
         Inc(TilemapOffset);
         fisTilemapChanged:=True;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.spbTilemapLineUpClick(Sender: TObject);
begin
    if TilemapOffset>=TilemapSx then
     begin
         Dec(TilemapOffset,TilemapSx);
         fisTilemapChanged:=True;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.spbTilemapLineDownClick(Sender: TObject);
begin
    if (TilemapOffset+TilemapSS+TilemapSx)<fNESFile.PRGSize then
     begin
         Inc(TilemapOffset,TilemapSx);
         fisTilemapChanged:=True;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.spbTilemapPageUpClick(Sender: TObject);
begin
    if TilemapOffset>=TilemapSS then
     begin
         Dec(TilemapOffset,TilemapSS);
         fisTilemapChanged:=True;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.spbTilemapPageDownClick(Sender: TObject);
begin
    if (TilemapOffset+TilemapSS+TilemapSS)<fNESFile.PRGSize then
     begin
         Inc(TilemapOffset,TilemapSS);
         fisTilemapChanged:=True;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.spbTilemapHomeClick(Sender: TObject);
begin
    TilemapOffset:=0;
    fisTilemapChanged:=True;
    RedrawTilemap;
end;

procedure TfmMainDialog.spbTilemapEndClick(Sender: TObject);
begin
    TilemapOffset:=fNESFile.PRGSize-TilemapSS;
    fisTilemapChanged:=True;
    RedrawTilemap;
end;

procedure TfmMainDialog.spbPatternsUpClick(Sender: TObject);
begin
    if PatternsOffset>0 then
     begin
         Dec(PatternsOffset);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsDownClick(Sender: TObject);
begin
    if (PatternsOffset+4096)<=fNESFile.CHRSize then
     begin
         Inc(PatternsOffset);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsTileUpClick(Sender: TObject);
begin
    if PatternsOffset>=16 then
     begin
         Dec(PatternsOffset,16);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsTileDownClick(Sender: TObject);
begin
    if (PatternsOffset+4112)<=fNESFile.CHRSize then
     begin
         Inc(PatternsOffset,16);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsLineUpClick(Sender: TObject);
begin
    if PatternsOffset>=256 then
     begin
         Dec(PatternsOffset,256);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsLineDownClick(Sender: TObject);
begin
    if (PatternsOffset+4352)<=fNESFile.CHRSize then
     begin
         Inc(PatternsOffset,256);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsPageUpClick(Sender: TObject);
begin
    if PatternsOffset>=4095 then
     begin
         Dec(PatternsOffset,4096);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsPageDownClick(Sender: TObject);
begin
    if (PatternsOffset+8192)<=fNESFile.CHRSize then
     begin
         Inc(PatternsOffset,4096);
         RedrawPatterns;
     end;
end;

procedure TfmMainDialog.spbPatternsHomeClick(Sender: TObject);
begin
    PatternsOffset:=0;
    RedrawPatterns;
end;

procedure TfmMainDialog.spbPatternsEndClick(Sender: TObject);
begin
    PatternsOffset:=fNESFile.CHRSize-4096;
    RedrawPatterns;
end;

procedure TfmMainDialog.pbTilemapSizeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if (Button=mbLeft) then
     begin
         TilemapSx:=(X shr 4)+1;
         if X<0 then TilemapSx:=1;
         if TilemapSx>32 then TilemapSx:=32;
         pbTilemapSize.Position:=TilemapSx;
         TilemapSS:=TilemapSx*TilemapSy;
         RedrawTilemap;
         fisBarDragged:=True;
     end;
end;

procedure TfmMainDialog.pbTilemapSizeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
    if (fisBarDragged) then
     begin
         TilemapSx:=(X shr 4)+1;
         if X<0 then TilemapSx:=1;
         if TilemapSx>32 then TilemapSx:=32;
         pbTilemapSize.Position:=TilemapSx;
         TilemapSS:=TilemapSx*TilemapSy;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.pbTilemapSizeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    fisBarDragged:=False;
end;

procedure TfmMainDialog.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    XX: Integer;
begin
    if fisNESLoaded and (Button=mbLeft) then
     begin
         XX:=X;
         Dec(X,TILEMAP_LEFT);
         if X<0 then X:=0;
         X:=X shr 4;
         Dec(Y,TILEMAP_TOP);
         if Y<0 then Y:=0;
         Y:=Y shr 4;
         if (X>=0) and (X<=TilemapSx) and
            (Y>=0) and (Y<=TilemapSy) then
          begin
              X:=X shl 4;
              Y:=Y shl 4;
              fisSelDragged:=True;
              fXOrigin:=X;
              fYOrigin:=Y;
              fSelection.Left:=fXOrigin;
              fSelection.Right:=fXOrigin;
              fSelection.Top:=fYOrigin;
              fSelection.Bottom:=fYOrigin;
              RedrawTilemap;
          end;

         Dec(XX,PATTERNS_LEFT);
         if XX>=0 then
          begin
              XX:=XX shr 4;

              if (XX>=0) and (XX<16) and
                 (Y>=0) and (Y<16) then
               begin
                   fisTileDragged:=True;
                   case DrawMode of
                    DRAW_NORMAL:   fDraggedTile:=Y shl 4 + XX;
                    DRAW_VERTICAL: fDraggedTile:=XX shl 4 + Y;
                    DRAW_8X16:     fDraggedTile:=(XX shl 1)+(Y mod 2)+(Y shr 1) shl 5;
                   end;
                   sbMain.Panels[0].Text:='Dragged Tile: '+IntToHex(fDraggedTile,2);
               end;
          end;
      end;
end;


procedure TfmMainDialog.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
    CurPtr: Pointer;
    XX: Integer;
begin
    if fisNESLoaded then
     begin
         Dec(Y,TILEMAP_TOP);
         if Y<0 then Y:=0;
         Y:=Y shr 4;
         if Y>TilemapSy then Y:=TilemapSy;

         XX:=X;
         Dec(XX,PATTERNS_LEFT);
         if XX<0 then XX:=0;
         XX:=XX shr 4;
         if XX>15 then XX:=15;

         Dec(X,TILEMAP_LEFT);
         if X<0 then X:=0;
         X:=X shr 4;
         if X>TilemapSx then X:=TilemapSx;

         if ((X<TilemapSx) and (Y<TilemapSy)) then
          begin
              if (TilemapOffset+TilemapSx*Y+X)<fNESFile.PRGSize then
               begin
                   CurPtr:=fNESFile.PRGData;
                   Inc(Longint(CurPtr),TilemapOffset);
                   Inc(Longint(CurPtr),TilemapSx*Y+X);
                   fCurTile:=Byte(CurPtr^);
                   RedrawPatterns;
               end;
          end
         else
         if ((XX<16) and (Y<16)) then
          begin
              case DrawMode of
               DRAW_NORMAL:   fCurTile:=(Y shl 4)+XX;
               DRAW_8X16:     fCurTile:=(XX shl 1)+(Y mod 2)+(Y shr 1) shl 5; // DONE
               DRAW_VERTICAL: fCurTile:=(XX shl 4)+Y;
              end;
              RedrawPatterns;
          end;

         if fisSelDragged then
          begin
              X:=X shl 4;
              Y:=Y shl 4;
              if X>fXOrigin then
               begin
                   fSelection.Left:=fXOrigin;
                   fSelection.Right:=X;
               end
              else
               begin
                   fSelection.Left:=X;
                   fSelection.Right:=fXOrigin;
               end;
              if Y>fYOrigin then
               begin
                   fSelection.Top:=fYOrigin;
                   fSelection.Bottom:=Y;
               end
              else
               begin
                   fSelection.Top:=Y;
                   fSelection.Bottom:=fYOrigin;
               end;
              RedrawTilemap;
          end;
     end;
end;

procedure TfmMainDialog.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    CurPtr: Pointer;
begin
    if fisNESLoaded then
     begin
         fisSelDragged:=False;

         if fisTileDragged then
          begin
              fisTileDragged:=false;
              Dec(X,TILEMAP_LEFT);
              if X<0 then X:=0;
              X:=X shr 4;
              Dec(Y,TILEMAP_TOP);
              if Y<0 then Y:=0;
              Y:=Y shr 4;
              sbMain.Panels[0].Text:='';
              if (X>=0) and (X<=TilemapSx) and
                 (Y>=0) and (Y<=TilemapSy) then
               begin
                   CurPtr:=fNESFile.PRGData;
                   Inc(Longint(CurPtr),TilemapOffset);
                   Inc(Longint(CurPtr),TilemapSx*Y+X);
                   Byte(CurPtr^):=fDraggedTile;
                   fisTilemapMOdified:=True;
                   mnSaveTilemap.Enabled:=True;
                   mnSaveNES.Enabled:=True;
                   sbMain.Panels[1].Text:='Tilemap modified';
               end;
          end;

         if (fSelection.Left=fSelection.Right) or
            (fSelection.Top=fSelection.Bottom) then
          begin
              fSelection.Left:=0;
              fSelection.Top:=0;
              fSelection.Bottom:=TilemapSy*16;;
              fSelection.Right:=TilemapSx*16;
          end;
         RedrawTilemap;
     end;
end;

procedure TfmMainDialog.cbDrawPatternsGridClick(Sender: TObject);
begin
    cbDrawPatternsGrid.Checked:=not cbDrawPatternsGrid.Checked;
    RedrawPatterns;
end;

procedure TfmMainDialog.cbDrawTilemapGridClick(Sender: TObject);
begin
    cbDrawTilemapGrid.Checked:=not cbDrawTilemapGrid.Checked;
    RedrawTilemap;
end;

procedure TfmMainDialog.cbDrawUsedTilesClick(Sender: TObject);
begin
    cbDrawUsedTiles.Checked:=not cbDrawUsedTiles.Checked;
    RedrawPatterns;
end;

procedure TfmMainDialog.mnSaveTilemapClick(Sender: TObject);
var
    Error: Integer;
begin
    fisTilemapModified:=False;
    with sdSaveTilemap as TSaveDialog do
     begin
         InitialDir:=ExtractFileDir(odOpenFile.Filename);
         Filename:=ExtractFileName(odOpenFile.Filename);
         Filename:=Copy(Filename,1,Pos('.',Filename)-1)+'.prg';
         if Execute then
          begin
              Error:=PRGFileSave(Filename,fNESFile);
              if Error<>0 then
                 Application.MessageBox(PChar('Cannot Save PRG file!'#13#10'Error: '+IntToStr(Error)),'Error!',0);
          end;
         mnSaveTilemap.Enabled:=False;
         mnSaveNES.Enabled:=False;
     end;
end;

procedure TfmMainDialog.mnSaveNESClick(Sender: TObject);
var
    Error: Integer;
begin
    fisTilemapModified:=False;
    with sdSaveTilemap as TSaveDialog do
     begin
         InitialDir:=ExtractFileDir(odOpenFile.Filename);
         Filename:=ExtractFileName(odOpenFile.Filename);
         if Execute then
          begin
              Error:=NESFileSave(Filename,fNESFile);
              if Error<>0 then
                 Application.MessageBox(PChar('Cannot Save NES file!'#13#10'Error: '+IntToStr(Error)),'Error!',0);
          end;
         mnSaveTilemap.Enabled:=False;
         mnSaveNES.Enabled:=False;
     end;
end;

procedure TfmMainDialog.mnVerticalDrawClick(Sender: TObject);
begin
    mnVerticalDraw.Checked:=true;
    mn8x16Draw.Checked:=false;
    mnNormalDraw.Checked:=false;
    DrawMode:=1;
    RedrawPatterns;
end;

procedure TfmMainDialog.mn8x16DrawClick(Sender: TObject);
begin
    mnVerticalDraw.Checked:=false;
    mn8x16Draw.Checked:=true;
    mnNormalDraw.Checked:=false;
    DrawMode:=2;
    RedrawPatterns;
end;

procedure TfmMainDialog.mnNormalDrawClick(Sender: TObject);
begin
    mnVerticalDraw.Checked:=false;
    mn8x16Draw.Checked:=false;
    mnNormalDraw.Checked:=true;
    DrawMode:=0;
    RedrawPatterns;
end;

procedure TfmMainDialog.mnLoadPatternsClick(Sender: TObject);
begin
    with odOpenFile as TOpenDialog do
     begin
         Filter:='All Files|*.*';
         if Execute then
          begin
              if PatternsRead(Filename, fNESFile)<>0 then
               begin
                   Application.MessageBox('Error Opening File','Error!',0);
                   Close;
               end;
              PatternsOffset:=0;
              RedrawPatterns;
          end;
     end;
end;

procedure TfmMainDialog.FormActivate(Sender: TObject);
begin
    if ParamCount=1 then
     begin
      if NESFileRead(ParamStr(1), fNESFile)<>0 then
         Application.MessageBox('Error Opening File','Error!',0);
      fisNESLoaded:=True;
      mnLoadTilemap.Enabled:=True;
      mnLoadPatterns.Enabled:=True;
      mnDecodeView.Enabled:=True;
      fisTilemapModified:=False;
      sbMain.Panels[1].Text:='';
      TilemapOffset:=0;
      PatternsOffset:=0;
      RedrawPatterns;
      RedrawTilemap;
     end;
end;

procedure TfmMainDialog.CheckBox1Click(Sender: TObject);
begin
    cbDrawPatternsGrid.Checked:=not cbDrawPatternsGrid.Checked;
    RedrawPatterns;
end;

procedure TfmMainDialog.CheckBox2Click(Sender: TObject);
begin
    cbDrawTilemapGrid.Checked:=not cbDrawTilemapGrid.Checked;
    RedrawTilemap;
end;

procedure TfmMainDialog.CheckBox3Click(Sender: TObject);
begin
    cbDrawUsedTiles.Checked:=not cbDrawUsedTiles.Checked;
    RedrawPatterns;
end;

end.


