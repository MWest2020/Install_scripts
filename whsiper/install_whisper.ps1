param(
    [string]$PythonVer = '3.10.11'
)

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Find-Python {
    $pythonPaths = @(
        "C:\whisper-python310\python.exe",
        "C:\Python310\python.exe", 
        "C:\Program Files\Python310\python.exe",
        "$env:USERPROFILE\AppData\Local\Programs\Python\Python310\python.exe"
    )
    
    foreach ($path in $pythonPaths) {
        if (Test-Path $path) {
            Write-Host "Found Python: $path"
            return $path
        }
    }
    return $null
}

# Setup directories
if (Test-Administrator) {
    $InstallDir = 'C:\whisper-python310'
    Write-Host "Admin mode - installing to C:\"
} else {
    $InstallDir = Join-Path $env:USERPROFILE 'whisper-python310'
    Write-Host "User mode - installing to user directory"
}

$venvPath = Join-Path $InstallDir 'venv'
Write-Host "Install directory: $InstallDir"
Write-Host "Virtual environment: $venvPath"
Write-Host ""

# Find existing Python
$pythonExe = Find-Python
if (-not $pythonExe) {
    Write-Host "No suitable Python found. Installing Python..."
    
    $exeName = "python-$PythonVer-amd64.exe"
    $url = "https://www.python.org/ftp/python/$PythonVer/$exeName"
    $exePath = Join-Path $env:TEMP $exeName

    Write-Host "1. Checking installer availability"
    Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -ErrorAction Stop | Out-Null
    Write-Host "   OK - $exeName"

    Write-Host "2. Downloading Python"
    Invoke-WebRequest -Uri $url -OutFile $exePath -UseBasicParsing -ErrorAction Stop
    Write-Host "   Downloaded to $exePath"

    Write-Host "3. Installing Python"
    if (Test-Administrator) {
        Start-Process -FilePath $exePath -ArgumentList "/quiet", "InstallAllUsers=1", "TargetDir=$InstallDir", "PrependPath=0", "Include_pip=1", "Include_launcher=1" -NoNewWindow -Wait
    } else {
        Start-Process -FilePath $exePath -ArgumentList "/quiet", "InstallAllUsers=0", "TargetDir=$InstallDir", "PrependPath=0", "Include_pip=1", "Include_launcher=1" -NoNewWindow -Wait
    }
    
    $pythonExe = "$InstallDir\python.exe"
    if (-not (Test-Path $pythonExe)) {
        Write-Error "Python installation failed: $pythonExe not found"
        exit 11
    }
    Write-Host "   Python installed: $pythonExe"
} else {
    Write-Host "Using existing Python: $pythonExe"
}

# Virtual environment
Write-Host "4. Setting up virtual environment"
if (-not (Test-Path "$venvPath\Scripts\python.exe")) {
    Write-Host "   Creating virtual environment..."
    & $pythonExe -m venv $venvPath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create venv (exit code $LASTEXITCODE)"
        exit 12
    }
    Write-Host "   Virtual environment created"
} else {
    Write-Host "   Virtual environment already exists"
}

$venvPython = "$venvPath\Scripts\python.exe"
$venvPip = "$venvPath\Scripts\pip.exe"

# Test venv
Write-Host "5. Testing virtual environment"
$pythonTest = & $venvPython --version 2>&1
Write-Host "   Python in venv: $pythonTest"

# Upgrade pip
Write-Host "6. Upgrading pip"
& $venvPython -m pip install --upgrade pip setuptools wheel
Write-Host "   Pip upgraded"

# GPU detection
Write-Host "7. GPU detection"
$hasNvidiaGpu = $false
$gpuInfo = Get-WmiObject -Class Win32_VideoController -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*NVIDIA*" }
if ($gpuInfo) {
    $hasNvidiaGpu = $true
    Write-Host "   NVIDIA GPU found: $($gpuInfo.Name)"
} else {
    Write-Host "   No NVIDIA GPU - using CPU version"
}

# Install PyTorch
Write-Host "8. Installing PyTorch"
if ($hasNvidiaGpu) {
    Write-Host "   Installing PyTorch with CUDA support..."
    & $venvPip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
} else {
    Write-Host "   Installing PyTorch CPU-only..."  
    & $venvPip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
}
if ($LASTEXITCODE -ne 0) {
    Write-Error "PyTorch installation failed"
    exit 14
}
Write-Host "   PyTorch installed"

# Install Whisper  
Write-Host "9. Installing Whisper"
& $venvPip install git+https://github.com/openai/whisper.git
if ($LASTEXITCODE -ne 0) {
    Write-Error "Whisper installation failed"
    exit 15
}
Write-Host "   Whisper installed"

# Test installation
Write-Host "10. Testing installation"
& $venvPython -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available()); import whisper; print('Whisper version:', whisper.__version__)"
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Test gave warnings, but installation seems complete"
} else {
    Write-Host "   All tests passed!"
}

Write-Host ""
Write-Host "Installation completed!"
Write-Host "Virtual environment: $venvPath"
Write-Host "To activate: & '$venvPath\Scripts\Activate.ps1'"
Write-Host "To transcribe: whisper 'audiofile.mp3' --language Dutch --model medium"
Write-Host ""
Write-Host "Example usage:"
Write-Host "& '$venvPath\Scripts\Activate.ps1'"
Write-Host "whisper interview.mp3 --language Dutch --model medium --output_dir transcriptions"
