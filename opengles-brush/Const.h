/**
 * Const.h
 *
 * Copyright (c) 2019 CIMTOPS CORPORATION. All rights reserved.
 *
 * アプリケーション共通定数定義用ヘッダ
 */

#import "TimeCalculateType.h"
#import "TimeUnit.h"

//
// OEM 関係の定数（OEMが増えた場合は、ここに定数を追加して、他の定数とは違う値を定義する）
//

#define BUILD_FOR_I_REPORTER 100
#define BUILD_FOR_PAT_REPORT 101
#define BUILD_FOR_ANOTHER_OEM_VERSION 999

// ＊＊＊＊　ビルド対象を定義（上記定数参照）　【ここの末尾の値だけを変更すればよいです】　＊＊
// この直下のコードの define 文で、BUILD_MODE に設定された値で、その後のプリプロセッサの
// 分岐が行われます。
// 上記の定数値(BUILD_FOR_XXXX)を使って、BUILD_MODE の値を定義して下さい。
// 標準は BUILD_FOR_I_REPORTER です。
// ＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
#define BUILD_MODE BUILD_FOR_I_REPORTER

// ビルド対象で定数の定義内容を分岐（上記のdefine内容に応じて分岐する）
#if (BUILD_MODE == BUILD_FOR_PAT_REPORT)

// PatReport の場合の定数定義
static NSString *const UPDATE_APPSTORE_URL = @"itms-apps://itunes.com/apps/patreport";
static NSString *const INTERACTION_URLSCHEME = @"jp.co.forvaltel.patreport";
static NSString *const OPEN_REPORT_URLSCHEME = @"jp.co.forvaltel.patreport.openreport";
static NSString *const CREATE_REPORT_URLSCHEME = @"jp.co.forvaltel.patreport.createreport";
static NSString *const CONFIG_FILE_EXTENSION = @"prcf";
static NSString *const CONNECTION_SETTING_EXTENSION = @"prcs";

// もし他のバージョンが増えたら、以下のように #elif を設けて分岐に入れるようにする
#elif (BUILD_MODE == BUILD_FOR_ANOTHER_OEM_VERSION)

// --- サンプル ---
static NSString *const UPDATE_APPSTORE_URL = @"items-apps://xxxxxxxxxx";
static NSString *const INTERACTION_URLSCHEME = @"xxxxx";
static NSString *const OPEN_REPORT_URLSCHEME = @"xxxxx.openreport";
static NSString *const CREATE_REPORT_URLSCHEME = @"xxxxx.createreport";
static NSString *const CONFIG_FILE_EXTENSION = @"xxcf";
static NSString *const CONNECTION_SETTING_EXTENSION = @"xxcs";

// 標準の i-Reporter の場合の定数定義
#else

static NSString *const IDENTIFIER_DEV = @"jp.conmas.i-Reporter";
static NSString *const IDENTIFIER_BETA = @"jp.co.cimtops.i-ReporterBeta";
static NSString *const IDENTIFIER_STORE = @"jp.co.cimtops.i-Reporter";

static NSString *const APPGROUP_DEV = @"group.758D54543R.jp.conmas.i-Reporter";
static NSString *const APPGROUP_BETA = @"group.jp.co.cimtops.i-Reporter";
static NSString *const APPGROUP_STORE = @"group.jp.co.cimtops.i-Reporter";

static NSString *const APPGROUP_LIBRARY_PATH = @"Library/Caches";

static NSString *const UPDATE_APPSTORE_URL = @"itms-apps://itunes.com/apps/conmasireporter";
static NSString *const INTERACTION_URLSCHEME = @"jp.co.cimtops.ireporter";
static NSString *const OPEN_REPORT_URLSCHEME = @"jp.co.cimtops.ireporter.openreport";
static NSString *const CREATE_REPORT_URLSCHEME = @"jp.co.cimtops.ireporter.createreport";
static NSString *const LOGOUT_URLSCHEME = @"jp.co.cimtops.ireporter.logout";
static NSString *const SETCLUSTER_URLSCHEME = @"jp.co.cimtops.ireporter.setcluster";
static NSString *const DOWNLOAD_REPORT_URLSCHEME = @"jp.co.cimtops.ireporter.downloadreport";
static NSString *const DOWNLOAD_DEFINITION_URLSCHEME = @"jp.co.cimtops.ireporter.downloaddefinition";
static NSString *const OPEN_FILE_FD_URLSCHEME = @"jp.co.cimtops.i-reporter-fd.openfile";
static NSString *const CONFIG_FILE_EXTENSION = @"ircf";
static NSString *const IRFZ_FILE_EXTENSION = @"irfz";
static NSString *const CONNECTION_SETTING_EXTENSION = @"ircs";
static NSString *const OPEN_PDF_URLSCHEME = @"jp.co.cimtops.ireporter.open-fd-report";

#endif

static const float CURSOR_WIDTH = 4.0;// カーソル幅
static const float BIG_CIRCLE_SIZE = 60.0;
static const float HEIGHT_OF_TOOLBAR = 44.0;

typedef NS_ENUM(NSInteger, DominantHandType) {
    LEFT_HANDED = 0,
    RIGHT_HANDED
};

// Scheduler用
static const float MOVED_DISPLAY_RANGE = 60.0;//　移動した後、描画する範囲
static const float START_X = 0.0;// 文字スタート位置

static const float NOTE_LINE_WIDTH = 1.0;//　ノート罫線幅

// プレビュー画像用最大サイズ
static const float PREVIEW_IMAGE_MAX_SIZE = 350.0f;

// 連携用
typedef NS_ENUM(NSInteger, CooperationType) {
    NoCooperationType = 0,// Cooperation=false;CoopEdit=false;
    EditableCooperationType,// Cooperation=true;CoopEdit=true;
    UneditableCooperationType,// Cooperation=true;CoopEdit=false;
};

// HorizontalLine/HorizontalDoubleのinset
static const CGFloat X_INSET = 3.0;

// チェッククラスタの表示スタイル
typedef NS_ENUM(NSInteger, CheckStyle) {
    CheckStyleCircle,
    CheckStyleOval,
    CheckStyleCheck,
    CheckStyleCheckBox,
    CheckStyleFillCircle,
    CheckStyleFillOval,
    CheckStyleFillRect,
    CheckStyleNone, // なし
    CheckStyleHorizontalLine, // 横線
    CheckStyleHorizontalDouble, // 横線(２重)
    CheckStyleCross, // ×
    CheckStyleStretchCross // ×（横長）
};

typedef NS_ENUM(NSInteger, CheckClusterRawChecked) {
    CheckClusterRawCheckedUndefined = -1,
    CheckClusterRawCheckedEmpty,
    CheckClusterRawCheckedFalse,
    CheckClusterRawCheckedTrue
};

// テキストベースのクラスタ用
typedef NS_ENUM(NSInteger, FontWeight) {
    FontWeightNormal,
    FontWeightBold,
    FontWeightItalic
};

typedef NS_ENUM(NSInteger, TextVerticalAlignment) {
    Alignment_Undefined = -1,
    Alignment_Top,
    Alignment_Center,
    Alignment_Bottom
};


// 帳票が使用している計算式
typedef NS_ENUM(NSInteger, CalculationType) {
    CalculationTypeUndefined = -99, //未チェック状態
    CalculationTypeNoUse = -1, //計算式使用していない
    CalculationTypeOldCalculationCluster = 1,
    CalculationTypeNewCalculationCluster = 2
};

