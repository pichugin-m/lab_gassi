unit u_gassi_visualobjects;

//************************************************************
//
//    Модуль компонента Graphic Assi Control Join edition
//    Copyright (c) 2013  Pichugin M.
//    ver. 0.21 Join edition
//    Разработчик: Pichugin M. (e-mail: pichugin-swd@mail.ru)
//
//************************************************************

interface

uses
{$IFDEF FPC}
  LCLIntf, LCLType,
{$ENDIF}
  Contnrs, Classes, SysUtils, controls, Graphics,
  u_gassi_logicaldraw, u_gassi_const, u_gassi_geometry;

// ver. 0.21
// Заменен TEntityList. Исключена утечка памяти из-за класса.
// ver. 0.20
// Исправление TEntityList.Delete();
// ver. 0.18
// Добавлены атрибуты для блоков, связь с атрибутами через поле tag у текста.
// ver. 0.17
// Добавлено автоматическое перемещение объектов связанных по свойству GroupOwner
// ver. 0.16
// Добавлен Join vertex
// ver. 0.15
// Добавлен TGraphicRectangel
// ver. 0.14
// Доработка алгоритма перемещения объектов
// ver. 0.13
// Добавлен nbg TGraphicConnectionline
// Исправление недоработах при работе с Vertex
// ver. 0.12
// Добавлено удаление блоков по префиксу
// ver. 0.10
// Исправления расчета крайних точек объектов
// ver. 0.9
// Изменено масштабирование
// ver. 0.8.1
// Комментарий добавлен
// ver. 0.8
// - Измена архитектура получения доступа объектов к классу TDrawDocumentCustom
// - Добавлена обработка блок в блоке
//
// ver. 0.6
// Новое:
// property  Tag  : integer;


// Базовые типы объекто

  {
    TGraphicBlock
    TGraphicText
    TGraphicArc
    TGraphicCircle
    TGraphicEllipse
    TGraphicPolyline
    TGraphicLine
    TGraphicPoint
  }

// Дополнительные типы

   {
     TGraphicAttribute       //Атрибуты блоков
     TGraphicRectangel
     TGraphicConnectionline  // Соединительная линия
     TGraphicHatch           // Штриховка (не реализована)
   }

