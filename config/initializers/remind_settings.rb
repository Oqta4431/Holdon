## リマインド間隔を定数で管理
## ⚠️本リリでは任意の間隔でリマインド出来るように改良する⚠️
if Rails.env.development?
  REMIND_INTERVAL = 5.seconds
else
  ## ⚠️ MVPレビュー用（短縮）_20260104
  REMIND_INTERVAL = 5.seconds
end