typedef NS_ENUM(NSInteger, GatewaySupport) {
    GatewaySupportUndifined = -1, // 古い定義設定等で指定なし
    GatewaySupportDisable, // Designerにて明示的に使用しない
    GatewaySupportEnable, // Designerにて明示的に使用するを指定
};

typedef NS_ENUM (NSInteger, TemporarySaveVersion) {
    TemporarySaveVersion1,
    TemporarySaveVersion2
};

typedef NS_ENUM(NSInteger, Direction) {
    DirectionNone = 0,
    DirectionTop = 1,
    DirectionTopLeft = 2,
    DirectionLeft = 3,
    DirectionBottomLeft = 4,
    DirectionBottom = 5,
    DirectionBottomRight = 6,
    DirectionRight = 7,
    DirectionTopRight = 8
};

typedef NS_ENUM(NSInteger, Shape) {
    ShapeCircle = 0,
    ShapeTriangle = 1
};

typedef NS_ENUM(NSInteger, AutoNumberMode) {
    AutoNumberModeOff = 0,
    AutoNumberModeOn = 1
};

// 必須チェック結果
typedef NS_ENUM(NSInteger, ValidateCheckResult) {
    ValidateCheckNG = 0,                // 現在のユーザーで入力できる必須項目がある
    ValidateCheckOKOnlyCurrentUser = 1, // 現在のユーザーの入力は完了だが別ユーザーで入力できる必須項目がある
    ValidateCheckAllOK = 2              // 必須入力がすべて埋まっているOK
};

// Numericクラスターの入力方法設定
typedef NS_ENUM(NSInteger, CounterMode) {
    CounterModeNone = 0,
    CounterModeRight2Button,
    CounterModeLeftRightButton,
};

// Select/MultiSelectの表示項目
typedef NS_ENUM(NSInteger, DisplayElementType) {
    DisplayTypeItems,
    DisplayTypeLables,
    DisplayTypeItemsAndLabels,
};

typedef NS_ENUM(NSInteger, SelectKeyboardMode) {
    Keyboard_Disable,// デフォルト（キーボード入力なし）
    Keyboard_Additable,// 項目追加
    Keyboard_Editable// 項目編集可能
};

typedef NS_ENUM(NSInteger, KeyboardType) {
    KeyboardTypeCustomized = 0,
    KeyboardTypeSystem,
    KeyboardTypeExternalDevice // #20272 外部機器でのみ入力
};

typedef NS_ENUM(NSInteger, FontPriority) {
    Priority_Lines,// 行指定
    Priority_AutoLines,// 折り返し、改行ありで全表示
    Priority_1Line// 折り返し、改行なしで全表示
};

typedef NS_ENUM(NSInteger, Punctuation) {
    Punctuation_Off, // カンマ区切りしない
    Punctuation_On, // カンマ区切り
    Punctuation_Return // 改行区切り
};

typedef NS_ENUM(NSInteger, ImageSizeMode) {
    ImageSize_NotDefined = -1,
    ImageSize_ClusterSize = 0,// Imageクラスタ、FreeTextはクラスタフィット、FreeDrawは画面キャプチャサイズ
    ImageSize_Original = 1,// オリジナル
    ImageSize_Custom = 2 // カスタム（ImageSizeパラメータで指定）
};

typedef NS_ENUM(NSInteger, MinimumEditSizeMode) {
    MinimumEditSizeModeNotDefined = -1, // 定義なし
    MinimumEditSizeModeCluster = 0      // cluster側の値使用
};

// Date/Timeの入力方式
typedef NS_ENUM(NSInteger, DateTimeInputType) {
    InputTypeManual,
    InputTypeAutoOnSending,// メール送信時、編集中保存、完了保存時に自動入力
    InputTypeAutoOnTapping,// タップ時に自動入力
    InputTypeAutoOnEditing // 編集開始時自動入力
};

// FirstOnlyの拡張仕様
typedef NS_ENUM(NSInteger, FirstOnlyType) {
    FirstOnly_Old_No,   // 旧BOOL値 FirstOnly = NOに対応 今後はこれが設定されることはない 既存のデータとの互換性のため残す
    FirstOnly_Yes,      // 旧BOOL値 FirstOnly = YESに対応
    FirstOnly_New_No    // 「期待通りに動作する」NO
};

typedef NS_ENUM(NSInteger, LoginUserInputType) {
    LoginUserInputOnEditing, // 編集開始時自動入力
    LoginUserInputOnSending,// 編集中保存、完了保存時に自動入力
    LoginUserInputOnTapping// タップ時に自動入力
} ;

// NumberHoursの入力方法
typedef NS_ENUM(NSInteger, NumberHoursInputType) {
    NumberHoursInputTypeNumeric,// 数値入力
    NumberHoursInputTypeFormatted,// フォーマット入力
};

// フォーマット(NumberHoursInputTypeFormattedの時)
typedef NS_ENUM(NSInteger, NumberHoursFormat) {
    NumberHoursFormatJapanese,// ○○時間 ○○分
    NumberHoursFormatColon,// ○○:○○
    NumberHoursFormatEnglish,// ○○h ○○m
};

// 計算クラスタのValidationチェック
typedef NS_ENUM(NSInteger, CalcValidationType) {
    CalcValidationSignal,// ×印 保存可能
    CalcValidationStrict// 警告マークと結果エラーの吹き出しを一定時間で消す 保存不可能
};

// 承認クラスター 保存タイプ
typedef NS_ENUM(NSInteger, SaveRequest) {
    SaveRequestLocal = 0,
    SaveRequestServer = 1,
    SaveRequestServerContinue = 2
};

// 写真に入れる日付タイプ
typedef NS_ENUM(NSInteger, PhotoDateType) {
    PhotoDateTypeNone = 0,
    PhotoDateTypeDateTime = 1,
    PhotoDateTypeDate = 2
};

// Error Domain
static NSString * const kCustomMasterErrorDomain = @"jp.co.cimtops.ireporter.CustomMasterErrorDomain";

// TextCluster
static const CGFloat MAX_FONT_SIZE = 120;
static const CGFloat MIN_FONT_SIZE = 4;
static const int FONT_SIZE_NOT_DEFINED = 0;
static NSString *const DEFAULT_FONT_NAME = @"HiraKakuProN-W3";
static const CGFloat BASELINE_OFFSET = 12.0f;

// 更新通知用
static NSString *const kNeedUpdateViewNotification = @"REPORT INPUT VIEW IS NEEDED TO UPDATE NOTIFICATION";

// ポップアップサムネイル
static const CGFloat SHEET_THUMBNAIL_ITEM_WIDTH = 135.0f;// サムネイル画像幅
static const CGFloat SHEET_THUMBNAIL_ITEM_HEIGHT = 90.0f;// サムネイル画像高さ
static const CGFloat SHEET_THUMBNAIL_HORIZONTAL_MARGIN = 15.0f;// 水平方向マージン
static const CGFloat SHEET_THUMBNAIL_VERTICAL_MARGIN = 10.0f;// 垂直方向マージン
static const CGFloat SHEET_THUMBNAIL_WIDTH = SHEET_THUMBNAIL_ITEM_WIDTH + SHEET_THUMBNAIL_HORIZONTAL_MARGIN;    // サムネイル画像幅+水平方向マージン

// ライブラリリスト幅保存用
static NSString *const kNeedUpdateLibraryExpandNotification = @"Library List Expanded Notification";

// コメント表示サイズ
static const CGFloat COMMENT_SIZE = 12.0f;

static  NSString * const CONTINUATION_SAVE_SERVER_VERSION = @"4.2.4775";

