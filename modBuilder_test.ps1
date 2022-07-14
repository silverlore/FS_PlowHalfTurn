$include = @("*.xml", "*.lua", "*.dds", "src\vehicles\specialization\*.lua", "src\*.lua", "translations\*.xml")
$zipFilename = "FS22_PlowHalfTurn.zip"

if(test-path "$env:ProgramFiles\WinRAR\WinRAR.exe"){
    Set-Alias winrar "$env:ProgramFiles\WinRAR\WinRar.exe"
    Start-Process -wait -FilePath winrar -ArgumentList "a -afzip $zipFilename $include"

    Copy-Item .\$zipFilename $home'\Documents\my games\FarmingSimulator2022\mods\'
}