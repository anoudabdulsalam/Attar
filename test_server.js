const express = require('express');
const app = express();
app.use(express.json());
app.use("/api/admin", require("./routes/adminRoutes"));
app.listen(5001, () => {
  console.log("Test server on 5001");
});