typedef NS_ENUM(NSInteger, DividedCopyDelimiterType) {
    DelimiterType_Comma, // カンマ区切り
    DelimiterType_Tab, // タブ区切り
    DelimiterType_Bytes, // 指定バイト数区切り
    DelimiterType_GS1_128 // GS1-128のアプリケーションID区切り
};

typedef NS_ENUM(NSInteger, GS1_128_Separator_InputMethod) { // 設定画面で区切り文字をアスキーコードで入力するか、普通に文字で入力するか
    InputMethod_String,
    InputMethod_ASC2
};

//iPhone版での編集モード設定
typedef NS_ENUM(NSInteger, MobileEditType) {
    TYPE_SELECT,
    TYPE_LIST,
    TYPE_NORMAL
};

//(iPhone版のみ)現在の帳票の編集モード
typedef NS_ENUM(NSInteger, ReportDisplayMode) {
    ReportDisplayModeNormal = 0,
    ReportDisplayModeList,
};

// 記入不要表示タイプ
typedef NS_ENUM(NSInteger, NoNeedToFillOutType) {
    NoNeedToFillOutTypeUnknown = -1,
    NoNeedToFillOutTypeHyphen = 0, // ハイフン
    NoNeedToFillOutTypeDiagonal1,  // 斜線1(右上から左下)
    NoNeedToFillOutTypeDiagonal2,  // 斜線2(左上から右下)
    NoNeedToFillOutTypeCross,      // クロス
    NoNeedToFillOutTypeLine1,      // ライン1(幅いっぱいの横線1本)
    NoNeedToFillOutTypeLine2,      // ライン2(幅いっぱいの横線2本)
    NoNeedToFillOutTypeTextNA,     // テキスト / N/A
    NoNeedToFillOutTypeTextHyphen  // テキスト / ハイフン
};

// 記入不要表示対象クラスター
typedef NS_ENUM(NSInteger, NoNeedToFillOutCluster) {
    NoNeedToFillOutClusterUnknown = -1,
    NoNeedToFillOutClusterAll = 0,     // 未入力全部
    NoNeedToFillOutClusterRequired,    // 必須で未入力
};

// 記入不要表示 ネットワークの設定
typedef NS_ENUM(NSInteger, NoNeedToFillOutNetworkType) {
    NoNeedToFillOutNetworkTypeNotSet = 0,   // 行わない
    NoNeedToFillOutNetworkTypeSetNext,      // 先行クラスター入力時に後続クラスターに記入不要表示する
    NoNeedToFillOutNetworkTypeSetTheOther   // 先行/後行クラスター入力時に残りの片方を記入不要表示する
};

// 帳票コピー方法の選択
// 0: 同一リビジョンの定義から作成する(規定値)
// 1: 最新の定義から作成する
// 2: 上記をコピー時に選択する
typedef NS_ENUM(NSInteger, ReportCopyType) {
    ReportCopyTypeCurrent = 0,
    ReportCopyTypeLatest = 1,
    ReportCopyTypeChoose = 2,
    ReportCopyTypeNone = 9
};

// ピン打ち
typedef NS_ENUM(NSInteger, PortraitDisplayPosition) {
    PortraitDisplayPositionUpSide = 0,
    PortraitDisplayPositionBottom = 1,
    PortraitDisplayPositionNone = 9
};

typedef NS_ENUM(NSInteger, LandscapeDisplayPosition) {
    LandscapeDisplayPositionRight = 0,
    LandscapeDisplayPositionLeft = 1,
    LandscapeDisplayPositionNone = 9
};

typedef NS_ENUM(NSInteger, NumberType) {
    NumberTypeNumberOnly = 0,
    NumberTypeEncircledNumber = 1
};

typedef NS_ENUM(NSInteger, PinReplacementMode) {
    PinReplacementModeNone = 0,
    PinReplacementModePinNumber = 1,
    PinReplacementModePinConnectPoint = 2
};

typedef NS_ENUM(int, PinReportType) {
    PinReportTypeNormal = 0,
    PinReportTypeJournal = 1
};

// #28474 トグル選択を文字列と扱う計算式での参照モード
typedef NS_ENUM(NSInteger, UseCalculateToggleStringValueMode) {
    UseCalculateToggleStartingValueModeLabel = 0,
    UseCalculateToggleStartingValueModeValue = 1
};

// フリードロービュー解像度
typedef NS_ENUM(NSInteger, FreeDrawViewResolution) {
    FreeDrawViewResolutionUndefined = -1,
    FreeDrawViewResolutionDefault = 0,
    FreeDrawViewResolutionConformWholeImageResolution = 1
};

// ネットワーク後続クリアモード #28098
typedef NS_ENUM(NSInteger, LockClusterNetworkClearMode) {
    lockClusterNetworkClearModeNotClear = 0,
    lockClusterNetworkClearModeClear = 1
};

// 必須チェック
typedef NS_ENUM(NSInteger, RequiredCheckMode) {
    RequiredCheckModeCompleteOnly = 0,
    RequiredCheckModeAlways = 1
};

typedef NS_ENUM(NSInteger, RequiredSaveMode) {
    RequiredSaveModeSelectable = 0,
    RequiredSaveModeNone = 1
};

// 画像消失問題対応
// メモリ上に画像を保持するか
typedef NS_ENUM(NSInteger, ImageSaveMode) {
    ImageSaveModeImage = 0, // 保持しない（デフォルト）
    ImageSaveModeBinary = 1 // 保持する
};

typedef NS_ENUM(NSInteger, LogOutputMode) {
    LogOutputModeDisable = 0,   // ログ出力しない（デフォルト）
    LogOutputModeEnable = 1     // ログ出力する
};
typedef NS_ENUM(NSInteger, LogSendMode) {
    LogSendModeDisable = 0,   // ログを自動送信しないで手動送信（デフォルト）
    LogSendModeEnable = 1     // ログを自動送信する（ログイン時）
};

typedef NS_ENUM(NSInteger, LogSaveMode) {
    LogSaveModeDisable = 0,   // ログを出力しない（デフォルト）
    LogSaveModeEnable = 1     // ログを出力する
};

typedef NS_ENUM(NSInteger, BackupImageSendMode) {
    BackupImageSendModeDisable = 0,   // バックアップした画像を自動送信しないで手動送信（デフォルト）
    BackupImageSendModeEnable = 1     // バックアップした画像を自動送信する
};

typedef NS_ENUM(NSInteger, BackupImageSaveMode) {
    BackupImageSaveModeDisable = 0,   // バックアップ画像を出力しない（デフォルト）
    BackupImageSaveModeEnable = 1     // バックアップ画像を出力する
};

typedef NS_ENUM(NSInteger, AutoDownloadMode) {
    AutoDownloadModeDisable = 0,   // 自動帳票ダウンロードしない（デフォルト）
    AutoDownloadModeEnable = 1     // 自動帳票ダウンロードする
};

typedef NS_ENUM(NSInteger, AutoDownloadTiming) {
    AutoDownloadTimingLoginOnly = 0,   // ログイン画面閉じた時のみ（デフォルト）
    AutoDownloadTimingLoginAndFinishedReport = 1     // ログイン画面閉じた時と帳票保存時の終了時
};

typedef NS_ENUM(NSInteger, AutoDownloadAutoOpenReport) {
    AutoDownloadAutoOpenReportDisable = 0,   // 自動帳票ダウンロード後、自動で帳票の起動をしない（デフォルト）
    AutoDownloadAutoOpenReportEnable = 1     // 自動帳票ダウンロード後、自動で帳票の起動（予定が入っているもので一番予定の値が小さいもの）をする
};

