(******************************************************************************
  * All Rights Reserved, Copyright(C)
  *                    Jupiter Shop Channel Co.,Ltd & Fujitsu Ltd (2003-2005)
  *****************************************************************************)
(******************************************************************************
  *
  * $Id$
  *
  * 概要
  *   IVR業務を行う上での各種機能処理の戻り値によって次に行う処理を管理・
  *   制御をするクラス(IVRコントロール)
  *
  *
  *
  * 改訂履歴
  *  DATE            NAME            V/L           explanation
  *  2004.09.22      Fj)山田 英介    V01L01.0001   新規作成
  *  2006.08.24      S,yokoyama      (IVR48 project)
  *                                                48 Channelized
  *    　　　　　　　　　　　　　　　　　　　　　　Goinitialize, GoReady　追加。　
  *                                                APPlogger.pas  参照
  *                                                PARENTFUNC.pas 参照
  *
  * 2006.09.26      S.yokoyama      (IVR48 project)
  *                  Goinitialize)  TApploggerのcreateは実施しない。
  * 2006.10.02      S.taruya   　   (IVR48 project)
  *                  引数名、変数名の変更（規約に合わせる）
  * 2006.10.10      S.taruya   　   (IVR48 project)
  *                  Log出力位置の変更
  * 2006.10.16      S.taruya   　   (IVR48 project)
  *                  waitForCallの失敗を、戻り値で返す処理を追加
  * 2006.12.22      S.yokoyama      (IVR48 pro4ject)
  *                  EventRinging をcatchしたことの判断を追加
  *  2012.12.31     SCSK)秋山 尚之   V01L01.0001   次期要件
  *  2014.03.19     IT)神谷 るり薫   V01L01.0001   送料定額PJ
  *  2015.01.09     IT)小滝 卓央     V01L01.0001   送料定額PJ仕様変更
  *  2018.06.29     JSC 小滝 卓央    V01L01.0002   17SIS00E 新音声対応
  *  2022.01.27     SCSK)岡野　晃    V02L01.0001   ショップチャンネルカード割引対応(21SIS014)
  *  2022.06.16     SCSK)加藤        V03L01.0001   クレジットカード非保持化対応(20SIS006)
  *  2023.03.14     JSC)水野 洋平    V04L01.0001   携帯番号保持(22SIS00A)
  
  *
  *****************************************************************************)
unit UCCOIVD20020;

interface

uses
  SysUtils, Classes, Forms, Contnrs, Dialogs, StdCtrls, StrUtils,
  CCCustomer_i, CCTelephony_i,CCTelephony_c,CCOrder_i, CCUtility_i,
  UCMServerAccess, CCOrder_c,
  UCCOIVD20030, UCCOIVD20040, UCCOIVD20050, UCCOIVD20060, UCCOIVD20070,
  UCCOIVD20080, UCCOIVD20090, UCCOIVD20100, UCCOIVD20110, UCCOIVD20120, UCCOIVD20130,
  UCCOIVD20140, UCCOIVD20150, UCCOIVD20160, UCCOIVD20170, UCCOIVD20190, UCCOIVD20200,
  UCCOIVD20210, UCCOIVD20220, UCCOIVD20230, UCCOIVD20240, UCCOIVD20250, UCCOIVD20270,
  UCCOIVD20280, UCCOIVD20290, UCCOIVD20300, UCCOIVD20400, UCCOIVD20450, UCCOIVD20460,
  UCCOIVD20470, UCCOIVD20480, UCCOIVD20500, UCCOIVD20520;

const
  DEFAULT = 0;                        // デフォルト値
  BLACK_CUSTOMER = 10;                // B顧客情報取得(1件でも存在)
  USUAL_CUSTOMER = 2;                 // 顧客の確定はしていないがB顧客でもない情報取得
  SPECIFY_CUSTOMER = 1;               // 確定顧客
  NEW_CUSTOMER = 2;                   // 新規顧客
  BUYING_ITEM_END = 2;                // 商品購入終了
  DESTINATION_MODIFICATION_OFF = 0;   // 届先変更なし
  DESTINATION_MODIFICATION_ON = 1;    // 届先変更あり

  SELECT_PROGRAM_GUIDE           = 1; // 番組ガイド申込案内
  SELECT_REFUNDMENT_GUIDANCE     = 2; // 返金案内
  SELECT_IEO_SERVICE_CHANGE_MENU = 3; // IEOサービス変更メニュー
  SELECT_POINT_GUIDANCE          = 4; // ポイント案内
//  SELECT_STOCK_GUIDE           = 5; // 在庫状況案内
//  SELECT_RETURN                = 6; // 返品
  SELECT_ORDER                   = 8; // IVR受注
  SELECT_ENQUIRY_TRANSFER        = 9; // OP問合せ

type
  IVRControlStatusInfo = record
    // 0:Default 1:B顧客情報取得(1件でも存在) 2:顧客の確定はしていないがB顧客でもない情報取得
    CustomerInformationStatus: ShortInt;
    // 0:Default 1:確定顧客 2:新規顧客
    SpecifyCustomerStatus: ShortInt;
    // 0:Default 1:確定顧客 2:新規顧客
    SpecifyExpressCustomerStatus: ShortInt;
    // 0:Default 1:受注選択 2:問合せ選択 3:予約選択
    IvrMenuStatus: ShortInt;
    // 0:Default 1:キャンセル選択  2:商品購入終了
    ItemStatus: ShortInt;
    // 0: Default 1: 届先変更なし 2:届先変更あり
    DestinationConfirmationStatus: ShortInt;
    // 0: Default 1:配送状況案内選択 2:番組ガイド申込案内選択 3:返金案内選択 4:ポイント案内選択 5:IEOサービス変更メニュー選択 8:IVR受注選択 9:OP問合せ選択
// ↑は在庫状況確認削除   // 0: Default 1:配送状況案内選択 2:番組ガイド申込案内選択 3:返金案内選択 4:ポイント案内選択 5:IEOサービス変更メニュー選択 6:在庫状況確認 8:IVR受注選択 9:OP問合せ選択
    EnqMenuStatus: ShortInt;
    // 0:Default 1:当日追加受注あり 2:当日追加受注なし
    AddOrderStatus: ShortInt;
end;

type
  TIVRControl = class(TIVRBase)
    private
      // 回線切断処理
      procedure CutConnection;
      // OP転送(受注・問合せ含む)
      procedure SetOPFowardTransferInfo(TransMsgCode: String);
      // オンライン運用日取得処理
      procedure ExecGetOperationDateInfo;
      // CC端末稼動情報追加・更新処理
      procedure ExecSetAgentControlForTel;
      // CC端末稼動情報追加・更新処理
      procedure ExecSetAgentControlForAffair(ABusinessStartCode: ShortInt);
      // CC端末稼動情報追加・更新処理
      procedure ExecSetAgentControlForAffairCutConnect;
      // CC端末稼動情報追加・更新処理
      procedure ExecSetAgentControlForTelOPFoward;
      // 顧客ロック解除処理
      procedure ExecunlockCustomer;
      // 配送指定情報クリア処理
      procedure ExecSetDeliveryOptionInfo;

    public
      FIVRLog: TIVRLog;                                     // ログ
      FCustomerInformation: TCustomerInformation;           // 顧客情報取得       (CCOIVD20030)
      FSpecifiedCustomer: TSpecifiedCustomer;               // 顧客特定           (CCOIVD20040)
      FSelectItem: TSelectItem;                             // 商品選択           (CCOIVD20050)
      FAmountCalculation: TAmountCalculation;               // 金額計算           (CCOIVD20060)
      FPaymentMethod: TPaymentMethod;                       // 支払い方法         (CCOIVD20070)
      FNewCustomer: TNewCustomer;                           // 新規顧客           (CCOIVD20080)
      FEnquete: TEnquete;                                   // アンケート         (CCOIVD20090)
      FDefaultDesignationConfirmation:
                        TDefaultDesignationConfirmation;    // 配送希望指定確認   (CCOIVD20500)
      FDestinationConfirmation: TDestinationConfirmation;   // 届け先確認         (CCOIVD20100)
      FDestinationJudgement: TDestinationJudgement;         // 届け先判定         (CCOIVD20110)
      FDeliveryDesignation: TDeliveryDesignation;           // 配送指定           (CCOIVD20120)
      FOrderConfirmation: TOrderConfirmation;               // 受注確認           (CCOIVD20130)
      FEnquiryMenu: TEnquiryMenu;                           // 問合せメニュー     (CCOIVD20140)
      FCancel: TCancel;                                     // キャンセル         (CCOIVD20150)
      FDeliveryStatus: TDeliveryStatus;                     // 配送状況案内       (CCOIVD20160)
      FPoint: TPoint;                                       // ポイント案内       (CCOIVD20170)
      FCopeCustomer: TCopeCustomer;                         // 顧客紐付           (CCOIVD20200)
      FDisableEnquiry: TDisableEnquiry;                     // 問合せ不可         (CCOIVD20270)
      FAddOrder: TAddOrder;                                 // 追加受注           (CCOIVD20280)
      FSelectRefundmentGuidance: TSelectRefundmentGuidance; // 返金案内           (CCOIVD20290)
      FProgramGuideOrder: TProgramGuideOrder;               // 番組ガイド申込案内 (CCOIVD20450)
      FCellularNumberRegistration:                          // 携帯番号登録       (CCOIVD20520)
                               TCellularNumberRegistration;
      // IVR Express Order
      FIEOController: TIEOController;                     // IEOコントローラー  (CCOIVD20300)
      FIEOServiceChangeMenu: TIEOServiceChangeMenu;       // IEOサービス変更    (CCOIVD20400)
      FStockGuide: TStockGuide;                           // 在庫状況案内       (CCOIVD20460)
      FDiscountTicket: TDiscountTicket;                   // IEO 割引券         (CCOIVD20470)
      FStockStatus: TStockStatus;                         // 在庫状況案内       (CCOIVD20480)

      // 各種パート構造体
      FIVRControlStatusInfo: IVRControlStatusInfo;
      // IVRコントロール業務処理
      procedure IVRControlBusinessMain;
      // コンストラクタ
      constructor Create;
      // デストラクタ
      destructor Destroy; override;
      procedure SetCommonObject(AIVRData: TIVRData; AIVRTalk: TIVRTalk;
        AIVRLog: TIVRLog; AServerAccess: TServerAccess); override;
    end;

implementation

uses
  UCMGlobalConst, TelDialog;

