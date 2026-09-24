Set-StrictMode -Version Latest

BeforeAll {
    $script:ScriptPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $script:ScriptPath

    function Invoke-MathToolCli {
        param(
            [Parameter(Mandatory)]
            [int] $N
        )

        $stdout = & pwsh -NoLogo -NoProfile -File $script:ScriptPath -N $N
        return [pscustomobject]@{
            Lines    = @($stdout)
            ExitCode = $LASTEXITCODE
        }
    }
}

Describe 'Get-Fibonacci' {
    It 'returns <Expected> for N=<N>' -ForEach @(
        @{ N = 0; Expected = 0 }
        @{ N = 1; Expected = 1 }
        @{ N = 10; Expected = 55 }
    ) {
        Get-Fibonacci -N $N | Should -Be $Expected
    }

    It 'emits exactly one numeric value and no incidental output for N=<N>' -ForEach @(
        @{ N = 0 }
        @{ N = 1 }
        @{ N = 10 }
    ) {
        $output = @(Get-Fibonacci -N $N)
        $output.Count | Should -Be 1
        $output[0] | Should -BeOfType [long]
    }

    It 'does not emit the direct-execution result line when dot-sourced' {
        $output = @(. $script:ScriptPath)
        $output.Count | Should -Be 0
    }
}

Describe 'math-tool.ps1 direct CLI execution' {
    It 'writes exactly "<Expected>" and exits zero for N=<N>' -ForEach @(
        @{ N = 0; Expected = 'Fibonacci(0) = 0' }
        @{ N = 1; Expected = 'Fibonacci(1) = 1' }
        @{ N = 10; Expected = 'Fibonacci(10) = 55' }
    ) {
        $result = Invoke-MathToolCli -N $N
        $result.ExitCode | Should -Be 0
        $result.Lines.Count | Should -Be 1
        $result.Lines[0] | Should -BeExactly $Expected
    }

    It 'does not match a differently formatted line for N=10' {
        $result = Invoke-MathToolCli -N 10
        $result.Lines[0] | Should -Not -BeExactly 'fibonacci(10) = 55'
        $result.Lines[0] | Should -Not -BeExactly 'Fibonacci(10)=55'
    }
}
