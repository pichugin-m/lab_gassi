unit u_gassi_dxf;

{$mode objfpc}{$H+}

{

 Версия - 2023-02-03
 Версия - 2023-01-29
 Версия - 2020-08-26
 Версия - 2020-08-25
 Версия - 2020-06-30
 Версия - 2020-06-27
 Версия - 2020-06-25

 //DXF Reference is u19.1.01
 //https://en.wikipedia.org/wiki/AutoCAD_DXF
 //https://ezdxf.mozman.at/docs/index.html
 //https://help.autodesk.com/view/ACD/2015/RUS/?guid=GUID-235B22E0-A567-4CF6-92D3-38A2306D73F3

 Реализовано:
 - R12 Линия, Полилиния, Круг, Точка

 Доделать:
 - Арка

 Другое:
 Для элипса и прочего нужна поддержка выше R12

  Autocad-Version	DXF-Version
  Release 5 / Version 2.0	AC1.50
  Release 6 / Version 2.1	AC2.10
  Release 7 / Version 2.5	AC1002
  Release 8 / Version 2.6	AC1003
  Release 9	AC1004
  Release 10	AC1006
  Release 11/12	AC1009
  Release 13	AC1012
  Release 14	AC1014
  Release 2000/0i/2	AC1015
  Release 2004/5/6	AC1018
  Release 2007/8/9	AC1021
  Release 2010/11/12	AC1024
  Release 2013/14	AC1027
  Release 2018	AC1032

}

interface

uses
  Classes, SysUtils, Variants, LazUTF8,
  FileUtil, Dialogs, u_gassi_drawcontrol, u_gassi_visualobjects,
  u_gassi_logicaldraw, u_gassi_const;

procedure BeginWorkDXF;
procedure EndWorkDXF;
procedure ExportModelSpaceToDXF(ADrawDocument:TAssiDrawDocument;AFileName:String);
//procedure ImportModelSpaceFromDXF(ADrawDocument:TAssiDrawDocument;AFileName:String);
procedure ReadSectionsFromDXF(AFileName:String);

var
   fs              : TFormatSettings;

   iHandleIndex,
   iACVersion      :integer;
   bShowClass      :Boolean;
   bDXFReadCancel  :Boolean;
   bDXFWriteBlocks :Boolean;

   slBlockOldNames :TStringList;
   slBlockNewNames :TStringList;

   slTargetList    :TStringList;
   slOutHeader     :TStringList;
   slOutCLASSES    :TStringList; //
   slOutTABLES     :TStringList; //
   slOutBLOCKS     :TStringList; //
   slOutENTITIES   :TStringList; //
   slOutOBJECTS    :TStringList; //
   slOutTHUMBNAILIMAGE :TStringList;

implementation

{

HEADER section
       General information about the drawing. Each parameter has a variable name and an associated value.
CLASSES section
        Holds the information for application-defined classes whose instances appear in the BLOCKS, ENTITIES, and OBJECTS sections of the database. Generally does not provide sufficient information to allow interoperability with other programs.
TABLES section
     This section contains definitions of named items.
     Application ID (APPID) table
     Block Record (BLOCK_RECORD) table
     Dimension Style (DIMSTYLE) table
     Layer (LAYER) table
     Linetype (LTYPE) table
     Text style (STYLE) table
     User Coordinate System (UCS) table
     View (VIEW) table
     Viewport configuration (VPORT) table
BLOCKS section
       This section contains Block Definition entities describing the entities comprising each Block in the drawing.
ENTITIES section
       This section contains the drawing entities, including any Block References.
OBJECTS section
        Contains the data that apply to nongraphical objects, used by AutoLISP, and ObjectARX applications.
THUMBNAILIMAGE section
        Contains the preview image for the DXF file.
END OF FILE

}

{

Controls symbol table naming:
0 = Release 14 compatibility.
Limits names to 31 characters in length. Names can include
the letters A to Z, the numerals 0 to 9, and the special characters dollar sign
($), underscore (_), and hyphen (-).

1 = AutoCAD 2000. Names can be up to 255 characters in length, and can include the
letters A to Z, the numerals 0 to 9, spaces, and any special
characters not used for other purposes by Microsoft Windows and AutoCAD

}

//Encoding
procedure TE_WriteLn(var AOutFile:TextFile; AText:String);
begin
    Writeln(AOutFile, UTF8ToWinCP(AText));
end;

function SymbolTableNaming(AText:string):string;
var
 i:integer;
begin
  Result:='';
  //AText:=UpperCASE(AText);
  for i:=1 to length(AText) do
  begin
    if (AText[i] in ['0'..'9','A'..'Z','a'..'z','$','_','-']) then
    begin
       Result:=Result+AText[i];
    end;
  end;
end;

//До версии AC1015 имена короткие
function ConvertNameToDXF(AName:String): String;
var
   i,k:integer;