typedef NS_ENUM(NSInteger, NoNeedToFillOutSystemMode) {
    NoNeedToFillOutSystemModeDefault = -1, // 定義に従う（デフォルト）
    NoNeedToFillOutSystemModeNetwork = 0, // ネットワーク優先
    NoNeedToFillOutSystemModeLastOperation = 1, // 操作優先
};

typedef NS_ENUM(NSInteger, ResponseMessageMode) {
    ResponseMessageModeInvalid = 0,
    ResponseMessageModeValid = 1
};

typedef NS_ENUM(NSInteger, ForceUpdateMode) {
    ForceUpdateModeDoNothing = 0,
    ForceUpdateModeForceUpdate = 1,
    ForceUpdateModeUserSelect = 2,
    ForceUpdateModeWarning = 3
};

typedef NS_ENUM(NSInteger, NoNeedToFillOutMode) {
    NoNeedToFillOutModeNetwork = 0, // ネットワーク優先
    NoNeedToFillOutModeLastOperation = 1 // 操作優先
};

typedef NS_ENUM(NSInteger, NoNeedToFillOutDocumentMode) {
    NoNeedToFillOutDocumentModeUnknown = -999, // 未定義（旧帳票定義）
    NoNeedToFillOutDocumentModeNetwork = 0, // ネットワーク優先
    NoNeedToFillOutDocumentModeLastOperation = 1 // 操作優先
};

typedef NS_ENUM(NSInteger, InternalImageSizeMode) {
    InternalImageSizeModeBugMode = 0,
    InternalImageSizeModeBugFixMode = 1
};
// 録音クラスターのデータ形式M4A形式
typedef NS_ENUM(NSInteger, AudioRecordingFileFormatType) {
    AudioRecordingFileFormatTypeUndefined = -1,
    AudioRecordingFileFormatTypeM4A = 0,  // M4A形式
    AudioRecordingFileFormatTypeWAV  // WAV形式
};

// マスター選択クラスターのGatewayMode
typedef NS_ENUM(NSInteger, GatewayMode) {
    GatewayModeUndefined = -1,
    GatewayModeNoUse = 0,  // 通常のカスタムマスター形式（GatewayMode使用しない）
    GatewayModeUse = 1  // Gatewayを使用したカスタムマスター形式（GatewayMode使用する）
};

typedef NS_OPTIONS(NSUInteger, LogMode) {
    LogModeNormal = 1 << 0,   // 通常のログ出力
    LogModeHigh = 1 << 1     // XMLのレスポンスエラー時 + IoTGateway通信時のJson + PDF共有時のバックアップファイル 出力};
};

typedef NS_ENUM(NSInteger, MoveInputClusterPositionMode) {
    MoveInputClusterPositionOFF = 0,
    MoveInputClusterPositionON = 1
};

typedef NS_ENUM(NSInteger, LegacySavingMethodMode) {
    LegacySavingMethodModeOFF = 0,
    LegacySavingMethodModeON = 1
};

typedef NS_ENUM(NSInteger,DisplayClusterNameAtInputViewMode) {
    DisplayClusterNameAtInputViewOFF = 0,
    DisplayClusterNameAtInputViewON = 1
} ;

typedef NS_ENUM(NSInteger, CalclateThresholdMode) {
    CalclateThresholdModeDisplayValue = 0,
    CalclateThresholdModeCalculationResult = 1
} ;

static NSString * const DeleteLocalDataNotification = @"DeleteLocalDataNotification";
static const CGFloat kCalloutAnchorRootHalfWidth = 10.0f;
static NSString * const clusterSectionHeaderViewUpdate = @"UPDATE_HEADER";
// Color Picker
static const CGFloat COLOR_PICKER_HEIGHT = 219;
static const CGFloat COLOR_PICKER_WIDTH = 317;
static const CGFloat COLOR_PICKER_TITLE_HEIGHT = 38;

static NSString * const COREDATA_STORE_FILENAME = @"i-Reporter.sql";

static NSString * const BASIC_MENU_PROPERTY_KEY = @"BasicMenuProperty";
static NSString * const CUSTOMIZE_TYPE_KEY = @"CustomizeType";
static NSString * const VALUE = @"VALUE";
static NSString * const VALUE_D = @"VALUE_D";
static NSString * const VALUE_DN = @"VALUE_DN";
static NSString * const ALIGN = @"ALIGN";
static NSString * const LINES = @"LINES";
static NSString * const WEIGHT = @"WEIGHT";
static NSString * const COLOR = @"COLOR";
static NSString * const FONT_NAME = @"FONT NAME";
static NSString * const FONT_SIZE = @"FONT SIZE";
static NSString * const TEXT = @"TEXT";
static NSString * const VALUE_SAVED_TO_SERVER = @"VALUE SAVED TO SERVER";
static NSString * const VALUE_SAVED_TO_SERVER_DN = @"VALUE SAVED TO SERVER DN";
static NSString * const TOP_LEFT_KEY = @"TOP LEFT KEY";
static NSString * const TOP_RIGHT_KEY = @"TOP RIGHT KEY";
static NSString * const BOTTOM_LEFT_KEY = @"BOTTOM LEFT KEY";
static NSString * const BOTTOM_RIGHT_KEY = @"BOTTOM RIGHT KEY";
static NSString * const LINE_WIDTH_KEY = @"LINE WIDTH KEY";
static NSString * const ENCODING_AUTO = @"AUTO";
static NSString * const ENCODING_SHIFT_JIS = @"SJIS";
static NSString * const ENCODING_UTF8 = @"UTF-8";
static NSString * const TARGET_CLUSTERS = @"targetClusters";
static NSString * const F_TABLE_ID = @"tableId";
static NSString * const F_RECORD_ID = @"recordId";
static NSString * const F_ACTION = @"action";
static NSString * const F_UPDATE_TIME = @"updateTime";
static NSString * const VERTICAL_ALIGNMENT = @"VERTICAL ALIGNMENT";
static NSString * const TERMINATION_CODE = @"TERMINATION CODE";
static NSString * const KEY_DEF_TOP_ID = @"defTopId";
static NSString * const KEY_DEF_TOP_ORG = @"defTopOrg";
static NSString * const KEY_LAST_UPDATE_DATE = @"lastUpdateDate";
static NSString * const KEY_USE_DATE_TYPE = @"useDateType";
static NSString * const KEY_DELETED = @"deleted";
static NSString * const WIDTH = @"Width";
static NSString * const START_POINT = @"Start Point";
static NSString * const END_POINT = @"End Point";
static NSString * const RECT_KEY = @"RECT";
static NSString * const KEY_REP_TOP_ID = @"repTopId";
static NSString * const KEY_ERROR_REMARK_APPLICANT_LOCK = @"applicantLock";
static NSString * const KEY_ERROR_REMARK_LOCK_CLUSTER = @"lockCluster";
static NSString * const KEY_ERROR_REMARK_AUTO_NUMBER = @"autoNumber";
static NSString * const LAST_EDITED_SIZE = @"LAST EDITED SIZE";
static NSString * const LENGTH_SAVED_TO_SERVER = @"LENGTH_SAVED_TO_SERVER";
static NSString * const FREE_DRAW_MINIMUM_EDIT_SIZE = @"MinimumEditSize";
static NSString * const ENABLE_SHORTCUT = @"ENABLE SHORTCUT";
static NSString * const CHUNK_ARRAY = @"CHUNK ARRAY";
static NSString * const ENABLE_PHOTODATE = @"ENABLE PHOTODATE";
static NSString * const PHOTODATE_TYPE = @"PHOTODATE TYPE";
static NSString * const XML_DATETIME_FORMAT = @"yyyy/MM/dd HH:mm:ss";
static NSString * const ALPHANUMERIC_SET = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\n";
static NSString * const NUMERIC_SET = @"0123456789";
static NSString * const FUNCTION = @"FUNCTION";
static NSString * const DECIMAL = @"DECIMAL";
static NSString * const TRUNCATE_ZERO_MODE = @"TRUNCATE_ZERO_MODE";
static NSString * const VISIBLE = @"Visible";
static NSString * const NZ = @"NZ";
static NSString * const COMMA = @"COMMA";
static NSString * const PREFIX = @"PREFIX";
static NSString * const SUFFIX = @"SUFFIX";
static NSString * const SHEET_NO = @"sheetNo";
static NSString * const SHEET_WIDTH = @"width";
static NSString * const SHEET_HEIGHT = @"height";
static NSString * const SHEET_SIZE = @"sheetSize";
static NSString * const IMAGE_KEY = @"IMAGE KEY";
static NSString * const MINIMUM = @"MINIMUM";
static NSString * const MINIMUM_D = @"MINIMUM_D";
static NSString * const MINIMUM_DN = @"MINIMUM_DN";
static NSString * const MAXIMUM = @"MAXIMUM";
static NSString * const MAXIMUM_D = @"MAXIMUM_D";
static NSString * const MAXIMUM_DN = @"MAXIMUM_DN";
static NSString * const VARIABLE_LIMIT_REFERANCE_OBJECT = @"VARIABLE_LIMIT_REFERANCE_OBJECT";