type

  { Forward Declarartions }

  TDrawDocumentCustom = class;

  TEntity            = class;
  TEntityBlockBasic  = class;
  TWorkSpaceCustom   = class;
  TWorkSpace         = class;
  TBlockItem         = class;
  TBlockList         = class;

  { Data types }

  TEntityID = ShortString;

  TEntityState     = set of (esNone,esCreating,esEditing,esMoving,esSelected);
  TEntityDrawStyle = set of (edsNone,edsNormal,edsSelected,edsEditing,edsMoving,edsCreating);
  TEntityType      = (etNone,etAll,etBlock,etText,etArc,etCircle,etEllipse,etLine,etPolyline,etRectangel,etPoint,etConnectionLine);
  TEntityTypes     = set of TEntityType;

  TGetDocumentEvent = function :TDrawDocumentCustom of object;

  { Record Declarartions }

  // Логические координаты
  PFloatPoint = ^TFloatPoint;
  TFloatPoint = record
    X, Y, Z :Double;
  end;

  PTFloatRect = ^TFloatRect;
  TFloatRect = record
    TopX, TopY, TopZ           :Double;
    BottomX, BottomY, BottomZ  :Double;
  end;

  TModifyVertex = record
    Item        : TEntity;
    VertexIndex : Integer;
    VertexPos   : TFloatPoint;
  end;

  // Массив точек
  TPointsArray                = array of TFloatPoint;
  TModifyVertexArray          = array of TModifyVertex;

  { TFloatPointList }

  TFloatPointList = class
  protected
         FList   : TList;
  private
         function GetCount: Integer;
         function GetPoint(Index: Integer): TFloatPoint;
         procedure SetPoint(Index: Integer; const Value: TFloatPoint);
         function  NewPoint(X, Y, Z: Double): PFloatPoint;
  public
         constructor Create; virtual;
         destructor Destroy; override;
         function Add(X, Y, Z: Double): Integer;
         procedure Insert(Index: Integer; X, Y, Z: Double);
         procedure Delete(Index: Integer);
         function  Extract(Index: Integer): PFloatPoint;
         property  Count: Integer read GetCount;
         property  Items[Index: Integer]: TFloatPoint read GetPoint write SetPoint;
  end;

  { TDrawDocumentCustom }

  TDrawDocumentCustom = class
  protected
    FModelSpace     :TWorkSpace;
    FBlockList      :TBlockList;
  public
    //Получить допуск по координатам
    function GetDeltaVertex:Double; virtual; abstract;
    procedure DeselectAll; virtual; abstract;
  end;

   { TEntityList }

   // Эллементы чертежа
   TEntityList      = class
   private
        FList               : TList;
		    FID                 : TEntityID;
        FModelSpace         : TWorkSpaceCustom;
		
        procedure SetEntityLinkVar(AEntity:TEntity);
        procedure ChangeCordVertex(const AVertCord:TFloatPoint);
        function GetCount: Integer;
        function GetItem(Index: Integer): TEntity;
        procedure SetItem(Index: Integer; const Value: TEntity);
   protected
        
   public
       constructor Create; virtual;
       destructor Destroy; override;
       // Cобытия
       procedure Add(AEntity: TEntity); overload;
       function  Add(AParentID:TEntityID): TEntity; overload;
       procedure Insert(Index: Integer; AEntity: TEntity);
       procedure Delete(Index: Integer);
       procedure Remove(AEntity: TEntity);
       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
         LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw);
       function  GetEntityByID(AID:TEntityID): TEntity;
       property  ID: TEntityID read FID write FID;
	   
       property  Count: Integer read GetCount;
       property  Items[Index: Integer]: TEntity read GetItem write SetItem;
	   
	   procedure Clear;
   end;

   { TWorkSpaceCustom }

      TWorkSpaceCustom      = class
      private
           function GetDocument: TDrawDocumentCustom;
      protected
           FTopLeft            : TFloatPoint;
           FBottomRight        : TFloatPoint;
           FSelectedEntityList : TList;
           FEntityList         : TEntityList;
           FOnGetDocumentEvent : TGetDocumentEvent;

           //Временное значение
           FByBlockColor        :TgaColor;
           FByBlockLineWeight   :TgaLineWeight;
      public
          constructor Create; virtual; overload;
          destructor Destroy; override;
          // Cобытия

          procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
                     LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
          procedure RepaintVertex(LogicalDrawing: TLogicalDraw);
          procedure DeselectAll;
          //procedure ResetMinMaxPoint; overload;
          //function  GetMinMaxPoint:TMinMaxPoint; overload;
          //function  GetColor(AParentID:TEntityID; AColor:TgaColor):TgaColor;
          //function  GetLineWeight(AParentID:TEntityID; LineWeight:TgaLineWeight):TgaLineWeight;
          function  GetColor(AColor:TgaColor):TgaColor;
          function  GetLineWeight(LineWeight:TgaLineWeight):TgaLineWeight;
          procedure GetRectVertex(var ATopLeft, ABottomRight: TFloatPoint);
          //Действия
          //Перемещение группы объектов
          procedure MoveEntityGroup(AOwnerGroup: TEntityID; APoint: TFloatPoint);

          property  ThisDocument : TDrawDocumentCustom read GetDocument;
          property  OnGetDocument: TGetDocumentEvent read FOnGetDocumentEvent
                                                     write FOnGetDocumentEvent;
          property  SelectedEntityList: TList read FSelectedEntityList
                                              write FSelectedEntityList;
          property  Objects: TEntityList read FEntityList write FEntityList;
      end;

  { TWorkSpace }

   TWorkSpace      = class(TWorkSpaceCustom);

   { TBlockItem }

   TBlockItem      = class(TWorkSpaceCustom)
   private

   protected
      FCurPaintOwnerBlock  : TEntityBlockBasic;
      FName                : AnsiString;    // Идентификатор
   public
      property  Name       : AnsiString read FName write FName;
      //Владелец блока в момент отрисовки
      property  OwnerBlock : TEntityBlockBasic read FCurPaintOwnerBlock
                                          write FCurPaintOwnerBlock;
      constructor Create; override;
   end;

   { TBlockList }

   TBlockList      = class(TObjectList)
   private
       function GetItem(Index: Integer): TBlockItem;
       function GetBlock(Name: AnsiString): TBlockItem;
       procedure SetItem(Index: Integer; const Value: TBlockItem);
       procedure SetBlock(Name: AnsiString; AValue: TBlockItem);
   protected
       FOnGetDocumentEvent : TGetDocumentEvent;
   public
       constructor Create; virtual; overload;
       function Add(AObject: TBlockItem): Integer;
       procedure Insert(Index: Integer; AObject: TBlockItem);
       property  Block[Name: AnsiString]: TBlockItem read GetBlock write SetBlock;
       property  Items[Index: Integer]: TBlockItem read GetItem write SetItem;
       property  OnGetDocument: TGetDocumentEvent read FOnGetDocumentEvent
                                                  write FOnGetDocumentEvent;
       procedure ClearByPrefix(APrefix:AnsiString; AInver:Boolean);
   end;

   { TEntityBasic }

   TEntityBasic = class // Базовый класс
   private

   protected
       FID           : TEntityID;    // Уникальный идентификатор эллемента чертежа
       FState        : TEntityState;
       FVertex       : TFloatPointList;
       FLineWeight   : TgaLineWeight;     // Толщина линий
       FColor        : TgaColor;          // Цвет объекта
       FLayerName    : ShortString;       // Слой объекта
       FData         : Pointer;
       FTag          : integer;
       FGroupOwner   : TEntityID;

       FBlocked     : Boolean;
       FParentList  : TEntityList;   // Основной список эллементов чертежа
       FBlockList   : TEntityList;   // Список составных частей блока
       FOnGetDocumentEvent : TGetDocumentEvent;

       //procedure Change;
       function  GetVertexCount: Integer; virtual; abstract;
       function  GetVertex(Index: Integer): TFloatPoint; virtual; abstract;
       procedure SetVertex(Index: Integer; const Value: TFloatPoint); virtual; abstract;
   public
       constructor Create; virtual;
       destructor Destroy; override;
       procedure Created;
       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
                  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); overload; virtual; abstract;
       procedure Repaint(LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);  overload;virtual; abstract;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); virtual; abstract;
       function GetSelect(TopLeft, BottomRight: TFloatPoint;
                  AllVertexInRect: Boolean):Integer; overload;virtual; abstract;
       function GetSelect(TopLeft, BottomRight: TFloatPoint;
                  AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;virtual; abstract;
       function GetColor(AColor:TgaColor):TgaColor; overload;
       function GetLineWeight(ALineWeight:TgaLineWeight):TgaLineWeight; overload;
       function GetColor:TgaColor; overload;
       function GetLineWeight:TgaLineWeight; overload;
       // Методы блокировки/разблокировки
       procedure BeginUpdate;
       procedure EndUpdate;

       procedure AddVertex(X, Y, Z: Double); virtual; abstract;
       procedure InsertVertex(Index: Integer; X, Y, Z: Double);  virtual; abstract;
       procedure DeleteVertex(Index: Integer); virtual; abstract;

       property  VertexCount: Integer read GetVertexCount;
       property  Vertex[Index: Integer]: TFloatPoint read GetVertex write SetVertex;
       property  State: TEntityState read FState write FState;
       property  ID: TEntityID read FID write FID;

       property  OnGetDocument: TGetDocumentEvent read FOnGetDocumentEvent
                                                  write FOnGetDocumentEvent;
   end;

   TEntity      = class(TEntityBasic)  // Общий предок класс
   protected
       FActionVertexIndex: integer;
       FActionVertexDelta: TFloatPoint;
   private
       function GetDocument: TDrawDocumentCustom;

       function GetVertexCount: Integer; override;
       function GetVertex(Index: Integer): TFloatPoint; override;
       procedure SetVertex(Index: Integer; const Value: TFloatPoint); override;

       function GetVertexAxleX(Index: Integer): Double;
       function GetVertexAxleY(Index: Integer): Double;
       function GetVertexAxleZ(Index: Integer): Double;
       procedure SetVertexAxleX(Index: Integer; const Value: Double);virtual;
       procedure SetVertexAxleY(Index: Integer; const Value: Double);virtual;
       procedure SetVertexAxleZ(Index: Integer; const Value: Double);virtual;

       function GetInteractiveVertex(AVertex:TFloatPoint):TFloatPoint;
       function GetGroupOwnerInteractiveVertex(AGroupOwner: TEntity;
         AVertex: TFloatPoint): TFloatPoint;

       property  VertexCount: Integer read GetVertexCount;
       property  Vertex[Index: Integer]: TFloatPoint read GetVertex write SetVertex;
       property  VertexAxleX[Index: Integer]: Double read GetVertexAxleX write SetVertexAxleX;
       property  VertexAxleY[Index: Integer]: Double read GetVertexAxleY write SetVertexAxleY;
       property  VertexAxleZ[Index: Integer]: Double read GetVertexAxleZ write SetVertexAxleZ;
   published
       property  LineWeight: TgaLineWeight read FLineWeight write FLineWeight;
       property  Color: TgaColor read FColor write FColor;
       property  LayerName :ShortString read FLayerName write FLayerName;
       property  Tag  : integer read FTag write FTag;
   public
       // Свойства/события
       property  ThisDocument : TDrawDocumentCustom read GetDocument;
       property  Data         : Pointer read FData write FData;
       property  GroupOwner   : TEntityID read FGroupOwner write FGroupOwner;

       //Временное свойство. Устанавливается во время перемещения мышкой
       property ActionVertexDelta :TFloatPoint read FActionVertexDelta write FActionVertexDelta;
       //Временное свойство. Устанавливается во время перемещения мышкой
       property ActionVertexIndex :integer read FActionVertexIndex write FActionVertexIndex;

       procedure AddVertex(X, Y, Z: Double); override;
       procedure InsertVertex(Index: Integer; X, Y, Z: Double); override;
       procedure DeleteVertex(Index: Integer); override;

       function GetOwnerGroup:TEntity;
       function RepaintOwnerGroupMove: TEntity;

       function GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean):Integer;overload;virtual;
       function GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;virtual;
       procedure Repaint(LogicalDrawing: TLogicalDraw; Style:TEntityDrawStyle); override;

       procedure GetRectVertex(var ATopLeft,ABottomRight:TFloatPoint);virtual;

       procedure MoveVertex(Index:integer; NewVertex:TFloatPoint);virtual;
       procedure MoveEntity(ADeltaVertex:TFloatPoint); virtual;
       procedure MoveGroupChildEntity(ADeltaVertex:TFloatPoint); virtual;

       property  ParentList: TEntityList read FParentList write FParentList;
       property  BlockList: TEntityList read FBlockList write FBlockList;

       constructor Create; override;
       destructor Destroy; override;
   end;

   TEntityLineBasic      = class(TEntity)
   protected
   public
       property  Vertex[Index: Integer]: TFloatPoint read GetVertex write SetVertex;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
       function GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean):Integer; overload; override;
       function GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
   end;

   { TEntityEllipseBasic }

    TEntityEllipseBasic      = class(TEntity)
    protected
        FAxleY: Double;
        FAxleX: Double;
    private
        function GetRadius: Double; virtual; abstract;
        procedure SetRadius(const Value: Double); virtual;  abstract;
        function GetDiameter: Double; virtual; abstract;
        procedure SetDiameter(const Value: Double); virtual; abstract;
        function GetBasePoint: TFloatPoint; virtual;
        procedure SetBasePoint(const Value: TFloatPoint); virtual;

        function GetAxleX: Double; virtual; abstract;
        function GetAxleY: Double; virtual; abstract;
        procedure SetAxleX(const Value: Double); virtual; abstract;
        procedure SetAxleY(const Value: Double); virtual; abstract;
   published
        property  Radius: Double read GetRadius write SetRadius;
        property  Diameter: Double read GetDiameter write SetDiameter;
        property  AxleY: Double read GetAxleY write SetAxleY;
        property  AxleX: Double read GetAxleX write SetAxleX;
   public
        property  BasePoint: TFloatPoint read GetBasePoint write SetBasePoint;

        procedure GetRectVertex(var ATopLeft,ABottomRight:TFloatPoint);override;
        function GetSelect(TopLeft, BottomRight: TFloatPoint;
          AllVertexInRect: Boolean):Integer;override;
        function GetSelect(TopLeft, BottomRight: TFloatPoint;
          AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
        procedure MoveVertex(Index:integer; NewVertex:TFloatPoint);override;
        procedure MoveEntity(ADeltaVertex:TFloatPoint); override;
   end;

  { TEntityBlockBasic }

  TEntityBlockBasic      = class(TEntity)
  protected
      FBlockID     : AnsiString;
      FScaleX      : Double;
      FScaleY      : Double;
      FScaleZ      : Double;
      FShowJoinVertex: Boolean;

      FJoinVertex   : TFloatPointList;
      FJoinNames    : TStringList;
      FAttributes   : TStringList;

  private
      function GetBasePoint: TFloatPoint; virtual;
      procedure SetBasePoint(const Value: TFloatPoint); virtual;
      function GetJoinVertex(Index: Integer): TFloatPoint; virtual; abstract;
      function GetJoinVertexCount: Integer; virtual; abstract;
      procedure SetJoinVertex(Index: Integer; AValue: TFloatPoint); virtual; abstract;

   public
      property  BasePoint: TFloatPoint read GetBasePoint write SetBasePoint;
      property  BlockID: AnsiString read FBlockID write FBlockID;
      property  ShowJoinVertex: Boolean read FShowJoinVertex write FShowJoinVertex;

      procedure AddVertex(X, Y, Z: Double); override;
      procedure InsertVertex(Index: Integer; X, Y, Z: Double); override;

      function AddJoinVertex(X, Y, Z: Double):integer;  virtual; abstract;
      procedure DeleteJoinVertex(Index: Integer);  virtual; abstract;
      procedure InsertJoinVertex(Index: Integer; X, Y, Z: Double);  virtual; abstract;
      function GetJoinVertex(TopLeft, BottomRight: TFloatPoint): Integer;
      function GetRecalculatedJoinVertex(AIndex: integer): TFloatPoint;

      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
        LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
      function GetSelect(TopLeft, BottomRight: TFloatPoint;
        AllVertexInRect: Boolean):Integer;  overload;override;
      function GetSelect(TopLeft, BottomRight: TFloatPoint;
        AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;override;
      procedure GetRectVertex(var ATopLeft,ABottomRight:TFloatPoint);override;

      procedure SetJoinName(Index: Integer;AName:String); virtual; abstract;
      function GetJoinName(Index: Integer):String; virtual; abstract;

      procedure SetAttributeValue(AName, AValue:String); virtual; abstract;
      function GetAttributeValue(AName:String):String; virtual; abstract;

      property  JoinVertexCount: Integer read GetJoinVertexCount;
      property  JoinVertex[Index: Integer]: TFloatPoint read GetJoinVertex
                                                 write SetJoinVertex;

      procedure MoveAllJoinVertex(ADeltaVertex:TFloatPoint); virtual; abstract;

      constructor Create; override;
      destructor Destroy; override;
   end;

  { TEntityTextBasic }

  TEntityTextBasic      = class(TEntity)
  protected
      FRotate       : integer;
  private
      function GetBasePoint: TFloatPoint; virtual;
      procedure SetBasePoint(const Value: TFloatPoint); virtual;
  public
      property  BasePoint: TFloatPoint read GetBasePoint write SetBasePoint;
      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
        LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
      function GetSelect(TopLeft, BottomRight: TFloatPoint;
        AllVertexInRect: Boolean):Integer;  overload;override;
      function GetSelect(TopLeft, BottomRight: TFloatPoint;
        AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;override;
      constructor Create; override;
  end;

   // Точка
   TGraphicPoint      = class(TEntity)
   private

   public
       // Свойства/события
       procedure AddVertex(X, Y, Z: Double); override;
       procedure InsertVertex(Index: Integer; X, Y, Z: Double); override;
       procedure Draw(APoint:TFloatPoint);overload;
       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
         LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
       function GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean):Integer; overload;override;
       function GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;override;
   end;

   // Линия

   { TGraphicLine }

   TGraphicLine                = class(TEntityLineBasic)
   public
       procedure Draw(APoint1,APoint2:TFloatPoint);overload;
       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
         LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
   end;

   // Полилиния

   { TGraphicPolyline }

   TGraphicPolyline            = class(TEntityLineBasic)
   protected
      FClosed:Boolean;
   private
      function GetClosed: Boolean;virtual;
      procedure SetClosed(AValue: Boolean); virtual;
   published
      property  Closed: Boolean read GetClosed write SetClosed;
   public
      procedure Draw(APoints:TPointsArray;AClosed: Boolean);overload;
      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
        LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
   end;

   { TGraphicConnectionline }

   TGraphicConnectionline     = class(TEntityLineBasic)
   protected
     FBeginEntityID      : TEntityID;
     FBeginEntityIndex   : Integer;
     FEndEntityID        : TEntityID;
     FEndEntityIndex     : Integer;
     FMiddleLineOffsetY  : Double;
     FMiddleLineOffsetX  : Double;
   private
     function GetBeginVertex(var AJoinExists:Boolean): TFloatPoint;
     function GetEndVertex(var AJoinExists:Boolean): TFloatPoint;
     function GetBeginVertex: TFloatPoint;overload;
     function GetEndVertex: TFloatPoint;overload;
     function ObjectYPosition(AItem: TEntity; AVertex: TFloatPoint): integer;
     function ObjectXPosition(AItem: TEntity; AVertex: TFloatPoint): integer;
     procedure GetBypassPoints(AItem: TEntity; AStartVertex: TFloatPoint; ALeft,
       ATop: Boolean; var AOutBypassPoints: TPointsArray);
   public
      property  BeginEntityID    : TEntityID read FBeginEntityID write FBeginEntityID;
      property  BeginEntityIndex : Integer read FBeginEntityIndex  write FBeginEntityIndex;
      property  BeginVertex      : TFloatPoint read GetBeginVertex;

      property  EndEntityID      : TEntityID read FEndEntityID write FEndEntityID;
      property  EndEntityIndex   : Integer read FEndEntityIndex  write FEndEntityIndex;
      property  EndVertex        : TFloatPoint read GetEndVertex;

      procedure Draw(APoints:TPointsArray;AClosed: Boolean);overload;
      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
        LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
      procedure MoveVertex(Index:integer; NewVertex:TFloatPoint);override;
      function GetSelect(TopLeft, BottomRight: TFloatPoint;
        AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;override;

      procedure GetLinePointsVertex(var APoints:TPointsArray);

      constructor Create; override;
   end;

   { TGraphicRectangel }

   TGraphicRectangel            = class(TGraphicPolyline)
   private
      function GetBottomRightPoint: TFloatPoint;
      function GetClosed: Boolean;override;
      function GetTopLeftPoint: TFloatPoint;
      procedure SetBottomRightPoint(AValue: TFloatPoint);
      procedure SetClosed(AValue: Boolean); override;
      procedure SetTopLeftPoint(AValue: TFloatPoint);
   public
        property  TopLeftPoint: TFloatPoint read GetTopLeftPoint write SetTopLeftPoint;
        property  BottomRightPoint: TFloatPoint read GetBottomRightPoint write SetBottomRightPoint;
        procedure MoveVertex(Index:integer; NewVertex:TFloatPoint);override;
        procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
          LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
        procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
        constructor Create; override;
   end;

   // Элипс
   TGraphicEllipse              = class(TEntityEllipseBasic)
   private
      function GetDiameter: Double; override;
      procedure SetDiameter(const Value: Double); override;
      function GetRadius: Double;override;
      procedure SetRadius(const Value: Double); override;
      function GetAxleX: Double; override;
      function GetAxleY: Double; override;
      procedure SetAxleX(const Value: Double); override;
      procedure SetAxleY(const Value: Double); override;
   published
   {    property  Radius: Double read GetRadius write SetRadius;
       property  Diameter: Double read GetDiameter write SetDiameter;
       property  AxleY: Double read GetAxleY write SetAxleY;
       property  AxleX: Double read GetAxleX write SetAxleX;
   }
   public
       procedure Draw(ABasePoint:TFloatPoint;AAxleY,AAxleX,ARotate:integer);overload;
       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
         LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
   end;

   // Круг
   TGraphicCircle              = class(TEntityEllipseBasic)
   private
        function GetDiameter: Double; override;
        procedure SetDiameter(const Value: Double); override;
        function GetRadius: Double;override;
        procedure SetRadius(const Value: Double); override;
        function GetAxleX: Double; override;
        function GetAxleY: Double; override;
        procedure SetAxleX(const Value: Double); override;
        procedure SetAxleY(const Value: Double); override;
   published
        {property  AxleY: Double read GetAxleY write SetAxleY;
        property  AxleX: Double read GetAxleX write SetAxleX;
        property  Radius: Double read GetRadius write SetRadius;
        property  Diameter: Double read GetDiameter write SetDiameter;}
   public
        procedure Draw(ABasePoint:TFloatPoint;ARadius:Double);overload;
        procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
          LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
        procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
   end;

   // Дуга
   TGraphicArc                 = class(TEntityEllipseBasic)
   private
      function GetDiameter: Double; override;
      procedure SetDiameter(const Value: Double); override;
      function  GetRadius: Double;override;
      procedure SetRadius(const Value: Double); override;
   public
      procedure Draw(ABasePoint,APoint1,APoint2:TFloatPoint;ARadius:Double);overload;
      procedure Draw(APoint1,APoint2,APoint3:TFloatPoint);overload;
      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
        LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
      procedure MoveVertex(Index:integer; NewVertex:TFloatPoint);override;
   end;

   { TGraphicText }

   // Текс
   TGraphicText                = class(TEntityTextBasic)
   protected
      FGroupTagName : ShortString;
      FStyleName    : AnsiString;
      FWidth        : Double;
      FHeight       : Double;
      FAlign        : TgaAttachmentPoint;
      FText         : String;
      FFontSize     : Double;
      FFontStyle    : TFontStyles;
      FFontName     : AnsiString;
   private
      function GetHeight : Double;
      function GetText   : String; virtual;
      function GetWidth  : Double;
      procedure SetHeight(const Value: Double);
      procedure SetWidth(const Value: Double);
   published
       //Лучше не задавать, чтобы было 0. Иначе отражается на выравнивании и обрезается зона надписи
       property  Width: Double read GetWidth write SetWidth;
       property  Height: Double read GetHeight write SetHeight;
       property  Rotate: integer read FRotate write FRotate;
       property  Text: String read GetText write FText;
       property  FontSize: Double read FFontSize write FFontSize;
       property  FontStyle: TFontStyles read FFontStyle write FFontStyle;
       property  FontName: AnsiString read FFontName write FFontName;
       property  StyleName: AnsiString read FStyleName write FStyleName;
       property  Align: TgaAttachmentPoint read FAlign write FAlign;
   public
       //Параметр для реализации функций программы.
       property  GroupTagName: ShortString read FGroupTagName write FGroupTagName;

       procedure Draw(ABasePoint:TFloatPoint; AText: String;
         AAlign: TgaAttachmentPoint; ARotate:integer);overload;
       procedure Draw(ABasePoint:TFloatPoint; AText: String;
         AAlign: TgaAttachmentPoint; AWidth,AHeight,ARotate:integer);overload;

       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
         LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
       function  GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean):Integer; override;
       function  GetSelect(TopLeft, BottomRight: TFloatPoint;
         AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
       procedure MoveVertex(Index:integer; NewVertex:TFloatPoint);override;
       procedure GetRectVertex(var ATopLeft,ABottomRight:TFloatPoint);override;

       constructor Create; override;
       destructor Destroy; override;
   end;

   { TGraphicAttribute }

   // Текс-Атрибут для отображения параметров из класса TGraphicBlock
   TGraphicAttribute              = class(TGraphicText)
   private
      FAttributeName: ShortString;
      function GetText: String; override;
   published
      //Параметр поиска значения в атрибутах блока
       property  AttributeName: ShortString read FAttributeName
                                            write FAttributeName;
   public
       constructor Create; override;
   end;

   { TGraphicBlock }
   // Блок
   TGraphicBlock               = class(TEntityBlockBasic)
   private
     procedure RepaintJoinVertex(Xshift, Yshift, AScaleX, AScaleY,
       AScaleZ: Double; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
     procedure SetScale(AValue: Double);
     function GetJoinVertex(Index: Integer): TFloatPoint; override;
     function GetJoinVertexCount: Integer; override;
     procedure SetJoinVertex(Index: Integer; AValue: TFloatPoint); override;
   published
       property  ScaleX: Double read FScaleX write FScaleX;
       property  ScaleY: Double read FScaleY write FScaleY;
       property  ScaleZ: Double read FScaleZ write FScaleZ;
       property  Scale: Double write SetScale;
   public
       function AddJoinVertex(X, Y, Z: Double): Integer; override;
       procedure DeleteJoinVertex(Index: Integer); override;
       procedure InsertJoinVertex(Index: Integer; X, Y, Z: Double); override;
       procedure SetJoinName(Index: Integer;AName:String); override;
       function GetJoinName(Index: Integer):String; override;

       procedure SetAttributeValue(AName, AValue:String); override;
       function GetAttributeValue(AName:String):String; override;

       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
         LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw);  override;
       procedure Draw(ABasePoint:TFloatPoint; ABlockID:string;
         AScaleX,AScaleY,AScaleZ:Double; ARotate:integer);overload;

       procedure MoveAllJoinVertex(ADeltaVertex:TFloatPoint);override;
   end;


const

  DELTASELECTVERTEX            = 10;

  //the affected area
  AFFA_OUTSIDE                 =-1; //Вне периметра
  AFFA_BASEPOINT               =0; //Базовая точка
  AFFA_VERTEX                  =1; //Вершина
  AFFA_INSIDE                  =2; //В периметре
  AFFA_BORDER                  =3; //Граница

  VERTEXMARKER_BASEPOINT_SEL   =-2; //Базовая точка
  VERTEXMARKER_VERTEX_SEL      =-3; //Вершина

  VERTEXMARKER_OUTSIDE         =-1; //Вне периметра
  VERTEXMARKER_BASEPOINT       =0; //Базовая точка
  VERTEXMARKER_VERTEX          =1; //Вершина
  VERTEXMARKER_INSIDE          =2; //В периметре
  VERTEXMARKER_BORDER          =3; //Граница
  VERTEXMARKER_CENTER          =4; //Центр

  LINETYPE_SOLID               ='LT_SOLID';
  LINETYPE_SELECTED            ='LT_SELECTED';

  JOINVERTEX_PADDING_Y         =7;
  JOINVERTEX_PADDING_X         =7;

  BYPASSVERTEX_PADDING_Y       =7;
  BYPASSVERTEX_PADDING_X       =7;

function SetNullToFloatPoint:TFloatPoint;
function FloatPoint(X,Y,Z:Double):TFloatPoint;
procedure SetDeltaToRectPoint(var TopLeft, BottomRight:TFloatPoint; DeltaVertex:Double);
function PointIn2DRect(Point, RectTopLeft, RectBottomRight: TFloatPoint): Boolean;
function CordEqualIn2D(APoint,BPoint: TFloatPoint):boolean;
function CordEqualIn3D(APoint,BPoint: TFloatPoint):boolean;
procedure GetRectCord(const Align:TgaAttachmentPoint; X0,Y0,AWidth,AHeight:Double; var TopLeftPointWCS,BottomRightPointWCS: TFloatPoint);
procedure GetEntityListRectVertex(AEntityList:TEntityList; var ATopLeft, ABottomRight: TFloatPoint);

implementation

function SetNullToFloatPoint:TFloatPoint;
var
  APoint:TFloatPoint;
begin
  APoint.X:=0;
  APoint.Y:=0;
  APoint.Z:=0;
  Result:=APoint;
end;

function FloatPoint(X,Y,Z:Double):TFloatPoint;
var
  APoint:TFloatPoint;
begin
  APoint.X:=X;
  APoint.Y:=Y;
  APoint.Z:=Z;
  Result:=APoint;
end;

procedure SetDeltaToRectPoint(var TopLeft, BottomRight:TFloatPoint; DeltaVertex:Double);
begin
      //DeltaVertex:=FDeltaCord+5;
      TopLeft.X     :=TopLeft.X-DeltaVertex;
      TopLeft.Y     :=TopLeft.Y+DeltaVertex;
      BottomRight.X :=BottomRight.X+DeltaVertex;
      BottomRight.Y :=BottomRight.Y-DeltaVertex;
end;

function PointIn2DRect(Point, RectTopLeft, RectBottomRight: TFloatPoint): Boolean;
begin
  Result:=PointInRect2D(Point.X,Point.Y,RectTopLeft.X,RectTopLeft.Y,RectBottomRight.X,RectBottomRight.Y);
end;

function CordEqualIn2D(APoint,BPoint: TFloatPoint):boolean;
begin
  if (APoint.X=BPoint.X)and(APoint.Y=BPoint.Y) then
      Result:=true
  else
      Result:=false;
end;

function CordEqualIn3D(APoint,BPoint: TFloatPoint):boolean;
begin
  if (APoint.X=BPoint.X)and(APoint.Y=BPoint.Y)and(APoint.Z=BPoint.Z) then
      Result:=true
  else
      Result:=false;
end;

procedure GetRectCord(const Align:TgaAttachmentPoint;
  X0,Y0,AWidth,AHeight:Double; var TopLeftPointWCS,BottomRightPointWCS: TFloatPoint);
begin
      case Align of
      gaAttachmentPointTopLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0-AHeight;
      end;
      gaAttachmentPointTopCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth/2;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0+AWidth/2;
          BottomRightPointWCS.Y:=Y0-AHeight;
      end;
      gaAttachmentPointTopRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0-AHeight;
      end;
      gaAttachmentPointMiddleLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0+AHeight/2;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0-AHeight/2;
      end;
      gaAttachmentPointMiddleCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth/2;
          TopLeftPointWCS.Y:=Y0+AHeight/2;
          BottomRightPointWCS.X:=X0+AWidth/2;
          BottomRightPointWCS.Y:=Y0-AHeight/2;
      end;
      gaAttachmentPointMiddleRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0+AHeight/2;
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0-AHeight/2;
      end;
      gaAttachmentPointBottomLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0+AHeight;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0;
      end;
      gaAttachmentPointBottomCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth/2;
          TopLeftPointWCS.Y:=Y0+AHeight;
          BottomRightPointWCS.X:=X0+AWidth/2;
          BottomRightPointWCS.Y:=Y0;
      end;
      gaAttachmentPointBottomRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0+AHeight;
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0;
      end;
      end;
end;

procedure GetEntityListRectVertex(AEntityList:TEntityList; var ATopLeft, ABottomRight: TFloatPoint);
var
   x1TopLeft,x1BottomRight: TFloatPoint;
   x2TopLeft,x2BottomRight: TFloatPoint;
   i,iSX,iSY:integer;
begin
  x1TopLeft:=SetNullToFloatPoint;
  x2TopLeft:=SetNullToFloatPoint;
  x1BottomRight:=SetNullToFloatPoint;
  x2BottomRight:=SetNullToFloatPoint;

  if AEntityList.Count>0 then
  begin
       AEntityList.Items[0].GetRectVertex(x1TopLeft,x1BottomRight);
       x2TopLeft.X:=x1TopLeft.X;
       x2TopLeft.Y:=x1TopLeft.Y;
       x2BottomRight.X:=x1BottomRight.X;
       x2BottomRight.Y:=x1BottomRight.Y;
  end;

  for i:=1 to AEntityList.Count-1 do
  begin
           iSX:=1;
           iSY:=1;

           AEntityList.Items[i].GetRectVertex(x1TopLeft,x1BottomRight);
           if (x1TopLeft.X*iSX)<x2TopLeft.X then x2TopLeft.X:=(x1TopLeft.X*iSX);
           if (x1TopLeft.Y*iSY)>x2TopLeft.Y then x2TopLeft.Y:=(x1TopLeft.Y*iSY);

           if (x1BottomRight.X*iSX)>x2BottomRight.x then x2BottomRight.X:=(x1BottomRight.X*iSX);
           if (x1BottomRight.Y*iSY)<x2BottomRight.Y then x2BottomRight.Y:=(x1BottomRight.Y*iSY);
  end;

  ATopLeft:=x2TopLeft;
  ABottomRight:=x2BottomRight;
end;

{ TGraphicAttribute }

function TGraphicAttribute.GetText: String;
var
  OwnerBlockTmp:TEntityBlockBasic;
begin
  if (Length(FAttributeName)>0)and(Assigned(ParentList)) then
  begin
     OwnerBlockTmp:=nil;
     if ParentList.FModelSpace is TBlockItem then
     begin
        OwnerBlockTmp:=TBlockItem(ParentList.FModelSpace).OwnerBlock;
     end;

     if Assigned(OwnerBlockTmp) and (OwnerBlockTmp is TGraphicBlock) then
     begin
        Result:=TGraphicBlock(OwnerBlockTmp).GetAttributeValue(AttributeName);
     end
     else begin
        Result:='#'+AttributeName;
     end;
  end
  else begin
     Result:=FText;
  end;
end;

constructor TGraphicAttribute.Create;
begin
  inherited Create;
  FAttributeName :='';
end;

{ TBlockItem }

constructor TBlockItem.Create;
begin
  inherited Create;
  FCurPaintOwnerBlock:=nil;
end;

{ TGraphicRectangel }

function TGraphicRectangel.GetBottomRightPoint: TFloatPoint;
begin
 Result:=Vertex[2];
end;

function TGraphicRectangel.GetClosed: Boolean;
begin
  Result:=True;
end;

function TGraphicRectangel.GetTopLeftPoint: TFloatPoint;
begin
 Result:=Vertex[0];
end;

procedure TGraphicRectangel.SetBottomRightPoint(AValue: TFloatPoint);
begin
 MoveVertex(2, AValue);
end;

procedure TGraphicRectangel.SetClosed(AValue: Boolean);
begin
  inherited SetClosed(True);
end;

procedure TGraphicRectangel.SetTopLeftPoint(AValue: TFloatPoint);
begin
  MoveVertex(0, AValue);
end;

procedure TGraphicRectangel.MoveVertex(Index: integer; NewVertex: TFloatPoint);
var
  TmpVertex: TFloatPoint;
  Delta:TFloatPoint;
begin
        if Index=0 then
        begin
            Delta.X:=NewVertex.X-VertexAxleX[Index];
            Delta.Y:=NewVertex.Y-VertexAxleY[Index];
            Delta.Z:=NewVertex.Z-VertexAxleZ[Index];
            MoveGroupChildEntity(Delta);

            TmpVertex:=Vertex[Index];
            TmpVertex.X:=NewVertex.X;
            TmpVertex.Y:=NewVertex.Y;
            TmpVertex.Z:=NewVertex.Z;
            Vertex[Index]:=TmpVertex;

            TmpVertex:=Vertex[1];
            TmpVertex.Y:=Vertex[Index].Y;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[1]:=TmpVertex;

            TmpVertex:=Vertex[3];
            TmpVertex.X:=Vertex[Index].X;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[3]:=TmpVertex;
        end
        else if (Index=1) then
        begin
            TmpVertex:=Vertex[Index];
            TmpVertex.X:=NewVertex.X;
            TmpVertex.Y:=NewVertex.Y;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[Index]:=TmpVertex;

            TmpVertex:=Vertex[0];
            TmpVertex.Y:=Vertex[Index].Y;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[0]:=TmpVertex;

            TmpVertex:=Vertex[2];
            TmpVertex.X:=Vertex[Index].X;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[2]:=TmpVertex;
        end
        else if (Index=2) then
        begin
            TmpVertex:=Vertex[Index];
            TmpVertex.X:=NewVertex.X;
            TmpVertex.Y:=NewVertex.Y;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[Index]:=TmpVertex;

            TmpVertex:=Vertex[1];
            TmpVertex.X:=Vertex[Index].X;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[1]:=TmpVertex;

            TmpVertex:=Vertex[3];
            TmpVertex.Y:=Vertex[Index].Y;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[3]:=TmpVertex;
        end
        else if (Index=3) then
        begin
            TmpVertex:=Vertex[Index];
            TmpVertex.X:=NewVertex.X;
            TmpVertex.Y:=NewVertex.Y;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[Index]:=TmpVertex;

            TmpVertex:=Vertex[0];
            TmpVertex.X:=Vertex[Index].X;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[0]:=TmpVertex;

            TmpVertex:=Vertex[2];
            TmpVertex.Y:=Vertex[Index].Y;
            TmpVertex.Z:=Vertex[0].Z;
            Vertex[2]:=TmpVertex;
        end;
end;

procedure TGraphicRectangel.Repaint(Xshift, Yshift, AScaleX, AScaleY,
  AScaleZ: Double; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
var
  TmpVertex0: TFloatPoint;
  TmpVertex1: TFloatPoint;
  TmpVertex2: TFloatPoint;
  TmpVertex3: TFloatPoint;
begin
  if VertexCount=4 then
  begin
      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));

        TmpVertex0:=Vertex[0];
        TmpVertex1:=Vertex[1];
        TmpVertex2:=Vertex[2];
        TmpVertex3:=Vertex[3];
        //Конвертирование координаты при перемещении курсора
        if ((esMoving in State)or(esEditing in State)) then
        begin

        if ActionVertexIndex=0 then
        begin
            TmpVertex0:=GetInteractiveVertex(TmpVertex0);
            TmpVertex1.Y:=TmpVertex0.Y;
            TmpVertex3.X:=TmpVertex0.X;
        end
        else if (ActionVertexIndex=1) then
        begin
            TmpVertex1:=GetInteractiveVertex(TmpVertex1);
            TmpVertex0.Y:=TmpVertex1.Y;
            TmpVertex2.X:=TmpVertex1.X;
        end
        else if (ActionVertexIndex=2) then
        begin
            TmpVertex2:=GetInteractiveVertex(TmpVertex2);
            TmpVertex3.Y:=TmpVertex2.Y;
            TmpVertex1.X:=TmpVertex2.X;
        end
        else if (ActionVertexIndex=3) then
        begin
            TmpVertex3:=GetInteractiveVertex(TmpVertex3);
            TmpVertex2.Y:=TmpVertex3.Y;
            TmpVertex0.X:=TmpVertex3.X;
        end;
        end;

      LogicalDrawing.LineDraw((TmpVertex0.X*AScaleX)+Xshift,(TmpVertex0.Y*AScaleY)+Yshift,(TmpVertex1.X*AScaleX)+Xshift,(TmpVertex1.Y*AScaleY)+Yshift);
      LogicalDrawing.LineDraw((TmpVertex1.X*AScaleX)+Xshift,(TmpVertex1.Y*AScaleY)+Yshift,(TmpVertex2.X*AScaleX)+Xshift,(TmpVertex2.Y*AScaleY)+Yshift);
      LogicalDrawing.LineDraw((TmpVertex2.X*AScaleX)+Xshift,(TmpVertex2.Y*AScaleY)+Yshift,(TmpVertex3.X*AScaleX)+Xshift,(TmpVertex3.Y*AScaleY)+Yshift);
      LogicalDrawing.LineDraw((TmpVertex3.X*AScaleX)+Xshift,(TmpVertex3.Y*AScaleY)+Yshift,(TmpVertex0.X*AScaleX)+Xshift,(TmpVertex0.Y*AScaleY)+Yshift);

  end;
end;

procedure TGraphicRectangel.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  TmpVertex0: TFloatPoint;
  TmpVertex1: TFloatPoint;
  TmpVertex2: TFloatPoint;
  TmpVertex3: TFloatPoint;
begin
  if (VertexCount=4) then
  begin

        TmpVertex0:=Vertex[0];
        TmpVertex1:=Vertex[1];
        TmpVertex2:=Vertex[2];
        TmpVertex3:=Vertex[3];
        //Конвертирование координаты при перемещении курсора
        if ((esMoving in State)or(esEditing in State)) then
        begin

        if ActionVertexIndex=0 then
        begin
            TmpVertex0:=GetInteractiveVertex(TmpVertex0);
            TmpVertex1.Y:=TmpVertex0.Y;
            TmpVertex3.X:=TmpVertex0.X;
        end
        else if (ActionVertexIndex=1) then
        begin
            TmpVertex1:=GetInteractiveVertex(TmpVertex1);
            TmpVertex0.Y:=TmpVertex1.Y;
            TmpVertex2.X:=TmpVertex1.X;
        end
        else if (ActionVertexIndex=2) then
        begin
            TmpVertex2:=GetInteractiveVertex(TmpVertex2);
            TmpVertex3.Y:=TmpVertex2.Y;
            TmpVertex1.X:=TmpVertex2.X;
        end
        else if (ActionVertexIndex=3) then
        begin
            TmpVertex3:=GetInteractiveVertex(TmpVertex3);
            TmpVertex2.Y:=TmpVertex3.Y;
            TmpVertex0.X:=TmpVertex3.X;
        end;
        end;

      LogicalDrawing.VertexDraw(TmpVertex0.X,TmpVertex0.Y,VERTEXMARKER_VERTEX);
      LogicalDrawing.VertexDraw(TmpVertex1.X,TmpVertex1.Y,VERTEXMARKER_VERTEX);
      LogicalDrawing.VertexDraw(TmpVertex2.X,TmpVertex2.Y,VERTEXMARKER_VERTEX);
      LogicalDrawing.VertexDraw(TmpVertex3.X,TmpVertex3.Y,VERTEXMARKER_VERTEX);

  end;
end;

constructor TGraphicRectangel.Create;
begin
  inherited Create;
  FClosed:=True;
end;

{ TBlockList }

function TBlockList.GetItem(Index: Integer): TBlockItem;
begin
   Result:=TBlockItem(inherited GetItem(Index));
end;

function TBlockList.GetBlock(Name: AnsiString): TBlockItem;
var
  i:integer;
  Item:TBlockItem;
begin
  Result:=nil;
  for i:=0 to Count-1 do
  begin
     Item:=TBlockItem(inherited GetItem(i));
     if Item.Name=Name then
     begin
          Result:=Item;
          break;
     end;
  end;
end;

procedure TBlockList.SetItem(Index: Integer; const Value: TBlockItem);
begin
   inherited SetItem(Index, Value);
end;

procedure TBlockList.SetBlock(Name: AnsiString; AValue: TBlockItem);
var
   i:integer;
   Item:TBlockItem;
begin
  for i:=0 to Count-1 do
  begin
     Item:=TBlockItem(inherited GetItem(i));
     if Item.Name=Name then
     begin
          inherited SetItem(i,AValue);
          break;
     end;
  end;
end;

constructor TBlockList.Create;
begin
  inherited Create;
  FOnGetDocumentEvent:=nil;
end;

function TBlockList.Add(AObject: TBlockItem): Integer;
begin
  if GetBlock(AObject.Name)=nil then
  begin
    Result:=inherited Add(AObject);
    AObject.FOnGetDocumentEvent:=FOnGetDocumentEvent;
  end
  else begin
    raise Exception.Create('Block name exists');
  end;
end;

procedure TBlockList.Insert(Index: Integer; AObject: TBlockItem);
begin
  inherited Insert(Index, AObject);
  AObject.FOnGetDocumentEvent:=FOnGetDocumentEvent;
end;

procedure TBlockList.ClearByPrefix(APrefix: AnsiString; AInver:Boolean);
var
   i:integer;
   s1,s2:AnsiString;
   b:boolean;
begin
   s1:=UpperCase(APrefix);
   for i:=Count-1 downto 0 do
   begin
      s2:=UpperCase(items[i].FName);
      b:=(Pos(s1, s2)=1);
      if AInver then
         b:=not b;
      if b then
      begin
         Delete(i);
      end;
   end;
end;

{ TWorkSpaceCustom }

function TWorkSpaceCustom.GetDocument: TDrawDocumentCustom;
begin
  if Assigned(FOnGetDocumentEvent) then
      Result:=FOnGetDocumentEvent()
  else
      Result:=nil;
end;

constructor TWorkSpaceCustom.Create;
begin
    inherited Create;
    FOnGetDocumentEvent       :=nil;
    FSelectedEntityList       :=nil;
    FEntityList               :=TEntityList.Create;
    FEntityList.ID            :=ENTITYLIST_ID;
    FEntityList.FModelSpace   :=TWorkSpace(Self);

    FBottomRight              :=SetNullToFloatPoint;
    FTopLeft                  :=SetNullToFloatPoint;
end;

destructor TWorkSpaceCustom.Destroy;
begin
     FSelectedEntityList:=nil;
     FEntityList.Free;
     inherited Destroy;
end;

procedure TWorkSpaceCustom.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
begin
  FEntityList.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,AStyle);
end;

procedure TWorkSpaceCustom.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
     FEntityList.RepaintVertex(LogicalDrawing);
end;

procedure TWorkSpaceCustom.DeselectAll;
begin
  if Assigned(ThisDocument) then
     ThisDocument.DeselectAll;
end;

function TWorkSpaceCustom.GetColor(AColor: TgaColor): TgaColor;
begin
      if AColor=gaByBlock then
      begin
          Result:=FByBlockColor;
      end
      else begin
          Result:=AColor;
      end;
end;

function TWorkSpaceCustom.GetLineWeight(LineWeight: TgaLineWeight): TgaLineWeight;
begin
      if (LineWeight=gaLnWtByBlock) then
      begin
          Result:=FByBlockLineWeight;
      end
      else begin
          Result:=LineWeight;
      end;
end;

procedure TWorkSpaceCustom.GetRectVertex(var ATopLeft, ABottomRight: TFloatPoint);
begin
  GetEntityListRectVertex(FEntityList,ATopLeft,ABottomRight);
end;

procedure TWorkSpaceCustom.MoveEntityGroup(AOwnerGroup: TEntityID; APoint: TFloatPoint);
var
   i,c:integer;
   dX,dY,dZ:Double;
   NewVertex: TFloatPoint;
begin
   dX:=0;
   dY:=0;
   dZ:=0;
   c:=0;
   for i:=0 to Objects.Count-1 do
   begin
      if Objects.Items[i].ID=AOwnerGroup then
      begin
         dX:=APoint.X-Objects.Items[i].VertexAxleX[0];
         dY:=APoint.Y-Objects.Items[i].VertexAxleY[0];
         dZ:=APoint.Z-Objects.Items[i].VertexAxleZ[0];
         Objects.Items[i].MoveVertex(0,APoint);
         inc(c);
         break;
      end;
   end;
   if c>0 then
   begin
   for i:=0 to Objects.Count-1 do
   begin
      if Objects.Items[i].GroupOwner=AOwnerGroup then
      begin
         NewVertex.X:=Objects.Items[i].VertexAxleX[0]+dX;
         NewVertex.Y:=Objects.Items[i].VertexAxleY[0]+dY;
         NewVertex.Z:=Objects.Items[i].VertexAxleZ[0]+dZ;
         Objects.Items[i].MoveVertex(0,NewVertex);
      end;
   end;
   end;
end;

{ TFloatPointList }

function TFloatPointList.GetCount: Integer;
begin
     Result:=Flist.Count;
end;

function TFloatPointList.GetPoint(Index: Integer): TFloatPoint;
begin
try
     Result:=TFloatPoint(PFloatPoint(FList.Items[Index])^);
except
     abort;
end;
end;

function TFloatPointList.NewPoint(X, Y, Z: Double): PFloatPoint;
var
  NPoint: PFloatPoint;
begin
  // Выделяем память под новую точку
  New(NPoint);
  NPoint^.X := X;
  NPoint^.Y := Y;
  NPoint^.Z := Z;
  Result    := NPoint;
end;

procedure TFloatPointList.SetPoint(Index: Integer; const Value: TFloatPoint);
begin
try
  PFloatPoint(FList.Items[Index])^:=Value;
except

end;
end;

constructor TFloatPointList.Create;
begin
  inherited Create;
  FList:=TList.Create;
end;

destructor TFloatPointList.Destroy;
var
  i: Integer;
begin
  // Перед уничтожением списка, освобождаем память
  for i := Count - 1 downto 0  do Delete(i);
  FList.Free;
  inherited Destroy;
end;

function TFloatPointList.Add(X, Y, Z: Double): Integer;
begin
     Result:=FList.Add(NewPoint(X,Y,Z));
end;

procedure TFloatPointList.Insert(Index: Integer; X, Y, Z: Double);
begin
  FList.Insert(Index,NewPoint(X,Y,Z));
end;

procedure TFloatPointList.Delete(Index: Integer);
begin
  Dispose(PFloatPoint(FList.items[index]));
  FList.Delete(Index);
end;

function TFloatPointList.Extract(Index: Integer): PFloatPoint;
var
  APoint: PFloatPoint;
begin
  APoint:=PFloatPoint(FList.items[index]);
  FList.Delete(Index);
  Result:=APoint;
end;


{ TEntityBasic }

constructor TEntityBasic.Create;
begin
     inherited Create;
     FID                 :='';
     FOnGetDocumentEvent :=nil;
     FState              :=[esCreating];
     FBlocked            :=false;
     FLineWeight         :=gaLnWtByBlock;
     FColor              :=gaByBlock;
     FLayerName          :='0';
     FTag                :=0;
     FData               :=nil;
end;

procedure TEntityBasic.Created;
begin
  if ID='' then
     raise Exception.Create('Не задан ID')
  else
     FState:=[esNone];
end;

destructor TEntityBasic.Destroy;
begin
    inherited Destroy;
end;

procedure TEntityBasic.BeginUpdate;
begin
     FBlocked:=true;
end;

procedure TEntityBasic.EndUpdate;
begin
     FBlocked:=false;
end;

function TEntityBasic.GetColor(AColor: TgaColor): TgaColor;
begin
try
    if (AColor=gaByBlock)or(AColor=gaByLayer) then
    begin
      Result:=FParentList.FModelSpace.GetColor(AColor);
    end
    else begin
      Result:=AColor;
    end;

except

end;
end;

function TEntityBasic.GetLineWeight(ALineWeight: TgaLineWeight): TgaLineWeight;
begin
try
    if (ALineWeight=gaLnWtByLayer)
        or(ALineWeight=gaLnWtByLwDefault)or(ALineWeight=gaLnWtByBlock) then
    begin
      Result:=FParentList.FModelSpace.GetLineWeight(ALineWeight);
    end
    else begin
      Result:=ALineWeight;
    end;
except

end;
end;

function TEntityBasic.GetColor: TgaColor;
begin
  Result:=FColor;
end;

function TEntityBasic.GetLineWeight: TgaLineWeight;
begin
  Result:=FLineWeight;
end;

{ TEntity }

procedure TEntity.AddVertex(X, Y, Z: Double);
begin
  FVertex.Add(x,y,z);
  if assigned(FParentList) then
  FParentList.ChangeCordVertex(FloatPoint(x,y,z));
end;

constructor TEntity.Create;
begin
     inherited Create;
     FVertex              :=TFloatPointList.Create;
     FActionVertexDelta.X :=0;
     FActionVertexDelta.Y :=0;
     FActionVertexDelta.Z :=0;
     FActionVertexIndex   :=-1;
end;

procedure TEntity.DeleteVertex(Index: Integer);
begin
  FVertex.Delete(Index);
end;

function TEntity.GetOwnerGroup: TEntity;
var
  i:integer;
  Item:TEntity;
begin
  Result:=nil;
  if Length(FGroupOwner)>0 then
  begin
    for i:=0 to ThisDocument.FModelSpace.Objects.Count-1 do
    begin
       Item:=ThisDocument.FModelSpace.Objects.Items[i];
       if ShortCompareText(Item.ID,FGroupOwner)=0 then
       begin
          Result:=Item;
          break;
       end;
    end;
  end;
end;

function TEntity.RepaintOwnerGroupMove: TEntity;
var
  i:integer;
  Item:TEntity;
begin
  Result:=nil;
  if Length(FGroupOwner)>0 then
  begin
    for i:=0 to ThisDocument.FModelSpace.Objects.Count-1 do
    begin
       Item:=ThisDocument.FModelSpace.Objects.Items[i];
       if ShortCompareText(Item.ID,FGroupOwner)=0 then
       begin
          if esMoving in Item.State then
          begin
             Result:=Item;
          end;
          break;
       end;
    end;
  end;
end;

destructor TEntity.Destroy;
begin
  FVertex.Free;
  inherited Destroy;
end;

procedure TEntity.GetRectVertex(var ATopLeft, ABottomRight: TFloatPoint);
var
  i:integer;
  tmpTopLeft,
  tmpBottomRight: TFloatPoint;
begin
  tmpTopLeft:=SetNullToFloatPoint;
  tmpBottomRight:=SetNullToFloatPoint;

  for i:=0 to VertexCount-1 do
  begin
       if (Vertex[i].X)<tmpTopLeft.X then tmpTopLeft.X:=(Vertex[i].X);
       if (Vertex[i].Y)>tmpTopLeft.Y then tmpTopLeft.Y:=(Vertex[i].Y);
       if (Vertex[i].X)>tmpBottomRight.X then tmpBottomRight.X:=(Vertex[i].X);
       if (Vertex[i].Y)<tmpBottomRight.Y then tmpBottomRight.Y:=(Vertex[i].Y);
  end;
  ATopLeft:=tmpTopLeft;
  ABottomRight:=tmpBottomRight;
end;

function TEntity.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
begin
  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  Result:=AFFA_OUTSIDE; //Вне периметра
  CountVertexInRect:=0;
  for I := 0 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
    Result:=AFFA_VERTEX
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
    Result:=AFFA_VERTEX;
end;

function TEntity.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TEntity.GetVertex(Index: Integer): TFloatPoint;
begin
  Result:=FVertex.Items[index];
end;

function TEntity.GetVertexAxleX(Index: Integer): Double;
begin
  Result:=Vertex[Index].X;
end;

function TEntity.GetVertexAxleY(Index: Integer): Double;
begin
  Result:=Vertex[Index].Y;
end;

function TEntity.GetVertexAxleZ(Index: Integer): Double;
begin
  Result:=Vertex[Index].Z;
end;

function TEntity.GetDocument: TDrawDocumentCustom;
begin
  if Assigned(FOnGetDocumentEvent) then
      Result:=FOnGetDocumentEvent()
  else
      Result:=nil;
end;

function TEntity.GetVertexCount: Integer;
begin
  Result:=FVertex.Count;
end;

procedure TEntity.InsertVertex(Index: Integer; X, Y, Z: Double);
begin
  FVertex.Insert(Index,X,Y,Z);
  if assigned(FParentList) then
  FParentList.ChangeCordVertex(FloatPoint(x,y,z));
end;

procedure TEntity.MoveVertex(Index:integer; NewVertex: TFloatPoint);
var
  Delta:TFloatPoint;
begin
  if Index>-1 then
  begin
        if Index=0 then
        begin
          Delta.X:=NewVertex.X-VertexAxleX[Index];
          Delta.Y:=NewVertex.Y-VertexAxleY[Index];
          Delta.Z:=NewVertex.Z-VertexAxleZ[Index];

          MoveGroupChildEntity(Delta);
        end;

        VertexAxleX[Index]:=NewVertex.X;
        VertexAxleY[Index]:=NewVertex.Y;
        VertexAxleZ[Index]:=NewVertex.Z;
  end;
end;

procedure TEntity.MoveEntity(ADeltaVertex: TFloatPoint);
var
  TmpVertex :TFloatPoint;
  i         :integer;
begin
  for I := 0 to VertexCount - 1 do
  begin
     TmpVertex   :=Vertex[i];
     TmpVertex.X :=TmpVertex.X+ADeltaVertex.X;
     TmpVertex.Y :=TmpVertex.Y+ADeltaVertex.Y;
     TmpVertex.Z :=TmpVertex.Z+ADeltaVertex.Z;
     Vertex[i]   :=TmpVertex;
  end;
end;

procedure TEntity.MoveGroupChildEntity(ADeltaVertex: TFloatPoint);
var
  i        :integer;
  Document :TDrawDocumentCustom;
  Item     :TEntity;
begin
  Document:=ThisDocument;
  if Assigned(Document) then
  begin
    for i:=0 to Document.FModelSpace.Objects.Count-1 do
    begin
        Item:=Document.FModelSpace.Objects.Items[i];
        if ShortCompareText(Item.GroupOwner,FID)=0 then
        begin
           Item.MoveEntity(ADeltaVertex);
        end;
    end;
  end;
end;

procedure TEntity.Repaint(LogicalDrawing: TLogicalDraw;
  Style: TEntityDrawStyle);
begin
  Repaint(0,0,1,1,1,LogicalDrawing,Style);
end;

procedure TEntity.SetVertex(Index: Integer; const Value: TFloatPoint);
begin
  FVertex.Items[Index]:=Value;
  if assigned(FParentList) then
  FParentList.ChangeCordVertex(FVertex.Items[Index]);
end;

procedure TEntity.SetVertexAxleX(Index: Integer; const Value: Double);
var
  A:TFloatPoint;
begin
  A:=FVertex.Items[Index];
  A.X:=Value;
  FVertex.Items[Index]:=A;
end;

procedure TEntity.SetVertexAxleY(Index: Integer; const Value: Double);
var
  A:TFloatPoint;
begin
  A:=FVertex.Items[Index];
  A.Y:=Value;
  FVertex.Items[Index]:=A;
end;

procedure TEntity.SetVertexAxleZ(Index: Integer; const Value: Double);
var
  A:TFloatPoint;
begin
  A:=FVertex.Items[Index];
  A.Z:=Value;
  FVertex.Items[Index]:=A;
end;

function TEntity.GetInteractiveVertex(AVertex:TFloatPoint): TFloatPoint;
var
  x:double;
  CurCord,
  NewCord :TFloatPoint;
begin
      x:=ActionVertexDelta.X;
      x:=x+ActionVertexDelta.Y;
      x:=x+ActionVertexDelta.Z;
      if (x<>0) then
      begin
          CurCord    :=AVertex;
          NewCord.Y  :=CurCord.Y+ActionVertexDelta.Y;
          NewCord.X  :=CurCord.X+ActionVertexDelta.X;
          NewCord.Z  :=CurCord.Z+ActionVertexDelta.Z;
          Result:=NewCord;
      end
      else begin
          Result:=AVertex;
      end;
end;

function TEntity.GetGroupOwnerInteractiveVertex(AGroupOwner:TEntity;
  AVertex:TFloatPoint): TFloatPoint;
var
  x:double;
  CurCord,
  NewCord :TFloatPoint;
begin
      x:=AGroupOwner.ActionVertexDelta.X;
      x:=x+AGroupOwner.ActionVertexDelta.Y;
      x:=x+AGroupOwner.ActionVertexDelta.Z;
      if (x<>0) then
      begin
          CurCord    :=AVertex;
          NewCord.Y  :=CurCord.Y+AGroupOwner.ActionVertexDelta.Y;
          NewCord.X  :=CurCord.X+AGroupOwner.ActionVertexDelta.X;
          NewCord.Z  :=CurCord.Z+AGroupOwner.ActionVertexDelta.Z;
          Result:=NewCord;
      end
      else begin
          Result:=AVertex;
      end;
end;

{ TGraphicLine }

procedure TGraphicLine.Draw(APoint1, APoint2: TFloatPoint);
begin
  if VertexCount=0 then
  begin
    AddVertex(APoint1.X,APoint1.Y,APoint1.Z);
    AddVertex(APoint2.X,APoint2.Y,APoint2.Z);
  end;
end;

procedure TGraphicLine.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  TmpVertex1,TmpVertex2:TFloatPoint;
begin
  if (VertexCount>=2) then
  begin
       if (esMoving in State) then
       begin
             TmpVertex1:=GetInteractiveVertex(Vertex[0]);
             TmpVertex2:=GetInteractiveVertex(Vertex[1]);
       end
       else if (esEditing in State) then
       begin
         case ActionVertexIndex of
              0:
              begin
                 TmpVertex1:=GetInteractiveVertex(Vertex[0]);
                 TmpVertex2:=Vertex[1];
              end;
              1:
              begin
                 TmpVertex1:=Vertex[0];
                 TmpVertex2:=GetInteractiveVertex(Vertex[1]);
              end;
         end;
       end
       else begin
        TmpVertex1:=Vertex[0];
        TmpVertex2:=Vertex[1];
       end;

      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
      LogicalDrawing.LineDraw((TmpVertex1.X*AScaleX)+Xshift,(TmpVertex1.Y*AScaleY)+Yshift,(TmpVertex2.X*AScaleX)+Xshift,(TmpVertex2.Y*AScaleY)+Yshift);
  end;
end;

procedure TGraphicLine.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex:TFloatPoint;
begin
  if (VertexCount>0) then
  begin
    for i:=0 to VertexCount-1 do
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=i) then
        TmpVertex:=GetInteractiveVertex(Vertex[i]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[i];

      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;

{ TGraphicPolyline }

function TGraphicPolyline.GetClosed: Boolean;
begin
  Result:=FClosed;
end;

procedure TGraphicPolyline.SetClosed(AValue: Boolean);
begin
  if FClosed<> AValue then
     FClosed:=AValue;
end;

procedure TGraphicPolyline.Draw(APoints: TPointsArray; AClosed: Boolean);
var
  i:integer;
begin
    for i:=0 to Length(APoints)-1 do
    begin
      AddVertex(APoints[i].X,APoints[i].Y,APoints[i].Z);
    end;

    if (AClosed)and(Length(APoints)>3)then
      FClosed:=true
    else
      FClosed:=false;
end;

procedure TGraphicPolyline.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  i:integer;
  TmpVertex,
  fpoint:TFloatPoint;
begin
  if VertexCount>1 then
  begin
      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));

    if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=0) then
      fpoint:=GetInteractiveVertex(Vertex[0]) //Конвертирование координаты при перемещении курсора
    else
      fpoint:=Vertex[0];

    for i:=1 to VertexCount-1 do
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=i) then
        TmpVertex:=GetInteractiveVertex(Vertex[i]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[i];

      LogicalDrawing.LineDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,(TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift);

        fpoint:=TmpVertex;
    end;


    if (FClosed)and (VertexCount>2) then
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=0) then
        TmpVertex:=GetInteractiveVertex(Vertex[0]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[0];

      LogicalDrawing.LineDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,(TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift);
    end;
  end;
end;

procedure TGraphicPolyline.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex:TFloatPoint;
begin
  if (VertexCount>0) then
  begin
    for i:=0 to VertexCount-1 do
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=i) then
        TmpVertex:=GetInteractiveVertex(Vertex[i]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[i];

      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;

{ TGraphicConnectionline }


function TGraphicConnectionline.ObjectYPosition(AItem:TEntity; AVertex:TFloatPoint): integer;
var
  i,iup,idwn  :integer;
begin
  Result:=0;
  iup:=0;
  idwn:=0;
  if Assigned(AItem) then
  begin
     for i:=0 to AItem.VertexCount-1 do
     begin
       if AVertex.Y>AItem.Vertex[i].Y then
       inc(idwn)
       else if AVertex.Y<AItem.Vertex[i].Y then
       inc(iup);
     end;

     if (AItem.VertexCount=iup)or((iup>0)and(idwn=0)) then
        Result:=-1
     else if (AItem.VertexCount=idwn)or((idwn>0)and(iup=0)) then
        Result:=1;
  end;
end;

function TGraphicConnectionline.ObjectXPosition(AItem: TEntity;
  AVertex: TFloatPoint): integer;
var
  i,iup,idwn  :integer;
begin
  Result:=0;
  iup:=0;
  idwn:=0;
  if Assigned(AItem) then
  begin
     for i:=0 to AItem.VertexCount-1 do
     begin
       if AVertex.X>AItem.Vertex[i].X then
       inc(idwn)
       else if AVertex.X<AItem.Vertex[i].X then
       inc(iup);
     end;

     if (AItem.VertexCount=iup)or((iup>0)and(idwn=0)) then
        Result:=-1
     else if (AItem.VertexCount=idwn)or((idwn>0)and(iup=0)) then
        Result:=1;
  end;
end;

procedure TGraphicConnectionline.GetBypassPoints(AItem:TEntity; AStartVertex:TFloatPoint; ALeft,ATop:Boolean; var AOutBypassPoints:TPointsArray);
var
  i,c,n  :integer;
  iMax   :double;
  TmpPoint :TFloatPoint;
begin
  if Assigned(AItem) then
  begin
     if ALeft then
     begin
         iMax:=AStartVertex.X;
         for i:=0 to AItem.VertexCount-1 do
         begin
           if AItem.Vertex[i].X<iMax then
              iMax:=AItem.Vertex[i].X;
         end;
         iMax:=iMax-BYPASSVERTEX_PADDING_X;
     end
     else begin
         iMax:=AStartVertex.X;
         for i:=0 to AItem.VertexCount-1 do
         begin
           if AItem.Vertex[i].X>iMax then
              iMax:=AItem.Vertex[i].X;
         end;
         iMax:=iMax+BYPASSVERTEX_PADDING_X;
     end;

     TmpPoint.X:=iMax;
     TmpPoint.Y:=AStartVertex.Y;
     TmpPoint.Z:=AStartVertex.Z;

     c:=Length(AOutBypassPoints);
     n:=c+1;
     SetLength(AOutBypassPoints,n);
     AOutBypassPoints[c] :=TmpPoint;

     if ATop then
     begin
         iMax:=AStartVertex.Y;
         for i:=0 to AItem.VertexCount-1 do
         begin
           if AItem.Vertex[i].Y>iMax then
              iMax:=AItem.Vertex[i].Y;
         end;
         iMax:=iMax+BYPASSVERTEX_PADDING_Y;
     end
     else begin
         iMax:=AStartVertex.Y;
         for i:=0 to AItem.VertexCount-1 do
         begin
           if AItem.Vertex[i].Y<iMax then
              iMax:=AItem.Vertex[i].Y;
         end;
         iMax:=iMax-BYPASSVERTEX_PADDING_Y;
     end;

     TmpPoint.Y:=iMax;

     c:=Length(AOutBypassPoints);
     n:=c+1;
     SetLength(AOutBypassPoints,n);
     AOutBypassPoints[c] :=TmpPoint;
  end;
end;

function TGraphicConnectionline.GetBeginVertex(var AJoinExists:Boolean): TFloatPoint;
var
  ItemA    :TEntity;
  ItemB    :TEntityBlockBasic;
  TmpVertex:TFloatPoint;
begin
  AJoinExists :=False;
  ItemB       :=nil;
  ItemA       :=ThisDocument.FModelSpace.Objects.GetEntityByID(FBeginEntityID);

  if Assigned(ItemA)and(ItemA is TEntityBlockBasic) then
  begin
    ItemB:=TEntityBlockBasic(ItemA);
    if Assigned(ItemB)and(ItemB.JoinVertexCount>0) then
    begin
      TmpVertex:=ItemB.GetRecalculatedJoinVertex(BeginEntityIndex);

      if esMoving in ItemB.State then
        Result:=ItemB.GetInteractiveVertex(TmpVertex)
      else
        Result:=TmpVertex;

      AJoinExists :=True;
    end
    else begin
        ItemB:=nil;
    end;
  end;

  if (not Assigned(ItemB))and Assigned(ItemA)and(ItemA.VertexCount>0) then
  begin
      if esMoving in ItemA.State then
        Result:=ItemA.GetInteractiveVertex(ItemA.Vertex[0])
      else
        Result:=ItemA.Vertex[0];
  end
  else if (not Assigned(ItemA))and(not Assigned(ItemB)) then
  begin
     Result.X:=0;
     Result.Y:=0;
     Result.Z:=0;
  end;
end;

function TGraphicConnectionline.GetEndVertex(var AJoinExists:Boolean): TFloatPoint;
var
  ItemA    :TEntity;
  ItemB    :TEntityBlockBasic;
  TmpVertex:TFloatPoint;
begin
  AJoinExists :=False;
  ItemB       :=nil;
  ItemA       :=ThisDocument.FModelSpace.Objects.GetEntityByID(FEndEntityID);

  if Assigned(ItemA)and(ItemA is TEntityBlockBasic) then
  begin
    ItemB:=TEntityBlockBasic(ItemA);
    if Assigned(ItemB)and(ItemB.JoinVertexCount>0) then
    begin
      TmpVertex:=ItemB.GetRecalculatedJoinVertex(EndEntityIndex);

      if esMoving in ItemB.State then
        Result:=ItemB.GetInteractiveVertex(TmpVertex)
      else
        Result:=TmpVertex;

      AJoinExists :=True;
    end
    else begin
        ItemB:=nil;
    end;
  end;

  if (not Assigned(ItemB))and Assigned(ItemA)and(ItemA.VertexCount>0) then
  begin
      if esMoving in ItemA.State then
        Result:=ItemA.GetInteractiveVertex(ItemA.Vertex[0])
      else
        Result:=ItemA.Vertex[0];
  end
  else if (not Assigned(ItemA))and(not Assigned(ItemB)) then
  begin
     Result.X:=0;
     Result.Y:=0;
     Result.Z:=0;
  end;
end;

function TGraphicConnectionline.GetBeginVertex: TFloatPoint;
var
  bJoinExists:Boolean;
begin
  Result:=GetBeginVertex(bJoinExists);
end;

function TGraphicConnectionline.GetEndVertex: TFloatPoint;
var
  bJoinExists:Boolean;
begin
  Result:=GetEndVertex(bJoinExists);
end;

procedure TGraphicConnectionline.Draw(APoints: TPointsArray; AClosed: Boolean);
var
  i:integer;
begin
    for i:=0 to Length(APoints)-1 do
    begin
      AddVertex(APoints[i].X,APoints[i].Y,APoints[i].Z);
    end;
end;

procedure TGraphicConnectionline.Repaint(Xshift, Yshift, AScaleX, AScaleY,
  AScaleZ: Double; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
var
  i        :integer;
  Points   :TPointsArray;
  fpoint   :TFloatPoint;
begin

    if AStyle=[edsSelected] then
       LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
    else
       LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
    {
    BeginBlock :=nil;
    EndBlock   :=nil;
    if Length(FEndBlockName)>0 then
       BeginBlock:=ThisDocument.FBlockList.GetBlock(FEndBlockName);
    if Length(FBeginBlockName)>0 then
       EndBlock:=ThisDocument.FBlockList.GetBlock(FBeginBlockName);
    }
    GetLinePointsVertex(Points);
    if Length(Points)>1 then
    begin
      fpoint:=Points[0];
      for i:=0 to high(Points) do
      begin
          LogicalDrawing.LineDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,(Points[i].X*AScaleX)+Xshift,(Points[i].Y*AScaleY)+Yshift);
          fpoint:=Points[i];
      end;
    end;

end;

procedure TGraphicConnectionline.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex:TFloatPoint;
begin
  if VertexCount>0 then
  begin
    for i:=0 to VertexCount-1 do
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=i) then
        TmpVertex:=GetInteractiveVertex(Vertex[i]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[i];

      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;

procedure TGraphicConnectionline.MoveVertex(Index: integer;
  NewVertex: TFloatPoint);
var
  Delta:TFloatPoint;
begin
    if Index=0 then
    begin
        Delta.X:=FMiddleLineOffsetX+NewVertex.X-VertexAxleX[Index];
        Delta.Y:=FMiddleLineOffsetY+NewVertex.Y-VertexAxleY[Index];
        Delta.Z:=NewVertex.Z-VertexAxleZ[Index];
        MoveGroupChildEntity(Delta);

        FMiddleLineOffsetY:=Delta.Y;
        FMiddleLineOffsetX:=Delta.X;
    end;
end;

function TGraphicConnectionline.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  bOnePointRect :boolean;
  Points        :TPointsArray;
  APoint,
  BPoint        :TFloatPoint;
  i,
  PointsCount,
  CountVertexInRect :integer;
begin
  //Объект нельзя выбрать за первую и последную точку

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);
  bOnePointRect :=False;
  Result        :=AFFA_OUTSIDE; //Вне периметра

  if (TopLeft.X=BottomRight.X)and
  ((TopLeft.Y=BottomRight.Y))and
  ((TopLeft.Z=BottomRight.Z)) then
  begin
     bOnePointRect:=True;
  end;

  GetLinePointsVertex(Points);

  CountVertexInRect :=0;
  PointsCount       :=high(Points);
  {for I := 1 to PointsCount-1 do
  begin
      if (i>0)and(bOnePointRect)then
      begin
         //Проверка на линии
         //ThisDocument.GetDeltaVertex
      end;
      if PointIn2DRect(Points[i], TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        {
        if not((i=0)or(i=c)) then
        begin
          MVertx.Item:=self;
          MVertx.VertexIndex:=-1;
          MVertx.VertexPos:=Points[i];
        end;
        }
      end;
  end;
  }
  // Проверка попадают ли вершины в зону выбора
  CountVertexInRect:=0;
  for I := 0 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end;

  // Проверка попадают ли промежуточные точки в зону выбора
    //ABCD
    if (not AllVertexInRect)and(PointsCount>1)and(Result<>AFFA_VERTEX) then
    begin
    APoint:=Points[0];
    for I := 1 to PointsCount do
    begin
      BPoint:=Points[i];
      //AC
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BD
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //AB
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BC
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //CD
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //DA
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      APoint:=BPoint;
    end;

   end;
end;

function isVectorUp(var APoints: TPointsArray):boolean;
var
  c:integer;
begin
  c:=high(APoints);
  if c>0 then
  begin
     if APoints[c].Y>APoints[c-1].Y then
        Result:=True
     else
        Result:=False;
  end
  else
      Result:=False;
end;

procedure TGraphicConnectionline.GetLinePointsVertex(var APoints: TPointsArray);
var
  iStyle,
  i,c,n    :integer;
  TmpPoint,
  spoint,
  spoint2,
  spoint3,
  spoint0,
  fpoint0,
  fpoint           :TFloatPoint;
  fBypassPoints    :TPointsArray;
  sBypassPoints    :TPointsArray;
  BeginItem        :TGraphicBlock;
  EndItem          :TGraphicBlock;
  TmpItem          :TGraphicBlock;
  bOnlyLeftByPass  :Boolean;
  bBeginBypass     :Boolean;
  bEndBypass       :Boolean;

  bBeginJoinExists :Boolean;
  bEndJoinExists   :Boolean;

  bBeginBypassEnabled :Boolean;
  bEndBypassEnabled   :Boolean;

  fPoints          :TPointsArray;
  sPoints          :TPointsArray;
begin
 SetLength(fPoints,0);
 SetLength(sPoints,0);

 iStyle:=2;

 bOnlyLeftByPass  :=False;
 BeginItem        :=TGraphicBlock(ThisDocument.FModelSpace.Objects.GetEntityByID(FBeginEntityID));
 EndItem          :=TGraphicBlock(ThisDocument.FModelSpace.Objects.GetEntityByID(FEndEntityID));

 bBeginJoinExists :=False;
 bEndJoinExists   :=False;


 {
  0- прямая линия
  1- горизонтальная
  2- вертикальная
  3- автовыбор горизонтальной и вертикальной
 }

 if iStyle=3 then
 begin
    fpoint:=GetBeginVertex(bBeginJoinExists);
    spoint:=GetEndVertex(bEndJoinExists);

    if abs(spoint.X-fpoint.X)>abs(spoint.Y-fpoint.Y) then
    begin
       iStyle:=1;
    end
    else begin
       iStyle:=2;
    end;
 end;

 if iStyle=0 then
 begin
    c:=Length(APoints);
    n:=c+1;
    SetLength(APoints,n);
    APoints[c]:=GetBeginVertex;


    for i:=0 to VertexCount-1 do
    begin
        c:=Length(APoints);
        n:=c+1;
        SetLength(APoints,n);
        APoints[c]:=Vertex[i];
    end;

    c:=Length(APoints);
    n:=c+1;
    SetLength(APoints,n);
    APoints[c]:=GetEndVertex;

 end
 else if iStyle=1 then  //горизонтально
 begin
   
   bBeginBypassEnabled :=True;
   bEndBypassEnabled   :=True;

   fpoint0  :=GetBeginVertex(bBeginJoinExists);
   fpoint   :=fpoint0;
   spoint0  :=GetEndVertex(bEndJoinExists);
   spoint   :=spoint0;

   if (spoint0.X>fpoint0.X) then
   begin
        //рокировка, если верх не начало
        TmpItem   :=BeginItem;
        BeginItem :=EndItem;
        EndItem   :=TmpItem;

        fpoint0   :=spoint;
        spoint0   :=fpoint;
        fpoint    :=fpoint0;
        spoint    :=spoint0;

        if bEndJoinExists then
        begin
           bEndJoinExists   :=bBeginJoinExists;
           bBeginJoinExists :=True;
        end
        else begin
           bEndJoinExists   :=bBeginJoinExists;
           bBeginJoinExists :=False;
        end;
   end;

   c:=Length(fPoints);
   n:=c+1;
   SetLength(fPoints,n);
   fPoints[c] :=fpoint0;

   c:=Length(sPoints);
   n:=c+1;
   SetLength(sPoints,n);
   sPoints[c]:=spoint0;

     if (Abs(spoint0.Y-fpoint0.Y)<>0)
         or ((not(Abs(spoint0.Y-fpoint0.Y)<>0))and(spoint0.X>fpoint0.X))
         or ((not(Abs(spoint0.Y-fpoint0.Y)<>0))and(spoint0.X<fpoint0.X)) then
     begin
       //Если не друг под другом или друг под другом, но зеркально

       TmpPoint :=fpoint;
       if ObjectXPosition(BeginItem,fpoint)>0 then
       begin
         //Если точка над блоком
         if bBeginJoinExists then
         TmpPoint.X :=TmpPoint.X+JOINVERTEX_PADDING_X;
         if (spoint.X<fpoint.X)and(bBeginBypassEnabled) then
         begin
           //Если надо вниз
           if spoint0.Y<=fpoint0.Y then
           begin
              //обход объекта влево
              GetBypassPoints(BeginItem,TmpPoint,True,False,fBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(BeginItem,TmpPoint,bOnlyLeftByPass,False,fBypassPoints);
           end;
         end;
       end
       else begin
         //Если точка под блоком
         if bBeginJoinExists then
         TmpPoint.X :=TmpPoint.X-JOINVERTEX_PADDING_X;
         if (spoint.X>fpoint.X)and(bBeginBypassEnabled) then
         begin
           if spoint0.Y<=fpoint0.Y then
           begin
              //обход объекта влево
              GetBypassPoints(BeginItem,TmpPoint,True,True,fBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(BeginItem,TmpPoint,bOnlyLeftByPass,True,fBypassPoints);
           end;
         end;
       end;

       if bBeginJoinExists then
       begin
         c:=Length(fPoints);
         n:=c+1;
         SetLength(fPoints,n);
         fPoints[c] :=TmpPoint;
         fpoint     :=fPoints[c];
       end;

       if bBeginBypassEnabled then
       begin
         bBeginBypass := (high(fBypassPoints)>-1);
         for i:=0 to high(fBypassPoints) do
         begin
             c:=Length(fPoints);
             n:=c+1;
             SetLength(fPoints,n);
             fPoints[c] :=fBypassPoints[i];
             fpoint     :=fPoints[c];
         end;
       end;

       TmpPoint:=spoint;
       if ObjectXPosition(EndItem,TmpPoint)>=0 then
       begin
         if bEndJoinExists then
         TmpPoint.X :=TmpPoint.X+JOINVERTEX_PADDING_X;
         if (spoint.X>fpoint.X)and(bEndBypassEnabled) then
         begin
           if spoint0.Y<=fpoint0.Y then
           begin
              //обход объекта влево
             GetBypassPoints(EndItem,TmpPoint,True,False,sBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(EndItem,TmpPoint,bOnlyLeftByPass,False,sBypassPoints);
           end;
         end;
       end
       else begin
         if bEndJoinExists then
         TmpPoint.X :=TmpPoint.X-JOINVERTEX_PADDING_X;
         if (spoint.X<fpoint.X)and(bEndBypassEnabled) then
         begin
           if spoint0.Y<=fpoint0.Y then
           begin
              //обход объекта влево
              GetBypassPoints(EndItem,TmpPoint,True,True,sBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(EndItem,TmpPoint,bOnlyLeftByPass,True,sBypassPoints);
           end;
         end;
       end;

       if bEndJoinExists then
       begin
         c:=Length(sPoints);
         n:=c+1;
         SetLength(sPoints,n);
         sPoints[c] :=TmpPoint;
         spoint     :=sPoints[c];
       end;

       if bEndBypassEnabled then
       begin
         bEndBypass :=(high(sBypassPoints)>-1);
         for i:=0 to high(sBypassPoints) do
         begin
             c:=Length(sPoints);
             n:=c+1;
             SetLength(sPoints,n);
             sPoints[c] :=sBypassPoints[i];
             spoint     :=sPoints[c];
         end;
       end;

       {
       for i:=0 to VertexCount-1 do
       begin
           c:=Length(APoints);
           n:=c+1;
           SetLength(APoints,n);
           APoints[c] :=Vertex[i];
           fpoint     :=APoints[c];
       end;
       }

       //if bBeginBypass and bEndBypass then
       //begin
          // Если оба делают обход, то достаточно одной точки

       //end
       //else begin
                 //Центральные две точки
                 //if isVectorUp(APoints) then

                 if (Abs(spoint0.Y-fpoint0.Y)<>0) then
                 begin

                   c:=Length(fPoints);
                   n:=c+1;
                   SetLength(fPoints,n);
                   fPoints[c].Y:=fpoint.Y;
                   fPoints[c].X:=fpoint.X+((spoint.X-fpoint.X)/2)+FMiddleLineOffsetX;
                   fPoints[c].Z:=0;

                   if VertexCount<1 then
                   begin
                      AddVertex(0,0,0);
                      VertexAxleX[0]:=fPoints[c].X;
                      VertexAxleY[0]:=fpoint.Y+((spoint.Y-fpoint.Y)/2);
                   end
                   else begin
                      VertexAxleX[0]:=fPoints[c].X;
                      VertexAxleY[0]:=fpoint.Y+((spoint.Y-fpoint.Y)/2);
                   end;

                   c:=Length(fPoints);
                   n:=c+1;
                   SetLength(fPoints,n);
                   fPoints[c].Y:=spoint.Y;
                   fPoints[c].X:=fpoint.X+((spoint.X-fpoint.X)/2)+FMiddleLineOffsetX;
                   fPoints[c].Z:=0;

                 end
                 else begin
                    FMiddleLineOffsetX:=0;
                    for i:=VertexCount-1 downto 0 do
                        DeleteVertex(i);
                 end;
        //end;
     end
     else begin
        FMiddleLineOffsetX:=0;
        for i:=VertexCount-1 downto 0 do
            DeleteVertex(i);
     end;
 end
 else if iStyle=2 then  //вертикально
 begin

   bBeginBypassEnabled :=True;
   bEndBypassEnabled   :=True;

   fpoint0  :=GetBeginVertex(bBeginJoinExists);
   fpoint   :=fpoint0;
   spoint0  :=GetEndVertex(bEndJoinExists);
   spoint   :=spoint0;

   if (spoint0.Y>fpoint0.Y) then
   begin
        //рокировка, если верх не начало
        TmpItem   :=BeginItem;
        BeginItem :=EndItem;
        EndItem   :=TmpItem;

        fpoint0   :=spoint;
        spoint0   :=fpoint;
        fpoint    :=fpoint0;
        spoint    :=spoint0;

        if bEndJoinExists then
        begin
           bEndJoinExists   :=bBeginJoinExists;
           bBeginJoinExists :=True;
        end
        else begin
           bEndJoinExists   :=bBeginJoinExists;
           bBeginJoinExists :=False;
        end;
   end;

   c:=Length(fPoints);
   n:=c+1;
   SetLength(fPoints,n);
   fPoints[c] :=fpoint0;

   c:=Length(sPoints);
   n:=c+1;
   SetLength(sPoints,n);
   sPoints[c]:=spoint0;

     if (Abs(spoint0.X-fpoint0.X)<>0)
         or ((not(Abs(spoint0.X-fpoint0.X)<>0))and(spoint0.Y>fpoint0.Y))
         or ((not(Abs(spoint0.X-fpoint0.X)<>0))and(spoint0.Y<fpoint0.Y)) then
     begin
       //Если не друг под другом или друг под другом, но зеркально

       TmpPoint :=fpoint;
       if ObjectYPosition(BeginItem,fpoint)>0 then
       begin
         //Если точка над блоком
         if bBeginJoinExists then
         TmpPoint.Y :=TmpPoint.Y+JOINVERTEX_PADDING_Y;
         if (spoint.Y<fpoint.Y)and(bBeginBypassEnabled) then
         begin
           //Если надо вниз
           if spoint0.X<=fpoint0.X then
           begin
              //обход объекта влево
              GetBypassPoints(BeginItem,TmpPoint,True,False,fBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(BeginItem,TmpPoint,bOnlyLeftByPass,False,fBypassPoints);
           end;
         end;
       end
       else begin
         //Если точка под блоком
         if bBeginJoinExists then
         TmpPoint.Y :=TmpPoint.Y-JOINVERTEX_PADDING_Y;
         if (spoint.Y>fpoint.Y)and(bBeginBypassEnabled) then
         begin
           if spoint0.X<=fpoint0.X then
           begin
              //обход объекта влево
              GetBypassPoints(BeginItem,TmpPoint,True,True,fBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(BeginItem,TmpPoint,bOnlyLeftByPass,True,fBypassPoints);
           end;
         end;
       end;

       if bBeginJoinExists then
       begin
         c:=Length(fPoints);
         n:=c+1;
         SetLength(fPoints,n);
         fPoints[c] :=TmpPoint;
         fpoint     :=fPoints[c];
       end;

       if bBeginBypassEnabled then
       begin
         bBeginBypass := (high(fBypassPoints)>-1);
         for i:=0 to high(fBypassPoints) do
         begin
             c:=Length(fPoints);
             n:=c+1;
             SetLength(fPoints,n);
             fPoints[c] :=fBypassPoints[i];
             fpoint     :=fPoints[c];
         end;
       end;

       TmpPoint:=spoint;
       if ObjectYPosition(EndItem,TmpPoint)>=0 then
       begin
         if bEndJoinExists then
         TmpPoint.Y :=TmpPoint.Y+JOINVERTEX_PADDING_Y;
         if (spoint.Y>fpoint.Y)and(bEndBypassEnabled) then
         begin
           if spoint0.X<=fpoint0.X then
           begin
              //обход объекта влево
             GetBypassPoints(EndItem,TmpPoint,True,False,sBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(EndItem,TmpPoint,bOnlyLeftByPass,False,sBypassPoints);
           end;
         end;
       end
       else begin
         if bEndJoinExists then
         TmpPoint.Y :=TmpPoint.Y-JOINVERTEX_PADDING_Y;
         if (spoint.Y<fpoint.Y)and(bEndBypassEnabled) then
         begin
           if spoint0.X<=fpoint0.X then
           begin
              //обход объекта влево
              GetBypassPoints(EndItem,TmpPoint,True,True,sBypassPoints);
           end
           else begin
             //обход объекта вправо
             GetBypassPoints(EndItem,TmpPoint,bOnlyLeftByPass,True,sBypassPoints);
           end;
         end;
       end;

       if bEndJoinExists then
       begin
         c:=Length(sPoints);
         n:=c+1;
         SetLength(sPoints,n);
         sPoints[c] :=TmpPoint;
         spoint     :=sPoints[c];
       end;

       if bEndBypassEnabled then
       begin
         bEndBypass :=(high(sBypassPoints)>-1);
         for i:=0 to high(sBypassPoints) do
         begin
             c:=Length(sPoints);
             n:=c+1;
             SetLength(sPoints,n);
             sPoints[c] :=sBypassPoints[i];
             spoint     :=sPoints[c];
         end;
       end;

       {
       for i:=0 to VertexCount-1 do
       begin
           c:=Length(APoints);
           n:=c+1;
           SetLength(APoints,n);
           APoints[c] :=Vertex[i];
           fpoint     :=APoints[c];
       end;
       }

       //if bBeginBypass and bEndBypass then
       //begin
          // Если оба делают обход, то достаточно одной точки

       //end
       //else begin
                 //Центральные две точки
                 //if isVectorUp(APoints) then

                 if (Abs(spoint0.X-fpoint0.X)<>0) then
                 begin

                   c:=Length(fPoints);
                   n:=c+1;
                   SetLength(fPoints,n);
                   fPoints[c].X:=fpoint.X;
                   fPoints[c].Y:=fpoint.Y+((spoint.y-fpoint.y)/2)+FMiddleLineOffsetY;
                   fPoints[c].Z:=0;

                   if VertexCount<1 then
                   begin
                      AddVertex(0,0,0);
                      VertexAxleY[0]:=fPoints[c].Y;
                      VertexAxleX[0]:=fpoint.X+((spoint.X-fpoint.X)/2);
                   end
                   else begin
                      VertexAxleY[0]:=fPoints[c].Y;
                      VertexAxleX[0]:=fpoint.X+((spoint.X-fpoint.X)/2);
                   end;

                   c:=Length(fPoints);
                   n:=c+1;
                   SetLength(fPoints,n);
                   fPoints[c].X:=spoint.X;
                   fPoints[c].Y:=fpoint.Y+((spoint.y-fpoint.y)/2)+FMiddleLineOffsetY;
                   fPoints[c].Z:=0;

                 end
                 else begin
                    FMiddleLineOffsetY:=0;
                    for i:=VertexCount-1 downto 0 do
                        DeleteVertex(i);
                 end;
        //end;
     end
     else begin
        FMiddleLineOffsetY:=0;
        for i:=VertexCount-1 downto 0 do
            DeleteVertex(i);
     end;

   end;

   for i:=0 to high(fPoints) do
   begin
       c:=Length(APoints);
       n:=c+1;
       SetLength(APoints,n);
       APoints[c] :=fPoints[i];
   end;
   for i:=high(sPoints) downto 0 do
   begin
       c:=Length(APoints);
       n:=c+1;
       SetLength(APoints,n);
       APoints[c] :=sPoints[i];
   end;

end;

constructor TGraphicConnectionline.Create;
begin
  inherited Create;
  FMiddleLineOffsetY:=0;
  FMiddleLineOffsetX:=0;
end;

{ TEntityList }

procedure TEntityList.SetEntityLinkVar(AEntity: TEntity);
begin
  AEntity.ParentList:=Self;
  AEntity.FOnGetDocumentEvent:=FModelSpace.FOnGetDocumentEvent;
end;

function TEntityList.Add(AParentID: TEntityID): TEntity;
var
  AEntity:TEntity;
begin
  AEntity:=TEntity.Create;
  FList.Add(AEntity);
  SetEntityLinkVar(AEntity);
  Result:=AEntity;
end;

procedure TEntityList.Add(AEntity: TEntity);
begin
  FList.Add(AEntity);
  SetEntityLinkVar(AEntity);
end;

constructor TEntityList.Create;
begin
  inherited Create;
  FList:=TList.Create;
end;

procedure TEntityList.Delete(Index: Integer);
var
  i:integer;
begin
  if Index<Count then
  begin
      Items[Index].Free;
      FList.Delete(Index);
  end
  else
     Abort;
end;

procedure TEntityList.Remove(AEntity: TEntity);
var
   i:integer;
begin
   for i:=Count-1 downto 0 do
   begin
      if Items[i]=AEntity then
      begin
        Items[i].Free;
        FList.Delete(i);
        break;
      end;
   end;
end;

destructor TEntityList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

function TEntityList.GetCount: Integer;
begin
  Result:= FList.Count;
end;

function TEntityList.GetItem(Index: Integer): TEntity;
begin
  Result:=TEntity(FList.Items[Index]);
end;

procedure TEntityList.ChangeCordVertex(const AVertCord:TFloatPoint);
begin
      //Реализуется в потомках
      {
      if FModelSpace.FTopLeft.X>AVertCord.X then FModelSpace.FTopLeft.X:=AVertCord.X;
      if Data.Ymin>APoint.Y then Data.Ymin:=APoint.Y;
      if Data.Zmin>APoint.Z then Data.Zmin:=APoint.Z;

      if Data.Xmax<APoint.X then Data.Xmax:=APoint.X;
      if Data.Ymax<APoint.Y then Data.Ymax:=APoint.Y;
      if Data.Zmax<APoint.Z then Data.Zmax:=APoint.Z;
      }
end;

procedure TEntityList.Insert(Index: Integer; AEntity: TEntity);
begin
   FList.Insert(Index,AEntity);
   SetEntityLinkVar(AEntity);
end;

procedure TEntityList.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  i,index    :integer;
  Item       :TEntity;
  tmpColor   :TgaColor;
  tmpLine    :TgaLineWeight;
  OwnerBlockTmp:TEntityBlockBasic;
begin
  OwnerBlockTmp:=nil;

  if FModelSpace is TBlockItem then
  begin
     OwnerBlockTmp:=TBlockItem(FModelSpace).OwnerBlock;
  end;

  for I := 0 to Count - 1 do
  begin
         if Assigned(OwnerBlockTmp) then
         begin
            //Если потомки отрисовывают этот блок нужно восстановить значение
            if TBlockItem(FModelSpace).OwnerBlock<>OwnerBlockTmp then
               TBlockItem(FModelSpace).OwnerBlock:=OwnerBlockTmp;
            //OwnerBlock нужен чтобы потомки могли брать параметры атрибутов вверху.
         end;

         Item:=Items[i];

         tmpColor:=Item.Color;
         if tmpColor=gaByBlock then
         begin
            Item.Color:=FModelSpace.FByBlockColor;
         end;

         tmpLine:=Item.LineWeight;
         if tmpLine=gaLnWtByBlock then
         begin
            Item.LineWeight:=FModelSpace.FByBlockLineWeight;
         end;
         //------

          if Assigned(FModelSpace.FSelectedEntityList) then
          begin
            index:=FModelSpace.FSelectedEntityList.IndexOf(Item);
            if index>-1 then
             Item.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,[edsSelected])
            else
              Item.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,[edsNormal]);
          end
          else
            Item.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,[edsNormal]);

         //------
         if tmpColor=gaByBlock then
         begin
            Item.Color:=tmpColor;
         end;

         if tmpLine=gaLnWtByBlock then
         begin
            Item.LineWeight:=tmpLine;
         end;
  end;
end;

procedure TEntityList.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  Item:TEntity;
begin
  for I := 0 to Count - 1 do
  begin
          if Assigned(FModelSpace.FSelectedEntityList) then
          begin
            Item:=Items[i];
            if FModelSpace.FSelectedEntityList.IndexOf(Item)>-1 then
              Item.RepaintVertex(LogicalDrawing);
          end;
  end;
end;

function TEntityList.GetEntityByID(AID: TEntityID): TEntity;
var
  i:integer;
  Item:TEntity;
begin
  Result:=nil;
  for I := 0 to Count - 1 do
  begin
       Item:=Items[i];
       if Item.ID=AID then
       begin
           Result:=Item;
           break;
       end;
  end;
end;

procedure TEntityList.Clear;
var
  i:integer;
begin
  for I := Count - 1 downto 0 do
  begin
      Delete(i);
  end;
end;

procedure TEntityList.SetItem(Index: Integer; const Value: TEntity);
begin
   FList.Items[Index]:=Value;
   Value.ParentList:=Self;
end;

{ TGraphicElipse }

procedure TGraphicEllipse.Draw(ABasePoint: TFloatPoint; AAxleY, AAxleX,
  ARotate:integer);
begin
  if VertexCount=0 then
  AddVertex(ABasePoint.X,ABasePoint.Y,ABasePoint.Z);
  AxleY:=AAxleY;
  AxleX:=AAxleX;
  //FRotate:=ARotate;
end;

function TGraphicEllipse.GetAxleX: Double;
begin
  Result:=FAxleX;
end;

function TGraphicEllipse.GetAxleY: Double;
begin
  Result:=FAxleY;
end;

function TGraphicEllipse.GetDiameter: Double;
begin
  Result:=2*GetRadius;
end;

procedure TGraphicEllipse.SetAxleX(const Value: Double);
begin
  FAxleX:=Value;
  if VertexCount=1 then
  begin
      AddVertex(Vertex[0].X+FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X-FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X,Vertex[0].Y+FAxleY,0);
      AddVertex(Vertex[0].X,Vertex[0].Y-FAxleY,0);
  end
  else begin
      VertexAxleX[1]:=Vertex[0].X+FAxleX;
      VertexAxleY[1]:=Vertex[0].Y;
      VertexAxleX[2]:=Vertex[0].X-FAxleX;
      VertexAxleY[2]:=Vertex[0].Y;
      VertexAxleX[3]:=Vertex[0].X;
      VertexAxleY[3]:=Vertex[0].Y+FAxleY;
      VertexAxleX[4]:=Vertex[0].X;
      VertexAxleY[4]:=Vertex[0].Y-FAxleY;
  end;
end;

procedure TGraphicEllipse.SetAxleY(const Value: Double);
begin
  FAxleY:=Value;
  if VertexCount=1 then
  begin
      AddVertex(Vertex[0].X+FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X-FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X,Vertex[0].Y+FAxleY,0);
      AddVertex(Vertex[0].X,Vertex[0].Y-FAxleY,0);
  end
  else begin
      VertexAxleX[1]:=Vertex[0].X+FAxleX;
      VertexAxleY[1]:=Vertex[0].Y;
      VertexAxleX[2]:=Vertex[0].X-FAxleX;
      VertexAxleY[2]:=Vertex[0].Y;
      VertexAxleX[3]:=Vertex[0].X;
      VertexAxleY[3]:=Vertex[0].Y+FAxleY;
      VertexAxleX[4]:=Vertex[0].X;
      VertexAxleY[4]:=Vertex[0].Y-FAxleY;
  end;
end;

procedure TGraphicEllipse.SetDiameter(const Value: Double);
begin
  SetRadius(Value/2);
  if VertexCount =1 then
  begin
      AddVertex(Vertex[0].X+FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X-FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X,Vertex[0].Y+FAxleY,0);
      AddVertex(Vertex[0].X,Vertex[0].Y-FAxleY,0);
  end
  else begin
      VertexAxleX[1]:=Vertex[0].X+FAxleX;
      VertexAxleY[1]:=Vertex[0].Y;
      VertexAxleX[2]:=Vertex[0].X-FAxleX;
      VertexAxleY[2]:=Vertex[0].Y;
      VertexAxleX[3]:=Vertex[0].X;
      VertexAxleY[3]:=Vertex[0].Y+FAxleY;
      VertexAxleX[4]:=Vertex[0].X;
      VertexAxleY[4]:=Vertex[0].Y-FAxleY;
  end;
end;

function TGraphicEllipse.GetRadius: Double;
begin
  if FAxleY>=FAxleX then
      Result:=FAxleY
  else
      Result:=FAxleX;
end;

procedure TGraphicEllipse.SetRadius(const Value: Double);
begin
  FAxleX:=Value;
  FAxleY:=Value;
   if VertexCount=1 then
  begin
      AddVertex(Vertex[0].X+FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X-FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X,Vertex[0].Y+FAxleY,0);
      AddVertex(Vertex[0].X,Vertex[0].Y-FAxleY,0);
  end
  else begin
      VertexAxleX[1]:=Vertex[0].X+FAxleX;
      VertexAxleY[1]:=Vertex[0].Y;
      VertexAxleX[2]:=Vertex[0].X-FAxleX;
      VertexAxleY[2]:=Vertex[0].Y;
      VertexAxleX[3]:=Vertex[0].X;
      VertexAxleY[3]:=Vertex[0].Y+FAxleY;
      VertexAxleX[4]:=Vertex[0].X;
      VertexAxleY[4]:=Vertex[0].Y-FAxleY;
  end;
end;

procedure TGraphicEllipse.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  TmpVertex  :TFloatPoint;
  ValueAxleX,ValueAxleY:Double;
begin
  if VertexCount>0 then
  begin
       ValueAxleX:=AxleX;
       ValueAxleY:=AxleY;

       if esMoving in State then
       begin
          TmpVertex:=GetInteractiveVertex(Vertex[0]);
       end
       else if esEditing in State then
       begin
          TmpVertex:=Vertex[0];
          if ActionVertexIndex=1 then
          begin
            ValueAxleX:=ValueAxleX+self.FActionVertexDelta.X;
          end
          else if ActionVertexIndex=2 then
          begin
            ValueAxleX:=ValueAxleX-self.FActionVertexDelta.X;
          end
          else if ActionVertexIndex=3 then
          begin
            ValueAxleY:=ValueAxleY+self.FActionVertexDelta.Y;
          end
          else if ActionVertexIndex=4 then
          begin
            ValueAxleY:=ValueAxleY-self.FActionVertexDelta.Y;
          end;
       end
       else begin
          TmpVertex:=Vertex[0];
       end;

      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));

      LogicalDrawing.EllipseDraw((TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift,ValueAxleX*AScaleX,ValueAxleY*AScaleY);
  end;
end;

procedure TGraphicEllipse.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex  :TFloatPoint;
begin
  if VertexCount>0 then
  begin
       if esMoving in State then
       begin
          TmpVertex:=GetInteractiveVertex(Vertex[0]);
       end
       else if esEditing in State then
       begin
          TmpVertex:=Vertex[0];
       end
       else begin
          TmpVertex:=Vertex[0];
       end;

      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_BASEPOINT);
      for i:=1 to VertexCount-1 do
      begin
         if esMoving in State then
         begin
            TmpVertex:=GetInteractiveVertex(Vertex[i]);
         end
         else if (esEditing in State) then
         begin
            TmpVertex:=Vertex[i];
            case i of
              0:
              begin
                 if (ActionVertexIndex=i) then
                 begin
                    TmpVertex:=GetInteractiveVertex(TmpVertex);
                 end;
              end;
              1:
              begin
                 if (ActionVertexIndex=i) then
                 begin
                    TmpVertex.X:=TmpVertex.X+FActionVertexDelta.X;
                 end
                 else if (ActionVertexIndex=2) then
                 begin
                    TmpVertex.X:=TmpVertex.X-FActionVertexDelta.X;
                 end;
              end;
              2:
              begin
                 if (ActionVertexIndex=i) then
                 begin
                    TmpVertex.X:=TmpVertex.X+FActionVertexDelta.X;
                 end
                 else if (ActionVertexIndex=1) then
                 begin
                    TmpVertex.X:=TmpVertex.X-FActionVertexDelta.X;
                 end;
              end;
              3:
              begin
                 if (ActionVertexIndex=i) then
                 begin
                    TmpVertex.Y:=TmpVertex.Y+FActionVertexDelta.Y;
                 end
                 else if (ActionVertexIndex=4) then
                 begin
                    TmpVertex.Y:=TmpVertex.Y-FActionVertexDelta.Y;
                 end;
              end;
              4:
              begin
                 if (ActionVertexIndex=i) then
                 begin
                    TmpVertex.Y:=TmpVertex.Y+FActionVertexDelta.Y;
                 end
                 else if (ActionVertexIndex=3) then
                 begin
                    TmpVertex.Y:=TmpVertex.Y-FActionVertexDelta.Y;
                 end;
              end;
              else
              begin

              end;
            end;

         end
         else begin
            TmpVertex:=Vertex[i];
         end;

        LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
      end;
  end;
end;

{ TGraphicCircle }

procedure TGraphicCircle.Draw(ABasePoint: TFloatPoint; ARadius: Double);
begin
  if VertexCount=0 then
  AddVertex(ABasePoint.X,ABasePoint.Y,ABasePoint.Z);
  Radius:=ARadius;
end;

function TGraphicCircle.GetAxleX: Double;
begin
  Result:=GetRadius;
end;

function TGraphicCircle.GetAxleY: Double;
begin
  Result:=GetRadius;
end;

function TGraphicCircle.GetDiameter: Double;
begin
  Result:=FAxleX*2;
end;

function TGraphicCircle.GetRadius: Double;
begin
  Result:=FAxleX;
end;

procedure TGraphicCircle.SetAxleX(const Value: Double);
begin
  SetRadius(Value);
end;

procedure TGraphicCircle.SetAxleY(const Value: Double);
begin
  SetRadius(Value);
end;

procedure TGraphicCircle.SetDiameter(const Value: Double);
begin
  FAxleX:=Value/2;
  FAxleY:=Value/2;
  if VertexCount=1 then
  begin
      AddVertex(Vertex[0].X+FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X-FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X,Vertex[0].Y+FAxleY,0);
      AddVertex(Vertex[0].X,Vertex[0].Y-FAxleY,0);
  end
  else begin
      VertexAxleX[1]:=Vertex[0].X+FAxleX;
      VertexAxleY[1]:=Vertex[0].Y;
      VertexAxleX[2]:=Vertex[0].X-FAxleX;
      VertexAxleY[2]:=Vertex[0].Y;
      VertexAxleX[3]:=Vertex[0].X;
      VertexAxleY[3]:=Vertex[0].Y+FAxleY;
      VertexAxleX[4]:=Vertex[0].X;
      VertexAxleY[4]:=Vertex[0].Y-FAxleY;
  end;
end;

procedure TGraphicCircle.SetRadius(const Value: Double);
begin
  FAxleX:=Value;
  FAxleY:=Value;
  if VertexCount=1 then
  begin
      AddVertex(Vertex[0].X+FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X-FAxleX,Vertex[0].Y,0);
      AddVertex(Vertex[0].X,Vertex[0].Y+FAxleY,0);
      AddVertex(Vertex[0].X,Vertex[0].Y-FAxleY,0);
  end
  else begin
      VertexAxleX[1]:=Vertex[0].X+FAxleX;
      VertexAxleY[1]:=Vertex[0].Y;
      VertexAxleX[2]:=Vertex[0].X-FAxleX;
      VertexAxleY[2]:=Vertex[0].Y;
      VertexAxleX[3]:=Vertex[0].X;
      VertexAxleY[3]:=Vertex[0].Y+FAxleY;
      VertexAxleX[4]:=Vertex[0].X;
      VertexAxleY[4]:=Vertex[0].Y-FAxleY;
  end;
end;

procedure TGraphicCircle.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
   TmpVertex  :TFloatPoint;
   ValueR:Double;
begin
  if VertexCount>=1 then
  begin
       ValueR:=GetRadius;
       if esMoving in State then
       begin
          TmpVertex:=GetInteractiveVertex(Vertex[0]);
       end
       else if esEditing in State then
       begin
          TmpVertex:=Vertex[0];
          if ActionVertexIndex=1 then
          begin
            ValueR:=ValueR+self.FActionVertexDelta.X;
          end
          else if ActionVertexIndex=2 then
          begin
            ValueR:=ValueR-self.FActionVertexDelta.X;
          end
          else if ActionVertexIndex=3 then
          begin
            ValueR:=ValueR+self.FActionVertexDelta.Y;
          end
          else if ActionVertexIndex=4 then
          begin
            ValueR:=ValueR-self.FActionVertexDelta.Y;
          end;
       end
       else begin
          TmpVertex:=Vertex[0];
       end;

      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
    LogicalDrawing.CircleDraw((TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift,ValueR*AScaleX);
  end;
end;

procedure TGraphicCircle.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex  :TFloatPoint;
begin
  if VertexCount>0 then
  begin
     if esMoving in State then
     begin
        TmpVertex:=GetInteractiveVertex(Vertex[0]);
     end
     else if esEditing in State then
     begin
        TmpVertex:=Vertex[0];
     end
     else begin
        TmpVertex:=Vertex[0];
     end;

    LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_BASEPOINT);
    for i:=1 to VertexCount-1 do
    begin
       if esMoving in State then
       begin
          TmpVertex:=GetInteractiveVertex(Vertex[i]);
       end
       else if (esEditing in State) then
       begin
          TmpVertex:=Vertex[i];
          case i of
            0:
            begin
               if (ActionVertexIndex=i) then
               begin
                  TmpVertex:=GetInteractiveVertex(TmpVertex);
               end;
            end;
            1:
            begin
               if (ActionVertexIndex=i) then
               begin
                  TmpVertex.X:=TmpVertex.X+FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=2) then
               begin
                  TmpVertex.X:=TmpVertex.X-FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=3) then
               begin
                  TmpVertex.X:=TmpVertex.X+FActionVertexDelta.Y;
               end
               else if (ActionVertexIndex=4) then
               begin
                  TmpVertex.X:=TmpVertex.X-FActionVertexDelta.Y;
               end;
            end;
            2:
            begin
               if (ActionVertexIndex=i) then
               begin
                  TmpVertex.X:=TmpVertex.X+FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=1) then
               begin
                  TmpVertex.X:=TmpVertex.X-FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=3) then
               begin
                  TmpVertex.X:=TmpVertex.X-FActionVertexDelta.Y;
               end
               else if (ActionVertexIndex=4) then
               begin
                  TmpVertex.X:=TmpVertex.X+FActionVertexDelta.Y;
               end;
            end;
            3:
            begin
               if (ActionVertexIndex=i) then
               begin
                  TmpVertex.Y:=TmpVertex.Y+FActionVertexDelta.Y;
               end
               else if (ActionVertexIndex=1) then
               begin
                  TmpVertex.Y:=TmpVertex.Y+FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=2) then
               begin
                  TmpVertex.Y:=TmpVertex.Y-FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=4) then
               begin
                  TmpVertex.Y:=TmpVertex.Y-FActionVertexDelta.Y;
               end;
            end;
            4:
            begin
               if (ActionVertexIndex=i) then
               begin
                  TmpVertex.Y:=TmpVertex.Y+FActionVertexDelta.Y;
               end
               else if (ActionVertexIndex=1) then
               begin
                  TmpVertex.Y:=TmpVertex.Y-FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=2) then
               begin
                  TmpVertex.Y:=TmpVertex.Y+FActionVertexDelta.X;
               end
               else if (ActionVertexIndex=3) then
               begin
                  TmpVertex.Y:=TmpVertex.Y-FActionVertexDelta.Y;
               end;
            end;
            else
            begin

            end;
          end;

       end
       else begin
          TmpVertex:=Vertex[i];
       end;

       LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;


