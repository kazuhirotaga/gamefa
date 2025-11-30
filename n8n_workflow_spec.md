# Real Quest - n8n ワークフロー仕様書

このドキュメントは、LINE Bot、Supabase、Gemini APIを連携させ、Real Questのバックエンドロジックを実装するためのn8nワークフローの詳細を記述します。

## 1. カード獲得・チェックイン ワークフロー

**トリガー**: Webhook (アプリ/LINE Botから) - `POST /api/checkin`

### ワークフローの手順:

1.  **Webhook ノード**: `userId`（ユーザーID）、`latitude`（緯度）、`longitude`（経度）、`facilityId`（施設ID）、`paymentAmount`（支払金額）、`receiptImage`（レシート画像）を受け取る。
2.  **Supabase ノード (ユーザー取得)**: `userId`を使ってユーザーデータを取得する。
3.  **Supabase ノード (施設取得)**: `facilityId`を使って施設詳細を取得する。
4.  **Function ノード (検証)**:
    *   ユーザーと施設の間の距離を計算する。
    *   `paymentAmount`が3000円を超える場合、レシートを検証する（必要に応じてGemini APIを呼び出す）。
5.  **Function ノード (カードロジック)**:
    *   施設タイプと支払金額に基づいて`cardCount`（獲得枚数）を計算する。
    *   支払金額に基づいて`rarityBoost`（レア度ブースト）を計算する。
    *   確率ロジックを実行し、各カードのレア度を決定する。
6.  **Supabase ノード (テンプレート取得)**: 決定されたレア度と地域に対応する`card_template`をランダムに選択する。
    *   *ロジック*: `SELECT * FROM card_templates WHERE region_id = $region AND rarity = $rarity ORDER BY RANDOM() LIMIT 1`
7.  **Supabase ノード (上限チェック)**: 選択されたカードの`region_card_limits`（地域発行上限）をチェックする。
    *   上限に達している場合、レア度を1つ下げて手順6を再試行する。
8.  **Supabase ノード (カード挿入)**: `user_cards`テーブルにデータを挿入する。
9.  **Supabase ノード (上限更新)**: `region_card_limits`の`current_count`をインクリメントする（Common以外の場合）。
10. **Response ノード**: 獲得したカードデータを含むJSONを返す。

---

## 2. バトルロジック ワークフロー

**トリガー**: Webhook - `POST /api/battle/action`

### ワークフローの手順:

1.  **Webhook ノード**: `userId`、`battleId`、`actionType`（攻撃/スキル/アイテム）、`targetId`を受け取る。
2.  **Supabase ノード (バトル状態取得)**: 現在のバトルステータス、敵のステータス、ターン数を取得する。
3.  **Supabase ノード (ユーザー・ステータス取得)**: ユーザーのHP、MP、装備、アクティブなバフを取得する。
4.  **Function ノード (ダメージ計算)**:
    *   ユーザーダメージ計算: `(攻撃力 * スキル倍率 * ランダム係数) - 敵防御力`
    *   属性相性の適用。
    *   クリティカルヒット判定。
5.  **Supabase ノード (バトル更新)**: 敵のHPを更新する。
6.  **If ノード (敵を倒した？)**:
    *   **True (勝利)**:
        *   XP/コイン報酬を計算する。
        *   **Supabase ノード**: ユーザー情報（XP、コイン）を更新する。
        *   **Response**: 勝利データを返す。
    *   **False (継続)**:
        *   **Function ノード**: 敵AIのターン（攻撃を選択）。
        *   敵からユーザーへのダメージを計算する。
        *   **Supabase ノード**: ユーザーHPを更新する。
        *   **Response**: ターン結果（ユーザーダメージ、敵ダメージ、現在の状態）を返す。

---

## 3. Gemini API 画像生成ワークフロー (管理者用)

**トリガー**: 手動 / スケジュール実行

### ワークフローの手順:

1.  **Supabase ノード**: `image_url`がNULLの`card_templates`を取得する。
2.  **Gemini ノード (画像生成)**:
    *   モデル: `imagen-3.0-generate-001`
    *   プロンプト: 「プロンプトテンプレート」を使用して、`character_name`、`description`、`rarity`からプロンプトを構築する。
3.  **HTTP Request ノード**: 生成された画像をSupabase Storageにアップロードする。
4.  **Supabase ノード**: 新しい`image_url`で`card_templates`を更新する。

---

## 4. LINE Bot メッセージハンドラー

**トリガー**: LINE Webhook

### ワークフローの手順:

1.  **Webhook ノード**: LINEイベントを受け取る。
2.  **Switch ノード (イベントタイプ)**:
    *   **Message**: テキスト/画像
    *   **Postback**: ボタンクリック
    *   **Beacon**: ロケーションビーコン
3.  **Case: Location Beacon**:
    *   近くの施設をチェックする。
    *   「チェックイン可能です！」というメッセージを送信する。
4.  **Case: Text "ステータス"**:
    *   ユーザーのステータスを取得する。
    *   HP/MP/レベルを表示するFlex Messageを返信する。
5.  **Case: Image (レシート)**:
    *   Gemini APIを呼び出してレシート（日付、金額、店舗名）を解析する。
    *   チェックインフローのために一時的な状態として保存する。

---

## 5. データ構造 (JSON例)

### チェックイン リクエスト
```json
{
  "userId": "U123456...",
  "latitude": 37.9161,
  "longitude": 139.0364,
  "facilityId": "fac_niigata_001",
  "paymentAmount": 3500,
  "receiptImage": "base64_string..."
}
```

### バトルアクション リクエスト
```json
{
  "userId": "U123456...",
  "battleId": "bat_98765...",
  "action": "attack",
  "cardId": "card_uuid_..."
}
```
