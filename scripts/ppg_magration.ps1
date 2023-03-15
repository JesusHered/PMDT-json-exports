$database = "master"
$contentDataBaseFolderPath = "/sitecore/content/pmdt-jss-site/Content/Database"
$mediaFolderPath = "/sitecore/media library/pmdt-jss-site/data/media/img/ProMedica/ProMedicaLocations"
$newLocationFolderPath = "$($contentDataBaseFolderPath)/Locations_230105/PPG"
$defaultLocationPath = "$($newLocationFolderPath)/Default PPG Template"
$oldLocationFolderPath = "$($contentDataBaseFolderPath)/NewLocations/PPG"
$servicesTemplate = "/sitecore/templates/Project/pmdt-jss-site/Services"
$amenitieTemplate =  "/sitecore/templates/Project/pmdt-jss-site/LocationsAndDoctors/Locations/_contentTemplates/AmenitiesContent"
$oldTemplateName = "AssistedLiving"

function Create-LocationStructureFromJson
{
    Process
    {
        Set-HostProperty -BackgroundColor Yellow
        Set-HostProperty -ForegroundColor Black
        Write-Host "****************************************************"
        Write-Host "New Location Structure Data Creation Process Started"
        Write-Host "****************************************************"
        Write-Host ""

        $jsonData = $jsonData =  curl 'https://raw.githubusercontent.com/JesusHered/PMDT-json-exports/master/locations-details.json' -UseBasicParsing
        $jsonData = $jsonData | ConvertFrom-Json
        $newLocations = Get-Item -Path $oldLocationFolderPath

        foreach($newLocation in $newLocations.Children)
        {
            $locationName = $newLocation.name
            $locationName = Set-TrimString -str $locationName
            $locationName = $locationName.replace("Consultants in Laboratory Medicine ","Consultants in Laboratory Medicine")
            $locationName = $locationName.replace("ProMedica Physicians Pediatric Cardiology  Sandusky ","ProMedica Physicians Pediatric Cardiology and Sandusky")
            $locationName = $locationName.replace("ProMedica Physicians Jobst Vascular  Bellevue ","ProMedica Physicians Jobst Vascular  Bellevue")
            
            $newPath = "$($newLocationFolderPath)/$($locationName)"
            Set-HostProperty -BackgroundColor Yellow
            Write-Host "    Copy default folder into: $($newPath)"
            Set-HostProperty -BackgroundColor Red
            
            
            $locationNamePathExist = Test-Path -Path $newPath
            if(-Not $locationNamePathExist)
            {
                Copy-Item -Path $defaultLocationPath -Destination $newPath -Recurse
            }
            
            $pageNewLocationPath = $oldLocationFolderPath + "/" + $newLocation.name + "/data"
            $pageNewLocation = Get-Item -Path $pageNewLocationPath

            
            $newPathItemPage = "$($database):$newPath/Page"
            $pageItem = Get-Item -Path $newPathItemPage
            $pageItem.Editing.BeginEdit()
                $pageItem["Page Title"]  = $pageNewLocation.Fields["PageTitle"]
                $pageItem["Meta Description"]  = $pageNewLocation.Fields["MetaDescription"]
                $pageItem["Page Type"]  = $pageNewLocation.Fields["PageType"]
                $pageItem["Custom Keywords"]  = $pageNewLocation.Fields["CustomKeywords"]
                $pageItem["Effective Keywords"]  = $pageNewLocation.Fields["EffectiveKeywords"]
                $pageItem["Canonical URL"]  = $pageNewLocation.Fields["SeoCanonicalURL"]
                $pageItem["Open Graph - Type"]  = $pageNewLocation.Fields["OpenGraphType"]
                $pageItem["Open Graph - Description"]  = $pageNewLocation.Fields["OpenGraphDescription"]
                $pageItem["Robots"]  = $pageNewLocation.Fields["Robots"]    
                $pageItem["Slug"]  = $pageNewLocation.Fields["DirectURL"]    

                $pageItem["Enabled"]  = $pageNewLocation.Fields["Enabled"]
                $pageItem["Location ID"]  = $pageNewLocation.Fields["LocationId"]
                $pageItem["Hero Image"]  = $pageNewLocation.Fields["HeroImage"]
                $pageItem["Address1"]  = $pageNewLocation.Fields["Address"]
                $pageItem["Address2"]  = $pageNewLocation.Fields["Address"]
                $pageItem["City"]  = $pageNewLocation.Fields["City"]
                $pageItem["State"]  = $pageNewLocation.Fields["State"]
                $pageItem["Zip"]  = $pageNewLocation.Fields["ZipCode"]
                $pageItem["Latitude"]  = $pageNewLocation.Fields["Latitude"]
                $pageItem["Longitude"]  = $pageNewLocation.Fields["Longitude"]
                $pageItem["Campus Map Download"]  = $pageNewLocation.Fields["DownloadMap"]
                $pageItem["Phone"]  = $pageNewLocation.Fields["Phone"]
                $pageItem["Fax"]  = $pageNewLocation.Fields["Fax"]
                $pageItem["Email"]  = $pageNewLocation.Fields["Email"]
                $pageItem["Intro Copy Heading"]  = $pageNewLocation.Fields["DescriptionHeading"]
                $pageItem["Intro Copy Body"]  = $pageNewLocation.Fields["DescriptionBody"]
                $pageItem["FAQs"]  = $pageNewLocation.Fields["Faqs"]
            $pageItem.Editing.EndEdit()
            
            
            foreach ($row in $jsonData) {
                $urlPath = "https://www.promedica.org/location/" + $pageNewLocation.Fields["DirectURL"]
                if($row.url -eq $urlPath)
                {
                    if(-not ([string]::IsNullOrEmpty($row.content.imgSrc))){
                        $imageSrc = $row.content.imgSrc.replace(".jpg","")
                        $imageSrc =  $imageSrc.replace("https://www.promedica.org/assets/images/ih/locations/","")
                        $imageHeroPath = $mediaFolderPath + "/" + $imageSrc
                        $imageHero = Get-Item -Path $imageHeroPath
                        $pageItem.Editing.BeginEdit()
                            $pageItem["Hero Image"]  = "<image mediaid='$($imageHero.Id)' />"
                        $pageItem.Editing.EndEdit()
                    }

                    $pageItem = Get-Item -Path "$($database):$newPath/Tabbed Content/Services"
                    $pageItem.Editing.BeginEdit()
                    $services = "<ul>"
                    foreach($service in $row.content.services){
                        $services += "<li>$service</li>"
                    }
                    $services += "</ul>";
                    $pageItem["Content"] =  $services
                    $pageItem.Editing.EndEdit()
                    Write-Host "    Services item was update with JSON DATA"

                    $pageItem = Get-Item -Path "$($database):$newPath/Tabbed Content/Volunteering"
                    $pageItem.Editing.BeginEdit()
                    $pageItem["Content"] = $row.content.volunteer
                    $pageItem.Editing.EndEdit()
                    Write-Host "    Volunteer Hours item was update with JSON DATA"

                    $pageItem = Get-Item -Path "$($database):$newPath/Tabbed Content/Education and Credentials"
                    $educations = "<ul>"
                    foreach($education in $row.content.education){
                        $educations += "<li>$education</li>"
                    }
                    $educations += "</ul>";
                    $pageItem.Editing.BeginEdit()
                    $pageItem["Content"] = $educations
                    $pageItem.Editing.EndEdit()
                    Write-Host "    Education Hours item was update with JSON DATA"

                }
            }
        }
    }
}

