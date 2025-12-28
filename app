// 確保 DOM 載入完成後再執行
document.addEventListener('DOMContentLoaded', () => {
    
    // 檢查資料是否成功載入
    if (typeof KEYWORD_DATA === 'undefined') {
        console.error("資料庫未載入！請檢查 data.js 路徑");
        document.getElementById('dataStatus').innerText = "❌ 資料庫載入失敗";
        document.getElementById('dataStatus').classList.add('text-red-500');
        return;
    }

    // 初始化狀態顯示
    const totalCombos = BigInt(KEYWORD_DATA.prefixes.length) * BigInt(KEYWORD_DATA.topics.length) * BigInt(KEYWORD_DATA.suffixes.length);
    document.getElementById('dataStatus').innerText = `✅ 資料庫已就緒 (可生成約 ${totalCombos.toLocaleString()} 種組合)`;
    
    // 綁定按鈕事件
    document.getElementById('generateBtn').addEventListener('click', generateKeywords);
    document.getElementById('copyBtn').addEventListener('click', copyAll);

    let currentKeywords = [];

    function generateKeywords() {
        const count = parseInt(document.getElementById('countSelect').value);
        const resultList = document.getElementById('resultList');
        const copyBtn = document.getElementById('copyBtn');
        const instruction = document.getElementById('instruction');

        // 使用組合演算法生成
        currentKeywords = generateCombinations(count);

        // 渲染結果
        renderResults(currentKeywords);
        
        // 顯示控制項
        copyBtn.classList.remove('hidden');
        instruction.classList.remove('hidden');
    }

    function generateCombinations(count) {
        const results = new Set();
        const maxAttempts = count * 10; // 防止無窮迴圈
        let attempts = 0;

        const { prefixes, topics, suffixes } = KEYWORD_DATA;

        while (results.size < count && attempts < maxAttempts) {
            const pattern = Math.random();
            let keyword = "";

            const topic = getRandomItem(topics);
            const prefix = getRandomItem(prefixes);
            const suffix = getRandomItem(suffixes);

            // 隨機排列模式
            if (pattern < 0.25) {
                // 模式 1: 主題 + 後綴 (iPhone 16 評價)
                keyword = `${topic} ${suffix}`;
            } else if (pattern < 0.5) {
                // 模式 2: 前綴 + 主題 (2025最新 日本旅遊)
                keyword = `${prefix} ${topic}`;
            } else if (pattern < 0.75) {
                // 模式 3: 前綴 + 主題 + 後綴 (懶人包 報稅 教學)
                keyword = `${prefix} ${topic} ${suffix}`;
            } else {
                // 模式 4: 主題 + 主題 (關聯詞) (台積電 股價)
                const topic2 = getRandomItem(topics);
                if (topic !== topic2) {
                    keyword = `${topic} ${topic2}`;
                } else {
                    keyword = `${topic} ${suffix}`;
                }
            }

            results.add(keyword);
            attempts++;
        }
        return Array.from(results);
    }

    function getRandomItem(arr) {
        return arr[Math.floor(Math.random() * arr.length)];
    }

    function renderResults(keywords) {
        const container = document.getElementById('resultList');
        container.innerHTML = '';

        keywords.forEach((keyword, index) => {
            const div = document.createElement('div');
            // 使用 CSS class (定義在 style.css)
            div.className = 'keyword-item fade-in group'; 
            
            div.onclick = function() {
                copySingleText(keyword);
                playClickAnimation(div);
            };

            div.innerHTML = `
                <div class="flex items-center gap-3 w-full">
                    <span class="index-badge group-hover:bg-blue-600 group-hover:text-white transition-colors shrink-0">
                        ${index + 1}
                    </span>
                    <span class="font-medium text-gray-800 text-lg flex-grow truncate">${keyword}</span>
                    <span class="text-xs text-gray-400 group-hover:text-blue-500 transition-colors opacity-0 group-hover:opacity-100 shrink-0">
                        複製
                    </span>
                </div>
            `;
            container.appendChild(div);
        });
    }

    function playClickAnimation(element) {
        element.classList.remove('click-feedback');
        void element.offsetWidth; // Trigger reflow
        element.classList.add('click-feedback');
    }

    function copySingleText(text) {
        performCopy(text);
        showToast(`已複製：${text}`);
    }

    function copyAll() {
        if (currentKeywords.length === 0) return;
        const textToCopy = currentKeywords.join('\n');
        performCopy(textToCopy);
        showToast("已複製全部關鍵字！");
    }

    function performCopy(text) {
        if (!navigator.clipboard) {
            fallbackCopy(text);
            return;
        }
        navigator.clipboard.writeText(text).catch(err => {
            console.warn("Clipboard API failed, using fallback", err);
            fallbackCopy(text);
        });
    }

    function fallbackCopy(text) {
        const textArea = document.createElement("textarea");
        textArea.value = text;
        textArea.style.position = "fixed";
        textArea.style.left = "-9999px";
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        try {
            document.execCommand('copy');
        } catch (err) {
            console.error('Fallback copy failed', err);
        }
        document.body.removeChild(textArea);
    }

    let toastTimeout;
    function showToast(message) {
        const toast = document.getElementById('toast');
        toast.innerText = message;
        toast.classList.remove('opacity-0');
        
        if (toastTimeout) clearTimeout(toastTimeout);
        
        toastTimeout = setTimeout(() => {
            toast.classList.add('opacity-0');
        }, 2000);
    }
});