{ TGraphicArc }

{
 Алгоритм работы дуги необходимо дорабатывать.
}

procedure TGraphicArc.Draw(ABasePoint, APoint1, APoint2: TFloatPoint; ARadius: Double);
begin

            AddVertex(0,0,0);
            AddVertex(0,0,0);
            AddVertex(0,0,0);
            //AddVertex(0,0,0);
            
            VertexAxleX[0]:=ABasePoint.X;
            VertexAxleY[0]:=ABasePoint.Y;
            VertexAxleZ[0]:=ABasePoint.Z;

            VertexAxleX[1]:=APoint1.X;
            VertexAxleY[1]:=APoint1.Y;
            VertexAxleZ[1]:=APoint1.Z;

            VertexAxleX[2]:=APoint2.X;
            VertexAxleY[2]:=APoint2.Y;
            VertexAxleZ[2]:=APoint2.Z;

            Radius:=ARadius;
end;

procedure TGraphicArc.Draw(APoint1, APoint2, APoint3: TFloatPoint);
begin
            abort;
            {
            VertexAxleX[0]:=ABasePoint.X;
            VertexAxleY[0]:=ABasePoint.Y;
            VertexAxleZ[0]:=ABasePoint.Z;

            VertexAxleX[1]:=APoint1.X;
            VertexAxleY[1]:=APoint1.Y;
            VertexAxleZ[1]:=APoint1.Z;

            VertexAxleX[2]:=APoint2.X;
            VertexAxleY[2]:=APoint2.Y;
            VertexAxleZ[2]:=APoint2.Z;

            VertexAxleX[3]:=ACenterPoint.X;
            VertexAxleY[3]:=ACenterPoint.Y;
            VertexAxleZ[3]:=ACenterPoint.Z;
            }
