Set-StrictMode -Version Latest

BeforeAll {
    $script:ScriptPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $script:ScriptPath

    function Invoke-MathToolCli {
        param(
            [Parameter(Mandatory)]
            [int] $N,

            [Parameter()]
            [string] $Operation = 'fibonacci'
        )

        $stdout = & pwsh -NoLogo -NoProfile -File $script:ScriptPath -N $N -Operation $Operation
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

    It 'writes the Fibonacci line when the fibonacci operation is selected explicitly for N=<N>' -ForEach @(
        @{ N = 0; Expected = 'Fibonacci(0) = 0' }
        @{ N = 1; Expected = 'Fibonacci(1) = 1' }
        @{ N = 10; Expected = 'Fibonacci(10) = 55' }
    ) {
        $result = Invoke-MathToolCli -N $N -Operation 'fibonacci'
        $result.ExitCode | Should -Be 0
        $result.Lines.Count | Should -Be 1
        $result.Lines[0] | Should -BeExactly $Expected
    }
}

Describe 'Get-Factorial' {
    It 'returns <Expected> for N=<N>' -ForEach @(
        @{ N = 0; Expected = 1 }
        @{ N = 1; Expected = 1 }
        @{ N = 5; Expected = 120 }
    ) {
        Get-Factorial -N $N | Should -Be $Expected
    }

    It 'emits exactly one numeric value and no incidental output for N=<N>' -ForEach @(
        @{ N = 0 }
        @{ N = 1 }
        @{ N = 5 }
    ) {
        $output = @(Get-Factorial -N $N)
        $output.Count | Should -Be 1
        $output[0] | Should -BeOfType [long]
    }
}

Describe 'math-tool.ps1 factorial CLI execution' {
    It 'writes exactly "<Expected>" and exits zero for N=<N>' -ForEach @(
        @{ N = 0; Expected = 'Factorial(0) = 1' }
        @{ N = 1; Expected = 'Factorial(1) = 1' }
        @{ N = 5; Expected = 'Factorial(5) = 120' }
    ) {
        $result = Invoke-MathToolCli -N $N -Operation 'factorial'
        $result.ExitCode | Should -Be 0
        $result.Lines.Count | Should -Be 1
        $result.Lines[0] | Should -BeExactly $Expected
    }

    It 'does not match a differently formatted line for N=5' {
        $result = Invoke-MathToolCli -N 5 -Operation 'factorial'
        $result.Lines[0] | Should -Not -BeExactly 'factorial(5) = 120'
        $result.Lines[0] | Should -Not -BeExactly 'Factorial(5)=120'
        $result.Lines[0] | Should -Not -BeExactly 'Fibonacci(5) = 5'
    }
}
