unit u_form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, u_gassi_drawcontrol, u_gassi_visualobjects,
  u_gassi_logicaldraw, u_gassi_const, ComObj, u_gassi_dxf,
  u_drawconnectionsschem_function;

type

  { TFgassicMain }

  TFgassicMain = class(TForm)
    btnEllipse: TButton;
    btnDeselectAll: TButton;
    btnConnLine: TButton;
    btnPolyline1: TButton;
    btnZoomToFit: TButton;
    btnPoint: TButton;
    btnCircle: TButton;
    btnLine: TButton;
    btnArc: TButton;
    btnPolyline: TButton;
    btnText: TButton;
    btnBlockInsert: TButton;
    btnBlockCreate: TButton;
    btnAddFrame: TButton;
    btnClearFrame: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button7: TButton;
    cbDevMode: TCheckBox;
    cbAxes: TCheckBox;
    cbBlocks: TComboBox;
    cbReadOnly: TCheckBox;
    cbColorSelect: TComboBox;
    cbLineWeight: TComboBox;
    cbAAINSIDE: TCheckBox;
    cbAABASEPOINT: TCheckBox;
    cbAAVERTEX: TCheckBox;
    cbAABORDER: TCheckBox;
    cbLayers: TComboBox;
    Memo1: TMemo;
    PageControl1: TPageControl;
    pnlBox: TPanel;
    pnlRight: TPanel;
    pnlTop: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    procedure btnAddFrameClick(Sender: TObject);
    procedure btnArcClick(Sender: TObject);
    procedure btnBlockCreate2Click(Sender: TObject);
    procedure btnBlockCreate3Click(Sender: TObject);
    procedure btnBlockCreateClick(Sender: TObject);
    procedure btnBlockInsert1Click(Sender: TObject);
    procedure btnBlockInsertClick(Sender: TObject);
    procedure btnCircleClick(Sender: TObject);
    procedure btnClearFrameClick(Sender: TObject);
    procedure btnConnLineClick(Sender: TObject);
    procedure btnDeselectAllClick(Sender: TObject);
    procedure btnEllipseClick(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure btnPointClick(Sender: TObject);
    procedure btnPolyline1Click(Sender: TObject);
    procedure btnPolylineClick(Sender: TObject);
    procedure btnZoomToFitClick(Sender: TObject);
    procedure btnImportBlockClick(Sender: TObject);
    procedure btnTextClick(Sender: TObject);
    procedure btnBlockCreate1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure cbAABASEPOINTChange(Sender: TObject);
    procedure cbAABORDERChange(Sender: TObject);
    procedure cbAAINSIDEChange(Sender: TObject);
    procedure cbAAOUTSIDEChange(Sender: TObject);
    procedure cbAAVERTEXChange(Sender: TObject);
    procedure cbColorSelectChange(Sender: TObject);
    procedure cbLineWeightChange(Sender: TObject);
    procedure cbDevModeChange(Sender: TObject);
    procedure cbAxesChange(Sender: TObject);
    procedure cbReadOnlyChange(Sender: TObject);
    procedure edtscaleKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Memo2Change(Sender: TObject);
    procedure pnlBoxClick(Sender: TObject);
  private
    procedure BlockJoin(Sender: TObject);
    procedure EditingDoneEvent(Sender: TObject);
    { private declarations }
  public
    { public declarations }
    procedure ChangeSelectList(Sender: TObject);
    procedure EntityBeforeDrawEvent(Sender: TObject; AEntity:TEntity; var CanDraw:Boolean);
    procedure EntityAfterDrawEvent(Sender: TObject; AEntity:TEntity);
  end;

var
  FgassicMain: TFgassicMain;
  AssiDrawControl:TAssiDrawControl;

implementation

{$R *.lfm}

{ TFgassicMain }

procedure TFgassicMain.pnlBoxClick(Sender: TObject);
begin

end;

procedure TFgassicMain.EditingDoneEvent(Sender: TObject);
begin

end;

procedure TFgassicMain.ChangeSelectList(Sender: TObject);
var
  EntityItem:TEntity;
  i:integer;
begin
  Memo1.Lines.Clear;
  for I := 0 to AssiDrawControl.ActiveDocument.SelectList.Count - 1 do
  begin
      EntityItem:=TEntity(AssiDrawControl.ActiveDocument.SelectList.Items[i]);
      Memo1.Lines.Add(EntityItem.ClassName);
  end;
end;

procedure TFgassicMain.EntityBeforeDrawEvent(Sender: TObject; AEntity: TEntity;
  var CanDraw: Boolean);
begin
  //AEntity.Color:=0;
end;

procedure TFgassicMain.EntityAfterDrawEvent(Sender: TObject; AEntity: TEntity);
begin

end;

procedure TFgassicMain.FormCreate(Sender: TObject);
begin
  AssiDrawControl        :=TAssiDrawControl.Create(FgassicMain);
  AssiDrawControl.Parent :=self.pnlBox;
  {$IFNDEF FPC}
    AssiDrawControl.OnSelectListChange:=ChangeSelectList;
  {$ELSE}
    AssiDrawControl.OnSelectListChange      :=@ChangeSelectList;
    AssiDrawControl.OnEntityAfterDrawEvent  :=@EntityAfterDrawEvent;
    AssiDrawControl.OnEntityBeforeDrawEvent :=@EntityBeforeDrawEvent;
    AssiDrawControl.OnEditingDone:=@EditingDoneEvent;

  {$ENDIF}
  AssiDrawControl.Top       :=0;
  AssiDrawControl.Left      :=0;
  AssiDrawControl.Width     :=pnlBox.Width;
  AssiDrawControl.Height    :=pnlBox.Height;
  AssiDrawControl.Align     :=alClient;
  AssiDrawControl.FrameViewModeSet('DemoText',clBlue);
  AssiDrawControl.Show;
  AssiDrawControl.SetDefaultSettings;

  AssiDrawControl.BackgroundColor :=$00EDF3F8;
  AssiDrawControl.DrawGrid        :=True;
  AssiDrawControl.GridColor       :=clBlack;
  AssiDrawControl.GridBeamColor   :=clSilver;
  AssiDrawControl.GridStepX       :=50;
  AssiDrawControl.GridStepY       :=50;
end;

procedure TFgassicMain.btnEllipseClick(Sender: TObject);
var
  x:TEntity;
begin
  x:=TGraphicEllipse.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(15,15,0);
  //x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicEllipse(x).AxleY:=10;
  TGraphicEllipse(x).AxleX:=20;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Эллипс');
end;

procedure TFgassicMain.btnLineClick(Sender: TObject);
var
  x:TEntity;
begin
  x:=TGraphicline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,10,0);
  x.AddVertex(40,10,0);
  x.Color:=gaYellow;
  x.LineWeight:=gaLnWt030;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,20,0);
  x.AddVertex(40,20,0);
  x.Color:=gaCyan;
  x.LineWeight:=gaLnWt050;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,30,0);
  x.AddVertex(40,30,0);
  x.Color:=gaMagenta;
  x.LineWeight:=gaLnWt100;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,40,0);
  x.AddVertex(40,40,0);
  x.Color:=gaWhite;
  x.LineWeight:=gaLnWt200;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(20,60,0);
  x.AddVertex(20,40,0);
  x.Color:=gaMagenta;
  x.LineWeight:=gaLnWt030;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(30,60,0);
  x.AddVertex(30,40,0);
  x.Color:=gaWhite;
  x.LineWeight:=gaLnWt030;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Линия');