end;

function TGraphicArc.GetDiameter: Double;
begin
  Result:=FAxleX*2;
end;

function TGraphicArc.GetRadius: Double;
begin
  Result:=FAxleX;
end;

procedure TGraphicArc.MoveVertex(Index: integer; NewVertex: TFloatPoint);
var
  dX,dY,dZ:Double;
  Delta:TFloatPoint;
begin
        //todo
        dX:=NewVertex.X-Vertex[Index].X;
        dY:=NewVertex.Y-Vertex[Index].Y;
        dZ:=NewVertex.Z-Vertex[Index].Z;

        if Index=0 then
        begin
            Delta.X:=NewVertex.X-VertexAxleX[Index];
            Delta.Y:=NewVertex.Y-VertexAxleY[Index];
            Delta.Z:=NewVertex.Z-VertexAxleZ[Index];
            MoveGroupChildEntity(Delta);

            VertexAxleX[Index]:=NewVertex.X;
            VertexAxleY[Index]:=NewVertex.Y;
            VertexAxleZ[Index]:=NewVertex.Z;

            VertexAxleX[1]:=VertexAxleX[1]+dX;
            VertexAxleY[1]:=VertexAxleY[1]+dY;
            VertexAxleZ[1]:=VertexAxleZ[1]+dZ;

            VertexAxleX[2]:=VertexAxleX[2]+dX;
            VertexAxleY[2]:=VertexAxleY[2]+dY;
            VertexAxleZ[2]:=VertexAxleZ[2]+dZ;
        end
        else if (Index=1) then
        begin
            VertexAxleX[1]:=VertexAxleX[1]+dX;
            VertexAxleY[1]:=VertexAxleY[1]+dY;
            VertexAxleZ[1]:=VertexAxleZ[1]+dZ;
        end
        else if (Index=2) then
        begin
            VertexAxleX[2]:=VertexAxleX[2]+dX;
            VertexAxleY[2]:=VertexAxleY[2]+dY;
            VertexAxleZ[2]:=VertexAxleZ[2]+dZ;
        end;
