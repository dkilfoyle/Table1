var tableInputBinding = new Shiny.InputBinding();
  $.extend(tableInputBinding, {
    
    find: function(scope) {
      return scope.find('.dataTable');
    },
    
    getValue: function(el) {

      var data_encoded = $(el).handsontable('getData');
      
      return JSON.stringify(data_encoded);
    },
    
    setValue: function(el, value) {
      
      var newData = [
        ["Year2", "Kia2", "Nissan2", "Toyota2", "Honda2"],
        ["2008", 10, 11, 12, 13],
        ["2009", 20, 11, 14, 13],
        ["2010", 30, 15, 12, 13]
        ];
        
        
      $(el).handsontable('setData', newData);
    },
    
    subscribe: function(el, callback) {
      $(el).on('change.tableInputBinding', function(e) { callback(); });
    },
    
    unsubscribe: function(el) {
      $(el).off('.tableInputBinding')
    }
  });
  
  Shiny.inputBindings.register(tableInputBinding);