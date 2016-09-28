Unit ClassWatchAdd;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, ClassWatch, Generics.Collections;

Type
  TClassWatchAddFrm = Class (TForm)
    MainPanel: TPanel;
    CancelButton: TButton;
    OkButton: TButton;
    FilterPositionRadioGroup: TRadioGroup;
    FilterTypeRadioGroup: TRadioGroup;
    GroupBox1: TGroupBox;
    ClassListView: TListView;
    procedure OkButtonClick(Sender: TObject);
    procedure ClassListViewData(Sender: TObject; Item: TListItem);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ClassListViewCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
  Private
    FBeginning : Boolean;
    FUpperFilter : Boolean;
    FSelectedClass : TWatchableClass;
    FCancelled : Boolean;
    FWatchList : TList<TWatchableClass>;
  Public
    Property Beginning : Boolean Read FBeginning;
    Property UpperFilter : Boolean Read FUpperFilter;
    Property SelectedClass : TWatchableClass Read FSelectedClass;
    Property Cancelled : Boolean Read FCancelled;
  end;


Implementation

{$R *.DFM}

Uses
  Utils;

Procedure TClassWatchAddFrm.CancelButtonClick(Sender: TObject);
begin
Close;
end;

Procedure TClassWatchAddFrm.ClassListViewCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
Var
  L : TListView;
  wc : TWatchableClass;
begin
L := (Sender As TListVIew);
wc := FWatchList[Item.Index];
If wc.Registered Then
  L.Canvas.Font.Color := clGray
Else L.Canvas.Font.Color := clBlack;

DefaultDraw := True;
end;

Procedure TClassWatchAddFrm.ClassListViewData(Sender: TObject; Item: TListItem);
Var
  wc : TWatchableClass;
begin
With Item Do
  begin
  wc := FWatchList[Index];
  Caption := wc.Name;
  SubItems.Add(wc.GUid);
  end;
end;

Procedure TClassWatchAddFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
Var
  wc : TWatchableClass;
begin
For wc In FWatchList Do
  wc.Free;

FWatchList.Free;
end;

Procedure TClassWatchAddFrm.FormCreate(Sender: TObject);
Var
  err : Cardinal;
begin
FCancelled := True;
FSelectedClass := Nil;
FWatchList := TList<TWatchableClass>.Create;
err := TWatchableClass.Enumerate(FWatchList);
If err = ERROR_SUCCESS Then
  ClassListVIew.Items.Count := FWatchList.Count
Else  Utils.WinErrorMessage('Failed to enumerate watchable classes', err);
end;

Procedure TClassWatchAddFrm.OkButtonClick(Sender: TObject);
Var
  L : TListItem;
begin
L := ClassListView.Selected;
If Assigned(L) Then
  begin
  FSelectedClass := FWatchList[L.Index];
  If Not FSelectedClass.Registered Then
    begin
    FCancelled := False;
    FUpperFilter := (FilterTypeRadioGroup.ItemIndex = 1);
    FBeginning := (FilterPositionRadioGroup.ItemIndex = 0);
    FWatchList.Delete(L.Index);
    Close;
    end
  Else WarningMessage('The selected class must not be watched already');
  end
Else WarningMessage('No class selected');
end;



End.

