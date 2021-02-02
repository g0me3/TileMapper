program TileMapper;

uses
  Forms,
  fmMain in 'fmMain.pas' {fmMainDialog} ,
  libNESTiles in 'libNESTiles.pas';

{$R *.RES}

begin
  Application.Title := 'Tile Mapper';
  Application.Initialize;
  Application.CreateForm(TfmMainDialog, fmMainDialog);
  Application.Run;
end.