(*******************************************************************************
  * 1. 関数・処理名称
  *      constructor Create;
  *
  * 2. パラメータ説明
  *    なし
  *
  * 3. 概要
  *    初期化処理
  *
  * 4. 機能説明
  *    自クラスのサービス名を設定します
  *
  * 5. 戻り値
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
constructor TIVRControl.Create;
begin
  inherited Create;
  // 業務サービス各種クラス生成
  FCustomerInformation            := TCustomerInformation.Create;
  FSpecifiedCustomer              := TSpecifiedCustomer.Create;
  FSelectItem                     := TSelectItem.Create;
  FAmountCalculation              := TAmountCalculation.Create;
  FPaymentMethod                  := TPaymentMethod.Create;
  FNewCustomer                    := TNewCustomer.Create;
  FEnquete                        := TEnquete.Create;
  FDestinationConfirmation        := TDestinationConfirmation.Create;
  FDestinationJudgement           := TDestinationJudgement.Create;
  FDeliveryDesignation            := TDeliveryDesignation.Create;
  FOrderConfirmation              := TOrderConfirmation.Create;
  FEnquiryMenu                    := TEnquiryMenu.Create;
  FCancel                         := TCancel.Create;
  FDeliveryStatus                 := TDeliveryStatus.Create;
  FProgramGuideOrder              := TProgramGuideOrder.Create;
  FSelectRefundmentGuidance       := TSelectRefundmentGuidance.Create;
  FPoint                          := TPoint.Create;
  FCopeCustomer                   := TCopeCustomer.Create;
  FDisableEnquiry                 := TDisableEnquiry.Create;
  FAddOrder                       := TAddOrder.Create;
  FStockGuide                     := TStockGuide.Create;
  FDiscountTicket                 := TDiscountTicket.Create;
  FStockStatus                    := TStockStatus.Create;
  FIEOController                  := TIEOController.Create;
  FIEOServiceChangeMenu           := TIEOServiceChangeMenu.Create;
  FDefaultDesignationConfirmation := TDefaultDesignationConfirmation.Create;
  FCellularNumberRegistration     := TCellularNumberRegistration.Create;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *      destructor Destroy;
  *
  * 2. パラメータ説明
  *    なし
  *
  * 3. 概要
  *    終了処理
  *
  * 4. 機能説明
  *    メモリ解放等の終了処理を行う
  *
  * 5. 戻り値
  *    なし
  *
  * 6. 備考
  *    なし
  *
*******************************************************************************)
destructor TIVRControl.Destroy;
const
  FUNCTION_NAME = 'Destroy';
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);

  FCustomerInformation.Free;
  FSpecifiedCustomer.Free;
  FSelectItem.Free;
  FAmountCalculation.Free;
  FPaymentMethod.Free;
  FNewCustomer.Free;
  FEnquete.Free;
  FDestinationConfirmation.Free;
  FDestinationJudgement.Free;
  FDeliveryDesignation.Free;
  FOrderConfirmation.Free;
  FEnquiryMenu.Free;
  FCancel.Free;
  FDeliveryStatus.Free;
  FProgramGuideOrder.Free;
  FSelectRefundmentGuidance.Free;
  FPoint.Free;
  FCopeCustomer.Free;
  FDisableEnquiry.Free;
  FAddOrder.Free;
  FStockGuide.Free;
  FDiscountTicket.Free;
  FStockStatus.Free;
  FIEOController.Free;
  FIEOServiceChangeMenu.Free;
  FDefaultDesignationConfirmation.Free;
  FCellularNumberRegistration.Free;

  // メソッド終了ログ
  Self.IVRLog.MethodEnd(FUNCTION_NAME);

  inherited Destroy;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure SetCommonObject(AIVRData: TIVRData; AIVRTalk: TIVRTalk; AIVRLog: TIVRLog; AServerAccess: TServerAccess);
  *
  * 2. パラメータ説明
  *    i TIVRData        AIVRData       共通データクラス
  *    i TIVRTalk        AIVRTalk       音声再生クラス
  *    i TIVRLog         AIVRLog        IVRログ出力クラス
  *    i TServerAccess   AServerAccess  サーバーアクセスクラス
  *
  * 3. 概要
  *    共通のオブジェクト設定
  *
  * 4. 機能説明
  *    共通のオブジェクトを業務サービス各種クラスにセットする
  *
  * 5. 戻り値
  *    なし
  *
  * 6. 備考
  *    なし
  *
*******************************************************************************)
procedure TIVRControl.SetCommonObject(AIVRData: TIVRData; AIVRTalk: TIVRTalk;
  AIVRLog: TIVRLog; AServerAccess: TServerAccess);
const
  FUNCTION_NAME = 'SetCommonObject';
begin
  // 継承元メソッドを呼び出す
  inherited SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);

  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);

  // 顧客情報取得
  FCustomerInformation.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 顧客特定
  FSpecifiedCustomer.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 商品選択
  FSelectItem.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 金額計算
  FAmountCalculation.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 支払い方法
  FPaymentMethod.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 新規顧客
  FNewCustomer.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // アンケート
  FEnquete.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 届け先確認
  FDestinationConfirmation.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 届け先判定
  FDestinationJudgement.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 配送指定
  FDeliveryDesignation.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 受注確認
  FOrderConfirmation.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 問合せメニュー
  FEnquiryMenu.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // キャンセル
  FCancel.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 配送状況案内
  FDeliveryStatus.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 番組ガイド申込案内
  FProgramGuideOrder.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 返品・返金案内選択
  FSelectRefundmentGuidance.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // ポイント案内
  FPoint.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 顧客紐付
  FCopeCustomer.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 問合せ不可
  FDisableEnquiry.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 追加受注
  FAddOrder.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 在庫状況案内
  FStockGuide.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // IEO 割引券
  FDiscountTicket.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 在庫状況案内
  FStockStatus.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // IVR Express Order メニュー
  FIEOController.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // IVR Express Order サービス変更
  FIEOServiceChangeMenu.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 配送希望指定確認
  FDefaultDesignationConfirmation.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);
  // 携帯番号登録
  FCellularNumberRegistration.SetCommonObject(AIVRData, AIVRTalk, AIVRLog, AServerAccess);

  // メソッド終了ログ
  Self.IVRLog.MethodEnd(FUNCTION_NAME);
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure IVRControlBusinessMain;
  *
  * 2. パラメータ説明
  *    なし
  *
  * 3. 概要
  *   IVR業務を行う上での各種機能処理の戻り値によって次に行う処理を管理・
  *   制御をするクラス(IVRコントロール)
  *
  * 4. 機能説明
  *   IVR業務を行う上での各種機能処理の戻り値によって次に行う処理を管理・
  *   制御をする
  *
  * 5. 戻り値
  *    なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.IVRControlBusinessMain;
var
  mLoopEnd: Boolean;
  mLoopEnquiry : Boolean;
  stat: Integer;
//2014/06/18 kamiya add start 送料定額ＰＪ
  mNotCarriageFeeCampaignFlg: Boolean;
//2014/06/18 kamiya add end 送料定額ＰＪ
const
  FUNCTION_NAME = 'IVRControlBusinessMain';
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  // 初期化処理
  mLoopEnd := False;
  mLoopEnquiry := False;
  Self.IVRData.PlayedZeroRepeat := True;
//2014/06/18 kamiya add start 送料定額ＰＪ
  mNotCarriageFeeCampaignFlg := False;
//2014/06/18 kamiya add end 送料定額ＰＪ
  try
    try
      // CC端末稼動情報追加・更新処理
      ExecSetAgentControlForTel;

      /////////////////////////////////////
      // 起動業務判定
      /////////////////////////////////////
      // 通常受注
      if Self.IVRData.BusinessStartCode = bsOrder then
      begin
        Self.FIVRControlStatusInfo.IvrMenuStatus := ORDER;
      end else
      // 問合せ
      if Self.IVRData.BusinessStartCode = bsENQ then
      begin
        Self.FIVRControlStatusInfo.IvrMenuStatus := ENQUIRY;
      end else
      // 商品先引当
      if Self.IVRData.BusinessStartCode = bsReserve then
      begin
        Self.FIVRControlStatusInfo.IvrMenuStatus := RESERVE;
      end else
      // 当日キャンセル
      if Self.IVRData.BusinessStartCode = bsCancel then
      begin
        Self.FIVRControlStatusInfo.IvrMenuStatus := CANCEL;
      end else
      // 配送状況案内
      if Self.IVRData.BusinessStartCode = bsDeliveryStatus then
      begin
        Self.FIVRControlStatusInfo.IvrMenuStatus := DELIVERY_STATUS;
      end else
      // 在庫状況案内
      if Self.IVRData.BusinessStartCode = bsStockStatus then
      begin
        Self.FIVRControlStatusInfo.IvrMenuStatus := STOCK_STATUS;
      end;

      // IVR Express Order 判定
      if Self.IVRData.BusinessStartCode = bsExpress then
      begin
        Self.IVRLog.ClassStrat('Express');
        Self.FIVRControlStatusInfo.IvrMenuStatus := ORDER;
        stat := Self.FIEOController.IEOControllerMain;
        Self.IVRLog.ClassEnd('Express');

        if stat = 1 then
        begin
          Self.IVRData.BusinessStartCode := bsOrder;
        end else
        begin
          mLoopEnd := True;
        end;
      end else
      // 発信者番号判定(発信者番号通知あり(発番あり状態)の場合、顧客情報取得)
      if Self.IVRData.TelNumber <> '' then
      begin
        // クラス開始ログ
        Self.IVRLog.ClassStrat('顧客情報取得');
        // 顧客情報取得クラス実行
        Self.FIVRControlStatusInfo.CustomerInformationStatus := Self.FCustomerInformation.CustomerInformationMain;
        Self.IVRLog.AddLog('CustomerInformationStatus = ' + IntToStr(Self.FIVRControlStatusInfo.CustomerInformationStatus));
        // クラス終了ログ
        Self.IVRLog.ClassEnd('顧客情報取得');
      end;

      // CC端末稼動情報追加・更新処理
      ExecSetAgentControlForAffair(Self.FIVRControlStatusInfo.IvrMenuStatus);

      // メインループ
      while not mLoopEnd do
      begin
        // 受注 or 予約
        if (Self.FIVRControlStatusInfo.IvrMenuStatus = ORDER) or
           (Self.FIVRControlStatusInfo.IvrMenuStatus = RESERVE) then
        begin
          // 顧客特定済みであるか
          if Self.IVRData.CustomerSpecified = FLAG_OFF then
          begin
            // 発信者番号なしの場合
            if Self.IVRData.TelNumber = '' then
            begin
              // クラス開始ログ
              Self.IVRLog.ClassStrat('顧客特定');
              // 顧客特定クラス実行
              Self.FIVRControlStatusInfo.SpecifyCustomerStatus := Self.FSpecifiedCustomer.CustomerMain;
              Self.IVRLog.AddLog('SpecifyCustomerStatus = ' + IntToStr(Self.FIVRControlStatusInfo.SpecifyCustomerStatus));
              // クラス終了ログ
              Self.IVRLog.ClassEnd('顧客特定');
            end;
          end;

          // クラス開始ログ
          Self.IVRLog.ClassStrat('商品選択');

          // 受注か予約選択判定
          if Self.FIVRControlStatusInfo.IvrMenuStatus = ORDER then
          begin
            // 商品選択クラス実行
            Self.FIVRControlStatusInfo.ItemStatus := Self.FSelectItem.SelectItemMain;
          end else
          begin
            // 商品先引当実行
            Self.FIVRControlStatusInfo.ItemStatus := Self.FSelectItem.SelectItemReserveMain;
            // タッチでショップで注文を続ける場合は受注系として扱う
            Self.FIVRControlStatusInfo.IvrMenuStatus := ORDER;
            Self.IVRData.BusinessStartCode := bsOrder;
          end;

          Self.IVRLog.AddLog('ItemStatus = ' + IntToStr(Self.FIVRControlStatusInfo.ItemStatus));
          // クラス終了ログ
          Self.IVRLog.ClassEnd('商品選択');

          // 顧客特定(確定顧客・新規顧客以外の場合)
          if Self.IVRData.NotFixedCustomer = FLAG_ON then
          begin
            // クラス開始ログ
            Self.IVRLog.ClassStrat('顧客特定');
            // 顧客特定クラス実行
            Self.FIVRControlStatusInfo.SpecifyCustomerStatus := Self.FSpecifiedCustomer.CustomerMain;
            Self.IVRLog.AddLog('SpecifyCustomerStatus = ' + IntToStr(Self.FIVRControlStatusInfo.SpecifyCustomerStatus));
            // クラス終了ログ
            Self.IVRLog.ClassEnd('顧客特定');
          end;
          // クラス開始ログ
          Self.IVRLog.ClassStrat('顧客紐付');
          // 顧客紐付クラス実行
          Self.FCopeCustomer.OrderInfoList := Self.FSelectItem.OrderInfoList;
          Self.FCopeCustomer.CopeCustomerMain;
          // クラス終了ログ
          Self.IVRLog.ClassEnd('顧客紐付');

          // クラス開始ログ
          Self.IVRLog.ClassStrat('追加受注');
          // 追加受注クラス実行
          Self.FAddOrder.OrderInfoList := Self.FCopeCustomer.OrderInfoList;
          Self.FIVRControlStatusInfo.AddOrderStatus := Self.FAddOrder.AddOrderMain;
          Self.IVRLog.AddLog('AddOrderStatus = ' + IntToStr(Self.FIVRControlStatusInfo.AddOrderStatus));
          // クラス終了ログ
          Self.IVRLog.ClassEnd('追加受注');

          // 当日追加受注がされた場合は以下の処理を行わず受注確認を行う
          if Self.FIVRControlStatusInfo.AddOrderStatus = 0 then
          begin
