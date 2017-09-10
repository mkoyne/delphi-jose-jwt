{******************************************************************************}
{                                                                              }
{  Delphi JOSE Library                                                         }
{  Copyright (c) 2015-2017 Paolo Rossi                                         }
{  https://github.com/paolo-rossi/delphi-jose-jwt                              }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}

unit JWTDemo.Form.Consumer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  System.Rtti, System.Generics.Collections, Vcl.ImgList, System.Actions, Vcl.ActnList,
  JOSE.Core.JWT,
  JOSE.Core.JWS,
  JOSE.Core.JWE,
  JOSE.Core.JWK,
  JOSE.Core.JWA,
  JOSE.Types.JSON,
  JOSE.Types.Bytes,
  JOSE.Core.Builder,
  JOSE.Hashing.HMAC,
  JOSE.Consumer,
  JOSE.Encoding.Base64;

type
  TfrmConsumer = class(TForm)
    memoLog: TMemo;
    grpClaims: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtIssuer: TLabeledEdit;
    edtIssuedAtTime: TDateTimePicker;
    edtNotBeforeDate: TDateTimePicker;
    edtExpiresDate: TDateTimePicker;
    chkIssuer: TCheckBox;
    chkIssuedAt: TCheckBox;
    chkExpires: TCheckBox;
    chkNotBefore: TCheckBox;
    edtIssuedAtDate: TDateTimePicker;
    edtExpiresTime: TDateTimePicker;
    edtNotBeforeTime: TDateTimePicker;
    cbbAlgorithm: TComboBox;
    edtSubject: TLabeledEdit;
    chkSubject: TCheckBox;
    edtAudience: TLabeledEdit;
    chkAudience: TCheckBox;
    actListMain: TActionList;
    actBuildJWS: TAction;
    ImageList1: TImageList;
    actBuildJWTConsumer: TAction;
    btnCustomJWS: TButton;
    edtJWTId: TLabeledEdit;
    chkJWTId: TCheckBox;
    edtSecret: TLabeledEdit;
    edtHeader: TLabeledEdit;
    edtPayload: TLabeledEdit;
    edtSignature: TLabeledEdit;
    GroupBox1: TGroupBox;
    btnConsumerBuild: TButton;
    actBuildJWTCustomConsumer: TAction;
    btnBuildJWTCustomConsumer: TButton;
    edtConsumerSecret: TLabeledEdit;
    chkCosnumerSecret: TCheckBox;
    chkConsumerSkipVerificationKey: TCheckBox;
    chkConsumerSetDisableRequireSignature: TCheckBox;
    edtConsumerSubject: TLabeledEdit;
    chkConsumerSubject: TCheckBox;
    edtConsumerAudience: TLabeledEdit;
    chkConsumerAudience: TCheckBox;
    edtConsumerIssuer: TLabeledEdit;
    chkConsumerIssuer: TCheckBox;
    edtConsumerJWTId: TLabeledEdit;
    chkConsumerJWTId: TCheckBox;
    Label1: TLabel;
    edtConsumerEvaluationDate: TDateTimePicker;
    edtConsumerEvaluationTime: TDateTimePicker;
    chkConsumerIssuedAt: TCheckBox;
    chkConsumerExpires: TCheckBox;
    chkConsumerNotBefore: TCheckBox;
    edtSkewTime: TLabeledEdit;
    edtMaxFutureValidity: TLabeledEdit;
    procedure actBuildJWSExecute(Sender: TObject);
    procedure actBuildJWTConsumerExecute(Sender: TObject);
    procedure actBuildJWTConsumerUpdate(Sender: TObject);
    procedure actBuildJWTCustomConsumerExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    const JWT_SUB =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.' +
      'eyJzdWIiOiJQYW9sbyIsImlhdCI6NTEzMTgxNzcxOX0.' +
      'KhWaLAR2_VUaID1hjwDwy6p7FEYCIVkFhGAetvtfBQw';
  private
    FJWT: TJWT;
    FNow: TDateTime;
    FCompact: TJOSEBytes;
    FCompactHeader: string;
    FCompactPayload: string;
    FCompactSignature: string;

    function BuildJWT: TJOSEBytes;
    procedure SetNow;
    procedure SetCompact(const Value: TJOSEBytes);
    procedure ProcessConsumer(AConsumer: TJOSEConsumer);
  public
    property Compact: TJOSEBytes read FCompact write SetCompact;
  end;


implementation

uses
  System.DateUtils,
  JOSE.Core.Base,
  JOSE.Types.Arrays,
  JOSE.Consumer.Validators;

{$R *.dfm}

procedure TfrmConsumer.actBuildJWSExecute(Sender: TObject);
begin
  Compact := BuildJWT;

  edtHeader.Text := FCompactHeader;
  edtPayload.Text := FCompactPayload;
  edtSignature.Text := FCompactSignature;
end;

procedure TfrmConsumer.actBuildJWTConsumerExecute(Sender: TObject);
var
  LAud: TArray<string>;
begin
  SetLength(LAud, 2);
  LAud[0] := 'Paolo';
  LAud[1] := 'Luca';

  ProcessConsumer(TJOSEConsumerBuilder.NewConsumer
    .SetClaimsClass(TJWTClaims)
    // JWS-related validation
    .SetVerificationKey(edtConsumerSecret.Text)
    .SetSkipVerificationKeyValidation
    .SetDisableRequireSignature
    // string-based claims validation
    .SetExpectedSubject('paolo-rossi')
    .SetExpectedAudience(True, LAud)
    // Time-related claims validation
    .SetRequireIssuedAt
    .SetRequireExpirationTime
    .SetEvaluationTime(IncSecond(FNow, 26))
    .SetAllowedClockSkew(20, TJOSETimeUnit.Seconds)
    .SetMaxFutureValidity(20, TJOSETimeUnit.Minutes)
    // Build the consumer object
    .Build()
  );

end;

procedure TfrmConsumer.actBuildJWTConsumerUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FCompact <> '';
end;

procedure TfrmConsumer.actBuildJWTCustomConsumerExecute(Sender: TObject);
var
  LBuilder: IJOSEConsumerBuilder;
  LAud: TArray<string>;
begin
  SetLength(LAud, 1);
  LAud[0] := 'Paolo';

  LBuilder := TJOSEConsumerBuilder.NewConsumer;
  LBuilder.SetClaimsClass(TJWTClaims);

  // JWS-related validation
  if chkCosnumerSecret.Checked then
    LBuilder.SetVerificationKey(edtConsumerSecret.Text);

  if chkConsumerSkipVerificationKey.Checked then
    LBuilder.SetSkipVerificationKeyValidation;

  if chkConsumerSetDisableRequireSignature.Checked then
    LBuilder.SetDisableRequireSignature;

  // string-based claims validation
  if chkConsumerSubject.Checked then
    LBuilder.SetExpectedSubject(edtSubject.Text);

  if chkConsumerAudience.Checked then
    LBuilder.SetExpectedAudience(True, string(edtConsumerAudience.Text).Split([',']));

  // string-based claims validation
  if chkConsumerJWTId.Checked then
    LBuilder.SetRequireJwtId;

  // Time-related claims validation
  if chkConsumerIssuedAt.Checked then
    LBuilder.SetRequireIssuedAt;

  if chkConsumerExpires.Checked then
    LBuilder.SetRequireExpirationTime;

  if chkConsumerNotBefore.Checked then
    LBuilder.SetRequireNotBefore;

  LBuilder.SetEvaluationTime(edtConsumerEvaluationDate.Date + edtConsumerEvaluationTime.Time);

  LBuilder.SetAllowedClockSkew(20, TJOSETimeUnit.Seconds);
  LBuilder.SetMaxFutureValidity(20, TJOSETimeUnit.Minutes);

  // Build the consumer object
  ProcessConsumer(LBuilder.Build());
end;

procedure TfrmConsumer.FormCreate(Sender: TObject);
begin
  SetNow;
end;

function TfrmConsumer.BuildJWT: TJOSEBytes;
var
  LJWT: TJWT;
  LAlg: TJOSEAlgorithmId;
begin
  LJWT := TJWT.Create;
  try
    SetNow;

    if chkIssuer.Checked then
      LJWT.Claims.Issuer := edtIssuer.Text;

    if chkSubject.Checked then
      LJWT.Claims.Subject := edtSubject.Text;

    if chkAudience.Checked then
      LJWT.Claims.Audience := edtAudience.Text;

    if chkJWTId.Checked then
      LJWT.Claims.JWTId := edtJWTId.Text;

    if chkIssuedAt.Checked then
      LJWT.Claims.IssuedAt := edtIssuedAtDate.Date + edtIssuedAtTime.Time;

    if chkExpires.Checked then
      LJWT.Claims.Expiration := edtExpiresDate.Date + edtExpiresTime.Time;

    if chkNotBefore.Checked then
      LJWT.Claims.NotBefore := edtNotBeforeDate.Date + edtNotBeforeTime.Time;

    case cbbAlgorithm.ItemIndex of
      0: LAlg := TJOSEAlgorithmId.HS256;
      1: LAlg := TJOSEAlgorithmId.HS384;
      2: LAlg := TJOSEAlgorithmId.HS512;
      else LAlg := TJOSEAlgorithmId.HS256;
    end;

    Result := TJOSE.SerializeCompact(edtSecret.Text,  LAlg, LJWT);
  finally
    LJWT.Free;
  end;
end;

procedure TfrmConsumer.FormDestroy(Sender: TObject);
begin
  FJWT.Free;
end;

procedure TfrmConsumer.ProcessConsumer(AConsumer: TJOSEConsumer);
begin
  if Assigned(AConsumer) then
  try
    AConsumer.Process(Compact);
  except
    on E: Exception do
      memoLog.Lines.Add(E.Message);
  end;
  AConsumer.Free;
end;

procedure TfrmConsumer.SetCompact(const Value: TJOSEBytes);
var
  LSplit: TArray<string>;
begin
  FCompact := Value;
  LSplit := FCompact.AsString.Split(['.']);

  if Length(LSplit) < 3 then
    raise Exception.Create('Malformed compact representation');

  FCompactHeader := LSplit[0];
  FCompactPayload := LSplit[1];
  FCompactSignature := LSplit[2];
end;

procedure TfrmConsumer.SetNow;
begin
  FNow := Now;

  edtIssuedAtDate.Date := FNow;
  edtIssuedAtTime.Time := FNow;

  edtExpiresDate.Date := IncSecond(FNow, 5);
  edtExpiresTime.Time := IncSecond(FNow, 5);

  edtNotBeforeDate.Date := IncMinute(FNow, -10);
  edtNotBeforeTime.Time := IncMinute(FNow, -10);
end;


end.
