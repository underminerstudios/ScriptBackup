-- Lightmap UVWs packer
-- written by Martin Lutteral 2012
-- juan-martin.lutteral@gameloft.com
-- NET_ListViewWrapper by Chris P.Johnson, (c)Autodesk
--821
global polyop_getMapSupport = polyop.getMapSupport
global polyop_getnumfaces = polyop.getNumFaces
global polyop_getFaceArea = polyop.getFaceArea
global rescale_uvboxes = false -- deprecated parameter
global globalcounter=0 -- for debug purposes
global mapsToRebuild 
global uv_weight
global LM_Bins = #()
global lmChunks
global _listView
global _padding = 1 -- UI element?

global thePack 
global theLayers

-- this is the id/address of the binary tree node. 
--The node is represented by the bitmap image in the bitmap holder.
global Chunk_ID 

ResumeEditing()
ResumeEditing()

/**********************************************************************
FILE: 		NET_ListViewWrapper.ms (ListViewOps)
DESCRIPTION:	A wrapper for the .NET System.Windows.Forms.ListView control
CREATED BY:	Chris P. Johnson
HISTORY:		Created April 18 2006
Copyright Autodesdk (c) 2000, All Rights Reserved.
**********************************************************************/
struct LMBinaryTree_new
(
    address="",
    Box=box2 0 0 999999 999999,
    chunk,
    child,
    size=0,
   
    fn isUsed = this.chunk!=undefined,
    fn getTreeNodes =
    (
        local res=#()
        if this.isUsed() then
        (
            --append res this
            append res (LMBinaryTree address:this.address box:this.box size:this.size chunk:this.chunk)
            join res (this.child[1].getTreeNodes())
            join res (this.child[2].getTreeNodes())
        )
        return res
    ),
   
    fn splitDown =
    (
        this.child=#()
        local prA=if this.address!=undefined then this.address else ""
        append this.child (LMBinaryTree address:(prA+"1"))
        append this.child (LMBinaryTree address:(prA+"2"))
        (
            --direction=(random 1 2)==1
            direction=(mod this.address.count 2)==1
            --direction=(mod globalcounter 2)==0
            if direction then
            (
                this.child[1].box = box2 [this.box.x,this.box.y+this.chunk.size] [this.box.right+1,this.box.bottom]
                this.child[2].box = box2 [this.box.x+this.chunk.size,this.box.y] [this.box.right+1,this.box.y+this.chunk.size-1]
            )
            else
            (
                this.child[1].box = box2 [this.box.x,this.box.y+this.chunk.size] [this.box.x+this.chunk.size-1,this.box.bottom]
                this.child[2].box = box2 [this.box.x+this.chunk.size,this.box.y] [this.box.right+1,this.box.bottom]
            )
        )
       
    ),
   
    fn insertAt _address _chunk =
    (
        if _address.count==0 then
        (
            this.chunk= _chunk
            this.splitDown()
        )
        else
        (
            this.child[_address[1] as integer].insertAt (substring _address 2 -1) _chunk
        )
       
    ),

    fn getFreeNodes =
    (
        local res=#()
        if not this.isUsed() then append res this
        else
        (
            join res (this.child[1].getFreeNodes())
            join res (this.child[2].getFreeNodes())
        )
        return res
    ),
    fn BoxFits _box1 _size =(_box1.w>=_size and _box1.h>=_size),
    fn pushChunk _chunk=
    (
        local fNodes=this.getFreeNodes()
        local addrss=""
        local maxDist=1000000
        local newSize=this.size
        local delta
       
        for i in fNodes where (this.BoxFits i.box _chunk.size) do
        (
           
            extents=(amax #((i.box.x+_chunk.size) ,(i.box.y+_chunk.size)))
            delta = extents-this.size
            --delta=distance [0,0] [i.box.x,i.box.y]
            --delta=abs(i.box.x-i.box.y)
            if delta<maxDist do
            (
                addrss=i.address
                maxDist=delta
                newSize=extents
            )
        )
        if (mod globalcounter 25)==0 do windows.processpostedmessages()
        globalcounter+=1
        --print globalcounter
        --print (_chunk.obj.name)
        this.insertAt addrss _chunk
        if newSize>this.size do this.size=newSize
    ),
   
    fn getBitmap elBitmap:undefined mapSize:800.0 =
    (
        --gc()
        local ratio=double ((mapSize as float)/thepack.size)
       
        if elBitmap==undefined do
        (
            elbitmap=bitmap mapSize mapSize color:(color 255 255 255 0) -- this is the rootNode, create the Bitmap
        )
       
        if this.chunk!=undefined do
        (
           
            tbm=this.chunk.bm
            mx=(this.box.x*ratio) as integer
            my=(this.box.y*ratio) as integer
            pasteBitmap tbm elBitmap [0,0] [mx,my]
        )
        if this.child!=undefined do
        (
            (this.child[1].getBitmap elbitmap:elBitmap )
            (this.child[2].getBitmap elbitmap:elBitmap )
        )
       
       
        return elBitmap
    )
   
   
)
struct ListViewOps
(		
	m_dnColor = dotNetClass "System.Drawing.Color",
	function MXSColor_to_dotNetColor hColor =
	(
		m_dnColor.fromARGB hColor.r hColor.g hColor.b
	),
	function dotNetColor_to_MXSColor dnColor =
	(
		local mxsCol = color (dnColor.r as integer) (dnColor.g as integer) (dnColor.b as integer)
		mxsCol
	),
	function InitImageList lv stringFileArray pSize:0 =
	(
		--[brief] This method only adds icons and bitmaps, to an imagelist.
		--        An imagelist is a structure that manages images for a control.
		--[param] lv - The listview control. Must inherit from System.Windows.Forms.Control class.
		--[param] stringFileArray - A maxscript array containing filenames of the images to add.
		--        Must pass the string file names as a symbolic pathname: 
		--        i.e. "$ui/icons/mybitmap.bmp"
		--[param] pSize - The size of the bitmap to add. For example 16 if the image is 16 x 16 pixels.
		--[return] A System.Windows.Forms.ImageList
		local hImgList 	= dotNetObject "System.Windows.Forms.ImageList"
		local imgSize 		= dotNetObject "System.Drawing.Size" 16 16
		
		if pSize == 0 then
		( 
			hImgList.imagesize	= imgSize
		)
		else if (pSize > 2) then
		(
			imgSize 		= dotNetObject "System.Drawing.Size" pSize pSize
			hImgList.imagesize = imgSize
		)
		
		local bColor 	= dotNetClass "System.Drawing.Color"
		if pTransparentColor != undefined and (classof pTransparentColor == color) then
		(	
			local col = pTransparentColor --temporary
			hImgList.transparentColor = bColor.fromARGB col.r col.g col.b
		) 
		else
		(
			hImgList.transparentColor = bColor.fromARGB 125 125 125	
		)
		
		local img  		= dotNetClass "System.Drawing.Image"
		
		function IsIconFile stringFileName =
		(
			local type = GetFileNameType stringFileName
			local result = false
			if type == ".ico" do ( result = true )
			result	
		)
		
		for file in stringFileArray do
		(
			fName = (symbolicPaths.expandFileName file)
			if (IsIconFile fName ) then --Add icons
			(
				local icon  = dotNetObject "System.Drawing.Icon" fName
				hImgList.images.add icon
			)
			else --or Add bitmaps
			(
				local dnBitmap = dotNetObject "System.Drawing.Bitmap" fName
				hImgList.images.add dnBitmap
			)
		)
		lv.SmallImageList = hImgList
	),
    function AddLvItem lv                 \
                    pTextItems:#()        \
                    pChecked:  false      \
                    pHashKey:  ""         \
                    pTag:      undefined  \
                    pToolTip:  ""         \
                    pInsertAt: undefined  \
                    pImgIndex: 1          \
                    pIndent:   0 =
	(
		--[brief] This function Creates and Adds a ListViewItem to a ListView control.
		--[param] pTextItems - A maxscript array that contains the strings to put in each cell
		--                     of the listview cells which are called ListViewSubItems
		--[param] pChecked   - If true displays a checkbox to the far left of the listview item
		--[param] pHashKey   - A string used for a hash table index
		--[param] pTag       - Any maxscript / custom value to be stored in the tag property
		--[param] pToolTip   - A string to be used for the tooltip for the ListViewItem
		--[param] pInsertAt  - A number used to insert a new listviewItem in the middle of a listview.
		--[param] pImgIndex  - Index of the image to use in the embedded imagelist.
		--[param] pIndent    - A number used to specify how far to indent the text of ListViewItems.
		--[return] Returns the newly created Listview Item.
		local item = dotNetObject "System.Windows.Forms.ListViewItem" pTextItems[1]
		
		item.Checked   = (pChecked == 1 or pChecked == true)
		item.indentCount = pIndent
		
		if pHashKey == "" then
		( item.Name	= pTextItems[1] ) --Useful for fast lookup
		else ( item.Name = pHashKey )
			
		if pTag != undefined do 
		(    item.tag  = pTag   )
		item.toolTipText = pToolTip
		item.imageIndex  = pImgIndex
		
		--Inserts the first item in the pTextItems array after ListViewItem specified by 
		--the pInsertAt index.
		if (pInsertAt != undefined) and (pInsertAt > 0) then
		(
			lv.items.Insert pInsertAt item
			item.indentCount = 1
		)
		else
		(
			lv.items.add item
		)
		
		--If the pTextItems array contains more than one entry, add additional cell
		-- entryies to the listviewITem in the form of ListViewSubItem class objects.
		--Note that an extra column will have to have been added to the listview to
		-- display these.
		local count = pTextItems.count
		-- Cache this method to improve performance
		local itemSubItemsAdd = item.SubItems.add
		for i = 2 to count do
		(
			-- subItem is of class System.Windows.Forms.ListViewSubItem
			local subItem = itemSubItemsAdd pTextItems[i]
			
			if (pHashKey == "") then --Useful for fast lookup
			( subItem.name = pTextItems[i] )
			else ( subItem.name = phashKey )
			subitem.tag = pTag
		)
		--return the listview item if the caller wants it
		item 
	),
	function DeleteLvItem lv index =
	(
		--[brief] Deletes the specified listview item.
		--[param] lv - A System.Windows.Forms.ListView control
		--[param] index - The integer index of the item to delete
		if (index != undefined) and (index >= 0) and (index < lv.Items.count) then
		(	
			lv.items.removeat index
		)	
	),

	function AddLvColumnHeader lv                \
	                         pCaption: ""        \
	                         pWidth: undefined =
	(
		--[brief] Adds a column header to the listview control
		--[param] lv - A System.Windows.Forms.ListView control
		--[param] pCaption - A string for the column caption
		--[param] pWidth - The horizontal size of the caption cell and column.
		if (pWidth == undefined) do
		(
			local sizeCaption = GetTextExtent pCaption
			pWidth = sizeCaption.x
			pWidth *= 2.0
		)
		
		--Adds a Column to a listview control.
		local horizontalAlignment = dotNetClass "System.Windows.Forms.HorizontalAlignment"
		lv.Columns.Add pCaption pWidth horizontalAlignment.Left
	),
	function RefreshListView lv = 
	(
		lv.Refresh()
	),
	function SetFontStyle pControl pStyle =
	(
		--[brief] Changes the font style. The font style is changed according to the list,
		--        but the The size and family are supposed to stay the same.
		--[param] pControl - Must inherit from the System.Windows.Forms.Control class
		--        This control must have a public font property
		--[param] pStyle - A maxscript enumeration or name indicating the style. See the
		--        case statement below for a list of possible values.
		local oldFont = pControl.font
		local oldSize = oldFont.size --as Integer
		local oldStyle= oldFont.style
			
		local fontStyle     = dotNetClass  "System.Drawing.FontStyle"
		local appliedFontStyle = undefined
		
		appliedFontStyle = case pStyle of
		(
			#bold: ( 
				if(oldStyle != fontStyle.bold) do (oldSize -= 3); 
				fontStyle.Bold      
			)
			#regular: (
				fontStyle.Regular   
			)
			#Italic:  ( 
				if (oldStyle != fontStyle.Italic) do (oldSize -= 3); 
				fontStyle.Italic    
			)
			#Strikeout:( 
				fontStyle.Strikeout 
			)
			#Underline:( 
				if (oldStyle != fontStyle.underline) do (oldSize -= 3); 
				fontStyle.Underline 
			)
			default:   ( 
				fontStyle.Regular   
			)
		)
		local highLightFont = dotNetObject "System.Drawing.Font" oldFont.fontFamily oldSize appliedFontStyle
		pControl.font = highLightFont
	),
	function SetForeColor pControl pColor =
	(
		--[brief] Changes the text color
		--[param] pControl - A control object which must inherit from the System.windows.forms.control class
		--[param] pColor   - A maxscript color value
		--[return] Returns the equivalent System.Drawing.Color
		pControl.foreColor = MXSColor_to_dotNetColor pColor
	),
	function HighLightLvItem pControl pStyle pColor =
	(
		--[brief] Highlights the font of a system.windows.forms.Listview class object.
		--[param] pControl - A control object which must inherit from the System.windows.forms.control class
		--[param] pStyle   - A maxscript name specifying the font style. See the SetFontStyle function for details.
		SetFontStyle pControl pStyle 
		SetForeColor pControl pColor
	),
	---------------------------------------
	-- Mass Deletion Methods 
	---------------------------------------
	function ClearColumns lv = 
	(
		lv.columns.clear()	
	),
	function ClearLvItems lv =
	(
		lv.items.clear()	
	),
	---------------------------------------
	-- Selection Methods 
	---------------------------------------
	function GetLvSelection lv =
	(
		--[brief] Returns a maxscript array of selected ListViewItems.
		--		  The SelectedItems property of a listview is of class 
		--		  System.Windows.Forms.SelectedListViewItemCollection
		--[param] lv - A ListView control
		--[return] A maxscript array of System.Windows.Forms.ListViewItem objects
		local sel = lv.selectedItems
		local result = #()
		if sel.count != 0 then
		(
			local nCount = sel.count - 1 --.NET arrays are zero based
			result = for i = 0 to nCount collect ( sel.item[i] )
		)
		else
		(
			result = #()
		)
		result
	),
	function GetLvSingleSelected lv =
	(
		--[brief] Returns a single selected ListViewItem 
		--        from the ListView Control
		--[return] An item of the System.Windows.Forms.ListViewItem class
		local result = GetLvSelection lv
		if (result.count > 0) then
			result[1]	
		else
			undefined
	),
	function GetSelectedIndex lv =
	(
		--[brief] Gets the index of the selected listview item. Only one 
		--        item can be selected at one time.
		--[param] lv - The System.Windows.Forms.ListView class control
		--[return] The integer index of the selected item in listview control
		local result = -1
		if (lv.SelectedIndices.count == 1) then
		(
			result = lv.SelectedIndices.item[0]
		)
		result
	),
	function SelectLvItem lv index =
	(	
		--[brief] Selects an Item in the Listview by integer index
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] index - An integer of the item to select. Note that
		--        .NET arrays are zero based.
		--[return] Returns the selected ListViewItem if the selection was
		--         valid, otherwise it returns undefined
		local result = undefined
		if (index != undefined) and (lv.items.count != 0) and (index != -1) then
		(
			if ( index >= lv.Items.count) do 
			(
				index = lv.Items.count - 1	-- off the end, use last item
			)
			li = lv.Items.item[ index ]
			if li != undefined do 
			(
				li.selected = true
				result = li
			)
		)
		else if (index == -1) do
		(
			lv.selectedItems.clear()	
		)
		result
	),

	---------------------------------------
	-- Cell Operations
	---------------------------------------
	function GetLvItemName lv nRow nColumn =
	(
		--[brief] Gets the text from the listviewItem or subItem. The listview
		--        must be in report mode, which means displaying its data in a 
		--        grid format. All .NET arrays are zero based.
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] nRow - An integer for the row, or ListViewItem to query
		--[param] nColumn - An integer for the column (if any) to help locate the cell
		--        by an x y coordinate system.
		--[return] A string from the specified cell.
		local result = ""
		if nRow >= 0 and \
		   nRow < lv.Items.count and \
		   nColumn >= 0 and \
		   nColumn < (lv.columns.count) then
		(
			local li = lv.Items.item[ nRow ]
			local si = li.subItems.item[ncolumn]
			result = si.text
		)
		else
		(
			result = ""
		)
		
		result
	),
	function SetLvItemName lv nRow nColumn newName =
	(
		--[brief] Sets the text from the listviewItem or subItem. The listview
		--        must be in report mode, which means displaying its data in a 
		--        grid format. All .NET arrays are zero based.
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] nRow - An integer for the row, or ListViewItem to query
		--[param] nColumn - An integer for the column (if any) to help locate the cell
		--        by an x y coordinate system.
		--[param] newName - A string to place into the specified cell.
		if nRow >= 0 and \
		   nRow < lv.Items.count and \
		   nColumn >= 0 and \
		   nColumn < lv.columns.count then
		(
			local li = lv.Items.item[ nRow ]
			local si = li.subItems.item[ncolumn]
			si.text = newName as string
		)
	),
	---------------------------------------
	-- ListViewItem Operations
	---------------------------------------
	function GetLvItemCheck lv index =
	(
		--[brief] Queries whether a ListViewItem is checked or not. A listview Item
		--        must be first displaying checkboxes for this to take effect.
		--        Note: All .NET arrays are zero based.
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] index - The index of the listview Item to query
		--[return] true if checked, false if not checked
		local result = false
		if index >= 0 and index < lv.Items.count then
		(
			li = lv.Items.item[ index ]
			result = li.checked
		)
		result
	),
	function SetLvItemCheck lv index newState =
	(
		--[brief] Sets a ListViewItems checked state. A listview Item
		--        must be first displaying checkboxes for this to take effect.
		--        Note: All .NET arrays are zero based.
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] index - The index of the listview Item to query
		--[param] newState - A boolean value that contains the state.
		if index >= 0 and index < lv.Items.count then
		(
			li = lv.Items.item[ index ]
			li.checked = newState
		)
	),
	function SetLvItemRowColor lv index newColor =
	(
		--[brief] Sets the row color for a listview control.
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] index - The index of the listview Item to modify
		--[param] newColor - A maxscript color
		if index >= 0 and index < lv.Items.count then
		(
			local li = lv.Items.item[ index ]
			li.ForeColor = MXSColor_to_dotNetColor newColor
			--cache these for fast lookup
			local si = li.SubItems.item
			local siCount = (li.SubItems.count - 1)
			local newNETColor = MXSColor_to_dotNetColor newColor
			for i = 0 to siCount do
			(
				si[i].ForeColor = newNETColor
			)
		) 
	),
	function GetLvItemCount lv =
	(
		lv.items.count	
	),
	function GetLvItems lv =
	(
		--[brief] Returns a maxscript array of ALL ListViewItems in the listview control
		--[param] lv - The System.Windows.Forms.ListView class control
		--[return] A maxscript array of System.Windows.Forms.ListViewItem objects
		local result = #()
		local nCount = lv.items.count - 1 --.NET arrays are zero based
		local lvItems = lv.items
		for i = 0 to nCount do
		(
			append result lvItems.item[i]
		)
		result
	),
	function GetLvItemByName lv stringName =
	(
		--[brief] Searchs the listview control for any listview Items that have
		--        a name matching the passed in string. 
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] stringName - The string to search for
		--[return] An array of all items with the stringName, or undefined 
		--         if no items were found
		local result = lv.Items.Find stringName true
		if result.count == 0 do (result = undefined)
		result
	),
	---------------------------------------
	-- The Grand Initialization Method
	---------------------------------------
	function InitListView lv pLabelEdit:    true \
						pAllowReorder: true \ 
						pCheckBoxes:   false\ 
						pFullRowSel:   true \
						pMultiSel:     true \
						pGridLines:    true \
						pHideHeaders:  false\
						pAllowDrop:    false\
						pInitColumns:  #()  \
						pInitColWidths:#()  =
	(
		--Initialization Function to set general properties of a listview control
		
		------------------------------------
		-- user defined options
		------------------------------------
		-- Allow the user to edit item text.
		lv.LabelEdit = pLabelEdit;
		-- Allow the user to rearrange columns.
		lv.AllowColumnReorder = pAllowReorder;
		-- Display check boxes.
		lv.CheckBoxes = pCheckBoxes;
		-- Select the item and subitems when selection is made.
		lv.FullRowSelect = pFullRowSel;
		-- Enable multiple selections
		lv.multiselect = pMultiSel
		-- Display grid lines.
		lv.GridLines = pGridLines;
		-- Set Drag and Drop
		lv.allowDrop = pAllowDrop
		------------------------------------
		-- other options
		------------------------------------
		-- Set the view to show details.
		local view = dotNetClass "System.Windows.Forms.View"
		lv.View = view.Details;
		-- Sort the items in the list in ascending order.
		local sortOrder = dotNetClass "System.Windows.Forms.SortOrder"
		lv.Sorting = sortOrder.Ascending;
		
		-- Add columns (if supplied) and name them 
		local index = 1
		local doSetWidth = if (pInitColWidths.count == pInitColumns.count) then true else false
		for caption in pInitColumns do
		(	
			local width = if (doSetWidth) then pInitColWidths[index] else undefined	
			local header = AddLvColumnHeader lv pCaption: caption pWidth: width
			index += 1
		)
		
		-- Set Listview to System Colors
		local textColor   = MXSColor_to_dotNetColor (((colorman.getColor #text  )*255) as color)
		local windowColor = MXSColor_to_dotNetColor (((colorman.getColor #window)*255) as color)

		lv.backColor = windowColor
		lv.foreColor = textColor
	)
)

global lvops = ListViewOps()

--END OF FILE NET_ListViewWrapper.ms


struct td2
(
	obj,
	data
)

struct objWeight
(
	value,
	modified
)

struct LMBinaryTree
(
	address="",
-- 	Box=box2 0 0 1048575 1048575,
	Box=box2 0 0 999999 999999,
	chunk,
	child,
	size=0,
	
	fn isUsed = this.chunk!=undefined,
	fn getTreeNodes =
	(
		local res=#()
		if this.isUsed() then 
		(
			append res this
			join res (this.child[1].getTreeNodes())
			join res (this.child[2].getTreeNodes())
		)
		return res
	),
	
	fn splitDown =
	(
		this.child=#()
		local prA=if this.address!=undefined then this.address else ""
		append this.child (LMBinaryTree address:(prA+"1"))
		append this.child (LMBinaryTree address:(prA+"2"))
		(
-- 			a=random 1 2
-- 			b=if a==1 then 2 else 1
-- 			this.child[a].box = box2 [this.box.x,this.box.y+this.chunk.size] [this.box.right,this.box.bottom]
-- 			this.child[b].box = box2 [this.box.x+this.chunk.size,this.box.y] [this.box.right,this.box.y+this.chunk.size-1]

            --direction=(random 1 2)==1
            direction=(mod this.address.count 2)==1
            --direction=(mod globalcounter 2)==0
            if direction then
            (
                this.child[1].box = box2 [this.box.x,this.box.y+this.chunk.size] [this.box.right+1,this.box.bottom]
                this.child[2].box = box2 [this.box.x+this.chunk.size,this.box.y] [this.box.right+1,this.box.y+this.chunk.size-1]
            )
            else
            (
                this.child[1].box = box2 [this.box.x,this.box.y+this.chunk.size] [this.box.x+this.chunk.size-1,this.box.bottom]
                this.child[2].box = box2 [this.box.x+this.chunk.size,this.box.y] [this.box.right+1,this.box.bottom]
            )
		)
		
	),
	
	fn insertAt _address _chunk =
	(
		if _address.count==0 then
		(
			this.chunk= _chunk
			this.splitDown()
		)
		else
		(
			this.child[_address[1] as integer].insertAt (substring _address 2 -1) _chunk
		)
		
	),

	fn getFreeNodes =
	(
		local res=#()
		if not this.isUsed() then append res this
		else
		(
			join res (this.child[1].getFreeNodes())
			join res (this.child[2].getFreeNodes())
		)
		return res
	),
	fn BoxFits _box1 _size =(_box1.w>=_size and _box1.h>=_size),
	fn pushChunk _chunk=
	(
		local fNodes=this.getFreeNodes()
		local addrss=""
		local maxDist=1000000
		local newSize=this.size
		local delta
		
		for i in fNodes where (this.BoxFits i.box _chunk.size) do
		(
			
			extents=(amax #((i.box.x+_chunk.size) ,(i.box.y+_chunk.size)))
			delta = extents-this.size
			--delta=distance [0,0] [i.box.x,i.box.y]
			--delta=abs(i.box.x-i.box.y)
			if delta<maxDist do
			(
				addrss=i.address
				maxDist=delta
				newSize=extents
			)
		)
-- 		windows.processpostedmessages()
		globalcounter+=1
		--print globalcounter
		--print (_chunk.obj.name)
		this.insertAt addrss _chunk
		if newSize>this.size do this.size=newSize
	),
	
	fn getBitmap elBitmap:undefined ref:false=
	(
		if elBitmap==undefined do 
		(
			elbitmap=bitmap this.size this.size color:(color 255 255 255 0) -- this is the rootNode, create the Bitmap
		)

		try (pasteBitmap (bitmap this.child[1].size this.child[1].size color:(random black white)) elBitmap [0,0] [this.child[1].box.x,this.child[1].box.y]) catch(":P")
		try (pasteBitmap (bitmap this.child[2].size this.child[2].size color:(random black white)) elBitmap [0,0] [this.child[2].box.x,this.child[2].box.y]) catch(":P")
		
		
		if ( this.chunk != undefined ) do 
		(			
			tbm=this.chunk.bm
			if tbm == undefined then 
			(
				messagebox("You have a bitmap problem")
			)
			else
			(
				pasteBitmap tbm elBitmap [0,0] [this.box.x,this.box.y]
			)
--             tbm=this.chunk.bm
--             mx=(this.box.x*ratio) as integer
--             my=(this.box.y*ratio) as integer
--             pasteBitmap tbm elBitmap [0,0] [mx,my]
		)
		if this.child!=undefined do
		(
			(this.child[1].getBitmap elbitmap:elBitmap ref:ref)
			(this.child[2].getBitmap elbitmap:elBitmap ref:ref)
		)
		return elBitmap
	)
)

struct LMChunk
(
	obj,
	size,
	M,
	bm
)
struct sceneInfo 
(
	bins,
	bins_wts,
	bins_props,
	bins_bitmap,
	bins_objects
)

fn UV_Normalize =
(
	if selection.count > 0 then
	(
		max modify mode
		SuspendEditing()
		windows.processpostedmessages()
		oSel = selection as array
		uv = modPanel.getCurrentObject()
		if classof uv != Unwrap_UVW then
		( 
			uv = unwrap_UVW()
			uv.unwrap.setMapChannel 2
			for n in oSel do (addmodifier n uv)
			uv.settvsubobjectmode 3
		)
		ArrX = #()
		ArrY = #()
		ArrPoint
		for ob in oSel do
		(
			ob.modifiers[1].unwrap6.selectFacesByNode (ob.faces as bitarray) ob
			ob.modifiers[1].unwrap2.selectFaces (ob.faces as bitarray)
			UVVerts = ob.modifiers[1].numberVerticesByNode ob 
			for zz = 1 to UVVerts do
			(
				uvPos = ob.modifiers[1].GetVertexPositionByNode 0 zz ob
				append ArrX uvPos[1]
				append ArrY uvPos[2]
			)
		)
		sort ArrX
		sort ArrY
		max_x = ArrX[1]
		min_x = ArrX[ArrX.count]
		max_y= ArrY[1]
		min_y = ArrY[ArrY.count]
		center_x = (max_x + min_x)/2
		center_y = (max_y + min_y)/2
		UVcenter  = [center_x, center_y, 0]
		UVMove =  ((uvCenter - [0.5, 0.5, 0]) - ((uvCenter - [0.5, 0.5, 0])*2) )
		scaleX  = abs (.994/((min_x - (min_x*2)) + max_x))
		scaleY = abs (.994/((min_y - (min_y*2)) + max_y))
		ResumeEditing()
-- 		print ("\nThe center of the UV is " + UVcenter as string)
-- 		print ("Move the UV Selection " + UVMove as string)
-- 		print ("Scale the UV at center " + (scaleX as string) + " by " +  (scaleY as string))
-- 	-- 	
		uv.MoveSelected UVMove
		uv.unwrap2.ScaleSelectedXY scaleX scaleY [0.5,0.5,0]    
	)		
)
fn UV_Flatten ImgSize =
(

	max modify mode
	uv = modPanel.getCurrentObject()
	oSel = selection as array
	SuspendEditing()
	windows.processpostedmessages()
	if classof uv != Unwrap_UVW then
	( 
		uv = unwrap_UVW()
		uv.unwrap.setMapChannel 2
		for n in oSel do (addmodifier n uv)
		uv.settvsubobjectmode 3
	)
	for ob in oSel do
	(
		ob.modifiers[1].unwrap6.selectFacesByNode (ob.faces as bitarray) ob
	)
	ResumeEditing()
	uv = modPanel.getCurrentObject()
	uv_spacing = 4.0 / ImgSize ;
	uv.flattenMap 65 #() uv_spacing true 0 true true

)


fn getVertUVWs obj theChannel= return if (polyop.getMapSupport obj theChannel) then (for i in 1 to (polyop.getnummapverts obj theChannel) collect (polyop.getmapvert obj theChannel i)) else #()
	
fn ClampUVWs theUVWs = for i in theUVWs collect [(clampBetween i.x), (clampBetween i.y), 0]

fn clampBetween val low:0.0 hi:1.0 =
(
	case of
	(
		(val>hi): hi
		(val<low):low
		default:val
	)
)

fn checkUVWBoundingBox obj theChannel:1 =
(
	local VertUVWs=getVertUVWs obj theChannel
	res=#()
	for i in VertUVWs do
	(
		if i.x<0 or i.x>1 or i.y<0 or i.y>1 do
		(
			appendIfUnique res obj.name
		)
	)
	VertUVWs=ClampUVWs VertUVWs --clamp the values between 0 and 1 (default)
	for i in 1 to (polyop.GetNumMapVerts obj theChannel) do (polyop.SetMapVert obj theChannel i VertUVWs[i])
	print res
)

fn compareFN v1 v2 valArray: = -- used by qsort
(
	case of
	(
		(valArray[v1]<valArray[v2]): 1
		(valArray[v1]>valArray[v2]): -1
		default: 0
	)
)

fn LayerObjects theLayer =
(
	local aOL=#()
	theLayer.nodes &aOL
	aOL
)


fn isWeightChanged obj=
(
	local gUp=getUserProp obj "#ml_LightMapWeight"
	if gUp==undefined then
		return false
	else
	(
-- 		local m=for i in (recurChildren obj) where matchpattern i.name pattern:@"*_0}*" collect i
		local m=recurChildren obj
		local res=0
		append m obj -- obj and all childrens
		for eachObj in m do 
		(
			for i in 1 to polyop_getNumFaces eachObj do
				res+=polyop_getFaceArea eachObj i
		)
		res = ((sqrt res)/20.0) as integer
		return (res!=gUp)
	)
)

fn recurChildren_original _obj=
(
	local res=#()
	local objArr = #()
	if (_obj.wirecolor == (color 0 0 255) ) then (append objArr _obj)
	if _obj.children.count > 0 do
	(
		res=for i in _obj.children collect i
		for i in _obj.children do 
		(
			(join res (recurChildren i))
			if i.wirecolor == (color 0 0 255)then
			(
				appendIfUnique objArr i 
			)
		)
	)
	return objArr
)

fn recurChildren _obj=
(
	local res=#()
	local objArr = #()	
	
	if ( _obj.wirecolor == (color 0 0 255) ) then
	(
		appendIfUnique objArr _obj
	)
	
	if _obj.children.count > 0 do
	(
		res=for i in _obj.children collect i
		for obj in _obj.children do 
		(
			join res (recurChildren obj)
			if ( obj.wirecolor == (color 0 0 255) ) then 
			(
				appendIfUnique objArr obj 
			)
		)
	)

	return objArr
)
fn getMapWeight obj _reset:false= 
(
	local gUp=getUserProp obj "#ml_LightMapWeight"
	local res = objWeight()
-- 	local m=for i in (recurChildren obj) where matchpattern i.name pattern:@"*_0}*" collect i
	
	local m = recurChildren obj
	local tw = 0
	append m obj -- obj and all childrens
	for eachObj in m do -- get area of all faces
	(
		if (eachObj.wirecolor ==  (color 0 0 255) )then
		(
			for i in 1 to polyop_getNumFaces eachObj do
			(
				tw+=polyop_getFaceArea eachObj i
			)
		)
	)
	tw=((sqrt tw)/10) as integer	
-- 	clearlistener()
-- 	print (tw) 
	if _reset do gUp=tw
	res.modified= not(gUp==undefined or tw==gUp)
-- 	print res
	res.value= if res.modified then gUp else tw
-- 	print res
	if (_reset or gUp==undefined) do setUserProp obj "#ml_LightMapWeight" tw
	return res
)
fn xResetXform _obj=
(
	local theChildren = for i in _obj.children collect i
	for i in theChildren do i.parent=undefined
	resetXform _obj
	collapseStack _obj
	for i in theChildren do i.parent = _obj
)

fn gatherlmInfoMC4 strLayer =
(
	local lmTempObs=#()

	local ll = ILayerManager.getLayerObject strLayer
	local aOL=#()
	ll.nodes &aOL
	for ob in aOL do
	(
		if ( ob.wirecolor == (color 0 0 255 ) ) then
		(
			append lmTempObs ob
		)
	)
-- 	for i in theLayers where i !=undefined do(join lmTempObs (LayerObjects i))
	max create mode
	suspendEditing()
	
-- 	for obj in lmTempObs do xResetXform obj--bug at startup 
-- 	local lm_bin=checkChannel2 lmTempObs
	
	local w
	local chunks=#()
-- 	for obj in lm_bin do
	for obj in lmTempObs do
	(
		--get the weight of each object
		local  wgt = 0
		for i in 1 to polyop_getNumFaces obj do
		(
			wgt += polyop_getFaceArea obj i
		)
		if wgt != 0 then 
		(
			append chunks (lmChunk obj:obj size:wgt M:"")
		)
	)
	resumeEditing()	
	return chunks
)

fn getLayersWeights layers _reset:false= 
(	
	local theLayersObjs = #()
	local temp_wt			= #()
	local object_wts		= #()
	local sceneWeight 	= 0
	local gUp
	for layer in layers do
	(
		ll = ILayerManager.getLayerObject layer.name
		layerNodes = refs.dependents ll
		local tmpObjArr = #()
		for zz in layerNodes do 
		(
			if superclassof zz == GeometryClass and zz.wirecolor == (color 0 0 255) then 
			(
				gUp=getUserProp zz "#ml_LightMapWeight"
				append tmpObjArr zz
			)
		)
		surfaceArea = 0

		for obj in tmpObjArr do
		(
			for i in 1 to polyop_getNumFaces obj do
			(
				surfaceArea += polyop_getFaceArea obj i
			)
		)
		append temp_wt surfaceArea
	)
	-- get the entire scene wheight
	for i in temp_wt do ( sceneWeight += i ) 
	--normilize the surface area to fit into a 2K map
	for i in temp_wt do 
	(
-- 		if i == 0 then (i = 40)
		wt = (i *(2048/sceneWeight)) as integer
		append object_wts  wt
	)
	return object_wts
)
fn gatherlmInfoMC4_recursive=
(
	local lmTempObs=#()
-- 		local theLayerNames = #("building","prop","ground") -- UI element?
-- 		theLayers=for i in theLayerNames collect (layerManager.getLayerFromName i)
-- 		print (classof theLayers)
-- 		theLayers=for i in _listView.lbx_Layers.selection collect (layermanager.getlayer i)
	theLayers		= #()
	theLayersObjs	= #()
	for i =  1 to LayerManager.count do 
	(
		layerM = LayerManager.getLayer (i-1)
		tokens = filterString layerM.name "_"
		if tokens[1] == "room" or  tokens[1] == "multi"or  tokens[1] == "zone"then
		(
			append theLayers layerM
		)
	)
	for i in theLayers where i != undefined do(join lmTempObs (LayerObjects i))
	max create mode
	suspendEditing()
	for obj in lmTempObs do xResetXform obj--bug at startup 
	local lm_bin=checkChannel2 lmTempObs
	local chunks=#()
	local bin_wt =(getLayersWeights theLayers )
-- 	local bin_wt =(getMapWeight obj)
	
	-- WORK ON OBJECTS 
	for zz = 1 to theLayers.count do
	(
		if bin_wt[zz] != 0 then 
		(
			append chunks (lmChunk obj:lm_bin[zz] size:bin_wt[zz] M:"" )
		)
	)
	resumeEditing()	
	return chunks
)

fn get_LMInfoLayerObjs _string =
(
	local lmTempObs=#()
	local ll = ILayerManager.getLayerObject _string
	local aOL=#()
	ll.nodes &aOL
	for ob in aOL do
	(
		if ( ob.wirecolor == (color 0 0 255 ) ) then
		(
			append lmTempObs ob
		)
	)
	max create mode
	suspendEditing()

	for obj in lmTempObs do xResetXform obj--bug at startup 
	checkChannel2 lmTempObs
	local w
	local chunks=#()
	for obj in lmTempObs do
	(
		w=(getMapWeight obj)
		if w.value != 0 then 
		(
			append chunks (lmChunk obj:obj size:w.value M:"")--(if w.modified then "X" else "")
		)
	)
	resumeEditing();
	return chunks
)

fn renderUVmaps =
(
	--local mapsToRebuild=tt
	local tot=mapsToRebuild.count
	local ratio=800.0/thepack.size
	
-- 	clearlistener();
	clearSelection()
	clearlistener()
	max modify mode
	print "###################"
	print tot
	suspendEditing()

		for i in 1 to tot do
		(	
			obs = #(lmchunks[mapsToRebuild[i]].obj)
				
			if ( _listView.chk_scene.state == true ) then 
			(
				obs=dependents obs[1]

				for zz in obs do
				(
					if zz.wirecolor == (color 0 0 255) then
					(
						selectmore zz
					)
				)
			)
			
			else
			(
				select obs[1]
			)
			_listView.lbl1.text="Rendering UVW map "+(lmchunks[mapsToRebuild[i]].obj.name)
			_listView.pb.value=100*(i/(tot as float))
				
			theUVW=unwrap_UVW()
			theUVW.unwrap.setMapChannel 2
			theUVW.renderUV_width=theUVW.renderUV_height=(lmchunks[mapsToRebuild[i]].size*ratio)
			theUVW.renderUV_force2sided=true
			theUVW.renderUV_fillColor = color 70 70 70
			theUVW.renderUV_fillalpha = 0.2
			theUVW.renderUV_showoverlap=false
			theUVW.showframebuffer=false
			theUVW.renderUV_fillmode=1

	-- 		if ( obs.count > 1 ) then
	-- 		(
				local uv = modPanel.getCurrentObject();
				if (classof uv != Unwrap_UVW ) then
				(
					addmodifier obs theUVW
				)
				if (classof  uv == Unwrap_UVW ) then
				(
	-- 				theUVW = obs.modifiers[#unwrap_uvw]
					theUVW = uv
				)
	-- 		)
			print obs -- need this print to render the map. It's a weird bug, related to the suspendEditing()
			windows.processpostedmessages()
			theUVW.renderUV @"$temp\dummy.png"
			bm=openbitmap @"$temp\dummy.png"
			
			lmchunks[mapsToRebuild[i]].bm=bitmap lmchunks[mapsToRebuild[i]].size lmchunks[mapsToRebuild[i]].size
			copy bm lmchunks[mapsToRebuild[i]].bm
	-- 		deleteModifier obs theUVW
		)
	
	_listView.lbl1.text=""
	_listView.pb.value=0
	mapsToRebuild=#()
	resumeEditing()
	max create mode
)

fn dependents _obj= 
(
	chunkObjs = #(_obj)+(for i in (recurChildren _obj) where (findItem theLayers i.layer>0) collect i)
	--MC4 MOD
	objArr = #()
	for obj in chunkObjs do
	(
		if obj.wirecolor == (color 0 0 255) then
		(
		append objArr (obj)
		)
	)
	return objArr
)
fn CleanupMultiUVs =
(
-- 	SuspendEditing()
-- 	for obj in selection do
-- 	(
-- 		mod_copy =  obj.modifiers[1]
-- 		maxOps.CollapseNode $ off
-- 		addModifier obj mod_copy
-- 	)
-- 	ResumeEditing()
)


fn checkChannel2 _arrayofNodes = --adds a uvw channel 2 if it doesnt exist, and collect parents of hierarchies
(
	local lm_bin=#()
	max create mode
	suspendEditing()
	for i in _arrayofNodes where superclassof i==geometryClass do
	(
		convertToPoly i
		if i.parent==undefined do append lm_bin i
		if  not polyop_getMapSupport i 2 do
		(
			_node=i
			select _node
			uvwmod = Unwrap_UVW()
			addModifier _node uvwmod
			modPanel.setCurrentObject _node.modifiers[#Unwrap_UVW]
			subObjectLevel = 3
			uvwmod.setMapChannel 2
			_node.modifiers[#unwrap_uvw].selectFaces (_node.faces as bitArray)
			uvwmod.flattenMapNoParams()
			collapseStack _node
			format "WARNING: object % doesnt have a UV channel number 2 defined. Using flatten UV\n" _node
			clearSelection()
		)
	)
	resumeEditing()
	return lm_bin
)

if _bitmapHolder!=undefined do destroyDialog _bitmapHolder
--###############################################
--#BUILD THE UI FOR THE TOOL
--###############################################

if _listView !=undefined do destroyDialog _listView
rollout _listView "listView" width:494 height:498
(
	rollout _bitmapHolder "UVW Channel 2" width:800 height:800
	(
		local treeNodes
		local freeNodes
		bitmap _bm pos:[0,0] height:800 width:800
		fn getBox _point =
		(
			for i in treeNodes do
			(
				if contains (box2 i.box.x i.box.y i.chunk.size i.chunk.size) _point do return i
			)
			for i in freeNodes do
			(
				if contains i.box _point do return i
			)
			return undefined
		)
		on _bitmapHolder open do
		(
			treeNodes=thePack.getTreeNodes()
			freeNodes=thePack.getFreeNodes()

		)
--LEFT MOUSE EVENT
		on _bitmapHolder lbuttondown _point2 do
		(	
				clearlistener();
				clearselection()
				local lv=_listView.lv_Objects
				local ratio = thePack.size/800.0
				local mousePos = (1+_point2)*ratio
				local theBox= (getBox mousePos)
	
				if theBox.chunk!=undefined then
				(
					local bin_objs = #(theBox.chunk.obj)
					hlbox=(box2 theBox.box.x theBox.box.y theBox.chunk.size theBox.chunk.size)
					select(dependents theBox.chunk.obj)
		
-- 					if _listView.chk_layer.state != true then
-- 					(
-- 						local bin_objs = dependents bin_objs[1]
-- 						for i in bin_objs do
-- 						(
-- 							if (i.wirecolor == (color 0 0 255)) then (selectmore i)
-- 						)
-- 					)
-- 					else
-- 					(
-- 						select (bin_objs[1]);
-- 					)
					Chunk_ID=findItem (for i in lmchunks collect i.obj) theBox.chunk.obj
					for i in 0 to lv.items.count-1 do 	lv.items.item[i].checked=(lv.items.item[i].tag==Chunk_ID)
				)
				else
				(
					hlbox=(box2 [theBox.box.x, theBox.box.y] [(amin #(theBox.box.right,thePack.size)), (amin #(theBox.box.bottom,thePack.size))])
				)
				if (theBox.chunk != undefined ) then(uv_weight =  theBox.chunk.size)
				hlbm=bitmap hlbox.w hlbox.h color:(color 255 0 0 80)
				cBitmap=thePack.getBitmap()
				pasteBitmap hlbm cBitmap [0,0] [theBox.box.x,theBox.box.y] type:#blend
				nBitmap=bitmap 800 800
				copy cBitmap nBitmap
				_bitmapHolder._bm.bitmap = nBitmap
				CleanupMultiUVs()

		)
--RIGHT MOUSE EVENT
		on _bitmapHolder rbuttondown _point2 do
		(
			clearselection()
			local lv=_listView.lv_Objects
		--print _point2
			local ratio = thePack.size/800.0
			local mousePos = (1+_point2)*ratio
			local theBox= (getBox mousePos)
			local bin_objs = #()
		
			if theBox.chunk!=undefined then
			(
				bin_objs = #( theBox.chunk.obj)
				hlbox=(box2 theBox.box.x theBox.box.y theBox.chunk.size theBox.chunk.size)
				select (dependents theBox.chunk.obj)
-- 				if _listView.chk_layer.state != true then
-- 				(
-- 					local bin_objs = dependents bin_objs[1]
-- 					for i in bin_objs do
-- 					(
-- 						if (i.wirecolor == (color 0 0 255)) then (selectmore i)
-- 					)
-- 				)
-- 				else
-- 				(
-- 					select (bin_objs[1]);
-- 				)
				Chunk_ID=findItem (for i in lmchunks collect i.obj) theBox.chunk.obj
				
				for i in 0 to lv.items.count-1 do 	lv.items.item[i].checked=(lv.items.item[i].tag==Chunk_ID)
			)
			else
			(
				hlbox=(box2 [theBox.box.x, theBox.box.y] [(amin #(theBox.box.right,thePack.size)), (amin #(theBox.box.bottom,thePack.size))])
			)
			if selection.count >0 then
			(
				append mapsToRebuild Chunk_ID
				renderUVmaps()
			)

			if (theBox.chunk != undefined ) then(uv_weight =  theBox.chunk.size)

			hlbm=bitmap hlbox.w hlbox.h color:(color 0 0 255 80)			
			cBitmap=thePack.getBitmap()
			pasteBitmap hlbm cBitmap [0,0] [theBox.box.x,theBox.box.y] type:#blend
			nBitmap=bitmap 800 800
			copy cBitmap nBitmap
			_bitmapHolder._bm.bitmap = nBitmap
			CleanupMultiUVs()
		)
--MIDDLE MOUSE EVENT
		on _bitmapHolder mbuttondown _point2 do
		(
			clearselection()
			local lv=_listView.lv_Objects
		--print _point2
			local ratio = thePack.size/800.0
			local mousePos = (1+_point2)*ratio
			local theBox= (getBox mousePos)
			local bin_objs = #()
		
			if theBox.chunk!=undefined then
			(
				bin_objs = #(theBox.chunk.obj)
				hlbox=(box2 theBox.box.x theBox.box.y theBox.chunk.size theBox.chunk.size)
--				select (dependents theBox.chunk.obj)
 				if _listView.chk_layer.state != true then
 				(
					select (dependents theBox.chunk.obj)
-- 					local bin_objs = dependents bin_objs[1]
-- 					for i in bin_objs do
-- 					(
-- 						if (i.wirecolor == (color 0 0 255)) then (selectmore i)
-- 					)
 				)
 				else
 				(
 					select (bin_objs[1])
 				)
				Chunk_ID=findItem (for i in lmchunks collect i.obj) theBox.chunk.obj
				
				for i in 0 to lv.items.count-1 do 	lv.items.item[i].checked=(lv.items.item[i].tag==Chunk_ID)
			)
			else
			(
				hlbox=(box2 [theBox.box.x, theBox.box.y] [(amin #(theBox.box.right,thePack.size)), (amin #(theBox.box.bottom,thePack.size))])
			)
-- 			local lv=_listView.lv_objects
-- 			local oblist=#()
-- 			for i in 0 to lv.items.count-1 do
-- 			(
-- 				if lv.items.item[i].checked do 
-- 				(
-- 					join obList (dependents lmchunks[lv.items.item[i].tag].obj)
-- 	-- 					appendIfUnique mapsToRebuild i
-- 				)
-- 			)			
-- 			
-- 			if (theBox.chunk != undefined ) then(uv_weight =  theBox.chunk.size)
-- 			--MC pipeline mod
-- 			for i in obList do
-- 			(
-- 				if (i.wirecolor != (color 0 0 255)) then (deselect i)
-- 			)
			oSel = selection as array
			max modify mode
			if ( oSel.count > 0 ) do
			(
				local theUVW = modPanel.getCurrentObject()
				if (classof theUVW != Unwrap_UVW) then
				(
					theUVW=unwrap_UVW()
					theUVW.unwrap.setMapChannel 2
					SuspendEditing()
					addmodifier oSel theUVW
-- 					max create mode
-- 					max modify mode
					ResumeEditing()
					theUVW.edit()
				)
				
				else
				(
					theUVW.edit()
				)
			
			)
			hlbm=bitmap hlbox.w hlbox.h color:(color 0 255 0 80)
			cBitmap=thePack.getBitmap()
			 pasteBitmap hlbm cBitmap [0,0] [theBox.box.x,theBox.box.y] type:#blend
			nBitmap=bitmap 800 800
			copy cBitmap nBitmap
			_bitmapHolder._bm.bitmap = nBitmap

		)
	)

	dotNetControl lv_Objects "System.Windows.Forms.ListView" pos:[32,58] width:271 height:419
	progressBar pb "ProgressBar" pos:[32,32] width:271 height:16
	label lbl1 "" pos:[35,8] width:559 height:17
	GroupBox grp7 "Edit Weights" 				pos:[312,29] width:177 height:133
		GroupBox grp1 "Absolute" 				pos:[320,51] width:160 height:60
			spinner spn_weight "" 					pos:[328,67] width:51 height:16 range:[1,10000,1] type:#integer scale:1
			button btn_Set "Set" 					pos:[386,66] width:40 height:17
			button btn_reset "Reset" 				pos:[429,66] width:40 height:17
			button btn_reset_all "Reset All"		pos:[386,85] width:83 height:17
		GroupBox grp2 "Relative" 					pos:[321,113] width:160 height:43
			spinner spn_Var "" 						pos:[329,130] width:51 height:16 range:[1,10000,50] type:#integer scale:1
			button btn_Add "+" 						pos:[412,129] width:18 height:17
			button btn_Sub "-" 						pos:[388,129] width:18 height:17
			checkbutton ckb_percent "%" 		pos:[443,130]  checked:true width:26 height:16
	
	button btn_editUVW "Edit UVW 2  ->" 	pos:[314,165] width:172 height:23  enabled:false
	button btn_normalizeUV "Normalize UV"	pos:[314,190] width:(84) height:23 enabled:false
	button btn_flattenUV "Flatten UV"			pos:[401,190] width:(84) height:23 enabled:false
	
-- 	multiListBox lbx_layers "Scene Layers" 	pos:[316,220] width:169 height:8
-- 	combobox lbx_layers "Scene Layers"  	pos:[316,220] width:169 height:7
	checkbox chk_onlyvisible "Only Visible" 	pos:[410,219] checked:true
	listbox lbx_layers "Scene Layers" 			pos:[316,220] width:172 height:8 -- items:(for o in objects collect o.name)
	checkbox chk_scene "Scene" 				pos:[316,350] checked:true
	checkbox chk_layer "Layer" 					pos:[380,350] checked:false

	button btn_Load "Load" 						pos:[314,388] width:172 height:23
	button btn_Process "Process" 				pos:[314,420] width:172 height:23 enabled:false
	button btn_Bake "Commit UVs" 				pos:[314,453] width:172 height:23 enabled:false
	
	
-- 	button btn_getSelection "<-Get from Selection" pos:[314,169] width:172 height:23 
	on chk_onlyvisible changed theState do
	(
		local lb=_listview.lbx_layers
		local mc_layers = #()
		sc_layers = for i in 1 to layermanager.count-1 collect (layermanager.getlayer i)
		for layer in sc_layers do
		(
			local tokens = filterstring layer.name "_"
			if (tokens[1] == "room" or tokens[1] == "multi" or  tokens[1] == "zone") then
			(
				if theState == true then
				(
					if layer.ishidden != true then 
					(
						append mc_layers  layer.name
					)
				)
				else
				(
					append mc_layers  layer.name
				)
			)
		)
		sort mc_layers
		lb.items = mc_layers
	)
	
	on chk_scene changed theState do
	( 
		chk_scene.state = true 
		chk_layer.state = false
	)
	on chk_layer changed theState do
	(
		chk_scene.state = false 
		chk_layer.state = true 
	)
	
	on btn_flattenUV pressed do
	(
		CleanupMultiUVs()
		local lv=_listView.lv_Objects
		local siCount=lv.Items.count
		local weights = #()
		-- Get the weight of the current object that is selected
-- 		clearlistener()
		for i =0 to siCount-1 do
		(
			checkTest = (lv.Items.item[i].Checked)
			if checkTest == true then
			(
				local ch_id = lv.Items.item[i].tag
				local lv_wt = (lvops.getlvitemname lv (ch_id-1) 1) as integer
-- 				print  lv_wt
				append weights lv_wt
			)
		)
		local currentWeight = weights[1]

		if currentWeight != undefined then 
		(
			UV_Flatten (currentWeight*2)
			append mapsToRebuild Chunk_ID
			renderUVmaps()
			cBitmap=thePack.getBitmap()
			nBitmap=bitmap 800 800
			copy cBitmap nBitmap
			_bitmapHolder._bm.bitmap = nBitmap	
		)
		
	)
	on btn_normalizeUV pressed do
	(
		UV_Normalize()
		append mapsToRebuild Chunk_ID
		renderUVmaps()
		cBitmap=thePack.getBitmap()
		nBitmap=bitmap 800 800
		copy cBitmap nBitmap
		_bitmapHolder._bm.bitmap = nBitmap	
		CleanupMultiUVs()
	)
	on btn_editUVW pressed do
	(
		CleanupMultiUVs()
		local lv=_listView.lv_objects
		local oblist=#()
		for i in 0 to lv.items.count-1 do
		(
			if lv.items.item[i].checked do 
			(
				join obList (dependents lmchunks[lv.items.item[i].tag].obj)
				appendIfUnique mapsToRebuild i
			)
		)
		if obList.count>0 do
		(
			select obList
			theUVW=unwrap_UVW()
			theUVW.unwrap.setMapChannel 2
			addmodifier obList theUVW
			max create mode
			max modify mode
			theUVW.edit()
		)
	)
	on btn_getSelection pressed do
	(
		local lv=_listView.lv_objects
		for i in 0 to lv.items.count-1 do	lv.items.item[i].checked=lmChunks[(lv.items.item[i].tag)].obj.isSelected
	)
	on btn_Load pressed do
	(
		if (chk_scene.state == true ) then
		(
			local lv=_listView.lv_objects
			lv.items.clear()	
			--The most important part gathering the information
			lmchunks = gatherlmInfoMC4_recursive()
			size = 0
			for item in lmchunks do 
			( 
				if (item.obj.wirecolor == (color 0 0 255) ) then
				(
					size += item.size 
				)
			)
			ratio =  (2048/size)
			for item in lmchunks do( item.size = ratio * item.size)
			mapsToRebuild=for i in 1 to lmChunks.count collect i
-- 			for i in lmchunks do checkUVWBoundingBox i.obj theChannel:2
				
			for i in 1 to lmchunks.count  do 
			(
				chnk=lmchunks[i]
-- 				changed=chnk.readSize()
				lvops.addlvItem lv pTextItems:#(chnk.obj.name,(chnk.size as string),"") ptag:i --if changed then "Y" else "N"
			)
			btn_process.enabled=true
			btn_bake.enabled=true
		)
		else
		(
			local lv				=_listView.lv_objects
			local LayerString	=_listView.lbx_Layers.selected
-- 			local lmchunks	= gatherlmInfoMC4();
			local lmchunks	= gatherlmInfoMC4 LayerString ;
			lv.items.clear()
			-- get all the the sizes of all the objects in the lm_bin	
			size = 0
			for item in lmchunks do 
			( 
				if (item.obj.wirecolor == (color 0 0 255) ) then
				(
					size += item.size 
				)
			)
			local ratio =  (2048.0/size)
			for item in lmchunks do( item.size = (ratio * item.size) as integer)
			mapsToRebuild=for i in 1 to lmChunks.count collect i
-- 	-- 			for i in lmchunks do checkUVWBoundingBox i.obj theChannel:2
				
			for i in 1 to lmchunks.count  do 
			(
				chnk=lmchunks[i]
-- 	-- 				changed=chnk.readSize()
				lvops.addlvItem lv pTextItems:#(chnk.obj.name,(chnk.size as string),"") ptag:i --if changed then "Y" else "N"
			)
			btn_process.enabled=true
			btn_bake.enabled=true
		)
	)
	on btn_Process pressed do
	(
		local lv=_listView.lv_objects
		_listView.btn_Process.enabled=false
		_listView.btn_Load.enabled=false
		_listView.btn_bake.enabled=false
		_listView.btn_flattenUV.enabled=true
		_listView.btn_normalizeUV.enabled=true
		_listView.btn_editUVW.enabled=true
		
		indices=for i in 1 to lmChunks.count collect i
		sizeArray =for i in lmchunks collect i.size
		qsort indices compareFN valArray:sizeArray
		thePack=lmBinaryTree()
		tot=indices.count as float
		cntr=0
		for i in indices do 
		(
			cntr+=1
			_listView.lbl1.text="Packing "+(lmchunks[i].obj.name)
			_listView.pb.value=100*(cntr/tot)
			thePack.pushChunk lmchunks[i]
		)
		
		_listView.lbl1.text=""
		_listView.pb.value=0
		
		renderUVmaps();
		mbmp=thePack.getBitmap() --gets all the bitmaps of each node in the binary tree. 
		bmp2=bitmap 800 800
		copy mbmp bmp2
		if _bitmapHolder!=undefined do destroyDialog _bitmapHolder
		createDialog _bitmapHolder pos:[600,0]
		_bitmapHolder._bm.bitmap=bmp2
		btn_Process.enabled=true -- there's a bug when processing for the second time
		btn_Load.enabled=true
		btn_bake.enabled=true
	)
	on btn_bake pressed do
	(
		sizeRatio=thePack.size/2048.00
		td=for i in (thePack.getTreeNodes()) collect td2 obj:i.chunk.obj data:([i.box.x,i.box.y,i.chunk.size]/sizeRatio)
		max create mode
		SuspendEditing()		
		cntr=1.0
		tot=td.count
		
		if _listView.chk_layer.state != true then
		(
			for i in td do
			(
	-- 			obs=dependents i.obj 
				obs=recurChildren i.obj
				for n in obs do
				(
					windows.processpostedmessages()
					select n
					theUVW=unwrap_UVW()
					theUVW.unwrap.setMapChannel 2
					addmodifier n theUVW
					theUVW.settvsubobjectmode 3

					print n -- weird, but if I don't access the object here, the script do nothing. 

					theUVW.unwrap2.selectFaces (n.faces as bitarray)
					scaleFactor=((i.data.z)/2048)
					paddingFactor=(i.data.z-_padding)/i.data.z

					theUVW.unwrap2.ScaleSelectedCenter paddingFactor 0
					-- fixed so that the uvs look like the layout bitmap image 
					theUVW.unwrap2.ScaleSelectedXY scaleFactor scaleFactor [0,0,0]	
					theUVW.unwrap2.MoveSelected [i.data.x/2048.0, i.data.y/2048.0, 0]
					
					collapseStack n
					
					cntr+=1
					lbl1.text="Remapping UVWs "+(i.obj.name)
					pb.value=100*(cntr/tot)

				)
			)
		)
		else
		(
			for i in td do
			(
			obj = i.obj
	-- 			obs=dependents i.obj 
--				obs=recurChildren i.obj
--				for n in obs do
--				(
					windows.processpostedmessages()
					select obj
					theUVW=unwrap_UVW()
					theUVW.unwrap.setMapChannel 2
					addmodifier obj theUVW
					theUVW.settvsubobjectmode 3

					print obj -- weird, but if I don't access the object here, the script do nothing. 

					theUVW.unwrap2.selectFaces (obj.faces as bitarray)
					scaleFactor=((i.data.z)/2048)
					paddingFactor=(i.data.z-_padding)/i.data.z

					theUVW.unwrap2.ScaleSelectedCenter paddingFactor 0

					theUVW.unwrap2.ScaleSelectedXY scaleFactor scaleFactor [0,0,0]	
					theUVW.unwrap2.MoveSelected [i.data.x/2048.0, i.data.y/2048.0, 0]
					-- fixed so that the uvs look like the layout bitmap image
--					theUVW.unwrap2.ScaleSelectedXY scaleFactor scaleFactor [0,1,0]
--					theUVW.unwrap2.MoveSelected [i.data.x/2048.0, (i.data.y/2048.0 * -1 ), 0] 
					
					collapseStack obj
					
					cntr+=1
					lbl1.text="Remapping UVWs "+(i.obj.name)
					pb.value=100*(cntr/tot)
--
--				)
			)
		)

		ResumeEditing()
		print "****end of process. Close Dialog(s)"
		DestroyDialog _listView
			
	)
	on btn_Add pressed do
	(
		local val=_listView.spn_Var.value
		local lv=_listView.lv_objects
		local chIdx,lvIDX,w
		for i in 0 to lv.items.count-1 do
		(
			if lv.items.item[i].checked do
			(
				chIdx= lv.items.item[i].tag -- index of the lmChunk
				lvIDX= lv.items.item[i].index -- 0 based index in LV
				lw=(lvops.getlvitemname lv lvIDX 1) as integer
				toAdd=if ckb_percent.checked then (val*lw/100) else val
				newVal=lw+toAdd
				lvops.setLVItemName lv lvIDX 1 newVal
				lvops.setLVItemName lv lvIDX 2 "X"
				lmChunks[chIdx].size=newVal
				lmChunks[chIdx].m="X"
				setUserProp lmChunks[chIDX].obj "#ml_LightMapWeight" newVal
				appendIfUnique mapsToRebuild chIdx
			)
		)

	)
	on btn_Sub pressed do
	(
		local val=_listView.spn_Var.value
		local lv=_listView.lv_objects
		local chIdx,lvIDX,w
		for i in 0 to lv.items.count-1 do
		(
			if lv.items.item[i].checked do
			(
				chIdx= lv.items.item[i].tag -- index of the lmChunk
				lvIDX= lv.items.item[i].index -- 0 based index in LV
				lw=(lvops.getlvitemname lv lvIDX 1) as integer
				toAdd=if ckb_percent.checked then (val*lw/100) else val
				newVal=lw-toAdd
				lvops.setLVItemName lv lvIDX 1 newVal
				lvops.setLVItemName lv lvIDX 2 "X"
				lmChunks[chIdx].size=newVal
				lmChunks[chIdx].m="X"
				setUserProp lmChunks[chIDX].obj "#ml_LightMapWeight" newVal
				appendIfUnique mapsToRebuild chIdx
			)
		)

	)
	on _listView close do
	(
		if _bitmapHolder!=undefined do destroyDialog _bitmapHolder
	)
	on btn_reset pressed do
	(
		local lv=_listView.lv_objects
		local chIdx,lvIDX,w
		for i in 0 to lv.items.count-1 do
		(
			if lv.items.item[i].checked do
			(
				chIdx= lv.items.item[i].tag -- index of the lmChunk
				lvIDX= lv.items.item[i].index -- 0 based index in LV
				w=getMapWeight lmChunks[chIdx].obj _reset:true
				
				lvops.setLVItemName lv lvIDX 1 w.value
				lvops.setLVItemName lv lvIDX 2 ""
				lmChunks[chIdx].size=w.value
				lmChunks[chIdx].m=""
				appendIfUnique mapsToRebuild chIdx
			)
		)
	)
	on btn_reset_all pressed do 
	(
		local lv=_listView.lv_objects
		local chIdx,lvIDX,w
		for i in 0 to lv.items.count-1 do
		(
				chIdx= lv.items.item[i].tag -- index of the lmChunk
				lvIDX= lv.items.item[i].index -- 0 based index in LV
				w=getMapWeight lmChunks[chIdx].obj _reset:true
				lvops.setLVItemName lv lvIDX 1 w.value
				lvops.setLVItemName lv lvIDX 2 ""
				lmChunks[chIdx].size=w.value
				lmChunks[chIdx].m=""
				appendIfUnique mapsToRebuild chIdx
		)
	)
	on btn_set pressed do
	(
		local lv=_listView.lv_objects
		local chIdx,lvIDX,w
		for i in 0 to lv.items.count-1 do
		(
			if lv.items.item[i].checked do
			(
				chIdx= lv.items.item[i].tag -- index of the lmChunk
				lvIDX= lv.items.item[i].index -- 0 based index in LV
				w=_listView.spn_weight.value
				
				lvops.setLVItemName lv lvIDX 1 w
				lvops.setLVItemName lv lvIDX 2 "X"
				lmChunks[chIdx].size=w
				lmChunks[chIdx].m="X"
				setUserProp lmChunks[chIDX].obj "#ml_LightMapWeight" w
				appendIfUnique mapsToRebuild chIdx
			)
		)

	)

	on lv_objects MouseClick  do
	(
-- 		clearlistener()
		local lv=_listView.lv_objects
		local currentWeight=0
		local obs=#()
		local siCount=lv.selectedItems.count

		for i in 0 to siCount-1 do
		(
			chIdx = lv.selecteditems.item[i].tag
			lvIDX = lv.selecteditems.item[i].index
			currentWeight +=(lvops.getlvitemname lv lvIDX 1) as integer
			-- get the name of the bin and get its childern that have a blue color
			local obj = getnodebyname ( lvops.getlvitemname lv lvIDX 0) 
			
			if chk_layer.state != true then 
			(
				obs = recurChildren obj
			)
			select obj
-- 			join obs (dependents lmchunks[chIdx].obj)
		)
		if siCount!=0 do (_listView.spn_weight.value=currentWeight/lv.selectedItems.count)
		select obs
	)
	on lv_objects columnclick arg do
	(
		local lv=lv_objects
-- 		clearlistener();
-- 		print (arg.column)
		if ( arg.column == 0 ) then 
		(
			lv.sorting=lv.sorting.ascending
		)
		else
		(
			lv.items.clear()
-- 			indices= for i=1 to LM_Bins.count collect i
			indices=for i in 1 to lmChunks.count collect i
			case arg.column of
			(
-- 				1: sizeArray = for i in LM_Bins collect i.bins_wts
-- 				2: sizeArray = for i in LM_Bins collect i.bins_props
				1:	sizeArray= for i in lmchunks collect i.size
				2:	sizeArray= for i in lmchunks collect i.M
			)
			qsort indices compareFN valArray:sizeArray
			lv.sorting=lv.sorting.none
-- 			for zz in indices do 
-- 			(
-- 				lvArr = #(LM_Bins[zz].bins as string,\
-- 						  LM_Bins[zz].bins_wts as string,\
-- 						  LM_Bins[zz].bins_props as string)
-- 				lvops.addlvItem lv pTextItems:lvArr ptag:zz
-- 			)
-- 			arg.column = 0
			for i in indices do lvops.addlvItem lv pTextItems:#(lmchunks[i].obj.name,(lmchunks[i].size as string),lmchunks[i].M) ptag:i
		)
	)
	on _listView open do
	(
		if heapsize<500000000 do heapsize=500000000
		local lv=_listview.lv_objects
		local lb=_listview.lbx_layers
		local DefaultLayers=#()
		lvops.InitListView lv	pLabelEdit:false \
									pAllowReorder: false \ 
									pCheckBoxes:true\ 
									pFullRowSel:   true \
									pMultiSel:     true \
									pGridLines:    true \
									pHideHeaders:  false\
									pAllowDrop:    false\
									pInitColumns:  #("Object", "Weight","M")  \
									pInitColWidths:#(195,40,20)
		
		--- init and get chunks
		lv.ShowItemToolTips=true
		lv.sorting=lv.sorting.none
-- 		lb.items = for i in 1 to layermanager.count-1 collect (layermanager.getlayer i).name
		--MC4 PIPELINE
		local mc_layers = #()
		sc_layers = for i in 1 to layermanager.count-1 collect (layermanager.getlayer i)
		for layer in sc_layers do
		(
			local tokens = filterstring layer.name "_"
			if (chk_onlyvisible.state == true ) then
			(
				if ( layer.ishidden == false ) then 
				(
					if (tokens[1] == "room" or tokens[1] == "multi" or  tokens[1] == "zone") then
					(
						append mc_layers  layer.name
					)
				)
			)
		)
		sort mc_layers
		lb.items = mc_layers
-- 		lb.Selection=(for i in 1 to lb.items.count where (finditem DefaultLayers lb.items[i])>0 collect i) as bitarray
		
	)
	
)

createDialog _listView pos:[0,0]