end;

procedure TFgassicMain.btnPointClick(Sender: TObject);
var
  x:TEntity;
begin
  x:=TGraphicpoint.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(30,25,0);
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Точка');
end;

procedure TFgassicMain.btnPolyline1Click(Sender: TObject);
var
  x:TEntity;
begin
  x:=AssiDrawControl.ActiveDocument.CreateRectangel;
  x.AddVertex(100,100,0);
  x.AddVertex(300,100,0);
  x.AddVertex(300,50,0);
  x.AddVertex(100,50,0);
  //x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Прямоугольник');

end;

procedure TFgassicMain.btnPolylineClick(Sender: TObject);
var
  x:TEntity;
begin
  x:=TGraphicPolyline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,10,0);
  x.AddVertex(200,10,0);
  x.AddVertex(200,200,0);
  x.AddVertex(10,200,0);
  //x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Полилиния');
end;

procedure TFgassicMain.btnDeselectAllClick(Sender: TObject);
begin
  AssiDrawControl.ActiveDocument.DeselectAll;
  AssiDrawControl.AddMessageToUser('Выполнено');
end;

function RotateFloatPoint(ABasePoint,ATarget:TFloatPoint;ADegree:integer):TFloatPoint;
var
    angle:double;
    t:TFloatPoint;
