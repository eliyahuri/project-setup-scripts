param(
    [string]$Name = "MyPythonProject"
)

# Function to create a file with content
function Create-File {
    param(
        [string]$Path,
        [string]$Content
    )
    if (-Not (Test-Path -Path $Path)) {
        $Content | Set-Content -Path $Path -Encoding UTF8
    } else {
        Write-Host "File '$Path' already exists. Skipping creation." -ForegroundColor Yellow
    }
}

# Check if the project directory exists, and create it if not
if (-Not (Test-Path -Path $Name)) {
    New-Item -Path $Name -ItemType Directory | Out-Null
    Write-Host "Created project directory: $Name" -ForegroundColor Green
} else {
    Write-Host "Project directory '$Name' already exists. Skipping creation." -ForegroundColor Yellow
}

# Navigate to the project directory
Set-Location -Path $Name

# Initialize a new pnpm project
if (-Not (Test-Path -Path "package.json")) {
    pnpm init | Out-Null
    Write-Host "Initialized a new pnpm project." -ForegroundColor Green
} else {
    Write-Host "pnpm project already initialized." -ForegroundColor Yellow
}

# Install nodemon as a development dependency
pnpm add -D nodemon | Out-Null
Write-Host "Installed 'nodemon' as a development dependency." -ForegroundColor Green

# Create the src directory
if (-Not (Test-Path -Path "src")) {
    New-Item -Path "src" -ItemType Directory | Out-Null
    Write-Host "Created 'src' directory." -ForegroundColor Green
} else {
    Write-Host "'src' directory already exists. Skipping creation." -ForegroundColor Yellow
}

# Create the index.py file
Create-File -Path "src/index.py" -Content 'print("Hello, World!")'

# Add the "dev" script to package.json
$packageJsonPath = "package.json"
if (Test-Path -Path $packageJsonPath) {
    $packageJson = Get-Content -Path $packageJsonPath -Raw | ConvertFrom-Json
    if (-Not $packageJson.scripts) {
        $packageJson | Add-Member -MemberType NoteProperty -Name "scripts" -Value @{}
    }
    # Ensure $packageJson.scripts exists
    if (-not $packageJson.PSObject.Properties.Match('scripts')) {
        $packageJson | Add-Member -MemberType NoteProperty -Name scripts -Value @{}
    }
    
    # Ensure $packageJson.scripts.dev exists
    if (-not $packageJson.scripts.PSObject.Properties.Match('dev')) {
        $packageJson.scripts | Add-Member -MemberType NoteProperty -Name dev -Value ""
    }
    

    # Add the "dev" script to package.json
    pnpm pkg set scripts.dev="nodemon src/index.py"
    # # Set the dev script
    # $packageJson.scripts.dev = "nodemon src/index.py"
    # $packageJson | ConvertTo-Json -Depth 10 | Set-Content -Path $packageJsonPath -Encoding UTF8
    Write-Host "Added 'dev' script to package.json." -ForegroundColor Green
} else {
    Write-Host "Error: package.json not found." -ForegroundColor Red
}

# Create a .gitignore file
Create-File -Path ".gitignore" -Content @'
node_modules
'@

# Print success message
Write-Host "Python project setup complete!" -ForegroundColor Green

# Open the project in VSCode (if available)
if (Get-Command code -ErrorAction SilentlyContinue) {
    code .
    Write-Host "Opened project in VSCode." -ForegroundColor Green
} else {
    Write-Host "VSCode not found. Please open the project manually." -ForegroundColor Yellow
}

# Exit the script
exit
