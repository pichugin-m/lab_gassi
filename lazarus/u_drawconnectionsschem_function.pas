unit u_drawconnectionsschem_function;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  u_gassi_drawcontrol,
  u_gassi_visualobjects, u_gassi_logicaldraw, u_gassi_const, u_gassi_dxf;

const
  SchemTerminalBlockWidth = 5;
  SchemTerminalBlockHeight = 10;
  SchemTerminalBlockWireHeight = 15;
  SchemTerminalBlockHeaderHeight = 10;
  SchemCableHeight = 200;
  SchemBoxPadding = 5;

  DRAWSCHEM_LAYERNAME_TEXT1       = 'EL_TABLETEXT';
  DRAWSCHEM_LAYERNAME_TEXT2       = 'EL_LABELNAME_TEXT';
  DRAWSCHEM_LAYERNAME_TEXT3       = 'EL_LABELNAME_TEXT';
  DRAWSCHEM_LAYERNAME_TEXT4       = 'EL_WIRETEXT';
  DRAWSCHEM_LAYERNAME_TABLEBORDER = 'EL_ANNOTATION_TABLEBORDER';
  DRAWSCHEM_LAYERNAME_CABLE1      = 'EL_SCHEM_CABLE1';


procedure DoDrawSchemConnections(DrawingControl:TAssiDrawControl);

implementation

procedure DrawSchemTerminalBlock(DrawingControl:TAssiDrawControl; X,Y:Double; AText:String);
var
  tmpEntity:TEntity;
  X2,Y2:Double;
