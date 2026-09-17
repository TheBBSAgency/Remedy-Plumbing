# Removes 22 photo files that no page on this site references.
# Written by Claude. Deletes itself when finished.
$ErrorActionPreference = 'Stop'
$photos = Join-Path $PSScriptRoot 'assets\photos'

$names = @(
  'modern-sink-repair-card.jpg',      'modern-sink-repair-card.webp',
  'plumber-inspecting-sink-card.jpg', 'plumber-inspecting-sink-card.webp',
  'plumber-repairing-sink.jpg',       'plumber-repairing-sink.webp',
  'plumber-sink-closeup.jpg',         'plumber-sink-closeup.webp',
  'residential-plumbing-card.jpg',    'residential-plumbing-card.webp',
  'residential-plumbing.jpg',         'residential-plumbing.webp',
  'tools-blueprint-card.jpg',         'tools-blueprint-card.webp',
  'water-heater-checkup.jpg',         'water-heater-checkup.webp',
  'water-heater-install-card.jpg',    'water-heater-install-card.webp',
  'water-heater-repair-card.jpg',     'water-heater-repair-card.webp',
  'water-heater-valve-card.jpg',      'water-heater-valve-card.webp'
)

# Belt and braces: refuse to delete anything still referenced by a page.
$pages = Get-ChildItem -LiteralPath $PSScriptRoot -Filter *.html
$referenced = @()
foreach ($n in $names) {
  $enc = $n -replace ' ', '%20'
  foreach ($p in $pages) {
    $t = Get-Content -LiteralPath $p.FullName -Raw
    if ($t.Contains($n) -or $t.Contains($enc)) { $referenced += $n; break }
  }
}
if ($referenced.Count -gt 0) {
  Write-Host "ABORT - these are still referenced by a page:" -ForegroundColor Red
  $referenced | ForEach-Object { Write-Host "  $_" }
  exit 1
}

$found = @()
foreach ($n in $names) {
  $p = Join-Path $photos $n
  if (Test-Path -LiteralPath $p) { $found += Get-Item -LiteralPath $p }
}

Write-Host ("Target list: {0} files.  Present on disk: {1}." -f $names.Count, $found.Count)
$kb = [math]::Round((($found | Measure-Object Length -Sum).Sum) / 1KB)
$found | ForEach-Object { Write-Host ("  {0,-38} {1,8:N0} bytes" -f $_.Name, $_.Length) }

$found | Remove-Item -Force
Write-Host ("Deleted {0} files, {1} KB reclaimed." -f $found.Count, $kb) -ForegroundColor Green

$left = $names | Where-Object { Test-Path -LiteralPath (Join-Path $photos $_) }
if ($left) {
  Write-Host "STILL PRESENT:" -ForegroundColor Red
  $left | ForEach-Object { Write-Host "  $_" }
} else {
  Write-Host "VERIFIED: all 22 removed." -ForegroundColor Green
}

Remove-Item -LiteralPath $PSCommandPath -Force
Write-Host "Script removed itself. DONE."