begin

   if (iACVersion<4) then
   begin
      AName:=StringReplace(AName,'{','',[]);
      AName:=StringReplace(AName,'}','',[]);
      AName:='$GA'+AName;

      AName:=SymbolTableNaming(AName);
      if Length(AName)=3 then
         AName:='$GA';
   end;

   if (iACVersion<4) then
   begin
      i:=slBlockOldNames.IndexOf(AName);
      if i=-1 then
      begin
         slBlockOldNames.Add(AName);

         if (Length(AName)>31) then
         begin
           k:=1;
           Result:=Copy(AName,1,28);
           Result:=Result+'_'+inttostr(k);

           while slBlockNewNames.IndexOf(Result)>-1 do
           begin
            k:=k+1;
            Result:=Copy(AName,1,28);
            Result:=Result+'_'+inttostr(k);
           end;
         end
         else begin
            Result:=AName;
         end;

         slBlockNewNames.Add(Result);
      end
      else begin
         Result:=slBlockNewNames.Strings[i];
      end;
   end
   else begin
       Result:=AName;
   end;
end;

/////////Read

function DXFStrToVariant(ACodeKey:integer;ACodeValue:String):Variant;
begin
  Result:=null;
  if ACodeKey in [0..9] then //String
  begin
     Result:=ACodeValue;
  end
  else if ACodeKey in [10..39] then //Double precision 3D point value
  begin
     Result:=StrToFloat(ACodeValue);
  end
  else if ACodeKey in [40..59] then //Double-precision floating-point value
  begin
     Result:=StrToFloat(ACodeValue);
  end
  else if ACodeKey in [60..79] then //16-bit integer value
  begin
     Result:=StrToInt(ACodeValue);
  end
  else if ACodeKey in [90..99] then //32-bit integer value
  begin
     Result:=StrToInt(ACodeValue);
  end
  else if ACodeKey in [110..119,120..129,130..139] then //Double precision floating-point value
  begin
     Result:=StrToFloat(ACodeValue);
  end
  else if ACodeKey in [140..149] then //Double precision
  begin
     Result:=StrToFloat(ACodeValue);
  end
  else if ACodeKey in [210..239] then //Double precision
  begin
     Result:=StrToFloat(ACodeValue);
  end
  else
  begin
     raise Exception.Create('Unknow code');
     Result:=null;
  end;
end;

function DXFReadCode(ASection:TStringList; AIndex:integer;
  var AOutCodeKey:integer; var AOutCodeValue:String):boolean;
begin
  try
     AOutCodeKey:=StrToInt(ASection.Strings[AIndex]);
     AOutCodeValue:=ASection.Strings[AIndex+1];

     Result:=True;
  except
     Result:=False;
  end;
end;

function DXFWriteCode(AIndex:integer;
  ACodeKey:integer; ACodeValue:String):boolean;
begin
  try
     if AIndex=-1 then
     begin
        slTargetList.Add(Utf8ToAnsi(IntToStr(ACodeKey)));
        slTargetList.Add(Utf8ToAnsi(ACodeValue));
     end
     else begin
        slTargetList.Strings[AIndex]:=Utf8ToAnsi(IntToStr(ACodeKey));
        slTargetList.Strings[AIndex+1]:=Utf8ToAnsi(ACodeValue);
     end;

     Result:=True;
  except
     Result:=False;
  end;
end;

function DXFReadGetParamIndex(ASection:TStringList; AParamCode:integer; AParamName:String):integer;
var
  iCount,iCur        :integer;
  iOutCodeKey        :integer;
  iOutCodeValue      :String;
begin
  Result             :=-1;
  iCount             :=ASection.Count-1;
  iCur               :=0;
  while iCur<=iCount do
  begin
      if DXFReadCode(ASection, iCur, iOutCodeKey, iOutCodeValue) then
      begin
         if (iOutCodeKey=AParamCode)and(CompareText(iOutCodeValue,AParamName)=0) then
         begin
             Result:=iCur;
             break;
         end;
      end;
      iCur:=iCur+2;
  end;
end;

function DXFReadGetParam(ASection:TStringList; AStart, AParamCode:integer):Variant;
var
  iCount,iCur            :integer;
  iOutCodeKey            :integer;
  iOutCodeValue          :String;
begin
  Result                 :=null;
  iOutCodeKey            :=-1;
  iOutCodeValue          :='';
  iCount                 :=ASection.Count-1;
  iCur                   :=AStart;
  while iCur<=iCount do
  begin
      if DXFReadCode(ASection, iCur, iOutCodeKey, iOutCodeValue) then
      begin
         if (iOutCodeKey=AParamCode) then
         begin
             Result:=DXFStrToVariant(iOutCodeKey,iOutCodeValue);
             break;
         end;
      end;
      iCur:=iCur+2;
  end;
end;

procedure DXFRead_Section(AFile,ASection:TStringList;ASectionName:String);
var
  i,iStart,iEnd :integer;
begin
  iStart             :=0;
  iEnd               :=0;
  ASection.Clear;
  for i:=0 to AFile.Count-1 do
  begin
      if CompareText(AFile.Strings[i],ASectionName)=0 then
      begin
         iStart:=i;
         break;
      end;
  end;

  if iStart>0 then
  begin

    for i:=iStart to AFile.Count-1 do
    begin
        if CompareText(AFile.Strings[i],'ENDSEC')=0 then
        begin
           iEnd:=i;
           break;
        end;
    end;

    iStart:=iStart+1;
    iEnd:=iEnd-2;
  end;

  if (iStart>0)and(iEnd>0)and(iStart<iEnd) then
  begin
      for i:=iStart to iEnd do
      begin
          ASection.Add(AFile.Strings[i]);
      end;
  end;
  {
    0
    SECTION
    2
    THUMBNAILIMAGE

    0
    ENDSEC
  }
