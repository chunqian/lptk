{ wgcustomgrid.pas: simple grid
  File maintainer: nvitya@freemail.hu

  History: }
// $Log: wgcustomgrid.pas,v $
// Revision 1.6  2004/04/24 13:21:24  nvitya
// flicker corrections
//
// Revision 1.5  2003/12/20 15:13:01  aegluke
// wgFileGrid-Changes
//
// Revision 1.4  2003/12/11 11:58:17  aegluke
// Scrollbar-Changes
//
// Revision 1.3  2003/12/10 19:11:08  aegluke
// Design and Visibility-Changes
//

unit wgcustomgrid;

{$ifdef FPC}
{$mode OBJFPC}{$H+}
{$endif}

interface

uses
  Classes, SysUtils, schar16, gfxbase, messagequeue, gfxwidget, wgscrollbar, wggrid;
  
type
  TGridColumn = class
  public
    Width : integer;
    Title : string16;
    Alignment : TAlignment;
    
    constructor Create;
  end;

  TwgCustomGrid = class(TwgGrid)
  private
    function GetColumns(index : integer): TGridColumn;
  protected
    FRowCount : integer;
    FColumns : TList;
    
    function GetColumnCount : integer; override;
    procedure SetColumnCount(value : integer);

    function GetRowCount : integer; override;
    procedure SetRowCount(value : integer);

    function GetColumnWidth(col : integer) : TGfxCoord; override;
    procedure SetColumnWidth(col : integer; cwidth : TgfxCoord); override;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    property RowCount : integer read GetRowCount write SetRowCount;

    property ColumnCount : integer read GetColumnCount write SetColumnCount;
    
    procedure DrawHeader(col : integer; rect : TGfxRect; flags : integer); override;
    
    function AddColumn(ATitle : string16; Awidth : integer) : TGridColumn;
    function AddColumn8(ATitle : string8; Awidth : integer) : TGridColumn;

    property Columns[index : integer] : TGridColumn read GetColumns;

  end;

implementation

{ TwgCustomGrid }

function TwgCustomGrid.GetColumns(index : integer): TGridColumn;
begin
  if (Index < 0) or (Index > FColumns.Count - 1)
    then result := nil
    else Result := TGridColumn(FColumns[index]);
end;

function TwgCustomGrid.GetColumnWidth(col: integer): TGfxCoord;
begin
  if (col > 0) and (col <= ColumnCount) then
    Result := TGridColumn(FColumns[col-1]).Width
  else
    result := 10;
end;

procedure TwgCustomGrid.SetColumnWidth(col: integer; cwidth: TgfxCoord);
begin
  with TGridColumn(FColumns[col-1]) do
  begin
    if width <> cwidth then
    begin
      width := cwidth;
      if width < 1 then width := 1;
      UpdateScrollBar;
      self.repaint;
    end;
  end;
end;

constructor TwgCustomGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColumns := TList.Create;
  FRowCount := 5;
end;

destructor TwgCustomGrid.Destroy;
begin
  SetColumnCount(0);
  FColumns.Free;
  inherited Destroy;
end;

function TwgCustomGrid.GetRowCount: integer;
begin
  Result := FRowCount;
end;

procedure TwgCustomGrid.SetRowCount(value: integer);
begin
  FRowCount := value;
  if FFocusRow > FRowCount then
  begin
    FFocusRow := FRowCount;
    FollowFocus;
  end;
  if FWinHandle > 0 then Update;
end;

function TwgCustomGrid.GetColumnCount: integer;
begin
  Result := FColumns.Count;
end;

procedure TwgCustomGrid.SetColumnCount(value: integer);
var
  n : integer;
begin
  n := FColumns.Count;
  if (n = value) or (value < 0) then Exit;
  
  if n < value then
  begin
    // adding columns
    while n < value do
    begin
      AddColumn('',50);
      inc(n);
    end;
  end
  else
  begin
    while n > value do
    begin
      TGridColumn(FColumns.Items[n-1]).Free;
      dec(n);
      FColumns.Count := n;
    end;
  end;
  if FWinHandle > 0 then Update;
end;

procedure TwgCustomGrid.DrawHeader(col: integer; rect: TGfxRect; flags: integer);
var
  s : string16;
  x : integer;
begin
  s := TGridColumn(FColumns[col-1]).Title;
  x := (rect.width div 2) - (FHeaderFont.TextWidth16(s) div 2);
  if x < 1 then x := 1;
  canvas.DrawString16(rect.left + x, rect.top+1, s);
end;

function TwgCustomGrid.AddColumn(ATitle: string16; Awidth: integer): TGridColumn;
begin
  result := TGridColumn.Create;
  result.Title := ATitle;
  result.Width := awidth;
  FColumns.Add(result);
  if FWinHandle > 0 then Update;
end;

function TwgCustomGrid.AddColumn8(ATitle: string8; Awidth: integer): TGridColumn;
begin
  result := AddColumn(u8(ATitle),awidth);
end;

{ TGridColumn }

constructor TGridColumn.Create;
begin
  Width := 30;
  Title := '';
  Alignment := alLeft;
end;

end.

