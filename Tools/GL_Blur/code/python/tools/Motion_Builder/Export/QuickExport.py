from pyfbsdk import *
from pyfbsdk_additions import *
import os
lSystem = FBSystem()
lScene = lSystem.Scene
app = FBApplication()

def getPathFromCurrentFile():
    tokens = (app.FBXFileName).split("\\")
    tokens.pop(-1)
    _path = ""
    for i in tokens:
        _path += i + "/"
    return _path
    
def getPathIni():
    '''Gets the ini information if none exists create it '''
    lPath = os.getcwd() + "\exportTakes.ini"
    exportPath = ''
    if os.path.isfile(lPath) != False:
        with open(lPath, 'r') as fp:
            exportPath = (fp.readlines(0) )[0]
        fp.close()
    else:
        with open(lPath, 'w') as fp:
            exportPath = getPathFromCurrentFile()
            fp.write( exportPath )
        fp.close()
    return exportPath 
    
def setPathIni():
    '''Set the path in to the ini file '''
    lPath = os.getcwd() + "\exportTakes.ini"
    with open(lPath, 'w') as fp:
        fp.write( ui_path.Text )
    fp.close()

def getFBXExportPath():
    lFileName = (lSystem.CurrentTake.Name)
    _path = ui_path.Text
    lFilePath = _path + lFileName + ".fbx"
    return lFilePath


def selectSekeletonExportGroup():
    r'''selects Skeleton export group'''
    lScene = FBSystem().Scene
    allGroups = lScene.Groups
    for group in allGroups:
        if group.Name == "Skeleton_export":
            group.Select(True)

def setStartEndWeights (lModels , weight = 0):
    '''
    Sets the start and end weights of models in a list
    '''
    for model in lModels: 
        if model.Animatable:
            #rotation and translate nodes
            rNode = model.Rotation.GetAnimationNode()
            rNode.Nodes
            tNode = model.Rotation.GetAnimationNode()
            tNode.Nodes
            
            RT_Nodes = (rNode.Nodes[0], rNode.Nodes[1], rNode.Nodes[2], tNode.Nodes[0], tNode.Nodes[1], tNode.Nodes[2])
           
            for node in RT_Nodes:
                fcurve = node.FCurve
                fcurve.Keys
                if len(fcurve.Keys) != 0:
                    fcurve.Keys[0].RightTangentWeight = weight
                    fcurve.Keys[-1].LeftTangentWeight = weight
                    
def setExportOptions(lOptions):
    lOptions.SaveSelectedModelsOnly = True
    lOptions.UseASCIIFormat = False
    lOptions.EmbedMedia = True
    #lOptions.GetTakeName = True
    
    # Not saving system information; only focus on the selected models.
    lOptions.BaseCameras = False
    lOptions.CameraSwitcherSettings = False
    lOptions.CurrentCameraSettings = False
    lOptions.GlobalLightingSettings = False
    lOptions.TransportSettings = False
    
          
def saveSelected():
    lOptions = FBFbxOptions(False)
    setExportOptions(lOptions)
    
    #Exports only the current Take.
    for index in range (0,lOptions.GetTakeCount()):
        if lOptions.GetTakeName(index) == lSystem.CurrentTake.Name:
            lOptions.SetTakeSelect(index, True)
        else:
            lOptions.SetTakeSelect(index, False)
        
    # Get the export path.
    selectSekeletonExportGroup()
    lModels = FBModelList()
    FBGetSelectedModels( lModels )
    
    #remove wheights on from the begining and end of each FCurve 
    #MBU 2013
    setStartEndWeights (lModels)     
    
    lFilePath = getFBXExportPath()
    
    if FBApplication().FileSave(lFilePath, lOptions):
        print "File successfully saved to %s" % lFilePath
    else:
        print "Failed to save file: %s" % lFilePath
    
def saveAllTakes():
    r'''Save all takes into separate files '''
    lOptions = FBFbxOptions(False)
    setExportOptions(lOptions)
    # Get the export path.
    selectSekeletonExportGroup()
    lModels = FBModelList()
    FBGetSelectedModels( lModels )

    # Iterate the list of takes.
    for lTake in lSystem.Scene.Takes:
        
        # Switch the current take to the one we want to save.
        lSystem.CurrentTake = lTake
        #remove wheights on from the begining and end of each FCurve
        setStartEndWeights (lModels) 
        lFilePath = getFBXExportPath()
        for index in range(lOptions.GetTakeCount()): ## take index
            if lOptions.GetTakeName(index) == lTake.Name:
                lOptions.SetTakeSelect(index, True)
            else:
                lOptions.SetTakeSelect(index, False)
                
        if FBApplication().FileSave(lFilePath, lOptions):
            print "File successfully saved to %s" % lFilePath
        else:
            print "Failed to save file: %s" % lFilePath
            
def plotOption(plot_options):
    plot_options.PlotAllTakes = False
    plot_options.PlotOnFrame = True   
    plot_options.PlotPeriod = FBTime(0, 0, 0, 0, 1, FBTimeMode.kFBTimeMode30Frames)
    plot_options.UseConstantKeyReducer = False
    plot_options.PreciseTimeDiscontinuities = True  
    plot_options.ConstantKeyReducerKeepOneKey  = True 
    
