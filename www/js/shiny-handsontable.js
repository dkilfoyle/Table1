var tableInputBinding = new Shiny.InputBinding();
  $.extend(tableInputBinding, {
    
    find: function(scope) {
      return $(scope).find('.dataTable');
    },
    
    getValue: function(el) {

      var data_encoded = $(el).handsontable('getData');
      
      return JSON.stringify(data_encoded);
    },
    
    setValue: function(el, value) {
      $(el).handsontable('getInstance').loadData(value)
    },
    
    subscribe: function(el, callback) {
      $(el).on('change.dataTable', function(e) { callback(); });
    },
    
    unsubscribe: function(el) {
      $(el).off('.dataTable')
    },
    
    receiveMessage: function(el, data) {
      if (data.hasOwnProperty('value'))
        this.setValue(el, data.value);
        
      $(el).trigger('change');
    }
  });
  
  Shiny.inputBindings.register(tableInputBinding);