//2014/02/28 kamiya add start 送料定額サービスPJ
            //金額計算
            // クラス開始ログ
            Self.IVRLog.ClassStrat('金額計算');
            // 金額計算クラス実行
            Self.FAmountCalculation.CalculateAmountMain;
            // クラス終了ログ
            Self.IVRLog.ClassEnd('金額計算');
            //配送希望指定確認
            // クラス開始ログ
            Self.IVRLog.ClassStrat('配送希望指定確認');
            // 配送希望指定確認クラス実行
            Self.FDefaultDesignationConfirmation.DefaultDesignationConfirmationMain;
            // クラス終了ログ
            Self.IVRLog.ClassEnd('配送希望指定確認');
            //配送希望指定が選択された場合支払方法指定
            if Self.IVRData.DefaultDesignationFlag then
            begin
              // クラス開始ログ
              Self.IVRLog.ClassStrat('届先判定');
              // 届け先判定クラス実行
              Self.FDestinationJudgement.DestinationJudgementMain;
              // クラス終了ログ
              Self.IVRLog.ClassEnd('届先判定');

              //「支払方法指定」
              // クラス開始ログ
              Self.IVRLog.ClassStrat('支払い方法');
              // 支払方法クラス実行
              Self.FPaymentMethod.PaymentMethodMain;
              // クラス終了ログ
              Self.IVRLog.ClassEnd('支払い方法');

              // 配送希望曜日登録なしの場合
              if not Self.IVRData.HasDlvrHopeWeekday then
              begin
                // 顧客配送情報クリア
                Self.ExecSetDeliveryOptionInfo;
                //「配送指定」
                // クラス開始ログ
                Self.IVRLog.ClassStrat('配送指定');
                // 配送指定クラス実行
                Self.FDeliveryDesignation.DeliveryOptionMain;
                // クラス終了ログ
                Self.IVRLog.ClassEnd('配送指定');
              end;

            end
            else
            begin
              mNotCarriageFeeCampaignFlg := True;
            end;
            if mNotCarriageFeeCampaignFlg then
            begin
              //新規顧客かどうかで分岐
              // 届先確認(新規顧客は行わない)
              if Self.FIVRControlStatusInfo.SpecifyCustomerStatus = NEW_CUSTOMER then
              begin
                // クラス開始ログ
                Self.IVRLog.ClassStrat('新規顧客');
                // 新規顧客クラス実行
                Self.FNewCustomer.NewCustomerMain;
                // クラス終了ログ
                Self.IVRLog.ClassEnd('新規顧客');
              end
              else
              begin
                // クラス開始ログ
                Self.IVRLog.ClassStrat('届先確認');
                // 届け先確認クラス実行
                Self.FIVRControlStatusInfo.DestinationConfirmationStatus := Self.FDestinationConfirmation.DestinationMain;
                Self.IVRLog.AddLog('DestinationConfirmationStatus = ' + IntToStr(Self.FIVRControlStatusInfo.DestinationConfirmationStatus));
                // クラス終了ログ
                Self.IVRLog.ClassEnd('届先確認');
              end;
              // クラス開始ログ
              Self.IVRLog.ClassStrat('届先判定');
              // 届け先判定クラス実行
              Self.FDestinationJudgement.DestinationJudgementMain;
              // クラス終了ログ
              Self.IVRLog.ClassEnd('届先判定');

              //「支払方法指定」
              // クラス開始ログ
              Self.IVRLog.ClassStrat('支払い方法');
              // 支払方法クラス実行
              Self.FPaymentMethod.PaymentMethodMain;
              // クラス終了ログ
              Self.IVRLog.ClassEnd('支払い方法');

              // クラス開始ログ
              Self.IVRLog.ClassStrat('配送指定');
              // 配送指定クラス実行
              Self.FDeliveryDesignation.DeliveryOptionMain;
              // クラス終了ログ
              Self.IVRLog.ClassEnd('配送指定');
            end;
          end;
//2014/02/28 kamiya add end 送料定額サービスPJ

          // クラス開始ログ
          Self.IVRLog.ClassStrat('受注確認');
          // 受注確認クラスに携帯番号登録クラスをセット
          Self.FOrderConfirmation.CellularNumberRegistration := FCellularNumberRegistration;
          // 受注確認クラス実行
          Self.FOrderConfirmation.OrderConfirmationMain;
          // クラス終了ログ
          Self.IVRLog.ClassEnd('受注確認');

          //----- 2006.11.17 現行(Rev705) start
          // 通話履歴に受注登録を記入
          if IVRData.CallHistInfo <> nil then
            IVRData.CallHistInfo.order_accept_flag := ODR_ACCPT_BEING;
          //----- 2006.11.17 現行(Rev705) end

          // アンケート(顧客状態(候補)新規顧客の場合に行う)
          if Self.FIVRControlStatusInfo.SpecifyCustomerStatus = NEW_CUSTOMER then
          begin
            // クラス開始ログ
            Self.IVRLog.ClassStrat('アンケート');
            // アンケートクラス実行
            Self.FEnquete.EnqueteMain;
            // クラス終了ログ
            Self.IVRLog.ClassEnd('アンケート');
          end;
          mLoopEnd := True;
        end else

        // 当日キャンセル
        if (Self.FIVRControlStatusInfo.IvrMenuStatus = CANCEL) then
        begin
          // クラス開始ログ
          Self.IVRLog.ClassStrat('キャンセル');
          // キャンセルクラス実行
          Self.FCancel.SpecifiedCustomer := Self.FSpecifiedCustomer;
          Self.FCancel.CancelMain;
          // クラス終了ログ
          Self.IVRLog.ClassEnd('キャンセル');
          mLoopEnd := True;
          Continue;
        end else

        // 配送状況案内
        if (Self.FIVRControlStatusInfo.IvrMenuStatus = DELIVERY_STATUS) then
        begin
          // クラス開始ログ
          Self.IVRLog.ClassStrat('配送状況案内');
          // 配送状況案内クラス実行
          Self.FDeliveryStatus.SpecifiedCustomer := Self.FSpecifiedCustomer;
          Self.FDeliveryStatus.DeliveryStatusMain;
          // クラス終了ログ
          Self.IVRLog.ClassEnd('配送状況案内');
          mLoopEnd := True;
          Continue;
        end else

        // 在庫状況案内
        if (Self.FIVRControlStatusInfo.IvrMenuStatus = STOCK_STATUS) then
        begin
          // クラス開始ログ
          Self.IVRLog.ClassStrat('在庫状況案内');
          // 在庫状況案内クラス実行
          Self.FStockStatus.StockStatusMain;
          // クラス終了ログ
          Self.IVRLog.ClassEnd('在庫状況案内');

          if Self.FStockStatus.OrderedInStockFlag then
          // 在庫照会内で注文があった場合
          begin
            Self.IVRLog.AddLog('在庫照会内にて注文商品有り');
            // 受注商品を移動
            Self.IVRData.StockItemData := Self.FStockStatus.OrderedItemInStockList;
            // 受注に進む
            Self.FIVRControlStatusInfo.IvrMenuStatus := ORDER;
// 2012/12/31 takenari add start 次期要件
            Self.IVRData.BusinessStartCode := bsOrder;
// 2012/12/31 takenari add end 次期要件
          end else
          begin
            // 在庫状況案内内で受注がなかった場合にはメインループ終了
            mLoopEnd := True;
          end;
          Continue;
        end else

        // 問合せ
        begin
          while not mLoopEnquiry do
          begin
            // クラス開始ログ
            Self.IVRLog.ClassStrat('問合せメニュー');
            // 問合せメニュークラス実行
            Self.FIVRControlStatusInfo.EnqMenuStatus := Self.FEnquiryMenu.EnquiryMenuMain;
            // クラス終了ログ
            Self.IVRLog.ClassEnd('問合せメニュー');

            // 選択されたサービスが顧客の特定が必要判定
            // 顧客特定が必要なサービス:
            //   番組ガイド申込案内、返金案内、ポイント案内
            if Self.FIVRControlStatusInfo.EnqMenuStatus in
               [SELECT_PROGRAM_GUIDE,
                SELECT_REFUNDMENT_GUIDANCE,
                SELECT_POINT_GUIDANCE] then
            begin
              // 顧客特定済み判定
              // 顧客特定ステータス <> "1"(確定顧客以外)の場合、顧客特定実行
              if Self.FIVRControlStatusInfo.SpecifyCustomerStatus <> SPECIFY_CUSTOMER then
              begin
                // クラス開始ログ
                Self.IVRLog.ClassStrat('顧客特定');
                // 顧客特定クラス実行
                Self.FSpecifiedCustomer.TransNoSpecify :=
                  (Self.FIVRControlStatusInfo.EnqMenuStatus = SELECT_REFUNDMENT_GUIDANCE);