def ensureDir(_path):
    '''Creates if the directory doesn't exist'''
    d = os.path.dirname(_path + "/")
    if not os.path.exists(d):
        os.makedirs(d)
  
def exportCurrentTake():
    r'''exports current Take'''
    current_character = app.CurrentCharacter
    if current_character.GetCharacterize:
        switchOn = current_character.SetCharacterizeOn(True)
        
    #print "Save current scene"
    currentFile = app.FBXFileName
    #app.FileSave(currentFile)

    plot_options = FBPlotOptions()
    plotOption(plot_options)
    
    current_character.PlotAnimation( FBCharacterPlotWhere.kFBCharacterPlotOnSkeleton,  plot_options)
    saveSelected()
    
    app.FileOpen( currentFile, False )

def exportAllTakes():
    r'''exports all the current Takes in the scene'''
    current_character = app.CurrentCharacter
    if current_character.GetCharacterize:
        switchOn = current_character.SetCharacterizeOn(True)
        
    #print "Save current scene"
    currentFile = app.FBXFileName
    app.FileSave(currentFile)

    plot_options = FBPlotOptions()
    plotOption(plot_options)

    current_character.PlotAnimation( FBCharacterPlotWhere.kFBCharacterPlotOnSkeleton,  plot_options)
    saveAllTakes()
    
    app.FileOpen( currentFile, False )  

def BtnExportTakeCallback(control, event):
    setPathIni()
    ensureDir(ui_path.Text)
    exportCurrentTake()

def BtnExportAllTakesCallback(control, event):
    setPathIni()
    ensureDir(ui_path.Text)
    exportAllTakes()

def PopulateLayout(mainLyt):

    x = FBAddRegionParam(0,FBAttachType.kFBAttachLeft,"")
    y = FBAddRegionParam(0,FBAttachType.kFBAttachTop,"")
    w = FBAddRegionParam(0,FBAttachType.kFBAttachRight,"")
    h = FBAddRegionParam(20,FBAttachType.kFBAttachNone,"")
    mainLyt.AddRegion("lb_edit","lb_edit", x, y, w, h)
    lyt = FBHBoxLayout()
    mainLyt.SetControl("lb_edit",lyt)
    lbl = FBLabel()
    lbl.Caption = "Path"
    lyt.Add(lbl,100)
    
    x = FBAddRegionParam(30,FBAttachType.kFBAttachLeft,"")
    y = FBAddRegionParam(0,FBAttachType.kFBAttachTop,"")
    w = FBAddRegionParam(0,FBAttachType.kFBAttachRight,"")
    h = FBAddRegionParam(20,FBAttachType.kFBAttachNone,"")
    mainLyt.AddRegion("edit","edit", x, y, w, h)
    lyt = FBHBoxLayout()
    mainLyt.SetControl("edit",lyt)
    
    global ui_path
    ui_path =  FBEdit()
    ui_path.Text = getPathIni()
    lyt.Add(ui_path, 100)
    
    #Export Buttons
    x = FBAddRegionParam(0,FBAttachType.kFBAttachLeft,"")
    y = FBAddRegionParam(22,FBAttachType.kFBAttachTop,"")
    w = FBAddRegionParam(0,FBAttachType.kFBAttachRight,"")
    h = FBAddRegionParam(20,FBAttachType.kFBAttachNone,"")
    mainLyt.AddRegion("exportCurrentTake","exportCurrentTake", x, y, w, h)
    lyt = FBHBoxLayout()
    mainLyt.SetControl("exportCurrentTake",lyt)
    
    b =  FBButton()
    b.Caption = "Export Current Take"
    b.Justify = FBTextJustify.kFBTextJustifyLeft
    lyt.Add(b,105)
    b.OnClick.Add(BtnExportTakeCallback)

    
    x = FBAddRegionParam(0,FBAttachType.kFBAttachLeft,"")
    y = FBAddRegionParam(44,FBAttachType.kFBAttachTop,"")
    w = FBAddRegionParam(0,FBAttachType.kFBAttachRight,"")
    h = FBAddRegionParam(20,FBAttachType.kFBAttachNone,"")
    mainLyt.AddRegion("exportAllTakes","exportAllTakes", x, y, w, h)
    lyt = FBHBoxLayout()
    mainLyt.SetControl("exportAllTakes",lyt)
    

    b =  FBButton()
    b.Caption = "Export All Takes"
    b.Justify = FBTextJustify.kFBTextJustifyLeft
    lyt.Add(b,105)
    b.OnClick.Add(BtnExportAllTakesCallback)
    
    
def CreateTool():
    # Tool creation will serve as the hub for all other controls
    t = FBCreateUniqueTool("Export FBX")
    t.StartSizeX = 80
    t.StartSizeY = 200
    PopulateLayout(t)
    ShowTool(t)
    

CreateTool()