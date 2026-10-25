# 化学資格研究所：大規模大気特論の10年分析ページに図解リンクを追加
# 元のHTMLは必ずバックアップし、分析本文や外部リンクを保持します。
$ErrorActionPreference = 'Stop'
try {
    $source = Join-Path $PSScriptRoot 'pollution-air-large-analysis.html'
    if (-not [System.IO.File]::Exists($source)) {
        throw 'pollution-air-large-analysis.html が見つかりません。このツール一式を GitHub の kagaku-shikaku-site フォルダに置いてから実行してください。'
    }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $page = [System.IO.File]::ReadAllText($source,[System.Text.Encoding]::UTF8)
    if ($page.Contains('id="large-figure-gallery"')) {
        Write-Host 'すでに図解リンクが追加されています。二重追加はしません。' -ForegroundColor Yellow
        exit 0
    }
    foreach ($marker in @('</style>', '<div class="a-actions">','id="rank-s"','id="rank-a"','id="comparison"','id="yearmap"')) {
        if (-not $page.Contains($marker)) { throw "想定した分析ページと異なります。不明な箇所: $marker （更新を中止しました）" }
    }
    $backupFolder = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Chemical-License-Lab-Backups'
    [void][System.IO.Directory]::CreateDirectory($backupFolder)
    $backup = Join-Path $backupFolder ('pollution-air-large-analysis-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.html')
    [System.IO.File]::Copy($source,$backup,$false)
    Write-Host "バックアップ：$backup" -ForegroundColor Cyan
    # CSSは既存スタイルに追加
    $css = @'

/* 大規模大気特論：図解34テーマへのリンク（分析本文は維持） */
.la-illustrations{background:#eef4ee;scroll-margin-top:140px}
.la-illustrations .la-intro{max-width:840px;color:#4b6050;font-size:15px;line-height:1.9;margin:0 0 26px}
.la-ill-grouptitle{font-size:clamp(22px,3vw,30px);letter-spacing:-.04em;margin:42px 0 16px;display:flex;align-items:center;gap:12px}
.la-ill-grouptitle:before{content:"";width:9px;height:27px;border-radius:12px;background:#33845c}
.la-ill-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:17px}
.la-ill-card{display:block;background:#fff;border:1px solid #d2dfd1;border-radius:16px;overflow:hidden;color:#132218;text-decoration:none;transition:box-shadow .15s,transform .15s}
.la-ill-card:hover,.la-ill-card:focus-visible{transform:translateY(-3px);box-shadow:0 10px 27px #152b1822;outline:2px solid #53946a;outline-offset:1px}
.la-ill-card img{display:block;width:100%;aspect-ratio:4/3;object-fit:cover;background:#e4ede4}
.la-ill-card-body{padding:15px 17px 18px}
.la-ill-num{font-size:11px;font-weight:900;letter-spacing:.12em;color:#346448}
.la-ill-card h3{font-size:clamp(16px,1.5vw,19px);margin:7px 0 10px;line-height:1.45;letter-spacing:-.03em}
.la-ill-more{font-size:12px;color:#1b6d41;font-weight:900}
.la-related{margin:11px 0 12px;display:flex;align-items:center;gap:7px;flex-wrap:wrap}
.la-related-label{font-size:12px;color:#506657;font-weight:850;margin-right:3px}
.la-related-link{padding:5px 9px!important;background:#e4f7dc!important;color:#174e2e!important;border:1px solid #bbddc1!important;border-radius:7px!important;font-size:12px!important;font-weight:900!important;text-decoration:none!important;display:inline-flex!important;align-items:center;min-height:30px}
.la-related-link:hover,.la-related-link:focus-visible{background:#c8ff4d!important;outline:2px solid #235233;outline-offset:1px}
.la-ill-end{margin-top:34px;background:#14251a;color:white;border-radius:15px;padding:23px;display:flex;align-items:center;justify-content:space-between;gap:18px}
.la-ill-end p{margin:0;color:#d8e7db;font-size:13px}
.la-ill-end a{white-space:nowrap;background:#c8ff4d;color:#102118;border-radius:100px;padding:12px 17px;font-weight:900;text-decoration:none}
@media(max-width:850px){.la-ill-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media(max-width:560px){.la-ill-grid{grid-template-columns:1fr}.la-ill-end{display:block}.la-ill-end a{display:inline-block;margin-top:15px}.la-ill-card-body{padding:15px}.la-ill-card h3{font-size:18px}}

'@
    $page = $page.Replace('</style>', $css + [Environment]::NewLine + '</style>')
    # ページ最上部と目次に図解リンクを増設
    $page = $page.Replace('<div class="a-actions">', '<div class="a-actions"><a class="a-btn dark" href="#large-figure-gallery">34枚の図解を見る ↓</a><a class="a-btn" href="pollution-air-large-topics.html">図解を検索する ↗</a>')
    $navRegex = [regex]::new('(?s)(<nav[^>]*class="a-subnav"[^>]*>.*?)(</div></nav>)')
    if (-not $navRegex.IsMatch($page)) { throw '目次の形式が異なるため更新を中止しました。' }
    $page = $navRegex.Replace($page,[System.Text.RegularExpressions.MatchEvaluator]{ param($m) $m.Groups[1].Value + '<a href="#large-figure-gallery">図解34テーマ</a>' + $m.Groups[2].Value },1)
    # Aランクの後ろに34テーマの図解ギャラリーを挿入
    $gallery = @'
<section class="a-section la-illustrations" id="large-figure-gallery" aria-labelledby="large-figure-gallery-heading"><div class="wrap">
<div class="a-caption">ILLUSTRATED STUDY / 34 THEMES</div><h2 class="a-section-title" id="large-figure-gallery-heading">過去問分析から、<br>図解で理解する。</h2>
<p class="la-intro">大規模大気特論の重要テーマを、気象・拡散モデル・排煙処理・産業別対策の34枚に整理しました。図を選ぶと各テーマの詳しい解説ページに進めます。分析ページのS/Aランクカードからも、対応する図解を直接開けます。</p>
<h3 class="la-ill-grouptitle">気象と大気の構造 <span style="font-size:12px;color:#587060">12テーマ</span></h3><div class="la-ill-grid">
<a class="la-ill-card" href="pollution-air-large-topic-01.html" aria-label="図解01：大気中の乱流拡散と自由対流・強制対流を詳しく見る"><img src="assets/topics/air-large/topic-01.webp" width="1280" height="960" loading="lazy" decoding="async" alt="大気中の乱流拡散と自由対流・強制対流の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 01</span><h3>大気中の乱流拡散と自由対流・強制対流</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-02.html" aria-label="図解02：温位と乾燥断熱減率を詳しく見る"><img src="assets/topics/air-large/topic-02.webp" width="1280" height="960" loading="lazy" decoding="async" alt="温位と乾燥断熱減率の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 02</span><h3>温位と乾燥断熱減率</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-03.html" aria-label="図解03：気温の鉛直分布と大気安定度を詳しく見る"><img src="assets/topics/air-large/topic-03.webp" width="1280" height="960" loading="lazy" decoding="async" alt="気温の鉛直分布と大気安定度の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 03</span><h3>気温の鉛直分布と大気安定度</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-04.html" aria-label="図解04：逆転層の種類と発生メカニズムを詳しく見る"><img src="assets/topics/air-large/topic-04.webp" width="1280" height="960" loading="lazy" decoding="async" alt="逆転層の種類と発生メカニズムの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 04</span><h3>逆転層の種類と発生メカニズム</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-05.html" aria-label="図解05：大気境界層・混合層の構造と特徴を詳しく見る"><img src="assets/topics/air-large/topic-05.webp" width="1280" height="960" loading="lazy" decoding="async" alt="大気境界層・混合層の構造と特徴の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 05</span><h3>大気境界層・混合層の構造と特徴</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-06.html" aria-label="図解06：海陸風と内部境界層の発達を詳しく見る"><img src="assets/topics/air-large/topic-06.webp" width="1280" height="960" loading="lazy" decoding="async" alt="海陸風と内部境界層の発達の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 06</span><h3>海陸風と内部境界層の発達</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-07.html" aria-label="図解07：風速の鉛直分布とべき乗則を詳しく見る"><img src="assets/topics/air-large/topic-07.webp" width="1280" height="960" loading="lazy" decoding="async" alt="風速の鉛直分布とべき乗則の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 07</span><h3>風速の鉛直分布とべき乗則</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-08.html" aria-label="図解08：大気安定度による煙の形の違いを詳しく見る"><img src="assets/topics/air-large/topic-08.webp" width="1280" height="960" loading="lazy" decoding="async" alt="大気安定度による煙の形の違いの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 08</span><h3>大気安定度による煙の形の違い</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-09.html" aria-label="図解09：ダウンウォッシュとダウンドラフトの違いを詳しく見る"><img src="assets/topics/air-large/topic-09.webp" width="1280" height="960" loading="lazy" decoding="async" alt="ダウンウォッシュとダウンドラフトの違いの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 09</span><h3>ダウンウォッシュとダウンドラフトの違い</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-10.html" aria-label="図解10：実煙突高さと有効煙突高さを詳しく見る"><img src="assets/topics/air-large/topic-10.webp" width="1280" height="960" loading="lazy" decoding="async" alt="実煙突高さと有効煙突高さの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 10</span><h3>実煙突高さと有効煙突高さ</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-11.html" aria-label="図解11：煙の上昇高さを求める代表的な式を詳しく見る"><img src="assets/topics/air-large/topic-11.webp" width="1280" height="960" loading="lazy" decoding="async" alt="煙の上昇高さを求める代表的な式の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 11</span><h3>煙の上昇高さを求める代表的な式</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-12.html" aria-label="図解12：フュミゲーションと逆転層の影響を詳しく見る"><img src="assets/topics/air-large/topic-12.webp" width="1280" height="960" loading="lazy" decoding="async" alt="フュミゲーションと逆転層の影響の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 12</span><h3>フュミゲーションと逆転層の影響</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
</div>
<h3 class="la-ill-grouptitle">大気拡散と予測モデル <span style="font-size:12px;color:#587060">9テーマ</span></h3><div class="la-ill-grid">
<a class="la-ill-card" href="pollution-air-large-topic-13.html" aria-label="図解13：正規形プルーム拡散式の原理と計算を詳しく見る"><img src="assets/topics/air-large/topic-13.webp" width="1280" height="960" loading="lazy" decoding="async" alt="正規形プルーム拡散式の原理と計算の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 13</span><h3>正規形プルーム拡散式の原理と計算</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-14.html" aria-label="図解14：パスキルの大気安定度分類と拡散幅を詳しく見る"><img src="assets/topics/air-large/topic-14.webp" width="1280" height="960" loading="lazy" decoding="async" alt="パスキルの大気安定度分類と拡散幅の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 14</span><h3>パスキルの大気安定度分類と拡散幅</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-15.html" aria-label="図解15：平均化時間と煙の蛇行・拡散幅を詳しく見る"><img src="assets/topics/air-large/topic-15.webp" width="1280" height="960" loading="lazy" decoding="async" alt="平均化時間と煙の蛇行・拡散幅の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 15</span><h3>平均化時間と煙の蛇行・拡散幅</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-16.html" aria-label="図解16：最大着地濃度 (C_{max}) と発生位置の関係を詳しく見る"><img src="assets/topics/air-large/topic-16.webp" width="1280" height="960" loading="lazy" decoding="async" alt="最大着地濃度 (C_{max}) と発生位置の関係の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 16</span><h3>最大着地濃度 (C_{max}) と発生位置の関係</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-17.html" aria-label="図解17：最大着地濃度から必要煙突高さを求めるを詳しく見る"><img src="assets/topics/air-large/topic-17.webp" width="1280" height="960" loading="lazy" decoding="async" alt="最大着地濃度から必要煙突高さを求めるの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 17</span><h3>最大着地濃度から必要煙突高さを求める</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-18.html" aria-label="図解18：大気拡散モデルの分類と特徴を詳しく見る"><img src="assets/topics/air-large/topic-18.webp" width="1280" height="960" loading="lazy" decoding="async" alt="大気拡散モデルの分類と特徴の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 18</span><h3>大気拡散モデルの分類と特徴</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-19.html" aria-label="図解19：AERMOD・METI-LIS・OCDなどの適用条件を詳しく見る"><img src="assets/topics/air-large/topic-19.webp" width="1280" height="960" loading="lazy" decoding="async" alt="AERMOD・METI-LIS・OCDなどの適用条件の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 19</span><h3>AERMOD・METI-LIS・OCDなどの適用条件</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-20.html" aria-label="図解20：長期平均濃度と風向データの処理を詳しく見る"><img src="assets/topics/air-large/topic-20.webp" width="1280" height="960" loading="lazy" decoding="async" alt="長期平均濃度と風向データの処理の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 20</span><h3>長期平均濃度と風向データの処理</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-21.html" aria-label="図解21：風洞実験と現地トレーサー実験の違いを詳しく見る"><img src="assets/topics/air-large/topic-21.webp" width="1280" height="960" loading="lazy" decoding="async" alt="風洞実験と現地トレーサー実験の違いの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 21</span><h3>風洞実験と現地トレーサー実験の違い</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
</div>
<h3 class="la-ill-grouptitle">排煙処理・汚染物質対策 <span style="font-size:12px;color:#587060">5テーマ</span></h3><div class="la-ill-grid">
<a class="la-ill-card" href="pollution-air-large-topic-22.html" aria-label="図解22：石炭火力発電所の排煙処理システム全体を詳しく見る"><img src="assets/topics/air-large/topic-22.webp" width="1280" height="960" loading="lazy" decoding="async" alt="石炭火力発電所の排煙処理システム全体の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 22</span><h3>石炭火力発電所の排煙処理システム全体</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-23.html" aria-label="図解23：低温形・低低温形電気集じん装置の違いを詳しく見る"><img src="assets/topics/air-large/topic-23.webp" width="1280" height="960" loading="lazy" decoding="async" alt="低温形・低低温形電気集じん装置の違いの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 23</span><h3>低温形・低低温形電気集じん装置の違い</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-24.html" aria-label="図解24：SOxの湿式石灰石こう法による除去を詳しく見る"><img src="assets/topics/air-large/topic-24.webp" width="1280" height="960" loading="lazy" decoding="async" alt="SOxの湿式石灰石こう法による除去の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 24</span><h3>SOxの湿式石灰石こう法による除去</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-25.html" aria-label="図解25：重油・重質油燃焼に伴うSO₃と乾式処理を詳しく見る"><img src="assets/topics/air-large/topic-25.webp" width="1280" height="960" loading="lazy" decoding="async" alt="重油・重質油燃焼に伴うSO₃と乾式処理の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 25</span><h3>重油・重質油燃焼に伴うSO₃と乾式処理</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-26.html" aria-label="図解26：NOxの生成抑制と排煙脱硝方法を詳しく見る"><img src="assets/topics/air-large/topic-26.webp" width="1280" height="960" loading="lazy" decoding="async" alt="NOxの生成抑制と排煙脱硝方法の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 26</span><h3>NOxの生成抑制と排煙脱硝方法</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
</div>
<h3 class="la-ill-grouptitle">産業・焼却施設の対策 <span style="font-size:12px;color:#587060">8テーマ</span></h3><div class="la-ill-grid">
<a class="la-ill-card" href="pollution-air-large-topic-27.html" aria-label="図解27：製油所の大気汚染防止対策を詳しく見る"><img src="assets/topics/air-large/topic-27.webp" width="1280" height="960" loading="lazy" decoding="async" alt="製油所の大気汚染防止対策の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 27</span><h3>製油所の大気汚染防止対策</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-28.html" aria-label="図解28：セメント製造工程と大気汚染物質の発生を詳しく見る"><img src="assets/topics/air-large/topic-28.webp" width="1280" height="960" loading="lazy" decoding="async" alt="セメント製造工程と大気汚染物質の発生の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 28</span><h3>セメント製造工程と大気汚染物質の発生</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-29.html" aria-label="図解29：鉄鋼製造工程とSOx・NOx・ばいじん対策を詳しく見る"><img src="assets/topics/air-large/topic-29.webp" width="1280" height="960" loading="lazy" decoding="async" alt="鉄鋼製造工程とSOx・NOx・ばいじん対策の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 29</span><h3>鉄鋼製造工程とSOx・NOx・ばいじん対策</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-30.html" aria-label="図解30：燃料品質規制と大気汚染対策を詳しく見る"><img src="assets/topics/air-large/topic-30.webp" width="1280" height="960" loading="lazy" decoding="async" alt="燃料品質規制と大気汚染対策の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 30</span><h3>燃料品質規制と大気汚染対策</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-31.html" aria-label="図解31：都市ごみ焼却で発生する主な大気汚染物質を詳しく見る"><img src="assets/topics/air-large/topic-31.webp" width="1280" height="960" loading="lazy" decoding="async" alt="都市ごみ焼却で発生する主な大気汚染物質の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 31</span><h3>都市ごみ焼却で発生する主な大気汚染物質</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-32.html" aria-label="図解32：ごみ焼却施設の排ガス処理フローを詳しく見る"><img src="assets/topics/air-large/topic-32.webp" width="1280" height="960" loading="lazy" decoding="async" alt="ごみ焼却施設の排ガス処理フローの図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 32</span><h3>ごみ焼却施設の排ガス処理フロー</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-33.html" aria-label="図解33：焼却排ガス中の水銀と除去対策を詳しく見る"><img src="assets/topics/air-large/topic-33.webp" width="1280" height="960" loading="lazy" decoding="async" alt="焼却排ガス中の水銀と除去対策の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 33</span><h3>焼却排ガス中の水銀と除去対策</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
<a class="la-ill-card" href="pollution-air-large-topic-34.html" aria-label="図解34：ダイオキシン類の生成・再合成と抑制を詳しく見る"><img src="assets/topics/air-large/topic-34.webp" width="1280" height="960" loading="lazy" decoding="async" alt="ダイオキシン類の生成・再合成と抑制の図解"/><div class="la-ill-card-body"><span class="la-ill-num">THEME 34</span><h3>ダイオキシン類の生成・再合成と抑制</h3><span class="la-ill-more">図解・解説を見る ↗</span></div></a>
</div>
<div class="la-ill-end"><div><strong>34テーマをまとめて探す</strong><p>キーワード検索・カテゴリ絞り込みができる専用一覧ページも用意しています。</p></div><a href="pollution-air-large-topics.html">図解34テーマ一覧へ ↗</a></div>
</div></section>
'@
    $page = $page.Replace('<section class="a-section" id="comparison">', $gallery + [Environment]::NewLine + '<section class="a-section" id="comparison">')
    # Sランク・Aランクの各項目に関連する図解への直接リンクを設定
    $rankMap = @(
        @{ Name='安定度・温位・大気境界層'; Rank='S1'; Topics=@(2,3,5) }
        @{ Name='乱流・パスキル安定度・拡散幅'; Rank='S2'; Topics=@(1,14,15) }
        @{ Name='正規形プルーム式と濃度計算'; Rank='S3'; Topics=@(13,16,17) }
        @{ Name='排煙上昇・有効煙突高さ・ダウンウォッシュ'; Rank='S4'; Topics=@(9,10,11) }
        @{ Name='拡散予測モデルの選定'; Rank='S5'; Topics=@(18,19,21) }
        @{ Name='石炭火力の排ガス処理系列'; Rank='S6'; Topics=@(22,23,24) }
        @{ Name='都市ごみ焼却の汚染物質と対策'; Rank='S7'; Topics=@(31,32,33,34) }
        @{ Name='大規模産業のSOx・NOx発生源と処理'; Rank='S8'; Topics=@(27,28,29) }
        @{ Name='製油所の脱硫・硫黄回収'; Rank='A1'; Topics=@(27) }
        @{ Name='鉄鋼の焼結炉とコークス炉'; Rank='A2'; Topics=@(29) }
        @{ Name='セメント工程のNOx・SOx・粉じん'; Rank='A3'; Topics=@(28) }
        @{ Name='長期平均濃度と風向セクター'; Rank='A4'; Topics=@(20) }
        @{ Name='海陸風・逆転層・ヒュミゲーション'; Rank='A5'; Topics=@(4,6,12) }
        @{ Name='重油火力のSO3・アンモニア注入'; Rank='A6'; Topics=@(25) }
    )
    $matches = 0
    foreach ($item in $rankMap) {
        $buttons = '<div class="la-related"><span class="la-related-label">対応する図解</span>'
        foreach ($n in $item.Topics) {
            $num = '{0:D2}' -f [int]$n
            $buttons += '<a class="la-related-link" href="pollution-air-large-topic-' + $num + '.html" aria-label="図解' + $num + 'を開く">図解' + $num + ' ↗</a>'
        }
        $buttons += '</div>'
        if ($item.Rank.StartsWith('S')) {
            $pattern = '(?s)(<h3>' + [regex]::Escape($item.Name) + '</h3>\s*<p class="hint">.*?</p>)'
        } else {
            $pattern = '(<h3>' + [regex]::Escape($item.Name) + '</h3>)'
        }
        $rx = [regex]::new($pattern)
        if (-not $rx.IsMatch($page)) { throw ('ランクカードが見つかりません: ' + $item.Rank + ' ' + $item.Name) }
        $page = $rx.Replace($page,[System.Text.RegularExpressions.MatchEvaluator]{ param($m) $m.Value + $buttons },1)
        $matches++
    }
    if ($matches -ne 14) { throw 'リンク数を確認できないため更新を中止しました。' }
    # 過去の大気有害物質特論のOGメタ情報が残っていた場合は、大規模大気特論へ修正
    $page = $page.Replace('大気有害物質特論｜過去10年100問の徹底分析・S/Aランク重要ポイント', '大規模大気特論｜過去10年100問の徹底分析・S/Aランク重要ポイント')
    $page = $page.Replace('公害防止管理者・大気有害物質特論のH28〜R7過去10年100問を独自分析。出題位置、S/Aランク、吸収・吸着・有害物質・JIS分析法、学習順、直前確認を1ページに。', '公害防止管理者・大規模大気特論の過去10年100問を独自分析。S/Aランク重要テーマと34枚の図解を関連づけ、気象・拡散モデル・排煙処理を体系的に学べます。')
    [System.IO.File]::WriteAllText($source,$page,$utf8)
    Write-Host '更新成功：大規模大気特論の分析ページに34テーマ一覧・S/Aランクの図解リンクを追加しました。' -ForegroundColor Green
    Write-Host 'GitHub Desktop で変更を確認し、Commit → Push origin してください。' -ForegroundColor Green
} catch {
    Write-Host ('更新エラー：' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
