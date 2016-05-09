class Asset_Preperation(dict):
 
    '''
    awesome concept from CmiVFX.  Keep the attribute of the names of the object attached to the object 
    it's self.  Obviously some of the ideas are used here.  What this does is makes a dictonary out 
    of our asset names and then sets the up to accept change so we can print it and use the values elsewhere
    '''
    
    
    def __init__(self):
        super(Asset_Preperation, self).__init__()
        
        for name_values in ('game_name', 'type', 'name', 'side','idenifier'):
            self[name_values] = ''
    

    def __repr__(self):

        name_for_printing = """\nGame Name: %(game_name)s 
        \n\t Type: %(type)s 
        \n\tObject Name: %(name)s 
        \n\tSide: %(side)s
        \n\tWhat is it?: %(idenifier)s """ % self
        return name_for_printing
    
    
    # all the following properties are read and write enabled in case we are pulling from one show to
    #another and need to rename on the fly then update the created nodes and the file's current name 
    #when coding
    @property
    def game_name(self):
        return self.get('game_name', '')

    @game_name.setter
    def game_name(self, name_values):
        self['game_name'] = name_values
        
    @property
    def type(self):
        return self.get('type', '')
    
    @type.setter
    def type(self, name_values):
        self['type'] = name_values

    @property
    def name(self):
        return self.get('name', '')
    
    @name.setter
    def name(self, name_values):
        self['name'] = name_values
        
    @property
    def side(self):
        return self.get('side', '')
    
    @side.setter
    def side(self, name_values):
        self['side'] = name_values
        
    @property
    def idenifier(self):
        return self.get('idenifier', '')
    
    @idenifier.setter
    def idenifier(self, name_values):
        self['idenifier'] = name_values