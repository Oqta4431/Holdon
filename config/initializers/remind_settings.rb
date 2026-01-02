## リマインド間隔を定数で管理
## ⚠️本リリでは任意の間隔でリマインド出来るように改良する⚠️
if Rails.env.development?
  REMIND_INTERVAL = 1.minute
else
  REMIND_INTERVAL = 24.hours
end