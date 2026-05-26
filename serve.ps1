# 로컬 미리보기 (같은 Wi-Fi에서 폰 QR 테스트용)
$port = 8765
Set-Location $PSScriptRoot

$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
  $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169\.'
} | Select-Object -First 1).IPAddress

Write-Host "PC에서 열기:     http://localhost:$port/" -ForegroundColor Green
if ($ip) {
  Write-Host "폰에서 QR 테스트: http://${ip}:$port/" -ForegroundColor Yellow
  Write-Host "(index.html을 위 주소로 연 뒤 QR을 스캔하세요)" -ForegroundColor DarkGray
}
Write-Host "종료: Ctrl+C" -ForegroundColor DarkGray
python -m http.server $port