//しきい値変動機能
static NSString * const MAXIMUM_CLUSTER = @"MAXIMUM CLUSTER";
static NSString * const MINIMUM_CLUSTER = @"MINIMUM CLUSTER";
static NSString * const ALLOWMIN_CLUSTER = @"ALLOWMIN CLUSTER";
static NSString * const ALLOWMAX_CLUSTER = @"ALLOWMAX CLUSTER";

static NSString * const ALLOW_VALUE_MODE = @"ALLOW VALUE MODE";
static NSString * const ALLOW_MIN_BACKGROUND_COLOR = @"ALLOW MIN BACKGROUND COLOR";
static NSString * const ALLOW_MIN_FONT_COLOR = @"ALLOW MIN FONT COLOR";
static NSString * const ALLOW_MIN_FONT_NAME = @"ALLOW MIN FONT NAME";
static NSString * const ALLOW_MIN_FONT_SIZE = @"ALLOW MIN FONT SIZE";
static NSString * const ALLOW_MIN_FONT_WEIGHT = @"ALLOW MIN FONT WEIGHT";
static NSString * const ALLOW_MIN_INVALID_MESSAGE = @"ALLOW MIN INVALID MESSAGE";
static NSString * const ALLOW_MIN_VALUE = @"ALLOW MIN VALUE";
static NSString * const ALLOW_MIN_VALUE_DN = @"ALLOW MIN VALUE DN";
static NSString * const ALLOW_MAX_BACKGROUND_COLOR = @"ALLOW MAX BACKGROUND COLOR";
static NSString * const ALLOW_MAX_FONT_COLOR = @"ALLOW MAX FONT COLOR";
static NSString * const ALLOW_MAX_FONT_NAME = @"ALLOW MAX FONT NAME";
static NSString * const ALLOW_MAX_FONT_SIZE = @"ALLOW MAX FONT SIZE";
static NSString * const ALLOW_MAX_FONT_WEIGHT = @"ALLOW MAX FONT WEIGHT";
static NSString * const ALLOW_MAX_INVALID_MESSAGE = @"ALLOW MAX INVALID MESSAGE";
static NSString * const ALLOW_MAX_VALUE = @"ALLOW MAX VALUE";
static NSString * const ALLOW_MAX_VALUE_DN = @"ALLOW MAX VALUE DN";
static NSString * const ALLOW_MODE_ON_CLUSTER = @"ALLOW MODE ON CLUSTER";
static NSString * const ALLOW_MIN_CAN_USE = @"ALLOW MIN CAN USE";
static NSString * const ALLOW_MAX_CAN_USE = @"ALLOW MAX CAN USE";
static NSString * const MIN_INVALID_MESSAGE = @"MIN INVALID MESSAGE";
static NSString * const MAX_INVALID_MESSAGE = @"MAX INVALID MESSAGE";
static NSString * const AUTO_NUMBER = @"AUTO NUMBER";
static NSString * const INPUT_RESTRICTION = @"INPUT RESTRICTION";
static NSString * const PROHIBITED_CHARACTERS = @"PROHIBITED CHARS";
static NSString * const MAX_LENGTH = @"MAX LENGTH";
static NSString * const PADDING_DIRECTION = @"PADDING DIRECTION";
static NSString * const PADDING_CHARACTER = @"PADDING CHARACTER";
static NSString * const BACKGROUND_IMAGE = @"backgroundImage";
static NSString * const THUMBNAIL = @"thumbnail";
static NSString * const REMARKS_NAME1 = @"remarksName1";
static NSString * const REMARKS_NAME2 = @"remarksName2";
static NSString * const REMARKS_NAME3 = @"remarksName3";
static NSString * const REMARKS_NAME4 = @"remarksName4";
static NSString * const REMARKS_NAME5 = @"remarksName5";
static NSString * const REMARKS_NAME6 = @"remarksName6";
static NSString * const REMARKS_NAME7 = @"remarksName7";
static NSString * const REMARKS_NAME8 = @"remarksName8";
static NSString * const REMARKS_NAME9 = @"remarksName9";
static NSString * const REMARKS_NAME10 = @"remarksName10";
static NSString * const REMARKS_VALUE1 = @"remarksValue1";
static NSString * const REMARKS_VALUE2 = @"remarksValue2";
static NSString * const REMARKS_VALUE3 = @"remarksValue3";
static NSString * const REMARKS_VALUE4 = @"remarksValue4";
static NSString * const REMARKS_VALUE5 = @"remarksValue5";
static NSString * const REMARKS_VALUE6 = @"remarksValue6";
static NSString * const REMARKS_VALUE7 = @"remarksValue7";
static NSString * const REMARKS_VALUE8 = @"remarksValue8";
static NSString * const REMARKS_VALUE9 = @"remarksValue9";
static NSString * const REMARKS_VALUE10 = @"remarksValue10";
static NSString * const EDIT_STATUS = @"editStatus";
static NSString * const INPUT_TYPE = @"INPUT TYPE";
static NSString * const GROUP_ID = @"GROUP ID";
static NSString * const VALIDATION = @"VALIDATION";
static NSString * const PARAM_WORD = @"word";
static NSString * const PRIMARY_FONT_SIZE = @"PRIMARY FONT SIZE";
static NSString * const CANUSE_CUSTOMKEYPAD = @"CANUSE_CUSTOM_KEYPAD";
static NSString * const CANUSE_CUSTOMNUMPAD = @"CANUSE_CUSTOM_NUMPAD";
static NSString * const PERCENT = @"PERCENT";
static NSString * const DEFAULT_INPUT = @"DEFAULT INPUT";
static NSString * const FIRST_ONLY = @"FIRST ONLY";
static NSString * const CONFIRM_DIALOG = @"CONFIRM DIALOG";
static NSString * const DISPLAY_TYPE = @"DISPLAY_TYPE";
static NSString * const FONT_PRIORITY = @"FONT PRIORITY";
static NSString * const KEYBOARD_VALUE = @"KEYBOARD VALUE";
static NSString * const KEYBOARD_MODE = @"KEYBOARD MODE";
static NSString * const DEFAULT_SELECTED = @"DEFAULT SELECTED";
static NSString * const SELECTED_ITEM = @"SELECTED ITEM";
static NSString * const ITEMS = @"ITEMS";
static NSString * const IS_NUMERIC_KEY = @"IS NUMERIC";
static NSString * const USE_SELECTGATEWAY = @"USE SELECTGATEWAY";
static NSString * const FORMAT_STRING = @"FORMAT STRING";
static NSString * const MANUAL_EDITABLE = @"MANUAL EDITABLE";
static NSString * const FIRST_ONLY_TYPE = @"FIRST ONLY TYPE";
static NSString * const KEY_LOCAL_FILE_ID = @"localFileId";
static NSString * const KEY_STATUS = @"status";
static NSString * const KEY_DISPLAY_NUMBER = @"displayNumber";
static NSString * const PARAM_TOPID = @"topId";
static NSString * const CLEAR_OPTION = @"ClearOption";

