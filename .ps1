#========================================================================
#
# Tool Name	: MDT CONTENT MANAGER V1.1
# Author 	: Damien VAN ROBAEYS
#
#========================================================================

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('MahApps.Metro.Controls.Dialogs')     | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') 	| out-null

Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("MDT_Content_Manager.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

#************************************************************************** OPEN DEPLOYMENTSHARE FOLDER  ***********************************************************************************************
$Open_Deploy = $Form.findname("Open_Deploy")
#************************************************************************** APPLICATIONS DATAGRID ******************************************************************************************************
$DataGrid_Applis = $form.FindName("DataGrid_Applis")
#************************************************************************** APPLICATIONS DATAGRID ******************************************************************************************************
$DataGrid_MUIs = $form.FindName("DataGrid_MUIs")
#************************************************************************** APPLICATIONS DATAGRID ******************************************************************************************************
$DataGrid_Packages = $form.FindName("DataGrid_Packages")
#************************************************************************** TEXTBOX FOR OPEN DEPLOY FOLDER *********************************************************************************************
$txtbox_Open = $form.FindName("txtbox_Open")
#************************************************************************** TAB CONTROL ****************************************************************************************************************
$Tab_Control = $form.FindName("Tab_Control")
#************************************************************************** ADD APPLICATION BUTTON *****************************************************************************************************
$Add_Content = $Form.findname("Add_Content") 
#************************************************************************** MODIFY APPLICATION BUTTON **************************************************************************************************
$Modify_Appli = $Form.findname("Modify_Appli") 
#************************************************************************** REMOVE APPLICATION BUTTON **************************************************************************************************
$Remove_Content = $Form.findname("Remove_Content") 
#************************************************************************** MDT VERSION LABEL **********************************************************************************************************
$MDT_Version_Label = $Form.findname("MDT_Version_Label") 
#************************************************************************** MDT VERSION CHECK ICON  ****************************************************************************************************
$Check_MDT_Icon = $Form.findname("Check_MDT_Icon") 
#************************************************************************** ABOUT **********************************************************************************************************************
$about = $Form.findname("about") 

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																		 VARIABLES DEFINITION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$Temp = $env:temp
$User = $env:USERPROFILE
$Date = get-date -format "dd-MM-yy_HHmm"
$Global:Current_Folder =(get-location).path 
$Global:Applis_Row_List = $DataGrid_Applis.items
$Global:MUIs_Row_List = $DataGrid_MUIs.items
$Global:Packages_Row_List = $DataGrid_Packages.items

$object = New-Object -comObject Shell.Application  
$Global:version_xml = "$deploymentshare\Control\Version.xml"
$MDT_Update_1 = "6.3.8298.1000"    
$MDT_Update_2 = "6.3.8330.1000"
$Control_Save = $User + "\desktop" + "\" + "MDT_Save\Deploy_Control_Save_$Date"    # Path for the control backup folder

#########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																			BUTTONS AND LABELS DEFAULT STATUS 
#*******************************************************************************************************************************************************************************************************
#########################################################################################################################################################################################################	

$Add_Content.IsEnabled = $false 
$Modify_Appli.IsEnabled = $false
$Remove_Content.IsEnabled = $false


#########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																			FUNCTIONS
#*******************************************************************************************************************************************************************************************************
#########################################################################################################################################################################################################	

Function Copy_Control_Folder # Function to backup your control folder
	{
		new-item $Control_Save -type directory		
		copy-item "$deploymentshare\Control" $Control_Save -recurse	
	}


Function Populate_Datagrid_Applis # Function to list your applications in the datagrid
	{	
		$Global:list_applis = ""
		$Input_Applications = ""
					
		$Global:list_applis = "$deploymentshare\Control\Applications.xml"						
		$Input_Applications = [xml] (Get-Content $list_applis)			
		foreach ($data in $Input_Applications.selectNodes("applications/application"))
			{
				$Applis_values = New-Object PSObject
				$Applis_values = $Applis_values | Add-Member NoteProperty Name $data.Name –passthru
				$Applis_values = $Applis_values | Add-Member NoteProperty ShortName $data.ShortName –passthru
				$Applis_values = $Applis_values | Add-Member NoteProperty Version $data.Version –passthru
				$Applis_values = $Applis_values | Add-Member NoteProperty Publisher $data.Publisher –passthru
				$Applis_values = $Applis_values | Add-Member NoteProperty Language $data.Language –passthru
				$Applis_values = $Applis_values | Add-Member NoteProperty Source $data.Source –passthru
				$Applis_values = $Applis_values | Add-Member NoteProperty CommandLine $data.CommandLine –passthru	
				$Applis_values = $Applis_values | Add-Member NoteProperty Comments $data.Comments –passthru		
				$Applis_values = $Applis_values | Add-Member NoteProperty Reboot $data.Reboot –passthru		
				$Applis_values = $Applis_values | Add-Member NoteProperty Enable $data.Enable –passthru		
				$Applis_values = $Applis_values | Add-Member NoteProperty Hide $data.Hide –passthru																	
				$DataGrid_Applis.Items.Add($Applis_values) > $null
			}			
	}	
	
	


Function Populate_Datagrid_MUIs # Function to list your applications in the datagrid
	{			
		$Global:list_MUIs = ""
		$Input_MUIs = ""		
		
		$Global:list_MUIs = "$deploymentshare\Control\Packages.xml"						
		$Input_MUIs = [xml] (Get-Content $list_MUIs)		
		$MUI_packages = $Input_MUIs.packages.package | Where {$_.PackageType -match "LanguagePack"}
		foreach ($data in $MUI_packages) 
			{
				$MUIs_values = New-Object PSObject
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Name $data.Name –passthru
				$MUIs_values = $MUIs_values | Add-Member NoteProperty PackageType $data.PackageType –passthru
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Language $data.Language –passthru
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Version $data.Version –passthru
				$MUIs_values = $MUIs_values | Add-Member NoteProperty ProductName $data.ProductName –passthru
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Architecture $data.Architecture –passthru
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Source $data.Source –passthru	
				$MUIs_values = $MUIs_values | Add-Member NoteProperty SupportInformation $data.SupportInformation –passthru		
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Comments $data.Comments –passthru						
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Reboot $data.Reboot –passthru		
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Enable $data.Enable –passthru		
				$MUIs_values = $MUIs_values | Add-Member NoteProperty Hide $data.Hide –passthru																	
				$DataGrid_MUIs.Items.Add($MUIs_values) > $null
			}		
	}	
	
	
	
Function Populate_Datagrid_Packages # Function to list your applications in the datagrid
	{	
		$Global:list_Packages = ""
		$Input_Packages = ""			

		$Global:list_Packages = "$deploymentshare\Control\Packages.xml"						
		$Input_Packages = [xml] (Get-Content $list_Packages)		
		$OnDemand_packages = $Input_Packages.packages.package | Where {$_.PackageType -match "OnDemandPack"}
		foreach ($data in $OnDemand_packages) 
			{
				$Packages_values = New-Object PSObject
				$Packages_values = $Packages_values | Add-Member NoteProperty Name $data.Name –passthru
				$Packages_values = $Packages_values | Add-Member NoteProperty PackageType $data.PackageType –passthru
				$Packages_values = $Packages_values | Add-Member NoteProperty Language $data.Language –passthru
				$Packages_values = $Packages_values | Add-Member NoteProperty Version $data.Version –passthru
				$Packages_values = $Packages_values | Add-Member NoteProperty ProductName $data.ProductName –passthru
				$Packages_values = $Packages_values | Add-Member NoteProperty Architecture $data.Architecture –passthru
				$Packages_values = $Packages_values | Add-Member NoteProperty Source $data.Source –passthru	
				$Packages_values = $Packages_values | Add-Member NoteProperty SupportInformation $data.SupportInformation –passthru		
				$Packages_values = $Packages_values | Add-Member NoteProperty Comments $data.Comments –passthru						
				$Packages_values = $Packages_values | Add-Member NoteProperty Reboot $data.Reboot –passthru		
				$Packages_values = $Packages_values | Add-Member NoteProperty Enable $data.Enable –passthru		
				$Packages_values = $Packages_values | Add-Member NoteProperty Hide $data.Hide –passthru																	
				$DataGrid_Packages.Items.Add($Packages_values) > $null
			}								
	}	
	
	
	
	
	

Function Add_Application_Part 
	{
		powershell "$Current_Folder\Add_Appli.ps1" -deploymentshare "'$global:deploymentshare'" -module $MDT_Module		
	}
	
Function Add_MUI_Part 
	{
		powershell "$Current_Folder\Add_MUI.ps1" -deploymentshare "'$global:deploymentshare'" -module $MDT_Module		
	}

Function Add_Package_Part 
	{
		powershell "$Current_Folder\Add_Package.ps1" -deploymentshare "'$global:deploymentshare'" -module $MDT_Module		
	}	
       

	   
	  	   
Function Remove_Application_Part
	{	
		If ($DataGrid_Applis.SelectedIndex -ne "-1")
			{
				$i = $DataGrid_Applis.SelectedIndex
				$App_Name = $Applis_Row_List[$i].Name		
				
				Import-Module $MDT_Module	
				
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
				remove-item -path "DSAppManager:\Applications\$App_Name" -force -verbose		
				[System.Windows.Forms.MessageBox]::Show("Your application has been correctly removed") 					
			}
		Else
			{
				[System.Windows.Forms.MessageBox]::Show("You have to select an application to remove") 	
			}				
	}

	
	
Function Remove_MUIs_Part
	{	
		If ($DataGrid_MUIs.SelectedIndex -ne "-1")
			{
				$i = $DataGrid_MUIs.SelectedIndex
				$MUI_Name = $MUIs_Row_List[$i].Name		
				
				Import-Module $MDT_Module	
				
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
				remove-item -path "DSAppManager:\Packages\$MUI_Name" -force -verbose					
				[System.Windows.Forms.MessageBox]::Show("Your application has been correctly removed") 					
			}
		Else
			{
				[System.Windows.Forms.MessageBox]::Show("You have to select an application to remove") 	
			}				
	}


Function Remove_Packages_Part
	{	
		If ($DataGrid_Packages.SelectedIndex -ne "-1")
			{
				$i = $DataGrid_Packages.SelectedIndex
				$Package_Name = $Packages_Row_List[$i].Name		
				
				Import-Module $MDT_Module	
				
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
				remove-item -path "DSAppManager:\Packages\$Package_Name" -force -verbose		
				[System.Windows.Forms.MessageBox]::Show("Your application has been correctly removed") 					
			}
		Else
			{
				[System.Windows.Forms.MessageBox]::Show("You have to select an application to remove") 	
			}				
	}
	
	
	
Function Modify_Application_Part
	{		
		If ($DataGrid_Applis.SelectedIndex -ne "-1")
			{
				$i = $DataGrid_Applis.SelectedIndex
				$Global:App_Name = $Applis_Row_List[$i].Name
				$Global:App_ShortName = $Applis_Row_List[$i].ShortName									
				$Global:App_Comments = $Applis_Row_List[$i].Comments					
				$Global:App_Publisher = $Applis_Row_List[$i].Publisher	
				$Global:App_Version = $Applis_Row_List[$i].Version
				$Global:App_Source = $Applis_Row_List[$i].Source				
				$Global:App_Language = $Applis_Row_List[$i].Language
				$Global:App_CMD = $Applis_Row_List[$i].CommandLine
				$Global:App_Reboot = $Applis_Row_List[$i].Reboot		
				$Global:App_Enable = $Applis_Row_List[$i].Enable									
				$Global:App_Hide = $Applis_Row_List[$i].Hide									

				If (!$App_Name){$App_Name = "-"}
				If (!$App_ShortName){$App_ShortName = "-"}
				If (!$App_Comments){$App_Comments = "-"}
				If (!$App_Publisher){$App_Publisher = "-"}
				If (!$App_Version){$App_Version = "-"}
				If (!$App_Source){$App_Source = "-"}
				If (!$App_Language){$App_Language = "-"}
				If (!$App_CMD){$App_CMD = "-"}
				If (!$App_Reboot){$App_Reboot = "False"}
				If (!$App_Enable){$App_Enable = "False"}
				If (!$App_Hide){$App_Hide = "False"}
				
				powershell "$Current_Folder\Modify_Appli.ps1" -deploymentshare "'$global:deploymentshare'" -applixml $list_applis -position $i -name "'$App_Name'" -ShortName "'$App_ShortName'" -comments "'$App_Comments'" -publisher "'$App_Publisher'" -version "'$App_Version'" -source "'$App_Source'" -language "'$App_Language'" -command "'$App_CMD'" -reboot $App_Reboot -enable $App_Enable -hide $App_Hide				
			}
		Else
			{
				[System.Windows.Forms.MessageBox]::Show("You have to select an application to modify") 	
			}				
	}		  
          


########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$Tab_Control.Add_SelectionChanged({
	
	If ($Tab_Control.SelectedItem.Header -eq "Applications")
		{
			$Global:Launch_mode = "Applis"		
			If ($txtbox_Open.Text -eq "")
				{
					$Modify_Appli.IsEnabled = $false										
				}			
			Else
				{
					$Modify_Appli.IsEnabled = $true										
				}
		}
		
	ElseIf ($Tab_Control.SelectedItem.Header -eq "MUIs")
		{
			$Global:Launch_mode = "MUI"			
			$Modify_Appli.IsEnabled = $false					
		}	
		
	ElseIf ($Tab_Control.SelectedItem.Header -eq "Packages")
		{
			$Global:Launch_mode = "Package"		
			$Modify_Appli.IsEnabled = $false					
		}			
})		
	

	
	