//  IEOサービス変更で発信者電話番号を確認しなくなったためコメント化
//                or (Self.FIVRControlStatusInfo.EnqMenuStatus = SELECT_IEO_SERVICE_CHANGE_MENU);
                Self.FIVRControlStatusInfo.SpecifyCustomerStatus := Self.FSpecifiedCustomer.CustomerMain;
                Self.IVRLog.AddLog('SpecifyCustomerStatus = ' + IntToStr(Self.FIVRControlStatusInfo.SpecifyCustomerStatus));
                // クラス終了ログ
                Self.IVRLog.ClassEnd('顧客特定');

                // 顧客状態が新規顧客の場合、問合せ不可実行
                if Self.FIVRControlStatusInfo.SpecifyCustomerStatus = NEW_CUSTOMER then
                begin
                  // CSOP転送
                  raise EOPForward.Create(ERR_CODE202700030001);
                end;
                if Self.IVRData.CustomerSpecified = FLAG_OFF then
                begin
                  Self.FIVRControlStatusInfo.EnqMenuStatus := 0;
                end;
              end else
              begin
                Self.IVRLog.AddLog('顧客特定済み(SpecifyCustomerStatus = ' + IntToStr(Self.FIVRControlStatusInfo.SpecifyCustomerStatus) + ')');
              end;
            end
            // IEOサービス変更メニュー
            else if Self.FIVRControlStatusInfo.EnqMenuStatus = SELECT_IEO_SERVICE_CHANGE_MENU then
            begin
              // Express顧客特定済み判定
              // Express顧客特定ステータス <> "1"(確定顧客以外)の場合、顧客特定実行
              if Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus <> SPECIFY_CUSTOMER then
              begin
                // クラス開始ログ
                Self.IVRLog.ClassStrat('Express顧客特定');
                // 顧客特定指示
                Self.FSpecifiedCustomer.TransNoSpecify := True;
                // Express顧客判定
                Self.FSpecifiedCustomer.SpecifyExpressCustomer := True;
                // 通常顧客判定フラグを格納
                Self.FSpecifiedCustomer.SpecifyCustomerFlag := (Self.FIVRControlStatusInfo.SpecifyCustomerStatus = SPECIFY_CUSTOMER);

                // 顧客判定呼び出し
                Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus := Self.FSpecifiedCustomer.CustomerMain;

                if Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus = SPECIFY_CUSTOMER then
                begin
                  // Express顧客特定済みの場合は、通常顧客判定も済とする
                  Self.FIVRControlStatusInfo.SpecifyCustomerStatus := SPECIFY_CUSTOMER;
                end;
                Self.IVRLog.AddLog('SpecifyExpressCustomerStatus = ' + IntToStr(Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus));
                // クラス終了ログ
                Self.IVRLog.ClassEnd('Express顧客特定');

                // 顧客状態が新規顧客の場合、問合せ不可実行
                if Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus = NEW_CUSTOMER then
                begin
                  // CSOP転送
                  raise EOPForward.Create(ERR_CODE202700030005);
                end;
                if Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus = DEFAULT then
                begin
                  Self.FIVRControlStatusInfo.EnqMenuStatus := 0;
                  Self.IVRLog.AddLog('Express顧客特未確定(SpecifyExpressCustomerStatus = ' + IntToStr(Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus) + ')');
                end;
              end else
              begin
                Self.IVRLog.AddLog('Express顧客特定済み(SpecifyExpressCustomerStatus = ' + IntToStr(Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus) + ')');
              end;
            end;

            case Self.FIVRControlStatusInfo.EnqMenuStatus of
              SELECT_PROGRAM_GUIDE:
                begin
                  // クラス開始ログ
                  Self.IVRLog.ClassStrat('番組ガイド申込案内');
                  // 番組ガイド申込案内クラス実行
                  Self.FProgramGuideOrder.ProgramGuideOrderMain;
                  // クラス終了ログ
                  Self.IVRLog.ClassEnd('番組ガイド申込案内');
                end;
              SELECT_REFUNDMENT_GUIDANCE:
                begin
                  // クラス開始ログ
                  Self.IVRLog.ClassStrat('返金案内');
                  // Express顧客特定済みかを設定
                  Self.FSelectRefundmentGuidance.SpecifyExpressCustomerFlag :=
                    (Self.FIVRControlStatusInfo.SpecifyExpressCustomerStatus = SPECIFY_CUSTOMER);
                  // 返金案内クラス実行
                  Self.FSelectRefundmentGuidance.SelectRefundmentGuidanceMain;
                  // クラス終了ログ
                  Self.IVRLog.ClassEnd('返金案内');
                end;
              SELECT_IEO_SERVICE_CHANGE_MENU:
                begin
                  // クラス開始ログ
                  Self.IVRLog.ClassStrat('IEOサービス変更メニュー');
                  // IEOサービス変更メニュークラス実行
                  Self.FIEOServiceChangeMenu.IEOServiceChangeMenuMain;
                  // クラス終了ログ
                  Self.IVRLog.ClassEnd('IEOサービス変更メニュー');
                end;
              SELECT_POINT_GUIDANCE:
                begin
                  // クラス開始ログ
                  Self.IVRLog.ClassStrat('ポイント案内');
                  // ポイント案内クラス実行
                  Self.FPoint.PointMain;
                  // クラス終了ログ
                  Self.IVRLog.ClassEnd('ポイント案内');
                end;
{   // リリース予定が延びた為保留
              SELECT_STOCK_GUIDE:
                begin
                  // クラス開始ログ
                  Self.IVRLog.ClassStrat('在庫状況案内');
                  // 番組ガイド申込案内クラス実行
                  Self.FStockGuide.StockGuideStatusMain;
                  // クラス終了ログ
                  Self.IVRLog.ClassEnd('在庫状況案内');

                  // 在庫状況確認で受注が選択された場合受注へ
                  if Length(Self.IVRData.StockItemData) <> 0 then
                  begin
                    mLoopEnquiry := True;
                    Self.FIVRControlStatusInfo.IvrMenuStatus := ORDER;
                    Self.IVRData.SysDateTime := Date;
                    // フラグの初期化
                    Self.IVRData.SetCustomerFlag := False;
                    // IDL(オンライン運用日取得)
                    ExecGetOperationDateInfo;
                  end;
                end;
}
              SELECT_ORDER:
                begin
                  // クラス開始ログ
                  Self.IVRLog.ClassStrat('IVR受注');
                  mLoopEnquiry := True;
                  Self.FIVRControlStatusInfo.IvrMenuStatus := ORDER;
                  Self.IVRData.BusinessStartCode := bsOrder;
                  Self.IVRData.SysDateTime := Date;

                  // フラグの初期化
                  Self.IVRData.SetCustomerFlag := False;
                  // ログ
                  Self.IVRLog.Normal('SetCustomerFlag=' + BoolToStr(Self.IVRData.SetCustomerFlag));

                  // クラス終了ログ
                  Self.IVRLog.ClassEnd('IVR受注');
                  // IDL(オンライン運用日取得)
                  ExecGetOperationDateInfo;

                  // 受注端末状況更新
                  // 　問合せ⇒受注へ
                  ExecSetAgentControlForAffair(Self.FIVRControlStatusInfo.IvrMenuStatus);
                end;
            end; // end case
          end; // end while
        end; // end if
      end; // end while メインループ
    except
      on E: EOPForward do
      begin
        // 顧客がロック状態の場合はロックの解除処理を行う
        Self.ExecunlockCustomer;  //2006.03.27  ロックフラグ=Trueならの条件を削除

        // 区分のセット
        Self.IVRData.LineStatusKbn := 1;
        // CC端末稼動情報追加・更新処理
        Self.ExecSetAgentControlForTelOPFoward;
        // OP転送処理
        SetOPFowardTransferInfo(E.Message);
        raise;
      end;
      on E: EPutDown do  // 回線切断
      begin
        // 区分のセット
        Self.IVRData.LineStatusKbn := 2;
        // CC端末稼動情報追加・更新処理
        Self.ExecSetAgentControlForAffairCutConnect;
        // 回線切断処理
        CutConnection;
        raise;
      end;
      else
      begin
        // 顧客ロック解除
        Self.ExecunlockCustomer;  //2006.03.27  ロックフラグ=Trueならの条件を削除
        // 区分のセット
        Self.IVRData.LineStatusKbn := 1;
        // OP転送処理
        SetOPFowardTransferInfo(ERR_CODE000000000001);
        raise;
      end;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure ExecSetAgentControlForTel;
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *    CC端末稼動情報追加・更新処理
  *
  * 4. 機能説明
  *    CC端末稼動情報追加・更新処理
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.ExecSetAgentControlForTel;
const
  FUNCTION_NAME = 'ExecSetAgentControlForTel';
// 2012/12/31 akiyama change start 次期要件
//  EXEC_IDL = 'SetAgentControlForTel';
  EXEC_IDL = 'SetAgentControlInfo';
// 2012/12/31 akiyama change end 次期要件
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
    try
      // ログ
      Self.IVRLog.AddLog('IDLパラメータセット');
// 2012/12/31 akiyama change start 次期要件
//      Self.IVRLog.AddLog('端末稼働状態区分:' + '2');
      Self.IVRLog.AddLog('受注端末状況区分:' + '2');
      Self.IVRLog.AddLog('受注端末業務区分:');
// 2012/12/31 akiyama change end 次期要件
      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);
      // IDL実行(SetAgentControlForTel)
// 2012/12/31 akiyama change start 次期要件
//      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlForTel('2');
      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlInfo(
          '2',       // 受注端末状況区分
          BLANK);    // 受注端末業務区分
// 2012/12/31 akiyama change end 次期要件
      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);
    except
      raise;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure ExecSetAgentControlForAffair(ABusinessStartCode: ShortInt);
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *    CC端末稼動情報追加・更新処理
  *
  * 4. 機能説明
  *    CC端末稼動情報追加・更新処理
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.ExecSetAgentControlForAffair(ABusinessStartCode: ShortInt);
var
  mTerminalOperatingAffrDiv: String;
const
  FUNCTION_NAME = 'ExecSetAgentControlForAffair';
// 2012/12/31 akiyama change start 次期要件
//  EXEC_IDL = 'SetAgentControlForAffair';
  EXEC_IDL = 'SetAgentControlInfo';
// 2012/12/31 akiyama change end 次期要件
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
    try
      // 業務区分より端末稼働業務区分の設定を行う
      if (ABusinessStartCode = ENQUIRY) or
         (ABusinessStartCode = DELIVERY_STATUS) then // 配送状況案内
      begin
        mTerminalOperatingAffrDiv := TERMINAL_AFFAIR_ENQ;
      end else
      begin
        mTerminalOperatingAffrDiv := TERMINAL_AFFAIR_ORDER;
      end;

      // ログ
      Self.IVRLog.AddLog('IDLパラメータセット');
// 2012/12/31 akiyama change start 次期要件
//      Self.IVRLog.AddLog('端末稼働業務区分:' + mTerminalOperatingAffrDiv);
      Self.IVRLog.AddLog('受注端末状況区分:');
      Self.IVRLog.AddLog('受注端末業務区分:' + mTerminalOperatingAffrDiv);
// 2012/12/31 akiyama change end 次期要件
      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);
      // IDL実行(SetAgentControlForAffair)
// 2012/12/31 akiyama change start 次期要件
//      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlForAffair(mTerminalOperatingAffrDiv);
      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlInfo(
          BLANK,                         // 受注端末状況区分
          mTerminalOperatingAffrDiv);    // 受注端末業務区分
// 2012/12/31 akiyama change end 次期要件
      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);
    except
      raise;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure ExecSetAgentControlForAffairCutConnect;
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *    CC端末稼動情報追加・更新処理
  *
  * 4. 機能説明
  *    CC端末稼動情報追加・更新処理
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.ExecSetAgentControlForAffairCutConnect;
const
  FUNCTION_NAME = 'ExecSetAgentControlForAffairCutConnect';
  TMNL_OPRTNG_COND_OTHER = '1';
// 2012/12/31 akiyama change start 次期要件
//  EXEC_IDL = 'SetAgentControlForAffair';
  EXEC_IDL = 'SetAgentControlInfo';
// 2012/12/31 akiyama change end 次期要件
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
    try
      // ログ
      Self.IVRLog.AddLog('IDLパラメータセット');
// 2012/12/31 akiyama change start 次期要件
//      Self.IVRLog.AddLog('端末稼働業務区分:' + TMNL_OPRTNG_COND_OTHER);
      Self.IVRLog.AddLog('受注端末状況区分:');
      Self.IVRLog.AddLog('受注端末業務区分:' + TMNL_OPRTNG_COND_OTHER);
// 2012/12/31 akiyama change end 次期要件
      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);
      // IDL実行(SetAgentControlForAffair)
// 2012/12/31 akiyama change start 次期要件
//      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlForAffair(TMNL_OPRTNG_COND_OTHER);
      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlInfo(
          BLANK,                      // 受注端末状況区分
          TMNL_OPRTNG_COND_OTHER);    // 受注端末業務区分
