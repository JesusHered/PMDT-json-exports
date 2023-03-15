$pathMediaImages = "master:/sitecore/pmdt-jss-site/data/media/img/ProMedica/ProvidersLive/"
$pathProviders = "master:/sitecore/content/pmdt-jss-site/Content/Database/Providers_230126/"
$importList = $importList =  curl 'https://raw.githubusercontent.com/LuigiEspinosa/promedica-scraper/main/json/ProMedica/doctors/doctors-details.json' -UseBasicParsing
$importList = $importList | ConvertFrom-Json
$providers = Get-Item -Path $pathProviders

foreach ( $provider in $providers.Children) {
    $pathPage = $pathProviders + $provider.name + "/" + "Page"
    $page = Get-Item -Path $pathPage
    $slug = $page["Slug"]
    
    $slugNotFoundInJson = 0
    foreach ($row in $importList){
        $jsonSlug = $row.url.replace("https://www.promedica.org/provider/","")
        if($jsonSlug -eq $slug){
            $slugNotFoundInJson = 1
            $image = $row.content.imgSrc.replace("https://www.promedica.org/assets/images/ih/providers/","")
            $pathProviderImage = $pathMediaImages + $image.replace(".svg","").replace(".jpg","").replace(".png","")
            $providerImage = Test-Path -Path $pathProviderImage
            if(-Not $providerImage) {
                Set-HostProperty -BackgroundColor Red
                Set-HostProperty -ForegroundColor Black
                Write-Host "Image not found" $image " By slug " $slug
            }
        }
    }
    
    if($slugNotFoundInJson -eq 0){
        Set-HostProperty -BackgroundColor Green
        Set-HostProperty -ForegroundColor Black
        Write-Host "Slug not found in json" $slug
    }
}
