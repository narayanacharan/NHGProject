param(
  $rgName,
  $cdnProfileName,
  $stgAcc1,
  $stgAcc2,
  $cdnEp1,
  $cdnEp2
)


Describe "Azure Resource Group" {
    Context "It is created" {
        BeforeAll{$rg = Get-AzResourceGroup -Name $rgName}
        It "Should be provisioned successfully" {
            $rg.ProvisioningState | Should -Be "Succeeded"
        }
        It "Should be named correctly" {
            $rg.ResourceGroupName | Should -Be "NextOps"
        }
    }
}



Describe "Azure Blue App Storage Account Test"{
    Context "Azure Storage Account Tests"{
        BeforeAll {$stgEp1 = (Get-AzStorageAccount -ResourceGroupName $rgName -Name $stgAcc1 |select PrimaryEndpoints).PrimaryEndpoints.Web
                   $content = curl $stgEp1 | select -ExpandProperty Content  
            }
        It "Validate the blue static site url"{
            $stgEp1 | Should -Be "https://$stgAcc1.z13.web.core.windows.net/"
        }
        It "Valudate blue app is accessible and delivering OK"{
            $content | Should -Match "<h1>Blue Deployment: Example static website v1</h1>"
        }        
    }
}

Describe "Azure Green Storage Account Test"{
    Context "Azure Storage Account Tests"{
        BeforeAll{$stgEp2 = (Get-AzStorageAccount -ResourceGroupName $rgName -Name $stgAcc2 |select PrimaryEndpoints).PrimaryEndpoints.Web
                  $content = curl $stgEp2 | select -ExpandProperty Content
            }
        It "Validate green the static site url"{
            $stgEp2 | Should -Be "https://$stgAcc2.z13.web.core.windows.net/"
        }
        It "Valudate green app is accessible and delivering OK"{
            $content | Should -Match "<h1>Green Deployment: Example static website v2</h1>"
        }            
    }
}

Describe "Azure CDN Test" {
    Context "Azure CDN exists" {
        BeforeAll {$cdnProfile = Get-AzCdnProfile -name $cdnProfileName -ResourceGroupName $rgName }
        It "Should be provisioned successfully" {
            $cdnProfile.ProvisioningState | Should -Be "Succeeded"            
        }
        It "Should be of Type Microsoft.Cdn/profiles" {
            $cdnProfile.Type | Should -Be "Microsoft.Cdn/profiles"
        }
        It "Should be in Active State"{
            $cdnProfile.ResourceState | Should -Be "Active"
        }
        It "Should be of Sku Standard_Microsoft"{
            $cdnProfile.SkuName | Should -Be "Standard_Microsoft"
        }    
    }
}


Describe "Azure Blue CDN Endpoint Test"{
        BeforeAll {
            $cdnEp1Url = Get-AzCdnEndpoint -ProfileName $cdnProfileName -ResourceGroupName $rgName -Name $cdnEp1
            $cdnEp1Hostname = $cdnEp1Url.HostName
            $cdnEp1Content = curl https://$cdnEp1Hostname | select -ExpandProperty Content
        }
        It "Should be provisioned successfully"{
            $cdnEp1Url.ProvisioningState | Should -Be "Succeeded"
        }
        It "Should be mapped to Blue Storage Account"{
            $cdnEp1Url.OriginHostHeader | Should -Be "$stgAcc1.z13.web.core.windows.net"
        }
        It "Should be accessible and serving blue app content OK"{
            $cdnEp1Content | Should -Match "<h1>Blue Deployment: Example static website v1</h1>"            
        }


}

Describe "Azure Green CDN Endpoint Test"{
        BeforeAll {
            $cdnEp2Url = Get-AzCdnEndpoint -ProfileName $cdnProfileName -ResourceGroupName $rgName -Name $cdnEp2
            $cdnEp2Hostname = $cdnEp2Url.HostName
            $cdnEp2Content = curl https://$cdnEp2Hostname | select -ExpandProperty Content        
        }
        It "Should be provisioned successfully"{
            $cdnEp2Url.ProvisioningState | Should -Be "Succeeded"
        }
        It "Should be mapped to Green Storage Account"{
            $cdnEp2Url.OriginHostHeader | Should -Be "$stgAcc2.z13.web.core.windows.net"
        }
        It "Should be accessible and serving green app content OK"{
            $cdnEp2Content | Should -Match "<h1>Green Deployment: Example static website v2</h1>"            
        }


}