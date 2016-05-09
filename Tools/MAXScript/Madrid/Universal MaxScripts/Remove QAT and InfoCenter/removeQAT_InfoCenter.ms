/*
	This will remove the Quick Access Toolbar and the Info Center from the 3dsMax window.
*/


ComponentManager = (dotnetclass "Autodesk.Windows.ComponentManager")
ComponentManager.QuickAccessToolBar.IsVisible = false

ComponentManager.InfoCenterToolBar.MaxWidth = 0
ComponentManager.InfoCenterToolBar.MinWidth = 0