// 2012/12/31 akiyama change end 次期要件
      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);
    except
      raise;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure ExecSetAgentControlForAffairCutConnect;
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *    CC端末稼動情報追加・更新処理
  *
  * 4. 機能説明
  *    CC端末稼動情報追加・更新処理
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.ExecSetAgentControlForTelOPFoward;
const
  FUNCTION_NAME = 'ExecSetAgentControlForTelOPFoward';
  TMNL_OPRTNG_COND_OTHER = '3';
// 2012/12/31 akiyama change start 次期要件
//  EXEC_IDL = 'SetAgentControlForTel';
  EXEC_IDL = 'SetAgentControlInfo';
// 2012/12/31 akiyama change end 次期要件
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
    try
      // ログ
      Self.IVRLog.AddLog('IDLパラメータセット');
// 2012/12/31 akiyama change start 次期要件
//      Self.IVRLog.AddLog('端末稼働業務区分:' + TMNL_OPRTNG_COND_OTHER);
      Self.IVRLog.AddLog('受注端末状況区分:' + TMNL_OPRTNG_COND_OTHER);
      Self.IVRLog.AddLog('受注端末業務区分:');
// 2012/12/31 akiyama change end 次期要件
      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);
      // IDL実行(SetAgentControlForTel)
// 2012/12/31 akiyama change start 次期要件
//      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlForTel(TMNL_OPRTNG_COND_OTHER);
      Self.ServerAccess.TelephonyAccess.TelephonyHome.SetAgentControlInfo(
          TMNL_OPRTNG_COND_OTHER,    // 受注端末状況区分
          BLANK);                    // 受注端末業務区分
// 2012/12/31 akiyama change end 次期要件
      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);
    except
      raise;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure ExecGetOperationDateInfo;
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *      オンライン運用日付再取得処理
  *
  * 4. 機能説明
  *      オンライン運用日付再取得処理
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.ExecGetOperationDateInfo;
var
  mOperationDateInfo: CCUtility_i.OperationDateInfo;
  mYYMMDDHHMMSS,mYear,mMonth,mDay,mHH,mMM,mSS: String;
const
  FUNCTION_NAME = 'ExecGetOperationDateInfo';
  EXEC_IDL = 'GetOperationDateInfo';
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
    try
      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);
      // IDL実行(GetOperationDateInfo)
      mOperationDateInfo := Self.ServerAccess.UtilityAccess.UtilityHome.GetOperationDateInfo();
      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);
      // IVRData.オンライン運用日付再設定処理
      mYear := Copy(mOperationDateInfo.online_operation_date,1,4);
      mMonth := Copy(mOperationDateInfo.online_operation_date,5,2);
      mDay := Copy(mOperationDateInfo.online_operation_date,7,2);

      mHH := Copy(FormatDateTime('HH:MM:SS',Now),1,2);
      mMM := Copy(FormatDateTime('HH:MM:SS',Now),4,2);
      mSS := Copy(FormatDateTime('HH:MM:SS',Now),7,2);

      mYYMMDDHHMMSS := mYear + SLASH + mMonth + SLASH + mDay + ' ' + mHH + COLON + mMM + COLON + mSS;
      // ログ出力
      Self.IVRLog.AddLog('オンライン運用日：' + mYYMMDDHHMMSS);

      Self.IVRData.SysDateTime := StrToDateTime(mYYMMDDHHMMSS);
    except
      raise;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure CutConnection;
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *      IVR業務の回線切断を行います
  *
  * 4. 機能説明

  *      IVR業務の回線切断を行います
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.CutConnection;
const
  FUNCTION_NAME = 'CutConnection';
  EXEC_IDL = 'RollbackOrders';
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
    // 商品選択のaddOrder ～ 受注確認のCommitOrdersの間で回線切断が発生した場合
    if Self.IVRData.RollBackFlag then
    begin
      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);
      // IDL実行(RollbackOrders)
      // 受注受付画面での全操作を取消して、受注入力処理以前の状態に戻す
      Self.ServerAccess.OrderAccess.OrdersHome.RollbackOrders;
      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);
    end else
    begin
      // 以外の場合で顧客がロック状態で回線切断が発生した場合
      // 顧客のロック解除処理実行
      Self.ExecunlockCustomer;  //2006.03.27  ロックフラグ=Trueならの条件を削除
    end;

  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure ExecunlockCustomer;
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *    顧客のロック解除処理を行います
  *
  * 4. 機能説明
  *    顧客のロック解除処理を行います
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.ExecunlockCustomer;
const
  FUNCTION_NAME = 'ExecunlockCustomer';
  EXEC_IDL = 'UnlockCustomer';
var
  wkCstCD:String;
// 2012/12/31 akiyama add start 次期要件
  i: Integer;
  mValidCount: Integer;
// 2012/12/31 akiyama add end 次期要件
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
      if Self.IVRData.UnlockCustomerFlag = True then exit;

// 2012/12/31 akiyama add start 次期要件
      mValidCount := 0;
      if (Self.IVRData.IVRExpressInfoList <> nil) then
      begin
        for i := 0 to Length(Self.IVRData.IVRExpressInfoList)-1 do
        begin
          if (Self.IVRData.IVRExpressInfoList[i].final_login_date_time <> BLANK) and
             (Self.IVRData.IVRExpressInfoList[i].ivr_information_expiry_flag = CST_IEO_NOT_EXPRY) then
          begin
            Inc(mValidCount);
          end;
        end;
      end;
// 2012/12/31 akiyama add end 次期要件

      if Self.IVRData.CustBasicInfoList <> nil then
      begin
        wkCstCD := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].customer_code;
// 2012/12/31 akiyama change start 次期要件
//      end else if (Self.IVRData.IVRExpressInfoList <> nil) and
//                  (Length(Self.IVRData.IVRExpressInfoList) > 0) and
      end else if (mValidCount > 0) and
// 2012/12/31 akiyama change end 次期要件
                  (Self.IVRData.CustomerSpecified = FLAG_ON) then
      begin
        wkCstCD := Self.IVRData.IVRExpressInfoList[0].customer_code;
      end else begin
        Exit;
      end;

      if Trim(wkCstCD)='' then Exit;

      Self.IVRLog.AddLog('IDLパラメータセット');
      Self.IVRLog.AddLog('顧客コード：' + wkCstCD);
      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);
      // IDL実行(UnlockCustomer)
      Self.ServerAccess.CustomerAccess.CustomerHome.UnlockCustomer(wkCstCD);
      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);

  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *    procedure ExecSetDeliveryOptionInfo;
  *
  * 2. パラメータ説明
  *      なし
  *
  * 3. 概要
  *      顧客の配送指定情報をクリアする
  *
  * 4. 機能説明
  *      配送指定情報をクリアする
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.ExecSetDeliveryOptionInfo;
var
  mDeliveryOptionInfo: CCOrder_i.DeliveryOptionInfo;

const
  FUNCTION_NAME = 'ExecSetDeliveryOptionInfo';
  EXEC_IDL = 'SetDeliveryOptionInfo';
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  try
    try
      // 構造体を作成
      mDeliveryOptionInfo := CCOrder_c.TDeliveryOptionInfo.Create(BLANK, BLANK, BLANK, BLANK, BLANK, BLANK, BLANK);

      mDeliveryOptionInfo.delivery_date_designation_division := DIV_APO_NON;

      Self.IVRLog.AddLog('IDLパラメータセット');
      Self.IVRLog.AddLog('受付番号:' + Self.IVRData.OrderNumber);
      Self.IVRLog.AddLog('配送通信欄内容:' + mDeliveryOptionInfo.delivery_communication_column_text);
      Self.IVRLog.AddLog('配送指定日:' + mDeliveryOptionInfo.delivery_designation_date);
      Self.IVRLog.AddLog('お届け希望曜日区分１:' + mDeliveryOptionInfo.delivery_hopeful_weekday_division_1);
      Self.IVRLog.AddLog('お届け希望曜日区分２:' + mDeliveryOptionInfo.delivery_hopeful_weekday_division_2);
      Self.IVRLog.AddLog('配送日指定区分:' + mDeliveryOptionInfo.delivery_date_designation_division);
      Self.IVRLog.AddLog('時間帯指定配送区分:' + mDeliveryOptionInfo.time_range_designation_delivery_division);
      Self.IVRLog.AddLog('お届け完了案内要フラグ:' + mDeliveryOptionInfo.delivery_close_out_guidance_flag);

      // CORBA開始ログ
      Self.IVRLog.CORBAMethodStart(EXEC_IDL);

      // IDLを実行してIVRDataにセット
      Self.IVRData.OrderInfo :=
        Self.ServerAccess.OrderAccess.OrderDeliveryHome.SetDeliveryOptionInfo(
          Self.IVRData.OrderNumber, BLANK, mDeliveryOptionInfo);

      // CORBA終了ログ
      Self.IVRLog.CORBAMethodEnd(EXEC_IDL);

      // デバッグ用CORBAログ
      Self.IVRLog.CORBALog(Self.IVRData.OrderInfo);

    except
      raise;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(*******************************************************************************
  * 1. 関数・処理名称
  *      procedure OPFowardTransfer(TransMsgCode: String);
  *
  * 2. パラメータ説明
  *      TransMsgCode: String
  *      各種サービスより渡されたエラーメッセージコード
  *
  * 3. 概要
  *      各種サービスより例外が発生した場合オペレータ転送を行います
  *
  * 4. 機能説明
  *
  * 5. 戻り値
  *      なし
  *
  * 6. 備考
  *      なし
  *
*******************************************************************************)
procedure TIVRControl.SetOPFowardTransferInfo(TransMsgCode: String);
var
  mTransferInfo: CCTelephony_i.TransferInfo;
// 2012/12/31 akiyama delete start 次期要件
//  mTransferDetailInfo: CCTelephony_i.TransferDetailInfo;
//  mTransferDetailInfoList: CCTelephony_i.TransferDetailInfoList;
// 2012/12/31 akiyama delete end 次期要件
  mDialogResult: TDialogRes;
// 2012/12/31 akiyama change start 次期要件
//  i,j: Integer;
  i: Integer;
// 2012/12/31 akiyama change end 次期要件
  mTransferReason: String;
  mTransferDivision: String;
//  mTransferDestination: String;
//  mTransMsgList: TStringList;
  mTransMsgCode: String;    // 転送メッセージコード
  mPartCode: String;
  DisConnected: Boolean;
// 2012/12/31 akiyama add start 次期要件
  mValidCount: Integer;
// 2012/12/31 akiyama add end 次期要件
  mTransferDestination: String;
const
  FUNCTION_NAME = 'SetOPFowardTransferInfo';
begin
  // メソッド開始ログ
  Self.IVRLog.MethodStart(FUNCTION_NAME);
  DisConnected := False;
  try
    try
// 2012/12/31 akiyama delete start 次期要件
//      // リストの初期化
//      SetLength(mTransferDetailInfoList,0);
//      // 構造体生成
//      mTransferDetailInfo := CCTelephony_c.TTransferDetailInfo.Create('','','','','','','','','','','','','',0,'','','','','','','','','','','');
// 2012/12/31 akiyama delete end 次期要件
// 2012/12/31 akiyama change start 次期要件
//      mTransferInfo := CCTelephony_c.TTransferInfo.Create('','','','','','','','','','','','','','','','',0,mTransferDetailInfoList,'','','',0);
      mTransferInfo := CCTelephony_c.TTransferInfo.Create;