########################################################################################################################################################################################################
#                        																OPEN DEPLOY FOLDER BUTTON                                   
########################################################################################################################################################################################################

$Open_Deploy.Add_Click({	

	$Applis_Row_List.Clear()
	$MUIs_Row_List.Clear()			
	$Packages_Row_List.Clear()			
	
    $folder = $object.BrowseForFolder(0, $message, 0, 0) 
    If ($folder -ne $null) 
		{ 		
			$global:deploymentshare = $folder.self.Path 
			$Global:version_xml = "$deploymentshare\Control\Version.xml"			
			$Global:txtbox_Open.Text =  $deploymentshare		
			Copy_Control_Folder		
			Populate_Datagrid_Applis	
			Populate_Datagrid_MUIs
			Populate_Datagrid_Packages		
			
			If ((Test-Path -LiteralPath $version_xml ) -ne $True)
				{
					[System.Windows.Forms.MessageBox]::Show("File Version.xml can't be found on your DeploymentShare.") 	
				}
			Else
				{		
					[xml]$fileContents = Get-Content -Path $version_xml
					$Global:MDT_Version = $fileContents.version
									
					If ($MDT_Version -eq $MDT_Update_1)
						{
							$MDT_Version_Label.Content = "MDT Update 1 - Build 6.3.8298"
							$Check_MDT_Icon.Fill = "Green"				
							$Global:MDT_Module = ".\mdt\update1\MicrosoftDeploymentToolkit.psd1"	

							$Add_Content.IsEnabled = $true
							$Remove_Content.IsEnabled = $true	
							If($Launch_mode -eq "Applis")
								{
									$Modify_Appli.IsEnabled = $true								
								}				
						}
					ElseIf ($MDT_Version -eq $MDT_Update_2)
						{
							$MDT_Version_Label.Content = "MDT Update 2 - Build 6.3.8330"
							$Check_MDT_Icon.Fill = "Green"			
							$Global:MDT_Module = ".\mdt\update2\MicrosoftDeploymentToolkit.psd1"	

							$Add_Content.IsEnabled = $true
							$Remove_Content.IsEnabled = $true
							If($Launch_mode -eq "Applis")
								{
									$Modify_Appli.IsEnabled = $true								
								}								
						}
						
						
				ElseIf (($MDT_Version -ne $MDT_Update_1) -or ($MDT_Version -ne $MDT_Update_2))
					{
						[System.Windows.Forms.MessageBox]::Show("You are using Build $MDT_Version which is not supported.") 	
						$MDT_Version_Label.Content = "Not supported version"	
						$MDT_Version_Label.Foreground = "Red"	
						$Check_MDT_Icon.Fill = "Red"					
					}							
				}						
		}	
})	


