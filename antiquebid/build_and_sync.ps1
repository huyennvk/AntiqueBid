$files = Get-ChildItem -Path "src\main\java" -Recurse -Filter "*.java" | 
    Where-Object { $_.Name -notlike "*JakartaRestConfiguration*" -and $_.Name -notlike "*JakartaEE11Resource*" } | 
    Resolve-Path -Relative

& "C:\Program Files\Common Files\Oracle\Java\javapath\javac.exe" -encoding UTF-8 -cp "target/antiquebid-1.0-SNAPSHOT/WEB-INF/lib/*;target/antiquebid-1.0-SNAPSHOT/WEB-INF/classes" -d target/antiquebid-1.0-SNAPSHOT/WEB-INF/classes $files
if ($LASTEXITCODE -eq 0) {
    Write-Host "JAVAC_SUCCESS"
    Copy-Item -Path "src/main/webapp/*" -Destination "target/antiquebid-1.0-SNAPSHOT" -Recurse -Force
    Write-Host "SYNC_SUCCESS"
} else {
    Write-Host "JAVAC_FAILED" $LASTEXITCODE
}
