function Test-DeploymentServer
{
    param(
        [string]$Server
    )

    if(Test-Path $Server)
    {
        Write-DeployLog "Deployment server reachable."
        return $true
    }

    Write-DeployLog "Deployment server unavailable." "ERROR"
    return $false
}