begin
  Angle:=ADegree*pi/180;
  t.X:=ABasePoint.X+round((ATarget.X-ABasePoint.X)*cos(Angle)-(ATarget.Y-ABasePoint.Y)*sin(Angle));
  t.Y:=(ABasePoint.Y+round((ATarget.Y-ABasePoint.Y)*cos(Angle)+(ATarget.X-ABasePoint.X)*sin(Angle)));
  t.z:=ATarget.Z;
  Result:=t;
end;

procedure TFgassicMain.btnCircleClick(Sender: TObject);
var
  x:TEntity;
  t1,t2,t3:TFloatPoint;
begin
  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(30,0,0);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  t1.X:=0;
  t1.Y:=0;
  t1.z:=0;

  t2.X:=30;
  t2.Y:=0;
  t2.z:=0;

  t3:=RotateFloatPoint(t1,t2,30);

  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(t3.X,t3.Y,t3.Z);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  t3:=RotateFloatPoint(t1,t2,45);

  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(t3.X,t3.Y,t3.Z);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;


  AssiDrawControl.AddMessageToUser('Круг');
end;

procedure TFgassicMain.btnClearFrameClick(Sender: TObject);
begin
  AssiDrawControl.FrameViewModeClear;
end;

procedure TFgassicMain.BlockJoin(Sender: TObject);
var
  x:TEntity;
  BlockItem:TBlockItem;
begin
   BlockItem      :=AssiDrawControl.ActiveDocument.CreateBlockItem('BlockJoin');
   AssiDrawControl.ActiveDocument.Blocks.Add(BlockItem);

   x:=AssiDrawControl.ActiveDocument.CreatePolyline;
   x.AddVertex(-5,-5,0);
   x.AddVertex(-5,5,0);
   x.AddVertex(5,5,0);
   x.AddVertex(5,-5,0);
   x.AddVertex(-5,-5,0);
   x.AddVertex(5,5,0);
   x.AddVertex(-5,-5,0);

   x.LineWeight :=gaLnWtByBlock;
   x.Color      :=gaByBlock;
   BlockItem.Objects.Add(x);
   x.Created;
end;

procedure TFgassicMain.btnConnLineClick(Sender: TObject);
var
  x1,x2:TGraphicBlock;
  x:TGraphicConnectionline;
begin
  {
  x1:=TGraphicCircle.Create;
  x1.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x1.AddVertex(50,50,0);
  TGraphicCircle(x1).Radius:=16;
  x1.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x1.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x1);
  x1.Created;

  x2:=TGraphicCircle.Create;
  x2.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x2.AddVertex(150,150,0);
  TGraphicCircle(x2).Radius:=16;
  x2.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x2.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x2);
  x2.Created;
  }
  BlockJoin(sender);

   x1:=AssiDrawControl.ActiveDocument.CreateBlockEntity;
   x1.AddVertex(300,300,0);
   TGraphicBlock(x1).BlockID:='BlockJoin';
   TGraphicBlock(x1).scale:=1;
   x1.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
   x1.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
   AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x1);
   x1.AddJoinVertex(0,5,0);
   x1.AddJoinVertex(0,-5,0);
   x1.AddJoinVertex(-5,0,0);
   x1.AddJoinVertex(5,0,0);
   x1.Created;

   x2:=AssiDrawControl.ActiveDocument.CreateBlockEntity;
   x2.AddVertex(150,150,0);
   TGraphicBlock(x2).BlockID:='BlockJoin';
   TGraphicBlock(x2).scale:=1;
   x2.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
   x2.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
   AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x2);
   x1.AddJoinVertex(0,5,0);
   x1.AddJoinVertex(0,-5,0);
   x1.AddJoinVertex(-5,0,0);
   x1.AddJoinVertex(5,0,0);
   x2.Created;

  x:=TGraphicConnectionline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.BeginEntityID:=x1.ID;
  x.BeginEntityIndex:=0;
  x.EndEntityID:=x2.ID;
  x.EndEntityIndex:=2;
  //x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Соединитель');

