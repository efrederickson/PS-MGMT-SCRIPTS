
# Helper function to load in the 'lib' scripts easier
function Expand-RelativeLibPaths {
    $ret = @( )
    $args | % {
        $path = $PSScriptRoot + [System.IO.Path]::DirectorySeparatorChar + $_ + ".psm1"
        $ret += $path
    }
    return $ret
}