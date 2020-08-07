const express = require("express");
const express_ws = require("express-ws");
const e = require("express");
const uuidv4 = require('uuid').v4;

var app = express();
express_ws(app);

app.use(express.static('static'));

var connections = []

app.ws('/api', (ws, req) => {
    if (connections.length > 8) return;

    connections.push(ws);

    ws.send(JSON.stringify({
        type: "id",
        id: uuidv4()
    }));

    ws.on('message', msg => {
        var parse = JSON.parse(msg);

        if (parse.type == "button" || parse.type == "unbutton") {
            connections.forEach(conn => {
                conn.send(msg);
            });
        } else if (parse.type == "get_peers") {
            ws.send(JSON.stringify({
                "type": "got_peers",
                "peers": connections.filter(conn =>
                    conn != ws
                ).map(conn => {
                    conn.id
                })
            }));
        }
    });

    ws.on('close', () => {
        connections = connections.filter(conn =>
            conn != ws
        );
    });
});

app.listen(8080);