end;

procedure TFgassicMain.btnArcClick(Sender: TObject);
var
  x:TEntity;
begin
  {
  x:=TGraphicArc.Create;

  x.AddVertex(25,40,0);
  x.AddVertex(30,60,0);
  x.AddVertex(20,60,0);

  //x.AddVertex(46,46,0);
  //x.AddVertex(46,30,0);
  //x.AddVertex(62,46,0);
  TGraphicArc(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;
  }
  x:=TGraphicArc.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(45,60,0);
  x.AddVertex(40,60,0);
  x.AddVertex(50,60,0);

  TGraphicArc(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Дуга');
end;

procedure TFgassicMain.btnBlockCreate2Click(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockCreate3Click(Sender: TObject);
begin

end;

procedure TFgassicMain.btnAddFrameClick(Sender: TObject);
begin
  AssiDrawControl.FrameViewModeSet('Эллипс',clBlue);
end;

procedure TFgassicMain.btnBlockCreateClick(Sender: TObject);
var
  x:TEntity;
  BlockItem:TBlockItem;
begin
   BlockItem      :=TBlockItem.Create;
   BlockItem.Name :='TMPL_Box';
   AssiDrawControl.ActiveDocument.Blocks.Add(BlockItem);

   x:=TGraphicPolyline.Create;
   x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
   x.AddVertex(-5,-5,0);
   x.AddVertex(-5,5,0);
   x.AddVertex(5,5,0);
   x.AddVertex(5,-5,0);

   x.LineWeight :=gaLnWtByBlock;
   x.Color      :=gaByBlock;
   BlockItem.Objects.Add(x);
   x.Created;
end;

procedure TFgassicMain.btnBlockInsert1Click(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockInsertClick(Sender: TObject);
var
  x:TEntity;
begin
   x:=TGraphicBlock.Create;
   x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
   x.AddVertex(20,20,0);
   TGraphicBlock(x).BlockID:='TMPL_Box';
   TGraphicBlock(x).scale:=1;
   x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
   x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
   AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
   x.Created;

   x:=TGraphicBlock.Create;
   x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
   x.AddVertex(80,60,0);
   TGraphicBlock(x).BlockID:='TMPL_Box';
   TGraphicBlock(x).scale:=1;
   x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
   x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
   AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
   x.Created;

  x:=TGraphicPolyline.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,10,0);
  x.AddVertex(200,10,0);
  x.AddVertex(200,200,0);
  x.AddVertex(10,200,0);
  //x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  //x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  AssiDrawControl.AddMessageToUser('Готово');


end;

procedure TFgassicMain.btnZoomToFitClick(Sender: TObject);
begin
  AssiDrawControl.ActiveDocument.ZoomToFit;
end;

procedure TFgassicMain.btnImportBlockClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnTextClick(Sender: TObject);
var
  x:TEntity;
begin
  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,10,0);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,10,0);
  TGraphicText(x).Align:=gaAttachmentPointBottomLeft;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  //TGraphicText(x).Width:=70;
  TGraphicText(x).Height:=16;
  TGraphicText(x).Text:='BottomLeft';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(200,10,0);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(200,10,0);
  TGraphicText(x).Align:=gaAttachmentPointBottomRight;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  //TGraphicText(x).Width:=70;
  TGraphicText(x).Height:=16;
  TGraphicText(x).Text:='BottomRight';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(200,200,0);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(200,200,0);
  TGraphicText(x).Align:=gaAttachmentPointTopRight;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  //TGraphicText(x).Width:=70;
  TGraphicText(x).Height:=16;
  TGraphicText(x).Text:='TopRight';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;


  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,200,0);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(10,200,0);
  TGraphicText(x).Align:=gaAttachmentPointTopLeft;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  //TGraphicText(x).Width:=70;
  TGraphicText(x).Height:=16;
  TGraphicText(x).Text:='TopLeft';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;


  x:=TGraphicCircle.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(35,35,0);
  TGraphicCircle(x).Radius:=5;
  x.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(400,50,0);
  TGraphicText(x).Align:=gaAttachmentPointBottomRight;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  TGraphicText(x).Width:=100;
  TGraphicText(x).Height:=200;
  TGraphicText(x).Rotate:=0; //не реализовано
  TGraphicText(x).Text:='Длинный очень текст теста строк';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(35,35,0);
  TGraphicText(x).Align:=gaAttachmentPointBottomRight;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  TGraphicText(x).Width:=0;
  TGraphicText(x).Height:=0;
  TGraphicText(x).Rotate:=0; //не реализовано
  TGraphicText(x).Text:='TGraphicText Rotate 0';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;


  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(35,35,0);
  TGraphicText(x).Align:=gaAttachmentPointBottomRight;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  TGraphicText(x).Width:=0;
  TGraphicText(x).Height:=0;
  TGraphicText(x).Rotate:=90; //не реализовано
  TGraphicText(x).Text:='TGraphicText Rotate 90';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;

  x:=TGraphicText.Create;
  x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
  x.AddVertex(35,35,0);
  TGraphicText(x).Align:=gaAttachmentPointBottomRight;
  TGraphicText(x).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x).FontSize:=10;
  TGraphicText(x).FontStyle:=[fsUnderline];
  TGraphicText(x).FontName:='Arial';
  TGraphicText(x).Width:=0;
  TGraphicText(x).Height:=0;
  TGraphicText(x).Rotate:=45; //не реализовано
  TGraphicText(x).Text:='TGraphicText Rotate 45';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;


  AssiDrawControl.AddMessageToUser('Текст');