// 2012/12/31 akiyama change end 次期要件
      // 転送理由コードが''の場合、転送は行わない
      if TransMsgCode <> '' then
      begin
        // 転送理由取得
        mTransferReason := TransMsgCode ;
        mTransMsgCode := Copy(mTransferReason,1,12);
        mPartCode := Copy(mTransferReason,1,5);

        // 転送区分の取得(受注系サービスの場合)
        if (mPartCode = TRANSFER_IVRMENU) or
           (mPartCode = TRANSFER_CUSTOMER_INFOMATION) or
           (mPartCode = TRANSFER_SELECT_ITEM) or
           (mPartCode = TRANSFER_AMOUNT_CALCULATION) or
           (mPartCode = TRANSFER_PAYMENT_METHOD) or
           (mPartCode = TRANSFER_NEW_CUSTOMER) or
           (mPartCode = TRANSFER_ENQUETE) or
           (mPartCode = TRANSFER_DESTINATION_CONFIRMATION) or
           (mPartCode = TRANSFER_DESTINATION_JUDGEMENT) or
           (mPartCode = TRANSFER_DELIVERY_DESIGNATION) or
//2014/03/03 kamiya add start 送料定額PJ
           (mPartCode = TRANSFER_TOTAL_AMOUNT) or
           (mPartCode = TRANSFER_DFLT_DESIG_CONFIRMATION) or
//2014/03/03 kamiya add end 送料定額PJ
           (mPartCode = TRANSFER_ORDER_CONFIRMATION) or
           (mPartCode = TRANSFER_COPE_CUSTOMER) or
           (mPartCode = TRANSFER_ADD_ORDER) or
           (mPartCode = TRANSFER_EXPRESS_MAIN) or
           (mPartCode = TRANSFER_EXPRESS_ITEM) or
           (mPartCode = TRANSFER_EXPRESS_CALC) or
           (mPartCode = TRANSFER_EXPRESS_BRTH) or
           (mPartCode = TRANSFER_EXPRESS_CONF) or
           (mPartCode = TRANSFER_EXPRESS_DELV) or
           (mPartCode = TRANSFER_EXPRESS_PAYM) or
           (mPartCode = TRANSFER_EXPRESS_CHNG) or
           (mPartCode = TRANSFER_EXPRESS_RGST) or
           (mPartCode = TRANSFER_EXPRESS_SPCF) or
           (mPartCode = TRANSFER_DISCOUNT_TICKET) or
           (mPartCode = TRANSFER_STOCK_STATUS) or
           (mPartCode = TRANSFER_CELLULAR_REG) then
        begin
          // 転送先セット(制御渡し)
          Self.IVRData.TransferDestination := TRANSFER_DIVISION_OP;
          // 転送区分セット
          mTransferDivision := DIV_ODR_FWD;

          // 商品先引当を通過しているか確認
          if Self.IVRData.ReserveFlag then
          begin
            Self.IVRData.TransferDestination := TRANSFER_DIVISION_OPLAST;
          end;
        end else
        begin
          if mPartCode = TRANSFER_CANCEL then
          begin
            // 転送先セット(制御渡し)
            Self.IVRData.TransferDestination := TRANSFER_DIVISION_OP;
            // 転送区分セット
            mTransferDivision := DIV_ODR_FWD;
          end else
          begin
            // 問合せ系サービスの場合(問合せメニュー・配送状況案内・返金案内・番組ガイド申込案内)
            if (mPartCode = TRANSFER_ENQUIRY_MENU) or
               (mPartCode = TRANSFER_DELIVERY_STATUS) or
               (mPartCode = TRANSFER_REFUNDMENT) or
               (mPartCode = TRANSFER_RETURN) or
               (mPartCode = TRANSFER_DISABLE_ENQUIRY) or
               (mPartCode = TRANSFER_EXPRESS_SRVC) or
               (mPartCode = TRANSFER_EXPRESS_DEID) or
               (mPartCode = TRANSFER_EXPRESS_EPRY) or
               (mPartCode = TRANSFER_RETURN_REFUNDMENT) or
               (mPartCode = TRANSFER_REFUNDMENT_GUIDANCE) or
               (mPartCode = TRANSFER_PROGRAM_GUIDE_ORDER) then
//               (mPartCode = TRANSFER_STOCK_GUIDE) then
            begin
              // 転送先セット(制御渡し)
              Self.IVRData.TransferDestination := TRANSFER_DIVISION_CSOP;
              // 転送区分セット
              mTransferDivision := DIV_ENQ_FWD;
            end else
            begin
              // ポイント案内の場合
              if mPartCode = TRANSFER_POINT then
              begin
                // 転送先セット(制御渡し)
                Self.IVRData.TransferDestination := TRANSFER_DIVISION_CSOP;
                // 転送区分セット
                mTransferDivision := DIV_PNT_GUID_FWD;
              end else
              begin
                // 顧客特定の場合
                // 受注系顧客特定の場合なのか？問合せ系顧客特定の場合なのか判断
                if mPartCode = TRANSFER_SPECIFIED_CUSTOMER then
                begin
                  if (Self.FIVRControlStatusInfo.IvrMenuStatus = ORDER) or
                     (Self.FIVRControlStatusInfo.IvrMenuStatus = CANCEL) or
                     (Self.FIVRControlStatusInfo.IvrMenuStatus = RESERVE) then
                  begin
                    // 受注系サービス時に転送があった場合、通常OP転送
                    // 転送先セット(制御渡し)
                    Self.IVRData.TransferDestination := TRANSFER_DIVISION_OP;
                    // 転送区分セット
                    mTransferDivision := DIV_ODR_FWD;
                  end else
                  begin
                    if (Self.FIVRControlStatusInfo.IvrMenuStatus = ENQUIRY) or
                       (Self.FIVRControlStatusInfo.IvrMenuStatus = DELIVERY_STATUS) then
                    begin
                      // 問合せメニュー～顧客特定時に転送があった場合、問合せ系OP転送
                      // 転送先セット(制御渡し)
                      Self.IVRData.TransferDestination := TRANSFER_DIVISION_CSOP;
                      // 転送区分セット
                      mTransferDivision := DIV_ENQ_FWD;
                    end;
                  end;
                end else
                begin
                  // 以外の場合
                  if (Self.FIVRControlStatusInfo.IvrMenuStatus = ORDER) or
                     (Self.FIVRControlStatusInfo.IvrMenuStatus = CANCEL) or
                     (Self.FIVRControlStatusInfo.IvrMenuStatus = RESERVE) then
                  begin
                    // 転送先セット(制御渡し)
                    Self.IVRData.TransferDestination := TRANSFER_DIVISION_OP;
                    // 転送区分セット
                    mTransferDivision := DIV_ODR_FWD;
                  end else
                  begin
                    if (Self.FIVRControlStatusInfo.IvrMenuStatus = ENQUIRY) or
                       (Self.FIVRControlStatusInfo.IvrMenuStatus = DELIVERY_STATUS) then
                    begin
                      // 転送先セット(制御渡し)
                      Self.IVRData.TransferDestination := TRANSFER_DIVISION_CSOP;
                      // 転送区分セット
                      mTransferDivision := DIV_ENQ_FWD;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;

