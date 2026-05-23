const express = require("express");
const app = express();

app.use("/api/admin", require("./routes/adminRoutes"));

app._router.stack.forEach(function(r){
  if (r.route && r.route.path){
    console.log(r.route.path)
  } else if (r.name === 'router') {
    r.handle.stack.forEach(function(handler){
      if(handler.route) {
        console.log('/api/admin' + handler.route.path)
      }
    });
  }
})