end;

procedure TFgassicMain.btnBlockCreate1Click(Sender: TObject);
begin

end;

procedure TFgassicMain.Button1Click(Sender: TObject);
begin
  //Элипс и что то сложное не будет работать.
  BeginWorkDXF;
  ExportModelSpaceToDXF(AssiDrawControl.ActiveDocument,'GassicTest.dxf');
  EndWorkDXF;
  ShowMessage('Write to GassicTest.dxf');
end;

procedure TFgassicMain.Button5Click(Sender: TObject);
begin
  BeginWorkDXF;
  ReadSectionsFromDXF('importtemplate.dxf');
  bDXFWriteBlocks   :=False;
  ExportModelSpaceToDXF(AssiDrawControl.ActiveDocument,'GassicTest.dxf');
  EndWorkDXF;
  ShowMessage('Write to GassicTest.dxf');
end;

procedure TFgassicMain.Button2Click(Sender: TObject);
var
  x:TEntity;
  i,k:integer;
begin
  k:=AssiDrawControl.GridStepY;
  for i:=0 to 50 do
  begin
    x:=TGraphicPolyline.Create;
    x.ID:=AssiDrawControl.ActiveDocument.GetEntityID;
    x.AddVertex(10,i*k,0);
    x.AddVertex(500,i*k,0);
    AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
  end;
end;

procedure TFgassicMain.Button3Click(Sender: TObject);
var
  x1,x2:TEntity;
begin

  x2:=AssiDrawControl.ActiveDocument.CreateText;
  x2.AddVertex(30,10,0);

  TGraphicText(x2).Align:=gaAttachmentPointBottomLeft;
  TGraphicText(x2).Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x2.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  TGraphicText(x2).FontSize:=10;
  TGraphicText(x2).FontStyle:=[fsUnderline];
  TGraphicText(x2).FontName:='Arial';
  //TGraphicText(x2).Width:=70;
  TGraphicText(x2).Height:=16;
  TGraphicText(x2).Text:='BottomLeft';
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x2);
  x2.Created;

  x1:=AssiDrawControl.ActiveDocument.CreateCircle;
  x1.AddVertex(10,10,0);
  TGraphicCircle(x1).Radius:=5;
  x1.Color:=AssiDrawControl.ActiveDocument.DefaultColor;
  x1.LineWeight:=AssiDrawControl.ActiveDocument.DefaultLineWeight;
  AssiDrawControl.ActiveDocument.ModelSpace.Objects.Add(x1);
  x1.Created;

  x2.GroupOwner:=x1.ID;

