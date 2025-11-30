// Real Quest - プロトタイプ JavaScript

// 画面切り替え
function showScreen(screenId) {
    // すべての画面を非表示
    const screens = document.querySelectorAll('.screen');
    screens.forEach(screen => {
        screen.style.display = 'none';
    });
    
    // 指定された画面を表示
    const targetScreen = document.getElementById(screenId);
    if (targetScreen) {
        targetScreen.style.display = 'flex';
    }
    
    // ナビゲーションのアクティブ状態を更新
    updateNavigation(screenId);
}

// ナビゲーション更新
function updateNavigation(screenId) {
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.classList.remove('active');
    });
    
    // 対応するナビゲーションアイテムをアクティブに
    const screenToNav = {
        'home-screen': 0,
        'camera-screen': 1,
        'quest-screen': 2,
        'collection-screen': 3,
        'profile-screen': 4
    };
    
    const index = screenToNav[screenId];
    if (index !== undefined) {
        const targetNav = document.querySelectorAll('.nav-item')[index];
        if (targetNav) {
            targetNav.classList.add('active');
        }
    }
}

// カード詳細表示
function showCardDetail(cardId) {
    const modal = document.getElementById('card-detail-modal');
    modal.classList.add('show');
    
    // カードデータ（サンプル）
    const cardData = {
        sakura: {
            emoji: '🌸',
            title: '🌸 桜の木',
            category: '自然',
            rarity: '★★★★☆ Epic',
            rarityClass: 'epic',
            stats: {
                attack: 45,
                defense: 60,
                speed: 30,
                utility: 50
            },
            description: '春の訪れを告げる美しい桜。その優美な姿は見る者の心を癒す...',
            date: '2025-03-15',
            location: '上野公園',
            tags: '#春 #自然 #ピンク'
        },
        castle: {
            emoji: '🏯',
            title: '🏯 日本の城',
            category: '場所',
            rarity: '★★★☆☆ Rare',
            rarityClass: 'rare',
            stats: {
                attack: 70,
                defense: 85,
                speed: 20,
                utility: 65
            },
            description: '日本の歴史を伝える威厳ある城。その堅固な作りは防御の象徴。',
            date: '2025-03-10',
            location: '大阪城',
            tags: '#歴史 #建築 #観光'
        },
        deer: {
            emoji: '🦌',
            title: '🦌 鹿',
            category: '生き物',
            rarity: '★★☆☆☆ Uncommon',
            rarityClass: 'uncommon',
            stats: {
                attack: 35,
                defense: 40,
                speed: 70,
                utility: 30
            },
            description: '森の奥深くに住む穏やかな鹿。その素早い動きは見る者を魅了する。',
            date: '2025-03-08',
            location: '奈良公園',
            tags: '#動物 #自然 #奈良'
        }
    };
    
    const card = cardData[cardId];
    if (card) {
        // カード情報を更新
        document.getElementById('detail-emoji').textContent = card.emoji;
        document.getElementById('detail-title').textContent = card.title;
        document.getElementById('detail-rarity').textContent = card.rarity;
        document.getElementById('detail-rarity').className = `rarity ${card.rarityClass}`;
        
        // ステータスバーを更新
        const statBars = document.querySelectorAll('.card-stats .progress-fill');
        statBars[0].style.width = card.stats.attack + '%';
        statBars[1].style.width = card.stats.defense + '%';
        statBars[2].style.width = card.stats.speed + '%';
        statBars[3].style.width = card.stats.utility + '%';
        
        const statValues = document.querySelectorAll('.card-stats .stat-value');
        statValues[0].textContent = card.stats.attack;
        statValues[1].textContent = card.stats.defense;
        statValues[2].textContent = card.stats.speed;
        statValues[3].textContent = card.stats.utility;
        
        // 説明文とメタデータ
        document.querySelector('.card-description').textContent = card.description;
        const metaItems = document.querySelectorAll('.card-metadata .meta-item');
        metaItems[0].textContent = `📅 ${card.date} 取得`;
        metaItems[1].textContent = `📍 ${card.location}`;
        metaItems[2].textContent = `🏷️ ${card.tags}`;
    }
}

// カード詳細を閉じる
function closeCardDetail() {
    const modal = document.getElementById('card-detail-modal');
    modal.classList.remove('show');
}

// モーダル外クリックで閉じる
document.addEventListener('click', (e) => {
    const modal = document.getElementById('card-detail-modal');
    if (e.target === modal) {
        closeCardDetail();
    }
});

// アニメーション効果
function animateProgressBars() {
    const progressBars = document.querySelectorAll('.progress-fill');
    progressBars.forEach((bar, index) => {
        const width = bar.style.width;
        bar.style.width = '0%';
        setTimeout(() => {
            bar.style.width = width;
        }, index * 50);
    });
}

// ページ読み込み時
document.addEventListener('DOMContentLoaded', () => {
    // プログレスバーアニメーション
    setTimeout(animateProgressBars, 300);
    
    // バトルボタンのサンプル動作
    document.querySelectorAll('.battle-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 100);
            
            // サンプルアクション
            if (this.classList.contains('attack-btn')) {
                showBattleAnimation('attack');
            }
        });
    });
});

// バトルアニメーション（サンプル）
function showBattleAnimation(action) {
    const enemy = document.querySelector('.enemy-sprite');
    if (!enemy) return;
    
    if (action === 'attack') {
        enemy.style.animation = 'shake 0.5s';
        setTimeout(() => {
            enemy.style.animation = '';
        }, 500);
        
        // ダメージ表示
        const damage = document.createElement('div');
        damage.textContent = '-123';
        damage.style.cssText = `
            position: absolute;
            top: 30%;
            left: 50%;
            transform: translateX(-50%);
            color: #FF6B6B;
            font-size: 36px;
            font-weight: bold;
            animation: damageFloat 1s ease-out;
            pointer-events: none;
        `;
        document.querySelector('.battle-container').appendChild(damage);
        
        setTimeout(() => {
            damage.remove();
        }, 1000);
    }
}

// CSSアニメーション追加
const style = document.createElement('style');
style.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        25% { transform: translateX(-10px); }
        75% { transform: translateX(10px); }
    }
    
    @keyframes damageFloat {
        0% {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
        100% {
            opacity: 0;
            transform: translateX(-50%) translateY(-50px);
        }
    }
`;
document.head.appendChild(style);

// バトル画面のデモ用ボタン
if (document.getElementById('battle-screen')) {
    const demoButton = document.createElement('button');
    demoButton.textContent = '⚔️ バトルを見る';
    demoButton.className = 'action-button primary';
    demoButton.style.margin = '0 20px'; demoButton.onclick = () => showScreen('battle-screen');
    
    const sections = document.querySelectorAll('.section');
    if (sections.length > 0) {
        sections[sections.length - 1].appendChild(demoButton);
    }
}

console.log('🎮 Real Quest プロトタイプ起動！');
console.log('📱 画面: ホーム、バトル、図鑑');
console.log('🃏 カードをクリックして詳細を表示');
