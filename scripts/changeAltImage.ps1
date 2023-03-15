$pathsasa = "master:/sitecore/media library/pmdt-jss-site/data/media/img/ProMedica/Locations  Doctors/"
$importList = $importList =  curl 'https://raw.githubusercontent.com/JesusHered/PMDT-json-exports/master/locations%26doctors.json' -UseBasicParsing
$importList = $importList | ConvertFrom-Json
$c = 0
foreach ( $row in $importList ) {
    $imagePath = $pathsasa + $row.image.replace(".jpg","")
    $item = Get-Item -Path $imagePath 
    $item.Editing.BeginEdit()
    $item["Alt"] = $row.alt
    $item.Editing.EndEdit()
    write-host $item.image
}
