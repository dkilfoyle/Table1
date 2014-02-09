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
      
      console.log("hello setvalue", value)
        
      $(el).handsontable('getInstance'). setDataAtCell( 0, 0, value);
    },
    
    subscribe: function(el, callback) {
      $(el).on('change.tableInputBinding', function(e) { callback(); });
    },
    
    unsubscribe: function(el) {
      $(el).off('.tableInputBinding')
    },
    
    receiveMessage: function(el, data) {
      console.log("tableInputBinding.receiveMessage")
      if (data.hasOwnProperty('value'))
        this.setValue(el, data.value);

      $(el).trigger('change');
    }
  });
  
  Shiny.inputBindings.register(tableInputBinding);