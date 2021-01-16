const cl = console.log;
const ce = console.error;
const ci = console.info;
const net = require('net');
const fs = require('fs');

module.exports = {
  config  : {
    host  : '127.0.0.1',
    port  : 9898,
    dbsrc : 'MYDEV',
  }  
}

function go(pobj,res){
  var socket = net.createConnection(module.exports.config.port, module.exports.config.host);
  
  socket
    .on('data', function(data) {
      res.write(data);
    })
  
    .on('connect', function() {
      var js = JSON.stringify(pobj);
      socket.write(js+"\r\n");
    })
  
    .on('end', function() {
      res.end();
    })
  
    .on('error', function(err){
      ce("Pentaho Server: "+err.message);
    })
}

var data = require('./nodedata.json');
go(data,{
  write:function(data){
    //if(data.param._format=='html') 
    cl(data.toString());
    //else if(data.param._format=='pdf') cl(data.toString());
  },
  end: function(){
    cl('quitting');
    process.exit();
  }
});