end;

function HexToInt(HexNum: string): LongInt;
begin
  Result:=StrToInt('$' + HexNum);
end;

procedure DXFRead_Data_HEADER;
var
  iParamIndex :integer;
  vValue:Variant;
begin
  iParamIndex:=DXFReadGetParamIndex(slOutHEADER, 9 ,'$HANDSEED');
  vValue:=DXFReadGetParam(slOutHEADER, iParamIndex, 5);
  if not Variants.VarIsNull(vValue) then
  begin
     iHandleIndex:=HexToInt(vValue);
  end;

  iParamIndex:=DXFReadGetParamIndex(slOutHEADER, 9 ,'$ACADVER');
  vValue:=DXFReadGetParam(slOutHEADER, iParamIndex, 1);
  if not Variants.VarIsNull(vValue) then
  begin
    if CompareText(vValue,'AC1006')=0 then
       iACVersion:=0
    else if CompareText(vValue,'AC1009')=0 then
       iACVersion:=1
    else if CompareText(vValue,'AC1012')=0 then
       iACVersion:=2
    else if CompareText(vValue,'AC1014')=0 then
       iACVersion:=3
    else if CompareText(vValue,'AC1015')=0 then
       iACVersion:=4
    else if CompareText(vValue,'AC1018')=0 then
       iACVersion:=5
    else if CompareText(vValue,'AC1021')=0 then
       iACVersion:=6
    else if CompareText(vValue,'AC1024')=0 then
       iACVersion:=7
    else if CompareText(vValue,'AC1027')=0 then
       iACVersion:=8
    else if CompareText(vValue,'AC1032')=0 then
       iACVersion:=9
    else
       iACVersion:=-1;
  end;

  if iACVersion=-1 then
  begin
     Dialogs.ShowMessage('Unknow version DXF file');
     bDXFReadCancel:=True;
  end;

  if iACVersion>1 then
     bShowClass:=True;

end;

procedure ReadSectionsFromDXF(AFileName:String);
var
  slFile               :TStringList;
  i                    :integer;
begin

  try
     bDXFReadCancel    :=False;
     slFile            :=TStringList.Create;
     slFile.LoadFromFile(AFileName);
     for i:=0 to slFile.Count-1 do
     begin
        slFile.Strings[i]:=WinCPToUTF8(slFile.Strings[i]);
     end;
     DXFRead_Section(slFile,slOutHEADER,'HEADER');
     DXFRead_Section(slFile,slOutCLASSES,'CLASSES');
     DXFRead_Section(slFile,slOutTABLES,'TABLES');
     DXFRead_Section(slFile,slOutBLOCKS,'BLOCKS');
     DXFRead_Section(slFile,slOutENTITIES,'ENTITIES');
     DXFRead_Section(slFile,slOutOBJECTS,'OBJECTS');
     DXFRead_Section(slFile,slOutTHUMBNAILIMAGE,'THUMBNAILIMAGE');

     DXFRead_Data_HEADER;

  finally
     slFile.free;
  end;

end;


/////////Write

procedure DXFWriteLn(AText:String);
begin
    //Writeln(AOutFile, Utf8ToAnsi(AText));
    slTargetList.Add(Utf8ToAnsi(AText));
end;


procedure DXFWriteBegin(ADrawDocument:TAssiDrawDocument);
var
  i:integer;
  DrwEntity:TEntity;
begin

  for i:=0 to ADrawDocument.ModelSpace.Objects.Count-1 do
  begin
     DrwEntity:=ADrawDocument.ModelSpace.Objects.Items[i];
     if DrwEntity is TGraphicEllipse then
     begin
        if iACVersion<2 then
           iACVersion:=2;
     end;
     {else if DrwEntity is TGraphicText then
     begin
        if iACVersion<2 then
           iACVersion:=2;
     end
     }
  end;

  if iACVersion>1 then
     bShowClass:=True;
end;

procedure DXFWriteHandle;
begin
  DXFWriteLn('5');
  DXFWriteLn(IntToHex(iHandleIndex,1));
  inc(iHandleIndex);
end;

{Общее}

