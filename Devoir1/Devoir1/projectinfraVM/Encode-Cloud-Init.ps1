param (
    [string]$ArtifactUrl="https://dev.azure.com/saranmadykeita84/_apis/resources/Containers/71840469/Devoir1-win-x64?itemPath=Devoir1-win-x64%2FWebApplication1.zip",
    [string]$Pat =""
)

$path = "azuredeploy.parameters.json"
$json = Get-Content $path -Raw | ConvertFrom-Json


$cloudInitContent = Get-Content -Raw -Path "cloud-init.txt"
$encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($cloudInitContent))

Write-Output $encoded

if ($json.parameters.customData) {
    $json.parameters.customData.value = $encoded
} else {
    $json.parameters.customData = @{ value = $encoded }
}

$json | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $path


# Load and modify cloud-init.txt
$cloudInitPath = "cloud-init.txt"
$cloudInitContent = Get-Content -Raw -Path $cloudInitPath

# Replace placeholders in cloud-init.txt
$cloudInitContent = $cloudInitContent -replace 'AUTH_HEADER_PLACEHOLDER', $Pat
$cloudInitContent = $cloudInitContent -replace 'ARTIFACT_URL_PLACEHOLDER', $ArtifactUrl

# Encode the modified cloud-init content
$encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($cloudInitContent))
Write-Output "Encoded cloud-init content: $encoded"

# Update azuredeploy.parameters.json
$path = "azuredeploy.parameters.json"
$json = Get-Content $path -Raw | ConvertFrom-Json

if ($json.parameters.customData) {
    $json.parameters.customData.value = $encoded
} else {
    $json.parameters.customData = @{ value = $encoded }
}

$json | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $path