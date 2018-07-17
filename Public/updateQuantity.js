
function RecipeFinder(host) {
    var subApp = this;
    
    subApp.ws = new WebSocket('ws://' + host);
    
    $('#quantity').o('submit', function(e) {
                  e.preventDefault();
                  var term = document.getElementById("quantity").value;
                     console.log(term);
                  subApp.ws.send(term);
                  });
    
    subApp.ws.onmessage = function (e) {
        document.getElementById("placeHere").innerHTML = e.data;
        
        console.log('Server: ' + e.data);
    };
}