// 2012/12/31 akiyama delete start 次期要件
//        if (Self.IVRData.OrderInfo <> nil) and (Length(Self.IVRData.OrderInfo.OrderSubInfo_list) > 0) then
//        begin
//          // 受注明細情報リスト要素分、以下のループ処理を行う
//          for i := 0 to Length(Self.IVRData.OrderInfo.OrderSubInfo_list) -1 do
//          begin
//            // 転送明細情報リストの長さをセットする
//            mTransferDetailInfo := CCTelephony_c.TTransferDetailInfo.Create('','','','','','','','','','','','','',0,'','','','','','','','','','','');
//            SetLength(mTransferDetailInfoList,Length(mTransferDetailInfoList) + 1);
//            // リストに値をセットする
//            mTransferDetailInfoList[Length(mTransferDetailInfoList) -1] := mTransferDetailInfo;
//            // 受注受付日時
//            mTransferDetailInfoList[i].order_accept_datetime := Self.IVRData.OrderInfo.order_accept_date_time;
//            // 受注受付番号
//            mTransferDetailInfoList[i].order_number := Self.IVRData.OrderInfo.order_number;
//            // 受注明細行連番
//            mTransferDetailInfoList[i].order_detail_row_sequence := Self.IVRData.OrderInfo.OrderSubInfo_list[i].order_detail_row_seq;
//            // 受注明細連番
//            mTransferDetailInfoList[i].order_detail_seq := Self.IVRData.OrderInfo.OrderSubInfo_list[i].order_detail_seq;
//            // 集合単位連番
//            mTransferDetailInfoList[i].ensemble_unit_seq := Self.IVRData.OrderInfo.OrderSubInfo_list[i].ensemble_unit_of_credit_seq;
//            // 商品No
//            mTransferDetailInfoList[i].sales_item_number := Self.IVRData.OrderInfo.OrderSubInfo_list[i].sales_item_number;
//            // 商品基本コード
//            mTransferDetailInfoList[i].item_basic_code := Self.IVRData.OrderInfo.OrderSubInfo_list[i].item_basic_code;
//            // サイズ
//            mTransferDetailInfoList[i].size_name_kana := Self.IVRData.OrderInfo.OrderSubInfo_list[i].size_name_kana;
//            // 色
//            mTransferDetailInfoList[i].item_basic_color_design_name_kana := Self.IVRData.OrderInfo.OrderSubInfo_list[i].item_basic_color_design_name_kana;
//            // ショップマネー番号
//            mTransferDetailInfoList[i].shopmoney_number := Self.IVRData.ShopmoneyNo;
//            // 割引１フラグ
//            mTransferDetailInfoList[i].shopmoney_discount_apply_division := Self.IVRData.GeneralDiscountUseFlag;
//            // 割引２フラグ
//            mTransferDetailInfoList[i].employee_discount_apply_flag := Self.IVRData.EmployeeDiscountUseFlag;
//
//            // IVR Express Order なら
//            if Self.IVRData.BusinessStartCode = bsExpress then
//            begin
//              // 顧客IVRExpress情報が存在するなら
//              if (Self.IVRData.IVRExpressInfoList <> nil) and
//                 (Length(Self.IVRData.IVRExpressInfoList) = 1) then
//              begin
//                // 受領形態区分 = クレジット なら
//                if Self.IVRData.IVRExpressInfoList[0].reception_figuration_division = RCPTN_CRDT then
//                begin
//                  // カード会社
//                  mTransferDetailInfoList[i].creditcard_company_code := Self.IVRData.IVRExpressInfoList[0].credit_card_company_code;
//                  // カードNO
//                  mTransferDetailInfoList[i].creditcard_number := Self.IVRData.IVRExpressInfoList[0].credit_card_number;
//                  // 有効期限
//                  mTransferDetailInfoList[i].creditcard_available_period := Self.IVRData.IVRExpressInfoList[0].credit_card_available_period;
//                  // 支払分割区分
//                  mTransferDetailInfoList[i].payment_divided_division := Self.IVRData.IVRExpressInfoList[0].payment_divided_division;
//                  // 支払回数
//                  mTransferDetailInfoList[i].payment_count := Self.IVRData.IVRExpressInfoList[0].payment_count;
//                end;
//                // 配送指定日
//                mTransferDetailInfoList[i].delivery_designation_date := Self.IVRData.IVRExpressAppointDate;
//                // 配送曜日指定１
//                mTransferDetailInfoList[i].delivery_hope_weekday_division_1 := Self.IVRData.IVRExpressInfoList[0].delivery_hopeful_weekday_division_1;
//                // 配送曜日指定２
//                mTransferDetailInfoList[i].delivery_hope_weekday_division_2 := Self.IVRData.IVRExpressInfoList[0].delivery_hopeful_weekday_division_2;
//                // 配送指定時間帯区分
//                mTransferDetailInfoList[i].time_range_designation_delivery_division := Self.IVRData.IVRExpressInfoList[0].time_range_designation_delivery_division;
//                //2008.12.01 add S081015004対応 >>>>
//                if self.IVRData.DelivryChangeFlg then
//                begin
//                  // 配送指定日
//                  mTransferDetailInfoList[i].delivery_designation_date := '';
//                  // 配送曜日指定１
//                  mTransferDetailInfoList[i].delivery_hope_weekday_division_1 := '';
//                  // 配送曜日指定２
//                  mTransferDetailInfoList[i].delivery_hope_weekday_division_2 := '';
//                  // 配送指定時間帯区分
//                  mTransferDetailInfoList[i].time_range_designation_delivery_division := '';
//                end;
//              end;
//            end
//
//            // 通常IVRなら
//            else
//            begin
//              // カード会社
//              mTransferDetailInfoList[i].creditcard_company_code := Self.IVRData.CardCompany;
//              // カードNo
//              mTransferDetailInfoList[i].creditcard_number := Self.IVRData.CardNumber;
//              if Self.IVRData.OrderInfo.OrderSubInfo_list[i].PaymentInfo_structure.PaymentCreditInfo_list <> nil then
//              begin
//                // 有効期限
//                mTransferDetailInfoList[i].creditcard_available_period := Self.IVRData.OrderInfo.OrderSubInfo_list[i].PaymentInfo_structure.PaymentCreditInfo_list[0].credit_card_available_period;
//                // 支払分割区分
//                mTransferDetailInfoList[i].payment_divided_division := Self.IVRData.OrderInfo.OrderSubInfo_list[i].PaymentInfo_structure.PaymentCreditInfo_list[0].payment_divided_division;
//                // 支払回数
//                mTransferDetailInfoList[i].payment_count := Self.IVRData.OrderInfo.OrderSubInfo_list[i].PaymentInfo_structure.PaymentCreditInfo_list[0].payment_count;
//              end;
//              if Self.IVRData.OrderInfo.OrderSubInfo_list[i].DeliveryOptionInfo_structure <> nil then
//              begin
//                // 配送指定日
//                mTransferDetailInfoList[i].delivery_designation_date := Self.IVRData.OrderInfo.OrderSubInfo_list[i].DeliveryOptionInfo_structure.delivery_designation_date;
//                // 配送曜日指定１
//                mTransferDetailInfoList[i].delivery_hope_weekday_division_1 := Self.IVRData.OrderInfo.OrderSubInfo_list[i].DeliveryOptionInfo_structure.delivery_hopeful_weekday_division_1;
//                // 配送曜日指定２
//                mTransferDetailInfoList[i].delivery_hope_weekday_division_2 := Self.IVRData.OrderInfo.OrderSubInfo_list[i].DeliveryOptionInfo_structure.delivery_hopeful_weekday_division_2;
//                // 配送指定時間帯区分
//                mTransferDetailInfoList[i].time_range_designation_delivery_division := Self.IVRData.OrderInfo.OrderSubInfo_list[i].DeliveryOptionInfo_structure.time_range_designation_delivery_division;
//              end;
//            end;
//          end;
//        end else
//        begin
//          // リストの長さをセットする
//          SetLength(mTransferDetailInfoList,1);
//          mTransferDetailInfoList[0] := mTransferDetailInfo;
//          mTransferInfo.TransferDetailInfo_List := mTransferDetailInfoList;
//        end;
// 2012/12/31 akiyama delete end 次期要件

        // 転送構造体に値をセットする
        // 受付番号
        if Self.IVRData.OrderInfo <> nil then
        begin
          mTransferInfo.order_number := Self.IVRData.OrderInfo.order_number;
        end;
        // 転送区分
        mTransferInfo.transfer_division := mTransferDivision;
        // 転送理由コード
        mTransferInfo.transfer_reason_code := mTransferReason;
        // 商品1件確定フラグ
        mTransferInfo.one_item_fix_flag := IntToStr(Self.IVRData.ItemSelectFlag);
        // 新規顧客フラグ
        mTransferInfo.new_customer_flag := IntToStr(Self.IVRData.NewCustomer);
        // 届先違いフラグ
        mTransferInfo.destination_different_flag := Self.IVRData.DestinationFlag;
        // 支払方法フラグ
        mTransferInfo.payment_means_flag := Self.IVRData.PaymentMeansFlag;
        // 配送指定フラグ判定
        if Self.IVRData.DeliveryDestinationFlag then
        begin
          mTransferInfo.delivery_designation_flag := DLVR_DSNT_AVLBL;
        end else
        begin
          mTransferInfo.delivery_designation_flag := DLVR_DSNT_UNAVL;
        end;
        // 新規顧客録音フラグ
        mTransferInfo.new_customer_recording_flag := IntToStr(Self.IVRData.NewCustomerAudioRecordingFlag);
        // 届先録音フラグ
        mTransferInfo.destination_recording_flag := IntToStr(Self.IVRData.DestinationAudioRecordingFlag);

        // 顧客が確定状態にある場合、顧客情報を転送情報としてセットする
        // 受注基本ワークに顧客コードがセットされていれば顧客確定状態
        if Self.IVRData.SetCustomerFlag then
        begin
// 2012/12/31 akiyama add start 次期要件
        // 有効データ数のカウント
        mValidCount := 0;
        if (Self.IVRData.IVRExpressInfoList <> nil) then
        begin
          for i := 0 to Length(Self.IVRData.IVRExpressInfoList)-1 do
          begin
            if (Self.IVRData.IVRExpressInfoList[i].final_login_date_time <> BLANK) and
               (Self.IVRData.IVRExpressInfoList[i].ivr_information_expiry_flag = CST_IEO_NOT_EXPRY) then
            begin
              Inc(mValidCount);
            end;
          end;
        end;
// 2012/12/31 akiyama add end 次期要件
          if Self.IVRData.CustBasicInfoList <> nil then
          begin
            // 顧客コード
            mTransferInfo.customer_code := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].customer_code;
// 2012/12/31 akiyama delete start 次期要件
//            // 顧客氏名姓カナ
//            mTransferInfo.customer_last_name_kana := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].customer_last_name_kana;
//            // 顧客氏名名カナ
//            mTransferInfo.customer_name_kana := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].customer_name_kana;
//            // 顧客ポイント数
//            mTransferInfo.customer_point_quantity := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].use_available_total_point_quantity;
//            // 顧客生年月日
//            mTransferInfo.customer_birth_date := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].customer_birth_date;
//            // 郵便番号
//            if Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].AddressInfo_structure <> nil then
//            begin
//              mTransferInfo.zipcode := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].AddressInfo_structure.zipcode;
//            end;
// 2012/12/31 akiyama delete end 次期要件
// 2012/12/31 akiyama change start 次期要件 ExpressInfoは全顧客が所有する
//          end else if (Self.IVRData.IVRExpressInfoList <> nil) and (Length(Self.IVRData.IVRExpressInfoList) > 0) then
          end else if (mValidCount > 0) then
// 2012/12/31 akiyama change end 次期要件
          begin
            if Self.IVRData.UnlockCustomerFlag = False then
            begin
              // 顧客コード
              mTransferInfo.customer_code := Self.IVRData.IVRExpressInfoList[0].customer_code;
            end;
// 2012/12/31 akiyama delete start 次期要件
//            // 顧客生年月日
//            mTransferInfo.customer_birth_date := Self.IVRData.IVRExpressInfoList[0].customer_birth_date;
// 2012/12/31 akiyama delete end 次期要件
          end;
        end;

// 2012/12/31 akiyama delete start 次期要件
//        // 顧客電話番号をセットする
//        if Self.IVRData.SetCustomerFlag then
//        begin
//          mTransferInfo.customer_telephone_number := Self.IVRData.InputTelNumber;
//          if (Self.IVRData.IVRExpressInfoList <> nil) and
//             (Length(Self.IVRData.IVRExpressInfoList) = 1) then
//          begin
//            mTransferInfo.customer_telephone_number := Self.IVRData.IVRExpressInfoList[0].customer_registration_telephone_number;
//          end;
//        end else
//        begin
//          if Self.IVRData.CustBasicInfoList <> nil then
//          begin
//            mTransferInfo.customer_telephone_number := Self.IVRData.CustBasicInfoList[Self.IVRData.CustIndex].customer_telephone_number;
//          end;
//        end;
// 2012/12/31 akiyama delete end 次期要件

