#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$DistDir = Join-Path $RootDir 'docs\.vuepress\dist'
$EnvFile = Join-Path $ScriptDir '.env.deploy'
$Tarball = Join-Path $ScriptDir 'dist-deploy.tar.gz'

$TotalSteps = 5
$Script:DeployStart = Get-Date

function Write-Banner {
  Write-Host ''
  Write-Host '  ========================================' -ForegroundColor DarkCyan
  Write-Host '       VuePress Build and Deploy' -ForegroundColor Cyan
  Write-Host '  ========================================' -ForegroundColor DarkCyan
  Write-Host ''
}

function Write-StepList {
  $steps = @(
    'Check environment and config',
    'Build site',
    'Package files',
    'Upload to server',
    'Done'
  )
  Write-Host '  Steps:' -ForegroundColor DarkGray
  for ($i = 0; $i -lt $steps.Count; $i++) {
    Write-Host ('    [{0}/{1}] {2}' -f ($i + 1), $TotalSteps, $steps[$i]) -ForegroundColor DarkGray
  }
  Write-Host ''
}

function Update-Progress {
  param(
    [int]$Step,
    [string]$Status,
    [int]$Percent = -1
  )

  $title = 'VuePress Deploy'
  $label = "[$Step/$TotalSteps] $Status"

  if ($Percent -ge 0) {
    Write-Progress -Activity $title -Status $label -PercentComplete $Percent
  }
  else {
    Write-Progress -Activity $title -Status $label -Indeterminate
  }

  Write-Host ''
  Write-Host $label -ForegroundColor Cyan
}

function Show-ProgressBar {
  param(
    [int]$Percent,
    [string]$Label = ''
  )

  $width = 36
  $filled = [math]::Min($width, [math]::Floor($width * $Percent / 100))
  $empty = $width - $filled
  $bar = ('#' * $filled) + ('-' * $empty)
  Write-Host ('  [{0}] {1,3}%  {2}' -f $bar, $Percent, $Label) -ForegroundColor Yellow
}

function Complete-Progress {
  Write-Progress -Activity 'VuePress Deploy' -Completed
}

function Write-Ok([string]$Message) {
  Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Err([string]$Message) {
  Write-Host "  [ERR] $Message" -ForegroundColor Red
}

function Write-Info([string]$Message) {
  Write-Host "  [..] $Message" -ForegroundColor DarkGray
}

function Get-Elapsed {
  $elapsed = (Get-Date) - $Script:DeployStart
  return '{0:mm}m {0:ss}s' -f $elapsed
}

function Load-EnvFile([string]$Path) {
  if (-not (Test-Path $Path)) {
    throw "Config not found: $Path. Copy deploy/.env.deploy.example to deploy/.env.deploy"
  }

  Get-Content $Path -Encoding UTF8 | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }
    if ($line -match '^\s*([^#=]+)=(.*)$') {
      $name = $matches[1].Trim()
      $value = $matches[2].Trim().Trim('"').Trim("'")
      Set-Item -Path "Env:$name" -Value $value
    }
  }
}

function Get-SshArgs([string]$KeyPath) {
  $args = @()
  if ($KeyPath -and (Test-Path $KeyPath)) {
    $args += @('-i', $KeyPath)
  }
  $args += @('-o', 'StrictHostKeyChecking=accept-new')
  return $args
}