procedure DXFWrite_CommonGroupCodes(AEntityName:String;AEntity:TEntity);
begin
  //Тип
  DXFWriteLn('0');
  DXFWriteLn(AEntityName);
  if (bShowClass) then
  begin
  DXFWriteHandle; //5
  DXFWriteLn('100');
  DXFWriteLn('AcDbEntity');
  end;
  //Слой
  DXFWriteLn('8');
  DXFWriteLn(AEntity.LayerName); //Имя слоя

  //Тип линии
  //DXFWriteLn('6');
  //DXFWriteLn('BYLAYER');
  {
  //Цвет
  //0 - BYBLOCK
  //256 - BYLAYER;
  //-1 - the layer is turned off (optional)
  DXFWriteLn('62');
  DXFWriteLn(256);
  }

  //Вес линии
  if (bShowClass) then
  if AEntity.LineWeight<>gaLnWtByLayer then
  begin
    DXFWriteLn('370'); //Не предусмотрено R12
    if AEntity.LineWeight=gaLnWtByBlock then
    begin
       DXFWriteLn('-2');
    end
    else if AEntity.LineWeight=gaLnWtByLwDefault then
    begin
       DXFWriteLn('-3');
    end
    else begin
       //DXFWriteLn(IntToStr(HexToInt(IntToStr(AEntity.LineWeight))));
       DXFWriteLn(IntToStr(AEntity.LineWeight));
    end;
  end;

  {
  //Масштаб линии
  DXFWriteLn('48');
  DXFWriteLn('1.0');
  }
end;

procedure DXFWrite_Vertex(AX,AY,AZ:Double);
begin
  //DXFWrite_CommonGroupCodes('VERTEX','0');
  //Тип
  DXFWriteLn('0');
  DXFWriteLn('VERTEX');
  if (bShowClass) then
  begin
  DXFWriteHandle; //5
  DXFWriteLn('100');
  DXFWriteLn('AcDbEntity');
  end;
  //Слой
  DXFWriteLn('8');
  DXFWriteLn('0'); //Имя слоя
  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbVertex');
  end;
  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDb2dVertex');
  end;
  DXFWriteLn('10'); //point X
  DXFWriteLn(FloatToStr(AX,fs));
  DXFWriteLn('20'); //point Y
  DXFWriteLn(FloatToStr(AY,fs));
  DXFWriteLn('30'); //point Z
  DXFWriteLn(FloatToStr(AZ,fs));

  DXFWriteLn('40'); // Starting width (optional; default is 0)
  DXFWriteLn('0');
  DXFWriteLn('41'); // End width (optional; default is 0)
  DXFWriteLn('0');

  {
  Vertex flags:
  1 = Extra vertex created by curve-fitting
  2 = Curve-fit tangent defined for this vertex. A curve-fit tangent direction of 0 may be omitted
  from DXF output but is significant if this bit is set
  4 = Not used
  8 = Spline vertex created by spline-fitting
  16 = Spline frame control point
  32 = 3D polyline vertex
  64 = 3D polygon mesh
  128 = Polyface mesh vertex
  }
  DXFWriteLn('70');
  DXFWriteLn('0');

  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Vertex(AEntity:TEntity; Index:integer);
begin
  DXFWrite_Vertex(AEntity.Vertex[index].X,AEntity.Vertex[index].Y,AEntity.Vertex[index].Z);
end;

procedure DXFWrite_SeqEnd(AEntity:TEntity);
begin
  DXFWriteLn('0');
  DXFWriteLn('SEQEND');
  if (bShowClass) then
  begin
  DXFWriteHandle; //5
  DXFWriteLn('100');
  DXFWriteLn('AcDbEntity');
  end;
  //Слой
  DXFWriteLn('8');
  DXFWriteLn('0'); //Имя слоя
end;

{Объекты}

procedure DXFWrite_Point(AEntity:TGraphicPoint);
begin
  DXFWrite_CommonGroupCodes('POINT',AEntity);

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbPoint');
  end;

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));

  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Line(AEntity:TGraphicLine);
begin
  DXFWrite_CommonGroupCodes('LINE',AEntity);

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbLine');
  end;

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
  DXFWriteLn('11'); //End point X
  DXFWriteLn(FloatToStr(AEntity.Vertex[1].X,fs));
  DXFWriteLn('21'); //End point Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[1].Y,fs));
  DXFWriteLn('31'); //End point Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[1].Z,fs));

  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_PolyLine(AEntity:TGraphicPolyline);
var
  i:integer;
begin
  DXFWrite_CommonGroupCodes('POLYLINE',AEntity);

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDb2dPolyline');
  end;

  DXFWriteLn('66');
  DXFWriteLn('1');

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn('0');
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn('0');
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn('0');
  {
   Polyline flag (bit-coded; default = 0):
    1 = This is a closed polyline (or a polygon mesh closed in the M direction)
    2 = Curve-fit vertices have been added
    4 = Spline-fit vertices have been added
    8 = This is a 3D polyline
    16 = This is a 3D polygon mesh
    32 = The polygon mesh is closed in the N direction
    64 = The polyline is a polyface mesh
    128 = The linetype pattern is generated continuously around the vertices of this polyline
  }
  DXFWriteLn('70');
  if AEntity.Closed then
    DXFWriteLn('1')
  else
    DXFWriteLn('0');

  for i:=0 to AEntity.VertexCount-1 do
      DXFWrite_Vertex(AEntity,i);

  DXFWrite_SeqEnd(AEntity);
  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Connectionline(AEntity:TGraphicConnectionline);
var
  i:integer;
  Points   :TPointsArray;