end;

procedure TFgassicMain.Button4Click(Sender: TObject);
begin
  AssiDrawControl.ActiveDocument.Clear;
end;

procedure TFgassicMain.Button6Click(Sender: TObject);
begin

end;

procedure TFgassicMain.Button7Click(Sender: TObject);
begin
  BeginWorkDXF;
  {
  TmpDXFDocument.ClearDocument;
  TmpDXFDocument.LoadFromFile('TestRead2018.dxf');

  cbLayers.Items.Text:=TmpDXFDocument.Layers.Text;
  cbBlocks.Items.Text:=TmpDXFDocument.Blocks.Text;
  }
  EndWorkDXF;
end;

procedure TFgassicMain.cbAABASEPOINTChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle+[aasoBASEPOINT]
  else
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle-[aasoBASEPOINT];
end;

procedure TFgassicMain.cbAABORDERChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle+[aasoBORDER]
  else
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle-[aasoBORDER];
end;

procedure TFgassicMain.cbAAINSIDEChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle+[aasoINSIDE]
  else
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle-[aasoINSIDE];
end;

procedure TFgassicMain.cbAAOUTSIDEChange(Sender: TObject);
begin

end;

procedure TFgassicMain.cbAAVERTEXChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle+[aasoVERTEX]
  else
  AssiDrawControl.SelectStyle:=AssiDrawControl.SelectStyle-[aasoVERTEX];
end;

procedure TFgassicMain.cbColorSelectChange(Sender: TObject);
begin
 case cbColorSelect.ItemIndex of
 0:AssiDrawControl.ActiveDocument.DefaultColor:=gaByBlock;
 1:AssiDrawControl.ActiveDocument.DefaultColor:=gaByLayer;
 2:AssiDrawControl.ActiveDocument.DefaultColor:=gaRed;
 3:AssiDrawControl.ActiveDocument.DefaultColor:=gaYellow;
 4:AssiDrawControl.ActiveDocument.DefaultColor:=gaGreen;
 5:AssiDrawControl.ActiveDocument.DefaultColor:=gaCyan;
 6:AssiDrawControl.ActiveDocument.DefaultColor:=gaBlue;
 7:AssiDrawControl.ActiveDocument.DefaultColor:=gaMagenta;
 8:AssiDrawControl.ActiveDocument.DefaultColor:=gaWhite;
 end;
end;

procedure TFgassicMain.cbLineWeightChange(Sender: TObject);
begin
  case cbLineWeight.ItemIndex of
0:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWtByLwDefault;
1:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWtByLayer;
2:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWtByBlock;
3:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt000;
4:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt005;
5:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt009;
6:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt013;
7:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt015;
8:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt018;
9:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt020;
10:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt025;
11:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt030;
12:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt035;
13:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt040;
14:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt050;
15:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt053;
16:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt060;
17:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt070;
18:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt080;
19:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt090;
20:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt100;
21:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt106;
22:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt120;
23:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt140;
24:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt158;
25:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt200;
26:AssiDrawControl.ActiveDocument.DefaultLineWeight:=gaLnWt211;
end;
end;

procedure TFgassicMain.cbDevModeChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
      AssiDrawControl.DevelopMode:=true
  else
      AssiDrawControl.DevelopMode:=false;
end;

procedure TFgassicMain.cbAxesChange(Sender: TObject);
begin
    if (Sender as TCheckBox).Checked then
      AssiDrawControl.ShowAxes:=true
  else
      AssiDrawControl.ShowAxes:=false;
end;

procedure TFgassicMain.cbReadOnlyChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
      AssiDrawControl.ActiveDocument.EditMode:=eemReadOnly
  else
      AssiDrawControl.ActiveDocument.EditMode:=eemCanAll;
end;

procedure TFgassicMain.edtscaleKeyPress(Sender: TObject; var Key: char);
begin
  if (Key in ['.']) then Key:=char(',');
end;

procedure TFgassicMain.FormDestroy(Sender: TObject);
begin
  AssiDrawControl.free;
end;

procedure TFgassicMain.Memo2Change(Sender: TObject);
begin

end;

end.

