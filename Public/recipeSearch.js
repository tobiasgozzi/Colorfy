
function RecipeFinder(host) {
    var subApp = this;

    subApp.ws = new WebSocket('ws://' + host);
//    alert('ws://' + host);
    
    $('#form').on('submit', function(e) {
                 e.preventDefault();
                  var term = document.getElementById("searchTermText").value;
                  console.log(term)
                  subApp.ws.send(term);
                  //$("#placeHere").val("inserted text");
                 });

    subApp.ws.onmessage = function (e) {
        document.getElementById("placeHere").innerHTML = e.data;

        console.log('Server: ' + e.data);
    };
    
//    subApp.ws.addEventListener('message', function (event) {
//                                   console.log('Message from server ', event.data);
//                                   });
//    subApp.ws.onmessage = function(event) {
//        event.preventDefault();
//
//        //var message = event.data;
//        alert(typeOf event.data)
//        document.getElementById("placeHere").innerHTML = event.data;
//
//    }
    
}