begin
  DXFWrite_CommonGroupCodes('POLYLINE',AEntity);

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDb2dPolyline');
  end;

  DXFWriteLn('66');
  DXFWriteLn('1');

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn('0');
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn('0');
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn('0');
  {
   Polyline flag (bit-coded; default = 0):
    1 = This is a closed polyline (or a polygon mesh closed in the M direction)
    2 = Curve-fit vertices have been added
    4 = Spline-fit vertices have been added
    8 = This is a 3D polyline
    16 = This is a 3D polygon mesh
    32 = The polygon mesh is closed in the N direction
    64 = The polyline is a polyface mesh
    128 = The linetype pattern is generated continuously around the vertices of this polyline
  }
  DXFWriteLn('70');
  DXFWriteLn('0'); //Close false

  AEntity.GetLinePointsVertex(Points);

  for i:=0 to high(Points) do
      DXFWrite_Vertex(Points[i].X,Points[i].Y,Points[i].Z);

  DXFWrite_SeqEnd(AEntity);
  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Text(AEntity:TGraphicText);
var
  a:double;
begin
  DXFWrite_CommonGroupCodes('TEXT',AEntity);

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbText');
  end;

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));

  DXFWriteLn('40');
  DXFWriteLn(FloatToStr(AEntity.FontSize,fs));

  DXFWriteLn('1');
  DXFWriteLn(AEntity.Text);

  DXFWriteLn('50');
  DXFWriteLn(FloatToStr(AEntity.Rotate,fs));//не реализовано в программе

  DXFWriteLn('7');  //Style
  if AEntity.StyleName='' then
    DXFWriteLn('STANDARD')
  else
    DXFWriteLn(AEntity.StyleName);

  DXFWriteLn('71');
  DXFWriteLn('0');
  {
  Horizontal text justification type (optional, default = 0) integer codes (not bit-coded)
0 = Left; 1= Center; 2 = Right
3 = Aligned (if vertical alignment = 0)
4 = Middle (if vertical alignment = 0)
5 = Fit (if vertical alignment = 0)
See the Group 72 and 73 integer codes table for clarification
  }

      case AEntity.Align of
      gaAttachmentPointTopLeft:
      begin
         DXFWriteLn('72');
         DXFWriteLn('0');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('3');
      end;
      gaAttachmentPointTopCenter:
      begin
         DXFWriteLn('72');
         DXFWriteLn('1');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('3');
      end;
      gaAttachmentPointTopRight:
      begin
         DXFWriteLn('72');
         DXFWriteLn('2');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('3');
      end;
      gaAttachmentPointMiddleLeft:
      begin
         DXFWriteLn('72');
         DXFWriteLn('0');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('2');
      end;
      gaAttachmentPointMiddleCenter:
      begin
         DXFWriteLn('72');
         DXFWriteLn('1');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('2');
      end;
      gaAttachmentPointMiddleRight:
      begin
         DXFWriteLn('72');
         DXFWriteLn('2');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('2');
      end;
      gaAttachmentPointBottomLeft:
      begin
         DXFWriteLn('72');
         DXFWriteLn('0');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('1');
      end;
      gaAttachmentPointBottomCenter:
      begin
         DXFWriteLn('72');
         DXFWriteLn('1');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('1');
      end;
      gaAttachmentPointBottomRight:
      begin
         DXFWriteLn('72');
         DXFWriteLn('2');
          DXFWriteLn('11'); //X
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
          DXFWriteLn('21'); //Y
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
          DXFWriteLn('31'); //Z
          DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
         if (bShowClass) then
          begin
          DXFWriteLn('100');
          DXFWriteLn('AcDbText');
         end;
         DXFWriteLn('73');
         DXFWriteLn('1');
      end;
      end;

  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Circle(AEntity:TGraphicCircle);
begin
  DXFWrite_CommonGroupCodes('CIRCLE',AEntity);

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbCircle');
  end;

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
  DXFWriteLn('40'); //Radius
  DXFWriteLn(FloatToStr(AEntity.Radius,fs));

  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Arc(AEntity:TGraphicArc);
begin
  DXFWrite_CommonGroupCodes('ARC',AEntity);

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbCircle');
  end;

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));

  DXFWriteLn('40'); //R
  DXFWriteLn(FloatToStr(AEntity.Radius,fs));

  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbArc');
  end;
  //todo: доделать расчет углов
  DXFWriteLn('50'); //Start angle
  DXFWriteLn('0');
  DXFWriteLn('51'); //End angle
  DXFWriteLn('180');

  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Ellipse(AEntity:TGraphicEllipse);
var
  a:double;
begin
  DXFWrite_CommonGroupCodes('ELLIPSE',AEntity);
  //Код не протестирован за отсутствием поддержки выше R12
  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbEllipse');
  end;

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));

  if AEntity.AxleX>AEntity.AxleY then
  begin
     a:=AEntity.AxleY/AEntity.AxleX;
     DXFWriteLn('11'); //X
     DXFWriteLn(FloatToStr(AEntity.Vertex[0].X+AEntity.AxleX,fs));
     DXFWriteLn('21'); //Y
     DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
     DXFWriteLn('31'); //Z
     DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
  end
  else begin
     a:=AEntity.AxleX/AEntity.AxleY;
     DXFWriteLn('11'); //X
     DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
     DXFWriteLn('21'); //Y
     DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y+AEntity.AxleY,fs));
     DXFWriteLn('31'); //Z
     DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));
  end;

  DXFWriteLn('40'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(a,fs));
  DXFWriteLn('41');
  DXFWriteLn('0');
  DXFWriteLn('42');
  DXFWriteLn('0');

  //extrusion выдавливание 3D
  //210,220,230