begin
  X2:=x;
  Y2:=y;
  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TABLEBORDER;
  tmpEntity.AddVertex(X2,Y2,0);
  tmpEntity.AddVertex(X2+SchemTerminalBlockWidth,Y2,0);
  tmpEntity.AddVertex(X2+SchemTerminalBlockWidth,Y2+SchemTerminalBlockHeight,0);
  tmpEntity.AddVertex(X2,Y2+SchemTerminalBlockHeight,0);
  tmpEntity.AddVertex(X2,Y2,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //tmpEntity.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

  tmpEntity:=TGraphicText.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TEXT1;
  tmpEntity.AddVertex(X2+1,Y2+1,0);
  TGraphicText(tmpEntity).Align:=gaAttachmentPointTopLeft;
  TGraphicText(tmpEntity).Color:=DrawingControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=DrawingControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(tmpEntity).Rotate:=90;
  TGraphicText(tmpEntity).FontSize:=2.5;
  TGraphicText(tmpEntity).FontStyle:=[];
  TGraphicText(tmpEntity).FontName:='Arial';
  //TGraphicText(tmpEntity).Width:=70;
  //TGraphicText(tmpEntity).Height:=16;
  TGraphicText(tmpEntity).Text:=AText;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;
end;

procedure DrawSchemTerminalBlockWire1(DrawingControl:TAssiDrawControl; X,Y:Double; AText:String);
var
  tmpEntity:TEntity;
  X2,Y2:Double;
begin
  X2:=x+(SchemTerminalBlockWidth/2);
  Y2:=y;
  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_CABLE1;
  tmpEntity.AddVertex(X2,Y2,0);
  tmpEntity.AddVertex(X2,Y2+SchemTerminalBlockWireHeight,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=gaLnWt025;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

  tmpEntity:=TGraphicText.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TEXT4;
  tmpEntity.AddVertex(X2-3.5,Y2+1,0);
  TGraphicText(tmpEntity).Align:=gaAttachmentPointTopLeft;
  TGraphicText(tmpEntity).Color:=DrawingControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=DrawingControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(tmpEntity).Rotate:=90;
  TGraphicText(tmpEntity).FontSize:=2.5;
  TGraphicText(tmpEntity).FontStyle:=[];
  TGraphicText(tmpEntity).FontName:='Arial';
  //TGraphicText(tmpEntity).Width:=70;
  //TGraphicText(tmpEntity).Height:=16;
  TGraphicText(tmpEntity).Text:=AText;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;
end;

procedure DrawSchemTerminalBlockEnd(DrawingControl:TAssiDrawControl; X,Y:Double; ACount:Integer; AText:String);
var
  tmpEntity:TEntity;
  X2,Y2:Double;
begin
  X2:=x;
  Y2:=y+SchemTerminalBlockHeight;
  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TABLEBORDER;
  tmpEntity.AddVertex(X2,Y2,0);
  tmpEntity.AddVertex(X2+SchemTerminalBlockWidth*ACount,Y2,0);
  tmpEntity.AddVertex(X2+SchemTerminalBlockWidth*ACount,Y2+SchemTerminalBlockHeaderHeight,0);
  tmpEntity.AddVertex(X2,Y2+SchemTerminalBlockHeaderHeight,0);
  tmpEntity.AddVertex(X2,Y2,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //tmpEntity.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

  tmpEntity:=TGraphicText.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TEXT1;
  tmpEntity.AddVertex(X2+(SchemTerminalBlockWidth*ACount)/2,Y2+(SchemTerminalBlockHeaderHeight/2),0);
  TGraphicText(tmpEntity).Align:=gaAttachmentPointMiddleCenter;
  TGraphicText(tmpEntity).Color:=DrawingControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=DrawingControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(tmpEntity).Rotate:=0;
  TGraphicText(tmpEntity).FontSize:=2.5;
  TGraphicText(tmpEntity).FontStyle:=[];
  TGraphicText(tmpEntity).FontName:='Arial';
  //TGraphicText(tmpEntity).Width:=70;
  //TGraphicText(tmpEntity).Height:=16;
  TGraphicText(tmpEntity).Text:=AText;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;
end;

procedure DrawSchemTerminalBlockUPBegin(DrawingControl:TAssiDrawControl; X,Y:Double; ACount:Integer);
var
  tmpEntity:TEntity;
  X2,Y2:Double;
  i:integer;
begin

  X2:=X;
  Y2:=Y;
  for i:=1 to ACount do
  begin
    DrawSchemTerminalBlock(DrawingControl,X2,Y2,'123');
    DrawSchemTerminalBlockWire1(DrawingControl,X2,Y2-SchemTerminalBlockWireHeight,IntToStr(i));
    x2:=x2+SchemTerminalBlockWidth;
  end;
  DrawSchemTerminalBlockEnd(DrawingControl,X,Y,ACount,'XT');

  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_CABLE1;
  tmpEntity.AddVertex(X+(SchemTerminalBlockWidth/2),Y2-SchemTerminalBlockWireHeight,0);
  tmpEntity.AddVertex(X-(SchemTerminalBlockWidth/2)+SchemTerminalBlockWidth*ACount,Y2-SchemTerminalBlockWireHeight,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=gaLnWt100;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

end;

procedure DrawSchemTerminalBlockDownBegin(DrawingControl:TAssiDrawControl; X,Y:Double; ACount:Integer);
var
  tmpEntity:TEntity;
  StartX,StartY:Double;
  X2,Y2:Double;
  i:integer;
begin

  X2:=X;
  Y2:=Y-SchemTerminalBlockHeight;
  for i:=1 to ACount do
  begin
    DrawSchemTerminalBlock(DrawingControl,X2,Y2,'123');
    DrawSchemTerminalBlockWire1(DrawingControl,X2,Y2+SchemTerminalBlockHeight,IntToStr(i));
    x2:=x2+SchemTerminalBlockWidth;
  end;
  DrawSchemTerminalBlockEnd(DrawingControl,X,Y2-(SchemTerminalBlockHeaderHeight*2),ACount,'XT');

  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_CABLE1;
  tmpEntity.AddVertex(X+(SchemTerminalBlockWidth/2),Y2+SchemTerminalBlockHeight+SchemTerminalBlockWireHeight,0);
  tmpEntity.AddVertex(X-(SchemTerminalBlockWidth/2)+SchemTerminalBlockWidth*ACount,Y2+SchemTerminalBlockHeight+SchemTerminalBlockWireHeight,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=gaLnWt100;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

end;

procedure DrawSchemCable1(DrawingControl:TAssiDrawControl; X,Y:Double; ACount:Integer; AText:String);
var
  tmpEntity:TEntity;
  X2,Y2:Double;
begin
  X2:=x+(SchemTerminalBlockWidth*ACount)/2;
  Y2:=y-SchemTerminalBlockWireHeight;
  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_CABLE1;
  tmpEntity.AddVertex(X2,Y2,0);
  tmpEntity.AddVertex(X2,Y2-SchemCableHeight,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=gaLnWt040;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

  tmpEntity:=TGraphicText.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TEXT3;
  tmpEntity.AddVertex(X2-1,Y2-(SchemCableHeight/2),0);
  TGraphicText(tmpEntity).Align:=gaAttachmentPointTopLeft;
  TGraphicText(tmpEntity).Color:=DrawingControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=DrawingControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(tmpEntity).Rotate:=90;
  TGraphicText(tmpEntity).FontSize:=2.5;
  TGraphicText(tmpEntity).FontStyle:=[];
  TGraphicText(tmpEntity).FontName:='Arial';
  //TGraphicText(tmpEntity).Width:=70;
  //TGraphicText(tmpEntity).Height:=16;
  TGraphicText(tmpEntity).Text:=AText;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;
end;

procedure DrawSchemBox1Begin(DrawingControl:TAssiDrawControl; var X,Y,BoxX,BoxY:Double);
begin
  BoxX:=X;
  BoxY:=Y-SchemCableHeight-SchemTerminalBlockWireHeight+SchemBoxPadding;
end;

procedure DrawSchemBox1End(DrawingControl:TAssiDrawControl; var StartX,StartY,EndX,EndY:Double; AText:String);
var
  tmpEntity:TEntity;
  X2,Y2:Double;
begin

  EndY:=EndY-SchemBoxPadding*2-SchemTerminalBlockHeaderHeight-SchemTerminalBlockWireHeight-SchemTerminalBlockHeight;
  EndX:=EndX;

  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.AddVertex(StartX,StartY,0);
  tmpEntity.AddVertex(EndX,StartY,0);
  tmpEntity.AddVertex(EndX,EndY,0);
  tmpEntity.AddVertex(StartX,EndY,0);
  tmpEntity.AddVertex(StartX,StartY,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //tmpEntity.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

  tmpEntity:=TGraphicText.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TEXT2;
  tmpEntity.AddVertex(StartX+5,EndY+1,0);
  TGraphicText(tmpEntity).Align:=gaAttachmentPointBottomLeft;
  TGraphicText(tmpEntity).Color:=DrawingControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=DrawingControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(tmpEntity).Rotate:=0;
  TGraphicText(tmpEntity).FontSize:=2.5;
  TGraphicText(tmpEntity).FontStyle:=[];
  TGraphicText(tmpEntity).FontName:='Arial';
  //TGraphicText(tmpEntity).Width:=70;
  //TGraphicText(tmpEntity).Height:=16;
  TGraphicText(tmpEntity).Text:=AText;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;
end;

procedure DrawSchemBox2Begin(DrawingControl:TAssiDrawControl; var X,Y,BoxX,BoxY:Double);
begin
  BoxX:=X;
  BoxY:=Y+SchemTerminalBlockWireHeight+SchemTerminalBlockHeaderHeight+SchemBoxPadding;
end;

procedure DrawSchemBox2End(DrawingControl:TAssiDrawControl; var StartX,StartY,EndX,EndY:Double; AText:String);
var
  tmpEntity:TEntity;
  X2,Y2:Double;
begin

  EndY:=EndY-SchemBoxPadding-SchemTerminalBlockWireHeight-SchemTerminalBlockHeight;
  EndX:=EndX;

  tmpEntity:=TGraphicPolyline.Create;
  tmpEntity.AddVertex(StartX,StartY,0);
  tmpEntity.AddVertex(EndX,StartY,0);
  tmpEntity.AddVertex(EndX,EndY,0);
  tmpEntity.AddVertex(StartX,EndY,0);
  tmpEntity.AddVertex(StartX,StartY,0);
  //tmpEntity.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //tmpEntity.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;

  tmpEntity:=TGraphicText.Create;
  tmpEntity.LayerName:=DRAWSCHEM_LAYERNAME_TEXT2;
  tmpEntity.AddVertex(StartX+5,StartY-1-SchemBoxPadding,0);
  TGraphicText(tmpEntity).Align:=gaAttachmentPointBottomLeft;
  TGraphicText(tmpEntity).Color:=DrawingControl.ActiveDocument.DefaultColor;
  tmpEntity.LineWeight:=DrawingControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(tmpEntity).Rotate:=0;
  TGraphicText(tmpEntity).FontSize:=2.5;
  TGraphicText(tmpEntity).FontStyle:=[];
  TGraphicText(tmpEntity).FontName:='Arial';
  //TGraphicText(tmpEntity).Width:=70;
  //TGraphicText(tmpEntity).Height:=16;
  TGraphicText(tmpEntity).Text:=AText;
  DrawingControl.ActiveDocument.ModelSpace.Objects.Add(tmpEntity);
  tmpEntity.Created;
end;

procedure DoDrawSchemConnections(DrawingControl:TAssiDrawControl);
var
  StartX,StartY:Double;
  EndX,EndY:Double;
  StartBox2X,StartBox2Y:Double;
  EndBox2X,EndBox2Y:Double;
  X,Y:Double;
  i,iBoxJ,iCables,iCablek,iCableWireCount:integer;
begin

  //Заранее получить список целевых щитов чтобы знать какие кабели искать
  X:=0;
  Y:=0;

  //Начало основного щита
  DrawSchemBox1Begin(DrawingControl,X,Y,StartX,StartY);
      //Начало целевого щита
      for iBoxJ:=0 to 2 do
      begin
          DrawSchemBox2Begin(DrawingControl,X,Y,StartBox2X,StartBox2Y);

          //Начало цикла кабелей
          for iCablek:=0 to 4 do
          begin
            iCableWireCount:=5;

            X:=X+SchemBoxPadding;
            DrawSchemTerminalBlockUpBegin(DrawingControl,X,Y,iCableWireCount);
            DrawSchemCable1(DrawingControl,X,Y,iCableWireCount,'Cable');
            DrawSchemTerminalBlockDownBegin(DrawingControl,X,Y-SchemBoxPadding-SchemCableHeight-SchemTerminalBlockWireHeight-SchemTerminalBlockHeight,iCableWireCount);
            X:=X+iCableWireCount*SchemTerminalBlockWidth;
            X:=X+SchemBoxPadding;

          //Конец цикла
          end;
          EndBox2X:=X;
          EndBox2Y:=Y;
          DrawSchemBox2End(DrawingControl,StartBox2X,StartBox2Y,EndBox2X,EndBox2Y,'Ящик');

          X:=X+SchemBoxPadding;
      //Конец целевого щита
      end;

  EndX:=X;
  EndY:=StartY;
  //Конец основного щита
  DrawSchemBox1End(DrawingControl,StartX,StartY,EndX,EndY,'Щит');

end;

end.