function Verif-AmenitiesExist
{
    Param([System.String] $AmenitieName) 
    Process
    {
        $AmenitieName =  Set-TrimString -str $AmenitieName
        Write-Host "            Verif Amenitie Exist: $($AmenitieName)"
        $AmenitiesPath = "/sitecore/content/pmdt-jss-site/Content/Database/Locations_230105/Hospital/Global_Hospital_Content/Amenities/"
        $AmenitiePath  = $AmenitiesPath + $AmenitieName
        $AmenitieNamePathExist = Test-Path -Path $AmenitiePath

        if(-Not $AmenitieNamePathExist)
        {
            Write-Host "            Amenitie not exist: $($AmenitieName)"
            New-Item -Path $AmenitiesPath -Name $AmenitieName -ItemType $amenitieTemplate 
            Write-Host "            Amenitie created: $($AmenitieName)"
            
        }else{
            Write-Host "            Amenitie exist: $($AmenitieName)"
        }
        $amenitie = Get-Item -Path $AmenitiePath
        Write-Host "*********************************            Amenitie id: $($amenitie.ID.ToString())"
        return $amenitie.ID.ToString()
    }
}

function Verif-ServiceExist
{
    Param([System.String] $ServiceName) 
    Process
    {
        $ServiceName =  Set-TrimString -str $ServiceName
        Write-Host "            Verif Service Exist: $($ServiceName)"
        $servicesPath = "/sitecore/content/pmdt-jss-site/Content/Database/Services/"
        $servicePath  = $servicesPath + $ServiceName
        $ServiceNamePathExist = Test-Path -Path $servicePath

        if(-Not $ServiceNamePathExist)
        {
            Write-Host "            Service not exist: $($ServiceName)"
            New-Item -Path $servicesPath -Name $ServiceName -ItemType $servicesTemplate 
            Write-Host "            Service created: $($ServiceName)"
            
        }else{
            Write-Host "            Service exist: $($ServiceName)"
        }
        $service = Get-Item -Path $servicePath
        Write-Host "*********************************            Service id: $($service.ID.ToString())"
        return $service.ID.ToString()
    }
}

## Function that return the name of an image from a given url
function Get-ImageNameFromUrl
{
    Param([System.String] $ImgUrl)
    Process
    {
        Write-Host "            Get-ImageNameFromUrl: $($ImgUrl)"
        $imgArray = $ImgUrl.Split("/")
        $imgNameExt = $imgArray[$imgArray.Length - 1]
        $imgName = $imgNameExt.Split(".")
        return $imgName[0]
    }
}

## Function that trim a string, removing several characters to avoid issues when a new item is created
function Set-TrimString
{
    Param([System.String] $str)
    Process
    {
        Write-Host "            Set-TrimString: $($str)"
        ## Sitecore item name cannot contain any of the following characters: \/:?"<>|[].
        $newStr = $str
        $newStr = $newStr.replace("|","")
        $newStr = $newStr.replace("(","")
        $newStr = $newStr.replace(")","")
        $newStr = $newStr.replace(",","")
        $newStr = $newStr.replace("-","")
        $newStr = $newStr.replace("\","")
        $newStr = $newStr.replace("/","")
        $newStr = $newStr.replace(":","")
        $newStr = $newStr.replace("?","")
        $newStr = $newStr.replace("<","")
        $newStr = $newStr.replace(">","")
        $newStr = $newStr.replace("[","")
        $newStr = $newStr.replace("]","")
        $newStr = $newStr.replace("{","")
        $newStr = $newStr.replace("}","")
        $newStr = $newStr.replace(".","")
        $newStr = $newStr.replace("&","and")
        Write-Host "            Set-TrimString, result: $($newStr)"
        return $newStr
    }
}

Create-LocationStructureFromJson