end;

procedure DXFWrite_Insert(AEntity:TGraphicBlock);
begin
  DXFWrite_CommonGroupCodes('INSERT',AEntity);
  //Код не протестирован за отсутствием поддержки выше R12
  if (bShowClass) then
  begin
  DXFWriteLn('100');
  DXFWriteLn('AcDbBlockReference');
  end;

  DXFWriteLn('2');
  DXFWriteLn(ConvertNameToDXF(AEntity.BlockID));

  DXFWriteLn('10'); //Start point (in WCS) X
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].X,fs));
  DXFWriteLn('20'); //Start point (in WCS) Y
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Y,fs));
  DXFWriteLn('30'); //Start point (in WCS) Z
  DXFWriteLn(FloatToStr(AEntity.Vertex[0].Z,fs));

  DXFWriteLn('41'); //X
  DXFWriteLn(FloatToStr(AEntity.ScaleX,fs));
  DXFWriteLn('42'); //Y
  DXFWriteLn(FloatToStr(AEntity.ScaleY,fs));
  DXFWriteLn('43'); //Z
  DXFWriteLn(FloatToStr(AEntity.ScaleZ,fs));

  DXFWriteLn('50'); //Rotation
  DXFWriteLn(FloatToStr(0,fs));

end;

{Заголовки}

procedure DXFWrite_Header(ADrawDocument:TAssiDrawDocument);
var
  iCur:integer;
begin
  iCur:=-1;

  iCur:=DXFReadGetParamIndex(slTargetList, 9 ,'$ACADVER');
  if iCur=-1 then
  begin
    DXFWriteCode(iCur,9,'$ACADVER')
  end
  else begin
    iCur:=iCur+2;
  end;
  case iACVersion of
  0: DXFWriteCode(iCur,1,'AC1006');
  1: DXFWriteCode(iCur,1,'AC1009');
  2: DXFWriteCode(iCur,1,'AC1012');
  3: DXFWriteCode(iCur,1,'AC1014');
  4: DXFWriteCode(iCur,1,'AC1015');
  5: DXFWriteCode(iCur,1,'AC1018');
  end;
  {
   The AutoCAD drawing database version number:
   AC1006 = R10;
   AC1009 = R11 and R12;
   AC1012 = R13;
   AC1014 = R14;
   AC1015 = AutoCAD 2000;
   AC1018 = AutoCAD 2004
  }

  iCur:=DXFReadGetParamIndex(slTargetList, 9 ,'$EXTNAMES');
  if iCur=-1 then
  begin
     if iACVersion>=4 then
     begin
       DXFWriteCode(iCur,9,'$EXTNAMES');
       DXFWriteCode(iCur,290,'1');//1-Длинные имена, 0-Имена длиной 31 символ
     end;
  end
  else begin
    iCur:=iCur+2;
    if iACVersion>=4 then
    begin
      DXFWriteCode(iCur,290,'1');//1-Длинные имена, 0-Имена длиной 31 символ
    end;
  end;

  iCur:=DXFReadGetParamIndex(slTargetList, 9 ,'$HANDSEED');
  if iCur=-1 then
  begin
     if (bShowClass) then
     begin
     DXFWriteCode(iCur,9,'$HANDSEED');
     DXFWriteCode(iCur,5,IntToHex(iHandleIndex,1)); //следующий свободный хендл
     end;
  end
  else begin
    iCur:=iCur+2;
      if (bShowClass) then
      begin
        DXFWriteCode(iCur,5,IntToHex(iHandleIndex,1)); //следующий свободный хендл
      end;
  end;
  {
  iCur:=DXFReadGetParamIndex(slTargetList, 9 ,'$LASTSAVEDBY');
  if iCur=-1 then
  begin
     DXFWriteCode(iCur,9,'$LASTSAVEDBY');
     DXFWriteCode(iCur,1,'UserName');
  end
  else begin
    iCur:=iCur+2;
     DXFWriteCode(iCur,1,'UserName');
  end;
  }
end;

procedure DXFWrite_Classes(ADrawDocument:TAssiDrawDocument);
begin

end;

procedure DXFWrite_Tables(ADrawDocument:TAssiDrawDocument);
begin
{
   * Linetype table (LTYPE)

   * Layer table (LAYER)

   * Text Style table (STYLE)

   * View table (VIEW)

   * User Coordinate System table (UCS)

   * Viewport configuration table (VPORT)

   * Dimension Style table (DIMSTYLE)

   * Application Identification table (APPID)
}
end;

procedure DXFWrite_Blocks(ADrawDocument:TAssiDrawDocument);
var
  BlockItem:TBlockItem;
  DrwEntity:TEntity;
  k,i:integer;