// 2012/12/31 akiyama delete start 次期要件
//        if (Self.IVRData.OrderInfo <> nil) and (Length(Self.IVRData.OrderInfo.OrderSubInfo_list) > 0) then
//        begin
//          // 受注明細情報リスト要素分、以下のループ処理を行う
//          for j := 0 to Length(Self.IVRData.OrderInfo.OrderSubInfo_list) -1 do
//          begin
//            if Self.IVRData.OrderInfo.OrderSubInfo_list[j].DestinationInfo_structure <> nil then
//            begin
//              // 届先電話番号
//              mTransferInfo.destination_telephone_number := Self.IVRData.OrderInfo.OrderSubInfo_list[j].DestinationInfo_structure.destination_telephone_number;
//
//              if Self.IVRData.OrderInfo.OrderSubInfo_list[j].DestinationInfo_structure.AddressInfo_structure <> nil then
//              begin
//                // 届先郵便番号
//                mTransferInfo.destination_zipcode := Self.IVRData.OrderInfo.OrderSubInfo_list[j].DestinationInfo_structure.AddressInfo_structure.zipcode;
//              end;
//            end;
//          end;
//        end;
//        // 在引き確定個数
//        mTransferInfo.allocated_stock_fix_quantity := Self.IVRData.ItemFixCount;
//        // 転送明細情報リスト
//        mTransferInfo.TransferDetailInfo_List := mTransferDetailInfoList;
// 2012/12/31 akiyama delete end 次期要件
        // 発番
        mTransferInfo.transmission_person_number := Self.IVRData.TelNumber;
        // 転送情報を格納する
        Self.IVRData.SetTransferInfo(mTransferInfo);

        // OP転送・CSOP転送・OP転送最後尾判定
        if Self.IVRData.TransferDestination = TRANSFER_DIVISION_OP then
        begin
          // 非保持化用転送メッセージコードの判定
          if (TransMsgCode = ERR_CODE203600010016) or
             (TransMsgCode = ERR_CODE200700030038) then
          begin
            // 転送先セット
            mTransferDestination := DSTNTN_NOP_FWD;
          end else
          begin
            // 転送先セット
            mTransferDestination := DSTNTN_OP_FWD;
          end;
          // ログ(転送先)
          Self.IVRLog.AddLog('転送先:' + mTransferDestination);

          // デバッグ用CORBAログ
          Self.IVRLog.CORBALog(mTransferInfo);
          // ログ(ガイダンス)
          Self.IVRLog.Guidance('受注オペレーター転送(OP転送)');
          // ガイダンス開始ログ
          Self.IVRLog.GuidanceStart('PlayOperatorForward');
          // 実行
          mDialogResult := Self.IVRTalk.PlayOperatorForward;
          // ガイダンス終了ログ
          Self.IVRLog.GuidanceEnd('PlayOperatorForward');

          case mDialogResult of
            tDROK:
              begin
                // ログ(エラーメッセージコード)
                Self.IVRLog.AddLog(mTransMsgCode);
                // ログ(転送理由)
                Self.IVRLog.AddLog(mTransferReason);

                // 非保持化転送の場合
                if mTransferDestination = DSTNTN_NOP_FWD then
                begin
                  // 転送先電話番号をセット
                  Self.IVRData.TransferTelNumber := Self.IVRData.FDestinationTelNumber[2];
                end else
                begin
                  // 転送先電話番号をセット
                  Self.IVRData.TransferTelNumber := Self.IVRData.FDestinationTelNumber[0];
                end;
              end else
              begin
                // 区分のセット
                Self.IVRData.LineStatusKbn := 2;
                // CC端末稼動情報追加・更新処理
                Self.ExecSetAgentControlForAffairCutConnect;
                // 回線切断処理
                if not DisConnected then CutConnection;
              end;
          end;
        end else
        begin
          // CSOP転送の場合
          if Self.IVRData.TransferDestination = TRANSFER_DIVISION_CSOP then
          begin
            // 問合せサービス営業時間内判定
            if (Self.IVRData.EnquiryServiceStartTime <= FormatDateTime('hh:mm:ss',Self.IVRData.SysDateTime)) and
               (Self.IVRData.EnquiryServiceEndTime >= FormatDateTime('hh:mm:ss',Self.IVRData.SysDateTime)) then
            begin
              // ログ(ガイダンス)
              Self.IVRLog.Guidance('問合せオペレーター転送(CSOP転送)');
              // ガイダンス開始ログ
              Self.IVRLog.GuidanceStart('PlayOperatorForward');
              // 実行
              mDialogResult := Self.IVRTalk.PlayOperatorForward;
              // ガイダンス終了ログ
              Self.IVRLog.GuidanceEnd('PlayOperatorForward');

              case mDialogResult of
                tDROK:
                  begin
                    // ログ(エラーメッセージコード)
                    Self.IVRLog.AddLog(mTransMsgCode);
                    // ログ(転送理由)
                    Self.IVRLog.AddLog(mTransferReason);
                    // 転送先電話番号をセット
                    Self.IVRData.TransferTelNumber := Self.IVRData.FDestinationTelNumber[1];
                  end
                else
                  begin
                    // 区分のセット
                    Self.IVRData.LineStatusKbn := 2;
                    // CC端末稼動情報追加・更新処理
                    Self.ExecSetAgentControlForAffairCutConnect;
                    // 回線切断処理
                    CutConnection;
                  end;
              end;
            end else
            begin
              // ログ(ガイダンス)
              Self.IVRLog.Guidance('オペレーター問合せ時間外の為に回線切断');
              // ガイダンス開始ログ
              Self.IVRLog.GuidanceStart('PlayOperatorForwardByNotTimeRange');
              // 実行
              mDialogResult := Self.IVRTalk.PlayOperatorForwardByNotTimeRange;
              // ガイダンス終了ログ
              Self.IVRLog.GuidanceEnd('PlayOperatorForwardByNotTimeRange');

              case mDialogResult of
                tDROK:
                  begin
                    // ログ(エラーメッセージコード)
                    Self.IVRLog.AddLog(mTransMsgCode);
                    // ログ(転送理由)
                    Self.IVRLog.AddLog(mTransferReason);
                    // 区分のセット
                    Self.IVRData.LineStatusKbn := 2;
                    // CC端末稼動情報追加・更新処理
                    Self.ExecSetAgentControlForAffairCutConnect;
                    // 回線切断処理
                    CutConnection;

                  end
                else
                  begin
                    // 区分のセット
                    Self.IVRData.LineStatusKbn := 2;
                    // CC端末稼動情報追加・更新処理
                    Self.ExecSetAgentControlForAffairCutConnect;
                    // 回線切断処理
                    CutConnection;
                  end;
              end;
            end;
          end;
        end;

        // OPLast転送の場合
        if Self.IVRData.TransferDestination = TRANSFER_DIVISION_OPLAST then
        begin
          // 非保持化用転送メッセージコードの判定
          if (TransMsgCode = ERR_CODE203600010016) or
             (TransMsgCode = ERR_CODE200700030038) then
          begin
            // 転送先セット
            mTransferDestination := DSTNTN_NOP_FWD;
          end else
          begin
            // 転送先セット
            mTransferDestination := DSTNTN_OPLAST_FWD;
          end;
          // ログ(転送先)
          Self.IVRLog.AddLog('転送先:' + mTransferDestination);

          // デバッグ用CORBAログ
          Self.IVRLog.CORBALog(mTransferInfo);
          // ログ(ガイダンス)
          Self.IVRLog.Guidance('受注オペレーター転送(OP転送)');
          // ガイダンス開始ログ
          Self.IVRLog.GuidanceStart('PlayOperatorForward');
          // 実行
          mDialogResult := Self.IVRTalk.PlayOperatorForward;
          // ガイダンス終了ログ
          Self.IVRLog.GuidanceEnd('PlayOperatorForward');

          case mDialogResult of
            tDROK:
              begin
                // ログ(エラーメッセージコード)
                Self.IVRLog.AddLog(mTransMsgCode);
                // ログ(転送理由)
                Self.IVRLog.AddLog(mTransferReason);
                // 非保持化転送の場合
                if mTransferDestination = DSTNTN_NOP_FWD then
                begin
                  // 転送先電話番号をセット
                  Self.IVRData.TransferTelNumber := Self.IVRData.FDestinationTelNumber[2];
                end else
                begin
                  // 転送先電話番号をセット
                  Self.IVRData.TransferTelNumber := Self.IVRData.ReserveDestinationTelNumber;
                end;
              end
            else
              begin
                // 区分のセット
                Self.IVRData.LineStatusKbn := 2;
                // CC端末稼動情報追加・更新処理
                Self.ExecSetAgentControlForAffairCutConnect;
                // 回線切断処理
                if not DisConnected then CutConnection;
              end;
          end;
        end;
        // VDNの書き出し
        Self.IVRLog.AddLog('VDN OUT: ' + Self.IVRData.TransferTelNumber);
      end;
    except
      raise;
    end;
  finally
    // メソッド終了ログ
    Self.IVRLog.MethodEnd(FUNCTION_NAME);
  end;
end;

(******************************************************************************
  *
  * 2006.12.22      S.yokoyama      (IVR48 project)
  *                  EventRinging をcatchしたことの判断を追加
  *
  * 2006.10.16      S.taruya   　   (IVR48 project)
  *                  waitForCallの失敗を、戻り値で返す処理を追加
  *
  * 2006.10.04      yokoyama
  *   log出力の方法。
  *
  * 2006.10.02      S.taruya
  *   引数名、ローカル変数名の変更
  * 2006.09.29      S.yokoyama
  *   TIVRControl.GoFinalize; 追加
  *
  * 2006.09.26      S.yokoyama
  *   Goinitialize)  TApploggerのcreateは実施しない。
  *
  *
  *
  * 2006.08.24      S,yokoyama                     48 Channelized
  *    　　　　　　　　　　　　　　　　　　　　　　Goinitialize, GoReady　追加。　
  *                                                APPlogger.pas  参照
  *                                                PARENTFUNC.pas 参照
  *
  *
  * $Log: UCCOIVD20020.pas,v $
  * Revision 1.6  2006/04/04 07:06:39  Takahashi-N2
  * librarian
  * 集結 200604041600
  * OP転送で落ちる
  *
  * Revision 1.6  2006/04/04 06:55:28  Akiyama-H
  * unlockcustomer修正
  *
  * Revision 1.5  2006/03/28 01:33:19  Akiyama-H
  * 顧客ロック対応（ロックフラグの使用中止）
  *
  * Revision 1.4  2006/01/20 04:30:11  Koudate-T
  * IVR CANCEL。転送時にRollBackOrdersをCALLしない為。受注基本ワークがlockしたまま。
  * ①ＳＭＹが付与され使用されていないにも関わらず、IVR側で顧客別SMY情報に対し削除フラグの更新を行っている
  * ②社割使用時、社割でないSMYで更新しようとしてエラーになる。
  *
  * ①ShopMoney使用時のメソッドを顧客コード＝NULLでCALLしていることがある。
  * ②代引いで、OVS限定待（\0受注）の場合、その後IVR追加受注をすると、支払い情報＝NULLになる（Setpaymentinfoを呼んでいない）。
  * ③社割使用時、社割でないSMYで更新しようとしてエラーになる。
  *
  * Revision 1.4  2006/01/19 14:07:56  Ono-T
  * (none)
  *
  * Revision 1.3  2005/12/18 17:05:35  Ono-T
  * (none)
  *
  * Revision 1.2  2005/12/12 14:05:16  Koudate-T
  * R20-2005121222
  * 金額計算エラー対応
  *
  * Revision 1.1  2005/12/12 13:17:01  Ono-T
  * (none)
  *
  * Revision 1.1  2005/09/13 09:53:42  Mochinaga-Y
  * (none)
  *
  * Revision 1.2  2005/09/08 02:45:17  Mochinaga-Y
  * 2005/09/08 12:00 集結。
  *
  * Revision 1.1  2005/09/07 09:22:30  Ono-T
  * (none)
  *
  * Revision 1.1  2005/08/23 07:11:40  Suzuki-H
  * 8/23 12:00 集結
  *
  * Revision 1.2  2005/08/22 13:08:31  Ono-T
  * (none)
  *
  * Revision 1.3  2005/08/16 02:17:18  Ono-T
  * (none)
  *
  * Revision 1.40  2005/07/14 10:48:31  yamada-e
  * (none)
  *
  * Revision 1.38  2005/06/17 02:47:55  yamada-e
  * 障害対応
  *
  * Revision 1.37  2005/06/02 11:55:21  yamada-e
  * (none)
  *
  * Revision 1.4  2005/04/25 01:02:26  yamada-e
  * レビュー指摘事項修正
  *
  * Revision 1.3  2005/04/20 01:09:31  yamada-e
  * 障害修正対応
  *
  * Revision 1.2  2005/04/19 06:13:11  yamada-e
  * CC_Work_Bへ格納変更
  *
  * Revision 1.34  2005/04/12 00:41:47  yamada-e
  * PGレビュー対応
  *
  * Revision 1.33  2005/04/11 00:54:30  yamada-e
  * 障害修正
  *
  * Revision 1.31  2005/04/04 16:32:42  yamada-e
  * IDL実行時ログ出力
  *
  * Revision 1.30  2005/04/04 01:22:29  yamada-e
  * (none)
  *
  * Revision 1.29  2005/03/30 06:37:54  yamada-e
  * 定数追加修正
  *
  * Revision 1.28  2005/03/28 05:10:26  yamada-e
  * (none)
  *
  * Revision 1.24  2005/03/23 00:38:27  yamada-e
  * (none)
  *
  * Revision 1.23  2005/03/22 06:45:55  yamada-e
  * (none)
  *
  * Revision 1.16  2005/03/20 06:01:54  yamada-e
  * (none)
  *
  * Revision 1.12  2005/03/16 13:08:25  yamada-e
  * (none)
  *
  * Revision 1.11  2005/03/15 02:40:18  yamada-e
  * (none)
  *
  * Revision 1.9  2005/03/14 10:36:19  yamada-e
  * (none)
  *
  *
  *****************************************************************************)
end.
