Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Archive,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$DestinationPath
)
if (Get-Command Expand-Archive -ErrorAction SilentlyContinue) {
    Get-Item $Archive | Expand-Archive -DestinationPath $DestinationPath -Force
} else {
    CScript unzip.vbs //B //Nologo $Archive $DestinationPath
}
