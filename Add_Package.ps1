#========================================================================
#
# Tool Name	: ENTITY TOOL WINDOWS 10
# Author 	: Damien VAN ROBAEYS
#
#========================================================================

param
	(
		[String]$deploymentshare,
		[String]$module
	)

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null

[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo] "en-US"

Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("Add_Package.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																		 VARIABLES DEFINITION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$object = New-Object -comObject Shell.Application  
$User = $env:USERNAME
$Date = get-date -format "dd/MM/yyyy hh:mm:ss"
$Global:Current_Folder =(get-location).path 

$Control_Folder = "$deploymentshare\Control"
$MDT_Update_1 = "6.3.8298.1000"
$MDT_Update_2 = "6.3.8330.1000"


########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################


#************************************************************************** BROWSE SOURCES BUTTON ***********************************************************************************************
$Package_source = $Form.findname("Package_source") 
#************************************************************************** SOURCES TEXBOX ***********************************************************************************************
$Package_source_textbox = $Form.findname("Package_source_textbox") 
#************************************************************************** ADD APPLICATION BUTTON ***********************************************************************************************
$ADD_Package_XML = $Form.findname("ADD_Package_XML") 

$Package_source_textbox.IsEnabled = $false



########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	

########################################################################################################################################################################################################
#                        																BROWSE APPLI BUTTON                                   
########################################################################################################################################################################################################	
	
$Package_source.Add_Click({	### action on button
    $folder = $object.BrowseForFolder(0, $message, 0, 0) 
    If ($folder -ne $null) { 
        $global:Package_sources_folder = $folder.self.Path 
		$global:Package_source_name = split-path  $folder.self.Path -leaf -resolve		
		$Package_source_textbox.Text =  $Package_sources_folder	
    } 	
})		
	
	

########################################################################################################################################################################################################
#                        																ADD APPLICATION BUTTON                                   
########################################################################################################################################################################################################	
	
$ADD_Package_XML.Add_Click({		
	
	If ($Package_source_textbox.Text -eq "")
		{
			$Package_source_textbox.BorderBrush = "Red"				

		}
	Else
		{								
			Import-Module $module				
			$PSDrive_Test = get-psdrive
			If ($PSDrive_Test -eq "DSAppManager")
				{
					Remove-PSDrive -Name "DSAppManager"		
					New-PSDrive -Name "DSAppManager" -PSProvider MDTProvider -Root $deploymentshare								
				}
			Else
				{
					New-PSDrive -Name "DSAppManager" -PSProvider MDTProvider -Root $deploymentshare		
				}			
						
			import-mdtpackage -path "DSAppManager:\Packages" -SourcePath $Package_sources_folder -Verbose
			[System.Windows.Forms.MessageBox]::Show("Package has been correctly added. You can close the window.") 		
		}		
})		
		
	
	
$Form.ShowDialog() | Out-Null