end;

procedure TGraphicArc.SetDiameter(const Value: Double);
begin
 FAxleX:=Value/2;
 FAxleY:=Value/2;
end;

procedure TGraphicArc.SetRadius(const Value: Double);
begin
 FAxleX:=Value;
 FAxleY:=Value;
end;

procedure TGraphicArc.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
   TmpVertex  :TFloatPoint;
   TmpVertex1 :TFloatPoint;
   TmpVertex2 :TFloatPoint;
begin
  if VertexCount>=3 then
  begin

     if esMoving in State then
     begin
      TmpVertex:=GetInteractiveVertex(Vertex[0]);
      TmpVertex1:=GetInteractiveVertex(Vertex[1]);
      TmpVertex2:=GetInteractiveVertex(Vertex[2]);
     end
     else if esEditing in State then
     begin
        TmpVertex:=Vertex[0];

        if ActionVertexIndex=1 then
           TmpVertex1:=GetInteractiveVertex(Vertex[1])
        else
           TmpVertex1:=Vertex[1];

        if ActionVertexIndex=2 then
           TmpVertex2:=GetInteractiveVertex(Vertex[2])
        else
           TmpVertex2:=Vertex[2];
     end
     else begin
      TmpVertex:=Vertex[0];
      TmpVertex1:=Vertex[1];
      TmpVertex2:=Vertex[2];
     end;

      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));

     LogicalDrawing.ArcDraw((TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift,(TmpVertex1.X*AScaleX)+Xshift,(TmpVertex1.Y*AScaleY)+Yshift,(TmpVertex2.X*AScaleX)+Xshift,(TmpVertex2.Y*AScaleY)+Yshift,GetRadius*AscaleX);
  end;
end;

procedure TGraphicArc.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
   TmpVertex  :TFloatPoint;
   TmpVertex1 :TFloatPoint;
   TmpVertex2 :TFloatPoint;
begin
  if VertexCount>0 then
  begin
     if esMoving in State then
     begin
        TmpVertex:=GetInteractiveVertex(Vertex[0]);
        TmpVertex1:=GetInteractiveVertex(Vertex[1]);
        TmpVertex2:=GetInteractiveVertex(Vertex[2]);
     end
     else if esEditing in State then
     begin
        TmpVertex:=Vertex[0];

        if ActionVertexIndex=1 then
           TmpVertex1:=GetInteractiveVertex(Vertex[1])
        else
           TmpVertex1:=Vertex[1];

        if ActionVertexIndex=2 then
           TmpVertex2:=GetInteractiveVertex(Vertex[2])
        else
           TmpVertex2:=Vertex[2];
     end
     else begin
        TmpVertex:=Vertex[0];
        TmpVertex1:=Vertex[1];
        TmpVertex2:=Vertex[2];
     end;

     LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_BASEPOINT);
     LogicalDrawing.VertexDraw(TmpVertex1.X,TmpVertex1.Y,VERTEXMARKER_VERTEX);
     LogicalDrawing.VertexDraw(TmpVertex2.X,TmpVertex2.Y,VERTEXMARKER_VERTEX);
  end;