static NSString * const LOGIN_RESULT_REMARK = @"LoginResultRemark";
static NSString * const LOGIN_RESULT_CUSTOM_MASTER_AUTO_UPDATE = @"LoginResultCustomMasterAutoUpdate";
static NSString * const LOGIN_RESULT_CUSTOM_MASTER_UPDATE_LABEL = @"LoginResultCustomMasterLastUpdateLabel";
static NSString * const LOGIN_RESULT_CUSTOM_MASTER_UPDATE_MASTER = @"LoginResultCustomMasterLastUpdateMaster";
static NSString * const LOGIN_RESULT_CUSTOM_MENU_VERSION = @"LoginResultCustomMenuVersion";
static NSString * const LOGIN_RESULT_RESPONSE_MESSAGE_MODE = @"LoginResultResponseMessageMode";
static NSString * const LOGIN_RESULT_CODE = @"LoginResultCode";
static NSString * const LOGIN_RESULT_SERVER_VERSION = @"LoginResultServerVersion";
static NSString * const LOGIN_RESULT_ENABLE_PASSWORD_CHANGE = @"LoginResultEnablePasswordChange";
static NSString * const LOGIN_RESULT_PASSWORD_EXPIRED = @"LoginResultPasswordExpired";
static NSString * const LOGIN_RESULT_WEAK_INCLUDE_MIXED_CASE = @"LoginResultWeakIncludeMixedCase";
static NSString * const LOGIN_RESULT_WEAK_INCLUDE_NUMBERS = @"LoginResultWeakIncludeNumbers";
static NSString * const LOGIN_RESULT_WEAK_INCLUDE_SYMBOLS = @"LoginResultWeakIncludeSymbols";
static NSString * const LOGIN_RESULT_WEAK_PASSWORD_LENGTH = @"LoginResultWeakPasswordLength";
static NSString * const LOGIN_RESULT_WEAK_ALLOW_SAME_PASSWORD = @"LoginResultWeakAllowSamePassword";
static NSString * const LOGIN_RESULT_WEAK_SIMILAR_PASSWORD = @"LoginResultWeakSimilarPassword";
static NSString * const LOGIN_RESULT_INTERNAL_IMAGE_FORMAT = @"LoginResultInternalImageFormat";
static NSString * const LOGIN_RESULT_AMI_VOICE_ENABLE = @"LoginResultAmiVoiceEnable";
static NSString * const LOGIN_RESULT_AMI_VOICE_EXPIRE = @"LoginResultAmiVoiceExpire";
static NSString * const LOGIN_RESULT_FUNCTION_ID_SEARCH = @"LoginResultFunctionIdSearch";
static NSString * const LOGIN_RESULT_NO_NEED_TO_FILL_OUT_MODE = @"LoginResultNoNeedToFillOutMode";
static NSString * const LOGIN_RESULT_USE_BIOMETRICS = @"useBiometrics";
static NSString * const LOGIN_RESULT_INTERNAL_IMAGE_SIZE = @"LoginResultInternalImageSize";
static NSString * const CALCULATE_THRESHOLD_TYPE_IOS = @"calculateThresholdTypeIOS";
// 画像消失問題対応
static NSString * const IMAGE_SAVE_MODE = @"ImageSaveMode"; // 画像をメモリ上に保持するか
static NSString * const LOG_OUTPUT_MODE = @"logOutputMode"; // ログ出力モード
static NSString * const LOG_SAVE_MODE = @"logSaveMode"; // ログ取得モード
static NSString * const LOG_SAVE_DAYS = @"logSaveDays"; // ログ保持日数
static NSString * const LOG_SEND_MODE = @"logSendMode"; // ログ自動送信設定
static NSString * const BACKUP_IMAGE_SAVE_MODE = @"backupImageSaveMode"; // 画像バックアップモード
static NSString * const BACKUP_IMAGE_SAVE_DAYS = @"backupImageSaveDays"; // 画像バックアップ日数
static NSString * const BACKUP_IMAGE_SEND_MODE = @"backupImageSendMode"; // 画像バックアップ日数
static NSString * const USE_CALCULATE_TOGGLE_STRING_VALUE = @"UseCalculateToggleStringValue"; // #28474 トグル選択を文字列と扱う計算式での参照モード
static NSString * const LOGIN_RESULT_FORCE_UPDATE = @"LoginResultForceUpdate";
static NSString * const AUTO_DOWNLOAD = @"autoDownload"; // 自動ダウンロードON OFF
static NSString * const AUTO_DOWNLOAD_TIMING = @"autoDownloadTiming"; //自動ダウンロードのタイミング
static NSString * const AUTO_DOWNLOAD_OPEN = @"autoDownloadOpen"; //自動ダウンロード自動
static NSString * const FREE_DRAW_IMAGE_QUALITY = @"freeDrawImageQuality";// フリードロー解像度設定(#20851)
static NSString * const LOCK_CLUSTER_NETWORK_CLEAR_MODE_IOS = @"lockClusterNetworkClearModeIOS";// ネットワーク後続クリア設定(#28098)

// Scandit
static NSString * const LOGIN_RESULT_USE_SCANDIT = @"useScandit";
static NSString * const SCANDIT_LOCKED = @"ScanditLocked";

static NSString * const BEFORE_LOGINVIEW_NOTIFICATION = @"Before LoginView Notification";
static NSString * const KEY_ACTION = @"action";
static NSString * const ACTION_MERGE = @"M";
static NSString * const ACTION_DELETE = @"D";
static NSString * const PARAM_COMMAND = @"command";
static NSString * const VALUE_TRUE = @"true";
static NSString * const VALUE_FALSE = @"false";
static NSString * const RESTClientBaseServerChangedNotification = @"RESTClientBaseServerChangedNotification";
static NSString * const ClearLocalDataNotification = @"ClearLocalDataNotification";
static NSString * const NORMAL_DATE_TIME_FORMAT = @"yyyy/MM/dd HH:mm:ss";

