//
//  Action.js
//  Action
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        arguments.completionFunction({ "host" : location.host });
    },
    
    finalize: function(arguments) {
        if (arguments.host) {
            window.alert(arguments.host + ' has been added to Serenus');
        }
    }
    
};
    
var ExtensionPreprocessingJS = new Action();