########################################################################################################################################################################################################
#                        															ADD APPLICATION BUTTON                                   
########################################################################################################################################################################################################
 $Add_Content.Add_Click({	
	If ($Launch_mode -eq "Applis")
		{
			Add_Application_Part
			$Applis_Row_List.Clear()			
			Populate_Datagrid_Applis			
		}
	ElseIf ($Launch_mode -eq "MUI")
		{
			Add_MUI_Part
			$MUIs_Row_List.Clear()			
			Populate_Datagrid_MUIs
		}		
	ElseIf ($Launch_mode -eq "Package")
		{
			Add_Package_Part
			$Packages_Row_List.Clear()			
			Populate_Datagrid_Packages
		}			
})		
########################################################################################################################################################################################################
#                        															MODIFY APPLICATION BUTTON                                   
########################################################################################################################################################################################################
$Modify_Appli.Add_Click({	
	Modify_Application_Part
	$Applis_Row_List.Clear()			
	Populate_Datagrid_Applis			

})		
########################################################################################################################################################################################################
#                        															REMOVE APPLICATION BUTTON                                   
########################################################################################################################################################################################################
$Remove_Content.Add_Click({	

	If ($Launch_mode -eq "Applis")
		{
			Remove_Application_Part
			$Applis_Row_List.Clear()			
			Populate_Datagrid_Applis			
			
		}
	ElseIf ($Launch_mode -eq "MUI")
		{
			Remove_MUIs_Part
			$MUIs_Row_List.Clear()			
			Populate_Datagrid_MUIs
			
		}		
	ElseIf ($Launch_mode -eq "Package")
		{
			Remove_Packages_Part
			$Packages_Row_List.Clear()			
			Populate_Datagrid_Packages
			
		}			
})		


########################################################################################################################################################################################################
#                        															ABOUT BUTTON                                   
########################################################################################################################################################################################################
$about.Add_Click({	
	powershell "$Current_Folder\About.ps1" 
})		




$Form.ShowDialog() | Out-Null
