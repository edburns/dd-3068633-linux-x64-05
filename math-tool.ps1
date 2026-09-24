[CmdletBinding()]
param(
    [Parameter()]
    [ValidateRange(0, [int]::MaxValue)]
    [int] $N = 0,

    [Parameter()]
    [ValidateSet('fibonacci', 'factorial')]
    [string] $Operation = 'fibonacci'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Fibonacci {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $N
    )

    [long] $previous = 0
    [long] $current = 1
    for ($i = 0; $i -lt $N; $i++) {
        $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $previous
}

function Get-Factorial {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $N
    )

    [long] $result = 1
    for ($i = 2; $i -le $N; $i++) {
        $result = $result * $i
    }

    return $result
}

if ($MyInvocation.InvocationName -ne '.') {
    switch ($Operation) {
        'factorial' { Write-Output ("Factorial({0}) = {1}" -f $N, (Get-Factorial -N $N)) }
        default { Write-Output ("Fibonacci({0}) = {1}" -f $N, (Get-Fibonacci -N $N)) }
    }
}
