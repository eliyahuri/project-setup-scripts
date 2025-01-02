param(
    [string]$Name = "typescript-example"
)

# Set the project name from the argument
$projectName = $Name

# Check if the project directory exists, and create it if not
if (-Not (Test-Path -Path $projectName)) {
    New-Item -Path $projectName -ItemType Directory
}

# Change to the project directory
Set-Location -Path $projectName

# Initialize a new pnpm project using npx
npx pnpm init

# Install TypeScript as a dev dependency
npx pnpm add -D typescript

# Install ts-node for running TypeScript files directly
npx pnpm add -D ts-node

# Install @types/node for Node.js type definitions
npx pnpm add -D @types/node

# Install Prettier as a dev dependency
npx pnpm add -D prettier

# Install ESLint and TypeScript plugins
npx pnpm add -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Install Airbnb ESLint config for TypeScript and necessary plugins
npx pnpm add -D eslint-config-airbnb-typescript eslint-plugin-import eslint-import-resolver-typescript

# Install @eslint/eslintrc for FlatCompat
npx pnpm add -D @eslint/eslintrc

# Create a basic tsconfig.json
$tsconfig = @{
    compilerOptions = @{
        target = "ESNext"
        module = "CommonJS"
        strict = $true
        esModuleInterop = $true
        skipLibCheck = $true
        forceConsistentCasingInFileNames = $true
        outDir = "./dist"
    }
    include = @("src/**/*.ts")
}

$tsConfigFormatted = $tsconfig | ConvertTo-Json -Depth 10
$tsConfigFormatted | Set-Content -Path "tsconfig.json"

# Check if the src directory exists, and create it if not
if (-Not (Test-Path -Path "src")) {
    New-Item -Path "src" -ItemType Directory
}

# Create a sample TypeScript file
Set-Content -Path "src/index.ts" -Value @'
console.log("Hello, TypeScript!");
'@

# Create a .gitignore file
Set-Content -Path ".gitignore" -Value @'
node_modules
dist
'@

# Create a .dockerignore file
Set-Content -Path ".dockerignore" -Value @'
node_modules
dist
'@

# Create a Dockerfile
Set-Content -Path "Dockerfile" -Value @'
# Use the official Node.js LTS version
FROM node:lts

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install

# Copy the source code
COPY . .

# Build the TypeScript code
RUN pnpm run build

# Expose the port (if needed)
EXPOSE 8080

# Run the application
CMD ["node", "dist/index.js"]
'@

# Create a Prettier configuration file with tab width 4
Set-Content -Path ".prettierrc" -Value @'
{
    "tabWidth": 4
}
'@

# Create a .prettierignore file
Set-Content -Path ".prettierignore" -Value @'
node_modules
dist
'@

# Create an eslint.config.js file using CommonJS syntax and Flat Configuration
Set-Content -Path "eslint.config.js" -Value @'
const { FlatCompat } = require("@eslint/eslintrc");
const compat = new FlatCompat();

module.exports = [
    {
        ignores: ["node_modules", "dist"],
    },
    ...compat.extends(
        "airbnb-base",
        "airbnb-typescript/base",
        "plugin:@typescript-eslint/recommended"
    ),
    {
        files: ["src/**/*.ts"],
        languageOptions: {
            parser: "@typescript-eslint/parser",
            parserOptions: {
                project: "./tsconfig.json",
                tsconfigRootDir: __dirname,
                sourceType: "module",
            },
        },
        plugins: {
            "@typescript-eslint": require("@typescript-eslint/eslint-plugin"),
        },
        rules: {
            indent: ["error", 4],
            // Additional rules can be added here
        },
    },
];
'@

# Check if package.json exists before trying to modify it
if (Test-Path -Path "package.json") {
    $packageJson = Get-Content -Path "package.json" -Raw | ConvertFrom-Json
    $packageJson.scripts = @{
        build = 'tsc'
        dev = 'ts-node src/index.ts'
        start = 'node dist/index.js'
        lint = 'eslint "src/**/*.{ts,tsx}"'
        format = 'prettier --write "src/**/*.{ts,tsx}"'
    }
    $packageJsonFormatted = $packageJson | ConvertTo-Json -Depth 10
    $packageJsonFormatted | Set-Content -Path "package.json"
}

# Open the project in VSCode
code .

# Print success message
Write-Host "TypeScript project setup complete!" -ForegroundColor Green

# Close the terminal
exit