function Test-Command([string]$Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Build {
  Update-Progress -Step 2 -Status 'Building site (please wait)...' -Percent 20
  Show-ProgressBar -Percent 20 -Label 'building'

  Push-Location $RootDir
  try {
    if (Test-Command 'pnpm') {
      pnpm docs:build
      if ($LASTEXITCODE -ne 0) { throw "Build failed, exit code $LASTEXITCODE" }
    }
    elseif (Test-Command 'npm') {
      npm run docs:build
      if ($LASTEXITCODE -ne 0) { throw "Build failed, exit code $LASTEXITCODE" }
    }
    else {
      throw 'pnpm or npm not found'
    }
  }
  finally {
    Pop-Location
  }

  if (-not (Test-Path $DistDir)) {
    throw "Build failed, dist not found: $DistDir"
  }

  $fileCount = (Get-ChildItem $DistDir -Recurse -File).Count
  Update-Progress -Step 2 -Status 'Build finished' -Percent 55
  Show-ProgressBar -Percent 55 -Label 'build done'
  Write-Ok "Build done, $fileCount files"
}

function Invoke-Upload-Tar {
  param(
    [string]$HostName,
    [string]$User,
    [int]$Port,
    [string]$RemotePath,
    [string[]]$SshArgs
  )

  Update-Progress -Step 3 -Status 'Creating tarball...' -Percent 60
  Show-ProgressBar -Percent 60 -Label 'packaging'

  if (Test-Path $Tarball) { Remove-Item $Tarball -Force }

  tar -czf $Tarball -C $DistDir .
  $sizeMb = [math]::Round((Get-Item $Tarball).Length / 1MB, 2)
  Write-Ok "Tarball created ($sizeMb MB)"

  Update-Progress -Step 4 -Status 'Uploading to server...' -Percent 75
  Show-ProgressBar -Percent 75 -Label 'uploading'

  $remote = "$User@$HostName"
  $remoteTar = "$RemotePath/dist-deploy.tar.gz"

  $scpArgs = @('-P', $Port.ToString()) + $SshArgs + @($Tarball, "${remote}:${remoteTar}")
  & scp @scpArgs

  Update-Progress -Step 4 -Status 'Extracting on server...' -Percent 88
  Show-ProgressBar -Percent 88 -Label 'extracting'

  $remoteCmd = "mkdir -p $RemotePath; tar -xzf $remoteTar -C $RemotePath; rm -f $remoteTar"
  $sshArgs = @('-p', $Port.ToString()) + $SshArgs + @($remote, $remoteCmd)
  & ssh @sshArgs

  Remove-Item $Tarball -Force
  Write-Ok 'Upload and extract done'
}

function Invoke-Upload-Rsync {
  param(
    [string]$HostName,
    [string]$User,
    [int]$Port,
    [string]$RemotePath,
    [string[]]$SshArgs
  )

  Update-Progress -Step 4 -Status 'Uploading via rsync...' -Percent 75
  Show-ProgressBar -Percent 75 -Label 'rsync'

  $sshCmd = "ssh -p $Port"
  if ($SshArgs.Count -gt 0) {
    $sshCmd += ' ' + ($SshArgs -join ' ')
  }

  $source = Join-Path $DistDir '/'
  $target = "$User@${HostName}:$RemotePath/"

  & rsync -avz --delete -e $sshCmd $source $target
  Write-Ok 'rsync upload done'
}

function Invoke-Upload-Scp {
  param(
    [string]$HostName,
    [string]$User,
    [int]$Port,
    [string]$RemotePath,
    [string[]]$SshArgs
  )

  Update-Progress -Step 4 -Status 'Uploading via scp...' -Percent 75
  Show-ProgressBar -Percent 75 -Label 'scp'

  $remote = "$User@${HostName}:$RemotePath/"
  $scpArgs = @('-P', $Port.ToString(), '-r') + $SshArgs + @("$DistDir/.", $remote)
  & scp @scpArgs
  Write-Ok 'scp upload done'
}

try {
  if ($Host.UI.RawUI) {
    $Host.UI.RawUI.WindowTitle = 'VuePress Deploy - Running'
  }

  Write-Banner
  Write-StepList

  Update-Progress -Step 1 -Status 'Checking environment...' -Percent 5
  Set-Location $RootDir

  if (-not (Test-Command 'ssh') -or -not (Test-Command 'scp')) {
    throw 'ssh/scp not found. Install OpenSSH Client on Windows'
  }
  Write-Ok 'ssh/scp available'

  Load-EnvFile $EnvFile
  Write-Ok 'Config loaded'

  $hostName = $env:DEPLOY_HOST
  $user = $env:DEPLOY_USER
  $port = if ($env:DEPLOY_PORT) { [int]$env:DEPLOY_PORT } else { 22 }
  $remotePath = $env:DEPLOY_PATH
  $keyPath = $env:DEPLOY_KEY
  $method = if ($env:DEPLOY_METHOD) { $env:DEPLOY_METHOD.ToLower() } else { 'auto' }

  if (-not $hostName -or -not $user -or -not $remotePath) {
    throw 'Set DEPLOY_HOST, DEPLOY_USER, DEPLOY_PATH in deploy/.env.deploy'
  }

  $sshArgs = Get-SshArgs $keyPath

  Show-ProgressBar -Percent 10 -Label 'ready'
  Write-Info "Target: ${user}@${hostName}:${port}${remotePath}"

  Invoke-Build

  switch ($method) {
    'tar' { Invoke-Upload-Tar $hostName $user $port $remotePath $sshArgs }
    'rsync' { Invoke-Upload-Rsync $hostName $user $port $remotePath $sshArgs }
    'scp' { Invoke-Upload-Scp $hostName $user $port $remotePath $sshArgs }
    'auto' {
      if (Test-Command 'tar') {
        Invoke-Upload-Tar $hostName $user $port $remotePath $sshArgs
      }
      elseif (Test-Command 'rsync') {
        Invoke-Upload-Rsync $hostName $user $port $remotePath $sshArgs
      }
      else {
        Invoke-Upload-Scp $hostName $user $port $remotePath $sshArgs
      }
    }
    default { throw "Unknown DEPLOY_METHOD: $method" }
  }

  Update-Progress -Step 5 -Status 'Deploy finished' -Percent 100
  Show-ProgressBar -Percent 100 -Label 'done'
  Complete-Progress

  if ($Host.UI.RawUI) {
    $Host.UI.RawUI.WindowTitle = 'VuePress Deploy - Success'
  }

  Write-Host ''
  Write-Host '  ========================================' -ForegroundColor Green
  Write-Host "  Deploy success! Elapsed: $(Get-Elapsed)" -ForegroundColor Green
  Write-Host '  Visit: https://wenzhaohui.com' -ForegroundColor Green
  Write-Host '  ========================================' -ForegroundColor Green
  Write-Host ''
}
catch {
  Complete-Progress

  if ($Host.UI.RawUI) {
    $Host.UI.RawUI.WindowTitle = 'VuePress Deploy - Failed'
  }

  Write-Host ''
  Write-Err $_.Exception.Message
  Write-Host "  Elapsed: $(Get-Elapsed)" -ForegroundColor DarkGray
  exit 1
}
