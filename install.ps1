#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$BetterVersion = if ($env:BETTER_VERSION) { $env:BETTER_VERSION } else { "latest" }
$BetterInstallDir = if ($env:BETTER_INSTALL_DIR) { $env:BETTER_INSTALL_DIR } else { Join-Path $env:USERPROFILE ".local\bin" }
$BetterGithubReleasesUrl = if ($env:BETTER_GITHUB_RELEASES_URL) {
    $env:BETTER_GITHUB_RELEASES_URL
} else {
    "https://github.com/logesh45/better-source-control/releases"
}

if (-not $env:BETTER_RELEASE_BASE_URL) {
    if ($BetterVersion -eq "latest") {
        $env:BETTER_RELEASE_BASE_URL = "$BetterGithubReleasesUrl/latest/download"
    } else {
        $env:BETTER_RELEASE_BASE_URL = "$BetterGithubReleasesUrl/download/v$BetterVersion"
    }
}

function Die([string]$Message) {
    [Console]::Error.WriteLine("better installer: $Message")
    exit 1
}

function Release-Target {
    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        "AMD64" { return "x86_64-pc-windows-msvc" }
        "ARM64" { return "aarch64-pc-windows-msvc" }
        default { Die "unsupported Windows architecture: $arch" }
    }
}

function Fetch-File([string]$Url, [string]$Dest) {
    if ($Url -like "file://*") {
        $src = $Url.Substring("file://".Length)
        if ($src -match "^/[A-Za-z]:") {
            $src = $src.Substring(1)
        }
        $src = $src -replace "/", "\"
        Copy-Item -LiteralPath $src -Destination $Dest -Force
        return
    }
    if ($Url -like "http://*" -or $Url -like "https://*") {
        Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing
        return
    }
    Die "unsupported download URL: $Url"
}

function Sha256-File([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

$target = Release-Target
$workdir = Join-Path ([System.IO.Path]::GetTempPath()) ("better-install-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Path $workdir | Out-Null
try {
    $baseUrl = $env:BETTER_RELEASE_BASE_URL.TrimEnd("/")
    $manifest = Join-Path $workdir "manifest.json"
    Fetch-File "$baseUrl/manifest.json" $manifest

    $manifestJson = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
    $artifact = @($manifestJson.artifacts) | Where-Object { $_.target -eq $target } | Select-Object -First 1
    if (-not $artifact) {
        Die "manifest does not include target: $target"
    }
    $artifactName = [string]$artifact.name
    $artifactUrl = [string]$artifact.url
    $expectedSha256 = ([string]$artifact.sha256).ToLowerInvariant()
    if (-not $artifactName) {
        Die "manifest entry for $target is missing name"
    }
    if (-not $expectedSha256) {
        Die "manifest entry for $target is missing sha256"
    }
    if (-not $artifactUrl) {
        $artifactUrl = "$baseUrl/$artifactName"
    } elseif ($artifactUrl -notmatch "^(file|https?):") {
        $artifactUrl = "$baseUrl/$artifactUrl"
    }

    $archive = Join-Path $workdir $artifactName
    Fetch-File $artifactUrl $archive
    $actualSha256 = Sha256-File $archive
    if ($actualSha256 -ne $expectedSha256) {
        Die "checksum mismatch for ${artifactName}: expected ${expectedSha256}, got ${actualSha256}"
    }

    $extractDir = Join-Path $workdir "extract"
    New-Item -ItemType Directory -Path $extractDir, $BetterInstallDir | Out-Null
    $nativeTar = Join-Path $env:SystemRoot "System32\tar.exe"
    if (-not (Test-Path -LiteralPath $nativeTar -PathType Leaf)) {
        Die "native Windows tar is unavailable at $nativeTar"
    }
    & $nativeTar -xzf $archive -C $extractDir
    if ($LASTEXITCODE -ne 0) {
        Die "failed to extract $artifactName"
    }

    $betterSrc = Get-ChildItem -LiteralPath $extractDir -Recurse -File -Filter "better.exe" | Select-Object -First 1
    $remoteSrc = Get-ChildItem -LiteralPath $extractDir -Recurse -File -Filter "better-remote.exe" | Select-Object -First 1
    if (-not $betterSrc) {
        Die "artifact does not contain better.exe"
    }
    if (-not $remoteSrc) {
        Die "artifact does not contain better-remote.exe"
    }

    $betterDest = Join-Path $BetterInstallDir "better.exe"
    $remoteDest = Join-Path $BetterInstallDir "better-remote.exe"
    Copy-Item -LiteralPath $betterSrc.FullName -Destination $betterDest -Force
    Copy-Item -LiteralPath $remoteSrc.FullName -Destination $remoteDest -Force

    $pathEntries = @($env:PATH -split ";" | Where-Object { $_ })
    $alreadyOnPath = $pathEntries -contains $BetterInstallDir
    $env:PATH = "$BetterInstallDir;$env:PATH"
    & $betterDest --version

    Write-Host "Installed better to $betterDest"
    Write-Host "Installed better-remote to $remoteDest"
    if (-not $alreadyOnPath) {
        Write-Host ""
        Write-Host "Add it to your PATH:"
        Write-Host "  $BetterInstallDir"
        Write-Host ""
        Write-Host "Then restart your terminal."
    }
}
finally {
    Remove-Item -LiteralPath $workdir -Recurse -Force -ErrorAction SilentlyContinue
}