end;


{ TEntityEllipseBasic }

function TEntityEllipseBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;


function TEntityEllipseBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect :integer;
  APoint1,APoint2     :TFloatPoint;
  xq,yq,a             :Double;
begin

  Result:=AFFA_OUTSIDE; //Вне периметра

  // Проверка попадают ли вершины в зону выбора
  CountVertexInRect:=0;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  // Проверка попадает ли базовая точка в зону выбора
  if (VertexCount>0) then
  begin
      if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=0;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
      if (not AllVertexInRect)and(CountVertexInRect>0) then
      begin
        Result:=AFFA_BASEPOINT;
      end;
  end;

  // Проверка попадают ли вершины в зону выбора
  for I := 1 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end;

  // Проверка попадают ли промежуточные точки в зону выбора

    if (not AllVertexInRect)and(VertexCount>=1)and(Result<>AFFA_VERTEX)and(Result<>AFFA_BASEPOINT) then
    begin
      for I := 0 to 180 do
      begin
        a:=i;
        APoint2:=APoint1;
        // уравнение эллипса с поворотом
        //xq := FAxleX*(0 - Vertex[0].x)*cos(a) - (0 - Vertex[0].y)*sin(a);
        //yq := FAxleY*(0 - Vertex[0].x)*sin(a) + (0 - Vertex[0].y)*cos(a);
        // уравнение эллипса
         xq:= Vertex[0].x+FAxleX*cos(a);
         yq:= Vertex[0].y+FAxleY*sin(a);
         APoint1.X:=xq;
         APoint1.Y:=yq;
        if PointInRect2D(xq,yq,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y)then
        begin
            Result:=AFFA_BORDER;
            break;
        end;

        if i>0 then
        begin
          if isLinesHasIntersection(APoint1.X,APoint1.Y,APoint2.X,APoint2.Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          if isLinesHasIntersection(APoint1.X,APoint1.Y,APoint2.X,APoint2.Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
        end;

      end; //for

      SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex*-1);

      // Проверка попадает ли зона выбора в периметр объекта
      if (Result=AFFA_OUTSIDE)and(not AllVertexInRect) then
      begin
          if (VertexCount>0) then
          begin
            APoint1.X:=Vertex[0].X-FAxleX;
            APoint1.Y:=Vertex[0].Y+FAxleY;
            APoint2.X:=Vertex[0].X+FAxleX;
            APoint2.Y:=Vertex[0].Y-FAxleY;
            if PointIn2DRect(TopLeft,APoint1, APoint2) then
              Result:=AFFA_INSIDE;
          end;
      end;

    end;
end;

procedure TEntityEllipseBasic.MoveVertex(Index:integer;  NewVertex: TFloatPoint);
var
  dX,dY,dZ:Double;
  Delta:TFloatPoint;
begin
        dX:=NewVertex.X-Vertex[Index].X;
        dY:=NewVertex.Y-Vertex[Index].Y;
        dZ:=NewVertex.Z-Vertex[Index].Z;

        if Index=0 then
        begin

            Delta.X:=NewVertex.X-VertexAxleX[Index];
            Delta.Y:=NewVertex.Y-VertexAxleY[Index];
            Delta.Z:=NewVertex.Z-VertexAxleZ[Index];
            MoveGroupChildEntity(Delta);

            VertexAxleX[Index]:=NewVertex.X;
            VertexAxleY[Index]:=NewVertex.Y;
            VertexAxleZ[Index]:=NewVertex.Z;

            VertexAxleX[1]:=VertexAxleX[1]+dX;
            VertexAxleY[1]:=VertexAxleY[1]+dY;
            VertexAxleZ[1]:=VertexAxleZ[1]+dZ;
            
            VertexAxleX[2]:=VertexAxleX[2]+dX;
            VertexAxleY[2]:=VertexAxleY[2]+dY;
            VertexAxleZ[2]:=VertexAxleZ[2]+dZ;

            VertexAxleX[3]:=VertexAxleX[3]+dX;
            VertexAxleY[3]:=VertexAxleY[3]+dY;
            VertexAxleZ[3]:=VertexAxleZ[3]+dZ;

            VertexAxleX[4]:=VertexAxleX[4]+dX;
            VertexAxleY[4]:=VertexAxleY[4]+dY;
            VertexAxleZ[4]:=VertexAxleZ[4]+dZ;
        end
        else if (Index=1) then
        begin
            AxleX:=AxleX+dX;
        end
        else if (Index=2) then
        begin
            AxleX:=AxleX+dX*-1;
        end
        else if (Index=3) then
        begin
            AxleY:=AxleY+dY;
        end
        else if (Index=4) then
        begin
            AxleY:=AxleY+dY*-1;
        end;
end;

procedure TEntityEllipseBasic.MoveEntity(ADeltaVertex: TFloatPoint);
var
  TmpVertex :TFloatPoint;
begin
  if VertexCount>0 then
  begin
     TmpVertex   :=Vertex[0];
     TmpVertex.X :=TmpVertex.X+ADeltaVertex.X;
     TmpVertex.Y :=TmpVertex.Y+ADeltaVertex.Y;
     TmpVertex.Z :=TmpVertex.Z+ADeltaVertex.Z;
     Vertex[0]   :=TmpVertex;
  end;
end;

procedure TEntityEllipseBasic.SetBasePoint(const Value: TFloatPoint);
begin
  if VertexCount>0 then
  begin
    Vertex[0]:=Value;
  end
  else begin
    AddVertex(Value.X,Value.Y,Value.Z);
  end;
end;

procedure TEntityEllipseBasic.GetRectVertex(var ATopLeft,
  ABottomRight: TFloatPoint);
begin

  ATopLeft.X:=BasePoint.X-FAxleX;
  ATopLeft.Y:=BasePoint.Y+FAxleY;

  ABottomRight.X:=BasePoint.X+FAxleX;
  ABottomRight.Y:=BasePoint.Y-FAxleY;
end;

function TEntityEllipseBasic.GetBasePoint: TFloatPoint;
begin
  if VertexCount>0 then
  begin
    Result:=Vertex[0];
  end;
end;

{ TEntityTextBasic }

function TEntityTextBasic.GetBasePoint: TFloatPoint;
begin
  if VertexCount>1 then
  begin
    Result:=Vertex[0];
  end;
end;

procedure TEntityTextBasic.SetBasePoint(const Value: TFloatPoint);
begin
  if VertexCount>1 then
  begin
    Vertex[0]:=Value;
  end
  else begin
    AddVertex(Value.X,Value.Y,Value.Z);
  end;
end;

constructor TEntityTextBasic.Create;
begin
  inherited Create;
  FRotate:=0;
end;

function TEntityTextBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TEntityTextBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect :integer;
begin
  Result:=AFFA_OUTSIDE; //Вне периметра
  CountVertexInRect:=0;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

      if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=0;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
    Result:=AFFA_BASEPOINT
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
    Result:=AFFA_BASEPOINT;
end;

procedure TEntityTextBasic.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
begin
  if VertexCount>0 then
  begin
      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
      LogicalDrawing.PointDraw((Vertex[0].X*AScaleX)+Xshift,(Vertex[0].Y*AScaleY)+Yshift);
  end;
end;

procedure TEntityTextBasic.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
  if VertexCount>0 then
  begin
      LogicalDrawing.VertexDraw(Vertex[0].X,Vertex[0].Y,VERTEXMARKER_BASEPOINT);
  end;
end;

{ TEntityBlockBasic }

function TEntityBlockBasic.GetBasePoint: TFloatPoint;
begin
  if VertexCount>0 then
  begin
    Result:=Vertex[0];
  end;
end;

procedure TEntityBlockBasic.SetBasePoint(const Value: TFloatPoint);
var
  TmpVertex: TFloatPoint;
begin
  if VertexCount>1 then
  begin
    TmpVertex    :=Vertex[0];
    TmpVertex.X  :=Value.X-TmpVertex.X;
    TmpVertex.Y  :=Value.Y-TmpVertex.Y;
    TmpVertex.Z  :=Value.Z-TmpVertex.Z;

    Vertex[0]:=Value;

    MoveAllJoinVertex(TmpVertex);
  end
  else begin
    AddVertex(Value.X,Value.Y,Value.Z);
  end;
end;

procedure TEntityBlockBasic.AddVertex(X, Y, Z: Double);
begin
  if VertexCount=0 then
      inherited AddVertex(X, Y, Z)
  else begin
      VertexAxleX[0]:=X;
      VertexAxleY[0]:=Y;
      VertexAxleZ[0]:=Z;
  end;
end;

constructor TEntityBlockBasic.Create;
begin
  inherited Create;
  FJoinVertex     :=TFloatPointList.Create;
  FJoinNames      :=TStringList.Create;
  FAttributes     :=TStringList.Create;
  FAttributes.Delimiter :='=';
  FAttributes.Sorted    :=True;
  FAttributes.Duplicates:=dupIgnore;
  FShowJoinVertex :=True;
  FScaleX         :=1;
  FScaleY         :=1;
  FScaleZ         :=1;
end;

destructor TEntityBlockBasic.Destroy;
begin
  FJoinVertex.Free;
  FJoinNames.Free;
  FAttributes.Free;
  inherited Destroy;
end;

function TEntityBlockBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight, AllVertexInRect, MVertx);
end;

function TEntityBlockBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect :integer;
  x1TopLeft,
  x1BottomRight     :TFloatPoint;
  X1,X2,Y1,Y2       :Double;
begin
  x1TopLeft     :=SetNullToFloatPoint;
  x1BottomRight :=SetNullToFloatPoint;
  GetRectVertex(x1TopLeft,x1BottomRight);

  Result:=AFFA_OUTSIDE; //Вне периметра
  CountVertexInRect:=0;

  if PointIn2DRect(TopLeft,x1TopLeft,x1BottomRight)
      and PointIn2DRect(BottomRight,x1TopLeft,x1BottomRight) then
  begin
      if not(AllVertexInRect)then
        Result:=AFFA_INSIDE;
  end;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
  begin
       CountVertexInRect:=CountVertexInRect+1;
       MVertx.Item:=self;
       MVertx.VertexIndex:=0;
       MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
    Result:=AFFA_BASEPOINT
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
    Result:=AFFA_BASEPOINT;

  if PointIn2DRect(x1TopLeft,TopLeft, BottomRight) and PointIn2DRect(x1BottomRight,TopLeft, BottomRight) then
  begin
      if (AllVertexInRect)then
        Result:=AFFA_VERTEX;
  end;

  //Проверка попадают ли промежуточные точки в зону выбора
  //ABCD
  if (not AllVertexInRect)and(Result=AFFA_OUTSIDE) then
  begin
      for i:=1 to 4 do
      begin

        case i of
          1:
          begin
             X1:=x1TopLeft.X;
             X2:=x1BottomRight.X;
             Y1:=x1TopLeft.Y;
             Y2:=x1TopLeft.Y;
          end;
          2:
          begin
             X1:=x1BottomRight.X;
             X2:=x1BottomRight.X;
             Y1:=x1TopLeft.Y;
             Y2:=x1BottomRight.Y;
          end;
          3:
          begin
             X1:=x1BottomRight.X;
             X2:=x1TopLeft.X;
             Y1:=x1BottomRight.Y;
             Y2:=x1BottomRight.Y;
          end;
          4:
          begin
             X1:=x1TopLeft.X;
             X2:=x1TopLeft.X;
             Y1:=x1TopLeft.Y;
             Y2:=x1BottomRight.Y;
          end;
        end;

        //AC
        if isLinesHasIntersection(X1,Y1,X2,Y2,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
        begin
          Result:=AFFA_BORDER;
          break;
        end;
        //BD
        if isLinesHasIntersection(X1,Y1,X2,Y2,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
        begin
          Result:=AFFA_BORDER;
          break;
        end;
        //AB
        if isLinesHasIntersection(X1,Y1,X2,Y2,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
        begin
          Result:=AFFA_BORDER;
          break;
        end;
        //BC
        if isLinesHasIntersection(X1,Y1,X2,Y2,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
        begin
          Result:=AFFA_BORDER;
          break;
        end;
        //CD
        if isLinesHasIntersection(X1,Y1,X2,Y2,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
        begin
          Result:=AFFA_BORDER;
          break;
        end;
        //DA
        if isLinesHasIntersection(X1,Y1,X2,Y2,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
        begin
          Result:=AFFA_BORDER;
          break;
        end;
      end;
  end;

end;

procedure TEntityBlockBasic.GetRectVertex(var ATopLeft,
  ABottomRight: TFloatPoint);
var
   x2TopLeft,
   x2BottomRight  :TFloatPoint;
   BlkItem        :TBlockItem;
begin

  x2TopLeft:=SetNullToFloatPoint;
  x2BottomRight:=SetNullToFloatPoint;

  BlkItem:=ThisDocument.FBlockList.Block[FBlockID];
  BlkItem.GetRectVertex(x2TopLeft,x2BottomRight);

  x2TopLeft.X:=(x2TopLeft.X*FScaleX)+BasePoint.X;
  x2TopLeft.Y:=(x2TopLeft.Y*FScaleY)+BasePoint.Y;
  x2TopLeft.Z:=(x2TopLeft.Z*FScaleZ)+BasePoint.Z;
  ATopLeft:=x2TopLeft;

  x2BottomRight.X:=(x2BottomRight.X*FScaleX)+BasePoint.X;
  x2BottomRight.Y:=(x2BottomRight.Y*FScaleY)+BasePoint.Y;
  x2BottomRight.Z:=(x2BottomRight.Z*FScaleZ)+BasePoint.Z;
  ABottomRight:=x2BottomRight;

  ///еще раз сравнить. Если масштба с минусом, то зеркалиться чертеж

  if ATopLeft.X>x2BottomRight.X then ATopLeft.X:=x2BottomRight.X;
  if ABottomRight.X<x2TopLeft.X then ABottomRight.X:=x2TopLeft.X;

  if ATopLeft.Y<x2BottomRight.Y then ATopLeft.Y:=x2BottomRight.Y;
  if ABottomRight.Y>x2TopLeft.Y then ABottomRight.Y:=x2TopLeft.Y;

end;

procedure TEntityBlockBasic.InsertVertex(Index: Integer; X, Y, Z: Double);
begin
  if VertexCount=0 then
      inherited InsertVertex(Index, X, Y, Z)
  else begin
      VertexAxleX[0]:=X;
      VertexAxleY[0]:=Y;
      VertexAxleZ[0]:=Z;
  end;
end;

procedure TEntityBlockBasic.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
begin
  if VertexCount>0 then
  begin
      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
      LogicalDrawing.PointDraw((Vertex[0].X*AScaleX)+Xshift,(Vertex[0].Y*AScaleY)+Yshift);
  end;
end;

procedure TEntityBlockBasic.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
   AVertex:TFloatPoint;
begin
  if (VertexCount>0)and(not(esMoving in State))then
  begin
      AVertex:=Vertex[0];
      LogicalDrawing.VertexDraw(AVertex.X,AVertex.Y,VERTEXMARKER_BASEPOINT);
  end;
end;

function TEntityBlockBasic.GetJoinVertex(TopLeft, BottomRight: TFloatPoint): Integer;
var
  i:integer;
begin
  Result:=-1;

  //Допуск
  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  // Проверка попадают ли вершины в зону выбора
  for I := 0 to JoinVertexCount - 1 do
  begin
      if PointIn2DRect(JoinVertex[i],TopLeft, BottomRight) then
      begin
        Result:=i;
        break;
      end;
  end;
end;

function TEntityBlockBasic.GetRecalculatedJoinVertex(AIndex: integer
  ): TFloatPoint;
var
  BaseVertex,
  TmpVertex  :TFloatPoint;
begin
  TmpVertex   :=JoinVertex[AIndex];
  BaseVertex  :=Vertex[0];
  TmpVertex.X :=TmpVertex.X+BaseVertex.X;
  TmpVertex.Y :=TmpVertex.Y+BaseVertex.Y;
  TmpVertex.Z :=TmpVertex.Z+BaseVertex.Z;
  Result      :=TmpVertex;
end;

{ TGraphicBlock }

procedure TGraphicBlock.Draw(ABasePoint:TFloatPoint; ABlockID:string;
  AScaleX,AScaleY,AScaleZ:Double; ARotate:integer);
begin
   if VertexCount=0 then
   AddVertex(ABasePoint.X,ABasePoint.Y,ABasePoint.Z);
   BlockID:=ABlockID;
   ScaleX:=AScaleX;
   ScaleY:=AScaleY;
   ScaleZ:=AScaleZ;
   //Rotate:=ARotate;
end;

procedure TGraphicBlock.SetScale(AValue: Double);
begin
   ScaleX:=AValue;
   ScaleY:=AValue;
   ScaleZ:=AValue;
end;

procedure TGraphicBlock.RepaintJoinVertex(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  ValueR                 :Double;
  i                      :integer;
  TmpVertex              :TFloatPoint;
begin
  if JoinVertexCount>0 then
  begin
      ValueR:=1;

      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,
                                  GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,
                                  GetLineWeight(FLineWeight),GetColor(FColor));

      for i:=0 to JoinVertexCount-1 do
      begin
          TmpVertex:=GetRecalculatedJoinVertex(i);
           if esMoving in State then
            TmpVertex:=GetInteractiveVertex(TmpVertex);
          LogicalDrawing.CircleDraw((TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift,ValueR*AScaleX);
      end;
  end;
end;

procedure TGraphicBlock.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  tmpByBlockColor        :TgaColor;
  tmpByBlockLineWeight   :TgaLineWeight;
  AK,BK                  :TFloatPoint;
  BlkItem                :TBlockItem;
  TmpVertex              :TFloatPoint;
begin
  if VertexCount>0 then
  begin
      BlkItem                :=ThisDocument.FBlockList.Block[FBlockID];
      tmpByBlockColor        :=BlkItem.FByBlockColor;
      tmpByBlockLineWeight   :=BlkItem.FByBlockLineWeight;
      BlkItem.FByBlockColor  :=FColor;
      BlkItem.FByBlockLineWeight:=FLineWeight;

      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,
                                  GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,
                                  GetLineWeight(FLineWeight),GetColor(FColor));
      //Конвертирование координаты при перемещении курсора
      if esMoving in State then
        TmpVertex:=GetInteractiveVertex(Vertex[0])
      else
        TmpVertex:=Vertex[0];

      LogicalDrawing.PointDraw((TmpVertex.X*AScaleX)+Xshift,
                                 (TmpVertex.Y*AScaleY)+Yshift);

      // GetRectVertex testing
      if LogicalDrawing.Develop then
      begin
        GetRectVertex(Ak,BK);
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,1,5);
        LogicalDrawing.RectangelDraw((Ak.X*AScaleX)+Xshift,
               (Ak.Y*AScaleY)+Yshift,(Bk.X*AScaleX)+Xshift,(Bk.Y*AScaleY)+Yshift);
      end;

      BlkItem.OwnerBlock:=Self;
      BlkItem.Repaint(TmpVertex.X*AScaleX+Xshift,TmpVertex.Y*AScaleY+Yshift, FScaleX*AScaleX,FScaleY*AScaleY,FScaleZ*AScaleZ,LogicalDrawing,AStyle);

      BlkItem.FByBlockColor     :=tmpByBlockColor;
      BlkItem.FByBlockLineWeight:=tmpByBlockLineWeight;

      RepaintJoinVertex(Xshift,Yshift,AScaleX,AScaleY,AScaleZ, LogicalDrawing, AStyle);
  end;
end;

procedure TGraphicBlock.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
    inherited RepaintVertex(LogicalDrawing);
end;

procedure TGraphicBlock.MoveAllJoinVertex(ADeltaVertex: TFloatPoint);
var
  i:integer;
  TmpVertex:TFloatPoint;
begin
  if (JoinVertexCount>0) then
  begin
    for i:=0 to JoinVertexCount-1 do
    begin
      TmpVertex:=JoinVertex[i];
      TmpVertex.X:=TmpVertex.X+ADeltaVertex.X;
      TmpVertex.Y:=TmpVertex.Y+ADeltaVertex.Y;
      TmpVertex.Z:=TmpVertex.Z+ADeltaVertex.Z;
      JoinVertex[i]:=TmpVertex;
    end;
  end;
end;

function TGraphicBlock.AddJoinVertex(X, Y, Z: Double): Integer;
begin
  Result:=FJoinVertex.Add(x,y,z);
  FJoinNames.Add('');
  //if assigned(FParentList) then
  //FParentList.ChangeCordVertex(FloatPoint(x,y,z));
end;

procedure TGraphicBlock.InsertJoinVertex(Index: Integer; X, Y, Z: Double);
begin
  FJoinVertex.Insert(Index,X,Y,Z);
  FJoinNames.Insert(Index,'');
  //if assigned(FParentList) then
  //FParentList.ChangeCordVertex(FloatPoint(x,y,z));
end;

procedure TGraphicBlock.SetJoinName(Index: Integer; AName: String);
begin
  FJoinNames.Strings[Index]:=AName;
end;

function TGraphicBlock.GetJoinName(Index: Integer): String;
begin
   Result:=FJoinNames.Strings[Index];
end;

procedure TGraphicBlock.SetAttributeValue(AName, AValue: String);
var
  i:integer;
begin
  i:=FAttributes.IndexOfName(AName);
  if i=-1 then
  begin
    FAttributes.AddPair(AName, AValue);
  end
  else begin
    FAttributes.ValueFromIndex[i]:=AValue;
  end;
end;

function TGraphicBlock.GetAttributeValue(AName: String): String;
var
  i:integer;
begin
  i:=FAttributes.IndexOfName(AName);
  if i=-1 then
  begin
    Result:='';
  end
  else begin
    Result:=FAttributes.ValueFromIndex[i];
  end;
end;

procedure TGraphicBlock.DeleteJoinVertex(Index: Integer);
begin
  FJoinVertex.Delete(Index);
  FJoinNames.Delete(Index);
end;

function TGraphicBlock.GetJoinVertex(Index: Integer): TFloatPoint;
begin
  Result:=FJoinVertex.Items[index];
end;

function TGraphicBlock.GetJoinVertexCount: Integer;
begin
  Result:=FJoinVertex.Count;
end;

procedure TGraphicBlock.SetJoinVertex(Index: Integer; AValue: TFloatPoint);
begin
  FJoinVertex.Items[Index]:=AValue;
  //if assigned(FParentList) then
  //FParentList.ChangeCordVertex(FVertex.Items[Index]);
end;

{ TGraphicText }

constructor TGraphicText.Create;
begin
  inherited Create;
  FStyleName     :='STANDARD';
  FAlign         :=gaAttachmentPointBottomLeft;
  FFontSize      :=2.5;
  FFontStyle     :=[];
  FFontName      :=GADEFAULT_FONTNAME;
  FWidth         :=0;
  FHeight        :=0;
  FText          :='';
  FGroupTagName  :='';
end;

destructor TGraphicText.Destroy;
begin
  inherited Destroy;
end;

procedure TGraphicText.Draw(ABasePoint: TFloatPoint; AText: String;
  AAlign: TgaAttachmentPoint; ARotate: integer);
begin
  if VertexCount=0 then
  AddVertex(ABasePoint.X,ABasePoint.Y,ABasePoint.Z);
  Align         :=AAlign;
  FontSize      :=2.5;
  FontStyle     :=[];
  FontName      :=GADEFAULT_FONTNAME;
  Width         :=0;
  Height        :=0;
  Rotate        :=ARotate;
  Text          :=AText;
end;

procedure TGraphicText.Draw(ABasePoint: TFloatPoint; AText: String;
  AAlign: TgaAttachmentPoint; AWidth, AHeight, ARotate: integer);
begin
  if VertexCount=0 then
  AddVertex(ABasePoint.X,ABasePoint.Y,ABasePoint.Z);
  Align         :=AAlign;
  FontSize      :=2.5;
  FontStyle     :=[];
  FontName      :=GADEFAULT_FONTNAME;
  Width         :=AWidth;
  Height        :=AHeight;
  Rotate        :=ARotate;
  Text          :=AText;
end;

function TGraphicText.GetHeight: Double;
begin
  Result:=FHeight;
end;

function TGraphicText.GetText: String;
begin
  Result:=FText;
end;

function TGraphicText.GetWidth: Double;
begin
  Result:=FWidth;
end;

procedure TGraphicText.MoveVertex(Index: integer; NewVertex: TFloatPoint);
var
  dX,dY,dZ:Double;
  Delta:TFloatPoint;
begin
        dX:=NewVertex.X-Vertex[Index].X;
        dY:=NewVertex.Y-Vertex[Index].Y;
        dZ:=NewVertex.Z-Vertex[Index].Z;

        if CordEqualIn2D(Vertex[0],Vertex[Index]) then index:=0;

        if Index=0 then
        begin
            Delta.X:=NewVertex.X-VertexAxleX[Index];
            Delta.Y:=NewVertex.Y-VertexAxleY[Index];
            Delta.Z:=NewVertex.Z-VertexAxleZ[Index];
            MoveGroupChildEntity(Delta);

            VertexAxleX[Index]:=NewVertex.X;
            VertexAxleY[Index]:=NewVertex.Y;
            VertexAxleZ[Index]:=NewVertex.Z;

            if VertexCount>=4 then
            begin
            VertexAxleX[1]:=VertexAxleX[1]+dX;
            VertexAxleY[1]:=VertexAxleY[1]+dY;
            VertexAxleZ[1]:=VertexAxleZ[1]+dZ;

            VertexAxleX[2]:=VertexAxleX[2]+dX;
            VertexAxleY[2]:=VertexAxleY[2]+dY;
            VertexAxleZ[2]:=VertexAxleZ[2]+dZ;

            VertexAxleX[3]:=VertexAxleX[3]+dX;
            VertexAxleY[3]:=VertexAxleY[3]+dY;
            VertexAxleZ[3]:=VertexAxleZ[3]+dZ;

            VertexAxleX[4]:=VertexAxleX[4]+dX;
            VertexAxleY[4]:=VertexAxleY[4]+dY;
            VertexAxleZ[4]:=VertexAxleZ[4]+dZ;
            end;
        end
        else if (Index=1) then
        begin
            //todo
        end
        else if (Index=2) then
        begin
            //todo
        end
        else if (Index=3) then
        begin
            //todo
        end
        else if (Index=4) then
        begin
            //todo
        end;
end;

procedure TGraphicText.GetRectVertex(var ATopLeft, ABottomRight: TFloatPoint);
var
   X0, Y0: Double;
begin
  //inherited GetRectVertex(ATopLeft, ABottomRight);
   X0:=BasePoint.X;
   Y0:=BasePoint.Y;
   if (FWidth<=0)and(FHeight<=0) then
   begin
      {W:=self.ParentList..TextWidth(FText);
      H:=FVirtualCanvas.TextHeight(FText);

      case FAlign of
      gaAttachmentPointTopLeft:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
      end;
      gaAttachmentPointTopCenter:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W div 2;
      end;
      gaAttachmentPointTopRight:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W;
      end;
      gaAttachmentPointMiddleLeft:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.Y:=PointSCS1.Y-H div 2;
      end;
      gaAttachmentPointMiddleCenter:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W div 2;
          PointSCS1.Y:=PointSCS1.Y-H div 2;
      end;
      gaAttachmentPointMiddleRight:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W;
          PointSCS1.Y:=PointSCS1.Y-H div 2;
      end;
      gaAttachmentPointBottomLeft:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X;
          PointSCS1.Y:=PointSCS1.Y-H;
      end;
      gaAttachmentPointBottomCenter:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W div 2;
          PointSCS1.Y:=PointSCS1.Y-H;
      end;
      gaAttachmentPointBottomRight:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W;
          PointSCS1.Y:=PointSCS1.Y-H;
      end;
      end; }
   end
   else begin
      case FAlign of
      gaAttachmentPointTopLeft:
      begin
          ATopLeft.X:=X0;
          ATopLeft.Y:=Y0;
          ABottomRight.X:=X0+FWidth;
          ABottomRight.Y:=Y0-FHeight;
      end;
      gaAttachmentPointTopCenter:
      begin
          ATopLeft.X:=X0-FWidth/2;
          ATopLeft.Y:=Y0;
          ABottomRight.X:=X0+FWidth/2;
          ABottomRight.Y:=Y0-FHeight;
      end;
      gaAttachmentPointTopRight:
      begin
          ATopLeft.X:=X0-FWidth;
          ATopLeft.Y:=Y0;
          ABottomRight.X:=X0;
          ABottomRight.Y:=Y0-FHeight;
      end;
      gaAttachmentPointMiddleLeft:
      begin
          ATopLeft.X:=X0;
          ATopLeft.Y:=Y0+FHeight/2;
          ABottomRight.X:=X0+FWidth;
          ABottomRight.Y:=Y0-FHeight/2;
      end;
      gaAttachmentPointMiddleCenter:
      begin
          ATopLeft.X:=X0-FWidth/2;
          ATopLeft.Y:=Y0+FHeight/2;
          ABottomRight.X:=X0+FWidth/2;
          ABottomRight.Y:=Y0-FHeight/2;
      end;
      gaAttachmentPointMiddleRight:
      begin
          ATopLeft.X:=X0-FWidth;
          ATopLeft.Y:=Y0+FHeight/2;
          ABottomRight.X:=X0;
          ABottomRight.Y:=Y0-FHeight/2;
      end;
      gaAttachmentPointBottomLeft:
      begin
          ATopLeft.X:=X0;
          ATopLeft.Y:=Y0+FHeight;
          ABottomRight.X:=X0+FWidth;
          ABottomRight.Y:=Y0;
      end;
      gaAttachmentPointBottomCenter:
      begin
          ATopLeft.X:=X0-FWidth/2;
          ATopLeft.Y:=Y0+FHeight;
          ABottomRight.X:=X0+FWidth/2;
          ABottomRight.Y:=Y0;
      end;
      gaAttachmentPointBottomRight:
      begin
          ATopLeft.X:=X0-FWidth;
          ATopLeft.Y:=Y0+FHeight;
          ABottomRight.X:=X0;
          ABottomRight.Y:=Y0;
      end;
      end;

   end;
end;

procedure TGraphicText.SetHeight(const Value: Double);
var
  TopLeftTextRect,BottomRightTextRect: TFloatPoint;
begin
  FHeight:=Value;
  if VertexCount=1 then
  begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      AddVertex(TopLeftTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,BottomRightTextRect.Y,0);
      AddVertex(TopLeftTextRect.X,BottomRightTextRect.Y,0);
  end
  else begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      VertexAxleX[1]:=TopLeftTextRect.X;
      VertexAxleY[1]:=TopLeftTextRect.Y;
      VertexAxleX[2]:=BottomRightTextRect.X;
      VertexAxleY[2]:=TopLeftTextRect.Y;
      VertexAxleX[3]:=BottomRightTextRect.X;
      VertexAxleY[3]:=BottomRightTextRect.Y;
      VertexAxleX[4]:=TopLeftTextRect.X;
      VertexAxleY[4]:=BottomRightTextRect.Y;
  end;
end;

procedure TGraphicText.SetWidth(const Value: Double);
var
  TopLeftTextRect,BottomRightTextRect: TFloatPoint;
begin
  TopLeftTextRect:=SetNullToFloatPoint;
  BottomRightTextRect:=SetNullToFloatPoint;
  FWidth:=Value;
  if VertexCount=1 then
  begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      AddVertex(TopLeftTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,BottomRightTextRect.Y,0);
      AddVertex(TopLeftTextRect.X,BottomRightTextRect.Y,0);
  end
  else begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      VertexAxleX[1]:=TopLeftTextRect.X;
      VertexAxleY[1]:=TopLeftTextRect.Y;
      VertexAxleX[2]:=BottomRightTextRect.X;
      VertexAxleY[2]:=TopLeftTextRect.Y;
      VertexAxleX[3]:=BottomRightTextRect.X;
      VertexAxleY[3]:=BottomRightTextRect.Y;
      VertexAxleX[4]:=TopLeftTextRect.X;
      VertexAxleY[4]:=BottomRightTextRect.Y;
  end;
end;

function TGraphicText.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight, AllVertexInRect, MVertx);
end;

function TGraphicText.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
  APoint,APoint1,APoint2,TopLeftTextRect,BottomRightTextRect: TFloatPoint;
begin

  Result:=AFFA_OUTSIDE; //Вне периметра

  // Проверка попадают ли вершины в зону выбора
  CountVertexInRect:=0;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  // Проверка попадает ли базовая точка в зону выбора
  if (VertexCount>0) then
  begin
      if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=0;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
      if (not AllVertexInRect)and(CountVertexInRect>0) then
      begin
        Result:=AFFA_BASEPOINT;
      end;
  end;

  // Проверка попадают ли вершины в зону выбора
  for I := 1 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end;

  // Проверка попадают ли промежуточные точки в зону выбора

    if (not AllVertexInRect)and(VertexCount>=1)and(Result<>AFFA_VERTEX)and(Result<>AFFA_BASEPOINT) then
    begin

    APoint:=Vertex[0];
    for I := 1 to VertexCount - 1 do
    begin
      //AC
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BD
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //AB
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BC
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //CD
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //DA
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      APoint:=Vertex[i];
    end; //for

      SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex*-1);

      // Проверка попадает ли зона выбора в периметр объекта
      if (Result=AFFA_OUTSIDE)and(not AllVertexInRect) then
      begin
          if (FWidth>0)and(FHeight>0)and(VertexCount>0) then
          begin
            GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
            if PointIn2DRect(TopLeft,TopLeftTextRect, BottomRightTextRect) then
              Result:=AFFA_INSIDE;
          end;
      end;

    end;
end;

procedure TGraphicText.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  TextSizeScale :Double;
  TmpVertex     :TFloatPoint;
  GOwnerItem    :TEntity;
begin
  if VertexCount>=1 then
  begin

    if esMoving in State then
    begin
      TmpVertex:=GetInteractiveVertex(Vertex[0]) //Конвертирование координаты при перемещении курсора
    end
    else begin
      GOwnerItem:=RepaintOwnerGroupMove;
      if Assigned(GOwnerItem) then
      begin
         TmpVertex:=GetGroupOwnerInteractiveVertex(GOwnerItem,Vertex[0]);
      end
      else begin
         TmpVertex:=Vertex[0];
      end;
    end;

      if edsSelected in AStyle then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));

    TextSizeScale:=AScaleY;
    if TextSizeScale<0 then
       TextSizeScale:=TextSizeScale*-1;
    LogicalDrawing.SetFontStyleDraw(FFontName, FFontSize*TextSizeScale, FFontStyle);
    LogicalDrawing.TextDraw((TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift, FWidth*AscaleX, FHeight*AscaleY, FRotate, GetText, FAlign);

    if edsSelected in AStyle then
    begin
      if (FWidth>0)and(FHeight>0) then
      begin
        //todo: draw text on selected todo
      end
      else begin
        //LogicalDrawing.GetTextWidth(FText); //todo:
        //LogicalDrawing.GetTextHeight(FText); //todo:
      end;
      //LogicalDrawing.LineDraw(TopLeftPointWCS.X,TopLeftPointWCS.Y,BottomRightPointWCS.X,TopLeftPointWCS.Y);
      //LogicalDrawing.LineDraw(TopLeftPointWCS.X,TopLeftPointWCS.Y,TopLeftPointWCS.X,BottomRightPointWCS.Y);
      //LogicalDrawing.LineDraw(TopLeftPointWCS.X,BottomRightPointWCS.Y,BottomRightPointWCS.X,BottomRightPointWCS.Y);
      //LogicalDrawing.LineDraw(BottomRightPointWCS.X,TopLeftPointWCS.Y,BottomRightPointWCS.X,BottomRightPointWCS.Y);
    end;
  end;
end;


procedure TGraphicText.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex  :TFloatPoint;
begin
    if esMoving in State then
      TmpVertex:=GetInteractiveVertex(Vertex[0])
    else
      TmpVertex:=Vertex[0];

    LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_BASEPOINT);
    for i:=1 to VertexCount-1 do
    begin
      if esMoving in State then
        TmpVertex:=GetInteractiveVertex(Vertex[i])
      else
        TmpVertex:=Vertex[i];
      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
    end;
end;

{ TEntityLineBasic }

function TEntityLineBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
  APoint: TFloatPoint;
begin

  Result:=AFFA_OUTSIDE; //Вне периметра

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  // Проверка попадают ли вершины в зону выбора
  CountVertexInRect:=0;
  for I := 0 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
  begin
    Result:=AFFA_VERTEX;
  end;

    //Проверка попадают ли промежуточные точки в зону выбора
    //ABCD
    if (not AllVertexInRect)and(VertexCount>1)and(Result<>AFFA_VERTEX) then
    begin
        APoint:=Vertex[0];
        for I := 1 to VertexCount - 1 do
        begin
          //AC
          if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          //BD
          if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          //AB
          if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          //BC
          if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          //CD
          if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          //DA
          if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          APoint:=Vertex[i];
        end;
    end;

end;

function TEntityLineBasic.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

procedure TEntityLineBasic.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
begin
  if VertexCount>0 then
  begin
    for i:=0 to VertexCount-1 do
    begin
      LogicalDrawing.VertexDraw(Vertex[i].X,Vertex[i].Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;

{ TGraphicPoint }

procedure TGraphicPoint.AddVertex(X, Y, Z: Double);
begin
  if VertexCount=0 then
      inherited AddVertex(X, Y, Z)
  else begin
      VertexAxleX[0]:=X;
      VertexAxleY[0]:=Y;
      VertexAxleZ[0]:=Z;
  end;
end;

procedure TGraphicPoint.Draw(APoint: TFloatPoint);
begin
   if VertexCount=0 then
   AddVertex(APoint.X,APoint.Y,APoint.Z);
end;

function TGraphicPoint.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TGraphicPoint.GetSelect(TopLeft, BottomRight: TFloatPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  CountVertexInRect:integer;
begin

  Result:=AFFA_OUTSIDE; //Вне периметра
  CountVertexInRect:=0;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

      if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=0;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
    Result:=AFFA_BASEPOINT
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
    Result:=AFFA_BASEPOINT;
end;

procedure TGraphicPoint.InsertVertex(Index: Integer; X, Y, Z: Double);
begin
  if VertexCount=0 then
      inherited InsertVertex(Index, X, Y, Z)
  else begin
      VertexAxleX[0]:=X;
      VertexAxleY[0]:=Y;
      VertexAxleZ[0]:=Z;
  end;
end;

procedure TGraphicPoint.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Double;
  LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
var
   TmpVertex  :TFloatPoint;
begin
  if VertexCount>0 then
  begin
    if esMoving in State then
      TmpVertex:=GetInteractiveVertex(Vertex[0])
    else
      TmpVertex:=Vertex[0];

      if AStyle=[edsSelected] then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
      LogicalDrawing.PointDraw((TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift);
  end;
end;

procedure TGraphicPoint.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  TmpVertex  :TFloatPoint;
begin
  if VertexCount>0 then
  begin
    if esMoving in State then
      TmpVertex:=GetInteractiveVertex(Vertex[0])
    else
      TmpVertex:=Vertex[0];

      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_BASEPOINT);
  end;
end;

end.
