import express from "express";
import env_vars from "../environments/api-environment";

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API route for assets
if (env_vars.ASSET_DIR) {
    app.use("/assets", express.static(`${process.cwd()}/${env_vars.ASSET_DIR}`));
}

/**
 * INSERT DATABASE CONNECTION HERE
 */

import router from "./routes/index";
app.use(router);

app.use(function (req, res) {
    res.status(404).json({ error: "invalid route" });
});

// Launches the server.
app.listen(env_vars.API_PORT, function () {
    console.log(`Server is running on port: ${env_vars.API_PORT}`);
});