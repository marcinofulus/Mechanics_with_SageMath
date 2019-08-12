from IPython.display import Math
def showmath(expr):
    return Math(latex(expr))
    
def sanitize_namelist(lst):
    new_lst = []
    for x_ in lst:
        if isinstance(  x_ , str):
            v, lv = x_, x_
        elif isinstance( x_, tuple):
            v, lv = x_
        else:
            raise ValueError,'Wrong name: ' + str(type(x_))
        new_lst.append((v, lv))
    return new_lst

def make_symbols(xy_names, uv_names=[], verbose=False):
    """
    Make a variables for CAS manipulation of  
    expressions, including derivatives and pretty typing.
    
    params:
    
    A list of coordinated with their latex_names, must be lower case 
    
    - ``xy_coords = [('x','x'),... ]``
    - ``uv_coords = [('phi',r'\varphi')]``

    For example for variable ``phi``:
     - a function ``Phi(t)`` 
     - variables: ``dphi``, ``phid`` and ``phidd`` 
     will be injected into global namespace. 
    
    To dictionaries will be returned 
    
    - to_fun - for substitution variables to functions, 
                  and their 1st and 2dn derivative
    - to_var - for substitution functions and their 
                1st and 2dn derivativeto variables    
    """
    xy_names = sanitize_namelist(xy_names)
    uv_names = sanitize_namelist(uv_names)

    var('t',domain='real')

    for v,lv in uv_names + xy_names:
    
        var("%s"%v,latex_name=r'%s'%lv)
        globals()[v.capitalize()] = function(v.capitalize())(t)
        var("%sdd"%v, latex_name=r'\ddot %s'%lv)
        var("%sd"%v, latex_name=r'\dot %s'%lv)
        var("d%s"%v, latex_name=r'\delta %s'%lv)
        print v, " :: has been  processed"
     
    uv = [globals()[v] for v,lv in uv_names]
    xy = [globals()[v] for v,lv in xy_names]
    
    to_fun = dict()
    
    for v,lv in uv_names + xy_names:
        to_fun[globals()[v]] = globals()[v.capitalize()]
        to_fun[globals()[v+"d"]] = globals()[v.capitalize()].diff()
        to_fun[globals()[v+"dd"]] = globals()[v.capitalize()].diff(2)
        
    to_var = dict((v,k) for k,v in to_fun.items())
    if verbose:
        print 'we have dictionaries:'
        show( table([ [v,r'$\iff$',k] for k,v in to_var.iteritems()]) )
    return to_fun, to_var


def transform_virtual_displacements(xy_names, uv_names, verbose=False, suffix='_polar'):
    """
    Transform vistual displacements using 
    chain rule of differentiation.

    

    """
    xy_names = sanitize_namelist(xy_names)
    uv_names = sanitize_namelist(uv_names)

    uv = [globals()[v] for v,lv in uv_names]
    xy = [globals()[v] for v,lv in xy_names]
    
    new_variations = []
    for w in xy:
        globals()['d'+repr(w)+suffix] = \
         sum([w.subs(x2u).diff(w2)*globals()['d'+repr(w2)]\
                                             for w2 in uv])
        new_variations.append( globals()['d'+repr(w)+suffix] )
        if verbose:
            print 'd'+repr(w)+suffix+' : is added to namespace'
            show([globals()['d'+repr(w)],globals()['d'+repr(w)+suffix]])
        
    
    return new_variations
