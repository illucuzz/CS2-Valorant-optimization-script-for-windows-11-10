# Optimise-CS2.ps1
# Version: 1.0.0
# Purpose: Apply PC optimizations on-demand for smooth gaming on poor internet conditions.
# When the script starts, it immediately applies optimizations and monitors until the game closes.
# Usage:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
#   .\Optimise-CS2.ps1 -ProcessNames cs2,hl2
#   .\Optimise-CS2.ps1 -ProcessNames cs2,hl2 -Aggressive
#
# Notes:
# - Run as Administrator.
# - Optimizations are applied immediately when the script starts.
# - Optimizations are restored when the monitored game process closes.

[CmdletBinding()]
param(
  [ValidateNotNullOrEmpty()]
  [string[]]$ProcessNames = @('cs2','hl2'),
  
  [ValidateRange(1, 60)]
  [int]$PollIntervalSeconds = 2,
  
  [switch]$Aggressive,
  [switch]$DryRun
)

$ScriptVersion = "1.0.0"

function Test-Admin {
  <#
  .SYNOPSIS
    Check if the script is running with Administrator privileges.
  #>
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $pr = New-Object Security.Principal.WindowsPrincipal($id)
  return $pr.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not $DryRun -and -not (Test-Admin)) {
  Write-Error "Administrator privileges required. Re-open PowerShell as Administrator and re-run this script."
  exit 1
}

Write-Output "========================================"
Write-Output "Optimise-CS2 v$ScriptVersion"
Write-Output "========================================"
Write-Output "Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })"
Write-Output "Monitoring process names: $($ProcessNames -join ', ')"
Write-Output ""

# Service management configuration
$servicesDefault = @('DoSvc')
$servicesAggressive = @('wuauserv','BITS')
$servicesToManage = $servicesDefault + (if ($Aggressive) { $servicesAggressive } else { @() })

# State tracking
$originalServiceStates = @{}
$oneDriveExe = Join-Path $env:LOCALAPPDATA "Microsoft\OneDrive\OneDrive.exe"
$oneDriveWasRunning = $false
$appliedChanges = $false
$gameDetected = $false

function Get-GameProcesses {
  <#
  .SYNOPSIS
    Retrieve running instances of monitored game processes.
  #>
  $procs = @()
  foreach ($name in $ProcessNames) {
    $ps = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($ps) { $procs += $ps }
  }
  return $procs
}

function Record-And-StopService {
  <#
  .SYNOPSIS
    Record the current state of a service and stop it if running.
  #>
  param($svcName)
  $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
  if (-not $svc) {
    Write-Verbose "Service $svcName not found"
    return
  }
  
  $originalServiceStates[$svcName] = $svc.Status
  
  if ($svc.Status -eq 'Running') {
    if ($DryRun) {
      Write-Output "[DRYRUN] Would stop service: $svcName"
    }
    else {
      try {
        Stop-Service -Name $svcName -Force -ErrorAction Stop
        Write-Output "[OK] Stopped service: $svcName"
        $script:appliedChanges = $true
      }
      catch {
        Write-Warning "[WARN] Failed to stop ${svcName}: $($_.Exception.Message)"
      }
    }
  }
  else {
    Write-Output "[INFO] Service not running: $svcName (state: $($svc.Status))"
  }
}