begin

     for k:=0 to ADrawDocument.Blocks.Count-1 do
     begin
         BlockItem:=ADrawDocument.Blocks.Items[k];

         DXFWriteLn('0');
         DXFWriteLn('BLOCK');

         if (bShowClass) then
         begin
          DXFWriteHandle; //5
          DXFWriteLn('100');
          DXFWriteLn('AcDbEntity');

          //Слой
          DXFWriteLn('8');
          DXFWriteLn('0'); //Имя слоя

          DXFWriteLn('100');
          DXFWriteLn('AcDbBlockBegin');
         end;

         DXFWriteLn('2');
         DXFWriteLn(ConvertNameToDXF(BlockItem.Name));

         DXFWriteLn('70');
         DXFWriteLn('0');

         DXFWriteLn('10'); //Base point (in WCS) X
         DXFWriteLn('0');
         DXFWriteLn('20'); //Base point (in WCS) Y
         DXFWriteLn('0');
         DXFWriteLn('30'); //Base point (in WCS) Z
         DXFWriteLn('0');

         DXFWriteLn('3');
         DXFWriteLn(ConvertNameToDXF(BlockItem.Name));

         //DXFWriteLn('4');
         //DXFWriteLn('Description');

         for i:=0 to BlockItem.Objects.Count-1 do
         begin
             DrwEntity:=BlockItem.Objects.Items[i];
             if DrwEntity is TGraphicLine then
             begin
                DXFWrite_Line(TGraphicLine(DrwEntity));
             end
             else if DrwEntity is TGraphicPolyline then
             begin
                DXFWrite_PolyLine(TGraphicPolyline(DrwEntity));
             end
             else if DrwEntity is TGraphicConnectionline then
             begin
                DXFWrite_Connectionline(TGraphicConnectionline(DrwEntity));
             end
             else if DrwEntity is TGraphicRectangel then
             begin
                DXFWrite_PolyLine(TGraphicPolyline(DrwEntity));
             end
             else if DrwEntity is TGraphicPoint then
             begin
                DXFWrite_Point(TGraphicPoint(DrwEntity));
             end
             else if DrwEntity is TGraphicText then
             begin
                DXFWrite_Text(TGraphicText(DrwEntity));
             end
             else if DrwEntity is TGraphicCircle then
             begin
                DXFWrite_Circle(TGraphicCircle(DrwEntity));
             end
             else if DrwEntity is TGraphicArc then
             begin
                DXFWrite_Arc(TGraphicArc(DrwEntity));
             end
             else if DrwEntity is TGraphicBlock then
             begin
                DXFWrite_Insert(TGraphicBlock(DrwEntity));
             end
             else if DrwEntity is TGraphicEllipse then
             begin //R13
                DXFWrite_Ellipse(TGraphicEllipse(DrwEntity));
             end;
         end;

         DXFWriteLn('0');
         DXFWriteLn('ENDBLK');

         if (bShowClass) then
         begin
          DXFWriteHandle; //5
          DXFWriteLn('100');
          DXFWriteLn('AcDbEntity');

          //Слой
          DXFWriteLn('8');
          DXFWriteLn('0'); //Имя слоя

          DXFWriteLn('100');
          DXFWriteLn('AcDbBlockEnd');
         end;

     end;
end;

procedure DXFWrite_Entities(ADrawDocument:TAssiDrawDocument);
var
  DrwEntity:TEntity;
  i:integer;
begin
     for i:=0 to ADrawDocument.ModelSpace.Objects.Count-1 do
     begin
         DrwEntity:=ADrawDocument.ModelSpace.Objects.Items[i];

         if DrwEntity is TGraphicLine then
         begin
            DXFWrite_Line(TGraphicLine(DrwEntity));
         end
         else if DrwEntity is TGraphicPolyline then
         begin
            DXFWrite_PolyLine(TGraphicPolyline(DrwEntity));
         end
         else if DrwEntity is TGraphicConnectionline then
         begin
            DXFWrite_Connectionline(TGraphicConnectionline(DrwEntity));
         end
         else if DrwEntity is TGraphicRectangel then
         begin
            DXFWrite_PolyLine(TGraphicPolyline(DrwEntity));
         end
         else if DrwEntity is TGraphicPoint then
         begin
            DXFWrite_Point(TGraphicPoint(DrwEntity));
         end
         else if DrwEntity is TGraphicText then
         begin
            DXFWrite_Text(TGraphicText(DrwEntity));
         end
         else if DrwEntity is TGraphicCircle then
         begin
            DXFWrite_Circle(TGraphicCircle(DrwEntity));
         end
         else if DrwEntity is TGraphicArc then
         begin
            DXFWrite_Arc(TGraphicArc(DrwEntity));
         end
         else if DrwEntity is TGraphicBlock then
         begin
            DXFWrite_Insert(TGraphicBlock(DrwEntity));
         end
         else if DrwEntity is TGraphicEllipse then
         begin //R13
            DXFWrite_Ellipse(TGraphicEllipse(DrwEntity));
         end;

     end;

end;

procedure DXFWrite_Objects(ADrawDocument:TAssiDrawDocument);
begin
  //Objects
end;

procedure DXFWrite_ThumbnailImage(ADrawDocument:TAssiDrawDocument);
begin
  //ThumbnailImage
end;

procedure ExportModelSpaceToDXF(ADrawDocument:TAssiDrawDocument;AFileName:String);
var
  OutFile: TextFile;
  i:integer;