static NSString * const LoginViewControllerAppaerNotification = @"LoginViewControllerAppaerNotification"; // ログインビュー表示時
static NSString * const LoginViewControllerDisappearNotification = @"LoginViewControllerDisappearNotification"; // ログインビュー非表示時
static NSString * const ProgressShowNotification = @"ProgressShowNotification";// プログレスshow処理
static NSString * const ProgressCloseNotification = @"ProgressCloseNotification";// プログレスclose処理
// 帳票定義保存ディレクトリ
static NSString * const kDefinitionDir = @"definition";
// 帳票保存ディレクトリ
static NSString * const kReportDir = @"report";
// テンポラリデータ保存ディレクトリ /Documents/temp
static NSString * const kTempDir = @"temp";
// 最後にロードしてきたデータ保存ディレクトリ /Documents/latestLoad
static NSString * const kLatestLoadDir = @"latestLoad";
// バックグラウンド保存ディレクトリ /Documents/intervalSave
static NSString * const kIntervalSaveDataDir = @"intervalSave";
// ローカル参照ファイル用ディレクトリ
static NSString * const kLocalDocuments = @"LocalDocuments";
// メッセージ画像ファイル用ディレクトリ
static NSString * const kMessage = @"message";
// FreeDraw files (PDF and IRFD)
static NSString * const kFreeDraw = @"freeDraw";
// 定義/帳票から背景画像、入力画像データを省略したバイナリファイル
static NSString * const NO_IMAGE_REPORT_FILE_NAME = @"noimagereport.bin";
// 背景画像ファイル名
static NSString * const SHEET_BACKGROUND_FILE_NAME = @"background%ld.png";
// 入力画像ファイル名
static NSString * const SHEET_INPUTIMAGE_FILE_NAME = @"inputImage%ld.png";
// 入力画像ファイルプレフィックス
static NSString * const SHEET_INPUTIMAGE_FILE_PREFIX = @"inputImage";
// プレビュー画像ファイル名
static NSString * const SHEET_PREVIEWIMAGE_FILE_NAME = @"previewImage%ld.jpg";
// クラスタ画像ファイル名
static NSString * const SHEET_CLUSTERIMAGE_FILE_NAME = @"clusterImage%ld_%ld.jpg";
static NSString * const SHEET_CLUSTERDATA_FILE_NAME = @"clusterData%ld_%ld";
// レイヤー画像、データ
static NSString * const SHEET_LAYERIMAGE_FILE_NAME = @"layerImage%ld_%ld";
static NSString * const SHEET_LAYERDATA_FILE_NAME = @"layerData%ld_%ld";

// Pin撮影画像
static NSString * const SHEET_PINIMAGE_FILE_NAME = @"pinImage%@.png";
static NSString * const SHEET_PINRDATA_FILE_NAME = @"pinData%@";

// pdfファイル名
static NSString * const SHEET_BACKGROUND_PDF_NAME = @"background.pdf";

static NSString * const SHEET_BACKGROUND_PDF_V2_NAME = @"background_V2.pdf";
// FreeDraw sheet IRFD and PDF file names
static NSString * const FREEDRAW_SHEET_PDF_FILE_NAME = @"freeDraw_%ld.pdf";
static NSString * const FREEDRAW_SHEET_IRFD_FILE_NAME = @"freeDraw_%ld.irfd";

static NSString * const DEFAULT_PDF_FILE_NAME = @"i-reporter-pdf-document.pdf";
static NSString * const DEFAULT_IRFD_FILE_NAME = @"i-reporter-irfd-document.irfd";

// 認証情報復号用
static NSString * const AUTH_KEY = @"conmas_i_reporter";

// セッション確認
static NSString * const VALUE_COMMAND_GET_USER_INFO = @"GetUserInfo";

// 分割送受信用コマンド
static NSString * const VALUE_COMMAND_GET_REPORT_DATA_TOP = @"GetReportDataTop";

// ログ送信用コマンド
static NSString * const VALUE_COMMAND_PUT_LOG = @"PutLog";

//　更新通知用
static NSString * const kNotifyUpdateReportList = @"NOTIFY UPDATE REPORT LIST";
static NSString * const kNotifyUpdateReportDetail = @"NOTIFY UPDATE REPORT DETAIL";
static NSString * const kNotifyGetReport = @"NOTIFY GET REPORT";

// NSNotification.userInfoのキーに使用
static NSString * const kReportListUserInfoKey = @"REPORT LIST USER INFO KEY";
static NSString * const kReportDetailUserInfoKey = @"REPORT LIST DETAIL USER INFO KEY";
static NSString * const kReportBundleUserInfoKey = @"REPORT BUNDLE USER INFO KEY";
static NSString * const kReportLaunchIdentifyUserInfoKey = @"REPORT LAUNCH IDENTIFY USER INFO KEY";
static NSString * const kReportUserInfoKey = @"REPORT USER INFO KEY";
static NSString * const kReportLockedUserInfoKey = @"REPORT LOCKED USER INFO KEY";
static NSString * const kReportHasLocalDataUserInfoKey = @"REPORT HAS LOCAL DATA USER INFO KEY";
static NSString * const kReportReceiveErrorInfoKey = @"REPORT RECEIVE ERROR INFO KEY";
static NSString * const kReportCopyTypeKey = @"REPORT COPY TYPE KEY";

// ロゴビュー表示設定用
static NSString * const kNotifyShowLogoView = @"NOTIFY SHOW LOGO VIEW";
static NSString * const kNotifyHideLogoView = @"NOTIFY HIDE LOGO VIEW";

// 値変更通知名
static NSString * const kClusterValueChangedNotification = @"CLUSTER VALUE CHANGED NOTIFICATION";
static NSString * const kClusterNoNeedToFillOutFlagChangedNotification = @"CLUSTER NO NEED TO FILL OUT FLAG CHANGED NOTIFICATION";
static NSString * const kClusterFinishEditingNotification = @"CLUSTER FINISH EDITING NOTIFICATION";
// 通知内容のキー
static NSString * const kClusterSentNotifiedUserInfoKey = @"NOTIFIED CLUSTER USER INFO KEY";// 送信元のクラスタ
static NSString * const kNeedToUpdateLocationUserKey = @"NOTIFIED NEED TO UPDATE LOCATION USER KEY";// 位置情報／ユーザー情報を更新するか

static NSString * const kFromTimeClusterWithoutChange = @"NOTIFIED TIME CLUSTER WITHOUT CHANGE";//
// 計算クラスタ用通知名 送信元のクラスタはkClusterSentNotifiedUserInfoKeyを使う
static NSString * const kNumericClusterValueChangedNotification = @"NUMERIC CLUSTER VALUE CHANGED NOTIFICATION";

static NSString * const kInvalidReportListRequest = @"INVALID REPORT LIST REQUEST";

// FreeDraw及びImageClusterの画像をローカル保存失敗時用
static NSString * const kFailedSaveImage = @"FAILED SAVE IMAGE";

// KeyboardToolbarのNotification
static NSString * const kDeviceOrientationWillChange = @"DeviceOrientationWillChange";

// Session Info notification
static NSString * const kSessionValidityChanged = @"SESSION VALIDITY CHANGE NOTIFICATION";

// FreeDraw sheet removed notification
static NSString * const kFreeDrawSheetRemovedNotification = @"FREEDRAW SHEET REMOVED NOTIFICATION";

// ピン打ち
static NSString * const KEY_PIN = @"pin";
static NSString * const KEY_PIN_DIETAIL = @"pinDetail";
static NSString * const PATH_PIN = @"pin/pinDetail";
static NSString * const KEY_PIN_NO = @"pinNo";
static NSString * const KEY_PIN_VALUE = @"pinValue";
static NSString * const KEY_IS_HIDDEN_CLUSTER = @"isHidden";
static NSString * const IS_COLOR_MANAGE_CLUSTER = @"ColorManageCluster";
static NSString * const PIN_COLORS = @"PinColors";
static NSString * const IS_SORT_REPORT = @"isSortReport";  // 仕訳

