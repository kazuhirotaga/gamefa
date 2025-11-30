# Real Quest Admin App Specification

## 1. Overview
A management application for "Real Quest" administrators to efficiently manage game content (Cards, Items) and user data.
This tool will be built as a **Flutter Web/Desktop** application to leverage existing data models and logic.

## 2. Core Features

### 2.1 Card Generation (Card Maker)
*   **Goal**: Create new card templates efficiently, utilizing AI for image generation.
*   **UI Inputs**:
    *   **Basic Info**: Name, Description, Rarity (Common~Legendary), Category, Element.
    *   **Stats**: Attack, Defense, Speed, Utility.
    *   **AI Prompt**: Text input for image generation prompt.
    *   **Reference Image**: (Optional) Upload an image to guide the generation.
*   **Actions**:
    *   **Generate Image**: Call `admin-generate-card` Edge Function using **Gemini 3 Pro Image Preview** model.
        *   Pass prompt and optional reference image (base64 or URL).
    *   **Preview**: Display the generated image and card frame.
    *   **Save**: Insert the new card data into `card_templates` table.

### 2.2 Item Generation (Item Maker)
*   **Goal**: Register new items usable by players.
*   **UI Inputs**:
    *   **Basic Info**: Name, Description.
    *   **Type**: Consumable, Material, Key Item.
    *   **Effect**: Effect Type (Heal HP, Restore MP, etc.), Effect Value.
    *   **AI Prompt**: Text input for image generation.
    *   **Reference Image**: (Optional) Upload an image to guide the generation.
*   **Actions**:
    *   **Generate Image**: Call `admin-generate-item` (or shared function) using **Gemini 3 Pro Image Preview**.
    *   **Save**: Insert the new item data into `item_templates` table.

### 2.5 Monster Generation (Monster Maker)
*   **Goal**: Create new enemies for battles.
*   **UI Inputs**:
    *   **Basic Info**: Name, Description, Element.
    *   **Stats**: HP, Attack, Defense, EXP Reward, Coin Reward.
    *   **AI Prompt**: Text input for image generation.
    *   **Reference Image**: (Optional) Upload an image to guide the generation.
*   **Actions**:
    *   **Generate Image**: Call `admin-generate-monster` (or shared function) using **Gemini 3 Pro Image Preview**.
    *   **Save**: Insert the new monster data into `monster_templates` table.

### 2.3 User Status Adjustment (Debugger / Support)
*   **Goal**: View and modify user data for debugging or customer support.
*   **UI Inputs**:
    *   **Search**: Search by User ID or Email.
*   **Display**:
    *   Current Status (Level, EXP, HP, MP, Coins).
    *   Inventory & Card List.
*   **Actions**:
    *   **Edit**: Modify Level, EXP, Coins, etc.
    *   **Grant**: Give specific Items or Cards to the user.

### 2.4 Database Viewer (Data Reference)
*   **Goal**: Inspect raw data in key tables for analysis and debugging.
*   **Target Tables**: `users`, `checkins`, `quests`, `user_quests`.
*   **UI**:
    *   **Table Selector**: Dropdown to choose which table to view.
    *   **Data Grid**: Paginated list of rows.
    *   **Refresh**: Button to reload data.

## 3. Technical Architecture

### 3.1 Framework
*   **Flutter (Web & macOS/Windows)**:
    *   Allows code sharing with the main app (Models, SupabaseService).
    *   Provides a responsive UI suitable for desktop management work.

### 3.2 Database Access
*   **Supabase**:
    *   The Admin App will use a dedicated Admin Account or Service Role (secured via RLS or separate Auth) to access tables.
    *   *Note*: For the prototype, we will use the existing Supabase project and potentially a simple "Admin Login" or just unrestricted access if running locally for development.

## 4. Project Structure
*   New Flutter Project: `real_quest_admin`
*   Location: `c:\Users\ikaru\.gemini\antigravity\scratch\real-quest-spec\real_quest_admin`

## 5. Roadmap
1.  **Project Setup**: Initialize Flutter Web project.
2.  **Card Gen UI**: Implement form and Image Gen integration.
3.  **Item Gen UI**: Implement form and DB insert.
4.  **User Manager**: Implement search and edit functionality.