begin

  try
     try
       Assign(OutFile, AFileName);
       Rewrite(OutFile);
     except
        Dialogs.ShowMessage('Cant write DXF file');
        exit;
     end;

     slTargetList:=slOutENTITIES;
     DXFWriteBegin(ADrawDocument);
     if (bShowClass) then
        DXFWrite_Classes(ADrawDocument);
     DXFWrite_Tables(ADrawDocument);
     slTargetList:=slOutBLOCKS;
     if bDXFWriteBlocks then
     DXFWrite_Blocks(ADrawDocument);
     slTargetList:=slOutENTITIES;
     DXFWrite_Entities(ADrawDocument);
     if (bShowClass) then
        DXFWrite_Objects(ADrawDocument);
     //DXFWrite_ThumbnailImage(ADrawDocument);
     slTargetList:=slOutHeader;
     DXFWrite_Header(ADrawDocument);
     slTargetList:=slOutENTITIES;

     //Собираем в правильном порядке следования

     if slOutHeader.Count>0 then
     begin
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'SECTION');
        TE_WriteLn(OutFile, '2');
        TE_WriteLn(OutFile, 'HEADER');
         for i:=0 to slOutHeader.Count-1 do
         begin
            TE_WriteLn(OutFile, slOutHeader.Strings[i]);
         end;
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'ENDSEC');
     end;

     if slOutCLASSES.Count>0 then
     begin
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'SECTION');
        TE_WriteLn(OutFile, '2');
        TE_WriteLn(OutFile, 'CLASSES');
         for i:=0 to slOutCLASSES.Count-1 do
         begin
            TE_WriteLn(OutFile, slOutCLASSES.Strings[i]);
         end;
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'ENDSEC');
     end;

     if slOutTABLES.Count>0 then
     begin
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'SECTION');
        TE_WriteLn(OutFile, '2');
        TE_WriteLn(OutFile, 'TABLES');
        for i:=0 to slOutTABLES.Count-1 do
        begin
           TE_WriteLn(OutFile, slOutTABLES.Strings[i]);
        end;
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'ENDSEC');
     end;

     if slOutBLOCKS.Count>0 then
     begin
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'SECTION');
        TE_WriteLn(OutFile, '2');
        TE_WriteLn(OutFile, 'BLOCKS');
        for i:=0 to slOutBLOCKS.Count-1 do
        begin
             TE_WriteLn(OutFile, slOutBLOCKS.Strings[i]);
        end;
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'ENDSEC');
     end;

     if slOutENTITIES.Count>0 then
     begin
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'SECTION');
        TE_WriteLn(OutFile, '2');
        TE_WriteLn(OutFile, 'ENTITIES');
        for i:=0 to slOutENTITIES.Count-1 do
        begin
          TE_WriteLn(OutFile, slOutENTITIES.Strings[i]);
        end;
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'ENDSEC');
     end;

     if slOutOBJECTS.Count>0 then
     begin
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'SECTION');
        TE_WriteLn(OutFile, '2');
        TE_WriteLn(OutFile, 'OBJECTS');
         for i:=0 to slOutOBJECTS.Count-1 do
         begin
            TE_WriteLn(OutFile, slOutOBJECTS.Strings[i]);
         end;
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'ENDSEC');
     end;

     if slOutTHUMBNAILIMAGE.Count>0 then
     begin
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'SECTION');
        TE_WriteLn(OutFile, '2');
        TE_WriteLn(OutFile, 'THUMBNAILIMAGE');
         for i:=0 to slOutTHUMBNAILIMAGE.Count-1 do
         begin
            TE_WriteLn(OutFile, slOutTHUMBNAILIMAGE.Strings[i]);
         end;
        TE_WriteLn(OutFile, '0');
        TE_WriteLn(OutFile, 'ENDSEC');
     end;

     TE_WriteLn(OutFile, '0');
     TE_WriteLn(OutFile, 'EOF');

     Close(OutFile);

  finally

  end;

end;

procedure BeginWorkDXF;
begin
    fs:=DefaultFormatSettings;
    fs.DecimalSeparator:='.';

    slOutHeader         :=TStringList.Create;
    slOutCLASSES        :=TStringList.Create;
    slOutTABLES         :=TStringList.Create;
    slOutBLOCKS         :=TStringList.Create;
    slOutENTITIES       :=TStringList.Create;
    slOutOBJECTS        :=TStringList.Create;
    slOutTHUMBNAILIMAGE :=TStringList.Create;

    slBlockOldNames     :=TStringList.Create;
    slBlockNewNames     :=TStringList.Create;

    iHandleIndex        :=734;
    iACVersion          :=1;  //1-R12 2-R13
    bShowClass          :=False;
    bDXFWriteBlocks     :=True;
end;

procedure EndWorkDXF;
begin
     slOutHeader.free;
     slOutCLASSES.free;
     slOutTABLES.free;
     slOutBLOCKS.free;
     slOutENTITIES.free;
     slOutOBJECTS.free;
     slOutTHUMBNAILIMAGE.free;

     slBlockOldNames.free;
     slBlockNewNames.free;
end;

end.