//保存した拡張子
static NSString * const FILE_EXTENSION = @"fileExtension";

static NSString * const keyPinNo = @"pinNo";
static NSString * const keyNoString = @"noString";
static NSString * const keyPinNoType = @"PinNoType";
static NSString * const keyVerticalPosition = @"PinDetailViewVerticalPosition";
static NSString * const keyHorizontalPosition = @"PinDetailViewHorizontalPosition";
static NSString * const keyPinDefaultColor = @"PinDefaultColor";
static NSString * const keyPinColor = @"pinColor";
static NSString * const keyPinPoint = @"pinPoint";                                  // アプリで使用するpinPoint
static NSString * const keyConnectPoint = @"connectPoint";                          // アプリで使用するconnectPoint
static NSString * const keyBackgroundPinPoint = @"pinPointForBackground";            // サーバーで使用するpinPoint
static NSString * const keyBackgroundConnectPoint = @"connectPointForBackground";   // サーバーで使用するconnectPoint
static NSString * const keyPinDirection = @"pinDirection";
static NSString * const keyPinClusters = @"pinItems";   // 明細表のクラスター配列
static NSString * const keyPinCluster = @"pinItem";
static NSString * const keyPinImages = @"pinImages";    // ピンに対するイメージクラスターの配列
static NSString * const keyPinImage = @"pinImage";
static NSString * const keyPinShape = @"pinShape";
static NSString * const keyClusterID = @"clusterId";
static NSString * const keySheetNo = @"sheetNo";

// 必須機能拡張
static NSString * const REQUIRED_CHECK_MODE = @"requiredCheckMode";
static NSString * const REQUIRED_SAVE_MODE = @"requiredSaveMode";

static const int NOT_SELECTED_INDEX = -1;
static const int kRootLabelId = -1;
static const int ALL_LABEL_ID = -1;
static const int NO_LABEL_ID = -2;
static const int RECENT_LABEL_ID = -3;
static const int FIELD_NO_RECORD_KEY = -1;
static const int FIELD_NO_RECORD_VALUE = 0;

static const float kArrowHeadHeightRatio = 3.0f; // 線幅に対する矢尻高さの割合
static const float kPointSizeRatio = 3.0f; // 線幅に対する点の半径
static const float kArrowHeadWidthRatio = 3.0f; // 線幅に対する矢尻の幅
static const int kPolygonNum = 20; // 円の近似折れ線数
static const float FORCUS_BORDER_WIDTH = 3.0;
static const float FIXED_FONT_SIZE = 25.0;
static const float BASIC_HEIGHT = 60.0f;
static const CGFloat CHECK_BUTTON_FIELD_WIDTH = 60.0;
static const CGFloat FIELD_WIDTH = 145.0;
static const CGFloat FIELD_HEIGHT = 44.0;
static const CGFloat IN_A_LUMP_DIALOG_WIDTH = 545.0f;
static const CGFloat IN_A_LUMP_DIALOG_HEIGHT = 680.0f;
static const CGFloat ERROR_LABEL_WIDTH = 150.0f;
static const CGFloat CONTENT_INSET = 0.0;

//クラスター備考
static NSString * const CLUSTER_REMARKS = @"clusterRemarks";

static const CGFloat NUMERIC_CLUSTER_HEIGHT_WITHOUT_CLUSTER_NAME_DISPLAY = 111.0f;


static NSInteger const DISPLAY_SAVE_MENU_COUNT = 11;

// IOT API Error Notification
static NSString * const kIoTClusterAPIErrorNotification = @"IoTClusterAPIErrorNotification";

// IOT API Success Notification
static NSString * const kIoTClusterAPIExecutionNotification = @"IoTClusterAPIExecutionNotification";

// 共通エラー定数
typedef NS_ENUM(int, CommonErrorCode) {
    REST_UNKNOWN = -1,
    REST_SUCCESS = 0,
    REST_COMMAND_NOT_FOUND = 1,
    REST_INVALID_PARAMETER = 2,
    REST_PRIVILEGE_ERROR = 3,
    REST_INVALID_HTTP_METHOD = 4,
    REST_NO_SESSION = 5,
    REST_RESOURCE_NOT_FOUND = 8,
    REST_DOCUMENT_DUPLICATED = 9,
    REST_CALCULATION_ERROR = 10,
    REST_REPORT_LOCKED = 1010,
    REST_ALREADY_COMPLETED = 1110,
    REST_DOCUMENT_CANCELLED = 2000,
    REST_DOCUMENT_CONSTRAINED_FUNCTION = 2002,
    REST_LICENSE_ERROR = 11050,
    REST_PROXY_ERROR = -407
};

static const int REST_RESPONSE_IS_NOT_CONMAS_FORMAT_XML = -10000;

// #8725 FreeDraw 保存タイプ
typedef enum {
    FreeDrawImageFormatUndefined = 0,
    FreeDrawImageFormatPng,
    FreeDrawImageFormatJpeg
} FreeDrawImageFormat;

// doubleとNSDecimalNumberの共通NS_ENUM
// DateCluster / DNDateCaluter
typedef NS_ENUM(NSInteger, YearDisplayType) {
    DISPLAY_NO_YEAR = 0,	// 西暦を表示しない
    DISPLAY_YYYY,			// 4桁(2011)表示
    DISPLAY_YY,				// 2桁(11)表示
};

// RelationOfMagnitude / DNRelationOfMagnitude
typedef NS_ENUM(NSInteger, RelationOfMagnitude) {
    RelationUnknown = -1,   // 未定義
    RelationGreater,        // >
    RelationGreaterOrEqual, // >=
    RelationLess,           // <
    RelationLessOrEqual,    // <=
    RelationEqual,          // ==
    RelationNotEqual,       // !=
};

// SelectCluster / DNSelectCluster
typedef NS_ENUM(NSInteger, LineSelectItemModeType) {
    LineSelectItemModeNormal = 0,
    LineSelectItemModeWithoutOK
};

// SelectCluster / DNSelectCluster
// Selectクラスタの表示タイプ
typedef NS_ENUM(NSInteger, SelectDisplayType) {
    Display_Default,    // ロール形式
    Display_Toggle,     // タップ入力
    Display_Table       // ライン形式
};

// BarcodeCluster / QRCodeCluster
// 利用するカメラデバイス設定・DefaultCamera
typedef NS_ENUM(NSInteger, CameraPositionType) {
    CameraPositionTypeBack = 0,
    CameraPositionTypeFront
};

// 音声入力の「まえ」「つぎ」での移動順
typedef NS_ENUM(NSInteger, MoveClusterIndexType) {
    MoveClusterIndexTypeClusterId = 0,  // クラスターId順
    MoveClusterIndexTypeIPhoneDisplay,  // iPhoneリスト順
};

// 検索条件
typedef NS_ENUM(NSInteger, SearchMatchingType) {
    SearchMatchingTypePartial = 0,  // 部分一致
    SearchMatchingTypeExact         // 完全一致
};

// #19789 完了帳票の表示モード
typedef NS_ENUM(NSInteger, CompleteEditDisplayType) {
    CompleteEditDisplayTypeNormal = 0, // 通常の帳票編集画面と同様の表示
    CompleteEditDisplayTypePDF = 1,    // PDF参照画面
};

// #7217 自動フォントサイズ調整の動作モード
typedef NS_ENUM(NSInteger, FontAutoResizingMode) {
    FontAutoResizingModeNone = -1,
    FontAutoResizingModeReduceOnly = 0,
    FontAutoResizingModeNormal = 1,
};
