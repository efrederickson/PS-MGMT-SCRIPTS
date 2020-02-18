function _Write-Common {
    param(
        $ForegroundColor
    )

    $args | % {
        Write-Host -ForegroundColor $ForegroundColor '[*]' $_
    }
}

function Write-Red {
    _Write-Common -ForegroundColor "Red" $args
}

function Write-Green {
    _Write-Common -ForegroundColor "Green" $args
}

function Write-Yellow {
    _Write-Common -ForegroundColor "Yellow" $args
}