
function RecipeFinder(host) {
    var subApp = this;
    
    subApp.ws = new WebSocket('ws://' + host);
    
    $('#quantity').on('submit', function(e) {
                  e.preventDefault();
                      
                      //send quantityInput and single quantities as [String]
                  var term = document.getElementById("quantityInput").value;
                     console.log(term);
                  subApp.ws.send(term);
                  });
    
    subApp.ws.onmessage = function (e) {
        document.getElementById("quantityField").innerHTML = e.data;
        
        console.log('Server: ' + e.data);
    };
}
