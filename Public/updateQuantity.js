
function RecipeFinder(host) {
    var subApp = this;
    
    subApp.ws = new WebSocket('ws://' + host);
    
    $('#quantity').on('submit', function(e) {
                      
                      
                      e.preventDefault();
                      
                      var term = document.getElementById("quantityInput").value;

                      if (!(isNaN(parseInt(term)))) {
                        var elems = document.querySelectorAll('.quantityField');
                        var values = Array.prototype.map.call(elems, function(obj) {
                          return obj.getAttribute("value");
                        });
                        console.log(values);
                      
                        var quantityFieldString = Array.prototype.map.call(values, function(obj) {
                          var val = parseFloat(obj);
                          if (!(Number.isNaN(val))) {
                            var factor = parseFloat(term)/1000;
                            val *= factor;
                          }
                          return val;
                        });
                        console.log(quantityFieldString);
                      
                      subApp.ws.send(quantityFieldString);
                      } else {
                        alert("Prego inserire un numero senza punti e/o virgole.");
                      }
                  });
    
    subApp.ws.onmessage = function (e) {
        
//        var quantitiesFields = document.getElementsByClassName("quantityField");
        var singleUnits = e.data.split(",");
        console.log(singleUnits);

        for(var i = 0; i<singleUnits.length;++i) {
            console.log(i + " " + singleUnits[i]);
            document.getElementById(i).innerHTML = singleUnits[i];
        }
//        for(const [index, value] of quantitiesFields) {
//            value.innerHTML = singleUnits[index];
//        }

//        var quantitiesFields = document.querySelectorAll(".quantityField");
//        console.log(e);
//        for(const [value, index] of singleUnits) {
//            console.log(index);
//            document.getElementById(index).innerHTML = value;
//        }

        
//        document.getElementById(quantitiesFields[i]).innerHTML = "stringy"//e.data;
        

    };
}
