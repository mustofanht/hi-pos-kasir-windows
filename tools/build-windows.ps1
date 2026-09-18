<#
.SYNOPSIS
    Sinkronkan kode terbaru dari GitLab (enhance-hipos) ke branch build GitHub,
    lalu picu GitHub Actions "Build Windows EXE".

.DESCRIPTION
    Urutan yang dikerjakan:
      1. Pastikan working tree bersih.
      2. git fetch hipos          (ambil kode terbaru dari GitLab)
      3. git checkout enhance-hipos-windows
      4. git rebase hipos/enhance-hipos
      5. git push github enhance-hipos-windows --force-with-lease
      6. Picu build (lewat GitHub CLI kalau ada) & buka halaman Actions.

.PARAMETER Target
    Target server aplikasi: dev (default) atau production.

.PARAMETER SkipSync
    Lewati langkah fetch/rebase/push; langsung picu build dari kode yang sudah
    ada di GitHub.

.EXAMPLE
    .\tools\build-windows.ps1
    Sinkronkan lalu build memakai server dev.

.EXAMPLE
    .\tools\build-windows.ps1 -Target production
    Sinkronkan lalu build installer untuk PC kasir (server produksi).
#>
[CmdletBinding()]
param(
    [ValidateSet('dev', 'production')]
    [string]$Target = 'dev',

    [switch]$SkipSync
)

$ErrorActionPreference = 'Stop'

$BuildBranch   = 'enhance-hipos-windows'
$SourceBranch  = 'hipos/enhance-hipos'
$WorkflowFile  = 'build-windows.yml'
$ActionsUrl    = 'https://github.com/mustofanht/hi-pos-kasir-windows/actions'

function Write-Step([string]$text) { Write-Host "`n==> $text" -ForegroundColor Cyan }
function Write-Note([string]$text) { Write-Host "    $text" -ForegroundColor DarkGray }

# Selalu bekerja dari root repo, bukan dari folder tempat skrip dipanggil.
Set-Location (Split-Path $PSScriptRoot -Parent)

if (-not $SkipSync) {
    Write-Step "Memeriksa perubahan yang belum di-commit"
    $dirty = git status --porcelain
    if ($dirty) {
        Write-Host "Ada perubahan lokal yang belum di-commit:" -ForegroundColor Yellow
        $dirty | ForEach-Object { Write-Host "  $_" }
        throw "Commit atau 'git stash' dulu perubahan di atas, lalu jalankan ulang skrip ini."
    }

    Write-Step "Mengambil kode terbaru dari GitLab"
    git fetch hipos
    if ($LASTEXITCODE -ne 0) { throw "git fetch hipos gagal." }

    Write-Step "Pindah ke branch build '$BuildBranch'"
    git checkout $BuildBranch
    if ($LASTEXITCODE -ne 0) { throw "Branch $BuildBranch tidak ditemukan." }

    Write-Step "Menumpuk commit build di atas $SourceBranch"
    git rebase $SourceBranch
    if ($LASTEXITCODE -ne 0) {
        Write-Host @"

REBASE BERHENTI KARENA KONFLIK.
  - Lihat file bermasalah : git status
  - Pertahankan versi build: git checkout --theirs <file> ; git add <file>
  - Lanjutkan             : git rebase --continue
  - Atau batalkan semuanya: git rebase --abort
Setelah selesai, jalankan lagi skrip ini.
"@ -ForegroundColor Yellow
        throw "Rebase perlu diselesaikan manual."
    }

    Write-Step "Mengirim ke GitHub"
    git push github $BuildBranch --force-with-lease
    if ($LASTEXITCODE -ne 0) { throw "git push gagal." }
}

$gh = Get-Command gh -ErrorAction SilentlyContinue

if ($gh) {
    Write-Step "Memicu workflow lewat GitHub CLI (target: $Target)"
    gh workflow run $WorkflowFile --ref $BuildBranch -f env=$Target
    if ($LASTEXITCODE -ne 0) { throw "gh workflow run gagal. Picu manual lewat $ActionsUrl" }
    Write-Note "Pantau      : gh run watch"
    Write-Note "Unduh hasil : gh run download --name hipos-kasir-installer-$Target"
}
elseif ($Target -eq 'dev') {
    Write-Step "Build dev sudah terpicu otomatis oleh push barusan"
    Write-Note "Push ke $BuildBranch selalu membangun versi dev."
}
else {
    Write-Step "Build produksi perlu dijalankan manual dari halaman Actions"
    Write-Note "Actions -> Build Windows EXE -> Run workflow"
    Write-Note "Branch: $BuildBranch, Target server aplikasi: production"
    Write-Note "(Atau pasang GitHub CLI: winget install --id GitHub.cli, lalu gh auth login)"
}

Write-Step "Membuka halaman GitHub Actions"
Start-Process $ActionsUrl
Write-Note "Artifact hasil build: hipos-kasir-installer-$Target"