function Apply-Optimizations {
  <#
  .SYNOPSIS
    Apply all configured optimizations.
  #>
  Write-Output "Applying optimizations..."
  Write-Output ""
  
  # Stop bandwidth-consuming services
  foreach ($svc in $servicesToManage) {
    Record-And-StopService $svc
  }

  # Stop OneDrive in aggressive mode
  if ($Aggressive) {
    $od = Get-Process -Name OneDrive -ErrorAction SilentlyContinue
    if ($od) {
      $oneDriveWasRunning = $true
      if ($DryRun) {
        Write-Output "[DRYRUN] Would stop OneDrive (PID $($od.Id))"
      }
      else {
        try {
          Stop-Process -Id $od.Id -Force -ErrorAction Stop
          Write-Output "[OK] Stopped OneDrive (PID $($od.Id))"
          $appliedChanges = $true
        }
        catch {
          Write-Warning "[WARN] Failed to stop OneDrive: $($_.Exception.Message)"
        }
      }
    }
  }

  # Set game process priority to High
  $gameProcs = Get-GameProcesses
  if ($gameProcs.Count -gt 0) {
    $script:gameDetected = $true
    foreach ($p in $gameProcs) {
      try {
        $pid = $p.Id
        if ($DryRun) {
          Write-Output "[DRYRUN] Would set priority High for PID $pid ($($p.ProcessName))"
        }
        else {
          $p.PriorityClass = 'High'
          Write-Output "[OK] Set process priority to High: $($p.ProcessName) [PID $pid]"
          $script:appliedChanges = $true
        }
      }
      catch {
        Write-Warning "[WARN] Could not change priority for PID ${pid}: $($_.Exception.Message)"
      }
    }
  }
  else {
    Write-Output "[INFO] No game process detected yet. Will check when you launch the game."
  }
  
  Write-Output ""
}

function Restore-Optimizations {
  <#
  .SYNOPSIS
    Restore system to original state before optimizations.
  #>
  Write-Output ""
  Write-Output "Restoring system state..."
  Write-Output ""
  
  # Restart services
  foreach ($svcName in $originalServiceStates.Keys) {
    $wasRunning = $originalServiceStates[$svcName] -eq 'Running'
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    
    if ($wasRunning -and $svc.Status -ne 'Running') {
      if ($DryRun) {
        Write-Output "[DRYRUN] Would start service: $svcName"
      }
      else {
        try {
          Start-Service -Name $svcName -ErrorAction Stop
          Write-Output "[OK] Started service: $svcName"
        }
        catch {
          Write-Warning "[WARN] Could not start ${svcName}: $($_.Exception.Message)"
        }
      }
    }
    else {
      Write-Output "[INFO] Service was not running before (state: $($svc.Status)); leaving as-is."
    }
  }

  # Restart OneDrive if it was running
  if ($oneDriveWasRunning) {
    if ($DryRun) {
      Write-Output "[DRYRUN] Would restart OneDrive"
    }
    else {
      if (Test-Path $oneDriveExe) {
        try {
          Start-Process -FilePath $oneDriveExe -ArgumentList "/background" -ErrorAction Stop
          Write-Output "[OK] Restarted OneDrive"
        }
        catch {
          Write-Warning "[WARN] Failed to restart OneDrive: $($_.Exception.Message)"
        }
      }
      else {
        Write-Warning "[WARN] OneDrive executable not found: $oneDriveExe"
      }
    }
  }

  if (-not $appliedChanges) {
    Write-Output "[INFO] No changes were applied."
  }
  else {
    Write-Output "[OK] Restore complete."
  }
  
  Write-Output ""
  Write-Output "========================================"
  Write-Output "Optimization session ended."
  Write-Output "========================================"
}

try {
  # Apply optimizations immediately
  Apply-Optimizations

  if (-not $gameDetected -and -not $DryRun) {
    Write-Output "Waiting for game process to appear..."
    while ((Get-GameProcesses).Count -eq 0) {
      Start-Sleep -Seconds $PollIntervalSeconds
    }
    
    Write-Output ""
    Write-Output "Game detected! Applying priority boost..."
    
    # Apply priority to newly detected game
    $gameProcs = Get-GameProcesses
    foreach ($p in $gameProcs) {
      try {
        $p.PriorityClass = 'High'
        Write-Output "[OK] Set process priority to High: $($p.ProcessName) [PID $($p.Id)]"
        $script:appliedChanges = $true
      }
      catch {
        Write-Warning "[WARN] Could not change priority: $($_.Exception.Message)"
      }
    }
  }

  Write-Output ""
  Write-Output "Optimizations active. Waiting for game to close..."
  Write-Output "(Press Ctrl+C to stop and restore)"
  Write-Output ""

  # Monitor until game process exits
  while ((Get-GameProcesses).Count -ne 0) {
    Start-Sleep -Seconds $PollIntervalSeconds
  }

  Write-Output ""
  Write-Output "Game process ended. Cleaning up..."
}
catch {
  Write-Error "An error occurred: $($_.Exception.Message)"
}
finally {
  Restore-Optimizations
}